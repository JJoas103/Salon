package com.soldesk.vo;

/**
 * Users - 사용자
 */
public class UserVO {

    private int userId; // 사용자 고유 식별자 (user_id)
    private String email; // 이메일 (로그인 ID)
    private String password; // 비밀번호
    private String userName; // 이름
    private String phoneNumber; // 전화번호 (phone_number)
    private String userType; // 사용자 유형: customer/owner/admin (user_type)
    private String createdAt; // 생성일시 (created_at)
    private String updatedAt; // 수정일시 (updated_at)
    private String deletedAt; // 삭제일시 (deleted_at)
    private String confirmPassword; // 비밀번호 확인용 (DB 미저장, 폼 검증 전용)
    private Integer pendingRequestId; // 대기중인 점주 승격 요청 id (OwnerRequests LEFT JOIN, 없으면 null)
    private String pendingSalonName; // 대기중인 점주 승격 요청의 매장명
    private String pendingSalonPhone; // 대기중인 점주 승격 요청의 매장 연락처
    private String pendingMessage; // 대기중인 점주 승격 요청의 신청 사유
    private String pendingRequestedAt; // 대기중인 점주 승격 요청의 신청일시
    private String status; // 커뮤니티 이용 제한 상태: active/suspended/banned (status)
    private java.time.LocalDateTime suspendedUntil; // 정지 만료 시각, 영구정지면 null (suspended_until)

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }
    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }
    public String getUserType() { return userType; }
    public void setUserType(String userType) { this.userType = userType; }
    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
    public String getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(String updatedAt) { this.updatedAt = updatedAt; }
    public String getDeletedAt() { return deletedAt; }
    public void setDeletedAt(String deletedAt) { this.deletedAt = deletedAt; }
    public String getConfirmPassword() { return confirmPassword; }
    public void setConfirmPassword(String confirmPassword) { this.confirmPassword = confirmPassword; }
    public Integer getPendingRequestId() { return pendingRequestId; }
    public void setPendingRequestId(Integer pendingRequestId) { this.pendingRequestId = pendingRequestId; }
    public String getPendingSalonName() { return pendingSalonName; }
    public void setPendingSalonName(String pendingSalonName) { this.pendingSalonName = pendingSalonName; }
    public String getPendingSalonPhone() { return pendingSalonPhone; }
    public void setPendingSalonPhone(String pendingSalonPhone) { this.pendingSalonPhone = pendingSalonPhone; }
    public String getPendingMessage() { return pendingMessage; }
    public void setPendingMessage(String pendingMessage) { this.pendingMessage = pendingMessage; }
    public String getPendingRequestedAt() { return pendingRequestedAt; }
    public void setPendingRequestedAt(String pendingRequestedAt) { this.pendingRequestedAt = pendingRequestedAt; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public java.time.LocalDateTime getSuspendedUntil() { return suspendedUntil; }
    public void setSuspendedUntil(java.time.LocalDateTime suspendedUntil) { this.suspendedUntil = suspendedUntil; }
}
