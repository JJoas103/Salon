package com.soldesk.service.payment;

import java.math.BigDecimal;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.soldesk.service.KakaoPayService;
import com.soldesk.vo.payment.PaymentApprovalVO;
import com.soldesk.vo.payment.PaymentContextVO;
import com.soldesk.vo.payment.PaymentReadyVO;

/**
 * 카카오페이 게이트웨이.
 *
 * HTTP 호출 자체는 기존 {@link KakaoPayService} 가 그대로 담당하고,
 * 이 클래스는 그 입출력을 공통 인터페이스 모양으로 바꿔 끼우기만 한다.
 */
@Service
public class KakaoPayGateway implements PaymentGateway {

    @Autowired
    private KakaoPayService kakaoPayService;

    @Override
    public String provider() {
        return "KAKAOPAY";
    }

    @Override
    public PaymentReadyVO ready(PaymentContextVO ctx) {
        Map<String, Object> response = kakaoPayService.ready(
                ctx.getReservationId(),
                ctx.getUserId(),
                ctx.getItemName(),
                BigDecimal.valueOf(ctx.getAmount()),
                ctx.getApprovalUrl(),
                ctx.getCancelUrl(),
                ctx.getFailUrl());

        PaymentReadyVO ready = new PaymentReadyVO();
        ready.setTid((String) response.get("tid"));
        ready.setRedirectUrl((String) response.get("next_redirect_pc_url"));
        return ready;
    }

    @Override
    public PaymentApprovalVO approve(PaymentContextVO ctx, Map<String, String> callbackParams) {
        // 카카오페이는 approval_url 로 되돌아오며 pg_token 을 붙여준다.
        // 이 이름이 결제사마다 달라서 인터페이스가 파라미터 맵 전체를 받는다.
        String pgToken = callbackParams.get("pg_token");

        Map<String, Object> response = kakaoPayService.approve(
                ctx.getReservationId(), ctx.getUserId(), ctx.getTid(), pgToken);

        @SuppressWarnings("unchecked")
        Map<String, Object> amount = (Map<String, Object>) response.get("amount");

        PaymentApprovalVO approval = new PaymentApprovalVO();
        approval.setApprovedAmount(((Number) amount.get("total")).intValue());
        // 승인 응답이 알려주는 실제 수단(CARD/MONEY). 결제사 이름(pg_provider)과는 다르다.
        approval.setPaymentMethod((String) response.get("payment_method_type"));
        return approval;
    }
}
