package com.soldesk.vo;

/**
 * OwnerRequests - 고객 → 점주 승격 요청
 */
public class OwnerRequestVO {

    private int requestId; // request_id
    private int userId; // user_id
    private String salonName; // salon_name
    private String salonPhone; // salon_phone
    private String message; // message
    private String status; // pending/approved/rejected
    private String requestedAt; // requested_at
    private String processedAt; // processed_at
    private Integer processedBy; // processed_by

    public int getRequestId() { return requestId; }
    public void setRequestId(int requestId) { this.requestId = requestId; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public String getSalonName() { return salonName; }
    public void setSalonName(String salonName) { this.salonName = salonName; }
    public String getSalonPhone() { return salonPhone; }
    public void setSalonPhone(String salonPhone) { this.salonPhone = salonPhone; }
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getRequestedAt() { return requestedAt; }
    public void setRequestedAt(String requestedAt) { this.requestedAt = requestedAt; }
    public String getProcessedAt() { return processedAt; }
    public void setProcessedAt(String processedAt) { this.processedAt = processedAt; }
    public Integer getProcessedBy() { return processedBy; }
    public void setProcessedBy(Integer processedBy) { this.processedBy = processedBy; }
}
