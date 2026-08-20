package com.soldesk.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.oauth2.client.registration.ClientRegistration;
import org.springframework.security.oauth2.client.registration.ClientRegistrationRepository;
import org.springframework.security.oauth2.client.registration.InMemoryClientRegistrationRepository;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserRequest;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserService;
import org.springframework.security.oauth2.core.AuthorizationGrantType;
import org.springframework.security.oauth2.core.ClientAuthenticationMethod;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.access.AccessDeniedHandler;
import org.springframework.security.web.access.expression.WebExpressionAuthorizationManager;
import org.springframework.security.web.util.matcher.AntPathRequestMatcher;
import org.springframework.util.StringUtils;

import com.soldesk.security.AjaxAwareAuthenticationFailureHandler;
import com.soldesk.security.OAuth2LoginFailureHandler;
import com.soldesk.security.UserDetailService;

import java.util.ArrayList;
import java.util.List;
import javax.servlet.http.HttpServletResponse;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Autowired
    private UserDetailService userDetailService;//사용자 정보

    // 구체 클래스가 아닌 인터페이스 타입으로 주입받아야 한다: loadUser()의 @Transactional 때문에
    // Spring이 JDK 동적 프록시(이 인터페이스만 구현)로 감싸서, 구체 클래스 타입 필드로는 주입에 실패한다.
    @Autowired
    private OAuth2UserService<OAuth2UserRequest, OAuth2User> customOAuth2UserService;//구글/네이버 로그인 후 Users와 연결

    @Value("${google.client-id:dummy-google-client-id}")
    private String googleClientId;

    @Value("${google.client-secret:dummy-google-client-secret}")
    private String googleClientSecret;

    @Value("${naver.client-id:dummy-naver-client-id}")
    private String naverClientId;

    @Value("${naver.client-secret:dummy-naver-client-secret}")
    private String naverClientSecret;

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http, DaoAuthenticationProvider authenticationProvider)
        throws Exception{
        http
            .authorizeHttpRequests(auth -> auth
                .requestMatchers(
                    new AntPathRequestMatcher("/admin/**")
                ).hasRole("ADMIN")
                .requestMatchers(
                    new AntPathRequestMatcher("/owner/**")
                ).hasRole("OWNER")
                .requestMatchers(
                    new AntPathRequestMatcher("/"),
                    new AntPathRequestMatcher("/common/home"),
                    new AntPathRequestMatcher("/user/login"),
                    new AntPathRequestMatcher("/user/join"),
                    new AntPathRequestMatcher("/user/check-email"),
                    new AntPathRequestMatcher("/resources/**"),
                    new AntPathRequestMatcher("/upload/**"),
                    new AntPathRequestMatcher("/common/community/suspended"),
                    // ai-service(FastAPI)가 서버 간 호출로 시술 카탈로그를 가져가는 내부 API
                    new AntPathRequestMatcher("/api/services"),
                    // 구글/네이버 로그인 시작(리다이렉트)·콜백 엔드포인트. 빠뜨리면 anyRequest().authenticated()에
                    // 걸려 로그인 시도 자체가 다시 로그인 페이지로 튕기는 리다이렉트 루프가 생긴다.
                    new AntPathRequestMatcher("/oauth2/authorization/**"),
                    new AntPathRequestMatcher("/login/oauth2/code/**")
                ).permitAll()
                .requestMatchers(
                    new AntPathRequestMatcher("/common/owner-request")
                )
                // 점주 승격 신청은 자체 회원가입(로컬) 계정만 가능 — 소셜(구글/네이버) 계정은 접근 불가
                .access(new WebExpressionAuthorizationManager("isAuthenticated() and !hasAuthority('SOCIAL_ACCOUNT')"))
                .requestMatchers(
                    new AntPathRequestMatcher("/common/community/write"),
                    new AntPathRequestMatcher("/common/community/*/edit"),
                    new AntPathRequestMatcher("/common/community/*/delete"),
                    new AntPathRequestMatcher("/common/community/*/comment"),
                    new AntPathRequestMatcher("/common/community/*/comment/*/delete"),
                    new AntPathRequestMatcher("/common/community/*/comment/*/report"),
                    new AntPathRequestMatcher("/common/community/*/react"),
                    new AntPathRequestMatcher("/common/community/*/report")
                )
                // 정지(SUSPENDED)된 계정은 커뮤니티 변경 액션만 막힌다 (로그인 자체는 계속 가능)
                .access(new WebExpressionAuthorizationManager("isAuthenticated() and !hasAuthority('SUSPENDED')"))
                .requestMatchers(
                    new AntPathRequestMatcher("/common/community/**")
                )
                // 정지(SUSPENDED)된 계정은 커뮤니티 탭 자체(목록/상세 포함)를 볼 수 없다.
                // 비로그인 사용자는 SUSPENDED 권한이 없으므로 기존처럼 자유롭게 둘러볼 수 있다.
                .access(new WebExpressionAuthorizationManager("!hasAuthority('SUSPENDED')"))
                .anyRequest().authenticated())
            .exceptionHandling(ex -> ex
                .authenticationEntryPoint((request, response, authException) ->
                    response.sendRedirect(request.getContextPath() + "/user/login?required"))
                .accessDeniedHandler(accessDeniedHandler()))
            .formLogin(form -> form
                .loginPage("/user/login")
                .loginProcessingUrl("/user/login")
                .usernameParameter("userEmail")
                .passwordParameter("userPassword")
                .defaultSuccessUrl("/", true)
                .failureHandler(new AjaxAwareAuthenticationFailureHandler())
                .permitAll())
            .oauth2Login(oauth2 -> oauth2
                .loginPage("/user/login")
                .userInfoEndpoint(userInfo -> userInfo.userService(customOAuth2UserService))
                .defaultSuccessUrl("/", true)
                // 폼 로그인 핸들러를 재사용하면 비밀번호 오류로 잘못 안내되고 원인이 로그에 안 남는다
                .failureHandler(new OAuth2LoginFailureHandler()))
            .logout(logout -> logout
                .logoutUrl("/user/logout")
                .logoutSuccessUrl("/common/home")
                .permitAll())    //로그아웃 설정
            .csrf(csrf -> csrf.disable())   //임시 토큰 비활성화
            .authenticationProvider(authenticationProvider);
        return http.build();
    }

    // 정지된 회원이 커뮤니티 탭에 접근하려 하면 안내 페이지로, 그 외 접근 거부는 기존 기본 처리(403)로
    @Bean
    public AccessDeniedHandler accessDeniedHandler() {
        return (request, response, ex) -> {
            if (request.getRequestURI().startsWith(request.getContextPath() + "/common/community")) {
                response.sendRedirect(request.getContextPath() + "/common/community/suspended");
            } else {
                response.sendError(HttpServletResponse.SC_FORBIDDEN);
            }
        };
    }

        // 구글/네이버 클라이언트 등록. oauth2.properties가 없거나 값이 비어 있으면 해당 provider는 아예
        // 등록하지 않는다 — ClientRegistration.build()가 clientId 공백을 허용하지 않아(IllegalArgumentException),
        // 값이 없는 provider까지 등록하려 하면 필터체인 빈 생성 자체가 실패해 앱이 아예 뜨지 않기 때문이다.
        // (@Value의 ":dummy-..." 기본값은 프로퍼티 키가 아예 없을 때만 적용되고, "google.client-id=" 처럼
        // 키는 있는데 값이 빈 경우엔 적용되지 않아 빈 문자열이 그대로 들어온다.)
        @Bean
        public ClientRegistrationRepository clientRegistrationRepository() {
            // Spring Boot의 CommonOAuth2Provider(자동 설정 전용, spring-boot-autoconfigure 소속)를 쓸 수 없는
            // 순수 Spring MVC 프로젝트라 구글도 네이버와 동일하게 직접 구성한다.
            // scope에 "openid"를 넣지 않아야 OIDC 로그인이 아닌 일반 OAuth2 로그인으로 처리되어
            // 아래 userInfoEndpoint().userService(customOAuth2UserService)가 그대로 적용된다.
            List<ClientRegistration> registrations = new ArrayList<>();

            if (StringUtils.hasText(googleClientId)) {
                registrations.add(ClientRegistration.withRegistrationId("google")
                        .clientId(googleClientId)
                        .clientSecret(googleClientSecret)
                        .authorizationGrantType(AuthorizationGrantType.AUTHORIZATION_CODE)
                        .clientAuthenticationMethod(ClientAuthenticationMethod.CLIENT_SECRET_BASIC)
                        .redirectUri("{baseUrl}/login/oauth2/code/{registrationId}")
                        .authorizationUri("https://accounts.google.com/o/oauth2/v2/auth")
                        .tokenUri("https://www.googleapis.com/oauth2/v4/token")
                        .userInfoUri("https://www.googleapis.com/oauth2/v3/userinfo")
                        .userNameAttributeName("sub")
                        .scope("email", "profile")
                        .clientName("Google")
                        .build());
            }

            // 네이버는 Spring Security 기본 제공 프로바이더가 아니라 직접 구성한다.
            if (StringUtils.hasText(naverClientId)) {
                registrations.add(ClientRegistration.withRegistrationId("naver")
                        .clientId(naverClientId)
                        .clientSecret(naverClientSecret)
                        .authorizationGrantType(AuthorizationGrantType.AUTHORIZATION_CODE)
                        .clientAuthenticationMethod(ClientAuthenticationMethod.CLIENT_SECRET_POST)
                        .redirectUri("{baseUrl}/login/oauth2/code/{registrationId}")
                        .authorizationUri("https://nid.naver.com/oauth2.0/authorize")
                        .tokenUri("https://nid.naver.com/oauth2.0/token")
                        .userInfoUri("https://openapi.naver.com/v1/nid/me")
                        .userNameAttributeName("response")
                        .scope("name", "email")
                        .clientName("Naver")
                        .build());
            }

            return new InMemoryClientRegistrationRepository(registrations);
        }

        @Bean
        public PasswordEncoder passwordEncoder(){
            return new BCryptPasswordEncoder();
        }
        
        @Bean
        public DaoAuthenticationProvider authenticationProvider(PasswordEncoder passwordEncoder){
            DaoAuthenticationProvider provider = new DaoAuthenticationProvider();
            provider.setUserDetailsService(userDetailService);
            provider.setPasswordEncoder(passwordEncoder);
            return provider;
        }//사용자 인증을 처리하는 객체
}
