package com.soldesk.controller;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.InitBinder;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.soldesk.service.AdvertisementService;
import com.soldesk.service.ChatService;
import com.soldesk.service.KakaoPayService;
import com.soldesk.service.OwnerRequestService;
import com.soldesk.service.ReservationService;
import com.soldesk.service.ReviewService;
import com.soldesk.service.SalonService;
import com.soldesk.service.StylistService;
import com.soldesk.service.UserService;
import com.soldesk.service.WishlistService;
import com.soldesk.validation.PasswordChangeValidator;
import com.soldesk.vo.ChatRoomVO;
import com.soldesk.vo.MessageVO;
import com.soldesk.vo.PasswordChangeVO;
import com.soldesk.vo.PaymentVO;
import com.soldesk.vo.ReservationVO;
import com.soldesk.vo.SalonVO;
import com.soldesk.vo.TimeSlotVO;
import com.soldesk.vo.UserVO;

@Controller
@RequestMapping("/common")
public class CommonController {

    private final Logger log =
            LoggerFactory.getLogger(CommonController.class);

    @Autowired
    private UserService userService;

    @Autowired
    private ReservationService reservationService;

    @Autowired
    private SalonService salonService;

    @Autowired
    private PasswordChangeValidator passwordChangeValidator;

    @Autowired
    private OwnerRequestService ownerRequestService;

    @Autowired
    private AdvertisementService advertisementService;

    @Autowired
    private ChatService chatService;

    @Autowired
    private WishlistService wishlistService;

    @Autowired
    private ReviewService reviewService;

    @Autowired
    private StylistService stylistService;

    @Autowired
    private KakaoPayService kakaoPayService;

    // 지도 마커용 미용실 목록을 JSP 안에서 JS 배열로 쓰기 위해 직접 생성
    private final ObjectMapper objectMapper =
            new ObjectMapper();

    @Value("${kakaoMapApiKey}")
    private String kakaoMapApiKey;


    /* =========================================================
       Validation
       ========================================================= */

    @InitBinder("changePassword")
    public void initBinder(WebDataBinder binder) {
        binder.addValidators(passwordChangeValidator);
    }


    /* =========================================================
       메인 페이지
       ========================================================= */

    @GetMapping("/home")
    public String home(
            Authentication authentication,
            Model model) {

        model.addAttribute(
                "salons",
                salonService.getSalons());

        model.addAttribute(
                "advertisements",
                advertisementService.getVisibleAdvertisements());

        model.addAttribute(
                "wishlistedSalonIds",
                java.util.Collections.emptyList());

        if (authentication != null
                && authentication.isAuthenticated()
                && !"anonymousUser".equals(authentication.getName())) {

            UserVO user =
                    userService.getUser(authentication.getName());

            model.addAttribute(
                    "wishlistedSalonIds",
                    wishlistService.getSalonIds(user.getUserId()));
        }

        return "common/home";
    }


    /* =========================================================
       마이페이지
       ========================================================= */

    @GetMapping("/mypage")
    public String mypage(
            Authentication authentication,
            Model model) {

        UserVO user =
                userService.getUser(authentication.getName());

        model.addAttribute("user", user);

        model.addAttribute(
                "reservationCount",
                reservationService.countCompleted(user.getUserId()));

        model.addAttribute(
                "wishlistCount",
                wishlistService.count(user.getUserId()));

        model.addAttribute(
                "reviewCount",
                reviewService.countUserReviews(user.getUserId()));

        return "common/mypage";
    }


    /* =========================================================
       비밀번호 변경
       ========================================================= */

