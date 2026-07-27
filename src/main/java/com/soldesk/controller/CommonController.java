package com.soldesk.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import com.soldesk.service.UserService;
import com.soldesk.vo.UserVO;

@Controller
@RequestMapping("/common")
public class CommonController {

    @Autowired
    private UserService userService;

    @GetMapping("/home")
    public String home() {
        return "common/home";
    }


    @GetMapping("/mypage")
    public String mypage(Authentication authentication, Model model){

    UserVO user = userService.getUser(authentication.getName());

    model.addAttribute("user", user);

    return "common/mypage";
    }
}