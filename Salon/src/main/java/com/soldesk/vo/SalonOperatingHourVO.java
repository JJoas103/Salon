package com.soldesk.vo;

/**
 * Salon_Operating_Hours - 미용실 영업시간
 */
public class SalonOperatingHourVO {

    private int hourId; // hour_id
    private int salonId; // salon_id
    private String dayOfWeek; // 요일: 월~일 (day_of_week)
    private String openTime; // open_time
    private String closeTime; // close_time

    public int getHourId() { return hourId; }
    public void setHourId(int hourId) { this.hourId = hourId; }
    public int getSalonId() { return salonId; }
    public void setSalonId(int salonId) { this.salonId = salonId; }
    public String getDayOfWeek() { return dayOfWeek; }
    public void setDayOfWeek(String dayOfWeek) { this.dayOfWeek = dayOfWeek; }
    public String getOpenTime() { return openTime; }
    public void setOpenTime(String openTime) { this.openTime = openTime; }
    public String getCloseTime() { return closeTime; }
    public void setCloseTime(String closeTime) { this.closeTime = closeTime; }
}
