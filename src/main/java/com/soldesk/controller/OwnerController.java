package com.soldesk.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

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

    // 점주 전용 홈 대시보드는 아직 없어서, 로그인 직후 착지할 곳으로 마이페이지를 사용
    @GetMapping("/home")
    public String home(){
        return "redirect:/owner/mypage";
    }

    @GetMapping("/mypage")
    public String mypage(Authentication authentication, Model model){
        UserVO user = userService.getUser(authentication.getName());
        SalonVO salon = salonService.getSalonByOwner(user.getUserId());

        model.addAttribute("user", user);
        model.addAttribute("salon", salon);

        return "owner/mypage";
    }

    // 아래 4개는 아직 정적 목업 내용을 그대로 보여주는 자리표시 라우트 — 추후 각자 실데이터로 구현 예정
    @GetMapping("/store")
    public String store(){
        return "owner/store";
    }

    @GetMapping("/staff")
    public String staff(){
        return "owner/staff";
    }

    @GetMapping("/reservations")
    public String reservations(){
        return "owner/reservations";
    }

    @GetMapping("/events")
    public String events(){
        return "owner/events";
    }

    @GetMapping("/chat")
    public String chat(){
        return "owner/chat";
    }
}
