package com.soldesk.vo.payment;

public class PaymentApprovalVO {
    int approvedAmount;
    String paymentMethod;

    public int getApprovedAmount() {
        return this.approvedAmount;
    }

    public void setApprovedAmount(int approvedAmount) {
        this.approvedAmount = approvedAmount;
    }

    public String getPaymentMethod() {
        return this.paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

}
