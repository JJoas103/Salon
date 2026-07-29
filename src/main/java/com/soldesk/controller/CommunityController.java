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
import java.util.List;

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

    // 게시글 목록 (카테고리 필터 + 검색)
    @GetMapping
    public String list(@RequestParam(required = false, defaultValue = "") String category,
                       @RequestParam(required = false, defaultValue = "") String keyword,
                       @RequestParam(required = false, defaultValue = "title_content") String searchType,
                       @RequestParam(required = false, defaultValue = "latest") String sort,
                       Model model) {
        List<PostVO> posts;
        if (!keyword.trim().isEmpty()) {
            posts = postService.searchPosts(searchType, keyword, sort);
        } else {
            posts = postService.getPostList(category, sort);
        }
        model.addAttribute("posts", posts);
        model.addAttribute("category", category);
        model.addAttribute("keyword", keyword);
        model.addAttribute("searchType", searchType);
        model.addAttribute("sort", sort);
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
    public String editForm(@PathVariable int postId, Model model) {
        // 검증 실패로 되돌아온 경우 flash 로 넘어온 post(사용자가 입력하던 값)를 그대로 쓴다
        if (!model.containsAttribute("post")) {
            PostVO post = postService.getPost(postId);
            if (post == null || post.getUserId() != currentUserId()) {
                throw new AccessDeniedException("본인이 작성한 글만 수정할 수 있습니다.");
            }
            model.addAttribute("post", post);
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
            redirectAttributes.addFlashAttribute("post", post);
            return "redirect:/common/community/" + postId + "/edit";
        }
        return "redirect:/common/community/" + postId;
    }

    // 글 삭제
    @PostMapping("/{postId}/delete")
    public String delete(@PathVariable int postId) {
        postService.removePost(postId, currentUserId());
        return "redirect:/common/community";
    }

    // 댓글 작성
    @PostMapping("/{postId}/comment")
    public String writeComment(@PathVariable int postId,
                               @ModelAttribute CommentVO comment) {
        comment.setPostId(postId);
        comment.setUserId(currentUserId());
        postService.writeComment(comment);
        return "redirect:/common/community/" + postId;
    }

    // 댓글 삭제
    @PostMapping("/{postId}/comment/{commentId}/delete")
    public String deleteComment(@PathVariable int postId,
                                @PathVariable int commentId) {
        postService.removeComment(commentId, currentUserId());
        return "redirect:/common/community/" + postId;
    }

    // 좋아요 / 별로예요 토글
    @PostMapping("/{postId}/react")
    public String react(@PathVariable int postId,
                        @RequestParam String type) {
        postService.react(postId, currentUserId(), type);
        return "redirect:/common/community/" + postId;
    }
}
