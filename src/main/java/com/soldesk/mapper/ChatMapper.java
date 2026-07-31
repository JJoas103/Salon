package com.soldesk.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.soldesk.vo.ChatRoomVO;
import com.soldesk.vo.ChatVO;
import com.soldesk.vo.MessageVO;

public interface ChatMapper {

    // ---------- 방 ----------

    /** 고객+매장 조합으로 기존 방 찾기. 없으면 null (그때만 새로 만든다) */
    ChatVO findRoom(@Param("customerId") int customerId, @Param("salonId") int salonId);

    /** 방 생성. 생성된 chat_id 는 인자로 넘긴 ChatVO 에 채워진다 */
    int insertRoom(ChatVO chat);

    ChatVO findById(int chatId);

    /** 이 사용자가 이 방의 참여자인가. 남의 방 메시지를 막는 검증용 */
    boolean isParticipant(@Param("chatId") int chatId, @Param("userId") int userId);

    /** 고객 화면의 방 목록 — 상대는 점주 */
    List<ChatRoomVO> findRoomsByCustomer(int customerId);

    /** 점주 화면의 방 목록 — 사이드바에서 고른 매장 기준, 상대는 고객.
     *  점주가 매장을 여러 개 가질 수 있어 ownerId 가 아니라 salonId 로 찾는다 */
    List<ChatRoomVO> findRoomsBySalon(int salonId);

    /** 마지막 활동 시각 갱신 (목록 정렬용) */
    int touchRoom(int chatId);

    // ---------- 메시지 ----------

    int insertMessage(MessageVO message);

    List<MessageVO> findMessages(int chatId);

    /** 내가 방을 열었을 때, 상대가 보낸 안읽음 메시지를 읽음 처리 */
    int markAsRead(@Param("chatId") int chatId, @Param("readerId") int readerId);
}