    @PostMapping("/mypage/password")
    @ResponseBody
    public Map<String, Object> passwordSubmit(
            Authentication authentication,
            @Validated
            @ModelAttribute("changePassword")
            PasswordChangeVO changePassword,
            BindingResult result) {

        if (!result.hasErrors()) {

            try {

                userService.changePassword(
                        authentication.getName(),
                        changePassword.getCurrentPassword(),
                        changePassword.getNewPassword());

            } catch (IllegalArgumentException e) {

                result.rejectValue(
                        "currentPassword",
                        "currentPassword.mismatch",
                        e.getMessage());
            }
        }

        if (result.hasErrors()) {

            Map<String, String> errors =
                    new LinkedHashMap<>();

            for (FieldError fieldError
                    : result.getFieldErrors()) {

                errors.put(
                        fieldError.getField(),
                        fieldError.getDefaultMessage());
            }

            return Map.of(
                    "success", false,
                    "errors", errors);
        }

        return Map.of(
                "success", true);
    }


    /* =========================================================
       점주 승격 요청 페이지
       ========================================================= */

    @GetMapping("/owner-request")
    public String ownerRequestForm(
            Authentication authentication,
            Model model) {

        model.addAttribute(
                "user",
                userService.getUser(authentication.getName()));

        return "common/owner-request";
    }


    /* =========================================================
       예약 히스토리
       ========================================================= */

    @GetMapping("/reservation")
    public String pageReserve(Model model) {

        String userEmail =
                SecurityContextHolder
                        .getContext()
                        .getAuthentication()
                        .getName();

        UserVO user =
                userService.getUser(userEmail);

        /*
         * 예약 히스토리에서는
         * confirmed / completed / cancelled를 모두 조회한다.
         *
         * 취소 예약은 이후 별도 탭으로 나눌 예정이므로
         * 여기서는 제거하지 않는다.
         */
        List<ReservationVO> list =
                reservationService.getRevList(
                        user.getUserId());

        model.addAttribute(
                "reservs",
                list);

        return "common/reservations";
    }


    /* =========================================================
       사용자 예약 취소
       confirmed → cancelled
       ========================================================= */

    @PostMapping("/reservation/cancel")
    @ResponseBody
    public Map<String, Object> cancelReservation(
            @RequestParam int reservationId,
            Authentication authentication) {

        UserVO user =
                userService.getUser(
                        authentication.getName());

        try {

            /*
             * 로그인한 사용자의 userId를 직접 사용한다.
             *
             * 클라이언트에서 userId를 받지 않기 때문에
             * 다른 사용자의 예약을 임의로 취소할 수 없다.
             */
            reservationService.cancelReservation(
                    reservationId,
                    user.getUserId());

            return Map.of(
                    "success", true);

        } catch (IllegalArgumentException e) {

            return Map.of(
                    "success", false,
                    "message", e.getMessage());
        }
    }


    /* =========================================================
       예약 캘린더 페이지
       ========================================================= */

    @GetMapping("/calendar")
    public String calendar() {

        return "common/calendar";
    }


    /* =========================================================
       예약 캘린더 JSON 데이터
       ========================================================= */

    @GetMapping("/calendar/events")
    @ResponseBody
    public List<ReservationVO> calendarEvents(
            Authentication authentication) {

        UserVO user =
                userService.getUser(
                        authentication.getName());

        /*
         * 전체 예약 정보를 조회한 뒤
         * cancelled 상태는 캘린더에 전달하지 않는다.
         *
         * 따라서:
         *
         * confirmed → 캘린더 표시
         * completed → 캘린더 표시
         * cancelled → 캘린더에서 제거
         *
         * JS에서도 한 번 더 CANCELLED를 필터링하므로
         * 서버 + 클라이언트 양쪽에서 안전하게 제외한다.
         */
        return reservationService
                .getRevList(user.getUserId())
                .stream()
                .filter(reservation ->
                        !"cancelled".equalsIgnoreCase(
                                reservation.getStatus()))
                .toList();
    }


    /* =========================================================
       미용실 지도 검색
       ========================================================= */

