package com.soldesk.security;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.authentication.AuthenticationFailureHandler;
import org.springframework.security.web.authentication.SimpleUrlAuthenticationFailureHandler;

// 사이드바 로그인 모달은 401+JSON으로 응답해 모달 안에서 에러 표시,
// login.jsp의 일반 폼 제출(직접 URL 접근 시 안전망)은 기존 리다이렉트 방식을 그대로 유지
public class AjaxAwareAuthenticationFailureHandler implements AuthenticationFailureHandler {

    private final AuthenticationFailureHandler defaultHandler =
        new SimpleUrlAuthenticationFailureHandler("/user/login?error");

    @Override
    public void onAuthenticationFailure(HttpServletRequest request, HttpServletResponse response,
            AuthenticationException exception) throws IOException, ServletException {
        if ("XMLHttpRequest".equals(request.getHeader("X-Requested-With"))) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"success\":false,\"message\":\"이메일 또는 비밀번호가 올바르지 않습니다.\"}");
            return;
        }
        defaultHandler.onAuthenticationFailure(request, response, exception);
    }
}
