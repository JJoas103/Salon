import logging

from fastapi import APIRouter, HTTPException, Request
from chat.schemas import ChatRequest, ChatResponse
from chat.main import McpChatService

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/api", tags=["chat"])

@router.post("/chat", response_model=ChatResponse)
async def chat(
    payload: ChatRequest,
    request: Request
) -> ChatResponse:
    question = payload.question.strip()
    session_id = payload.session_id

    try:
        # 세션ID와 질문을 Mcp 서버에 전달해 답변을 반환
        chat_service: McpChatService = request.app.state.chat_service
        answer = await chat_service.ask(session_id, question, payload.user_context)
        
    except Exception as error:
        # 예외 문자열에 ES 주소가 들어있어 브라우저로 내보내지 않음
        logger.exception("MCP 상품 상담 요청에 실패했습니다")
        raise HTTPException(
            status_code= 503,
            detail=(
                "MCP 상품 상담 서비스를 사용할 수 없습니다. "
                "ElasticSearch와 LLM 설정을 확인하세요."
            ),
        ) from error
    
    return ChatResponse(
        answer = answer,
        source = "mcp",
        question = question,
        sessionId = session_id,
    )
