package com.soldesk.vo;

/**
 * 채팅방 "목록 화면"용 조회 결과. Chats 테이블 그대로가 아니라
 * 목록 한 줄을 그리는 데 필요한 것들(상대 이름, 매장명, 마지막 메시지, 안읽음 수)을 조인해 담는다.
 *
 * 상대(partner)는 보는 사람에 따라 달라진다 — 고객이 보면 점주, 점주가 보면 고객.
 * 그 판단은 SQL 쪽(findRoomsByCustomer / findRoomsBySalon)에서 끝내고 여기엔 결과만 담는다.
 */
public class ChatRoomVO {

    private int chatId;
    private int salonId;
    private String salonName;
    private String salonImageUrl;

    private int partnerId;      // 대화 상대 user_id
    private String partnerName; // 대화 상대 이름

    private String lastMessage;   // 마지막 메시지 내용 (없으면 null)
    private String lastMessageAt; // 마지막 메시지 시각
    private int unreadCount;      // 내가 안 읽은 메시지 수

    public int getChatId() { return chatId; }
    public void setChatId(int chatId) { this.chatId = chatId; }
    public int getSalonId() { return salonId; }
    public void setSalonId(int salonId) { this.salonId = salonId; }
    public String getSalonName() { return salonName; }
    public void setSalonName(String salonName) { this.salonName = salonName; }
    public String getSalonImageUrl() { return salonImageUrl; }
    public void setSalonImageUrl(String salonImageUrl) { this.salonImageUrl = salonImageUrl; }
    public int getPartnerId() { return partnerId; }
    public void setPartnerId(int partnerId) { this.partnerId = partnerId; }
    public String getPartnerName() { return partnerName; }
    public void setPartnerName(String partnerName) { this.partnerName = partnerName; }
    public String getLastMessage() { return lastMessage; }
    public void setLastMessage(String lastMessage) { this.lastMessage = lastMessage; }
    public String getLastMessageAt() { return lastMessageAt; }
    public void setLastMessageAt(String lastMessageAt) { this.lastMessageAt = lastMessageAt; }
    public int getUnreadCount() { return unreadCount; }
    public void setUnreadCount(int unreadCount) { this.unreadCount = unreadCount; }
}
