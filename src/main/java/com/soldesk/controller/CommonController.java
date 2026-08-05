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
import com.soldesk.service.OwnerRequestService;
import com.soldesk.service.ChatService;
import com.soldesk.service.KakaoPayService;
import com.soldesk.service.ReservationService;
import com.soldesk.service.ReviewService;
import com.soldesk.service.AdvertisementService;
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
// import org.springframework.web.bind.annotation.RequestBody;

@Controller
@RequestMapping("/common")
public class CommonController {

    private final Logger log = LoggerFactory.getLogger(CommonController.class);

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

    // 지도 마커용 미용실 목록을 JSP 안에서 JS 배열로 쓰기 위해 직접 만들어 쓴다 (빈으로 등록된 ObjectMapper 는 없다)
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Value("${kakaoMapApiKey}")
    private String kakaoMapApiKey;

    @InitBinder("changePassword")
    public void initBinder(WebDataBinder binder) {
        binder.addValidators(passwordChangeValidator);
    }

    // 메인페이지
    @GetMapping("/home")
    public String home(Authentication authentication, Model model) {
        model.addAttribute("salons", salonService.getSalons());
        model.addAttribute("advertisements", advertisementService.getVisibleAdvertisements());
        model.addAttribute("wishlistedSalonIds", java.util.Collections.emptyList());
        if (authentication != null && authentication.isAuthenticated()
                && !"anonymousUser".equals(authentication.getName())) {
            UserVO user = userService.getUser(authentication.getName());
            model.addAttribute("wishlistedSalonIds", wishlistService.getSalonIds(user.getUserId()));
        }
        return "common/home";
    }

    // 마이페이지
    @GetMapping("/mypage")
    public String mypage(Authentication authentication, Model model) {

        UserVO user = userService.getUser(authentication.getName());

        model.addAttribute("user", user);
        model.addAttribute("reservationCount", reservationService.countCompleted(user.getUserId()));
        model.addAttribute("wishlistCount", wishlistService.count(user.getUserId()));
        model.addAttribute("reviewCount", reviewService.countUserReviews(user.getUserId()));

        return "common/mypage";
    }

    /** 비밀번호 변경 (마이페이지 모달에서 AJAX로 호출) */
    @PostMapping("/mypage/password")
    @ResponseBody
    public Map<String, Object> passwordSubmit(Authentication authentication,
            @Validated @ModelAttribute("changePassword") PasswordChangeVO changePassword,
            BindingResult result) {
        if (!result.hasErrors()) {
            try {
                userService.changePassword(authentication.getName(), changePassword.getCurrentPassword(),
                        changePassword.getNewPassword());
            } catch (IllegalArgumentException e) {
                result.rejectValue("currentPassword", "currentPassword.mismatch", e.getMessage());
            }
        }

        if (result.hasErrors()) {
            Map<String, String> errors = new LinkedHashMap<>();
            for (FieldError fieldError : result.getFieldErrors()) {
                errors.put(fieldError.getField(), fieldError.getDefaultMessage());
            }
            return Map.of("success", false, "errors", errors);
        }
        return Map.of("success", true);
    }

    // 점주 승격 요청 페이지 — 신청 제출/처리 백엔드는 아직 없음(다음 단계 작업)
    @GetMapping("/owner-request")
    public String ownerRequestForm(Authentication authentication, Model model) {
        model.addAttribute("user", userService.getUser(authentication.getName()));
        return "common/owner-request";
    }

    // 예약 내역 가져오기
    @GetMapping("/reservation")
    public String pageReserve(Model model) {
        String userEmail = SecurityContextHolder.getContext().getAuthentication().getName();

        UserVO user = userService.getUser(userEmail);
        List<ReservationVO> list = reservationService.getRevList(user.getUserId());
        model.addAttribute("reservs", list);
        return "common/reservations";
    }

    // 예약 캘린더
    @GetMapping("/calendar")
    public String calendar() {
        return "common/calendar";
    }

    // 예약 캘린더에 표시할 실제 예약 데이터//
    @GetMapping("/calendar/events")
    @ResponseBody
    public List<ReservationVO> calendarEvents(Authentication authentication) {
        UserVO user = userService.getUser(authentication.getName());
        return reservationService.getRevList(user.getUserId());
    }

    // 미용실 지도 검색 (카카오맵)
    @GetMapping("/salonmap")
    public String salonMap(Authentication authentication, Model model) throws JsonProcessingException {

        model.addAttribute("salonsJson", objectMapper.writeValueAsString(salonService.getSalons()));
        model.addAttribute("kakaoMapApiKey", kakaoMapApiKey);
        List<Integer> wishlistedSalonIds = java.util.Collections.emptyList();
        if (authentication != null && authentication.isAuthenticated()
                && !"anonymousUser".equals(authentication.getName())) {
            UserVO user = userService.getUser(authentication.getName());
            wishlistedSalonIds = wishlistService.getSalonIds(user.getUserId());
        }
        model.addAttribute("wishlistedSalonIdsJson", objectMapper.writeValueAsString(wishlistedSalonIds));
        return "common/salonmap";
    }

