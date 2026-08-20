package com.soldesk.controller;

import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

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
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.soldesk.service.AdvertisementService;
import com.soldesk.service.ChatService;
import com.soldesk.service.CouponService;
import com.soldesk.service.OwnerRequestService;
import com.soldesk.service.PointService;
import com.soldesk.service.PostService;
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
    private PointService pointService;

    @Autowired
    private CouponService couponService;

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

    @Autowired
    private PostService postService;

    // 지도 마커용 미용실 목록을 JSP 안에서 JS 배열로 쓰기 위해 직접 만들어 쓴다 (빈으로 등록된 ObjectMapper 는 없다)
    private final ObjectMapper objectMapper = new ObjectMapper();

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
        model.addAttribute("reservationCount", reservationService.countCompleted(user.getUserId()));
        // 등급은 매장마다 점주가 다른 별개 사업자라 전체 합산이 아니라 매장별로 따로 보여준다.
        // "내 등급 보기" 버튼이 여는 모달에서 이 목록을 매장별 배지로 나열한다.
        model.addAttribute("salonGrades", reservationService.getSalonGrades(user.getUserId()));
        model.addAttribute("wishlistCount", wishlistService.count(user.getUserId()));
        model.addAttribute("reviewCount", reviewService.countUserReviews(user.getUserId()));
        model.addAttribute("pointBalance", pointService.getBalance(user.getUserId()));
        model.addAttribute("couponCount", couponService.countAvailable(user.getUserId()));
        model.addAttribute("communityReplyCount", postService.countRepliesToMyPosts(user.getUserId()));

        return "common/mypage";
    }

    /** 내 커뮤니티 활동(작성 글/댓글, 받은 댓글) — 마이페이지의 커뮤니티 활동 카드에서 들어온다 */
    @GetMapping("/my-community")
    public String myCommunity(@RequestParam(required = false, defaultValue = "posts") String tab,
                              Authentication authentication, Model model) {

        UserVO user = userService.getUser(authentication.getName());
        int userId = user.getUserId();

        if ("replies".equals(tab)) {
            userService.markReplyCheck(userId); // 안읽음 배지를 0으로 되돌린다
        }

        model.addAttribute("tab", tab);
        model.addAttribute("myPosts", postService.getMyPosts(userId));
        model.addAttribute("myComments", postService.getMyComments(userId));
        model.addAttribute("myReplies", postService.getRepliesToMyPosts(userId));

        return "common/my-community";
    }

    /** 내 커뮤니티 활동 - "내가 쓴 댓글" 탭에서 삭제된 게시글의 죽은 기록 정리 (본인 댓글만) */
    @PostMapping("/my-community/comments/{commentId}/delete")
    public String deleteMyComment(@PathVariable int commentId, Authentication authentication) {
        UserVO user = userService.getUser(authentication.getName());
        postService.removeComment(commentId, user.getUserId());
        return "redirect:/common/my-community?tab=comments";
    }

    /** 내 커뮤니티 활동 - "내 글에 달린 댓글" 탭에서 삭제된 게시글의 죽은 기록 정리 (내 글 주인일 때만) */
    @PostMapping("/my-community/replies/{commentId}/delete")
    public String deleteReplyOnMyPost(@PathVariable int commentId, Authentication authentication) {
        UserVO user = userService.getUser(authentication.getName());
        postService.removeCommentAsPostOwner(commentId, user.getUserId());
        return "redirect:/common/my-community?tab=replies";
    }

    /** 쿠폰함 — 마이페이지의 쿠폰 카드에서 들어온다 */
    @GetMapping("/coupons")
    public String coupons(Authentication authentication, Model model) {

        UserVO user = userService.getUser(authentication.getName());

        model.addAttribute("couponCount", couponService.countAvailable(user.getUserId()));
        model.addAttribute("myCoupons", couponService.getMyCoupons(user.getUserId()));
        // 화면이 기한 만료를 판단하는 기준. 만료분은 status 를 바꾸지 않으므로 날짜를 직접 견줘야 한다.
        model.addAttribute("today", java.time.LocalDate.now().toString());

        return "common/coupons";
    }

    /**
     * 쿠폰 코드 등록 — 마이페이지의 코드 입력 폼에서 들어온다.
     *
     * 성공/실패 모두 마이페이지로 돌려보낸다. 폼이 그 화면에 있으므로 결과도 같은 자리에서 보여야
     * 하고, 성공 시 "보유 활성 쿠폰" 카드 숫자가 바로 올라간 것이 함께 보인다.
     */
    @PostMapping("/coupons/redeem")
    public String redeemCoupon(Authentication authentication,
            @RequestParam(required = false) String couponCode,
            RedirectAttributes redirectAttributes) {

        UserVO user = userService.getUser(authentication.getName());

        try {
            String couponName = couponService.redeemByCode(user.getUserId(), couponCode);
            redirectAttributes.addFlashAttribute("couponRedeemSuccess",
                    "'" + couponName + "' 쿠폰이 발급되었습니다.");
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("couponRedeemError", e.getMessage());
        }

        return "redirect:/common/mypage";
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
    public Map<String, Object> passwordSubmit(
            Authentication authentication,
            @Validated
            @ModelAttribute("changePassword")
            PasswordChangeVO changePassword,
            BindingResult result) {
        // 소셜(구글/네이버) 계정은 로컬 비밀번호가 없다. 화면에서 버튼을 숨기는 것과 별개로,
        // 요청을 직접 보내는 경우까지 막기 위해 서버에서도 한 번 더 확인한다.
        UserVO currentUser = userService.getUser(authentication.getName());
        if (!"local".equals(currentUser.getProvider())) {
            result.rejectValue("currentPassword", "provider.notLocal", "소셜 로그인 계정은 비밀번호를 변경할 수 없습니다.");
        }

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

    /** 사이드바 "내 정보" 모달이 열릴 때 AJAX로 부르는 현재 회원 정보. 페이지마다 user 모델을 안 채워도 되게 하려고 분리함 */
    @GetMapping("/mypage/whoami")
    @ResponseBody
    public Map<String, Object> whoami(Authentication authentication) {
        UserVO user = userService.getUser(authentication.getName());
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("userName", user.getUserName());
        result.put("phoneNumber", user.getPhoneNumber());
        result.put("email", user.getEmail());
        result.put("createdAt", user.getCreatedAt());
        result.put("profileImageUrl", user.getProfileImageUrl() == null ? "" : user.getProfileImageUrl());
        result.put("notificationsEnabled", user.isNotificationsEnabled());
        return result;
    }

    /** 알림 설정 on/off 토글 — 마이페이지에서 AJAX로 호출, 바뀐 뒤 값을 돌려준다 */
    @PostMapping("/mypage/notifications")
    @ResponseBody
    public Map<String, Object> toggleNotifications(Authentication authentication) {
        boolean enabled = userService.toggleNotifications(authentication.getName());
        return Map.of("enabled", enabled);
    }

    /** 내 정보(이름·전화번호·프로필사진) 변경 — 마이페이지 모달에서 AJAX로 호출. 이메일은 정책상 여기서 안 받음 */
    @PostMapping("/mypage/info")
    @ResponseBody
    public Map<String, Object> infoSubmit(Authentication authentication,
            @RequestParam String userName, @RequestParam String phoneNumber,
            @RequestParam(required = false) MultipartFile profileImage) {
        try {
            userService.updateProfile(authentication.getName(), userName, phoneNumber, profileImage);
        } catch (IllegalArgumentException | IOException e) {
            return Map.of("success", false, "message", e.getMessage());
        }
        UserVO updated = userService.getUser(authentication.getName());
        return Map.of("success", true, "profileImageUrl", updated.getProfileImageUrl() == null ? "" : updated.getProfileImageUrl());
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

        // 환불 실패는 IllegalStateException 으로 올라옴. 같이 잡지 않으면 500 이 나가서
        // 화면에 "오류가 발생했습니다" 만 뜨고 왜 취소가 안 됐는지 손님이 알 수 없음
        } catch (IllegalArgumentException | IllegalStateException e) {

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
            UserVO user = userService.getUser(authentication.getName());
            wishlistedSalonIds = wishlistService.getSalonIds(user.getUserId());
            model.addAttribute("currentUserId", user.getUserId());
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

    /** 지도 상세 카드의 "공지사항" 탭이 매장을 고를 때마다 호출하는 JSON. */
    @GetMapping("/salons/{salonId}/notices")
    @ResponseBody
    public List<SalonNoticeVO> salonNotices(@PathVariable int salonId) {
        return salonNoticeService.getBySalonId(salonId);
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
            RedirectAttributes redirectAttributes) {
        UserVO user = userService.getUser(authentication.getName());
        try {
            ownerRequestService.submit(user.getUserId(), salonName, salonPhone, message);
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
            return "redirect:/common/owner-request";
        }
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
