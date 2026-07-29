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
        return "redirect:/admin/salons";
    }

    @GetMapping("/salons")
    public String salons(Authentication authentication, Model model) {
        model.addAttribute("user", userService.getUser(authentication.getName()));
        return "admin/salons";
    }

    @GetMapping("/members")
    public String members(Authentication authentication, Model model) {
        model.addAttribute("user", userService.getUser(authentication.getName()));
        return "admin/members";
    }

    @GetMapping("/community")
    public String community(Authentication authentication, Model model) {
        model.addAttribute("user", userService.getUser(authentication.getName()));
        return "admin/community";
    }

    @GetMapping("/banners")
    public String banners(Authentication authentication, Model model) {
        model.addAttribute("user", userService.getUser(authentication.getName()));
        return "admin/banners";
    }
}
