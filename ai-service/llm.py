import os
from functools import lru_cache
from pathlib import Path

from dotenv import load_dotenv
from langchain_ollama import ChatOllama

# 저장소 루트와 ai-service 의 .env 를 둘 다 읽음 (강사 완성본 chapter15 방식)
load_dotenv(Path(__file__).resolve().parent.parent / ".env")
load_dotenv()

# 8b/14b/9b 를 실제 상담 질문 15개로 비교한 결과 9b 가 속도·정확도 모두 1위였음
# 8b 는 개인화 질문에서 카탈로그에 없는 시술을 지어내고, 대화가 길어지면 응답이 160초까지 늘어남
DEFAULT_MODEL = "qwen3.5:9b"

# Ollama 기본 num_ctx 는 4096 인데, SEARCH_GUIDE + tool 스키마 + 예약이력 + 검색결과 +
# qwen3 thinking 블록이 겹치면 5턴만에 3천 토큰을 넘김
# 넘치는 순간 오래된 쪽부터 잘려나가므로 여유를 두고 16384 로 올림
DEFAULT_NUM_CTX = 16384

# 어느 Ollama 에 물을지 — 안 주면 이 PC, 다른 주소를 주면 그 PC 가 대신 추론함
DEFAULT_BASE_URL = "http://localhost:11434"

DEFAULT_OPENAI_MODEL = "gpt-4o-mini"
TEMPERATURE = 0.3


# Y/N 한 글자면 되지만 조사가 붙어 나올 때를 봐서 여유를 둠
GATE_MAX_TOKENS = 4


def _use_openai() -> bool:
    return os.getenv("LLM_PROVIDER", "ollama").strip().lower() == "openai"


@lru_cache(maxsize=1)
def get_llm():
    """LLM 인스턴스 (앱 전체에서 공유)
       LLM_PROVIDER=openai 면 OpenAI, 그 외에는 로컬 Ollama 를 씀"""
    if _use_openai():
        return _openai_llm()
    return _ollama_llm()


@lru_cache(maxsize=1)
def get_gate_llm():
    """도메인 게이트 전용 인스턴스

    상담과 같은 모델을 씀 — 더 작은 모델을 쓰면 Ollama 가 매번 모델을 바꿔 올리느라
    판정(1초 미만)보다 교체가 더 걸림
    """
    if _use_openai():
        return _openai_llm(temperature=0, max_tokens=GATE_MAX_TOKENS)
    return _ollama_llm(temperature=0, num_predict=GATE_MAX_TOKENS)


def _ollama_llm(temperature: float = TEMPERATURE,
                num_predict: int | None = None) -> ChatOllama:
    return ChatOllama(
        model=os.getenv("OLLAMA_MODEL", DEFAULT_MODEL),
        base_url=os.getenv("OLLAMA_BASE_URL", DEFAULT_BASE_URL),
        temperature=temperature,
        num_predict=num_predict,
        num_ctx=int(os.getenv("OLLAMA_NUM_CTX", DEFAULT_NUM_CTX)),
        # 사고 과정을 끔
        # qwen3.5 는 사고형 모델이라 생각을 thinking 으로 따로 내보내는데, 그 턴을 생각으로만
        # 채우고 본문을 비워 보내는 일이 있어 빈 답변이 나갔음
        # 시술 상담은 검색 결과를 정리해 보여주는 일이라 긴 추론이 필요하지 않고, 끄면 그만큼 빨라짐
        reasoning=False,
    )


def _openai_llm(temperature: float = TEMPERATURE, max_tokens: int | None = None):
    # 로컬 전용으로 돌릴 때는 langchain-openai 가 없어도 되도록 여기서 임포트함
    try:
        from langchain_openai import ChatOpenAI
    except ImportError as exc:
        raise RuntimeError(
            "langchain-openai 가 설치되어 있지 않습니다. "
            "pip install langchain-openai 후 다시 시도하세요"
        ) from exc

    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        raise RuntimeError(
            "OPENAI_API_KEY 가 없습니다. "
            "ai-service/.env 또는 환경변수에 키를 설정하세요"
        )

    return ChatOpenAI(
        model=os.getenv("OPENAI_MODEL", DEFAULT_OPENAI_MODEL),
        api_key=api_key,
        temperature=temperature,
        max_tokens=max_tokens,
    )
