package com.soldesk.vo.coupon;

public class CouponOptionVO {
    private int userCouponId;
    private String couponName;
    private int discountAmount;
    private boolean usable;
    private String reason;


    public int getUserCouponId() {
        return this.userCouponId;
    }

    public void setUserCouponId(int userCouponId) {
        this.userCouponId = userCouponId;
    }

    public String getCouponName() {
        return this.couponName;
    }

    public void setCouponName(String couponName) {
        this.couponName = couponName;
    }

    public int getDiscountAmount() {
        return this.discountAmount;
    }

    public void setDiscountAmount(int discountAmount) {
        this.discountAmount = discountAmount;
    }

    public boolean isUsable() {
        return this.usable;
    }

    public boolean getUsable() {
        return this.usable;
    }

    public void setUsable(boolean usable) {
        this.usable = usable;
    }

    public String getReason() {
        return this.reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

}
