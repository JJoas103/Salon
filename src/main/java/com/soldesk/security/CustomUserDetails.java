package com.soldesk.security;

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

    public CustomUserDetails(UserVO user, String role) {
        this.userId = user.getUserId();
        this.email = user.getEmail();
        this.password = user.getPassword();
        this.userName = user.getUserName();
        this.role = role;
    }

    // 화면/컨트롤러에서 쓰는 추가 정보
    public int getUserId() { return userId; }
    public String getUserName() { return userName; }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return List.of(new SimpleGrantedAuthority("ROLE_" + role));
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
