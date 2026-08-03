package com.soldesk.vo;

/**
 * 예약 화면의 시간 한 칸. DB 테이블이 아니라 서버가 계산해서 만들어 내려주는 값이다.
 *
 * 마감된 시간도 available=false 로 함께 내려준다. 목록에서 빼버리면 화면이 듬성듬성해져
 * "원래 없는 시간"인지 "이미 찬 시간"인지 구분되지 않기 때문이다.
 */
public class TimeSlotVO {

    private String time; // 'HH:mm'
    private boolean available; // 예약 가능 여부

    public TimeSlotVO() {
    }

    public TimeSlotVO(String time, boolean available) {
        this.time = time;
        this.available = available;
    }

    public String getTime() { return time; }
    public void setTime(String time) { this.time = time; }
    public boolean isAvailable() { return available; }
    public void setAvailable(boolean available) { this.available = available; }
}
