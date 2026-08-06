package com.soldesk.controller;

import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.soldesk.service.CheckoutService;
import com.soldesk.service.ReservationService;
import com.soldesk.service.SalonService;
import com.soldesk.service.StylistService;
import com.soldesk.service.UserService;
import com.soldesk.service.WishlistService;
import com.soldesk.service.payment.PaymentGatewayResolver;
import com.soldesk.vo.payment.PaymentApprovalVO;
import com.soldesk.vo.payment.PaymentContextVO;
import com.soldesk.vo.payment.PaymentReadyVO;
import com.soldesk.vo.PaymentVO;
import com.soldesk.vo.PriceQuoteVO;
import com.soldesk.vo.ReservationVO;
// import com.soldesk.vo.SalonVO;
import com.soldesk.vo.ServiceVO;
// import com.soldesk.vo.StylistVO;
import com.soldesk.vo.TimeSlotVO;
import com.soldesk.vo.UserVO;

@Controller
@RequestMapping("/common/reserve")
public class ReserveController {

    private final Logger log = LoggerFactory.getLogger(ReserveController.class);

    @Autowired
    private SalonService salonService;

    @Autowired
    private UserService userService;

    @Autowired
    private WishlistService wishlistService;

    @Autowired
    private StylistService stylistService;

    @Autowired
    private ReservationService reservationService;

    @Autowired
    private PaymentGatewayResolver paymentGatewayResolver;

    @Autowired
    private CheckoutService checkoutService;

    // 미용실 검색하기
    @GetMapping
    public String search(@RequestParam(required = false) Integer salonId,
            Authentication authentication, Model model) {
        if (salonId == null) {
            // 모든 미용실정보 가져오기
            java.util.List<com.soldesk.vo.SalonVO> salons = salonService.getSalons();
            if (salons.isEmpty()) {
                model.addAttribute("salonNotFound", true);
                return "common/reserve";
            }
            salonId = salons.get(0).getSalonId();
        }
        // id로 미용실 정보 가져오기
        com.soldesk.vo.SalonVO salon = salonService.getSalon(salonId);
        if (salon == null) {
            model.addAttribute("salonNotFound", true);
            return "common/reserve";
        }

        model.addAttribute("salon", salon);
        UserVO user = userService.getUser(authentication.getName());
        model.addAttribute("wishlisted", wishlistService.isWishlisted(user.getUserId(), salonId));
        // 시술정보 가져오기
        model.addAttribute("services", salonService.getServices(salonId));
        model.addAttribute("stylists", stylistService.findBySalonId(salonId));
        return "common/reserve";
    }

    /**
     * 예약 화면 3단계가 날짜를 고를 때마다 부르는 시간대 목록.
     * 뷰가 아니라 JSON 을 돌려주므로 @ResponseBody 를 붙인다.
     *
     * 매장은 파라미터로 받지 않고 디자이너에서 거슬러 올라가 찾는다.
     * 클라이언트가 보낸 salonId 를 믿으면 남의 매장 영업시간으로 시간대를 만들 수 있다.
     */
    @GetMapping("/slots")
    @ResponseBody
    public List<TimeSlotVO> reserveSlots(@RequestParam int stylistId,
            @RequestParam String date) {
        return reservationService.getAvailableSlots(stylistId, date);
    }

    /**
     * 예약 화면 3단계 캘린더가 디자이너를 고른 직후 한 번 부르는 엔드포인트.
     * 그 디자이너가 예약 가능으로 등록한 날짜 목록만 돌려주고, 캘린더는 이 목록에 없는
     * 날짜를 회색으로 비활성화한다 — 영업시간 등 매장 쪽 예약 로직과는 무관하게 스케줄만 본다.
     */
    @GetMapping("/stylist-schedule")
    @ResponseBody
    public List<String> reserveStylistSchedule(@RequestParam int stylistId) {
        return stylistService.getAvailableDates(stylistId);
    }

