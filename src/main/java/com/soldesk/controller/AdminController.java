package com.soldesk.controller;

import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
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
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.soldesk.service.OwnerRequestService;
import com.soldesk.service.PostService;
import com.soldesk.service.SalonService;
import com.soldesk.service.UserService;
import com.soldesk.vo.OwnerRequestVO;
import com.soldesk.vo.PostVO;
import com.soldesk.vo.SalonVO;
import com.soldesk.vo.UserSanctionVO;
import com.soldesk.vo.UserVO;

@Controller
@RequestMapping("/admin")
public class AdminController {

    @Autowired
    private UserService userService;

    @Autowired
    private OwnerRequestService ownerRequestService;

    @Autowired
    private SalonService salonService;

    @Autowired
    private PostService postService;

    private int currentAdminId(Authentication authentication){
        return userService.getUser(authentication.getName()).getUserId();
    }

    @GetMapping("/home")
    public String home() {
        return "redirect:/admin/salons";
    }

    @GetMapping("/salons")
    public String salons(@RequestParam(required = false) String keyword,
                          @RequestParam(required = false) String status,
                          @RequestParam(defaultValue = "1") int page,
                          @RequestParam(defaultValue = "10") int size,
                          Authentication authentication,
                          Model model) {
        if (page < 1) page = 1;
        if (size <= 0) size = 10;

        model.addAttribute("user", userService.getUser(authentication.getName()));
        model.addAttribute("keyword", keyword);
        model.addAttribute("status", status);
        model.addAttribute("page", page);
        model.addAttribute("size", size);
        model.addAttribute("activeSalonCount", salonService.countActiveSalons());
        model.addAttribute("newThisMonthCount", salonService.countNewSalonsThisMonth());
        model.addAttribute("activeReservationCount", salonService.countActiveReservations());

        // 탭 배지 숫자는 어느 탭을 보고 있든 항상 필요하다
        model.addAttribute("preparingSalonCount", salonService.getPreparingSalons().size());
        model.addAttribute("additionalSalonRequestCount", ownerRequestService.countPendingAdditionalSalon());

        if ("preparing".equals(status)) {
            // 심사 대기 큐 — 2차 승인 전이라 보통 몇 건 안 돼서 검색/페이지네이션 없이 전체를 보여준다
            List<SalonVO> preparing = salonService.getPreparingSalons();
            model.addAttribute("salons", preparing);
            // 체크리스트(주소/영업시간/시술메뉴)는 매장마다 직접 조회 — 대기 큐가 커봐야 수십 건이라 N+1이어도 무방
            Map<Integer, Boolean> hasAddress = new HashMap<>();
            Map<Integer, Integer> hoursCount = new HashMap<>();
            Map<Integer, Integer> serviceCount = new HashMap<>();
            for (SalonVO salon : preparing) {
                hasAddress.put(salon.getSalonId(), salon.getAddress() != null && !salon.getAddress().isBlank());
                hoursCount.put(salon.getSalonId(), salonService.getOperatingHours(salon.getSalonId()).size());
                serviceCount.put(salon.getSalonId(), salonService.getServices(salon.getSalonId()).size());
            }
            model.addAttribute("hasAddress", hasAddress);
            model.addAttribute("hoursCount", hoursCount);
            model.addAttribute("serviceCount", serviceCount);
            model.addAttribute("totalCount", preparing.size());
            model.addAttribute("totalPages", 1);
        } else if ("requests".equals(status)) {
            // 매장 추가 요청 큐 — 회원관리에서 옮겨온 승인/반려 처리
            List<OwnerRequestVO> requests = ownerRequestService.getPendingAdditionalSalonRequests();
            model.addAttribute("additionalSalonRequests", requests);
            model.addAttribute("totalCount", requests.size());
            model.addAttribute("totalPages", 1);
        } else {
            int totalCount = salonService.countSalonsForAdmin(keyword, status);
            model.addAttribute("salons", salonService.getSalonsForAdmin(keyword, status, page, size));
            model.addAttribute("totalCount", totalCount);
            model.addAttribute("totalPages", (int) Math.ceil((double) totalCount / size));
        }
        return "admin/salons";
    }

