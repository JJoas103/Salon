package com.soldesk.vo;

/**
 * Messages - 메시지
 */
public class MessageVO {

    private int messageId; // message_id
    private int chatId; // chat_id
    private int senderId; // 발신자 (sender_id)
    private String messageContent; // message_content
    private boolean isRead; // 상대가 읽었는지 (is_read)
    private String sentAt; // sent_at

    // 조인용 - 말풍선에 표시할 발신자 이름
    private String senderName;

    public int getMessageId() { return messageId; }
    public void setMessageId(int messageId) { this.messageId = messageId; }
    public int getChatId() { return chatId; }
    public void setChatId(int chatId) { this.chatId = chatId; }
    public int getSenderId() { return senderId; }
    public void setSenderId(int senderId) { this.senderId = senderId; }
    public String getMessageContent() { return messageContent; }
    public void setMessageContent(String messageContent) { this.messageContent = messageContent; }
    // getIsRead/setIsRead 로 둔다 — isRead()/setRead() 로 두면 MyBatis·EL 이 보는
    // 프로퍼티명이 "read" 가 되어 resultMap 의 property="isRead" 와 어긋난다
    public boolean getIsRead() { return isRead; }
    public void setIsRead(boolean isRead) { this.isRead = isRead; }
    public String getSentAt() { return sentAt; }
    public void setSentAt(String sentAt) { this.sentAt = sentAt; }
    public String getSenderName() { return senderName; }
    public void setSenderName(String senderName) { this.senderName = senderName; }
}
