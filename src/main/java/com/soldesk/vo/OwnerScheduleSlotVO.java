package com.soldesk.vo;

// 예약현황판의 한 칸 (특정 시각 × 특정 디자이너)
public class OwnerScheduleSlotVO {

    private ReservationVO reservation; // 이 시각에 시작하는 예약, 없으면 null
    private boolean working; // 그 디자이너가 이 시각에 근무하는지
    private boolean occupied; // 앞 시각에 시작한 시술이 이 칸까지 이어지는지

    public OwnerScheduleSlotVO(boolean working) {
        this.working = working;
    }

    public ReservationVO getReservation() { return reservation; }
    public void setReservation(ReservationVO reservation) { this.reservation = reservation; }
    public boolean isWorking() { return working; }
    public void setWorking(boolean working) { this.working = working; }
    public boolean isOccupied() { return occupied; }
    public void setOccupied(boolean occupied) { this.occupied = occupied; }

    // 근무시간 밖인데 예약이 잡혀 있는 칸. 놓치면 안 되므로 화면에서 따로 표시한다
    public boolean isOutsideHours() {
        return reservation != null && !working;
    }
}
