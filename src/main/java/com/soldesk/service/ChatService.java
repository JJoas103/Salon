package com.soldesk.service;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.soldesk.mapper.ChatMapper;
import com.soldesk.mapper.SalonMapper;
import com.soldesk.mapper.UserMapper;
import com.soldesk.vo.ChatRoomVO;
import com.soldesk.vo.ChatVO;
import com.soldesk.vo.MessageVO;
import com.soldesk.vo.SalonVO;
import com.soldesk.vo.SocketEventMessage;
import com.soldesk.vo.UserVO;

/**
 * 1:1 상담 채팅.
 *
 * 방 생성·이력 조회는 평범한 HTTP 요청에서 호출되고, sendMessage 만 STOMP 핸들러에서 호출된다.
 * "이 사람이 이 방 참여자인가" 같은 행 단위 검증은 URL 규칙으로 표현할 수 없으므로
 * SecurityConfig 가 아니라 여기서 한다.
 */
@Service
public class ChatService {

    @Autowired
    private ChatMapper chatMapper;

    @Autowired
    private SalonMapper salonMapper;

    @Autowired
    private UserMapper userMapper;

    // @EnableWebSocketMessageBroker 가 등록해주는 빈. 브로커로 메시지를 밀어넣는 통로다.
    @Autowired
    private SimpMessagingTemplate messagingTemplate;


    /**
     * 고객이 특정 매장에 문의를 시작한다. 이미 방이 있으면 그 방을 재사용한다.
     * @return chatId
     */
    @Transactional
    public int openRoom(int customerId, int salonId) {

        SalonVO salon = salonMapper.findById(salonId);
        if (salon == null) {
            throw new IllegalArgumentException("존재하지 않는 매장입니다.");
        }
        if (salon.getOwnerId() == customerId) {
            throw new IllegalArgumentException("본인 매장에는 문의할 수 없습니다.");
        }

        ChatVO existing = chatMapper.findRoom(customerId, salonId);
        if (existing != null) {
            return existing.getChatId();
        }

        ChatVO room = new ChatVO();
        room.setUser1Id(customerId);          // 순서 고정: user1 = 고객
        room.setUser2Id(salon.getOwnerId());  //            user2 = 점주
        room.setSalonId(salonId);

        try {
            chatMapper.insertRoom(room);
            return room.getChatId();
        } catch (DuplicateKeyException e) {
            // 문의 버튼을 연타하는 등으로 동시에 두 번 들어온 경우.
            // UNIQUE(user1_id, salon_id) 가 막아준 것이므로 먼저 만들어진 방을 쓴다.
            return chatMapper.findRoom(customerId, salonId).getChatId();
        }
    }

    /** 고객 화면의 방 목록 */
    @Transactional(readOnly = true)
    public List<ChatRoomVO> getCustomerRooms(int customerId) {
        return chatMapper.findRoomsByCustomer(customerId);
    }

    /** 사이드바 알림 배지용 - 참여한 모든 방의 안읽음 합계 */
    @Transactional(readOnly = true)
    public int getUnreadCount(int userId) {
        return chatMapper.countUnread(userId);
    }

    /** 점주 화면의 방 목록 (사이드바에서 고른 매장 기준) */
    @Transactional(readOnly = true)
    public List<ChatRoomVO> getSalonRooms(int salonId) {
        return chatMapper.findRoomsBySalon(salonId);
    }

    /**
     * 방 하나의 대화 이력. 여는 순간 상대가 보낸 메시지를 읽음 처리한다.
     * (읽음 처리가 있어서 readOnly 가 아니다)
     */
    @Transactional
    public List<MessageVO> getMessages(int chatId, int userId) {
        requireParticipant(chatId, userId);
        markReadAndNotify(chatId, userId);
        return chatMapper.findMessages(chatId);
    }

