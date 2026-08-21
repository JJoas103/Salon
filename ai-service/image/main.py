import base64
import io
import logging
import os
import time

import requests
from PIL import Image, ImageOps

from llm import get_image_llm, IMAGE_MODEL_NAME, IMAGE_QUALITY

logger = logging.getLogger(__name__)


def get_provider() -> str:
    """none(기본) | openai | sdcpp

    상담용 LLM_PROVIDER 와 분리함 — 상담 모델을 GPT 로 바꾼다고 유료 이미지 API 까지
    같이 켜지면 안 되고, 반대로 Ollama 는 이미지를 아예 생성하지 못함
    """
    return os.getenv("IMAGE_PROVIDER", "none").strip().lower()


def is_enabled() -> bool:
    return get_provider() != "none"


def generate_image(
    prompt: str,
    reference_bytes: bytes,
    reference_media_type: str,
) -> tuple[str, str]:
    """참고 이미지를 편집해 (base64, mime) 로 돌려줌"""
    provider = get_provider()
    if provider == "openai":
        return _openai_edit(prompt, reference_bytes, reference_media_type)
    if provider == "sdcpp":
        return _sdcpp_edit(prompt, reference_bytes)
    raise RuntimeError(f"지원하지 않는 IMAGE_PROVIDER 입니다: {provider}")


def _openai_edit(
    prompt: str,
    reference_bytes: bytes,
    reference_media_type: str,
) -> tuple[str, str]:
    reference_base64 = base64.b64encode(reference_bytes).decode("utf-8")

    content = [
        {
            "type": "text",
            "text": prompt.strip(),
        },
        {
            "type": "image",
            "base64": reference_base64,
            "mime_type": reference_media_type,
        },
    ]

    image_tool = {
        "type": "image_generation",
        "quality": IMAGE_QUALITY,
        # edit 은 첨부 이미지를 고쳐 쓰고, create 는 백지에서 그림
        "action": "edit",
    }

    llm = get_image_llm()
    answer = llm.bind_tools([image_tool]).invoke([{"role": "user", "content": content}])

    for block in answer.content_blocks:
        if block.get("type") == "image" and block.get("base64"):
            return block["base64"], block.get("mime_type") or "image/png"

    raise RuntimeError("모델 응답에 생성된 이미지가 없습니다")


# ── 로컬 백엔드 (stable-diffusion.cpp sd-server) ──────────────────────────────
#
# 6800XT/Vulkan 실측 — 512 편집 23초에 VRAM 7.6GB, 1024 는 163초라 512 로 고정함
# Navi21 에 행렬 가속 유닛이 없어(matrix cores: none) 해상도를 올리면 급격히 느려짐

# 512 는 실측으로 고른 값이라 올릴 때는 다시 재야 함
SDCPP_EDGE = int(os.getenv("SDCPP_IMAGE_EDGE", "512"))

# FLUX.2 Klein 은 4스텝 증류 모델이라 더 줘도 나아지지 않음
SDCPP_STEPS = int(os.getenv("SDCPP_STEPS", "4"))

# 증류 모델은 txt_cfg 를 1.0 으로 두고 distilled_guidance 로 조절함
SDCPP_TXT_CFG = 1.0
SDCPP_DISTILLED_GUIDANCE = 3.5

SDCPP_POLL_INTERVAL = 1.0
SDCPP_TIMEOUT_SECONDS = int(os.getenv("SDCPP_TIMEOUT_SECONDS", "180"))

# 첫 요청은 7.2GB 를 VRAM 으로 올리는 시간이 붙음
SDCPP_HTTP_TIMEOUT = 60

# 색 얘기가 없어도 검정 머리가 갈색으로 바뀌는 현상이 3회 전부 재현됨
_COLOR_WORDS = ("색", "컬러", "염색", "탈색", "블리치", "color", "dye", "blond", "brown")

_PRESERVE = ("keep the same person, same face, same skin tone, "
             "same clothing and same background")
_KEEP_COLOR = "keep the original hair color"


def _sdcpp_base() -> str:
    return os.getenv("SDCPP_BASE_URL", "http://localhost:8080").rstrip("/")


def _sdcpp_prompt(prompt: str) -> str:
    """얼굴이 다른 사람으로 밀리는 것과 머리색이 새는 것을 문구로 막음"""
    parts = [prompt.strip(), _PRESERVE]
    if not any(word in prompt.lower() for word in _COLOR_WORDS):
        parts.append(_KEEP_COLOR)
    return ", ".join(parts)


