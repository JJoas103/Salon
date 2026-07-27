package com.soldesk.vo;

/**
 * 마이페이지 - 비밀번호 변경 폼 전용 (DB 미저장)
 */
public class PasswordChangeVO {

    private String currentPassword;
    private String newPassword;
    private String confirmPassword;

    public String getCurrentPassword() { return currentPassword; }
    public void setCurrentPassword(String currentPassword) { this.currentPassword = currentPassword; }
    public String getNewPassword() { return newPassword; }
    public void setNewPassword(String newPassword) { this.newPassword = newPassword; }
    public String getConfirmPassword() { return confirmPassword; }
    public void setConfirmPassword(String confirmPassword) { this.confirmPassword = confirmPassword; }
}
