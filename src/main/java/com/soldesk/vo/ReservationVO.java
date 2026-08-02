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
    private String createdAt; // created_at
    private String updatedAt; // updated_at

    // ===== 조인 결과 (salons / payments) =====
    private String salonName; // 매장명 (salons.name)
    private String transactionId; // 주문번호 (payments.transaction_id)
    private String paymentMethod; // 결제수단 (payments.payment_method)
    private int amount; // 결제금액 (payments.amount)
    private String serviceName; // 시술명(service.name)

    public String getServiceName() {
        return this.serviceName;
    }

    public void setServiceName(String serviceName) {
        this.serviceName = serviceName;
    }

    public int getReservationId() { return reservationId; }
    public void setReservationId(int reservationId) { this.reservationId = reservationId; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public int getSalonId() { return salonId; }
    public void setSalonId(int salonId) { this.salonId = salonId; }
    public int getStylistId() { return stylistId; }
    public void setStylistId(int stylistId) { this.stylistId = stylistId; }
    public int getServiceId() { return serviceId; }
    public void setServiceId(int serviceId) { this.serviceId = serviceId; }
    public String getReservationTime() { return reservationTime; }
    public void setReservationTime(String reservationTime) { this.reservationTime = reservationTime; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
    public String getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(String updatedAt) { this.updatedAt = updatedAt; }
    public String getSalonName() { return salonName; }
    public void setSalonName(String name) { this.salonName = name; }
    public String getTransactionId() { return transactionId; }
    public void setTransactionId(String transactionId) { this.transactionId = transactionId; }
    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }
    public int getAmount() { return amount; }
    public void setAmount(int amount) { this.amount = amount; }
}
