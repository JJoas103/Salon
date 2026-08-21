from fastapi import APIRouter

from image.main import get_provider, is_enabled

router = APIRouter(tags=["health"])

@router.get("/health")
def health() -> dict[str, str | bool]:
    return {
        "status" : "ok",
        "service" : "python-service",
        # 백엔드가 없으면 스프링이 이미지 메뉴를 아예 그리지 않게 함
        "imageEnabled" : is_enabled(),
        "imageProvider" : get_provider()
    }
