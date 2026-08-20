package com.soldesk.vo;

/**
 * Comments - 커뮤니티 댓글
 */
public class CommentVO {

    private int commentId; // comment_id
    private int postId; // post_id
    private int userId; // 작성자 (user_id)
    private String content;
    private String createdAt; // created_at
    private String updatedAt; // updated_at
    private String authorName; // Users JOIN 조회 전용 (DB 컬럼 아님)
    private int reportCount; // 누적 신고 수 (DB 컬럼 아님 -- comment_reports COUNT(*) 조인 집계, 관리자 화면 전용)
    private String reportReasonSummary; // 신고 사유 집계 요약 (DB 컬럼 아님, 관리자 화면 전용)
    private String postTitle; // 소속 게시글 제목 (DB 컬럼 아님, Posts JOIN 조회, 관리자 화면 전용)
    private String postStatus; // 소속 게시글 상태 (DB 컬럼 아님, Posts JOIN 조회 -- 마이페이지에서 삭제/블라인드된 글 판별용)

    public int getCommentId() { return commentId; }
    public void setCommentId(int commentId) { this.commentId = commentId; }
    public int getPostId() { return postId; }
    public void setPostId(int postId) { this.postId = postId; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
    public String getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(String updatedAt) { this.updatedAt = updatedAt; }
    public String getAuthorName() { return authorName; }
    public void setAuthorName(String authorName) { this.authorName = authorName; }
    public int getReportCount() { return reportCount; }
    public void setReportCount(int reportCount) { this.reportCount = reportCount; }
    public String getReportReasonSummary() { return reportReasonSummary; }
    public void setReportReasonSummary(String reportReasonSummary) { this.reportReasonSummary = reportReasonSummary; }
    public String getPostTitle() { return postTitle; }
    public void setPostTitle(String postTitle) { this.postTitle = postTitle; }
    public String getPostStatus() { return postStatus; }
    public void setPostStatus(String postStatus) { this.postStatus = postStatus; }
}
