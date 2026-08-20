"""미용실과 무관한 질문을 상담에 들이기 전에 걸러냄

intent.classify 는 차단 목록이라 목록에 없는 주제는 전부 통과함
("서울대학교 알아?" → SERVICE_SEARCH, "대한민국 수도가 어디야" → '어디' 때문에 SALON_FIND)
미용실 밖이 무엇인지는 목록으로 못 적으므로 이 갈래만 LLM 이 판정함

도구도 대화기록도 없이 Y/N 한 글자만 받으면 0.85초임 (qwen3.5:9b, 23건 평균)
도메인 밖이면 25~43초짜리 에이전트 턴을 건너뛰므로 오히려 빠름
"""

import asyncio
import logging

from langchain_core.messages import HumanMessage, SystemMessage

from llm import get_gate_llm

logger = logging.getLogger(__name__)

GATE_TIMEOUT_SECONDS = 10

GATE_PROMPT = (
    "너는 미용실 시술 상담 서비스의 입력 필터다. "
    "사용자 발화가 이 서비스에서 다룰 수 있는 것인지만 판정한다.\n"
    "다룰 수 있는 것: 헤어 시술, 고민/증상, 가격, 소요시간, 미용실 매장, 디자이너, 예약.\n"
    "다룰 수 없는 것: 그 외 모든 주제(일반 상식, 인물, 지명, 날씨, 뉴스, 코딩, 요리 등).\n"
    "짧은 맞장구나 후속 발화('네', '그거 말고', '두 번째 거')는 상담이 이어지는 중이므로 Y 다.\n"
    "관련 있으면 Y, 없으면 N 한 글자만 출력한다. 설명하지 않는다."
)


def _verdict(content) -> str:
    # 일부 모델은 content 를 블록 리스트로 돌려줌
    if isinstance(content, list):
        content = "".join(
            block.get("text", "")
            for block in content
            if isinstance(block, dict) and block.get("type") == "text"
        )
    return str(content).strip().upper()


async def is_in_domain(question: str) -> bool:
    """미용실 상담으로 다룰 수 있는 질문인지 — 판정이 안 되면 통과시킴"""
    text = (question or "").strip()
    if not text:
        return True

    try:
        answer = await asyncio.wait_for(
            get_gate_llm().ainvoke([
                SystemMessage(content=GATE_PROMPT),
                HumanMessage(content=text),
            ]),
            GATE_TIMEOUT_SECONDS,
        )
    except Exception:
        logger.exception("도메인 게이트 판정 실패 — 질문을 통과시킴")
        return True

    # N 으로 시작할 때만 막음. 빈 값이나 엉뚱한 글자는 통과
    return not _verdict(answer.content).startswith("N")


def off_domain_answer() -> str:
    return (
        "저는 헤어 시술과 매장 상담만 도와드릴 수 있습니다.\n\n"
        "어떤 시술이 좋을지, 가격이 얼마인지, 어느 매장이 괜찮은지 궁금하시면 말씀해 주세요."
    )
