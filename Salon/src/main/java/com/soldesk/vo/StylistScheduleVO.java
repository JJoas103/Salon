package com.soldesk.vo;

/**
 * Stylist_Schedules - 스타일리스트 스케줄
 */
public class StylistScheduleVO {

    private int scheduleId; // schedule_id
    private int stylistId; // stylist_id
    private String date;
    private String startTime; // start_time
    private String endTime; // end_time
    private boolean isAvailable; // 예약 가능 여부 (is_available)

    public int getScheduleId() { return scheduleId; }
    public void setScheduleId(int scheduleId) { this.scheduleId = scheduleId; }
    public int getStylistId() { return stylistId; }
    public void setStylistId(int stylistId) { this.stylistId = stylistId; }
    public String getDate() { return date; }
    public void setDate(String date) { this.date = date; }
    public String getStartTime() { return startTime; }
    public void setStartTime(String startTime) { this.startTime = startTime; }
    public String getEndTime() { return endTime; }
    public void setEndTime(String endTime) { this.endTime = endTime; }
    public boolean getIsAvailable() { return isAvailable; }
    public void setIsAvailable(boolean isAvailable) { this.isAvailable = isAvailable; }
}
