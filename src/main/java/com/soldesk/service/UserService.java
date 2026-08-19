package com.soldesk.service;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

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

    @Autowired
    private FileService fileService;

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

    /**
     * 마이페이지 "내 정보 변경". 이메일은 로그인 ID라 여기서 안 받는다 — 바꾸고 싶으면 관리자에게
     * 문의해야 하는 정책(화면 안내 문구로 노출). updateUser 가 password 도 같이 SET 하므로
     * 기존 비밀번호 그대로 들고 있는 user 객체에 이름/전화/사진만 바꿔서 넘긴다.
     *
     * @param profileImage 새로 고를 때만 전달됨(선택). null/빈 파일이면 기존 사진 유지.
     */
    @Transactional
    public void updateProfile(String email, String userName, String phoneNumber, MultipartFile profileImage)
            throws IOException {
        if (userName == null || userName.trim().isEmpty()) {
            throw new IllegalArgumentException("이름을 입력해주세요.");
        }
        // U+FFFD(대체 문자)는 정상적으로 입력될 일이 없고, 클라이언트가 잘못된 인코딩으로 텍스트를 보냈을 때만
        // 나타난다 — 이걸 그대로 저장하면 이름이 깨진 채로 DB에 남아 사이드바/모달 어디서 봐도 깨져 보인다.
        if (userName.indexOf('�') >= 0) {
            throw new IllegalArgumentException("이름에 읽을 수 없는 문자가 포함되어 있습니다. 다시 입력해주세요.");
        }
        if (phoneNumber == null || !phoneNumber.matches("[0-9-]{9,13}")) {
            throw new IllegalArgumentException("연락처는 숫자와 하이픈(-)만 사용해 입력해주세요.");
        }
        UserVO user = userMapper.findByEmail(email);
        user.setUserName(userName.trim());
        user.setPhoneNumber(phoneNumber);
        String saved = fileService.saveFile(profileImage);
        if (saved != null) {
            fileService.deleteFile(stripUploadPrefix(user.getProfileImageUrl()));
            user.setProfileImageUrl("/upload/" + saved);
        }
        userMapper.updateUser(user);
    }//이름·전화번호·프로필사진 변경 (이메일은 정책상 불변)

    private String stripUploadPrefix(String imageUrl) {
        if (imageUrl != null && imageUrl.startsWith("/upload/")) {
            return imageUrl.substring("/upload/".length());
        }
        return null;
    }

    @Transactional
    public boolean toggleNotifications(String email){
        UserVO user = userMapper.findByEmail(email);
        userMapper.toggleNotifications(user.getUserId());
        return !user.isNotificationsEnabled();
    }//알림 설정 on/off — 바뀐 뒤의 값을 돌려줘서 화면이 바로 반영할 수 있게 한다

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
}
