package com.soldesk.controller;

import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import com.soldesk.service.PostService;
import com.soldesk.service.UserService;
import com.soldesk.vo.PostVO;
import com.soldesk.vo.UserSanctionVO;
import com.soldesk.vo.UserVO;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
@RequestMapping("/admin")
public class AdminController {

    @Autowired
    private PostService postService;

    @Autowired
    private UserService userService;

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
    public String community(Model model) {
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
    public String reportedPostDetail(@PathVariable int postId, Model model) {
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
        return "admin/banners";
    }
}
