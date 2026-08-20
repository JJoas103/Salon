"""매장 자체를 고르는 질문에 쓰는 salons 인덱스 조회

시술 인덱스에는 평점도 주소도 없어서 "어디가 잘해요" 에 답할 수 없음
같은 ES 인스턴스의 다른 인덱스라 클라이언트는 재사용함
"""

from typing import Any

from search.elasticsearch_store import client, ensure_elasticsearch

SALON_INDEX = 'salons'

# 상담에 쓸 필드만 추림 (좌표는 안 씀)
_FIELDS = ['salonId', 'salonName', 'address', 'phoneNumber',
           'description', 'averageRating', 'minimumPrice']


def search_salons(
    keyword: str | None = None,
    sort_by: str = 'averageRating',
    count: int = 5,
) -> list[dict[str, Any]]:
    """매장을 평점순(기본) 또는 최저가순으로 돌려줌

    keyword 를 주면 매장명·주소·소개문에서 찾고, 없으면 전체를 정렬만 해서 돌려줌
    """
    ensure_elasticsearch()

    if keyword:
        query: dict[str, Any] = {
            'multi_match': {
                'query': keyword,
                'fields': ['salonName^3', 'address^2', 'description'],
            }
        }
    else:
        query = {'match_all': {}}

    # 평점은 높은 순, 가격은 낮은 순
    if sort_by == 'minimumPrice':
        sort = [{'minimumPrice': {'order': 'asc'}}]
    else:
        sort = [{'averageRating': {'order': 'desc'}}]

    response = client.search(
        index=SALON_INDEX,
        size=max(1, min(count, 20)),
        query=query,
        sort=sort,
        source_includes=_FIELDS,
    )
    return [hit['_source'] for hit in response['hits']['hits']]


def salon_find_hint(question: str, count: int = 5) -> str | None:
    """SALON_FIND 인텐트일 때 첫 턴에 붙일 매장 목록 — 9B 는 도구 선택을 자주 건너뜀"""
    # "저렴한/싼" 이면 가격 기준, 아니면 평점 기준
    sort_by = 'minimumPrice' if any(k in question for k in ('저렴', '싼', '가격', '저가')) else 'averageRating'

    try:
        salons = search_salons(sort_by=sort_by, count=count)
    except Exception:
        return None

    if not salons:
        return None

    lines = []
    for s in salons:
        rating = s.get('averageRating')
        price = s.get('minimumPrice')
        parts = [s.get('salonName', '')]
        if rating is not None:
            parts.append(f"평점 {rating}")
        if price:
            parts.append(f"최저 {int(price):,}원")
        if s.get('address'):
            parts.append(s['address'])
        if s.get('description'):
            parts.append(s['description'])
        lines.append("- " + " / ".join(str(p) for p in parts if p))

    label = "최저가순" if sort_by == 'minimumPrice' else "평점순"
    return (
        f"[등록된 매장 {label} 목록]\n"
        + "\n".join(lines)
        + "\n이 목록에 없는 매장은 존재하지 않습니다. 평점과 가격은 이 값만 사용하세요."
    )


def list_salon_names() -> list[dict[str, Any]]:
    """등록된 매장의 id 와 이름 — chat/links.py 가 답변과 대조할 때 씀

    매장 수가 두 자리라 통째로 받아도 부담 없고, 폐업 매장은 색인에서 이미 빠져 있음
    """
    ensure_elasticsearch()

    response = client.search(
        index=SALON_INDEX,
        size=1000,
        query={'match_all': {}},
        source_includes=['salonId', 'salonName'],
    )
    return [hit['_source'] for hit in response['hits']['hits']]
