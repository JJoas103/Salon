from functools import lru_cache
from langchain_ollama import ChatOllama


@lru_cache(maxsize=1)
def get_llm():
    """LLM 인스턴스 (앱 전체에서 공유) — 로컬 Ollama"""
    return ChatOllama(
        model="qwen3:8b",
        temperature=0.3,
    )
