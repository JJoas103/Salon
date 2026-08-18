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

    @Autowired
    private CouponService couponService;

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

        //가입 축하 쿠폰
        //issue_type='signup' 정책을 만들면 그떄부터나가고, is_active를 끄면 멈춘다.
        couponService.issueByType(user.getUserId(), "signup");
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

    // 마이페이지 "내 글에 달린 댓글" 탭 확인 -- 안읽음 배지를 0으로 되돌린다
    @Transactional
    public void markReplyCheck(int userId) {
        userMapper.updateLastReplyCheckAt(userId);
    }
}
