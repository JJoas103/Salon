package com.soldesk.vo;

// ai-service(FastAPI) 로 전달할 채팅 요청
public class ChatRequest {

    private String question;
    private String sessionId;
    // 클라이언트가 보내는 값은 무시하고, AiChatController 가 로그인 사용자의 예약이력으로 직접 채워 넣는다
    private String userContext;

    public String getQuestion() {
        return question;
    }
    public void setQuestion(String question) {
        this.question = question;
    }
    public String getSessionId() {
        return sessionId;
    }
    public void setSessionId(String sessionId) {
        this.sessionId = sessionId;
    }
    public String getUserContext() {
        return userContext;
    }
    public void setUserContext(String userContext) {
        this.userContext = userContext;
    }
}
