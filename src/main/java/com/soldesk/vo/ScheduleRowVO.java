package com.soldesk.vo;

import java.util.List;

// 예약현황판의 한 줄 (시각 하나). cells 는 현황판의 디자이너 목록과 같은 순서
public class ScheduleRowVO {

    private String time; // 'HH:mm'
    private boolean past; // 이미 지난 시각
    private boolean current; // 지금 이 시간대 (오늘만 true)
    private List<OwnerScheduleSlotVO> cells;

    public String getTime() { return time; }
    public void setTime(String time) { this.time = time; }
    public boolean isPast() { return past; }
    public void setPast(boolean past) { this.past = past; }
    public boolean isCurrent() { return current; }
    public void setCurrent(boolean current) { this.current = current; }
    public List<OwnerScheduleSlotVO> getCells() { return cells; }
    public void setCells(List<OwnerScheduleSlotVO> cells) { this.cells = cells; }
}
