package com.soldesk.vo;

/**
 * 고객의 매장별 등급 — Reservations 를 salon_id 로 묶어 완료 건수를 센 결과.
 * grade 는 DB 컬럼이 아니라 ReservationService 가 completedCount 를 보고 계산해 채워 넣는다.
 */
public class SalonGradeVO {

    private int salonId;
    private String salonName;
    private int completedCount;
    private String grade;

    public int getSalonId() { return salonId; }
    public void setSalonId(int salonId) { this.salonId = salonId; }
    public String getSalonName() { return salonName; }
    public void setSalonName(String salonName) { this.salonName = salonName; }
    public int getCompletedCount() { return completedCount; }
    public void setCompletedCount(int completedCount) { this.completedCount = completedCount; }
    public String getGrade() { return grade; }
    public void setGrade(String grade) { this.grade = grade; }
}
