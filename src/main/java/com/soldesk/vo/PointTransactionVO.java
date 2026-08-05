package com.soldesk.vo;

public class PointTransactionVO {
    private int pointTxId;
    private int userId;
    private Integer reservationId;   // 관리자 조정은 예약과 무관해서 NULL 이 들어간다
    private String txType;
    private int amount;
    private int balanceAfter;
    private String description;
    private String expiresAt;
    private String createdAt;

    public int getPointTxId() {
        return this.pointTxId;
    }

    public void setPointTxId(int pointTxId) {
        this.pointTxId = pointTxId;
    }

    public int getUserId() {
        return this.userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public Integer getReservationId() {
        return this.reservationId;
    }

    public void setReservationId(Integer reservationId) {
        this.reservationId = reservationId;
    }

    public String getTxType() {
        return this.txType;
    }

    public void setTxType(String txType) {
        this.txType = txType;
    }

    public int getAmount() {
        return this.amount;
    }

    public void setAmount(int amount) {
        this.amount = amount;
    }

    public int getBalanceAfter() {
        return this.balanceAfter;
    }

    public void setBalanceAfter(int balanceAfter) {
        this.balanceAfter = balanceAfter;
    }

    public String getDescription() {
        return this.description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getExpiresAt() {
        return this.expiresAt;
    }

    public void setExpiresAt(String expiresAt) {
        this.expiresAt = expiresAt;
    }

    public String getCreatedAt() {
        return this.createdAt;
    }

    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }

}
