package com.soldesk.service;

import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.soldesk.mapper.CouponMapper;
import com.soldesk.vo.coupon.CouponOptionVO;
import com.soldesk.vo.coupon.CouponVO;
import com.soldesk.vo.coupon.UserCouponVO;

@Service
public class CouponService {
    
    @Autowired
    private CouponMapper couponMapper;

    @Autowired
    private NotificationService notificationService;

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

    // ===================== 관리자 =====================

    /** 정책 목록 (발급/사용 집계 포함) */
    @Transactional(readOnly = true)
    public List<CouponVO> getAllCoupons(){
        return couponMapper.findAllCoupons();
    }

    /** 정책 등록 */
    @Transactional
    public void createCoupon(CouponVO coupon){
        couponMapper.insertCoupon(coupon);
    }

    /** 활성/중지 전환. 삭제 대신 이걸 쓴다 — 이미 발급된 쿠폰이 정책을 FK 로 참조한다. */
    @Transactional
    public void toggleActive(int couponId){
        couponMapper.toggleActive(couponId);
    }

    /**
     * 관리자 지정 발급.
     *
     * issueCoupon 은 발급 못 한 이유를 알려주지 않고 0 만 돌려준다. 관리자에게 "실패" 라고만
     * 하면 원인을 알 수 없으므로, 여기서 보유 여부를 한 번 더 확인해 사유를 갈라 던진다.
     *
     * @throws IllegalArgumentException 회원이 없거나, 이미 보유했거나, 발급할 수 없는 정책일 때
     */
    @Transactional
    public void issueTo(int userId, int couponId){
        if (couponMapper.issueCoupon(userId, couponId) == 1) {
            CouponVO coupon = couponMapper.findCouponById(couponId);
            notificationService.create(
                    userId, "COUPON", "쿠폰이 발급되었습니다",
                    coupon.getCouponName(), "/common/mypage", couponId);
            return;
        }
        if (couponMapper.countOwnedByUser(userId, couponId) > 0) {
            throw new IllegalArgumentException("이미 보유한 쿠폰입니다. (1인 1매 쿠폰)");
        }
        throw new IllegalArgumentException("발급할 수 없는 쿠폰입니다. 중지되었거나 유효기간이 지났습니다.");
    }

    // ===================== 조회 =====================

    /** 마이페이지 "보유 활성 쿠폰" 개수. 만료분은 조회 조건에서 빠진다. */
    @Transactional(readOnly = true)
    public int countAvailable(int userId){
        return couponMapper.countAvailable(userId);
    }

    /** 쿠폰함 — 사용·만료분까지 전부 (쓸 수 있는 것이 위로 온다) */
    @Transactional(readOnly = true)
    public List<UserCouponVO> getMyCoupons(int userId){
        return couponMapper.findAllByUserId(userId);
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

    @Transactional
    public void issueByType(int userId, String issueType){
        for(CouponVO coupon : couponMapper.findByIssueType(issueType)){
            if (couponMapper.issueCoupon(userId, coupon.getCouponId()) == 1) {
                notificationService.create(
                        userId, "COUPON", "쿠폰이 발급되었습니다",
                        coupon.getCouponName(), "/common/mypage", coupon.getCouponId());
            }
        }
    }
}
