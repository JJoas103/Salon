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
    private java.math.BigDecimal minimumPrice;
    private String createdAt; // created_at
    private String updatedAt; // updated_at
    private String closedAt; // 폐업일시 (null이면 운영중)
    private java.math.BigDecimal latitude;  //위도
    private java.math.BigDecimal longitude; //경도
    private String ownerName; // 점주 이름 (Users LEFT JOIN, 관리자 매장목록 전용)


    private String wishlistCreatedAt;

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
    public java.math.BigDecimal getMinimumPrice() { return minimumPrice; }
    public void setMinimumPrice(java.math.BigDecimal minimumPrice) { this.minimumPrice = minimumPrice; }
    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
    public String getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(String updatedAt) { this.updatedAt = updatedAt; }
    public String getClosedAt() { return closedAt; }
    public void setClosedAt(String closedAt) { this.closedAt = closedAt; }

    public java.math.BigDecimal getLatitude() {
        return this.latitude;
    }

    public void setLatitude(java.math.BigDecimal latitude) {
        this.latitude = latitude;
    }

    public java.math.BigDecimal getLongitude() {
        return this.longitude;
    }

    public void setLongitude(java.math.BigDecimal longitude) {
        this.longitude = longitude;
    }

    public String getWishlistCreatedAt() { return wishlistCreatedAt; }
    public void setWishlistCreatedAt(String wishlistCreatedAt) { this.wishlistCreatedAt = wishlistCreatedAt; }
    public String getOwnerName() { return ownerName; }
    public void setOwnerName(String ownerName) { this.ownerName = ownerName; }

}
