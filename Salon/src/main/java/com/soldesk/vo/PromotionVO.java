package com.soldesk.vo;

/**
 * Promotions - 프로모션/광고
 */
public class PromotionVO {

    private int promotionId; // promotion_id
    private int salonId; // salon_id (nullable)
    private String title;
    private String description;
    private String startDate; // start_date
    private String endDate; // end_date
    private java.math.BigDecimal discountRate; // 할인율 (discount_rate)
    private String couponCode; // coupon_code
    private String imageUrl; // image_url
    private String createdAt; // created_at
    private String updatedAt; // updated_at

    public int getPromotionId() { return promotionId; }
    public void setPromotionId(int promotionId) { this.promotionId = promotionId; }
    public int getSalonId() { return salonId; }
    public void setSalonId(int salonId) { this.salonId = salonId; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getStartDate() { return startDate; }
    public void setStartDate(String startDate) { this.startDate = startDate; }
    public String getEndDate() { return endDate; }
    public void setEndDate(String endDate) { this.endDate = endDate; }
    public java.math.BigDecimal getDiscountRate() { return discountRate; }
    public void setDiscountRate(java.math.BigDecimal discountRate) { this.discountRate = discountRate; }
    public String getCouponCode() { return couponCode; }
    public void setCouponCode(String couponCode) { this.couponCode = couponCode; }
    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
    public String getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(String updatedAt) { this.updatedAt = updatedAt; }
}