    /**
     * 결제하기 → 결제창으로 보내는 단계.
     * 예약을 pending 으로 세운 뒤 결제사가 알려준 주소로 리다이렉트한다.
     *
     * 어느 결제사를 쓰는지는 화면이 아니라 서비스가 금액을 보고 정한다.
     * 여기서는 그 결정을 읽어 게이트웨이를 찾아 쓸 뿐이라, 결제사가 늘어도 이 메서드는 그대로다.
     */
    @PostMapping
    public String reserveSubmit(@RequestParam int salonId,
            @RequestParam int serviceId,
            @RequestParam int stylistId,
            @RequestParam String reservationTime,
            @RequestParam(required = false) Integer userCouponId,
            @RequestParam(defaultValue = "0") int pointToUse,
            Authentication authentication,
            HttpServletRequest request,
            Model model) {

        UserVO user = userService.getUser(authentication.getName());
        ReservationVO reservation;
        try {
            // 금액은 넘기지 않는다. 서비스가 quote() 로 다시 계산한다.
            reservation = reservationService.createPendingReservation(
                    user.getUserId(), salonId, stylistId, serviceId, reservationTime,
                    userCouponId, pointToUse);
        } catch (IllegalArgumentException e) {
            // 자리를 뺏겼거나 값이 어긋난 경우 — 예약이 만들어지지 않았으므로 되돌릴 것이 없다
            return reserveFailView(model, salonId, e.getMessage());
        }

        int reservationId = reservation.getReservationId();
        String provider = reservation.getPgProvider();
        // 콜백 주소에 결제사를 넣어 두어야 돌아왔을 때 누구에게 승인을 물을지 알 수 있다
        String callbackBase = baseUrlOf(request) + "/common/reserve/payment/" + provider;

        PaymentContextVO ctx = new PaymentContextVO();
        ctx.setReservationId(reservationId);
        ctx.setUserId(user.getUserId());
        ctx.setItemName(reservation.getServiceName());
        ctx.setAmount(reservation.getAmount());
        ctx.setApprovalUrl(callbackBase + "/approve?reservationId=" + reservationId);
        ctx.setCancelUrl(callbackBase + "/cancel?reservationId=" + reservationId);
        ctx.setFailUrl(callbackBase + "/fail?reservationId=" + reservationId);

        try {
            PaymentReadyVO ready = paymentGatewayResolver.resolve(provider).ready(ctx);

            // 승인 단계에서 이 tid 가 있어야 한다
            reservationService.saveTransactionId(reservationId, ready.getTid());
            return "redirect:" + ready.getRedirectUrl();

        } catch (IllegalStateException | IllegalArgumentException e) {
            // 결제창까지 못 갔으니 방금 잡아둔 자리를 놓아준다
            reservationService.failPayment(reservationId);
            return reserveFailView(model, salonId, e.getMessage());
        }
    }

