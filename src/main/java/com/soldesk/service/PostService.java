package com.soldesk.service;

import com.soldesk.vo.CommentVO;
import com.soldesk.vo.PostVO;
import com.soldesk.vo.SalonVO;
import java.io.IOException;
import java.util.List;
import org.springframework.web.multipart.MultipartFile;

public interface PostService {

    List<PostVO> getPostList(String category, String sort, int page, int size);

    int getPostListCount(String category);

    PostVO getPost(int postId);

    /**
     * 조회수를 올리지 않는 단순 조회(노출 중인 글만).
     * 존재/노출 여부 확인용 -- getPost 는 조회수를 증가시키므로 그 목적으로 쓰면 안 된다.
     */
    PostVO findVisiblePost(int postId);

    void writePost(PostVO post, MultipartFile imageFile) throws IOException;

    void editPost(PostVO post, MultipartFile imageFile, int userId) throws IOException;

    void removePost(int postId, int userId);

    List<CommentVO> getComments(int postId);

    void writeComment(CommentVO comment);

    void removeComment(int commentId, int userId);

    // 내 글에 달린 남의 댓글 삭제 -- 게시글이 이미 삭제/블라인드된 경우에만 허용(마이페이지 로그 정리용)
    void removeCommentAsPostOwner(int commentId, int userId);

    List<SalonVO> getSalonList();

    void react(int postId, int userId, String type);

    String getUserReaction(int postId, int userId);

    List<PostVO> searchPosts(String searchType, String keyword, String sort, int page, int size);

    int getSearchCount(String searchType, String keyword);

    void reportPost(int postId, int userId, String reason, String reasonDetail);

    boolean hasReported(int postId, int userId);

    List<PostVO> getBlindedPosts();

    void approveDeleteWithSanction(int postId, String sanctionType, String adminReason);

    void dismissReport(int postId);

    PostVO getPostForAdmin(int postId);

    List<String> getOtherReasonDetails(int postId);

    int sumReportCountByAuthor(int userId);

    void reportComment(int commentId, int userId, String reason, String reasonDetail);

    boolean hasReportedComment(int commentId, int userId);

    List<Integer> getReportedCommentIds(int postId, int userId);

    List<CommentVO> getReportedComments();

    List<String> getOtherCommentReasonDetails(int commentId);

    void approveDeleteCommentWithSanction(int commentId, String sanctionType, String adminReason);

    void dismissCommentReport(int commentId);

    // 마이페이지 "내 커뮤니티 활동" 탭
    List<PostVO> getMyPosts(int userId);

    List<CommentVO> getMyComments(int userId);

    List<CommentVO> getRepliesToMyPosts(int userId);

    int countRepliesToMyPosts(int userId);
}
