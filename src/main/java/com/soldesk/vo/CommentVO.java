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
}
