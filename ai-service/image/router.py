import asyncio
import logging
import time
from typing import Annotated

from fastapi import APIRouter, File, Form, HTTPException, UploadFile

from image.main import generate_image, get_provider, is_enabled
from image.schemas import ImageResponse
from vram import image_turn

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/api", tags=["images"])

MAX_REFERENCE_BYTES = 10 * 1024 * 1024

# 상담이 GPU 를 쥐고 있을 때 기다리는 시간
GPU_WAIT_SECONDS = 120


def detect_image_type(content: bytes) -> str | None:
    """확장자·Content-Type 은 브라우저가 보내는 값이라 매직바이트로 다시 봄"""
    if content.startswith(b"\x89PNG\r\n\x1a\n"):
        return "image/png"
    if content.startswith(b"\xff\xd8\xff"):
        return "image/jpeg"
    return None


@router.post("/images", response_model=ImageResponse)
async def create_image(
    prompt: Annotated[str, Form(min_length=1, max_length=1000)],
    image: Annotated[UploadFile, File(...)],
) -> ImageResponse:

    if not is_enabled():
        raise HTTPException(
            status_code=503,
            detail="이미지 생성 백엔드가 설정되어 있지 않습니다",
        )

    clean_prompt = prompt.strip()
    if not clean_prompt:
        raise HTTPException(status_code=400, detail="이미지 생성 문구를 입력하세요")

    try:
        reference_bytes = await image.read(MAX_REFERENCE_BYTES + 1)
    finally:
        await image.close()

    if not reference_bytes:
        raise HTTPException(status_code=400, detail="이미지를 첨부하세요")

    if len(reference_bytes) > MAX_REFERENCE_BYTES:
        raise HTTPException(status_code=413, detail="참고 이미지는 10MB 이하여야 합니다")

    media_type = detect_image_type(reference_bytes)
    if media_type is None:
        raise HTTPException(status_code=400, detail="PNG, JPEG, JPG 이미지만 첨부하세요")

    provider = get_provider()
    start = time.monotonic()
    try:
        # 로컬 백엔드면 여기서 상담 모델이 내려가고, 빠져나올 때 이미지 모델이 내려감
        async with image_turn(provider, GPU_WAIT_SECONDS):
            # 동기 호출이라 그대로 두면 이벤트 루프가 통째로 멈춤
            generated_base64, generated_media_type = await asyncio.to_thread(
                generate_image,
                clean_prompt,
                reference_bytes,
                media_type,
            )
    except TimeoutError as error:
        raise HTTPException(
            status_code=503,
            detail="지금 다른 작업이 GPU 를 쓰고 있습니다. 잠시 후 다시 시도해주세요",
        ) from error
    except Exception as error:
        logger.exception(
            "이미지 생성에 실패했습니다. provider=%s elapsed=%.1fs",
            provider, time.monotonic() - start,
        )
        # 예외 문자열에 키·주소가 들어있어 브라우저로 내보내지 않음
        raise HTTPException(
            status_code=503,
            detail="이미지를 생성할 수 없습니다",
        ) from error

    logger.info(
        "이미지 생성 완료: provider=%s elapsed=%.1fs size=%d",
        provider, time.monotonic() - start, len(generated_base64),
    )

    return ImageResponse(
        imageBase64=generated_base64,
        mediaType=generated_media_type,
        prompt=clean_prompt,
        source="ai-service",
        model=provider,
    )
