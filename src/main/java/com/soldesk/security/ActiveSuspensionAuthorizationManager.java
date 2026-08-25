package com.soldesk.security;

import java.util.function.Supplier;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.authorization.AuthorizationDecision;
import org.springframework.security.authorization.AuthorizationManager;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.web.access.intercept.RequestAuthorizationContext;
import org.springframework.stereotype.Component;

import com.soldesk.mapper.UserMapper;
import com.soldesk.vo.UserVO;

/**
 * 커뮤니티 "변경 액션"(글쓰기/댓글/신고/삭제)에 대해 제재 여부를 매 요청 DB에서 다시 확인한다.
 *
 * CustomUserDetails 의 SUSPENDED 권한은 로그인 시점에 한 번 계산되어 Authentication 에 고정되므로,
 * 관리자가 제재를 걸어도 이미 로그인해 있는 세션에는 재로그인 전까지 반영되지 않았다(제재 우회).
 * 반대로 제재가 만료돼도 재로그인 전까지 계속 차단됐다. 여기서 최신 상태를 읽어 두 방향 모두 해결한다.
 *
 * 열람용 매처에는 일부러 적용하지 않는다 — 요청 빈도가 높은 반면, 정지 회원이 재로그인 전까지
 * 글을 '읽을 수' 있는 것은 피해가 작기 때문이다. 실제 피해는 변경 액션 쪽에 있다.
 *
 * UserService(com.soldesk.service)가 아니라 UserMapper 를 쓰는 이유: 이 빈은 SecurityFilterChain 과
 * 함께 루트 컨텍스트에서 생성되는데, service 패키지는 웹(dispatcher) 컨텍스트에서만 스캔되어
 * 루트에서는 주입받을 수 없다. mapper 는 루트의 MapperScannerConfigurer 가 등록하므로 사용 가능하다.
 * (UserDetailService 가 UserMapper 를 직접 쓰는 것과 같은 이유)
 */
@Component
public class ActiveSuspensionAuthorizationManager
        implements AuthorizationManager<RequestAuthorizationContext> {

    @Autowired
    private UserMapper userMapper;

    @Override
    public AuthorizationDecision check(Supplier<Authentication> authentication,
                                       RequestAuthorizationContext context) {
        Authentication auth = authentication.get();
        if (auth == null || !auth.isAuthenticated() || auth instanceof AnonymousAuthenticationToken) {
            return new AuthorizationDecision(false); // 비로그인은 기존과 동일하게 거부
        }
        return new AuthorizationDecision(!isCurrentlySuspended(auth));
    }

    /**
     * 제재 안내 화면을 보여줘야 할 상황인지 판단한다.
     *
     * DB 기준(지금 제재 중)과 로그인 시점 캐시 권한(SUSPENDED)을 모두 본다. 열람용 매처는 캐시
     * 권한으로 막고 있어서, 제재가 만료됐는데 세션에 옛 권한이 남은 회원은 "차단은 되는데 DB상
     * 제재는 아닌" 상태가 된다. DB만 보면 이 회원이 안내 대신 맥락 없는 403 을 받게 된다.
     */
    public boolean shouldShowSuspendedNotice(Authentication auth) {
        if (isCurrentlySuspended(auth)) {
            return true;
        }
        if (auth == null) {
            return false;
        }
        for (GrantedAuthority authority : auth.getAuthorities()) {
            if ("SUSPENDED".equals(authority.getAuthority())) {
                return true;
            }
        }
        return false;
    }

    /** 지금 이 순간 제재 상태인지 DB에서 확인한다. 차단 판정과 안내 화면 선택이 공유하는 기준. */
    public boolean isCurrentlySuspended(Authentication auth) {
        if (auth == null || !auth.isAuthenticated() || auth instanceof AnonymousAuthenticationToken) {
            return false;
        }
        UserVO user = userMapper.findByEmail(auth.getName());
        if (user == null) {
            return false; // 탈퇴/삭제 등으로 계정이 사라진 경우는 제재가 아니라 일반 거부로 다룬다
        }
        return CustomUserDetails.isSuspended(user);
    }
}
