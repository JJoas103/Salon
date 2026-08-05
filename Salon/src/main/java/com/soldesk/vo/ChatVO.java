package com.soldesk.vo;

/**
 * Chats - 채팅방
 */
public class ChatVO {

    private int chatId; // chat_id
    private int user1Id; // 참여자1 (user1_id)
    private int user2Id; // 참여자2 (user2_id)
    private String createdAt; // created_at
    private String updatedAt; // updated_at

    public int getChatId() { return chatId; }
    public void setChatId(int chatId) { this.chatId = chatId; }
    public int getUser1Id() { return user1Id; }
    public void setUser1Id(int user1Id) { this.user1Id = user1Id; }
    public int getUser2Id() { return user2Id; }
    public void setUser2Id(int user2Id) { this.user2Id = user2Id; }
    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
    public String getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(String updatedAt) { this.updatedAt = updatedAt; }
}
