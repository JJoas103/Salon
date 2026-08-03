package com.soldesk.handler;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.simp.stomp.StompCommand;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.messaging.support.ChannelInterceptor;
import org.springframework.messaging.support.MessageHeaderAccessor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.web.context.HttpSessionSecurityContextRepository;
import org.springframework.stereotype.Component;

@Component
public class StompAuthChannelInterceptor implements ChannelInterceptor{
    
    private static final Logger log = LoggerFactory.getLogger(StompAuthChannelInterceptor.class);

    @Override
    public Message<?> preSend(Message<?> message, MessageChannel channel) {
        StompHeaderAccessor accessor = MessageHeaderAccessor.getAccessor(message, StompHeaderAccessor.class);
        if(accessor == null || !StompCommand.CONNECT.equals(accessor.getCommand())){
            return message;
        }
        SecurityContext securityContext 
                = (SecurityContext)accessor.getSessionAttributes()
                            .get(HttpSessionSecurityContextRepository.SPRING_SECURITY_CONTEXT_KEY);
        Authentication authentication
            = securityContext != null ? securityContext.getAuthentication() : null;
        //시큐리티로 인증된 사용자인지 검사
        if(authentication == null ||
            !authentication.isAuthenticated() ||
            "anonymousUser".equals(authentication.getName())){
                log.warn("STOMP 연결 거부 - 미로그인");
                throw new IllegalArgumentException("로그인이 필요합니다.");
            }//인증된 사용자가 아니면 연결 거부

        accessor.setUser(authentication);//웹소켓 메시지 헤더에 인증된 사용자 정보 설정
        log.info("STOMP 연결: {}", authentication.getName());

        return message;
    }//인증된 사용자인지 검
}
