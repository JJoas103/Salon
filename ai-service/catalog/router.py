import logging

from fastapi import APIRouter, HTTPException

from search.elasticsearch_store import rebuild_index

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/api", tags=["catalog"])

# Spring(SalonService)이 시술 등록/수정/삭제 직후 호출 — 검색 인덱스를 즉시 최신화한다.
@router.post("/reindex")
def reindex() -> dict[str, str | int]:
    try:
        result = rebuild_index()
    except Exception as error:
        logger.exception("시술 인덱스 재색인에 실패했습니다")
        raise HTTPException(
            status_code=503,
            detail=f"시술 인덱스 재색인에 실패했습니다 ({type(error).__name__}: {error})",
        ) from error

    return result
