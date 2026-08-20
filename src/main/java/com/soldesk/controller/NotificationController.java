package com.soldesk.controller;

import java.util.ArrayList;
import java.util.List;
import java.util.LinkedHashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

import com.soldesk.service.NotificationService;
import com.soldesk.service.UserService;
import com.soldesk.vo.NotificationVO;
import com.soldesk.vo.UserVO;

/**
 * 고객 사이드바 알림 드롭다운 전용. 예약/쿠폰/채팅/공지사항 알림을 한 곳에서 조회·읽음처리한다.
 * (기존 CommonController 의 /common/chat/unread-count 는 채팅 전용 카운트라 계속 남겨두되,
 *  사이드바 벨 배지는 이 컨트롤러의 unread-count 로 갈아탄다)
 */
@RestController
@RequestMapping("/common/notifications")
public class NotificationController {

    @Autowired
    private NotificationService notificationService;

    @Autowired
    private UserService userService;

    @GetMapping
    @ResponseBody
    public List<Map<String, Object>> list(Authentication authentication) {
        UserVO user = userService.getUser(authentication.getName());
        List<Map<String, Object>> result = new ArrayList<>();
        // LocalDateTime 을 문자열로 직접 내려준다 — JavaTimeModule 자체는 등록돼 있어 예외는
        // 안 나지만, 기본 설정대로면 [2026,8,20,16,30,44] 같은 숫자 배열로 직렬화된다.
        // notifications.js 의 timeAgo() 는 new Date(iso 문자열) 을 기대하므로 배열이 오면
        // Invalid Date 가 된다 — 그래서 여기서 문자열로 바꿔 내려준다.
        for (NotificationVO n : notificationService.getRecent(user.getUserId(), 20)) {
            Map<String, Object> row = new LinkedHashMap<>();
            row.put("notificationId", n.getNotificationId());
            row.put("type", n.getType());
            row.put("title", n.getTitle());
            row.put("message", n.getMessage());
            row.put("linkUrl", n.getLinkUrl());
            row.put("read", n.isRead());
            row.put("createdAt", n.getCreatedAt() == null ? null : n.getCreatedAt().toString());
            result.add(row);
        }
        return result;
    }

    @GetMapping("/unread-count")
    @ResponseBody
    public Map<String, Integer> unreadCount(Authentication authentication) {
        UserVO user = userService.getUser(authentication.getName());
        return Map.of("count", notificationService.getUnreadCount(user.getUserId()));
    }

    @PostMapping("/{notificationId}/read")
    @ResponseBody
    public void markRead(@PathVariable int notificationId, Authentication authentication) {
        UserVO user = userService.getUser(authentication.getName());
        notificationService.markRead(notificationId, user.getUserId());
    }

    @PostMapping("/read-all")
    @ResponseBody
    public void markAllRead(Authentication authentication) {
        UserVO user = userService.getUser(authentication.getName());
        notificationService.markAllRead(user.getUserId());
    }
}
