import os

# 환경변수 설정
HOST = os.getenv("FASTAPI_HOST", "localhost")
PORT = int(os.getenv("FASTAPI_PORT", "8000"))