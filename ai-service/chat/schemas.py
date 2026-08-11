from pydantic import BaseModel, ConfigDict, Field

# 스프링에서 전달한 채팅 객체(사용자의 질문, 브라우저별 세션ID)
class ChatRequest(BaseModel):
    model_config =ConfigDict(populate_by_name=True)
    question: str = Field(min_length=1, max_length=500)
    session_id: str | None = Field(
        default=None,
        alias="sessionId",  # alias: 외부 JSON 데이터 중 sessionId 필드를 매핑
        min_length=1,
        max_length=100
    )

# Fast-API에서 전달할 채팅 객체(LLM 답변)
class ChatResponse(BaseModel):
    model_config = ConfigDict(populate_by_name=True)
    answer: str
    source: str
    question: str
    session_id: str = Field(alias="sessionId")
