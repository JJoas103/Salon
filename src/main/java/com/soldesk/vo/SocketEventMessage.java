package com.soldesk.vo;

/**
 * 웹소켓으로 나가는 모든 메시지의 겉봉투.
 *
 * 클라이언트는 구독 하나(/user/queue/messages)로 여러 종류의 알림을 받게 되므로,
 * "무슨 일이 일어났는지(event)" 와 "내용(data)" 을 분리해 둔다.
 * 그래야 나중에 알림 종류가 늘어도 구독을 새로 파지 않고 event 분기만 추가하면 된다.
 *
 * 예) {"event":"newMessage", "data":{...MessageVO...}}
 */
public class SocketEventMessage {

    private String event;
    private Object data;

    public SocketEventMessage() {
    }

    public SocketEventMessage(String event, Object data) {
        this.event = event;
        this.data = data;
    }

    public String getEvent() { return event; }
    public void setEvent(String event) { this.event = event; }
    public Object getData() { return data; }
    public void setData(Object data) { this.data = data; }
}
