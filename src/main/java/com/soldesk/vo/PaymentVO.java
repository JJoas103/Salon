package com.soldesk.vo;

/**
 * Payments - 결제
 */
public class PaymentVO {

    private int paymentId; // payment_id
    private int reservationId; // reservation_id
    private int userId; // user_id
    private java.math.BigDecimal amount; // 결제 금액
    private String paymentMethod; // 결제 수단 (payment_method)
    private String paymentStatus; // pending/completed/failed/refunded (payment_status)
    private String transactionId; // transaction_id
    private String paidAt; // 결제 일시 (paid_at)
    private java.math.BigDecimal originalAmount;
    private java.math.BigDecimal couponDiscount;
    private int pointUsed;
    private String pgProvider;
    private Integer userCouponId;


    public int getPaymentId() { return paymentId; }
    public void setPaymentId(int paymentId) { this.paymentId = paymentId; }
    public int getReservationId() { return reservationId; }
    public void setReservationId(int reservationId) { this.reservationId = reservationId; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public java.math.BigDecimal getAmount() { return amount; }
    public void setAmount(java.math.BigDecimal amount) { this.amount = amount; }
    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }
    public String getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }
    public String getTransactionId() { return transactionId; }
    public void setTransactionId(String transactionId) { this.transactionId = transactionId; }
    public String getPaidAt() { return paidAt; }
    public void setPaidAt(String paidAt) { this.paidAt = paidAt; }

    public java.math.BigDecimal getOriginalAmount() {
        return this.originalAmount;
    }

    public void setOriginalAmount(java.math.BigDecimal originalAmount) {
        this.originalAmount = originalAmount;
    }

    public java.math.BigDecimal getCouponDiscount() {
        return this.couponDiscount;
    }

    public void setCouponDiscount(java.math.BigDecimal couponDiscount) {
        this.couponDiscount = couponDiscount;
    }

    public int getPointUsed() {
        return this.pointUsed;
    }

    public void setPointUsed(int pointUsed) {
        this.pointUsed = pointUsed;
    }

    public String getPgProvider() {
        return this.pgProvider;
    }

    public void setPgProvider(String pgProvider) {
        this.pgProvider = pgProvider;
    }

    public Integer getUserCouponId() {
        return this.userCouponId;
    }

    public void setUserCouponId(int userCouponId) {
        this.userCouponId = userCouponId;
    }
    

}