    /**
     * 지도 페이지 검색창이 호출한다. 뷰가 아니라 JSON 을 돌려주므로 Model 이 아니라
     * 
     * @ResponseBody + 반환값이 곧 응답 본문이 된다. JSON 키는 SalonVO 필드명 그대로 나가고,
     *               salonmap.jsp 의 renderSalons() 가 그 이름을 그대로 읽는다.
     *               (검색은 상태를 바꾸지 않는 조회라서 POST 가 아니라 GET)
     */
    @GetMapping("/salons/search")
    @ResponseBody
    public List<SalonVO> searchSalons(@RequestParam(defaultValue = "") String keyword) throws Exception {
        return salonService.searchSalons(keyword);
    }

    // 미용실 검색하기
    @GetMapping("/reserve")
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
    @GetMapping("/reserve/slots")
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
    @GetMapping("/reserve/stylist-schedule")
    @ResponseBody
    public List<String> reserveStylistSchedule(@RequestParam int stylistId) {
        return stylistService.getAvailableDates(stylistId);
    }

    /**
     * 예약하기 → 결제창으로 보내는 단계.
     * 예약을 pending 으로 세운 뒤 카카오페이 결제창 주소로 리다이렉트한다.
     */
    @PostMapping("/reserve")
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
    @GetMapping("/reserve/payment/approve")
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
    @GetMapping({ "/reserve/payment/cancel", "/reserve/payment/fail" })
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

    // 점주요청
    @PostMapping("/owner-request")
    public String ownerRequestSubmit(Authentication authentication,
            @RequestParam String salonName,
            @RequestParam String salonPhone,
            @RequestParam String message,
            Model model) {
        UserVO user = userService.getUser(authentication.getName());
        ownerRequestService.submit(user.getUserId(), salonName, salonPhone, message);
        return "redirect:/common/owner-request?submitted=true";
    }

    /**
     * 1:1 상담 채팅 화면.
     * 사이드바에서는 파라미터 없이 들어오고(→ 방 목록만), 방을 고르면 ?chatId=N 이 붙는다.
     * 과거 대화 이력은 웹소켓이 아니라 여기서 미리 실어 보낸다 — 소켓은 "이후 새 메시지"만 담당.
     */
    @GetMapping("/chat")
    public String chat(Authentication authentication,
            @RequestParam(required = false) Integer chatId,
            Model model) {

        UserVO user = userService.getUser(authentication.getName());
        List<ChatRoomVO> rooms = chatService.getCustomerRooms(user.getUserId());
        log.debug("채팅 목록 조회 - user={}, rooms={}", user.getUserName(), rooms.size());
        model.addAttribute("user", user);
        model.addAttribute("rooms", rooms);

        // 방을 안 골랐으면 가장 최근 방을 자동으로 연다 (목록은 updated_at 내림차순)
        if (chatId == null && !rooms.isEmpty()) {
            chatId = rooms.get(0).getChatId();
        }
        if (chatId != null) {
            model.addAttribute("chatId", chatId);
            // getMessages 가 읽음 처리까지 하므로, 이미 뽑아둔 rooms 의 안읽음 배지도 맞춰준다
            // (다시 조회하지 않으려고 메모리에서 0으로 내린다)
            model.addAttribute("messages", chatService.getMessages(chatId, user.getUserId()));
            clearUnreadBadge(rooms, chatId);
        }
        return "common/chat";
    }

    /** 매장 상세/예약내역의 "1:1 문의" 버튼. 방이 없으면 만들고, 있으면 그 방으로 보낸다. */
    @PostMapping("/chat/room")
    public String openChatRoom(Authentication authentication, @RequestParam int salonId) {

        UserVO user = userService.getUser(authentication.getName());
        int chatId = chatService.openRoom(user.getUserId(), salonId);

        return "redirect:/common/chat?chatId=" + chatId;
    }

    /**
     * 방을 바꿀 때 페이지 새로고침 없이 이력만 갈아끼우기 위한 JSON.
     * 점주 화면(owner/chat)도 같은 엔드포인트를 쓴다 — 참여자 검증은 ChatService 가 한다.
     */
    @GetMapping("/chat/{chatId}/messages")
    @ResponseBody
    public List<MessageVO> chatMessages(Authentication authentication, @PathVariable int chatId) {

        UserVO user = userService.getUser(authentication.getName());
        return chatService.getMessages(chatId, user.getUserId());
    }

    /**
     * 사이드바 알림 배지의 초기값. 사이드바는 거의 모든 페이지에 들어가므로
     * 컨트롤러마다 모델에 넣는 대신 이 한 곳을 화면에서 호출하게 한다.
     * (점주 화면도 같은 엔드포인트를 쓴다)
     */
    @GetMapping("/chat/unread-count")
    @ResponseBody
    public Map<String, Integer> unreadCount(Authentication authentication) {

        UserVO user = userService.getUser(authentication.getName());
        return Map.of("count", chatService.getUnreadCount(user.getUserId()));
    }

    /** 지금 열어본 방은 읽음 처리됐으므로 목록의 안읽음 배지도 0으로 맞춘다 */
    static void clearUnreadBadge(List<ChatRoomVO> rooms, int chatId) {
        for (ChatRoomVO room : rooms) {
            if (room.getChatId() == chatId) {
                room.setUnreadCount(0);
                return;
            }
        }
    }

}
