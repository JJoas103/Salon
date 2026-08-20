package com.soldesk.vo;

/** AI 상담 답변에 등장한 매장 — 주소 조립은 화면에서 함 */
public class SalonLink {

    private int salonId;
    private String salonName;

    public SalonLink() {
    }

    public int getSalonId() {
        return salonId;
    }
    public void setSalonId(int salonId) {
        this.salonId = salonId;
    }
    public String getSalonName() {
        return salonName;
    }
    public void setSalonName(String salonName) {
        this.salonName = salonName;
    }
}
