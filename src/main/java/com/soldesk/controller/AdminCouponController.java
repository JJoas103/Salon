package com.soldesk.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.soldesk.service.CouponService;
import com.soldesk.service.SalonService;
import com.soldesk.service.UserService;
import com.soldesk.vo.UserVO;
import com.soldesk.vo.coupon.CouponVO;

/**
 * 관리자 쿠폰 관리. 광고 관리(AdminAdvertisementController)와 같은 구조다.
 *
 * 권한은 SecurityConfig 의 /admin/** hasRole('ADMIN') 이 이미 막고 있어
 * 여기서 따로 확인하지 않는다.
 */
@Controller
@RequestMapping("/admin/coupons")
public class AdminCouponController {

    @Autowired
    private CouponService couponService;

    @Autowired
    private UserService userService;

    @Autowired
    private SalonService salonService;

    @GetMapping
    public String list(Model model) {
        model.addAttribute("coupons", couponService.getAllCoupons());
        return "admin/coupons/list";
    }

    @GetMapping("/new")
    public String createForm(Model model) {
        if (!model.containsAttribute("coupon")) {
            CouponVO coupon = new CouponVO();
            coupon.setDiscountType("percent");
            coupon.setIssueType("admin");
            coupon.setIsActive(true);
            model.addAttribute("coupon", coupon);
        }
        model.addAttribute("salons", salonService.getSalons());
        return "admin/coupons/form";
    }

    @PostMapping
    public String create(@ModelAttribute("coupon") CouponVO coupon,
                         RedirectAttributes redirectAttributes) {
        try {
            couponService.createCoupon(coupon);
        } catch (RuntimeException e) {
            // 코드 중복(UNIQUE 위반)이 대부분이다. 원문 대신 무엇을 고쳐야 하는지 알려준다.
            redirectAttributes.addFlashAttribute("errorMessage",
                    "쿠폰을 등록하지 못했습니다. 쿠폰 코드가 이미 사용 중인지 확인해 주세요.");
            return "redirect:/admin/coupons/new";
        }
        redirectAttributes.addFlashAttribute("message", "쿠폰이 등록되었습니다.");
        return "redirect:/admin/coupons";
    }

    @PostMapping("/{couponId}/toggle")
    public String toggle(@PathVariable int couponId, RedirectAttributes redirectAttributes) {
        couponService.toggleActive(couponId);
        redirectAttributes.addFlashAttribute("message", "쿠폰 상태를 변경했습니다.");
        return "redirect:/admin/coupons";
    }

    /** 지정 발급. 회원은 이메일로 찾는다. */
    @PostMapping("/{couponId}/issue")
    public String issue(@PathVariable int couponId,
                        @RequestParam String email,
                        RedirectAttributes redirectAttributes) {

        UserVO user = userService.getUser(email.trim());
        if (user == null) {
            redirectAttributes.addFlashAttribute("errorMessage",
                    "해당 이메일의 회원을 찾을 수 없습니다: " + email);
            return "redirect:/admin/coupons";
        }

        try {
            couponService.issueTo(user.getUserId(), couponId);
        } catch (IllegalArgumentException e) {
            // 서비스가 사유를 갈라 던져준다 (이미 보유 / 중지·기간 밖)
            redirectAttributes.addFlashAttribute("errorMessage", e.getMessage());
            return "redirect:/admin/coupons";
        }

        redirectAttributes.addFlashAttribute("message",
                user.getUserName() + "(" + email + ") 님에게 쿠폰을 발급했습니다.");
        return "redirect:/admin/coupons";
    }
}
