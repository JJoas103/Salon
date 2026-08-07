package com.soldesk.mapper;

import org.apache.ibatis.annotations.Param;

import com.soldesk.vo.PaymentVO;

public interface PaymentMapper {

    /** 결제창으로 보내기 전에 pending 상태로 먼저 만들어 둔다 (예약 1건당 1행) */
    int insertPayment(PaymentVO payment);

    PaymentVO findByReservationId(int reservationId);

    /** ready 응답으로 받은 tid 를 붙여둔다. 승인 단계에서 이 값이 필요하다. */
    void updateTransactionId(@Param("reservationId") int reservationId,
                             @Param("transactionId") String transactionId);

    /** 승인 성공 — 결제수단(카드/머니)은 승인 응답을 보고서야 알 수 있다 */
    int markCompleted(@Param("reservationId") int reservationId,
                       @Param("paymentMethod") String paymentMethod);

    int markFailed(int reservationId);
    
    /** 점주 거절로 인한 환불 처리 — 완료된 결제만 환불 대상이다 */
    void markRefunded(int reservationId);
}
