package com.soldesk.controller;

import java.io.IOException;
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
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import com.soldesk.service.ReviewService;
import com.soldesk.service.SalonService;
import com.soldesk.service.UserService;
import com.soldesk.service.WishlistService;
import com.soldesk.vo.SalonVO;
import com.soldesk.vo.UserVO;

/** 매장 리뷰 + 찜(위시리스트).
 *  이 컨트롤러의 모든 경로는 SecurityConfig 의 anyRequest().authenticated() 에 걸려
 *  로그인한 사용자만 도달한다 — 따라서 여기서 authentication 을 다시 검사하지 않는다. */
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
        UserVO user = userService.getUser(authentication.getName());
        model.addAttribute("salon", salon);
        model.addAttribute("reviews", reviewService.getReviews(salonId));
        model.addAttribute("reviewCount", reviewService.countReviews(salonId));
        model.addAttribute("wishlisted", wishlistService.isWishlisted(user.getUserId(), salonId));
        model.addAttribute("reviewableReservations",
            reviewService.getReviewableReservations(user.getUserId(), salonId));
        model.addAttribute("currentUserId", user.getUserId());
        return "common/reviews";
    }

    @PostMapping("/salons/{salonId}/reviews")
    public String writeReview(@PathVariable int salonId, @RequestParam int reservationId,
                              @RequestParam int rating, @RequestParam String comment,
                              @RequestParam(required = false) MultipartFile imageFile,
                              @RequestParam(required = false) MultipartFile imageFile2,
                              Authentication authentication, RedirectAttributes redirectAttributes)
            throws IOException {
        UserVO user = userService.getUser(authentication.getName());
        try {
            reviewService.write(user.getUserId(), salonId, reservationId, rating, comment, imageFile, imageFile2);
            redirectAttributes.addFlashAttribute("success", "리뷰가 등록되었습니다.");
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/common/salons/" + salonId + "/reviews";
    }

    @PostMapping("/salons/{salonId}/reviews/{reviewId}/update")
    public String updateReview(@PathVariable int salonId, @PathVariable int reviewId,
                               @RequestParam int rating, @RequestParam String comment,
                               @RequestParam(required = false) MultipartFile imageFile,
                               @RequestParam(required = false) MultipartFile imageFile2,
                               Authentication authentication, RedirectAttributes redirectAttributes)
            throws IOException {
        UserVO user = userService.getUser(authentication.getName());
        try {
            reviewService.update(reviewId, user.getUserId(), rating, comment, imageFile, imageFile2);
            redirectAttributes.addFlashAttribute("success", "리뷰가 수정되었습니다.");
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/common/salons/" + salonId + "/reviews";
    }

    @PostMapping("/salons/{salonId}/reviews/{reviewId}/ajax")
    @ResponseBody
    public Map<String, Object> updateReviewAjax(@PathVariable int salonId, @PathVariable int reviewId,
            @RequestParam int rating, @RequestParam String comment,
            @RequestParam(required = false) MultipartFile imageFile,
            @RequestParam(required = false) MultipartFile imageFile2,
            Authentication authentication) throws IOException {
        UserVO user = userService.getUser(authentication.getName());
        try {
            reviewService.update(reviewId, user.getUserId(), rating, comment, imageFile, imageFile2);
            return Map.of("success", true);
        } catch (IllegalArgumentException e) {
            return Map.of("success", false, "error", e.getMessage());
        }
    }

    @GetMapping("/salons/{salonId}/reviews/data")
    @ResponseBody
    public Map<String, Object> reviewData(@PathVariable int salonId, Authentication authentication) {
        SalonVO salon = salonService.getSalon(salonId);
        UserVO user = userService.getUser(authentication.getName());
        return Map.of(
            "reviews", reviewService.getReviews(salonId),
            "reviewCount", reviewService.countReviews(salonId),
            "averageRating", salon != null && salon.getAverageRating() != null
                ? salon.getAverageRating() : java.math.BigDecimal.ZERO,
            "reviewableReservations", reviewService.getReviewableReservations(user.getUserId(), salonId)
        );
    }

    @PostMapping("/salons/{salonId}/reviews/ajax")
    @ResponseBody
    public Map<String, Object> writeReviewAjax(@PathVariable int salonId,
            @RequestParam int reservationId, @RequestParam int rating, @RequestParam String comment,
            @RequestParam(required = false) MultipartFile imageFile,
            @RequestParam(required = false) MultipartFile imageFile2,
            Authentication authentication) throws IOException {
        UserVO user = userService.getUser(authentication.getName());
        try {
            reviewService.write(user.getUserId(), salonId, reservationId, rating, comment, imageFile, imageFile2);
            return Map.of("success", true);
        } catch (IllegalArgumentException e) {
            return Map.of("success", false, "error", e.getMessage());
        }
    }

    @PostMapping("/salons/{salonId}/wishlist")
    @ResponseBody
    public Map<String, Object> toggleWishlist(@PathVariable int salonId,
                                              Authentication authentication) {
        UserVO user = userService.getUser(authentication.getName());
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
        UserVO user = userService.getUser(authentication.getName());
        model.addAttribute("salons", wishlistService.getSalons(user.getUserId()));
        return "common/wishlists";
    }

    @GetMapping("/my-reviews")
    public String myReviews(Authentication authentication, Model model) {
        UserVO user = userService.getUser(authentication.getName());
        model.addAttribute("reviews", reviewService.getUserReviews(user.getUserId()));
        model.addAttribute("reviewCount", reviewService.countUserReviews(user.getUserId()));
        return "common/my-reviews";
    }
}
