package com.soldesk.service;

import java.util.List;

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

    @Transactional
    public void changePassword(String email, String currentPassword, String newPassword){
        UserVO user = userMapper.findByEmail(email);
        if(!passwordEncoder.matches(currentPassword, user.getPassword())){
            throw new IllegalArgumentException("현재 비밀번호가 일치하지 않습니다.");
        }
        user.setPassword(passwordEncoder.encode(newPassword));
        userMapper.updateUser(user);
    }//비밀번호 변경

    @Transactional
    public List<UserVO> getMembers(String keyword, String userType, String status, int page, int size){
        int offset = (page - 1) * size;
        return userMapper.findMembers(keyword, userType, status, offset, size);
    }//관리자 회원 목록 (검색/필터/활성·탈퇴 + 페이지네이션)

    @Transactional
    public int countMembers(String keyword, String userType, String status){
        return userMapper.countMembers(keyword, userType, status);
    }//현재 검색조건의 총 건수 (총 페이지 수 계산용)

    @Transactional
    public int countActiveMembers(){
        return userMapper.countActiveMembers();
    }

    @Transactional
    public int countNewMembersThisMonth(){
        return userMapper.countNewMembersThisMonth();
    }

    @Transactional
    public int countDeletedMembers(){
        return userMapper.countDeletedMembers();
    }

    @Transactional
    public void withdrawMember(int userId){
        UserVO user = userMapper.findById(userId);
        if(user.getDeletedAt() != null){
            throw new IllegalArgumentException("이미 탈퇴된 회원입니다.");
        }
        if(!"customer".equals(user.getUserType())){
            throw new IllegalArgumentException("점주/관리자 회원은 먼저 일반회원으로 전환한 후 탈퇴 처리할 수 있습니다.");
        }
        userMapper.softDeleteById(userId);
    }//회원 탈퇴 (점주/관리자, 이미 탈퇴된 회원 차단)

    @Transactional
    public void demoteToCustomer(int userId){
        userMapper.demoteToCustomer(userId);
    }//점주/관리자 → 일반회원 강등
}