    /**
     * 결제창에서 승인하고 돌아오는 자리.
     *
     * 결제사마다 되돌아올 때 붙여주는 값이 달라(카카오는 pg_token, 토스는 paymentKey 등)
     * 특정 파라미터를 받지 않고 전체를 맵으로 받아 게이트웨이에 그대로 넘긴다.
     */
    @GetMapping("/payment/{provider}/approve")
    public String reserveApprove(@PathVariable String provider,
            @RequestParam int reservationId,
            @RequestParam Map<String, String> callbackParams,
            Authentication authentication,
            Model model) {

        UserVO user = userService.getUser(authentication.getName());
        ReservationVO reservation = reservationService.getReservation(reservationId);

        // 주소만 알면 남의 예약을 승인시킬 수 있으므로 주인이 맞는지 본다
        if (reservation == null || reservation.getUserId() != user.getUserId()) {
            return reserveFailView(model, 0, "예약 정보를 찾을 수 없습니다.");
        }

        PaymentVO payment = reservationService.getPayment(reservationId);
        if (payment == null || payment.getTransactionId() == null) {
            return reserveFailView(model, reservation.getSalonId(), "결제 정보를 찾을 수 없습니다.");
        }

        // provider 는 주소에 실려 오므로 사용자가 고칠 수 있다. 결제를 시작할 때 저장해 둔
        // 결제사와 다르면 승인하지 않는다. 이 검사가 없으면 유료 결제를 ZERO 게이트웨이로
        // 승인시켜 공짜로 예약을 확정할 수 있다.
        if (!provider.equals(payment.getPgProvider())) {
            return reserveFailView(model, reservation.getSalonId(), "결제 정보가 올바르지 않습니다.");
        }

        // 승인 화면을 새로고침하면 결제사가 준 일회용 토큰이 이미 쓰인 값이라 두 번째 승인은 실패한다.
        // 그대로 두면 결제가 끝난 예약이 실패 화면으로 보이므로 여기서 먼저 걸러낸다.
        if ("completed".equals(payment.getPaymentStatus())) {
            model.addAttribute("success", true);
            model.addAttribute("reservation", reservation);
            return "common/reserve-result";
        }

        // 결제창에 10분 넘게 머물렀다면 만료 정리가 이미 이 예약을 접었다.
        // 이때 승인을 호출하면 돈은 빠져나가는데 예약은 취소 상태로 남는다.
        // 승인 '전에' 막아야 하는 이유이고, 그래서 이 검사는 gateway.approve() 위에 있어야 한다.
        if (!"pending".equals(payment.getPaymentStatus())) {
            return reserveFailView(model, reservation.getSalonId(),
                    "결제 시간이 만료되어 예약이 취소되었습니다. 다시 예약해 주세요.");
        }

        try {
            PaymentContextVO ctx = new PaymentContextVO();
            ctx.setReservationId(reservationId);
            ctx.setUserId(user.getUserId());
            ctx.setTid(payment.getTransactionId());
            ctx.setAmount(payment.getAmount().intValue());

            PaymentApprovalVO approved = paymentGatewayResolver.resolve(provider).approve(ctx, callbackParams);

            reservationService.confirmPayment(reservationId,
                    approved.getApprovedAmount(), approved.getPaymentMethod());

        } catch (IllegalStateException | IllegalArgumentException e) {
            reservationService.failPayment(reservationId);
            return reserveFailView(model, reservation.getSalonId(), e.getMessage());
        }

        model.addAttribute("success", true);
        model.addAttribute("reservation", reservationService.getReservation(reservationId));
        return "common/reserve-result";
    }

    /** 결제창에서 취소를 누르거나(cancel_url) 결제가 실패했을 때(fail_url) */
    @GetMapping({ "/payment/{provider}/cancel", "/payment/{provider}/fail" })
    public String reservePaymentAborted(@RequestParam int reservationId,
            Authentication authentication, Model model) {

        UserVO user = userService.getUser(authentication.getName());
        ReservationVO reservation = reservationService.getReservation(reservationId);

        if (reservation != null && reservation.getUserId() == user.getUserId()) {
            reservationService.failPayment(reservationId);
        }
        return reserveFailView(model,
                reservation == null ? 0 : reservation.getSalonId(),
                "결제가 취소되었습니다. 예약은 저장되지 않았습니다.");
    }

    private String reserveFailView(Model model, int salonId, String message) {
        model.addAttribute("success", false);
        model.addAttribute("errorMessage", message);
        if (salonId > 0) {
            model.addAttribute("salonId", salonId);
        }
        return "common/reserve-result";
    }

    /**
     * 카카오페이가 되돌아올 주소를 만들려면 절대 주소가 필요하다.
     * 배포 환경마다 호스트/포트가 달라지므로 들어온 요청에서 그대로 뽑아 쓴다.
     */
    private String baseUrlOf(HttpServletRequest request) {
        StringBuilder url = new StringBuilder()
                .append(request.getScheme()).append("://")
                .append(request.getServerName());

        int port = request.getServerPort();
        boolean defaultPort = ("http".equals(request.getScheme()) && port == 80)
                || ("https".equals(request.getScheme()) && port == 443);
        if (!defaultPort) {
            url.append(':').append(port);
        }
        return url.append(request.getContextPath()).toString();
    }

