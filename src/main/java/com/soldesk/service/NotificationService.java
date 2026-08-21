package com.soldesk.service;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.soldesk.mapper.NotificationMapper;
import com.soldesk.mapper.UserMapper;
import com.soldesk.vo.NotificationVO;
import com.soldesk.vo.SocketEventMessage;
import com.soldesk.vo.UserVO;

/**
 * 고객 알림함 (예약 상태변경 · 쿠폰발급 · 채팅 새메시지 · 매장 신규 공지사항).
 *
 * 호출하는 쪽(ReservationService/CouponService/ChatService/SalonNoticeService)은
 * "무슨 일이 있었는지"만 넘기고, 알림 설정(notifications_enabled) 확인·저장·실시간 push는
 * 전부 여기 한 곳에 모아둔다.
 */
@Service
public class NotificationService {

    @Autowired
    private NotificationMapper notificationMapper;

    @Autowired
    private UserMapper userMapper;

    // 채팅과 같은 브로커 통로(/user/queue/messages)를 그대로 재사용한다.
    // 클라이언트는 이미 이 채널을 구독하고 있으므로 event 분기만 늘리면 된다.
    @Autowired
    private SimpMessagingTemplate messagingTemplate;

    @Transactional
    public void create(int userId, String type, String title, String message, String linkUrl, Integer refId) {
        UserVO user = userMapper.findById(userId);
        if (user == null || !user.isNotificationsEnabled()) {
            return;   // 알림 설정이 꺼져 있으면 애초에 쌓지 않는다
        }

        NotificationVO notification = new NotificationVO();
        notification.setUserId(userId);
        notification.setType(type);
        // title/message 는 매장명·시술명 등 호출부가 조합한 문자열이라 컬럼 길이(100/255)를
        // 넘을 수 있다. 넘기면 MySQL strict mode 가 예외를 던져 이 알림을 만든 원래 작업
        // (예약 확정, 매장 공지 등록 등) 전체가 롤백되므로, 여기서 미리 잘라 방지한다.
        notification.setTitle(truncate(title, 100));
        notification.setMessage(truncate(message, 255));
        notification.setLinkUrl(linkUrl);
        notification.setRefId(refId);
        notificationMapper.insert(notification);

        // 실시간 배지 갱신에 필요한 필드만 담아 보낸다. is_read/createdAt 등은 클라이언트가
        // 어차피 패널을 열 때 GET 으로 다시 받으므로 여기서는 최소한만 보낸다.
        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("notificationId", notification.getNotificationId());
        payload.put("type", notification.getType());
        payload.put("title", notification.getTitle());
        payload.put("message", notification.getMessage());
        payload.put("linkUrl", notification.getLinkUrl());

        messagingTemplate.convertAndSendToUser(
                user.getEmail(), "/queue/messages",
                new SocketEventMessage("newNotification", payload));
    }

    @Transactional(readOnly = true)
    public List<NotificationVO> getRecent(int userId, int limit) {
        return notificationMapper.findRecentByUser(userId, limit);
    }

    @Transactional(readOnly = true)
    public int getUnreadCount(int userId) {
        return notificationMapper.countUnread(userId);
    }

    @Transactional
    public void markRead(int notificationId, int userId) {
        notificationMapper.markRead(notificationId, userId);
    }

    @Transactional
    public void markAllRead(int userId) {
        notificationMapper.markAllRead(userId);
    }

    private String truncate(String value, int maxLength) {
        if (value != null && value.length() > maxLength) {
            return value.substring(0, maxLength - 1) + "…";
        }
        return value;
    }
}
