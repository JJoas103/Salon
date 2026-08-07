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
import com.soldesk.service.PointService;
import com.soldesk.service.ReservationService;
import com.soldesk.service.ReviewService;
import com.soldesk.service.AdvertisementService;
import com.soldesk.service.SalonNoticeService;
import com.soldesk.service.SalonService;
import com.soldesk.service.UserService;
import com.soldesk.service.WishlistService;
import com.soldesk.validation.PasswordChangeValidator;
import com.soldesk.vo.ChatRoomVO;
import com.soldesk.vo.MessageVO;
import com.soldesk.vo.PasswordChangeVO;
import com.soldesk.vo.ReservationVO;
import com.soldesk.vo.SalonNoticeVO;
import com.soldesk.vo.SalonVO;
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
    private PointService pointService;

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
    private SalonNoticeService salonNoticeService;

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
        model.addAttribute("pointBalance", pointService.getBalance(user.getUserId()));

        return "common/mypage";
    }

    /** 적립금 내역 — 마이페이지의 적립금 카드에서 들어온다 */
    @GetMapping("/points")
    public String points(Authentication authentication, Model model) {

        UserVO user = userService.getUser(authentication.getName());

        model.addAttribute("pointBalance", pointService.getBalance(user.getUserId()));
        model.addAttribute("pointHistory", pointService.getHistory(user.getUserId()));

        return "common/points";
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
            model.addAttribute("currentUserId", user.getUserId());
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

    /** 지도 상세 카드의 "공지사항" 탭이 매장을 고를 때마다 호출하는 JSON. */
    @GetMapping("/salons/{salonId}/notices")
    @ResponseBody
    public List<SalonNoticeVO> salonNotices(@PathVariable int salonId) {
        return salonNoticeService.getBySalonId(salonId);
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
