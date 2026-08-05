package com.soldesk.vo;

import java.util.List;

// 하루치 예약현황판. 세로축이 시각, 가로축이 디자이너다
public class ScheduleBoardVO {

    private List<StylistVO> stylists; // 표의 열 순서
    private List<ScheduleRowVO> rows;
    private int bookedCount; // 그 날 잡힌 예약 건수

    public List<StylistVO> getStylists() { return stylists; }
    public void setStylists(List<StylistVO> stylists) { this.stylists = stylists; }
    public List<ScheduleRowVO> getRows() { return rows; }
    public void setRows(List<ScheduleRowVO> rows) { this.rows = rows; }
    public int getBookedCount() { return bookedCount; }
    public void setBookedCount(int bookedCount) { this.bookedCount = bookedCount; }
}