    @GetMapping("/salonmap")
    public String salonMap(
            Authentication authentication,
            Model model)
            throws JsonProcessingException {

        model.addAttribute(
                "salonsJson",
                objectMapper.writeValueAsString(
                        salonService.getSalons()));

        model.addAttribute(
                "kakaoMapApiKey",
                kakaoMapApiKey);

        List<Integer> wishlistedSalonIds =
                java.util.Collections.emptyList();

        if (authentication != null
                && authentication.isAuthenticated()
                && !"anonymousUser".equals(authentication.getName())) {

            UserVO user =
                    userService.getUser(
                            authentication.getName());

            wishlistedSalonIds =
                    wishlistService.getSalonIds(
                            user.getUserId());
        }

        model.addAttribute(
                "wishlistedSalonIdsJson",
                objectMapper.writeValueAsString(
                        wishlistedSalonIds));

        return "common/salonmap";
    }


    /* =========================================================
       미용실 검색 API
       ========================================================= */

    @GetMapping("/salons/search")
    @ResponseBody
    public List<SalonVO> searchSalons(
            @RequestParam(defaultValue = "")
            String keyword)
            throws Exception {

        return salonService.searchSalons(keyword);
    }


    /* =========================================================
       미용실 예약 화면
       ========================================================= */

    @GetMapping("/reserve")
    public String search(
            @RequestParam(required = false)
            Integer salonId,
            Authentication authentication,
            Model model) {

        if (salonId == null) {

            List<SalonVO> salons =
                    salonService.getSalons();

            if (salons.isEmpty()) {

                model.addAttribute(
                        "salonNotFound",
                        true);

                return "common/reserve";
            }

            salonId =
                    salons.get(0).getSalonId();
        }

        SalonVO salon =
                salonService.getSalon(salonId);

        if (salon == null) {

            model.addAttribute(
                    "salonNotFound",
                    true);

            return "common/reserve";
        }

        model.addAttribute(
                "salon",
                salon);

        UserVO user =
                userService.getUser(
                        authentication.getName());

        model.addAttribute(
                "wishlisted",
                wishlistService.isWishlisted(
                        user.getUserId(),
                        salonId));

        model.addAttribute(
                "services",
                salonService.getServices(
                        salonId));

        model.addAttribute(
                "stylists",
                stylistService.findBySalonId(
                        salonId));

        return "common/reserve";
    }


    /* =========================================================
       예약 가능 시간 조회
       ========================================================= */

    @GetMapping("/reserve/slots")
    @ResponseBody
    public List<TimeSlotVO> reserveSlots(
            @RequestParam int stylistId,
            @RequestParam String date) {

        return reservationService
                .getAvailableSlots(
                        stylistId,
                        date);
    }


    /* =========================================================
       예약 생성 → 카카오페이 결제창
       ========================================================= */

    @PostMapping("/reserve")
    public String reserveSubmit(
            @RequestParam int salonId,
            @RequestParam int serviceId,
            @RequestParam int stylistId,
            @RequestParam String reservationTime,
            Authentication authentication,
            HttpServletRequest request,
            Model model) {

        UserVO user =
                userService.getUser(
                        authentication.getName());

        ReservationVO reservation;

        try {

            reservation =
                    reservationService
                            .createPendingReservation(
                                    user.getUserId(),
                                    salonId,
                                    stylistId,
                                    serviceId,
                                    reservationTime);

        } catch (IllegalArgumentException e) {

            return reserveFailView(
                    model,
                    salonId,
                    e.getMessage());
        }

        int reservationId =
                reservation.getReservationId();

        String callbackBase =
                baseUrlOf(request)
                        + "/common/reserve/payment";

        try {

            Map<String, Object> ready =
                    kakaoPayService.ready(
                            reservationId,
                            user.getUserId(),
                            reservation.getServiceName(),
                            java.math.BigDecimal.valueOf(
                                    reservation.getAmount()),
                            callbackBase
                                    + "/approve?reservationId="
                                    + reservationId,
                            callbackBase
                                    + "/cancel?reservationId="
                                    + reservationId,
                            callbackBase
                                    + "/fail?reservationId="
                                    + reservationId);

            reservationService
                    .saveTransactionId(
                            reservationId,
                            (String) ready.get("tid"));

            return "redirect:"
                    + ready.get(
                            "next_redirect_pc_url");

        } catch (IllegalStateException e) {

            reservationService
                    .failPayment(
                            reservationId);

            return reserveFailView(
                    model,
                    salonId,
                    e.getMessage());
        }
    }


