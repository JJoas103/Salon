package com.soldesk.service.payment;

import java.util.Map;

import com.soldesk.vo.payment.PaymentApprovalVO;
import com.soldesk.vo.payment.PaymentContextVO;
import com.soldesk.vo.payment.PaymentReadyVO;

public interface PaymentGateway {
    String provider();
    PaymentReadyVO ready(PaymentContextVO ctx);
    PaymentApprovalVO approve(PaymentContextVO ctx, Map<String, String> callbackParams);
}
