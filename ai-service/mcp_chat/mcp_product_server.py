# 시술 색인과 검색을 제공하는 MCP 서버

from typing import Any
from mcp.server.fastmcp import FastMCP
from search.elasticsearch_store import prepare_index, hybrid_search

# MCP 서버 객체 생성
mcp = FastMCP(
    "salon-service-rag",
    instructions='고민, 가격, 카테고리 조건으로 미용 시술을 검색합니다.'
)

# LLM이 어떤 Tool을 어떻게 호출해야 하는지 알려주는 안내문
SEARCH_GUIDE = """
# 시술 검색 Tool 사용 안내
- query에는 고민이나 시술 종류를 넣습니다. 예: `머리 부스스함`, `손상모 케어`
- `5만원 이하`는 max_price=50000으로 전달합니다.
- `펌만 보여줘`는 category='펌'으로 전달합니다.
- 카테고리 값: 컷, 펌, 염색, 클리닉, 세트
- 가격이나 카테고리 조건이 없으면 해당 인자는 null로 둡니다.
- 후속 질문은 최근 Tool 결과를 먼저 참조하고, 새로운 조건이 생겼을 때만 재검색합니다.
- 시술명, 가격, 소요시간, 유지주기는 Tool 결과에 있는 값만 답변에 사용합니다.
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

if __name__ == '__main__':
    mcp.run(transport='stdio')