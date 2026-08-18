package com.soldesk.service;

import java.math.BigDecimal;
import java.util.LinkedHashMap;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

/**
 * 카카오페이 온라인 결제(단건) 연동.
 *
 * 예전 예제에서 많이 보이는 kapi.kakao.com + Admin_Key 방식은 2024-02-01 로 신규 연동이
 * 끊겼다. 지금은 open-api.kakaopay.com + Secret_Key 만 쓸 수 있다.
 *
 * 흐름은 ready → (사용자가 카카오페이 결제창에서 승인) → approve 두 번의 서버 호출이다.
 * 결제창은 브라우저 리다이렉트로 다녀오므로 웹훅이 필요 없고, 그래서 localhost 에서도
 * 그대로 동작한다.
 */
@Service
public class KakaoPayService {

    private static final Logger log = LoggerFactory.getLogger(KakaoPayService.class);

    @Value("${kakaopay.api.base:https://open-api.kakaopay.com}")
    private String apiBase;

    @Value("${kakaopay.cid:TC0ONETIME}")
    private String cid;

    /** payment.properties 가 없거나 비어 있을 수 있으므로 기본값을 빈 문자열로 둔다 */
    @Value("${kakaopay.secret.key:}")
    private String secretKey;

    @Value("${kakaopay.auth.scheme:DEV_SECRET_KEY}")
    private String authScheme;

    // 빈으로 등록된 RestTemplate 이 없어 여기서 직접 만들어 쓴다 (CommonController 의 ObjectMapper 와 같은 방식)
    private final RestTemplate restTemplate = new RestTemplate();

    /** 주문번호는 예약 번호에서 그대로 만들어 낸다. 덕분에 승인 단계에서 세션에 담아둘 것이 없다. */
    public String orderIdOf(int reservationId) {
        return "salu-" + reservationId;
    }

    /**
     * 결제 준비. 성공하면 tid 와 결제창 주소가 담긴 응답을 돌려준다.
     *
     * @return next_redirect_pc_url / tid 가 들어 있는 맵
     */
    public Map<String, Object> ready(int reservationId, int userId, String itemName,
            BigDecimal totalAmount, String approvalUrl, String cancelUrl, String failUrl) {

        Map<String, Object> body = new LinkedHashMap<>();
        body.put("cid", cid);
        body.put("partner_order_id", orderIdOf(reservationId));
        body.put("partner_user_id", String.valueOf(userId));
        body.put("item_name", itemName);
        body.put("quantity", 1);
        body.put("total_amount", totalAmount.intValue());
        body.put("tax_free_amount", 0);
        body.put("approval_url", approvalUrl);
        body.put("cancel_url", cancelUrl);
        body.put("fail_url", failUrl);

        return post("/online/v1/payment/ready", body);
    }

    /**
     * 결제 승인. 이 호출이 성공해야 실제로 돈이 빠져나간다.
     *
     * @param pgToken 결제창이 approval_url 로 되돌아오며 붙여준 일회용 토큰
     * @return amount.total / payment_method_type 등이 들어 있는 승인 응답
     */
    public Map<String, Object> approve(int reservationId, int userId, String tid, String pgToken) {
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("cid", cid);
        body.put("tid", tid);
        body.put("partner_order_id", orderIdOf(reservationId));
        body.put("partner_user_id", String.valueOf(userId));
        body.put("pg_token", pgToken);

        return post("/online/v1/payment/approve", body);
    }

    // 결제취소(환불). 점주가 확정된 예약을 거절할 때 이미 승인된 결제를 되돌리기 위해 부른다. 전액취소만 쓴다.
    public Map<String, Object> cancel(String tid, BigDecimal cancelAmount) {
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("cid", cid);
        body.put("tid", tid);
        body.put("cancel_amount", cancelAmount.intValue());
        body.put("cancel_tax_free_amount", 0);

        return post("/online/v1/payment/cancel", body);
    }

    @SuppressWarnings("unchecked")
    private Map<String, Object> post(String path, Map<String, Object> body) {
        if (secretKey == null || secretKey.isBlank()) {
            throw new IllegalStateException(
                    "카카오페이 결제 키가 설정되지 않았습니다. "
                  + "properties/payment.properties 의 kakaopay.secret.key 를 채워주세요.");
        }

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        // 개발용 키와 운영용 키는 인증 방식 표기가 다르다 (DEV_SECRET_KEY / SECRET_KEY)
        headers.set(HttpHeaders.AUTHORIZATION, authScheme + " " + secretKey);

        try {
            return restTemplate.postForObject(
                    apiBase + path, new HttpEntity<>(body, headers), Map.class);
        } catch (RestClientException e) {
            // 응답 본문에 실패 사유가 들어 있어 남겨두지 않으면 원인을 찾기 어렵다
            log.error("카카오페이 호출 실패 [{}] : {}", path, e.getMessage());
            throw new IllegalStateException("결제 요청을 처리하지 못했습니다. 잠시 후 다시 시도해 주세요.", e);
        }
    }
}
