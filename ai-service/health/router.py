from fastapi import APIRouter

from image.main import get_provider, is_enabled

router = APIRouter(tags=["health"])

@router.get("/health")
def health() -> dict[str, str | bool]:
    return {
        "status" : "ok",
        "service" : "python-service",
        # 스프링은 아직 이 값을 보지 않음 — 꺼진 채로 요청이 오면 라우터가 503 을 냄
        "imageEnabled" : is_enabled(),
        "imageProvider" : get_provider()
    }
