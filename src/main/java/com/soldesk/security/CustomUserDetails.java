package com.soldesk.security;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import com.soldesk.vo.UserVO;

/**
 * 로그인한 사용자 정보를 담기 위해 사용(닉네임 등..)
 * Spring 기본 User 대신 이걸 써서, JSP/컨트롤러에서 userName·userId 등도 꺼내 쓸 수 있게 함.
 * (jsp ex) <sec:authentication property="principal.userName"/>)
 */
public class CustomUserDetails implements UserDetails {

    private final int userId;
    private final String email;    // 로그인 ID
    private final String password;
    private final String userName; // 화면에 표시할 이름
    private final String role;     // ADMIN / OWNER / CUSTOMER
    private final String provider; // local / google / naver
    private final boolean currentlySuspended; // 커뮤니티 기능 제한 여부 (로그인 자체는 막지 않음)

    public CustomUserDetails(UserVO user, String role) {
        this.userId = user.getUserId();
        this.email = user.getEmail();
        // 소셜 전용 계정은 password가 null이다. BCryptPasswordEncoder.matches(raw, null)은 NPE를 던지므로,
        // 폼 로그인 시도 시 예외 대신 "항상 불일치"로 자연스럽게 실패하도록 매번 새 해시를 채워 넣는다.
        this.password = user.getPassword() != null ? user.getPassword()
                : "$2a$10$abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0";
        this.userName = user.getUserName();
        this.role = role;
        this.provider = user.getProvider();
        this.currentlySuspended = isSuspended(user);
    }

    /**
     * 제재 판정 규칙. 로그인 시점(이 클래스)과 커뮤니티 변경 액션 시점
     * (ActiveSuspensionAuthorizationManager)이 같은 규칙을 써야 하므로 패키지 공용으로 둔다.
     * — resolveRole()을 UserDetailService에 공용으로 둔 것과 같은 이유.
     */
    static boolean isSuspended(UserVO user) {
        return "banned".equals(user.getStatus())
                || ("suspended".equals(user.getStatus())
                    && user.getSuspendedUntil() != null
                    && user.getSuspendedUntil().isAfter(LocalDateTime.now()));
    }

    // 화면/컨트롤러에서 쓰는 추가 정보
    public int getUserId() { return userId; }
    public String getUserName() { return userName; }
    public String getProvider() { return provider; }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        List<GrantedAuthority> authorities = new ArrayList<>();
        authorities.add(new SimpleGrantedAuthority("ROLE_" + role));
        if (currentlySuspended) {
            authorities.add(new SimpleGrantedAuthority("SUSPENDED"));
        }
        // 소셜(구글/네이버) 계정은 로컬 비밀번호가 없는 자체 가입 회원이 아니므로,
        // 점주 승격 신청 등 자체 가입 회원 전용 기능을 SecurityConfig에서 이 권한으로 막는다.
        if (!"local".equals(provider)) {
            authorities.add(new SimpleGrantedAuthority("SOCIAL_ACCOUNT"));
        }
        return authorities;
    }

    @Override
    public String getPassword() { return password; }

    @Override
    public String getUsername() { return email; } // 로그인 ID = 이메일

    @Override
    public boolean isAccountNonExpired() { return true; }

    @Override
    public boolean isAccountNonLocked() { return true; }

    @Override
    public boolean isCredentialsNonExpired() { return true; }

    @Override
    public boolean isEnabled() { return true; }
}
