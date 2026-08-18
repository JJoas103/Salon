package com.soldesk.controller;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.soldesk.service.ChatService;
import com.soldesk.service.OwnerRequestService;
import com.soldesk.service.ReservationService;
import com.soldesk.service.SalonNoticeService;
import com.soldesk.service.SalonService;
import com.soldesk.service.StaffService;
import com.soldesk.service.UserService;
import com.soldesk.vo.ChatRoomVO;
import com.soldesk.vo.SalonNoticeVO;
import com.soldesk.vo.SalonVO;
import com.soldesk.vo.StylistScheduleVO;
import com.soldesk.vo.StylistVO;
import com.soldesk.vo.UserVO;

@Controller
@RequestMapping("/owner")
public class OwnerController {

    // 예약현황판 날짜 라벨용 (DB day_of_week 와 같은 한글 표기)
    private static final String[] DAY_KO = { "월", "화", "수", "목", "금", "토", "일" };

    // 매장 좌표가 들어올 수 있는 범위 (대한민국). 화면이 보내는 값이라 그대로 믿지 않고 여기서 한 번 거른다.
    private static final BigDecimal LAT_MIN = new BigDecimal("33");
    private static final BigDecimal LAT_MAX = new BigDecimal("39");
    private static final BigDecimal LNG_MIN = new BigDecimal("124");
    private static final BigDecimal LNG_MAX = new BigDecimal("132");

    @Autowired
    private UserService userService;

    @Autowired
    private SalonService salonService;

    @Autowired
    private StaffService staffService;

    @Autowired
    private ChatService chatService;

    @Autowired
    private ReservationService reservationService;
    
    @Autowired
    private SalonNoticeService salonNoticeService;

    @Autowired
    private OwnerRequestService ownerRequestService;

    // 매장정보 관리의 주소 검색 지도에 쓴다. 고객용 지도(CommonController.salonMap)와 같은 키다.
    @Value("${kakaoMapApiKey}")
    private String kakaoMapApiKey;

    // 점주 전용 홈 대시보드는 아직 없어서, 로그인 직후 착지할 곳으로 매장정보 관리를 사용
    @GetMapping("/home")
    public String home() {
        return "redirect:/owner/store";
    }

    /** 사이드바의 "매장 선택" 모달에서 카드 선택 시 호출 — 세션에 선택한 매장을 기억해둔다 */
    @GetMapping("/select-salon")
    public String selectSalon(@RequestParam int salonId, HttpSession session, HttpServletRequest request) {
        session.setAttribute("selectedSalonId", salonId);
        String referer = request.getHeader("Referer");
        return "redirect:" + (referer != null ? referer : "/owner/store");
    }

    // 아래 3개는 아직 정적 목업 내용을 그대로 보여주는 자리표시 라우트 — 추후 각자 실데이터로 구현 예정.
    // user/salons는 헤더의 내정보 모달과 사이드바의 매장 선택 모달에 공통으로 필요해서 매번 채워준다.
    @GetMapping("/store")
    public String store(Authentication authentication, HttpSession session, Model model) {
        fillCommonModel(authentication, model);
        model.addAttribute("kakaoMapApiKey", kakaoMapApiKey);
        Integer salonId = (Integer) session.getAttribute("selectedSalonId");
        if (salonId != null) {
            UserVO user = userService.getUser(authentication.getName());
            try {
                model.addAttribute("salon", salonService.getSalonForOwner(salonId, user.getUserId()));
                model.addAttribute("services", salonService.getServices(salonId));
            } catch (IllegalArgumentException e) {
                // 세션의 selectedSalonId가 본인 소유가 아니면 빈 폼으로 둔다
            }
            model.addAttribute("notices", salonNoticeService.getBySalonId(salonId));
        } else {
            model.addAttribute("notices", List.of());
        }
        return "owner/store";
    }

