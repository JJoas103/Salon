package com.soldesk.service.payment;

import java.util.Map;

import org.springframework.stereotype.Service;

import com.soldesk.vo.payment.PaymentApprovalVO;
import com.soldesk.vo.payment.PaymentContextVO;
import com.soldesk.vo.payment.PaymentReadyVO;

/**
 * 결제할 금액이 0원일 때 쓰는 게이트웨이.
 *
 * 쿠폰이나 적립금이 정가를 전부 덮으면 최종 금액이 0원이 되는데,
 * 카카오페이 ready 는 total_amount = 0 을 거부한다. 컨트롤러에 if (amount == 0)
 * 분기를 두는 대신 결제사 하나로 취급하면, 승인·확정·실패 처리가
 * 결제사 유무와 무관하게 한 경로로 유지된다.
 */
@Service
public class ZeroAmountGateway implements PaymentGateway {

    @Override
    public String provider() {
        return "ZERO";
    }

    /**
     * 외부 호출 없이 승인 콜백 주소를 그대로 돌려준다.
     * 컨트롤러가 이 주소로 redirect 하면 곧바로 승인 단계로 들어간다.
     */
    @Override
    public PaymentReadyVO ready(PaymentContextVO ctx) {
        PaymentReadyVO ready = new PaymentReadyVO();
        // transaction_id 는 UNIQUE 컬럼이라 예약번호로 겹치지 않게 만든다.
        // 승인 단계의 "결제 정보를 찾을 수 없습니다" 검사도 이 값이 있어야 통과한다.
        ready.setTid("ZERO-" + ctx.getReservationId());
        ready.setRedirectUrl(ctx.getApprovalUrl());
        return ready;
    }

    /** 오갈 돈이 없으므로 승인할 것도 없다. 콜백 파라미터는 보지 않는다. */
    @Override
    public PaymentApprovalVO approve(PaymentContextVO ctx, Map<String, String> callbackParams) {
        PaymentApprovalVO approval = new PaymentApprovalVO();
        approval.setApprovedAmount(0);
        approval.setPaymentMethod("ZERO");
        return approval;
    }
}
