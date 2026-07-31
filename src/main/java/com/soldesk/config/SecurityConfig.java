package com.soldesk.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.access.AccessDeniedHandler;
import org.springframework.security.web.access.expression.WebExpressionAuthorizationManager;
import org.springframework.security.web.util.matcher.AntPathRequestMatcher;

import com.soldesk.security.AjaxAwareAuthenticationFailureHandler;
import com.soldesk.security.UserDetailService;

import javax.servlet.http.HttpServletResponse;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Autowired
    private UserDetailService userDetailService;//사용자 정보

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
                    new AntPathRequestMatcher("/reserve/info"),
                    new AntPathRequestMatcher("/common/community/suspended")
                ).permitAll()
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
