package com.soldesk.controller;

import java.security.Principal;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.stereotype.Controller;

import com.soldesk.service.ChatService;
import com.soldesk.vo.MessageVO;

/**
 * STOMP 메시지 전용 컨트롤러. @RequestMapping 이 아니라 @MessageMapping 이라
 * 뷰를 반환하지 않고, 반환값은 곧 상대에게 보낼 메시지 본문이 된다.
 *
 * principal 은 StompAuthChannelInterceptor 가 CONNECT 때 심어준 Authentication 이다.
 * 미인증 연결은 거기서 이미 끊기므로 여기서 다시 로그인 검사를 하지 않는다.
 */
@Controller
public class ChatSocketController {

    private static final Logger log = LoggerFactory.getLogger(ChatSocketController.class);

    @Autowired
    private ChatService chatService;

    /**
     * 메시지 전송. 클라이언트는 /app/chat/send 로 보낸다.
     *
     * 반환값이 없는 이유: 저장한 메시지를 "상대와 나" 양쪽에 보내야 하는데
     * @SendToUser 는 호출자 한 명에게만 보내므로, 발송은 ChatService 가
     * SimpMessagingTemplate 으로 직접 처리한다.
     *
     * payload 로 MessageVO 를 받지만 실제로 읽는 값은 chatId 와 messageContent 둘뿐이다.
     * senderId 는 클라이언트가 뭘 보내든 무시하고 principal 에서 가져온다 —
     * 그러지 않으면 남의 이름으로 메시지를 보낼 수 있다.
     */
    @MessageMapping("/chat/send")
    public void send(MessageVO payload, Principal principal) {
        log.debug("STOMP send - from={}, chatId={}", principal.getName(), payload.getChatId());
        chatService.sendMessage(payload.getChatId(), principal.getName(), payload.getMessageContent());
    }
}
