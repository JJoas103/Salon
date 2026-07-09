package com.soldesk.vo;

/**
 * Wishlists - 찜 목록
 */
public class WishlistVO {

    private int wishlistId; // wishlist_id
    private int userId; // user_id
    private int salonId; // salon_id
    private String createdAt; // created_at

    public int getWishlistId() { return wishlistId; }
    public void setWishlistId(int wishlistId) { this.wishlistId = wishlistId; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public int getSalonId() { return salonId; }
    public void setSalonId(int salonId) { this.salonId = salonId; }
    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
}
