import base64
import os

from llm import get_image_llm, IMAGE_MODEL_NAME, IMAGE_QUALITY


def get_provider() -> str:
    """none(기본) | openai | comfy

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
