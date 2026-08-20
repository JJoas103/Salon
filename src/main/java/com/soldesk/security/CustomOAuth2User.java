package com.soldesk.security;

import java.util.Collection;
import java.util.List;
import java.util.Map;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.oauth2.core.user.OAuth2User;

/**
 * 구글/네이버 로그인 사용자 정보를 담기 위해 사용.
 * CustomUserDetails와 마찬가지로 JSP/컨트롤러에서 userId·userName을 꺼내 쓸 수 있게 한다.
 * (jsp ex) <sec:authentication property="principal.userName"/>)
 *
 * getName()은 OAuth2User의 기본 규약(provider가 정한 name attribute, 예: 구글의 sub)이 아니라
 * 이메일을 반환한다 — 코드베이스 전반이 authentication.getName()을 로그인 ID(이메일)로 취급하므로
 * (예: UserService.getUser(authentication.getName())), 폼 로그인과 동일하게 맞춰야 컨트롤러를 안 건드린다.
 */
public class CustomOAuth2User implements OAuth2User {

    private final int userId;
    private final String email;
    private final String userName;
    private final String role;
    private final Map<String, Object> attributes;

    public CustomOAuth2User(int userId, String email, String userName, String role, Map<String, Object> attributes) {
        this.userId = userId;
        this.email = email;
        this.userName = userName;
        this.role = role;
        this.attributes = attributes;
    }

    public int getUserId() { return userId; }
    public String getUserName() { return userName; }

    @Override
    public Map<String, Object> getAttributes() { return attributes; }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        // OAuth2 로그인 세션은 정의상 항상 소셜 계정이다 — CustomUserDetails(폼 로그인)의
        // SOCIAL_ACCOUNT 권한과 동일한 이름으로 부여해 SecurityConfig에서 한 규칙으로 같이 막는다.
        return List.of(
                new SimpleGrantedAuthority("ROLE_" + role),
                new SimpleGrantedAuthority("SOCIAL_ACCOUNT"));
    }

    @Override
    public String getName() { return email; }
}
