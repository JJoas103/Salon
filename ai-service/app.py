from fastapi import FastAPI
from health.router import router as health_router
from chat.router import router as chat_router
from chat.main import McpChatService
import config
import logging

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(name)s - %(message)s"
)

app = FastAPI(
    title="시술 추천 AI 챗봇"
)

# MCP 연결과 에이전트를 여러 요청에서 재사용
chat_service = McpChatService()
app.state.chat_service = chat_service

# 라우터 등록
app.include_router(health_router)
app.include_router(chat_router)

# 서버 기동 시 MCP 연결 및 에이전트 미리 준비
async def init_chat_service() -> None:
    await chat_service.start()
app.router.add_event_handler("startup", init_chat_service)

# 서버 종료 시 자원 반납
async def close_chat_service() -> None:
    await chat_service.close()
app.router.add_event_handler("shutdown", close_chat_service)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host=config.HOST, port=config.PORT)