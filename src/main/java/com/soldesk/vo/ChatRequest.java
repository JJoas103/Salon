package com.soldesk.vo;

// ai-service(FastAPI) 로 전달할 채팅 요청
public class ChatRequest {

    private String question;
    private String sessionId;

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
}
