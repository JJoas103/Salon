package com.soldesk.controller;

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

import com.soldesk.service.OwnerRequestService;
import com.soldesk.service.UserService;

@Controller
@RequestMapping("/admin")
public class AdminController {

    @Autowired
    private UserService userService;

    @Autowired
    private OwnerRequestService ownerRequestService;

    private int currentAdminId(Authentication authentication){
        return userService.getUser(authentication.getName()).getUserId();
    }

    @GetMapping("/home")
    public String home() {
        return "redirect:/admin/salons";
    }

    @GetMapping("/mypage")
    public String mypage(Authentication authentication, Model model){
        model.addAttribute("user", userService.getUser(authentication.getName()));
        return "admin/mypage";
    }

    @GetMapping("/salons")
    public String salons(Authentication authentication, Model model) {
        model.addAttribute("user", userService.getUser(authentication.getName()));
        return "admin/salons";
    }

    @GetMapping("/members")
    public String members(@RequestParam(required = false) String keyword,
                           @RequestParam(required = false) String userType,
                           @RequestParam(required = false) String status,
                           @RequestParam(defaultValue = "1") int page,
                           @RequestParam(defaultValue = "10") int size,
                           Authentication authentication,
                           Model model) {
        if (page < 1) page = 1;
        if (size <= 0) size = 10;

        int totalCount = userService.countMembers(keyword, userType, status);
        int totalPages = (int) Math.ceil((double) totalCount / size);

        model.addAttribute("user", userService.getUser(authentication.getName()));
        model.addAttribute("members", userService.getMembers(keyword, userType, status, page, size));
        model.addAttribute("keyword", keyword);
        model.addAttribute("userType", userType);
        model.addAttribute("status", status);
        model.addAttribute("page", page);
        model.addAttribute("size", size);
        model.addAttribute("totalCount", totalCount);
        model.addAttribute("totalPages", totalPages);
        model.addAttribute("activeCount", userService.countActiveMembers());
        model.addAttribute("newThisMonthCount", userService.countNewMembersThisMonth());
        model.addAttribute("deletedCount", userService.countDeletedMembers());
        return "admin/members";
    }

    @PostMapping("/members/{userId}/withdraw")
    public String withdrawMember(@PathVariable int userId, RedirectAttributes redirectAttributes) {
        try {
            userService.withdrawMember(userId);
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/admin/members";
    }

    @PostMapping("/members/{userId}/demote")
    public String demoteMember(@PathVariable int userId) {
        userService.demoteToCustomer(userId);
        return "redirect:/admin/members";
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

    @PostMapping("/owner-requests/{id}/approve")
    public String approveOwnerRequest(@PathVariable int id, Authentication authentication){
        ownerRequestService.approve(id, currentAdminId(authentication));
        // approve() 내부에서: 1) Users.user_type='owner' 2) OwnerRequests.status='approved'
        return "redirect:/admin/members";
    }

    @PostMapping("/owner-requests/{id}/reject")
    public String rejectOwnerRequest(@PathVariable int id, Authentication authentication){
        ownerRequestService.reject(id, currentAdminId(authentication));
        return "redirect:/admin/members";
    }
}
