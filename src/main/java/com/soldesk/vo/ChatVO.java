package com.soldesk.vo;

/**
 * Chats - 채팅방 (고객 ↔ 매장 점주 1:1 문의)
 *
 * 참여자 순서는 고정이다: user1Id = 고객, user2Id = 점주.
 * 이 순서를 지켜야 UNIQUE(user1_id, salon_id) 가 성립하고,
 * 방 조회가 (a,b) OR (b,a) 없이 단일 조건으로 끝난다.
 */
public class ChatVO {

    private int chatId; // chat_id
    private int user1Id; // 고객 (user1_id)
    private int user2Id; // 점주 (user2_id)
    private String createdAt; // created_at
    private String updatedAt; // updated_at

    //매장ID
    private int salonId;    //

    public int getSalonId() { return salonId; }
    public void setSalonId(int salonId) { this.salonId = salonId; }
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
