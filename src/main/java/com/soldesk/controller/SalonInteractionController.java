package com.soldesk.controller;

import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import com.soldesk.service.ReviewService;
import com.soldesk.service.SalonService;
import com.soldesk.service.UserService;
import com.soldesk.service.WishlistService;
import com.soldesk.vo.SalonVO;
import com.soldesk.vo.UserVO;

@Controller
@RequestMapping("/common")
public class SalonInteractionController {
    @Autowired private ReviewService reviewService;
    @Autowired private WishlistService wishlistService;
    @Autowired private SalonService salonService;
    @Autowired private UserService userService;

    @GetMapping("/salons/{salonId}/reviews")
    public String reviews(@PathVariable int salonId, Authentication authentication, Model model) {
        SalonVO salon = salonService.getSalon(salonId);
        if (salon == null) return "redirect:/common/home";
        UserVO user = currentUser(authentication);
        model.addAttribute("salon", salon);
        model.addAttribute("reviews", reviewService.getReviews(salonId));
        model.addAttribute("reviewCount", reviewService.countReviews(salonId));
        model.addAttribute("wishlisted", user != null && wishlistService.isWishlisted(user.getUserId(), salonId));
        if (user != null) {
            model.addAttribute("reviewableReservations",
                reviewService.getReviewableReservations(user.getUserId(), salonId));
        }
        return "common/reviews";
    }

    @PostMapping("/salons/{salonId}/reviews")
    public String writeReview(@PathVariable int salonId, @RequestParam int reservationId,
                              @RequestParam int rating, @RequestParam String comment,
                              Authentication authentication, RedirectAttributes redirectAttributes) {
        UserVO user = requireUser(authentication);
        try {
            reviewService.write(user.getUserId(), salonId, reservationId, rating, comment);
            redirectAttributes.addFlashAttribute("success", "리뷰가 등록되었습니다.");
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/common/salons/" + salonId + "/reviews";
    }

    @PostMapping("/salons/{salonId}/wishlist")
    @ResponseBody
    public Map<String, Object> toggleWishlist(@PathVariable int salonId,
                                              Authentication authentication) {
        UserVO user = requireUser(authentication);
        if (salonService.getSalon(salonId) == null) {
            throw new IllegalArgumentException("존재하지 않는 헤어샵입니다.");
        }
        boolean added = wishlistService.toggle(user.getUserId(), salonId);
        return Map.of(
            "success", true,
            "wishlisted", added,
            "wishlistCount", wishlistService.count(user.getUserId())
        );
    }

    @GetMapping("/wishlists")
    public String wishlists(Authentication authentication, Model model) {
        UserVO user = requireUser(authentication);
        model.addAttribute("salons", wishlistService.getSalons(user.getUserId()));
        return "common/wishlists";
    }

    @GetMapping("/my-reviews")
    public String myReviews(Authentication authentication, Model model) {
        UserVO user = requireUser(authentication);
        model.addAttribute("reviews", reviewService.getUserReviews(user.getUserId()));
        model.addAttribute("reviewCount", reviewService.countUserReviews(user.getUserId()));
        return "common/my-reviews";
    }

    private UserVO currentUser(Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated()
                || "anonymousUser".equals(authentication.getName())) return null;
        return userService.getUser(authentication.getName());
    }
    private UserVO requireUser(Authentication authentication) {
        UserVO user = currentUser(authentication);
        if (user == null) throw new IllegalStateException("로그인이 필요합니다.");
        return user;
    }
}
