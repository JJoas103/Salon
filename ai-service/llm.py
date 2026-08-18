import os
from functools import lru_cache
from langchain_ollama import ChatOllama

# qwen3:8b 가 tool 호출 판단은 더 낫지만, 로컬 Ollama 환경에서 응답 지연이 커서
# 기본값은 1.7b 로 두고 필요할 때만 OLLAMA_MODEL 환경변수로 8b 전환
DEFAULT_MODEL = "qwen3:1.7b"


@lru_cache(maxsize=1)
def get_llm():
    """LLM 인스턴스 (앱 전체에서 공유) — 로컬 Ollama"""
    return ChatOllama(
        model=os.getenv("OLLAMA_MODEL", DEFAULT_MODEL),
        temperature=0.3,
    )
