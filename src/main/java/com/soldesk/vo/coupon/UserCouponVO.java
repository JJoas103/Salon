package com.soldesk.vo.coupon;

public class UserCouponVO {
    private int userCouponId;
    private int userId;
    private int couponId;
    
    private String status;         // ENUM('available','reserved','used','expired') NOT NULL DEFAULT 'available',
    private Integer reservationId;    // reserved/used 일 때 어느 예약에 묶였는지
    private java.time.LocalDateTime issuedAt;
    //발급 시점에 Coupons.valid_until 을 복사한다. 정책의 기간을 나중에 줄여도
    //이미 나간 쿠폰의 유효기간이 소급해서 바뀌면 안 된다.
    private java.time.LocalDateTime expiresAt;
    private java.time.LocalDateTime usedAt;

    // ===== 조인 결과 (Coupons) =====
    private String couponName;
    private String discountType;
    private java.math.BigDecimal discountValue;
    private java.math.BigDecimal maxDiscount;
    private java.math.BigDecimal minOrderAmount;
    private Integer couponSalonId;     // NULL = 전 매장 공통
    private Integer couponServiceId;   // NULL = 전 시술 공통

    public String getCouponName() {
        return this.couponName;
    }

    public void setCouponName(String couponName) {
        this.couponName = couponName;
    }

    public String getDiscountType() {
        return this.discountType;
    }

    public void setDiscountType(String discountType) {
        this.discountType = discountType;
    }

    public java.math.BigDecimal getDiscountValue() {
        return this.discountValue;
    }

    public void setDiscountValue(java.math.BigDecimal discountValue) {
        this.discountValue = discountValue;
    }

    public java.math.BigDecimal getMaxDiscount() {
        return this.maxDiscount;
    }

    public void setMaxDiscount(java.math.BigDecimal maxDiscount) {
        this.maxDiscount = maxDiscount;
    }

    public java.math.BigDecimal getMinOrderAmount() {
        return this.minOrderAmount;
    }

    public void setMinOrderAmount(java.math.BigDecimal minOrderAmount) {
        this.minOrderAmount = minOrderAmount;
    }

    public Integer getCouponSalonId() {
        return this.couponSalonId;
    }

    public void setCouponSalonId(Integer couponSalonId) {
        this.couponSalonId = couponSalonId;
    }

    public Integer getCouponServiceId() {
        return this.couponServiceId;
    }

    public void setCouponServiceId(Integer couponServiceId) {
        this.couponServiceId = couponServiceId;
    }


    public int getUserCouponId() {
        return this.userCouponId;
    }

    public void setUserCouponId(int userCouponId) {
        this.userCouponId = userCouponId;
    }

    public int getUserId() {
        return this.userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public int getCouponId() {
        return this.couponId;
    }

    public void setCouponId(int couponId) {
        this.couponId = couponId;
    }

    public String getStatus() {
        return this.status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Integer getReservationId() {
        return this.reservationId;
    }

    public void setReservationId(Integer reservationId) {
        this.reservationId = reservationId;
    }

    public java.time.LocalDateTime getIssuedAt() {
        return this.issuedAt;
    }

    public void setIssuedAt(java.time.LocalDateTime issuedAt) {
        this.issuedAt = issuedAt;
    }

    public java.time.LocalDateTime getExpiresAt() {
        return this.expiresAt;
    }

    public void setExpiresAt(java.time.LocalDateTime expiresAt) {
        this.expiresAt = expiresAt;
    }

    public java.time.LocalDateTime getUsedAt() {
        return this.usedAt;
    }

    public void setUsedAt(java.time.LocalDateTime usedAt) {
        this.usedAt = usedAt;
    }
  
}
