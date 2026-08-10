package com.soldesk.service;

import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.soldesk.mapper.CouponMapper;
import com.soldesk.vo.coupon.CouponOptionVO;
import com.soldesk.vo.coupon.UserCouponVO;

@Service
public class CouponService {
    
    @Autowired
    private CouponMapper couponMapper;

    @Transactional
    public void reserve(int userCouponId, int userId, int reservationId){
        if(couponMapper.reserveCoupon(userCouponId, userId, reservationId) == 0){
            throw new IllegalArgumentException("사용할 수 없는 쿠폰입니다.");
        }
        
    }
    
    @Transactional
    public void confirm(int reservationid){
        couponMapper.confirmCoupon(reservationid);
    }
    
    /** 결제 실패·이탈 — 아직 확정되지 않은(reserved) 쿠폰을 되돌린다 */
    @Transactional
    public void release(int reservationId) {
        couponMapper.releaseCoupon(reservationId);
    }

    /**
     * 환불 — 이미 사용 처리된(used) 쿠폰을 되돌린다.
     * release() 로는 안 된다. 그쪽은 reserved 만 보므로 확정된 쿠폰에는 0행이 된다.
     */
    @Transactional
    public void refund(int reservationId) {
        couponMapper.refundCoupon(reservationId);
    }

    @Transactional(readOnly = true)
    public List<CouponOptionVO> evaluate(int userId, int originalAmount, int salonId, int serviceId){
        List<CouponOptionVO> options = new ArrayList<>();

        for(UserCouponVO coupon : couponMapper.findUsableByUserId(userId)){
            CouponOptionVO option = new CouponOptionVO();
            option.setUserCouponId(coupon.getUserCouponId());
            option.setCouponName(coupon.getCouponName());

            String reason = reasonUnusable(coupon, originalAmount, salonId, serviceId);
            option.setUsable(reason == null);
            option.setReason(reason);
            option.setDiscountAmount(reason == null ? discountOf(coupon, originalAmount) : 0);

            options.add(option);
        }

        return options;
    }

    //할인 계산
    private int discountOf(UserCouponVO coupon, int originalAmount) {
        int discount;
        if("percent".equals(coupon.getDiscountType())) {
            discount = (int) Math.floor(originalAmount * coupon.getDiscountValue().doubleValue() / 100);
            if(coupon.getMaxDiscount() != null){
                discount = Math.min(discount, coupon.getMaxDiscount().intValue());
            }
        } else {
            discount = coupon.getDiscountValue().intValue();
        }

        return Math.min(discount, originalAmount);
    }

    //사용 불가 사유
    private String reasonUnusable(UserCouponVO coupon, int originalAmount, int salonId, int serviceId){
        if(coupon.getCouponSalonId() != null && coupon.getCouponSalonId() != salonId){
            return "다른 매장 전용 쿠폰입니다.";
        }
        if(coupon.getCouponServiceId() != null && coupon.getCouponServiceId() != serviceId){
            return "다른 시술 전용 쿠폰입니다.";
        }
        if(originalAmount < coupon.getMinOrderAmount().intValue()){
            return String.format("최소 결제 금액 %d원부터 사용할 수 있습니다.",
                                        coupon.getMinOrderAmount().intValue());
        }
        return null; //사용 가능
    }
}