    /* =========================================================
       카카오페이 결제 승인
       ========================================================= */

    @GetMapping("/reserve/payment/approve")
    public String reserveApprove(
            @RequestParam int reservationId,
            @RequestParam("pg_token")
            String pgToken,
            Authentication authentication,
            Model model) {

        UserVO user =
                userService.getUser(
                        authentication.getName());

        ReservationVO reservation =
                reservationService
                        .getReservation(
                                reservationId);

        if (reservation == null
                || reservation.getUserId()
                != user.getUserId()) {

            return reserveFailView(
                    model,
                    0,
                    "예약 정보를 찾을 수 없습니다.");
        }

        PaymentVO payment =
                reservationService
                        .getPayment(
                                reservationId);

        if (payment == null
                || payment.getTransactionId()
                == null) {

            return reserveFailView(
                    model,
                    reservation.getSalonId(),
                    "결제 정보를 찾을 수 없습니다.");
        }

        /*
         * 이미 결제가 완료된 페이지를 새로고침하면
         * pg_token 재사용 오류가 발생하므로
         * 먼저 완료 여부를 확인한다.
         */
        if ("completed".equals(
                payment.getPaymentStatus())) {

            model.addAttribute(
                    "success",
                    true);

            model.addAttribute(
                    "reservation",
                    reservation);

            return "common/reserve-result";
        }

        try {

            Map<String, Object> approved =
                    kakaoPayService.approve(
                            reservationId,
                            user.getUserId(),
                            payment.getTransactionId(),
                            pgToken);

            @SuppressWarnings("unchecked")
            Map<String, Object> amount =
                    (Map<String, Object>)
                            approved.get("amount");

            int total =
                    ((Number)
                            amount.get("total"))
                            .intValue();

            reservationService
                    .confirmPayment(
                            reservationId,
                            total,
                            (String) approved.get(
                                    "payment_method_type"));

        } catch (IllegalStateException e) {

            reservationService
                    .failPayment(
                            reservationId);

            return reserveFailView(
                    model,
                    reservation.getSalonId(),
                    e.getMessage());
        }

        model.addAttribute(
                "success",
                true);

        model.addAttribute(
                "reservation",
                reservationService
                        .getReservation(
                                reservationId));

        return "common/reserve-result";
    }


    /* =========================================================
       카카오페이 결제 취소 / 실패
       ========================================================= */

    @GetMapping({
            "/reserve/payment/cancel",
            "/reserve/payment/fail"
    })
    public String reservePaymentAborted(
            @RequestParam int reservationId,
            Authentication authentication,
            Model model) {

        UserVO user =
                userService.getUser(
                        authentication.getName());

        ReservationVO reservation =
                reservationService
                        .getReservation(
                                reservationId);

        if (reservation != null
                && reservation.getUserId()
                == user.getUserId()) {

            reservationService
                    .failPayment(
                            reservationId);
        }

        return reserveFailView(
                model,
                reservation == null
                        ? 0
                        : reservation.getSalonId(),
                "결제가 취소되었습니다. 예약은 저장되지 않았습니다.");
    }


    /* =========================================================
       예약 실패 화면
       ========================================================= */

    private String reserveFailView(
            Model model,
            int salonId,
            String message) {

        model.addAttribute(
                "success",
                false);

        model.addAttribute(
                "errorMessage",
                message);

        if (salonId > 0) {

            model.addAttribute(
                    "salonId",
                    salonId);
        }

        return "common/reserve-result";
    }


