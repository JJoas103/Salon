package com.soldesk.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/admin")
public class AdminController {

    @GetMapping("/home")
    public String home() {
        return "redirect:/admin/salons";
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
        return "admin/banners";
    }
}
