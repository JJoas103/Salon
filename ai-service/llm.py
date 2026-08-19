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

# 추론만 별도 머신(6800XT 데스크탑)으로 넘길 때 쓰는 스위치
# 환경변수를 안 주면 이 머신의 내장그래픽으로 그대로 돌아감
DEFAULT_BASE_URL = "http://localhost:11434"

DEFAULT_OPENAI_MODEL = "gpt-4o-mini"
TEMPERATURE = 0.3


@lru_cache(maxsize=1)
def get_llm():
    """LLM 인스턴스 (앱 전체에서 공유)
       LLM_PROVIDER=openai 면 OpenAI, 그 외에는 로컬 Ollama 를 씀"""
    if os.getenv("LLM_PROVIDER", "ollama").strip().lower() == "openai":
        return _openai_llm()
    return _ollama_llm()


def _ollama_llm() -> ChatOllama:
    return ChatOllama(
        model=os.getenv("OLLAMA_MODEL", DEFAULT_MODEL),
        base_url=os.getenv("OLLAMA_BASE_URL", DEFAULT_BASE_URL),
        temperature=TEMPERATURE,
        num_ctx=int(os.getenv("OLLAMA_NUM_CTX", DEFAULT_NUM_CTX)),
    )


def _openai_llm():
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
            "저장소 루트 .env 또는 환경변수에 키를 설정하세요"
        )

    return ChatOpenAI(
        model=os.getenv("OPENAI_MODEL", DEFAULT_OPENAI_MODEL),
        api_key=api_key,
        temperature=TEMPERATURE,
    )
