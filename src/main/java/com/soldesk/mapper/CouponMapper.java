package com.soldesk.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.soldesk.vo.coupon.CouponVO;
import com.soldesk.vo.coupon.UserCouponVO;

public interface CouponMapper {

    // ===================== 사용 =====================

    /**
     * 지금 쓸 수 있는 쿠폰 + 그 정책.
     * quote() 가 이 목록을 받아 예약별로 사용 가부와 할인액을 판정한다.
     * 만료분은 상태를 바꾸지 않고 조회 조건으로 거른다 — 쿠폰은 자리 같은 자원을 점유하지 않는다.
     */
    List<UserCouponVO> findUsableByUserId(int userId);

    /**
     * 결제 시작 — available → reserved.
     * user_id 조건이 없으면 URL 로 남의 쿠폰 번호를 넣어 쓸 수 있다.
     *
     * @return 0 이면 이미 쓰였거나, 기한이 지났거나, 남의 쿠폰
     */
    int reserveCoupon(@Param("userCouponId") int userCouponId,
                      @Param("userId") int userId,
                      @Param("reservationId") int reservationId);

    /**
     * 승인 성공 — reserved → used.
     * 예약번호로 찾는다. confirmPayment() 는 어느 쿠폰이었는지 모르고 예약번호만 안다.
     */
    int confirmCoupon(int reservationId);

    /** 결제 실패·이탈 — reserved → available (결제창에 머무는 사이 기한이 지났으면 expired) */
    int releaseCoupon(int reservationId);

    /**
     * 환불 — used → available.
     * 결제가 확정된 뒤 되돌리는 경우라 releaseCoupon 과 시작 상태가 다르다.
     * 점주 거절 환불, 그리고 앞으로 생길 고객 취소가 이 경로를 쓴다.
     */
    int refundCoupon(int reservationId);

    /** 마이페이지 "보유 활성 쿠폰 N개" */
    int countAvailable(int userId);

    /** 마이페이지 쿠폰함 — 사용·만료분까지 전부 */
    List<UserCouponVO> findAllByUserId(int userId);

    // ===================== 발행 =====================

    /**
     * 쿠폰 1장 발급.
     * once_per_user 가 켜진 정책은 이미 가진 사람에게 다시 나가지 않는다.
     * 판정을 INSERT 문 안에 넣었으므로 반환값만 보면 된다.
     *
     * @return 0 이면 발급 안 됨 (이미 보유 / 비활성 / 기간 밖)
     */
    int issueCoupon(@Param("userId") int userId, @Param("couponId") int couponId);

    /** 발급 경로별 정책 목록. 회원가입 시 issueType='signup' 을 전부 발급한다. */
    List<CouponVO> findByIssueType(String issueType);

    // ---- 관리자 ----

    List<CouponVO> findAllCoupons();

    CouponVO findCouponById(int couponId);

    void insertCoupon(CouponVO coupon);

    int toggleActive(int couponId);
}
