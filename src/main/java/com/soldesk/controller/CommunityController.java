package com.soldesk.controller;

import com.soldesk.service.PostService;
import com.soldesk.service.UserService;
import com.soldesk.vo.CommentVO;
import com.soldesk.vo.PostVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.io.IOException;
import java.time.format.DateTimeFormatter;
import java.util.List;

import com.soldesk.vo.UserSanctionVO;

@Controller
@RequestMapping("/common/community")
public class CommunityController {

    @Autowired
    private PostService postService;

    @Autowired
    private UserService userService;

    // 로그인한 사용자의 user_id 조회
    private int currentUserId() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return userService.getUser(email).getUserId();
    }

    // 로그인한 사용자면 user_id, 비로그인이면 null
    private Integer currentUserIdOrNull() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || auth instanceof AnonymousAuthenticationToken) {
            return null;
        }
        return userService.getUser(auth.getName()).getUserId();
    }

    // 제재당한 유저가 커뮤니티 접근 시도 시 안내 페이지 (SecurityConfig의 accessDeniedHandler에서 리다이렉트됨)
    @GetMapping("/suspended")
    public String suspended(Model model) {
        Integer currentUserId = currentUserIdOrNull();
        if (currentUserId == null) {
            return "redirect:/common/community";
        }
        List<UserSanctionVO> history = userService.getSanctionHistory(currentUserId);
        if (!history.isEmpty()) {
            UserSanctionVO latest = history.get(0);
            model.addAttribute("sanctionType", latest.getSanctionType());
            if (latest.getSuspendedUntil() != null) {
                model.addAttribute("suspendedUntilText",
                        latest.getSuspendedUntil().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")));
            }
        }
        return "common/community/suspended";
    }

    // 게시글 목록 (카테고리 필터 + 검색)
    @GetMapping
    public String list(@RequestParam(required = false, defaultValue = "") String category,
                       @RequestParam(required = false, defaultValue = "") String keyword,
                       @RequestParam(required = false, defaultValue = "title_content") String searchType,
                       @RequestParam(required = false, defaultValue = "latest") String sort,
                       @RequestParam(required = false, defaultValue = "1") int page,
                       Model model) {
        int size = 10;
        List<PostVO> posts;
        int totalCount;
        if (!keyword.trim().isEmpty()) {
            posts = postService.searchPosts(searchType, keyword, sort, page, size);
            totalCount = postService.getSearchCount(searchType, keyword);
        } else {
            posts = postService.getPostList(category, sort, page, size);
            totalCount = postService.getPostListCount(category);
        }
        int totalPages = (int) Math.ceil((double) totalCount / size);
        model.addAttribute("posts", posts);
        model.addAttribute("totalCount", totalCount);
        model.addAttribute("category", category);
        model.addAttribute("keyword", keyword);
        model.addAttribute("searchType", searchType);
        model.addAttribute("sort", sort);
        model.addAttribute("page", page);
        model.addAttribute("totalPages", totalPages);
        return "common/community/list";
    }

    // 게시글 상세
    @GetMapping("/{postId}")
    public String detail(@PathVariable int postId, Model model) {
        PostVO post = postService.getPost(postId);
        if (post == null) {
            return "redirect:/common/community";
        }
        Integer currentUserId = currentUserIdOrNull();
        model.addAttribute("selectedPost", post);
        model.addAttribute("comments", postService.getComments(postId));
        model.addAttribute("userReaction",
                currentUserId != null ? postService.getUserReaction(postId, currentUserId) : null);
        model.addAttribute("currentUserId", currentUserId);
        model.addAttribute("hasReported",
                currentUserId != null && postService.hasReported(postId, currentUserId));
        model.addAttribute("reportedCommentIds",
                currentUserId != null ? postService.getReportedCommentIds(postId, currentUserId) : java.util.Collections.emptyList());
        return "common/community/detail";
    }

    // 글쓰기 폼
    @GetMapping("/write")
    public String writeForm(Model model) {
        model.addAttribute("salons", postService.getSalonList());
        return "common/community/write";
    }

    // 글 저장
    @PostMapping("/write")
    public String write(@ModelAttribute PostVO post,
                        @RequestParam(required = false) MultipartFile imageFile,
                        RedirectAttributes redirectAttributes) throws IOException {
        post.setUserId(currentUserId());
        try {
            postService.writePost(post, imageFile);
        } catch (IllegalArgumentException e) {
            // 허용되지 않은 첨부파일 등 사용자 입력 오류 → 입력값을 살린 채 폼으로 되돌린다
            redirectAttributes.addFlashAttribute("errorMessage", e.getMessage());
            redirectAttributes.addFlashAttribute("post", post);
            return "redirect:/common/community/write";
        }
        return "redirect:/common/community/" + post.getPostId();
    }

    // 글 수정 폼
    @GetMapping("/{postId}/edit")
    public String editForm(@PathVariable int postId, Model model,
                           RedirectAttributes redirectAttributes) {
        // 글이 사라졌으면 flash 로 넘어온 입력값이 있어도 폼을 다시 열지 않는다 — 저장할 대상이
        // 없는데 폼만 계속 뜨면 사용자가 같은 실패를 반복하게 된다.
        // getPost 가 아니라 findVisiblePost 를 쓴다 — 수정 폼을 여는 것이 조회수로 집계되면 안 된다.
        PostVO current = postService.findVisiblePost(postId);
        if (current == null) {
            redirectAttributes.addFlashAttribute("errorMessage", "삭제되었거나 블라인드된 글입니다.");
            return "redirect:/common/community";
        }
        if (current.getUserId() != currentUserId()) {
            throw new AccessDeniedException("본인이 작성한 글만 수정할 수 있습니다.");
        }
        // 검증 실패로 되돌아온 경우 flash 로 넘어온 post(사용자가 입력하던 값)를 그대로 쓴다
        if (!model.containsAttribute("post")) {
            model.addAttribute("post", current);
        }
        model.addAttribute("salons", postService.getSalonList());
        return "common/community/write";
    }

    // 글 수정 저장
    @PostMapping("/{postId}/edit")
    public String edit(@PathVariable int postId,
                       @ModelAttribute PostVO post,
                       @RequestParam(required = false) MultipartFile imageFile,
                       RedirectAttributes redirectAttributes) throws IOException {
        post.setPostId(postId);
        // imageFile 없으면 post.imageUrl은 hidden 필드로 넘어온 기존 값 유지
        try {
            postService.editPost(post, imageFile, currentUserId());
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("errorMessage", e.getMessage());
            // 글 자체가 사라진 경우엔 폼으로 되돌려봐야 곧바로 목록으로 튕겨 나온다
            if (postService.findVisiblePost(postId) == null) {
                return "redirect:/common/community";
            }
            redirectAttributes.addFlashAttribute("post", post);
            return "redirect:/common/community/" + postId + "/edit";
        }
        return "redirect:/common/community/" + postId;
    }

    // 글 삭제
    @PostMapping("/{postId}/delete")
    public String delete(@PathVariable int postId, RedirectAttributes redirectAttributes) {
        try {
            postService.removePost(postId, currentUserId());
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/common/community";
    }

    // 댓글 작성
    @PostMapping("/{postId}/comment")
    public String writeComment(@PathVariable int postId,
                               @ModelAttribute CommentVO comment,
                               RedirectAttributes redirectAttributes) {
        comment.setPostId(postId);
        comment.setUserId(currentUserId());
        try {
            postService.writeComment(comment);
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("errorMessage", e.getMessage());
            // 글이 사라진 경우 상세로 보내면 목록으로 다시 튕기면서 안내가 사라진다
            if (postService.findVisiblePost(postId) == null) {
                return "redirect:/common/community";
            }
        }
        return "redirect:/common/community/" + postId;
    }

    // 댓글 삭제
    @PostMapping("/{postId}/comment/{commentId}/delete")
    public String deleteComment(@PathVariable int postId,
                                @PathVariable int commentId,
                                RedirectAttributes redirectAttributes) {
        try {
            postService.removeComment(commentId, currentUserId());
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/common/community/" + postId;
    }

    // 좋아요 / 별로예요 토글
    @PostMapping("/{postId}/react")
    public String react(@PathVariable int postId,
                        @RequestParam String type,
                        RedirectAttributes redirectAttributes) {
        try {
            postService.react(postId, currentUserId(), type);
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("errorMessage", e.getMessage());
            // 글이 사라진 경우 상세로 보내면 목록으로 다시 튕기면서 안내가 사라진다
            return "redirect:/common/community";
        }
        return "redirect:/common/community/" + postId;
    }

    // 게시글 신고 (1인 1회, 사유 카테고리 선택, 누적 시 서비스단에서 자동 블라인드)
    @PostMapping("/{postId}/report")
    public String report(@PathVariable int postId,
                         @RequestParam String reason,
                         @RequestParam(required = false) String reasonDetail,
                         RedirectAttributes redirectAttributes) {
        try {
            postService.reportPost(postId, currentUserId(), reason, reasonDetail);
            return "redirect:/common/community/" + postId + "?reported=true";
        } catch (IllegalStateException e) {
            return "redirect:/common/community/" + postId + "?reported=duplicate";
        } catch (IllegalArgumentException e) {
            // 실패 사유가 한 가지가 아니므로 고정 문구 대신 서비스가 준 메시지를 그대로 보여준다
            redirectAttributes.addFlashAttribute("errorMessage", e.getMessage());
            return "redirect:/common/community/" + postId;
        }
    }

    // 댓글 신고 (1인 1회, 사유 카테고리 선택) -- 게시글 신고와 달리 자동 블라인드 없음, 관리자 검토 대기 상태로만 남는다
    @PostMapping("/{postId}/comment/{commentId}/report")
    public String reportComment(@PathVariable int postId,
                                @PathVariable int commentId,
                                @RequestParam String reason,
                                @RequestParam(required = false) String reasonDetail,
                                RedirectAttributes redirectAttributes) {
        try {
            postService.reportComment(commentId, currentUserId(), reason, reasonDetail);
            return "redirect:/common/community/" + postId + "?reported=true";
        } catch (IllegalStateException e) {
            return "redirect:/common/community/" + postId + "?reported=duplicate";
        } catch (IllegalArgumentException e) {
            // 사유 미선택과 이미 삭제된 댓글이 같은 예외라 고정 문구로는 잘못 안내된다
            redirectAttributes.addFlashAttribute("errorMessage", e.getMessage());
            return "redirect:/common/community/" + postId;
        }
    }
}
