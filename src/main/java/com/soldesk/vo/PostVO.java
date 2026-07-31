package com.soldesk.vo;

/**
 * Posts - 커뮤니티 게시글
 */
public class PostVO {

    private int postId; // post_id
    private int userId; // 작성자 (user_id)
    private String title;
    private String content;
    private String category;
    private int viewCount; // 조회수 (view_count)
    private String createdAt; // created_at
    private String updatedAt; // updated_at
    private String imageUrl; // 첨부 이미지 파일명 (image_url)
    private int salonId; // 연관 미용실 (salon_id)
    private int likeCount; // 좋아요 수 (like_count)
    private int dislikeCount; // 별로예요 수 (dislike_count)
    private int reportCount; // 누적 신고 수 (report_count)
    private String status; // 노출 상태 visible|blinded (status)
    private String authorName; // Users JOIN 조회 전용 (DB 컬럼 아님)
    private String salonName; // Salons JOIN 조회 전용 (DB 컬럼 아님)
    private String reportReasonSummary; // 신고 사유 집계 요약, 관리자 화면 전용 (DB 컬럼 아님)

    public int getPostId() { return postId; }
    public void setPostId(int postId) { this.postId = postId; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public int getViewCount() { return viewCount; }
    public void setViewCount(int viewCount) { this.viewCount = viewCount; }
    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
    public String getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(String updatedAt) { this.updatedAt = updatedAt; }
    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
    public int getSalonId() { return salonId; }
    public void setSalonId(int salonId) { this.salonId = salonId; }
    public int getLikeCount() { return likeCount; }
    public void setLikeCount(int likeCount) { this.likeCount = likeCount; }
    public int getDislikeCount() { return dislikeCount; }
    public void setDislikeCount(int dislikeCount) { this.dislikeCount = dislikeCount; }
    public int getReportCount() { return reportCount; }
    public void setReportCount(int reportCount) { this.reportCount = reportCount; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getAuthorName() { return authorName; }
    public void setAuthorName(String authorName) { this.authorName = authorName; }
    public String getSalonName() { return salonName; }
    public void setSalonName(String salonName) { this.salonName = salonName; }
    public String getReportReasonSummary() { return reportReasonSummary; }
    public void setReportReasonSummary(String reportReasonSummary) { this.reportReasonSummary = reportReasonSummary; }
}