def _normalize_reference(reference_bytes: bytes) -> str:
    """참고 이미지를 SDCPP_EDGE 정사각 PNG 로 맞춰 base64 로 돌려줌

    잘라내지 않고 여백을 채움 — 전신 사진이 들어오면 가운데를 자를 때 머리가 통째로
    날아가는데, 바꿔 보려는 게 머리라 그쪽 실패가 훨씬 나쁨
    """
    source = Image.open(io.BytesIO(reference_bytes))
    # 안 풀면 세로로 찍은 폰 사진이 눕혀진 채로 들어감
    image = ImageOps.exif_transpose(source).convert("RGB")
    image.thumbnail((SDCPP_EDGE, SDCPP_EDGE), Image.LANCZOS)

    canvas = Image.new("RGB", (SDCPP_EDGE, SDCPP_EDGE), (255, 255, 255))
    canvas.paste(image, ((SDCPP_EDGE - image.width) // 2,
                         (SDCPP_EDGE - image.height) // 2))

    buffer = io.BytesIO()
    canvas.save(buffer, format="PNG")
    return base64.b64encode(buffer.getvalue()).decode("utf-8")


def _sdcpp_edit(prompt: str, reference_bytes: bytes) -> tuple[str, str]:
    base = _sdcpp_base()

    # init_image 가 아니라 ref_images 여야 함 — init_image 는 원본에 노이즈를 씌워
    # 다시 그리는 고전 img2img 라 얼굴이 남지 않음. cli 의 -r 에 해당하는 것이 이쪽
    payload = {
        "prompt": _sdcpp_prompt(prompt),
        "ref_images": [_normalize_reference(reference_bytes)],
        "width": SDCPP_EDGE,
        "height": SDCPP_EDGE,
        "batch_count": 1,
        "sample_params": {
            "sample_method": "euler",
            "sample_steps": SDCPP_STEPS,
            "guidance": {
                "txt_cfg": SDCPP_TXT_CFG,
                "img_cfg": SDCPP_TXT_CFG,
                "distilled_guidance": SDCPP_DISTILLED_GUIDANCE,
            },
        },
        "output_format": "png",
    }

    accepted = requests.post(f"{base}/sdcpp/v1/img_gen", json=payload,
                             timeout=SDCPP_HTTP_TIMEOUT)
    accepted.raise_for_status()
    job = accepted.json()

    job_id = job.get("id")
    if not job_id:
        raise RuntimeError(f"sd-server 가 작업 번호를 주지 않았습니다: {job}")

    return _sdcpp_wait(base, job_id)


def _sdcpp_wait(base: str, job_id: str) -> tuple[str, str]:
    """완료될 때까지 폴링함

    sd-server 는 202 만 주고 끝나므로 여기서 기다려 스프링에는 동기로 보이게 함
    512 기준 23초라 이 방식으로 버틸 수 있고, 해상도를 올리면 성립하지 않음
    """
    deadline = time.monotonic() + SDCPP_TIMEOUT_SECONDS

    while True:
        if time.monotonic() > deadline:
            _sdcpp_cancel(base, job_id)
            raise TimeoutError(f"sd-server 작업이 {SDCPP_TIMEOUT_SECONDS}초 안에 끝나지 않았습니다")

        polled = requests.get(f"{base}/sdcpp/v1/jobs/{job_id}",
                              timeout=SDCPP_HTTP_TIMEOUT)
        polled.raise_for_status()
        state = polled.json()
        status = state.get("status")

        if status == "completed":
            images = (state.get("result") or {}).get("images") or []
            if not images or not images[0].get("b64_json"):
                raise RuntimeError("sd-server 응답에 이미지가 없습니다")
            return images[0]["b64_json"], "image/png"

        if status in ("failed", "cancelled"):
            raise RuntimeError(f"sd-server 작업이 {status} 로 끝났습니다: {state.get('error')}")

        time.sleep(SDCPP_POLL_INTERVAL)


def _sdcpp_cancel(base: str, job_id: str) -> None:
    """안 지우면 우리가 포기한 뒤에도 GPU 를 계속 붙잡고 있음"""
    try:
        requests.post(f"{base}/sdcpp/v1/jobs/{job_id}/cancel", timeout=SDCPP_HTTP_TIMEOUT)
    except Exception:
        logger.warning("sd-server 작업을 취소하지 못했습니다: %s", job_id)
