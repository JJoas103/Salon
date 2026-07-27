package com.soldesk.controller;

import com.soldesk.service.PostService;
import com.soldesk.vo.CommentVO;
import com.soldesk.vo.PostVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.UUID;

@Controller
@RequestMapping("/community")
public class CommunityController {

    private static final String UPLOAD_DIR = "C:/soldesk/uploads/";

    @Autowired
    private PostService postService;

    // 게시글 목록 (카테고리 필터 + 검색)
    @GetMapping
    public String list(@RequestParam(required = false, defaultValue = "") String category,
                       @RequestParam(required = false, defaultValue = "") String keyword,
                       @RequestParam(required = false, defaultValue = "title_content") String searchType,
                       Model model) {
        List<PostVO> posts;
        if (!keyword.trim().isEmpty()) {
            posts = postService.searchPosts(searchType, keyword);
        } else {
            posts = postService.getPostList(category);
        }
        model.addAttribute("posts", posts);
        model.addAttribute("category", category);
        model.addAttribute("keyword", keyword);
        model.addAttribute("searchType", searchType);
        return "community/list";
    }

    // 게시글 상세
    @GetMapping("/{postId}")
    public String detail(@PathVariable int postId, Model model) {
        PostVO post = postService.getPost(postId);
        if (post == null) {
            return "redirect:/community";
        }
        model.addAttribute("selectedPost", post);
        model.addAttribute("comments", postService.getComments(postId));
        model.addAttribute("userReaction", postService.getUserReaction(postId, 1));
        return "community/detail";
    }

    // 글쓰기 폼
    @GetMapping("/write")
    public String writeForm(Model model) {
        model.addAttribute("salons", postService.getSalonList());
        return "community/write";
    }

    // 글 저장
    @PostMapping("/write")
    public String write(@ModelAttribute PostVO post,
                        @RequestParam(required = false) MultipartFile imageFile) throws IOException {
        if (imageFile != null && !imageFile.isEmpty()) {
            post.setImageUrl(saveFile(imageFile));
        }
        post.setUserId(1); // TODO: 로그인 연동 후 SecurityContextHolder로 교체
        postService.writePost(post);
        return "redirect:/community/" + post.getPostId();
    }

    // 글 수정 폼
    @GetMapping("/{postId}/edit")
    public String editForm(@PathVariable int postId, Model model) {
        model.addAttribute("post", postService.getPost(postId));
        model.addAttribute("salons", postService.getSalonList());
        return "community/write";
    }

    // 글 수정 저장
    @PostMapping("/{postId}/edit")
    public String edit(@PathVariable int postId,
                       @ModelAttribute PostVO post,
                       @RequestParam(required = false) MultipartFile imageFile) throws IOException {
        post.setPostId(postId);
        if (imageFile != null && !imageFile.isEmpty()) {
            post.setImageUrl(saveFile(imageFile));
        }
        // imageFile 없으면 post.imageUrl은 hidden 필드로 넘어온 기존 값 유지
        postService.editPost(post);
        return "redirect:/community/" + postId;
    }

    // 글 삭제
    @PostMapping("/{postId}/delete")
    public String delete(@PathVariable int postId) {
        postService.removePost(postId);
        return "redirect:/community";
    }

    // 댓글 작성
    @PostMapping("/{postId}/comment")
    public String writeComment(@PathVariable int postId,
                               @ModelAttribute CommentVO comment) {
        comment.setPostId(postId);
        comment.setUserId(1); // TODO: 로그인 연동 후 교체
        postService.writeComment(comment);
        return "redirect:/community/" + postId;
    }

    // 댓글 삭제
    @PostMapping("/{postId}/comment/{commentId}/delete")
    public String deleteComment(@PathVariable int postId,
                                @PathVariable int commentId) {
        postService.removeComment(commentId);
        return "redirect:/community/" + postId;
    }

    // 좋아요 / 별로예요 토글
    @PostMapping("/{postId}/react")
    public String react(@PathVariable int postId,
                        @RequestParam String type) {
        postService.react(postId, 1, type); // TODO: 로그인 연동 후 실제 userId 사용
        return "redirect:/community/" + postId;
    }

    // 인기글 목록
    @GetMapping("/popular")
    public String popular(Model model) {
        model.addAttribute("posts", postService.getPopularPosts());
        return "community/popular";
    }

    private String saveFile(MultipartFile file) throws IOException {
        File dir = new File(UPLOAD_DIR);
        if (!dir.exists()) dir.mkdirs();
        String ext = "";
        String original = file.getOriginalFilename();
        if (original != null && original.contains(".")) {
            ext = original.substring(original.lastIndexOf("."));
        }
        String filename = UUID.randomUUID().toString() + ext;
        file.transferTo(new File(dir, filename));
        return filename;
    }
}
