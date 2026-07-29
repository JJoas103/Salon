package com.soldesk.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import com.soldesk.service.UserService;

@Controller
@RequestMapping("/admin")
public class AdminController {

    @Autowired
    private UserService userService;

    @GetMapping("/home")
    public String home() {
        return "redirect:/admin/mypage";
    }

    @GetMapping("/mypage")
    public String mypage(Authentication authentication, Model model){
        model.addAttribute("user", userService.getUser(authentication.getName()));
        return "admin/mypage";
    }

    @GetMapping("/salons")
    public String salons() {
        return "admin/salons";
    }

    @GetMapping("/members")
    public String members() {
        return "admin/members";
    }

    @GetMapping("/community")
    public String community() {
        return "admin/community";
    }

    @GetMapping("/banners")
    public String banners() {
        return "redirect:/admin/advertisements";
    }
}
