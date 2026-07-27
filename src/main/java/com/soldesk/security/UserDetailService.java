package com.soldesk.security;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.method.P;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import com.soldesk.mapper.UserMapper;
import com.soldesk.vo.UserVO;

@Service
public class UserDetailService implements UserDetailsService{
    
    @Autowired
    private UserMapper userMapper;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        
        UserVO user = userMapper.findByEmail(username);// DB에서 사용자 조회
        if(user == null) {
            throw new UsernameNotFoundException("회원을 찾을 수 없습니다:" + username);
        }//email과 일치하는 회원 없음

        return new CustomUserDetails(user, resolveRole(user.getUserType()));
        //CustomUserDetails: 인증된 사용자 객체(이름, userId 포함)를 생성
    }   
    //권한 설정(문자열 -> 권한으로 변환)
    private String resolveRole(String usertype){
        if("ADMIN".equalsIgnoreCase(usertype)){
            return "ADMIN";
        }
        else if("OWNER".equalsIgnoreCase(usertype)){
            return "OWNER";
        }
        return "CUSTOMER";
    }
}
