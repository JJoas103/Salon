package com.soldesk.vo;

import java.util.ArrayList;
import java.util.List;

// ai-service(FastAPI) 응답을 그대로 담아 브라우저에 전달
public class ChatResponse {

    private String answer;
    private String source;
    private String question;
    private String sessionId;
    // 답변에 등장한 매장. 오류 응답에도 필드가 있어야 화면이 분기 없이 읽음
    private List<SalonLink> salons = new ArrayList<>();

    public ChatResponse() {
    }

    public ChatResponse(String answer, String source, String question, String sessionId) {
        this.answer = answer;
        this.source = source;
        this.question = question;
        this.sessionId = sessionId;
    }

    public String getAnswer() {
        return answer;
    }
    public void setAnswer(String answer) {
        this.answer = answer;
    }
    public String getSource() {
        return source;
    }
    public void setSource(String source) {
        this.source = source;
    }
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
    public List<SalonLink> getSalons() {
        return salons;
    }
    public void setSalons(List<SalonLink> salons) {
        this.salons = salons == null ? new ArrayList<>() : salons;
    }
}
