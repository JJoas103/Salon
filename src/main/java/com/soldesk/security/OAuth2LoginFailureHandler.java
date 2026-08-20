package com.soldesk.security;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.oauth2.core.OAuth2AuthenticationException;
import org.springframework.security.web.authentication.AuthenticationFailureHandler;

/**
 * 소셜 로그인 실패 처리.
 *
 * 폼 로그인과 같은 핸들러를 쓰면 /user/login?error 로 보내져 "이메일 또는 비밀번호가 올바르지 않습니다"가
 * 뜬다. 소셜 로그인에는 비밀번호가 없으므로 그 안내는 틀렸고, 진짜 원인(이메일 제공 동의 누락,
 * 토큰 교환 실패, 콜백 URL 불일치 등)도 가려진다. 그래서 따로 두고 서버 로그에 원인을 남긴다.
 */
public class OAuth2LoginFailureHandler implements AuthenticationFailureHandler {

    private static final Logger log = LoggerFactory.getLogger(OAuth2LoginFailureHandler.class);

    @Override
    public void onAuthenticationFailure(HttpServletRequest request, HttpServletResponse response,
            AuthenticationException exception) throws IOException, ServletException {

        if (exception instanceof OAuth2AuthenticationException) {
            // getError() 의 code/description 이 프로바이더가 알려준 실패 사유다. 스택보다 이쪽이 먼저 도움이 된다.
            log.warn("소셜 로그인 실패 - {}", ((OAuth2AuthenticationException) exception).getError(), exception);
        } else {
            log.warn("소셜 로그인 실패", exception);
        }

        response.sendRedirect(request.getContextPath() + "/user/login?socialError");
    }
}
