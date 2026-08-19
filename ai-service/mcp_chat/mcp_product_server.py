# 시술 색인과 검색을 제공하는 MCP 서버

from typing import Any
from mcp.server.fastmcp import FastMCP
from search.elasticsearch_store import prepare_index, hybrid_search, list_services

# MCP 서버 객체 생성
mcp = FastMCP(
    "salon-service-rag",
    instructions='고민, 가격, 카테고리 조건으로 미용 시술을 검색합니다.'
)

# LLM이 어떤 Tool을 어떻게 호출해야 하는지 알려주는 안내문
SEARCH_GUIDE = """
# 시술 검색 Tool 사용 안내
- query에는 고민이나 시술 종류를 넣습니다. 예: `부스스한 모발`, `손상모 갈라짐`
- `5만원 이하`는 max_price=50000으로 전달합니다.
- `펌만 보여줘`는 category='펌'으로 전달합니다.
- 카테고리 값: 컷, 펌, 염색, 클리닉, 세트
- 가격이나 카테고리 조건이 없으면 해당 인자는 null로 둡니다.
- 후속 질문은 최근 Tool 결과를 먼저 참조하고, 새로운 조건이 생겼을 때만 재검색합니다.
- `제일 저렴한`, `가장 비싼`, `10만원 넘는 것 전부`, `무슨 종류가 있어` 처럼 순위나 전체 목록을
  묻는 질문은 search_service 가 아니라 list_catalog 를 씁니다. search_service 는 관련도 상위
  몇 건만 돌려주므로 최저가/최고가를 물으면 틀린 답이 나옵니다.
- 예약 이력에 있는 매장이 그 시술을 취급하는지 확인할 때는 list_catalog 에 salon='매장명' 을 넣습니다.
  0건이면 그 매장에는 없는 것이므로 추측하지 말고 없다고 답합니다.
- 시술명, 가격, 소요시간, 매장명, 추천고민은 Tool 결과에 있는 값만 답변에 사용합니다.
- 시술을 소개할 때는 매장명을 괄호에 넣지 말고 `매장: OO` 처럼 가격과 같은 형태의 항목으로
  가장 먼저 적습니다. 예약하려면 어느 매장인지가 가격보다 먼저 필요합니다.
- 검색 결과가 2건 이상이면 상위 3건까지 같은 형식으로 나열합니다. 한 건만 남기지 않습니다.
- 유지주기/관리주기 같은 값은 카탈로그에 없습니다. 물어보면 매장 데이터가 아니라 일반 정보임을 밝히고 답합니다.
""".strip()

# MCP 리소스 등록
@mcp.resource('catalog://salon/search-guide')
def search_guide() -> str:
    """시술 검색 Tool의 인자 변환 규칙과 답변 근거 규칙이다."""
    return SEARCH_GUIDE

# MCP 프롬프트 등록
@mcp.prompt()
def salon_consult_prompt(tone: str = '친절하고 전문적인') -> str:
    """사용자가 선택할 수 있는 시술 상담 프롬프트 템플릿이다."""
    return (
        f'{tone} 미용 시술 상담을 진행해 주세요. 시술 검색이 필요한 첫 질문에는 '
        'prepare_service_index를 먼저 호출하고, search_service를 호출하세요. '
        '사용자의 자연어 가격과 카테고리 조건은 search_service의 인자로 구조화하세요. '
        '"그중", "두 번째", "방금 시술" 같은 후속 질문은 최근 대화와 Tool 결과를 사용하고 '
        '불필요한 재검색을 피하세요.'
    )

# MCP 도구 등록(1): 인덱스 생성
@mcp.tool()
def prepare_service_index() -> dict[str, Any]:
    """전용 Elasticsearch 인덱스와 시술 카탈로그를 준비한다."""
    return prepare_index()

# MCP 도구 등록(2): 시술 검색
@mcp.tool()
def search_service(
    query: str,
    max_price: int | None = None,
    category: str | None = None,
    count: int = 5
) -> dict[str, Any]:
    """시술을 검색한다. 가격은 원 단위 상한, 카테고리는 한글 문자열로 받는다.
    query에는 가격, 카테고리 표현을 제외한 고민이나 시술 특징을 넣는다.
    예를 들어 '5만원 이하 펌'은 query='펌', max_price=50000, category='펌'이다.
    카테고리 값: 컷, 펌, 염색, 클리닉, 세트
    """
    if max_price is not None:
        if max_price <= 0 or max_price > 100000000:
            raise ValueError('max_price는 1원 이상 1억 원 이하이어야 합니다.')

    if count < 1:
        count = 1
    elif count > 10:
        count = 10

    # ES에서 검색
    results = hybrid_search(
        query=query,
        max_price=max_price,
        category=category,
        count=count
    )

    # LLM에게 전달
    return {
        'query': query,
        'filters': {
            'max_price': max_price,
            'category': category,
        },
        'result_count': len(results),
        'services': results
    }
@mcp.tool()
def list_catalog(
    category: str | None = None,
    salon: str | None = None,
    sort_by: str = 'price',
    order: str = 'asc',
    count: int = 20,
) -> dict[str, Any]:
    """카탈로그를 정렬해서 목록으로 돌려준다. 검색이 아니라 순위/전량 조회용이다.
    '제일 저렴한 시술', '가장 비싼 것', '10만원 넘는 것 전부', '염색 종류 뭐 있어'처럼
    최저가·최고가·전체 목록을 묻는 질문에 쓴다.
    sort_by 는 price 또는 duration_min, order 는 asc 또는 desc 이다.
    category 를 주면 그 카테고리만, 안 주면 전체를 본다.
    salon 에 매장명을 주면 그 매장이 취급하는 시술만 본다.
    사용자 예약 이력에 있는 매장에 그 시술이 있는지 확인할 때 salon 을 쓴다.
    카테고리 값: 컷, 펌, 염색, 클리닉, 세트
    """
    if category is not None and not str(category).strip():
        category = None
    if salon is not None and not str(salon).strip():
        salon = None
    try:
        items = list_services(
            category=category,
            salon=salon,
            sort_by=sort_by,
            order=order,
            count=count,
        )
    except Exception as exc:
        return {'ok': False, 'error': str(exc), 'items': []}

    return {'ok': True, 'count': len(items), 'items': items}


if __name__ == '__main__':
    mcp.run(transport='stdio')
