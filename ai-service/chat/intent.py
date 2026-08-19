"""질문을 LLM 에 넘기기 전에 백엔드에서 갈래를 먼저 정함

작은 모델에 판단을 맡기면 건너뛰거나 한쪽으로 쏠려서, 무엇을 물었는지는 코드가 정하고
LLM 에게는 그 갈래에 필요한 데이터만 쥐여줌

분류는 규칙 기반임 — LLM 으로 분류하면 호출이 한 번 더 붙어 응답이 20초 가까이 늘어남
확실한 것만 키워드로 잡고 애매하면 SERVICE_SEARCH 로 떨어뜨려서 오탐 피해를 줄임
"""

import re
from enum import Enum


class Intent(str, Enum):
    SERVICE_SEARCH = "service_search"   # 고민/시술로 검색 — 기본값
    CATALOG_LIST = "catalog_list"       # 정렬·전량 (제일 싼, 10만원 넘는)
    SALON_MENU = "salon_menu"           # 특정 매장이 뭘 취급하는지
    SALON_FIND = "salon_find"           # 매장 자체를 고름 (평점, 위치)
    OUT_OF_SCOPE = "out_of_scope"       # 카탈로그에 없는 정보


# 인덱스 어디에도 없는 정보 — 답하려면 지어낼 수밖에 없으므로 LLM 까지 보내지 않음
# 예약/결제/운영은 각자 화면이 따로 있으니 그쪽으로 안내함
OUT_OF_SCOPE_RULES: list[tuple[str, str]] = [
    (r"주차|발렛|주차장", "주차 정보"),
    (r"영업\s*시간|오픈\s*시간|몇\s*시에?\s*(열|닫|문)|휴무|쉬는\s*날|정기휴무", "영업시간"),
    (r"예약\s*(취소|변경|확인|내역)|취소\s*하고|환불|결제\s*취소", "예약·결제"),
    (r"쿠폰|포인트|적립|할인\s*코드", "쿠폰·포인트"),
    (r"탈모\s*(치료|약|병원)|두피\s*질환|피부염|알레르기|부작용", "의학적 판단이 필요한 내용"),
    (r"회원\s*가입|탈퇴|비밀번호|로그인", "계정"),
]

# 매장 자체를 고르려는 질문 — 시술 인덱스가 아니라 salons 인덱스를 봐야 함
# "제일 싼 매장", "어디가 제일 저렴해" 처럼 수식어가 끼므로 인접 매칭을 쓰지 않고
# 매장을 가리키는 말과 고르는 말이 한 문장에 같이 있는지로 판단함
_SALON_WORD = r"(매장|미용실|헤어\s*샵|헤어샵|살롱|가게|샵|어디|어느\s*곳)"
_PICK_WORD = r"(추천|검색|찾|알려|어디|어느|리스트|목록|제일|가장|좋|잘|괜찮|저렴|싼|비싼|평점|별점|후기|리뷰)"

SALON_FIND_RE = re.compile(
    rf"(?=.*{_SALON_WORD})(?=.*{_PICK_WORD})"
    r"|(평점|별점)\s*(높|좋|많)"
    r"|(근처|가까운|주변)\s*(매장|미용실|헤어|샵|살롱)"
)

# 특정 매장을 콕 집어 묻는 질문
# "뭐가 있어" 처럼 조사가 끼어들므로 의문사와 서술어 사이에 여유를 둠
SALON_MENU_RE = re.compile(
    r"(에서|에는|에|의)\s*(뭐|무엇|어떤|무슨)\S{0,3}\s*(있|받|하|가능|해)"
    r"|(취급|메뉴|시술\s*목록)"
    r"|(내가|제가)\s*(갔던|다녔던|이용한|방문한)\s*(매장|곳|가게|미용실)"
)

# 순위·전량 — hybrid_search 로는 못 맞추고 list_catalog 가 필요함
CATALOG_LIST_RE = re.compile(
    r"(제일|가장|최고|최저)\s*(싼|저렴|비싼|짧|긴)"
    r"|(싼|저렴한|비싼)\s*(것|거|시술|순)"
    r"|\d+\s*만?\s*원\s*(넘|이상|이하|미만|아래|밑)"
    r"|(전부|모두|다|전체|종류)\s*(보여|알려|뭐|있)"
    r"|(뭐뭐|무슨)\s*(있|종류)"
    r"|(순서|순위|정렬|리스트|목록)"
)

# 증상만 있는 발화(예: "머리 상했어요")는 따로 가르지 않고 SERVICE_SEARCH 로 보냄
# 되묻기는 system_prompt 의 "추천 먼저, 질문은 마지막" 규칙이 이미 처리하고,
# 규칙으로 가르려 하면 "손상모 케어 추천해줘" 같은 정상 검색까지 되묻기로 새어나감


def classify(question: str) -> tuple[Intent, str | None]:
    """(인텐트, 차단 사유) 를 돌려줌 — 차단 사유는 OUT_OF_SCOPE 일 때만 채워짐"""
    text = (question or "").strip()
    if not text:
        return Intent.SERVICE_SEARCH, None

    normalized = re.sub(r"\s+", " ", text)

    for pattern, label in OUT_OF_SCOPE_RULES:
        if re.search(pattern, normalized):
            return Intent.OUT_OF_SCOPE, label

    # 특정 매장의 메뉴를 묻는 쪽이 더 좁으므로 매장 고르기보다 먼저 검사함
    if SALON_MENU_RE.search(normalized):
        return Intent.SALON_MENU, None

    if SALON_FIND_RE.search(normalized):
        return Intent.SALON_FIND, None

    if CATALOG_LIST_RE.search(normalized):
        return Intent.CATALOG_LIST, None

    return Intent.SERVICE_SEARCH, None


def _subject_josa(word: str) -> str:
    """받침 유무로 은/는 을 고름 — "영업시간는" 처럼 어색하게 나가지 않도록"""
    if not word:
        return "는"
    last = word[-1]
    if "가" <= last <= "힣":
        return "은" if (ord(last) - 0xAC00) % 28 else "는"
    return "는"


def out_of_scope_answer(reason: str) -> str:
    """차단된 질문에 돌려줄 고정 문구 — 어디로 가면 되는지까지 알려줌"""
    guide = {
        "주차 정보": "매장 상세 페이지에 주소와 연락처가 있으니 매장에 직접 확인해 주세요.",
        "영업시간": "매장 상세 페이지에서 영업시간을 확인하실 수 있습니다.",
        "예약·결제": "마이페이지 > 예약 내역에서 확인하고 변경하실 수 있습니다.",
        "쿠폰·포인트": "마이페이지에서 보유하신 쿠폰과 포인트를 확인하실 수 있습니다.",
        "의학적 판단이 필요한 내용": "두피나 피부 상태는 전문의 상담이 필요합니다.",
        "계정": "마이페이지에서 계정 정보를 관리하실 수 있습니다.",
    }.get(reason, "")

    return (
        f"{reason}{_subject_josa(reason)} 시술 상담에서 다루지 않습니다. {guide}\n\n"
        "어떤 시술이 좋을지, 가격이 얼마인지 궁금하시면 말씀해 주세요."
    ).strip()