    @PostMapping("/salons/{salonId}/activate")
    public String activateSalon(@PathVariable int salonId, RedirectAttributes redirectAttributes) {
        try {
            salonService.activateSalon(salonId);
            redirectAttributes.addFlashAttribute("success", "매장을 승인했습니다. 이제 손님에게 노출됩니다.");
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/admin/salons?status=preparing";
    }

    @PostMapping("/salons/{salonId}/close")
    public String closeSalon(@PathVariable int salonId, RedirectAttributes redirectAttributes) {
        try {
            salonService.closeSalon(salonId);
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/admin/salons";
    }

    @PostMapping("/salons/{salonId}/reopen")
    public String reopenSalon(@PathVariable int salonId, RedirectAttributes redirectAttributes) {
        try {
            salonService.reopenSalon(salonId);
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/admin/salons?status=closed";
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
        model.addAttribute("pendingOwnerRequestCount", ownerRequestService.countPendingPromotion());
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
        model.addAttribute("reportedPosts", postService.getBlindedPosts());
        model.addAttribute("reportedComments", postService.getReportedComments());

        List<UserVO> sanctionedUsers = userService.getSanctionedUsers();
        Map<Integer, UserSanctionVO> latestSanctions = new HashMap<>();
        Map<Integer, String> suspendedUntilText = new HashMap<>();
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
        for (UserVO u : sanctionedUsers) {
            List<UserSanctionVO> history = userService.getSanctionHistory(u.getUserId());
            if (!history.isEmpty()) {
                latestSanctions.put(u.getUserId(), history.get(0));
            }
            if (u.getSuspendedUntil() != null) {
                suspendedUntilText.put(u.getUserId(), u.getSuspendedUntil().format(fmt));
            }
        }
        model.addAttribute("sanctionedUsers", sanctionedUsers);
        model.addAttribute("latestSanctions", latestSanctions);
        model.addAttribute("suspendedUntilText", suspendedUntilText);
        return "admin/community";
    }

    // 신고된 게시글 관리자 전용 상세보기 (블라인드 상태 무시하고 전체 내용 확인)
    @GetMapping("/community/{postId}")
    public String reportedPostDetail(@PathVariable int postId, Authentication authentication, Model model) {
        model.addAttribute("user", userService.getUser(authentication.getName()));
        PostVO post = postService.getPostForAdmin(postId);
        model.addAttribute("post", post);
        model.addAttribute("comments", postService.getComments(postId));
        model.addAttribute("otherReasonDetails", postService.getOtherReasonDetails(postId));
        if (post != null) {
            model.addAttribute("sanctionHistory", userService.getSanctionHistory(post.getUserId()));
            model.addAttribute("totalReportsOnOtherPosts", postService.sumReportCountByAuthor(post.getUserId()));
        }
        return "admin/community_detail";
    }

    // 신고 누적으로 블라인드된 게시글 삭제 승인 + 작성자 제재
    @PostMapping("/community/{postId}/approve-delete")
    public String approveDelete(@PathVariable int postId, @RequestParam String sanctionType,
                                 @RequestParam(required = false) String adminReason) {
        postService.approveDeleteWithSanction(postId, sanctionType, adminReason);
        return "redirect:/admin/community";
    }

    // 신고 기각 (블라인드 해제 + 신고 기록 초기화)
    @PostMapping("/community/{postId}/dismiss")
    public String dismiss(@PathVariable int postId) {
        postService.dismissReport(postId);
        return "redirect:/admin/community";
    }

    // 신고 누적된 댓글 삭제 승인 + 작성자 제재
    @PostMapping("/community/comment/{commentId}/approve-delete")
    public String approveDeleteComment(@PathVariable int commentId, @RequestParam String sanctionType,
                                        @RequestParam(required = false) String adminReason) {
        postService.approveDeleteCommentWithSanction(commentId, sanctionType, adminReason);
        return "redirect:/admin/community";
    }

    // 댓글 신고 기각 (신고 기록만 초기화, 댓글은 그대로 유지)
    @PostMapping("/community/comment/{commentId}/dismiss")
    public String dismissComment(@PathVariable int commentId) {
        postService.dismissCommentReport(commentId);
        return "redirect:/admin/community";
    }

    // 제재 해제 (status active로 복구, suspended_until 초기화)
    @PostMapping("/community/user/{userId}/lift-sanction")
    public String liftSanction(@PathVariable int userId) {
        userService.liftSanction(userId);
        return "redirect:/admin/community";
    }

    @GetMapping("/banners")
    public String banners() {
        return "redirect:/admin/advertisements";
    }

    // 회원관리 "점주 승격 요청" 탭 전용 — 매장 추가 요청은 매장관리(/admin/salons?status=requests)에서 처리한다.
    @PostMapping("/owner-requests/{id}/approve")
    public String approveOwnerRequest(@PathVariable int id, Authentication authentication,
            RedirectAttributes redirectAttributes){
        try {
            ownerRequestService.approvePromotionRequest(id, currentAdminId(authentication));
            // approve() 내부에서: 1) Users.user_type='owner' 2) OwnerRequests.status='approved'
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/admin/members";
    }

    @PostMapping("/owner-requests/{id}/reject")
    public String rejectOwnerRequest(@PathVariable int id, Authentication authentication,
            RedirectAttributes redirectAttributes){
        try {
            ownerRequestService.rejectPromotionRequest(id, currentAdminId(authentication));
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/admin/members";
    }

    // 매장관리 "매장 추가 요청" 탭 전용 — 회원관리에서 이쪽으로 옮겨왔다.
    @PostMapping("/salons/requests/{id}/approve")
    public String approveSalonRequest(@PathVariable int id, Authentication authentication,
            RedirectAttributes redirectAttributes){
        try {
            ownerRequestService.approveAdditionalSalonRequest(id, currentAdminId(authentication));
            redirectAttributes.addFlashAttribute("success", "매장 추가 요청을 승인했습니다.");
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/admin/salons?status=requests";
    }

    @PostMapping("/salons/requests/{id}/reject")
    public String rejectSalonRequest(@PathVariable int id, Authentication authentication,
            RedirectAttributes redirectAttributes){
        try {
            ownerRequestService.rejectAdditionalSalonRequest(id, currentAdminId(authentication));
            redirectAttributes.addFlashAttribute("success", "매장 추가 요청을 반려했습니다.");
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/admin/salons?status=requests";
    }
}
