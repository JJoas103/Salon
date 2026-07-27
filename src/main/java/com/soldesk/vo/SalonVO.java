package com.soldesk.vo;

/**
 * Salons - 미용실
 */
public class SalonVO {

    private int salonId; // salon_id
    private int ownerId; // 점주 user_id (owner_id)
    private String salonName;
    private String address;
    private String phoneNumber; // phone_number
    private String description;
    private java.math.BigDecimal averageRating; // 평균 별점 (average_rating)
    private String imageUrl; // image_url
    private String createdAt; // created_at
    private String updatedAt; // updated_at

    public int getSalonId() { return salonId; }
    public void setSalonId(int salonId) { this.salonId = salonId; }
    public int getOwnerId() { return ownerId; }
    public void setOwnerId(int ownerId) { this.ownerId = ownerId; }
    public String getSalonName() { return salonName; }
    public void setSalonName(String salonName) { this.salonName = salonName; }
    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }
    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public java.math.BigDecimal getAverageRating() { return averageRating; }
    public void setAverageRating(java.math.BigDecimal averageRating) { this.averageRating = averageRating; }
    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
    public String getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(String updatedAt) { this.updatedAt = updatedAt; }
}
