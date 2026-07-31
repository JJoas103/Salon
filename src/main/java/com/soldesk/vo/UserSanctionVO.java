package com.soldesk.vo;

import java.time.LocalDateTime;

/**
 * user_sanctions - 회원 제재 이력
 */
public class UserSanctionVO {

    private int sanctionId;
    private int userId;
    private Integer postId; // 원인이 된 게시글 ID (참고용, 삭제 후에도 남음)
    private String postTitle; // 게시글 삭제 전 제목 스냅샷
    private Integer commentId; // 원인이 된 댓글 ID (참고용, 삭제 후에도 남음)
    private String commentContent; // 댓글 삭제 전 내용 스냅샷
    private String adminReason; // 관리자가 입력한 제재 사유
    private String sanctionType; // suspend_3d / suspend_7d / permanent
    private LocalDateTime suspendedUntil; // permanent면 null
    private String createdAt;

    public int getSanctionId() { return sanctionId; }
    public void setSanctionId(int sanctionId) { this.sanctionId = sanctionId; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public Integer getPostId() { return postId; }
    public void setPostId(Integer postId) { this.postId = postId; }
    public String getPostTitle() { return postTitle; }
    public void setPostTitle(String postTitle) { this.postTitle = postTitle; }
    public Integer getCommentId() { return commentId; }
    public void setCommentId(Integer commentId) { this.commentId = commentId; }
    public String getCommentContent() { return commentContent; }
    public void setCommentContent(String commentContent) { this.commentContent = commentContent; }
    public String getAdminReason() { return adminReason; }
    public void setAdminReason(String adminReason) { this.adminReason = adminReason; }
    public String getSanctionType() { return sanctionType; }
    public void setSanctionType(String sanctionType) { this.sanctionType = sanctionType; }
    public LocalDateTime getSuspendedUntil() { return suspendedUntil; }
    public void setSuspendedUntil(LocalDateTime suspendedUntil) { this.suspendedUntil = suspendedUntil; }
    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
}
