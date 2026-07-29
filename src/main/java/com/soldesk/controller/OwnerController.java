package com.soldesk.controller;

import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.soldesk.service.SalonService;
import com.soldesk.service.UserService;
import com.soldesk.vo.SalonVO;
import com.soldesk.vo.UserVO;

@Controller
@RequestMapping("/owner")
public class OwnerController {

    @Autowired
    private UserService userService;

    @Autowired
    private SalonService salonService;

    // 점주 전용 홈 대시보드는 아직 없어서, 로그인 직후 착지할 곳으로 매장정보 관리를 사용
    @GetMapping("/home")
    public String home(){
        return "redirect:/owner/store";
    }

    /** 사이드바의 "매장 선택" 모달에서 카드 선택 시 호출 — 세션에 선택한 매장을 기억해둔다 */
    @GetMapping("/select-salon")
    public String selectSalon(@RequestParam int salonId, HttpSession session, HttpServletRequest request){
        session.setAttribute("selectedSalonId", salonId);
        String referer = request.getHeader("Referer");
        return "redirect:" + (referer != null ? referer : "/owner/store");
    }

    // 아래 5개는 아직 정적 목업 내용을 그대로 보여주는 자리표시 라우트 — 추후 각자 실데이터로 구현 예정.
    // user/salons는 헤더의 내정보 모달과 사이드바의 매장 선택 모달에 공통으로 필요해서 매번 채워준다.
    @GetMapping("/store")
    public String store(Authentication authentication, Model model){
        fillCommonModel(authentication, model);
        return "owner/store";
    }

    @GetMapping("/staff")
    public String staff(Authentication authentication, Model model){
        fillCommonModel(authentication, model);
        return "owner/staff";
    }

    @GetMapping("/reservations")
    public String reservations(Authentication authentication, Model model){
        fillCommonModel(authentication, model);
        return "owner/reservations";
    }

    @GetMapping("/events")
    public String events(Authentication authentication, Model model){
        fillCommonModel(authentication, model);
        return "owner/events";
    }

    @GetMapping("/chat")
    public String chat(Authentication authentication, Model model){
        fillCommonModel(authentication, model);
        return "owner/chat";
    }

    private void fillCommonModel(Authentication authentication, Model model){
        UserVO user = userService.getUser(authentication.getName());
        List<SalonVO> salons = salonService.getSalonByOwner(user.getUserId());

        model.addAttribute("user", user);
        model.addAttribute("salons", salons);
    }
}
