"""답변에 나온 매장을 예약 화면으로 이어주는 목록

LLM 이 링크를 쓰게 하면 없는 매장과 엉뚱한 id 를 지어내므로, 답변 본문과 salons 인덱스를
대조해 실재하는 매장만 골라냄
URL 조립은 JSP 가 함 — ai-service 는 스프링의 URL 구조를 모름
"""

from typing import Any

MAX_LINKS = 3


def _normalize(name: str) -> str:
    return (name or "").replace(" ", "")


def _all_salons() -> list[dict[str, Any]]:
    # ES 가 죽어도 상담 답변은 나가야 하므로 링크만 포기함
    try:
        from search.salon_store import list_salon_names
        return list_salon_names()
    except Exception:
        return []


def _entry(salon: dict[str, Any]) -> dict[str, Any] | None:
    salon_id = salon.get('salonId')
    name = salon.get('salonName')
    if salon_id is None or not name:
        return None
    return {'salonId': int(salon_id), 'salonName': str(name)}


def reservation_links(answer: str) -> list[dict[str, Any]]:
    """답변에 이름이 나온 매장을 등장 순서대로 최대 3곳"""
    text = _normalize(answer)
    if not text:
        return []

    found: list[tuple[int, dict[str, Any]]] = []
    seen: set[int] = set()
    for salon in _all_salons():
        entry = _entry(salon)
        if entry is None or entry['salonId'] in seen:
            continue
        position = text.find(_normalize(entry['salonName']))
        if position < 0:
            continue
        seen.add(entry['salonId'])
        found.append((position, entry))

    # 먼저 언급된 매장이 대개 첫 추천임
    found.sort(key=lambda item: item[0])
    return [entry for _, entry in found[:MAX_LINKS]]


def salon_link(salon_id: int | None) -> list[dict[str, Any]]:
    """매장 상세 페이지에서 물었을 때 그 매장 한 곳만"""
    if salon_id is None:
        return []

    for salon in _all_salons():
        if str(salon.get('salonId')) == str(salon_id):
            entry = _entry(salon)
            return [entry] if entry else []
    return []
