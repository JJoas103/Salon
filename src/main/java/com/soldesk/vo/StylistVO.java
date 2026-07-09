package com.soldesk.vo;

/**
 * Stylists - 스타일리스트
 */
public class StylistVO {

    private int stylistId; // stylist_id
    private int salonId; // salon_id
    private String name;
    private String phoneNumber; // phone_number
    private String description;
    private String imageUrl; // image_url
    private String createdAt; // created_at
    private String updatedAt; // updated_at

    public int getStylistId() { return stylistId; }
    public void setStylistId(int stylistId) { this.stylistId = stylistId; }
    public int getSalonId() { return salonId; }
    public void setSalonId(int salonId) { this.salonId = salonId; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
    public String getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(String updatedAt) { this.updatedAt = updatedAt; }
}
