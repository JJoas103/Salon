"""VRAM 에 모델이 한 번에 하나만 올라가도록 순서를 잡는 중재자

16GB 에 상담 모델(qwen3.5:9b 6.6GB)과 이미지 모델(Q4 기준 14GB)이 같이 안 들어감
둘 중 하나를 내리고 들어가야 해서, 내리는 시점을 여기 한 군데로 모음

내려도 GGUF 는 OS 페이지 캐시에 남아 다시 올릴 때 디스크를 다시 읽지 않음 —
왕복 비용이 첫 로딩보다 훨씬 싼 이유가 이것

IMAGE_PROVIDER 가 openai 면 이미지가 VRAM 을 안 쓰므로 아무것도 하지 않음
"""

import asyncio
import logging
import os
from contextlib import asynccontextmanager

import requests

logger = logging.getLogger(__name__)

# 상담과 이미지가 같은 GPU 를 두고 번갈아 씀
_gpu_lock = asyncio.Lock()

# 언로드는 실패해도 요청을 막지 않음 — 짧게 끊고 로그만 남김
_UNLOAD_TIMEOUT = 10


def _ollama_base() -> str:
    return os.getenv("OLLAMA_BASE_URL", "http://localhost:11434").rstrip("/")


def _comfy_base() -> str:
    return os.getenv("COMFY_BASE_URL", "http://localhost:8188").rstrip("/")


def _unload_ollama() -> None:
    """올라와 있는 모델을 전부 내림

    이름을 고정하지 않고 /api/ps 로 실제 적재된 것만 봄 — 상담이 쓰는 모델과
    OLLAMA_MODEL 이 어긋나 있어도 남는 것이 없게 함
    """
    base = _ollama_base()
    try:
        loaded = requests.get(f"{base}/api/ps", timeout=_UNLOAD_TIMEOUT).json()
    except Exception:
        logger.warning("Ollama 적재 목록을 읽지 못했습니다: %s", base)
        return

    for model in loaded.get("models", []):
        name = model.get("name")
        if not name:
            continue
        try:
            # keep_alive 0 이면 응답 직후 내려감
            requests.post(
                f"{base}/api/generate",
                json={"model": name, "keep_alive": 0},
                timeout=_UNLOAD_TIMEOUT,
            )
            logger.info("Ollama 모델을 내렸습니다: %s", name)
        except Exception:
            logger.warning("Ollama 모델을 내리지 못했습니다: %s", name)


def _unload_comfy() -> None:
    try:
        requests.post(
            f"{_comfy_base()}/free",
            json={"unload_models": True, "free_memory": True},
            timeout=_UNLOAD_TIMEOUT,
        )
        logger.info("ComfyUI 모델을 내렸습니다")
    except Exception:
        logger.warning("ComfyUI 모델을 내리지 못했습니다: %s", _comfy_base())


@asynccontextmanager
async def image_turn(provider: str, wait_seconds: float):
    """이미지 생성이 GPU 를 잡는 구간

    들어갈 때 상담 모델을 내리고, 나올 때 이미지 모델을 내려 상담이 바로 올라오게 함
    """
    local = provider not in ("openai", "none")

    try:
        await asyncio.wait_for(_gpu_lock.acquire(), wait_seconds)
    except (asyncio.TimeoutError, TimeoutError):
        raise TimeoutError("GPU 를 쓰고 있는 다른 작업이 끝나지 않았습니다")

    try:
        if local:
            await asyncio.to_thread(_unload_ollama)
        yield
    finally:
        if local:
            await asyncio.to_thread(_unload_comfy)
        _gpu_lock.release()


async def acquire_gpu(wait_seconds: float) -> None:
    """상담이 GPU 차례를 잡음

    이미지 쪽이 나갈 때 자기 모델을 내리므로 여기서는 순서만 기다리면 됨
    잡는 순서는 항상 상담 락 → 이 락 — 반대로 잡는 경로를 만들면 교착이 생김
    """
    try:
        await asyncio.wait_for(_gpu_lock.acquire(), wait_seconds)
    except (asyncio.TimeoutError, TimeoutError):
        raise TimeoutError("GPU 를 쓰고 있는 다른 작업이 끝나지 않았습니다")


def release_gpu() -> None:
    # locked() 로 감싸면 남의 락까지 풀 수 있음 — 잡은 쪽에서만 부르는 전제
    _gpu_lock.release()


@asynccontextmanager
async def chat_turn(wait_seconds: float):
    await acquire_gpu(wait_seconds)
    try:
        yield
    finally:
        release_gpu()
