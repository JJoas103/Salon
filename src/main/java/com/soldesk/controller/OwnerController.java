package com.soldesk.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import java.io.IOException;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import org.springframework.web.multipart.MultipartFile;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.soldesk.service.ChatService;
import com.soldesk.service.SalonService;
import com.soldesk.service.StaffService;
import com.soldesk.service.UserService;
import com.soldesk.vo.ChatRoomVO;
import com.soldesk.vo.SalonVO;
import com.soldesk.vo.StylistScheduleVO;
import com.soldesk.vo.StylistVO;
import com.soldesk.vo.UserVO;

@Controller
@RequestMapping("/owner")
public class OwnerController {

    @Autowired
    private UserService userService;

    @Autowired
    private SalonService salonService;

    @Autowired
    private StaffService staffService;

    @Autowired
    private ChatService chatService;

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
        Integer salonId = (Integer) session.getAttribute("selectedSalonId");
        if (salonId != null) {
            UserVO user = userService.getUser(authentication.getName());
            try {
                model.addAttribute("salon", salonService.getSalonForOwner(salonId, user.getUserId()));
            } catch (IllegalArgumentException e) {
                // 세션의 selectedSalonId가 본인 소유가 아니면 빈 폼으로 둔다
            }
        }
        return "owner/store";
    }

    @PostMapping("/store/update")
    public String updateSalonInfo(Authentication authentication, HttpSession session,
            @RequestParam String salonName,
            @RequestParam(required = false) String address,
            @RequestParam(required = false) String phoneNumber,
            @RequestParam(required = false) String description,
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
        try {
            salonService.updateSalonInfo(user.getUserId(), salon);
            redirectAttributes.addFlashAttribute("success", "매장 정보가 저장되었습니다.");
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/owner/store";
    }

    @GetMapping("/reservations")
    public String reservations(Authentication authentication, Model model) {
        fillCommonModel(authentication, model);
        return "owner/reservations";
    }

    @GetMapping("/events")
    public String events(Authentication authentication, Model model) {
        fillCommonModel(authentication, model);
        return "owner/events";
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
