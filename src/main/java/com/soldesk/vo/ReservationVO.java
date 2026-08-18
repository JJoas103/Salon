package com.soldesk.vo;

/**
 * Reservations - 예약
 */
public class ReservationVO {

    private int reservationId; // reservation_id
    private int userId; // user_id
    private int salonId; // salon_id
    private int stylistId; // stylist_id
    private int serviceId; // service_id
    private String reservationTime; // 예약 일시 (reservation_time)
    private String status; // pending/confirmed/completed/cancelled
    private String rejectReason; // 점주 취소 사유 (reject_reason)
    private String cancelType; // 취소 유형 (cancel_type): rejected=거절+환불 / no_show=노쇼+환불없음
    private String createdAt; // created_at
    private String updatedAt; // updated_at

    // ===== 조인 결과 (salons / payments / users / stylists) =====
    private String salonName; // 매장명 (salons.name)
    private String transactionId; // 주문번호 (payments.transaction_id)
    private String paymentMethod; // 결제수단 (payments.payment_method)
    private int amount; // 결제금액 (payments.amount)
    private String serviceName; // 시술명(service.name)
    private int originalAmount;
    private int couponDiscount;
    private int pointUsed;
    private String pgProvider;

    private String customerName; // 예약 고객명 (users.user_name)
    private String customerPhone; // 예약 고객 연락처, 거절 시 연락용 (users.phone_number)
    private String stylistName; // 담당 디자이너명 (stylists.stylist_name)
    private int durationMinutes; // 시술 소요시간 (services.duration_minutes)

    // ===== 서비스가 계산해 넣는 값 (DB 컬럼 아님) =====
    private String displayStatus; // 화면용 상태: 결제중/결제 미완료/예약됨/진행중/완료/거절됨/취소됨
    private boolean rejectable; // 거절 가능 여부 (확정 + 아직 시술 전)
    private String endTime; // 시술 종료 예정 'HH:mm'

    public int getOriginalAmount() {
        return this.originalAmount;
    }

    public void setOriginalAmount(int originalAmount) {
        this.originalAmount = originalAmount;
    }

    public int getCouponDiscount() {
        return this.couponDiscount;
    }

    public void setCouponDiscount(int couponDiscount) {
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

    public String getServiceName() {
        return this.serviceName;
    }

    public void setServiceName(String serviceName) {
        this.serviceName = serviceName;
    }

    public int getReservationId() {
        return reservationId;
    }

    public void setReservationId(int reservationId) {
        this.reservationId = reservationId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public int getSalonId() {
        return salonId;
    }

    public void setSalonId(int salonId) {
        this.salonId = salonId;
    }

    public int getStylistId() {
        return stylistId;
    }

    public void setStylistId(int stylistId) {
        this.stylistId = stylistId;
    }

    public int getServiceId() {
        return serviceId;
    }

    public void setServiceId(int serviceId) {
        this.serviceId = serviceId;
    }

    public String getReservationTime() {
        return reservationTime;
    }

    public void setReservationTime(String reservationTime) {
        this.reservationTime = reservationTime;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }

    public String getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(String updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getSalonName() {
        return salonName;
    }

    public void setSalonName(String name) {
        this.salonName = name;
    }

    public String getTransactionId() {
        return transactionId;
    }

    public void setTransactionId(String transactionId) {
        this.transactionId = transactionId;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public int getAmount() {
        return amount;
    }

    public void setAmount(int amount) {
        this.amount = amount;
    }

    public String getRejectReason() {
        return rejectReason;
    }

    public void setRejectReason(String rejectReason) {
        this.rejectReason = rejectReason;
    }

    public String getCancelType() {
        return cancelType;
    }

    public void setCancelType(String cancelType) {
        this.cancelType = cancelType;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public String getCustomerPhone() {
        return customerPhone;
    }

    public void setCustomerPhone(String customerPhone) {
        this.customerPhone = customerPhone;
    }

    public String getStylistName() {
        return stylistName;
    }

    public void setStylistName(String stylistName) {
        this.stylistName = stylistName;
    }

    public int getDurationMinutes() {
        return durationMinutes;
    }

    public void setDurationMinutes(int durationMinutes) {
        this.durationMinutes = durationMinutes;
    }

    public String getDisplayStatus() {
        return displayStatus;
    }

    public void setDisplayStatus(String displayStatus) {
        this.displayStatus = displayStatus;
    }

    public boolean isRejectable() {
        return rejectable;
    }

    public void setRejectable(boolean rejectable) {
        this.rejectable = rejectable;
    }

    public String getEndTime() {
        return endTime;
    }

    public void setEndTime(String endTime) {
        this.endTime = endTime;
    }
}
