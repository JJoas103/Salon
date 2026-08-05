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
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.soldesk.service.KakaoPayService;
import com.soldesk.service.ReservationService;
import com.soldesk.service.SalonService;
import com.soldesk.service.StylistService;
import com.soldesk.service.UserService;
import com.soldesk.service.WishlistService;
import com.soldesk.vo.PaymentVO;
import com.soldesk.vo.ReservationVO;
import com.soldesk.vo.SalonVO;
import com.soldesk.vo.ServiceVO;
import com.soldesk.vo.StylistVO;
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
    private KakaoPayService kakaoPayService;

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
     * 예약하기 → 결제창으로 보내는 단계.
     * 예약을 pending 으로 세운 뒤 카카오페이 결제창 주소로 리다이렉트한다.
     */
    @PostMapping
    public String reserveSubmit(@RequestParam int salonId,
            @RequestParam int serviceId,
            @RequestParam int stylistId,
            @RequestParam String reservationTime,
            Authentication authentication,
            HttpServletRequest request,
            Model model) {

        UserVO user = userService.getUser(authentication.getName());
        ReservationVO reservation;
        try {
            reservation = reservationService.createPendingReservation(
                    user.getUserId(), salonId, stylistId, serviceId, reservationTime);
        } catch (IllegalArgumentException e) {
            // 자리를 뺏겼거나 값이 어긋난 경우 — 예약이 만들어지지 않았으므로 되돌릴 것이 없다
            return reserveFailView(model, salonId, e.getMessage());
        }

        int reservationId = reservation.getReservationId();
        String callbackBase = baseUrlOf(request) + "/common/reserve/payment";

        try {
            Map<String, Object> ready = kakaoPayService.ready(
                    reservationId,
                    user.getUserId(),
                    reservation.getServiceName(),
                    java.math.BigDecimal.valueOf(reservation.getAmount()),
                    callbackBase + "/approve?reservationId=" + reservationId,
                    callbackBase + "/cancel?reservationId=" + reservationId,
                    callbackBase + "/fail?reservationId=" + reservationId);

            // 승인 단계에서 이 tid 가 있어야 한다
            reservationService.saveTransactionId(reservationId, (String) ready.get("tid"));
            return "redirect:" + ready.get("next_redirect_pc_url");

        } catch (IllegalStateException e) {
            // 결제창까지 못 갔으니 방금 잡아둔 자리를 놓아준다
            reservationService.failPayment(reservationId);
            return reserveFailView(model, salonId, e.getMessage());
        }
    }

    /** 카카오페이 결제창에서 승인하고 돌아오는 자리 */
    @GetMapping("/payment/approve")
    public String reserveApprove(@RequestParam int reservationId,
            @RequestParam("pg_token") String pgToken,
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

        // 승인 화면을 새로고침하면 pg_token 이 이미 쓰인 값이라 두 번째 승인은 실패한다.
        // 그대로 두면 결제가 끝난 예약이 실패 화면으로 보이므로 여기서 먼저 걸러낸다.
        if ("completed".equals(payment.getPaymentStatus())) {
            model.addAttribute("success", true);
            model.addAttribute("reservation", reservation);
            return "common/reserve-result";
        }

        try {
            Map<String, Object> approved = kakaoPayService.approve(
                    reservationId, user.getUserId(), payment.getTransactionId(), pgToken);

            @SuppressWarnings("unchecked")
            Map<String, Object> amount = (Map<String, Object>) approved.get("amount");
            int total = ((Number) amount.get("total")).intValue();

            reservationService.confirmPayment(reservationId, total,
                    (String) approved.get("payment_method_type"));

        } catch (IllegalStateException e) {
            reservationService.failPayment(reservationId);
            return reserveFailView(model, reservation.getSalonId(), e.getMessage());
        }

        model.addAttribute("success", true);
        model.addAttribute("reservation", reservationService.getReservation(reservationId));
        return "common/reserve-result";
    }

    /** 결제창에서 취소를 누르거나(cancel_url) 결제가 실패했을 때(fail_url) */
    @GetMapping({ "/payment/cancel", "/payment/fail" })
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


    @GetMapping("/checkout")
    public String getCheckout(Model model, @RequestParam int salonId, 
                                            @RequestParam int serviceId, 
                                            @RequestParam int stylistId, 
                                            @RequestParam String reservationTime){
        //1) 조합 검증 
        ServiceVO service;
        try{
            service = reservationService.validateCombination(salonId, stylistId, serviceId);
        } catch(IllegalArgumentException e) {
            return reserveFailView(model, salonId, e.getMessage());
        }

        // 2) 아직 비어있는 자리인지 
        String date = reservationTime.substring(0, 10);
        String time = reservationTime.substring(11, 16);
        boolean open = reservationService.getAvailableSlots(stylistId, date).stream()
                        .anyMatch(s -> s.getTime().equals(time) && s.isAvailable());
        if(!open) {
            return reserveFailView(model, salonId, "선택할 수 없는 시간입니다. 다른 시간을 골라주세요.");
        }
        
        model.addAttribute("salon", salonService.getSalon(salonId));
        model.addAttribute("service", service);
        model.addAttribute("stylist", stylistService.findByStylistId(stylistId));
        model.addAttribute("reservationTime", reservationTime);
        return "common/checkout";
    }
}