    /**
     * 최종 확인 화면. DB 를 쓰지 않는 조회 전용이라 자리를 선점하지 않는다.
     * 선점은 이 화면의 [결제하기] 가 POST 로 들어올 때 비로소 시작된다.
     */
    @GetMapping("/checkout")
    public String getCheckout(Model model, @RequestParam int salonId,
            @RequestParam int serviceId,
            @RequestParam int stylistId,
            @RequestParam String reservationTime,
            Authentication authentication) {
        // 1) 조합 검증
        ServiceVO service;
        try {
            service = reservationService.validateCombination(salonId, stylistId, serviceId);
        } catch (IllegalArgumentException e) {
            return reserveFailView(model, salonId, e.getMessage());
        }

        // 2) 아직 비어있는 자리인지
        String date = reservationTime.substring(0, 10);
        String time = reservationTime.substring(11, 16);
        boolean open = reservationService.getAvailableSlots(stylistId, date).stream()
                .anyMatch(s -> s.getTime().equals(time) && s.isAvailable());
        if (!open) {
            return blockedSlotView(model, salonId, stylistId, reservationTime, authentication);
        }

        UserVO user = userService.getUser(authentication.getName());

        model.addAttribute("salon", salonService.getSalon(salonId));
        model.addAttribute("service", service);
        model.addAttribute("stylist", stylistService.findByStylistId(stylistId));
        model.addAttribute("reservationTime", reservationTime);
        // 처음 들어왔을 때는 할인 없이 계산한 값. 사용자가 적립금을 입력하면
        // /checkout/quote 가 같은 메서드로 다시 계산해 화면만 갱신한다.
        model.addAttribute("quote",
                checkoutService.quote(user.getUserId(), serviceId, null, 0));
        return "common/checkout";
    }

    /**
     * 확인 화면에서 적립금·쿠폰을 바꿀 때마다 부르는 금액 재계산.
     * 뷰가 아니라 JSON 을 돌려주므로 @ResponseBody 를 붙인다.
     *
     * 계산은 결제 시점과 <b>같은</b> CheckoutService.quote() 가 한다.
     * 화면용 계산을 따로 만들면 보여준 금액과 청구한 금액이 어긋난다.
     */
    @PostMapping("/checkout/quote")
    @ResponseBody
    public PriceQuoteVO checkoutQuote(@RequestParam int serviceId,
            @RequestParam(required = false) Integer userCouponId,
            @RequestParam(defaultValue = "0") int pointToUse,
            Authentication authentication) {

        UserVO user = userService.getUser(authentication.getName());
        return checkoutService.quote(user.getUserId(), serviceId, userCouponId, pointToUse);
    }

    /**
     * 자리가 막혔을 때, 막고 있는 것이 본인의 미완료 결제인지 남의 예약인지 구분한다.
     *
     * 결제창에서 뒤로가기로 빠져나오면 콜백이 오지 않아 방금 만든 pending 예약이 그대로 남는다.
     * 그 상태로 확인 화면에 다시 들어오면 "자기가 잡아둔 자리 때문에 막히는" 막다른 길이 된다.
     * 그래서 본인 것이면 되돌릴 링크를 함께 준다.
     *
     * 여기서 곧바로 취소해 버리지 않는 이유는, 다른 탭에서 결제를 진행 중일 수 있기 때문이다.
     * 그 예약을 말없이 접으면 결제는 승인되는데 예약은 취소 상태로 남아 돈만 빠져나간다.
     */
    private String blockedSlotView(Model model, int salonId, int stylistId,
            String reservationTime, Authentication authentication) {

        // reservation_time 은 초까지 저장돼 있다 (createPendingReservation 이 ":00" 을 붙인다)
        ReservationVO hold = reservationService.findPendingHold(stylistId, reservationTime + ":00");
        UserVO user = userService.getUser(authentication.getName());

        if (hold != null && hold.getUserId() == user.getUserId()) {
            model.addAttribute("pendingReservationId", hold.getReservationId());
            model.addAttribute("pendingProvider", hold.getPgProvider());
            return reserveFailView(model, salonId,
                    "이전 결제가 완료되지 않아 이 시간이 아직 잡혀 있습니다.");
        }
        return reserveFailView(model, salonId, "선택할 수 없는 시간입니다. 다른 시간을 골라주세요.");
    }
}
