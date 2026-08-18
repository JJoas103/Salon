package com.soldesk.vo;

/**
 * Reviews - 리뷰
 */
public class ReviewVO {

    private int reviewId; // review_id
    private int userId; // user_id
    private int salonId; // salon_id
    private int reservationId; // reservation_id
    private int rating; // 1~5
    private String comment;
    private String imageUrl; // image_url
    private String imageUrl2; // image_url2
    private String createdAt; // created_at
    private String updatedAt; // updated_at
    private String userName;
    private String salonName;

    public int getReviewId() { return reviewId; }
    public void setReviewId(int reviewId) { this.reviewId = reviewId; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public int getSalonId() { return salonId; }
    public void setSalonId(int salonId) { this.salonId = salonId; }
    public int getReservationId() { return reservationId; }
    public void setReservationId(int reservationId) { this.reservationId = reservationId; }
    public int getRating() { return rating; }
    public void setRating(int rating) { this.rating = rating; }
    public String getComment() { return comment; }
    public void setComment(String comment) { this.comment = comment; }
    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
    public String getImageUrl2() { return imageUrl2; }
    public void setImageUrl2(String imageUrl2) { this.imageUrl2 = imageUrl2; }
    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
    public String getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(String updatedAt) { this.updatedAt = updatedAt; }
    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }
    public String getSalonName() { return salonName; }
    public void setSalonName(String salonName) { this.salonName = salonName; }
}
