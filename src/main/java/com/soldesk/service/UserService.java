package com.soldesk.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.soldesk.mapper.UserMapper;
import com.soldesk.vo.UserVO;

@Service   
public class UserService {

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Transactional
    public boolean isEmailAvailable(String userEmail){
        UserVO user = userMapper.findByEmail(userEmail);
        if(user == null) return true;
        return false;
    }//이메일 사용가능여부

    @Transactional
    public void join(UserVO user){
        String dbPass = passwordEncoder.encode(user.getPassword());
        user.setPassword(dbPass);
        userMapper.insertUser(user);
    }//회원가입

    @Transactional
    public UserVO getUser(String email){
        UserVO user = userMapper.findByEmail(email);
    return user;
    }//이메일로 회원정보 조회
}
