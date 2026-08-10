package com.soldesk.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.soldesk.mapper.SalonMapper;
import com.soldesk.vo.PriceQuoteVO;
import com.soldesk.vo.ServiceVO;
import com.soldesk.vo.coupon.CouponOptionVO;

/**
 * 결제 금액 계산의 유일한 입구.
 *
 * 확인 화면이 금액을 보여줄 때(/checkout/quote)와 실제로 예약을 만들 때(createPendingReservation)가
 * 모두 {@link #quote} 를 부른다. 두 벌로 계산하면 화면에 보인 금액과 청구한 금액이 반드시 어긋난다.
 *
 * 이 클래스는 DB 를 읽기만 하고 아무것도 바꾸지 않는다. 적립금 차감과 쿠폰 점유는
 * 예약을 만드는 트랜잭션 안에서 일어난다.
 */
@Service
public class CheckoutService {

    /** 적립금으로 낼 수 있는 최대 비율. 매출이 통째로 0 이 되는 것을 막는다. */
    private static final double POINT_USE_RATE = 0.5;

    /** 적립금 사용 단위 (원). 100 원 미만은 버린다. */
    private static final int POINT_UNIT = 100;

    /** 이 금액 미만을 보유했으면 적립금을 쓸 수 없다. */
    private static final int POINT_MIN_BALANCE = 1000;

    /** 적립률. 실제로 현금이 오간 금액에만 적용한다. */
    private static final double EARN_RATE = 0.05;

    @Autowired
    private SalonMapper salonMapper;

    @Autowired
    private PointService pointService;

    @Autowired
    private CouponService couponService;

    /**
     * 금액을 계산한다. 부수효과 없음.
     *
     * 요청한 적립금이 상한을 넘으면 거절하지 않고 <b>잘라낸다.</b> 화면과 청구가 같은 함수를
     * 쓰므로 잘라낸 결과도 양쪽이 똑같이 보게 되고, 사용자는 실패 화면 대신 조정된 금액을 본다.
     *
     * @param userCouponId 쓰지 않으면 null (Step 5 에서 실제로 쓰인다)
     * @param pointToUse   사용자가 입력한 적립금. 음수나 상한 초과는 여기서 정리된다.
     */
    @Transactional(readOnly = true)
    public PriceQuoteVO quote(int userId, int serviceId, Integer userCouponId, int pointToUse) {

        PriceQuoteVO quote = new PriceQuoteVO();

        // 1) 정가 — 화면이 보낸 금액이 아니라 DB 의 가격을 읽는다
        ServiceVO service = salonMapper.findServiceById(serviceId);
        if (service == null) {
            throw new IllegalArgumentException("시술 정보를 찾을 수 없습니다.");
        }
        int originalAmount = service.getPrice().intValue();
        quote.setOriginalAmount(originalAmount);

        // 2) 쿠폰 할인 — Step 5 에서 채운다.
        //    적립금보다 먼저 빼는 순서는 바뀌면 안 된다. 적립금을 먼저 빼면 %할인의
        //    대상 금액이 줄어 사용자가 손해를 본다.
        List<CouponOptionVO> options = couponService.evaluate(
            userId, originalAmount, service.getSalonId(), serviceId
        );
        quote.setCoupons(options);

        int couponDiscount = 0;
        if(userCouponId != null) {
            CouponOptionVO picked = options.stream()
                            .filter(o -> o.getUserCouponId() == userCouponId)
                            .findFirst().orElse(null);
            if(picked == null || !picked.isUsable()) {
                quote.addMessage("coupon", "선택한 쿠폰을 사용할 수 없습니다");
            } else {
                couponDiscount = picked.getDiscountAmount();
            }
        }
        quote.setCouponDiscount(couponDiscount);
        int afterCoupon = originalAmount - couponDiscount;

        // 3) 적립금
        int balance = pointService.getBalance(userId);
        quote.setPointBalance(balance);

        int maxUsable = maxPointUsable(afterCoupon, balance);
        quote.setMaxPointUsable(maxUsable);

        int pointUsed = clampPoint(pointToUse, maxUsable, balance, quote);
        quote.setPointUsed(pointUsed);

        // 4) 최종 금액과 적립 예정액
        int finalAmount = afterCoupon - pointUsed;
        quote.setFinalAmount(finalAmount);

        // 적립금으로 낸 부분은 적립에서 뺀다. 그러지 않으면 적립금이 스스로를 불린다.
        quote.setEarnPreview((int) Math.floor(finalAmount * EARN_RATE));

        // 5) 결제사 — 0 원이면 외부 결제사를 거치지 않는다
        quote.setPgProvider(finalAmount == 0 ? "ZERO" : "KAKAOPAY");

        return quote;
    }

    /** 이번 결제에 쓸 수 있는 적립금 상한 (보유액과 비율 상한 중 작은 쪽, 100원 단위) */
    private int maxPointUsable(int afterCoupon, int balance) {
        if (balance < POINT_MIN_BALANCE) {
            return 0;
        }
        int byRate = (int) Math.floor(afterCoupon * POINT_USE_RATE);
        int usable = Math.min(byRate, balance);
        return usable / POINT_UNIT * POINT_UNIT;
    }

    /** 입력값을 사용 가능한 범위로 다듬고, 깎였다면 왜 깎였는지 남긴다. */
    private int clampPoint(int requested, int maxUsable, int balance, PriceQuoteVO quote) {
        if (requested <= 0) {
            return 0;
        }
        if (balance < POINT_MIN_BALANCE) {
            quote.addMessage("point",
                    String.format("적립금은 %,d원 이상 보유했을 때 사용할 수 있습니다.", POINT_MIN_BALANCE));
            return 0;
        }

        int used = requested / POINT_UNIT * POINT_UNIT;
        if (used != requested) {
            quote.addMessage("point", String.format("적립금은 %d원 단위로 사용할 수 있습니다.", POINT_UNIT));
        }
        if (used > maxUsable) {
            used = maxUsable;
            quote.addMessage("point", String.format("이번 결제에는 최대 %,d원까지 사용할 수 있습니다.", maxUsable));
        }
        return used;
    }
}
