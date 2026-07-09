package com.soldesk.vo;

/**
 * Messages - 메시지
 */
public class MessageVO {

    private int messageId; // message_id
    private int chatId; // chat_id
    private int senderId; // 발신자 (sender_id)
    private String messageContent; // message_content
    private String sentAt; // sent_at

    public int getMessageId() { return messageId; }
    public void setMessageId(int messageId) { this.messageId = messageId; }
    public int getChatId() { return chatId; }
    public void setChatId(int chatId) { this.chatId = chatId; }
    public int getSenderId() { return senderId; }
    public void setSenderId(int senderId) { this.senderId = senderId; }
    public String getMessageContent() { return messageContent; }
    public void setMessageContent(String messageContent) { this.messageContent = messageContent; }
    public String getSentAt() { return sentAt; }
    public void setSentAt(String sentAt) { this.sentAt = sentAt; }
}
