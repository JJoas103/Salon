package com.soldesk.service.payment;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

/**
 * 결제사 이름으로 게이트웨이를 찾아 준다.
 *
 * Spring 이 PaymentGateway 를 구현한 빈을 전부 모아 List 로 넣어주므로,
 * 결제사를 추가할 때 이 클래스도 컨트롤러도 고칠 필요가 없다.
 * 새 구현체에 @Service 를 붙이는 것만으로 목록에 들어온다.
 */
@Component
public class PaymentGatewayResolver {

    private final Map<String, PaymentGateway> byProvider;

    @Autowired
    public PaymentGatewayResolver(List<PaymentGateway> gateways) {
        this.byProvider = gateways.stream()
                .collect(Collectors.toMap(PaymentGateway::provider, gateway -> gateway));
    }

    /**
     * @param provider Payments.pg_provider 에 저장해 둔 결제사 이름
     * @throws IllegalArgumentException 등록되지 않은 이름일 때.
     *         provider 는 콜백 URL 로 들어오므로 조작될 수 있다. 여기서 걸러낸다.
     */
    public PaymentGateway resolve(String provider) {
        PaymentGateway gateway = byProvider.get(provider);
        if (gateway == null) {
            throw new IllegalArgumentException("지원하지 않는 결제수단입니다.");
        }
        return gateway;
    }
}
