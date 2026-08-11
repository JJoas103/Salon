package com.soldesk.vo.coupon;

public class CouponVO {
    private int couponId;
    private Integer promotionId;
    private Integer salonId;
    private Integer serviceId;
    private String couponName;
    private String couponCode;
    private String discountType;
    private java.math.BigDecimal discountValue;
    private java.math.BigDecimal maxDiscount;
    private java.math.BigDecimal minOrderAmount;
    // <input type="date"> 가 보내는 'yyyy-MM-dd' 를 그대로 받는다.
    // 이 어노테이션이 없으면 폼 제출 시 타입 변환에 실패해 400 이 난다.
    @org.springframework.format.annotation.DateTimeFormat(pattern = "yyyy-MM-dd")
    private java.time.LocalDate validFrom;

    @org.springframework.format.annotation.DateTimeFormat(pattern = "yyyy-MM-dd")
    private java.time.LocalDate validUntil;
    private String issueType;
    private boolean oncePerUser;
    private boolean isActive;
    private String createdAt;
    private String updatedAt;

    // ===== 집계 (관리자 목록에서만 채워진다) =====
    private int issuedCount;   // 지금까지 나간 장수
    private int usedCount;     // 그중 실제로 쓰인 장수

    public int getIssuedCount() { return this.issuedCount; }
    public void setIssuedCount(int issuedCount) { this.issuedCount = issuedCount; }
    public int getUsedCount() { return this.usedCount; }
    public void setUsedCount(int usedCount) { this.usedCount = usedCount; }

    /** 매장 한정 쿠폰인지 (화면에서 "전 매장 공통" 과 가르는 데 쓴다) */
    public boolean isSalonLimited() { return this.salonId != null; }

    public int getCouponId() {
        return this.couponId;
    }

    public void setCouponId(int couponId) {
        this.couponId = couponId;
    }

    public Integer getPromotionId() {
        return this.promotionId;
    }

    public void setPromotionId(Integer promotionId) {
        this.promotionId = promotionId;
    }

    public Integer getSalonId() {
        return this.salonId;
    }

    public void setSalonId(Integer salonId) {
        this.salonId = salonId;
    }

    public Integer getServiceId() {
        return this.serviceId;
    }

    public void setServiceId(Integer serviceId) {
        this.serviceId = serviceId;
    }

    public String getCouponName() {
        return this.couponName;
    }

    public void setCouponName(String couponName) {
        this.couponName = couponName;
    }

    public String getCouponCode() {
        return this.couponCode;
    }

    public void setCouponCode(String couponCode) {
        this.couponCode = couponCode;
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

    public java.time.LocalDate getValidFrom() {
        return this.validFrom;
    }

    public void setValidFrom(java.time.LocalDate validFrom) {
        this.validFrom = validFrom;
    }

    public java.time.LocalDate getValidUntil() {
        return this.validUntil;
    }

    public void setValidUntil(java.time.LocalDate validUntil) {
        this.validUntil = validUntil;
    }

    public String getIssueType() {
        return this.issueType;
    }

    public void setIssueType(String issueType) {
        this.issueType = issueType;
    }

    public boolean isOncePerUser() {
        return this.oncePerUser;
    }

    public boolean getOncePerUser() {
        return this.oncePerUser;
    }

    public void setOncePerUser(boolean oncePerUser) {
        this.oncePerUser = oncePerUser;
    }

    public boolean isIsActive() {
        return this.isActive;
    }

    public boolean getIsActive() {
        return this.isActive;
    }

    public void setIsActive(boolean isActive) {
        this.isActive = isActive;
    }

    public String getCreatedAt() {
        return this.createdAt;
    }

    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }

    public String getUpdatedAt() {
        return this.updatedAt;
    }

    public void setUpdatedAt(String updatedAt) {
        this.updatedAt = updatedAt;
    }

}