    /* =========================================================
       Callback Base URL 생성
       ========================================================= */

    private String baseUrlOf(
            HttpServletRequest request) {

        StringBuilder url =
                new StringBuilder()
                        .append(
                                request.getScheme())
                        .append("://")
                        .append(
                                request.getServerName());

        int port =
                request.getServerPort();

        boolean defaultPort =
                ("http".equals(
                        request.getScheme())
                        && port == 80)
                ||
                ("https".equals(
                        request.getScheme())
                        && port == 443);

        if (!defaultPort) {
            url.append(':')
                    .append(port);
        }

        return url
                .append(
                        request.getContextPath())
                .toString();
    }


    /* =========================================================
       점주 승격 요청
       ========================================================= */

    @PostMapping("/owner-request")
    public String ownerRequestSubmit(
            Authentication authentication,
            @RequestParam String salonName,
            @RequestParam String salonPhone,
            @RequestParam String message,
            Model model) {

        UserVO user =
                userService.getUser(
                        authentication.getName());

        ownerRequestService.submit(
                user.getUserId(),
                salonName,
                salonPhone,
                message);

        return "redirect:/common/owner-request?submitted=true";
    }


    /* =========================================================
       1:1 채팅
       ========================================================= */

    @GetMapping("/chat")
    public String chat(
            Authentication authentication,
            @RequestParam(required = false)
            Integer chatId,
            Model model) {

        UserVO user =
                userService.getUser(
                        authentication.getName());

        List<ChatRoomVO> rooms =
                chatService.getCustomerRooms(
                        user.getUserId());

        log.debug(
                "채팅 목록 조회 - user={}, rooms={}",
                user.getUserName(),
                rooms.size());

        model.addAttribute(
                "user",
                user);

        model.addAttribute(
                "rooms",
                rooms);

        if (chatId == null
                && !rooms.isEmpty()) {

            chatId =
                    rooms.get(0).getChatId();
        }

        if (chatId != null) {

            model.addAttribute(
                    "chatId",
                    chatId);

            model.addAttribute(
                    "messages",
                    chatService.getMessages(
                            chatId,
                            user.getUserId()));

            clearUnreadBadge(
                    rooms,
                    chatId);
        }

        return "common/chat";
    }


    /* =========================================================
       채팅방 생성 / 이동
       ========================================================= */

    @PostMapping("/chat/room")
    public String openChatRoom(
            Authentication authentication,
            @RequestParam int salonId) {

        UserVO user =
                userService.getUser(
                        authentication.getName());

        int chatId =
                chatService.openRoom(
                        user.getUserId(),
                        salonId);

        return "redirect:/common/chat?chatId="
                + chatId;
    }


    /* =========================================================
       채팅 메시지 조회
       ========================================================= */

    @GetMapping("/chat/{chatId}/messages")
    @ResponseBody
    public List<MessageVO> chatMessages(
            Authentication authentication,
            @PathVariable int chatId) {

        UserVO user =
                userService.getUser(
                        authentication.getName());

        return chatService.getMessages(
                chatId,
                user.getUserId());
    }


    /* =========================================================
       읽지 않은 채팅 수
       ========================================================= */

    @GetMapping("/chat/unread-count")
    @ResponseBody
    public Map<String, Integer> unreadCount(
            Authentication authentication) {

        UserVO user =
                userService.getUser(
                        authentication.getName());

        return Map.of(
                "count",
                chatService.getUnreadCount(
                        user.getUserId()));
    }


    /* =========================================================
       읽음 배지 초기화
       ========================================================= */

    static void clearUnreadBadge(
            List<ChatRoomVO> rooms,
            int chatId) {

        for (ChatRoomVO room : rooms) {

            if (room.getChatId()
                    == chatId) {

                room.setUnreadCount(0);

                return;
            }
        }
    }
}