    @PostMapping("/store/service/register")
    public String registerService(Authentication authentication, HttpSession session,
            @RequestParam String serviceName,
            @RequestParam java.math.BigDecimal price,
            @RequestParam(required = false) Integer durationMinutes,
            @RequestParam(required = false) String description,
            RedirectAttributes redirectAttributes) {
        Integer salonId = (Integer) session.getAttribute("selectedSalonId");
        if (salonId == null) {
            redirectAttributes.addFlashAttribute("error", "매장을 먼저 선택해주세요.");
            return "redirect:/owner/store";
        }
        UserVO user = userService.getUser(authentication.getName());
        com.soldesk.vo.ServiceVO service = new com.soldesk.vo.ServiceVO();
        service.setSalonId(salonId);
        service.setServiceName(serviceName);
        service.setPrice(price);
        if (durationMinutes != null) {
            service.setDurationMinutes(durationMinutes);
        }
        service.setDescription(description);
        try {
            salonService.registerService(user.getUserId(), service);
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/owner/store";
    }

    @PostMapping("/store/service/{serviceId}/update")
    public String updateService(@PathVariable int serviceId, Authentication authentication,
            @RequestParam String serviceName,
            @RequestParam java.math.BigDecimal price,
            @RequestParam(required = false) Integer durationMinutes,
            @RequestParam(required = false) String description,
            RedirectAttributes redirectAttributes) {
        UserVO user = userService.getUser(authentication.getName());
        com.soldesk.vo.ServiceVO service = new com.soldesk.vo.ServiceVO();
        service.setServiceId(serviceId);
        service.setServiceName(serviceName);
        service.setPrice(price);
        if (durationMinutes != null) {
            service.setDurationMinutes(durationMinutes);
        }
        service.setDescription(description);
        try {
            salonService.updateService(user.getUserId(), service);
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/owner/store";
    }

    @PostMapping("/store/service/{serviceId}/delete")
    public String deleteService(@PathVariable int serviceId, Authentication authentication,
            RedirectAttributes redirectAttributes) {
        UserVO user = userService.getUser(authentication.getName());
        try {
            salonService.deleteService(user.getUserId(), serviceId);
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/owner/store";
    }

    /**
     * 좌표는 화면의 주소 검색이 채워 보내는 hidden 값이라 String 으로 받는다.
     * BigDecimal 로 직접 받으면 좌표가 아직 없는 매장이 보내는 빈 문자열에 400 이 난다.
     */
    @PostMapping("/store/update")
    public String updateSalonInfo(Authentication authentication, HttpSession session,
            @RequestParam String salonName,
            @RequestParam(required = false) String address,
            @RequestParam(required = false) String phoneNumber,
            @RequestParam(required = false) String description,
            @RequestParam(required = false) String latitude,
            @RequestParam(required = false) String longitude,
            RedirectAttributes redirectAttributes) {
        Integer salonId = (Integer) session.getAttribute("selectedSalonId");
        if (salonId == null) {
            redirectAttributes.addFlashAttribute("error", "매장을 먼저 선택해주세요.");
            return "redirect:/owner/store";
        }
        UserVO user = userService.getUser(authentication.getName());
        SalonVO salon = new SalonVO();
        salon.setSalonId(salonId);
        salon.setSalonName(salonName);
        salon.setAddress(address);
        salon.setPhoneNumber(phoneNumber);
        salon.setDescription(description);
        salon.setLatitude(toCoordinate(latitude, LAT_MIN, LAT_MAX));
        salon.setLongitude(toCoordinate(longitude, LNG_MIN, LNG_MAX));
        try {
            salonService.updateSalonInfo(user.getUserId(), salon);
            redirectAttributes.addFlashAttribute("success", "매장 정보가 저장되었습니다.");
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/owner/store";
    }

    /**
     * 화면이 보낸 좌표 문자열을 컬럼에 넣을 값으로 바꾼다.
     *
     * 비었거나(주소를 아직 검색하지 않은 매장), 숫자가 아니거나, 대한민국 밖이면 null 을 준다.
     * 값을 버려도 주소는 그대로 저장된다 — 좌표가 없으면 고객 지도에서 마커만 빠진다.
     */
    private BigDecimal toCoordinate(String raw, BigDecimal min, BigDecimal max) {
        if (raw == null || raw.isBlank()) {
            return null;
        }
        try {
            BigDecimal value = new BigDecimal(raw.trim());
            return (value.compareTo(min) < 0 || value.compareTo(max) > 0) ? null : value;
        } catch (NumberFormatException e) {
            return null;
        }
    }

    // 예약현황판 + 하단 전체목록 화면
    @GetMapping("/reservations")
    public String reservations(@RequestParam(required = false) String date,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size,
            Authentication authentication, HttpSession session, Model model) {
        // 점주 데이터 세팅, 페이징 검증 보정
        fillCommonModel(authentication, model);
        if (page < 1) page = 1;
        if (size <= 0) size = 10;
        
        // 조회 날짜 계산 및 화면 이동용
        // 파라미터 날짜가 없으면 오늘 날짜를 기본값으로
        LocalDate targetDate = (date != null && !date.isBlank()) ? LocalDate.parse(date) : LocalDate.now();
        model.addAttribute("scheduleDate", targetDate.toString());
        model.addAttribute("today", LocalDate.now().toString());
        model.addAttribute("prevDate", targetDate.minusDays(1).toString());
        model.addAttribute("nextDate", targetDate.plusDays(1).toString());
        model.addAttribute("dayLabel", DAY_KO[targetDate.getDayOfWeek().getValue() - 1]);
        // 페이징 정보는 거절 모달의 hidden 값으로도 쓰임.
        // 매장 미선택이라 아래 조회를 통째로 건너뛰어도 이 값은 필요해서 if 밖에 둠
        model.addAttribute("page", page);
        model.addAttribute("size", size);

        // 세션 매장 확인 및 예약, 현황판 DB 조회
        Integer salonId = (Integer) session.getAttribute("selectedSalonId");
        if (salonId != null) {
            UserVO user = userService.getUser(authentication.getName());
            try {
                // 해당 매장 예약 건수
                int totalCount = reservationService.countReservationsForOwner(salonId, user.getUserId());
                model.addAttribute("board", reservationService.getScheduleBoard(salonId, user.getUserId(), targetDate));
                model.addAttribute("reservations",
                        reservationService.getReservationsForOwner(salonId, user.getUserId(), page, size));
                model.addAttribute("totalCount", totalCount);
                model.addAttribute("totalPages", (int) Math.ceil((double) totalCount / size));
            } catch (IllegalArgumentException e) {
                // 서비스의 소유 검증에 걸린 경우 (세션에 남은 selectedSalonId 가 본인 매장이 아님).
                // 여기서 안 잡으면 500
            }
        }
        return "owner/reservations";
    }

    // 예약 거절 및 노쇼 처리
    @PostMapping("/reservations/{reservationId}/reject")
    public String rejectReservation(@PathVariable int reservationId, Authentication authentication,
            @RequestParam String rejectReason, // 거절, 노쇼 사유
            @RequestParam(defaultValue = "rejected") String resolution,
            @RequestParam(required = false) String date,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int size,
            RedirectAttributes redirectAttributes) {
        UserVO user = userService.getUser(authentication.getName());
        try {
            // 상태 변경 + 사유 기록 + (거절이면) 환불까지 서비스에서 한 트랜잭션으로 처리.
            // 본인 매장인지, 지금 처리해도 되는 상태인지 검증도 그쪽에 있음
            reservationService.rejectReservation(reservationId, user.getUserId(), rejectReason, resolution);
            redirectAttributes.addFlashAttribute("success",
                    "no_show".equals(resolution) ? "노쇼로 처리했습니다." : "예약을 거절하고 환불했습니다.");
        } catch (IllegalArgumentException | IllegalStateException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
        }
        // 보고 있던 날짜/페이지를 유지
        // 처리하고 나서 오늘 보드로 튕기지 않게, 보고 있던 날짜/페이지를 그대로 되돌려줌.
        // 위 addFlashAttribute 는 세션에 잠깐 실려 리다이렉트 한 번만 살아있고,
        // 여기 addAttribute 는 ?date=..&page=.. 형태로 URL 에 붙음
        if (date != null && !date.isBlank()) {
            redirectAttributes.addAttribute("date", date);
        }
        redirectAttributes.addAttribute("page", page);
        redirectAttributes.addAttribute("size", size);
        return "redirect:/owner/reservations";
    }

    /** 공지사항 작성. 세션에 선택된 매장(selectedSalonId)이 실제로 이 점주 소유인지 확인한 뒤에만 저장한다. */
    @PostMapping("/store/notices")
    public String createNotice(Authentication authentication, HttpSession session,
            @RequestParam String title,
            @RequestParam String content,
            @RequestParam(required = false) MultipartFile imageFile,
            RedirectAttributes redirectAttributes) throws IOException {
        Integer selectedSalonId = (Integer) session.getAttribute("selectedSalonId");
        if (selectedSalonId == null) {
            redirectAttributes.addFlashAttribute("error", "매장을 먼저 선택해주세요.");
            return "redirect:/owner/store";
        }

        UserVO user = userService.getUser(authentication.getName());
        try {
            salonService.getSalonForOwner(selectedSalonId, user.getUserId());

            SalonNoticeVO notice = new SalonNoticeVO();
            notice.setSalonId(selectedSalonId);
            notice.setTitle(title);
            notice.setContent(content);
            salonNoticeService.create(notice, imageFile);
            redirectAttributes.addFlashAttribute("success", "공지사항이 등록되었습니다.");
        } catch (IllegalArgumentException | IOException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/owner/store";
    }

    @PostMapping("/store/notices/{noticeId}/delete")
    public String deleteNotice(@PathVariable int noticeId, Authentication authentication, HttpSession session,
            RedirectAttributes redirectAttributes) {
        Integer selectedSalonId = (Integer) session.getAttribute("selectedSalonId");
        if (selectedSalonId == null) {
            redirectAttributes.addFlashAttribute("error", "매장을 먼저 선택해주세요.");
            return "redirect:/owner/store";
        }

        UserVO user = userService.getUser(authentication.getName());
        try {
            salonService.getSalonForOwner(selectedSalonId, user.getUserId());
            salonNoticeService.delete(noticeId, selectedSalonId);
            redirectAttributes.addFlashAttribute("success", "공지사항이 삭제되었습니다.");
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/owner/store";
    }

    /** 매장 추가 등록 요청 — 사이드바 매장 선택 모달의 "+ 매장 추가" 카드에서 들어온다 */
    @GetMapping("/salon-request")
    public String salonRequestForm(Authentication authentication, Model model) {
        fillCommonModel(authentication, model);
        return "owner/salon-request";
    }

    @PostMapping("/salon-request")
    public String salonRequestSubmit(Authentication authentication,
            @RequestParam String salonName,
            @RequestParam String salonPhone,
            @RequestParam String message) {
        UserVO user = userService.getUser(authentication.getName());
        ownerRequestService.submitAdditionalSalon(user.getUserId(), salonName, salonPhone, message);
        return "redirect:/owner/salon-request?submitted=true";
    }

    /**
     * 1:1 면담. 방 목록은 사이드바에서 고른 매장(selectedSalonId) 기준이다 —
     * 점주가 매장을 여러 개 가지면 ownerId 로 뽑을 때 매장별 문의가 섞이기 때문.
     * 매장 미선택 상태는 salon_gate_overlay.jsp 가 화면에서 막아주므로 여기선 빈 목록만 넘긴다.
     */
    @GetMapping("/chat")
    public String chat(Authentication authentication,
            @RequestParam(required = false) Integer chatId,
            HttpSession session, Model model) {
        fillCommonModel(authentication, model);

        Integer selectedSalonId = (Integer) session.getAttribute("selectedSalonId");
        List<ChatRoomVO> rooms = (selectedSalonId == null)
                ? List.of()
                : chatService.getSalonRooms(selectedSalonId);
        model.addAttribute("rooms", rooms);

        if (chatId == null && !rooms.isEmpty()) {
            chatId = rooms.get(0).getChatId();
        }
        if (chatId != null) {
            UserVO user = userService.getUser(authentication.getName());
            model.addAttribute("chatId", chatId);
            model.addAttribute("messages", chatService.getMessages(chatId, user.getUserId()));
            CommonController.clearUnreadBadge(rooms, chatId);
        }
        return "owner/chat";
    }

    private void fillCommonModel(Authentication authentication, Model model) {
        UserVO user = userService.getUser(authentication.getName());
        List<SalonVO> salons = salonService.getSalonByOwner(user.getUserId());

        model.addAttribute("user", user);
        model.addAttribute("salons", salons);
    }

    @GetMapping("/staff")
    public String staff(Authentication authentication, HttpSession session, Model model) {
        fillCommonModel(authentication, model);
        Integer salonId = (Integer) session.getAttribute("selectedSalonId");
        if (salonId != null) {
            UserVO user = userService.getUser(authentication.getName());
            List<StylistVO> stylists = staffService.getStylists(salonId, user.getUserId());
            model.addAttribute("stylists", stylists);

            Map<Integer, List<Map<String, Object>>> schedulesByStylist = new HashMap<>();
            for (StylistVO stylist : stylists) {
                schedulesByStylist.put(stylist.getStylistId(),
                        staffService.getScheduleGroups(stylist.getStylistId(), user.getUserId()));
            }
            model.addAttribute("schedulesByStylist", schedulesByStylist);
        }
        return "owner/staff";
    }

    @PostMapping("/staff/register")
    public String registerStylist(Authentication authentication, HttpSession session,
            @RequestParam String stylistName,
            @RequestParam(required = false) String phoneNumber,
            @RequestParam(required = false) String description,
            @RequestParam(required = false) MultipartFile imageFile,
            RedirectAttributes redirectAttributes) {
        Integer salonId = (Integer) session.getAttribute("selectedSalonId");
        if (salonId == null) {
            redirectAttributes.addFlashAttribute("error", "매장을 먼저 선택해주세요.");
            return "redirect:/owner/staff";
        }
        UserVO user = userService.getUser(authentication.getName());
        StylistVO stylist = new StylistVO();
        stylist.setStylistName(stylistName);
        stylist.setPhoneNumber(phoneNumber);
        stylist.setDescription(description);
        try {
            staffService.registerStylist(salonId, user.getUserId(), stylist, imageFile);
        } catch (IllegalArgumentException | IOException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/owner/staff";
    }

    @PostMapping("/staff/{stylistId}/update")
    public String updateStylist(@PathVariable int stylistId, Authentication authentication,
            @RequestParam String stylistName,
            @RequestParam(required = false) String phoneNumber,
            @RequestParam(required = false) String description,
            @RequestParam(required = false) MultipartFile imageFile,
            RedirectAttributes redirectAttributes) {
        UserVO user = userService.getUser(authentication.getName());
        StylistVO stylist = new StylistVO();
        stylist.setStylistId(stylistId);
        stylist.setStylistName(stylistName);
        stylist.setPhoneNumber(phoneNumber);
        stylist.setDescription(description);
        try {
            staffService.updateStylist(user.getUserId(), stylist, imageFile);
        } catch (IllegalArgumentException | IOException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/owner/staff";
    }

    @PostMapping("/staff/{stylistId}/delete")
    public String deleteStylist(@PathVariable int stylistId, Authentication authentication,
            RedirectAttributes redirectAttributes) {
        UserVO user = userService.getUser(authentication.getName());
        try {
            staffService.deleteStylist(stylistId, user.getUserId());
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/owner/staff";
    }

    // ---- 스케줄 ---- 캘린더에서 고른 날짜별 시간을 JSON으로 받는다:
    // [{"date":"2026-07-23","startTime":"10:00","endTime":"19:00","isAvailable":true},
    // ...]
    @PostMapping("/staff/{stylistId}/schedule")
    public String registerSchedules(@PathVariable int stylistId, Authentication authentication,
            @RequestParam String scheduleData,
            RedirectAttributes redirectAttributes) {
        UserVO user = userService.getUser(authentication.getName());
        try {
            List<StylistScheduleVO> schedules = new ObjectMapper().readValue(scheduleData,
                    new TypeReference<List<StylistScheduleVO>>() {
                    });
            String skippedMessage = staffService.registerSchedules(user.getUserId(), stylistId, schedules);
            if (skippedMessage != null) {
                redirectAttributes.addFlashAttribute("error", skippedMessage);
            }
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
        } catch (JsonProcessingException e) {
            redirectAttributes.addFlashAttribute("error", "스케줄 데이터 형식이 올바르지 않습니다.");
        }
        return "redirect:/owner/staff";
    }

    // 화면에 묶여 보이는 연속 날짜 그룹을 통째로 초기화 — 그룹에 속한 schedule_id 전부를 hidden input들로 받는다
    @PostMapping("/staff/schedule/delete")
    public String deleteSchedules(@RequestParam List<Integer> scheduleIds, Authentication authentication,
            RedirectAttributes redirectAttributes) {
        UserVO user = userService.getUser(authentication.getName());
        try {
            staffService.deleteSchedules(scheduleIds, user.getUserId());
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/owner/staff";
    }
}