    /**
     * 메시지 전송. STOMP 핸들러가 호출한다.
     * 저장이 끝난 뒤에만 상대에게 밀어준다 — 순서가 바뀌면 "받았는데 새로고침하면 없는" 메시지가 생긴다.
     */
    @Transactional
    public MessageVO sendMessage(int chatId, String senderEmail, String content) {

        if (content == null || content.isBlank()) {
            throw new IllegalArgumentException("빈 메시지는 보낼 수 없습니다.");
        }

        UserVO sender = userMapper.findByEmail(senderEmail);
        if (sender == null) {
            throw new IllegalArgumentException("알 수 없는 발신자입니다.");
        }

        ChatVO room = chatMapper.findById(chatId);
        if (room == null) {
            throw new IllegalArgumentException("존재하지 않는 채팅방입니다.");
        }
        requireParticipant(chatId, sender.getUserId());

        MessageVO message = new MessageVO();
        message.setChatId(chatId);
        message.setSenderId(sender.getUserId());
        message.setMessageContent(content);

        chatMapper.insertMessage(message);
        chatMapper.touchRoom(chatId);

        // 화면에 바로 그릴 수 있도록 저장 후 부족한 값을 채워 돌려준다
        message.setSenderName(sender.getUserName());

        // 방의 두 참여자 중 발신자가 아닌 쪽이 수신자다
        int recipientId = (room.getUser1Id() == sender.getUserId()) ? room.getUser2Id() : room.getUser1Id();
        UserVO recipient = userMapper.findById(recipientId);

        SocketEventMessage event = new SocketEventMessage("newMessage", message);

        // 수신자에게. 접속 중이 아니면 그냥 버려지고, 나중에 이력 조회로 보게 된다.
        if (recipient != null) {
            messagingTemplate.convertAndSendToUser(recipient.getEmail(), "/queue/messages", event);
        }
        // 발신자 본인에게도 되돌려준다. 그래야 여러 탭을 켜둬도 화면이 어긋나지 않고,
        // 저장에 성공한 메시지만 말풍선이 된다.
        messagingTemplate.convertAndSendToUser(senderEmail, "/queue/messages", event);

        return message;
    }

    /**
     * 화면을 열어둔 채로 받은 메시지를 읽음 처리한다.
     *
     * getMessages 의 읽음 처리는 "방을 여는 순간" 한 번뿐이라,
     * 창을 켜둔 채 실시간으로 받은 메시지는 눈으로 봤어도 is_read = 0 으로 남는다.
     * 그 간극을 클라이언트가 이 메서드로 메워준다.
     */
    @Transactional
    public int markAsRead(int chatId, String readerEmail) {

        UserVO reader = userMapper.findByEmail(readerEmail);
        if (reader == null) {
            throw new IllegalArgumentException("알 수 없는 사용자입니다.");
        }
        requireParticipant(chatId, reader.getUserId());

        return markReadAndNotify(chatId, reader.getUserId());
    }

    /**
     * 읽음 처리 + 원래 보낸 사람에게 "읽었다" 통지.
     *
     * 통지가 필요한 이유: 발신자 화면의 "1" 표시를 지우려면 상대가 읽었다는 사실을
     * 발신자가 알아야 하는데, DB만 바꾸면 발신자는 새로고침 전까지 모른다.
     * 바뀐 행이 0이면(이미 다 읽은 방을 다시 연 경우) 굳이 보내지 않는다.
     */
    private int markReadAndNotify(int chatId, int readerId) {

        int updated = chatMapper.markAsRead(chatId, readerId);
        if (updated == 0) {
            return 0;
        }

        ChatVO room = chatMapper.findById(chatId);
        int senderId = (room.getUser1Id() == readerId) ? room.getUser2Id() : room.getUser1Id();
        UserVO sender = userMapper.findById(senderId);

        // 보낸 사람에게: 내 메시지 옆의 "1" 을 지우라고
        if (sender != null) {
            messagingTemplate.convertAndSendToUser(sender.getEmail(), "/queue/messages",
                    new SocketEventMessage("messagesRead", Map.of("chatId", chatId)));
        }

        // 읽은 사람에게: 사이드바 알림 배지의 새 합계.
        // 클라이언트가 스스로 빼면 여러 방·여러 탭에서 어긋나므로 서버가 계산한 값을 그대로 준다.
        UserVO reader = userMapper.findById(readerId);
        if (reader != null) {
            messagingTemplate.convertAndSendToUser(reader.getEmail(), "/queue/messages",
                    new SocketEventMessage("unreadCount", Map.of("count", chatMapper.countUnread(readerId))));
        }
        return updated;
    }

    /** 남의 방에 끼어드는 것을 막는다. URL 로는 표현할 수 없는 검증이라 서비스에서 처리한다. */
    private void requireParticipant(int chatId, int userId) {
        if (!chatMapper.isParticipant(chatId, userId)) {
            throw new IllegalArgumentException("접근할 수 없는 채팅방입니다.");
        }
    }
}
