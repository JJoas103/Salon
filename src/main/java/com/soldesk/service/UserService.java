package com.soldesk.service;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.soldesk.mapper.UserMapper;
import com.soldesk.mapper.UserSanctionMapper;
import com.soldesk.vo.UserSanctionVO;
import com.soldesk.vo.UserVO;

@Service
public class UserService {

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private UserSanctionMapper userSanctionMapper;

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

    // 회원 제재(정지) 부여 + 이력 기록 -- postId/postTitle은 원인이 된 게시글 참고용 스냅샷 (댓글이 원인이면 7-인자 오버로드 사용)
    @Transactional
    public void suspendUser(int userId, String sanctionType, Integer postId, String postTitle, String adminReason) {
        suspendUser(userId, sanctionType, postId, postTitle, null, null, adminReason);
    }

    // 댓글 신고로 인한 제재 -- commentId/commentContent는 댓글이 원인일 때의 스냅샷, postId/postTitle은 그 댓글이 달린 글의 참고 정보,
    // adminReason은 관리자가 직접 입력한 제재 사유
    @Transactional
    public void suspendUser(int userId, String sanctionType, Integer postId, String postTitle,
                             Integer commentId, String commentContent, String adminReason) {
        LocalDateTime until = null;
        String status;
        switch (sanctionType) {
            case "suspend_3d": status = "suspended"; until = LocalDateTime.now().plusDays(3); break;
            case "suspend_7d": status = "suspended"; until = LocalDateTime.now().plusDays(7); break;
            case "permanent":  status = "banned"; break;
            default: throw new IllegalArgumentException("올바르지 않은 제재 유형입니다.");
        }
        userMapper.updateSuspension(userId, status, until);

        UserSanctionVO sanction = new UserSanctionVO();
        sanction.setUserId(userId);
        sanction.setPostId(postId);
        sanction.setPostTitle(postTitle);
        sanction.setCommentId(commentId);
        sanction.setCommentContent(commentContent);
        sanction.setAdminReason(adminReason);
        sanction.setSanctionType(sanctionType);
        sanction.setSuspendedUntil(until);
        userSanctionMapper.insert(sanction);
    }

    // 회원 제재 이력 조회 (관리자 화면용)
    public List<UserSanctionVO> getSanctionHistory(int userId) {
        return userSanctionMapper.findByUserId(userId);
    }

    // 현재 제재중인 회원 목록 (관리자 화면용)
    public List<UserVO> getSanctionedUsers() {
        return userMapper.findSanctionedUsers();
    }

    // 제재 해제 -- status를 active로 되돌리고 suspended_until 초기화
    @Transactional
    public void liftSanction(int userId) {
        userMapper.updateSuspension(userId, "active", null);
    }
}
