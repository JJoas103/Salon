package com.soldesk.vo;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import com.soldesk.vo.coupon.CouponOptionVO;

/**
 * 결제 금액 계산 결과.
 *
 * 확인 화면 표시(/checkout/quote)와 실제 청구(/pay)가 이 객체 하나를 공유한다.
 * 두 곳에서 따로 계산하면 화면 금액과 청구 금액이 어긋난다.
 */
public class PriceQuoteVO {

    private int originalAmount;   // 정가 (시술 가격)
    private int couponDiscount;   // 쿠폰 할인 — Step 5 전까지 항상 0
    private int pointUsed;        // 상한으로 잘린 뒤의 실제 사용액
    private int finalAmount;      // = original - coupon - point (PG 에 청구할 금액)
    private int earnPreview;      // 방문 완료 시 적립될 예정 금액

    private int pointBalance;     // 화면에 보여줄 보유 잔액
    private int maxPointUsable;   // [전액 사용] 버튼이 채울 값

    /** finalAmount 가 0 이면 "ZERO" — 외부 결제사를 거치지 않는다 */
    private String pgProvider;

    private List<CouponOptionVO> coupons;

    public List<CouponOptionVO> getCoupons() {
        return this.coupons;
    }

    public void setCoupons(List<CouponOptionVO> coupons) {
        this.coupons = coupons;
    }
    /**
     * 사용자에게 알려줄 안내. 필드명 → 문구.
     * 요청한 적립금이 상한을 넘으면 거절하지 않고 잘라낸 뒤 그 이유를 여기 담는다.
     */
    private Map<String, String> messages = new LinkedHashMap<>();

    public void addMessage(String field, String message) {
        this.messages.put(field, message);
    }

    public int getOriginalAmount() { return originalAmount; }
    public void setOriginalAmount(int originalAmount) { this.originalAmount = originalAmount; }
    public int getCouponDiscount() { return couponDiscount; }
    public void setCouponDiscount(int couponDiscount) { this.couponDiscount = couponDiscount; }
    public int getPointUsed() { return pointUsed; }
    public void setPointUsed(int pointUsed) { this.pointUsed = pointUsed; }
    public int getFinalAmount() { return finalAmount; }
    public void setFinalAmount(int finalAmount) { this.finalAmount = finalAmount; }
    public int getEarnPreview() { return earnPreview; }
    public void setEarnPreview(int earnPreview) { this.earnPreview = earnPreview; }
    public int getPointBalance() { return pointBalance; }
    public void setPointBalance(int pointBalance) { this.pointBalance = pointBalance; }
    public int getMaxPointUsable() { return maxPointUsable; }
    public void setMaxPointUsable(int maxPointUsable) { this.maxPointUsable = maxPointUsable; }
    public String getPgProvider() { return pgProvider; }
    public void setPgProvider(String pgProvider) { this.pgProvider = pgProvider; }
    public Map<String, String> getMessages() { return messages; }
    public void setMessages(Map<String, String> messages) { this.messages = messages; }
}
