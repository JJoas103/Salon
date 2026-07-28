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
import org.springframework.security.web.util.matcher.AntPathRequestMatcher;

import com.soldesk.security.UserDetailService;

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
                    new AntPathRequestMatcher("/reserve/info"),
                    new AntPathRequestMatcher("/common/mypage"),
                    new AntPathRequestMatcher("/common/mypage/**"),
                    new AntPathRequestMatcher("/common/community/write"),
                    new AntPathRequestMatcher("/common/community/*/edit"),
                    new AntPathRequestMatcher("/common/community/*/delete"),
                    new AntPathRequestMatcher("/common/community/*/comment"),
                    new AntPathRequestMatcher("/common/community/*/comment/*/delete"),
                    new AntPathRequestMatcher("/common/community/*/react")
                )
                .authenticated()
                .anyRequest().permitAll())
            .formLogin(form -> form
                .loginPage("/user/login")
                .loginProcessingUrl("/user/login")
                .usernameParameter("userEmail")
                .passwordParameter("userPassword")
                .defaultSuccessUrl("/", true)
                .failureUrl("/user/login?error")
                .permitAll()) 
            .logout(logout -> logout
                .logoutUrl("/user/logout")
                .logoutSuccessUrl("/")
                .permitAll())    //로그아웃 설정
            .csrf(csrf -> csrf.disable())   //임시 토큰 비활성화
            .authenticationProvider(authenticationProvider); 
        return http.build();               
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
