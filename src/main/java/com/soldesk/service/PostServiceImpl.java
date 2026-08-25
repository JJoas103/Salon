package com.soldesk.service;

import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.soldesk.mapper.CommentMapper;
import com.soldesk.mapper.CommentReportMapper;
import com.soldesk.mapper.PostLikeMapper;
import com.soldesk.mapper.PostMapper;
import com.soldesk.mapper.PostReportMapper;
import com.soldesk.mapper.SalonMapper;
import com.soldesk.vo.CommentReportVO;
import com.soldesk.vo.CommentVO;
import com.soldesk.vo.PostLikeVO;
import com.soldesk.vo.PostReportVO;
import com.soldesk.vo.PostVO;
import com.soldesk.vo.SalonVO;

@Service
public class PostServiceImpl implements PostService {

    @Autowired
    private PostMapper postMapper;

    @Autowired
    private CommentMapper commentMapper;

    @Autowired
    private SalonMapper salonMapper;

    @Autowired
    private PostLikeMapper postLikeMapper;

    @Autowired
    private PostReportMapper postReportMapper;

    @Autowired
    private CommentReportMapper commentReportMapper;

    @Autowired
    private FileService fileService;

    @Autowired
    private UserService userService;

    @Value("${report.blind-threshold:5}")
    private int reportBlindThreshold;

    // 신고 사유 코드 -> 한글 라벨 (관리자 화면 요약 표시용)
    private static final Map<String, String> REPORT_REASON_LABELS = new LinkedHashMap<>();
    static {
        REPORT_REASON_LABELS.put("spam", "스팸/광고");
        REPORT_REASON_LABELS.put("illegal", "음란물/불법 정보");
        REPORT_REASON_LABELS.put("abuse", "욕설/비하/도배");
        REPORT_REASON_LABELS.put("privacy", "개인정보 노출");
        REPORT_REASON_LABELS.put("other", "기타");
    }

    @Override
    public List<PostVO> getPostList(String category, String sort, int page, int size) {
        int offset = (page - 1) * size;
        if (category == null || category.isEmpty()) {
            return postMapper.findAll(sort, offset, size);
        }
        return postMapper.findByCategory(category, sort, offset, size);
    }

    @Override
    public int getPostListCount(String category) {
        if (category == null || category.isEmpty()) {
            return postMapper.countAll();
        }
        return postMapper.countByCategory(category);
    }

    @Override
    public PostVO getPost(int postId) {
        PostVO post = postMapper.findById(postId);
        if (post != null) {
            postMapper.incrementViewCount(postId);
            post.setViewCount(post.getViewCount() + 1);
        }
        return post;
    }

    @Override
    @Transactional
    public void writePost(PostVO post, MultipartFile imageFile) throws IOException {
        post.setImageUrl(fileService.saveFile(imageFile));
        if (post.getContent() != null) post.setContent(post.getContent().trim());
        if (post.getTitle()   != null) post.setTitle(post.getTitle().trim());
        postMapper.insert(post);
    }

    @Override
    @Transactional
    public void editPost(PostVO post, MultipartFile imageFile, int userId) throws IOException {
        PostVO existing = postMapper.findById(post.getPostId());
        if (existing == null || existing.getUserId() != userId) {
            throw new AccessDeniedException("본인이 작성한 글만 수정할 수 있습니다.");
        }
        // 새 이미지가 올라온 경우에만 교체. 아니면 hidden 필드로 넘어온 기존 파일명 유지
        String newImage = fileService.saveFile(imageFile);
        if (newImage != null) {
            fileService.deleteFile(post.getImageUrl());
            post.setImageUrl(newImage);
        }
        if (post.getContent() != null) post.setContent(post.getContent().trim());
        if (post.getTitle()   != null) post.setTitle(post.getTitle().trim());
        postMapper.update(post);
    }

    @Override
    @Transactional
    public void removePost(int postId, int userId) {
        PostVO post = postMapper.findById(postId);
        if (post == null || post.getUserId() != userId) {
            throw new AccessDeniedException("본인이 작성한 글만 삭제할 수 있습니다.");
        }
        deletePostCascade(post);
    }

    // removePost()와 approveDelete()가 공유하는 삭제 로직
    // 댓글은 지우지 않는다 -- 마이페이지 "내가 쓴 댓글"/"내 글에 달린 댓글" 탭에 로그로 남겨야 하므로
    // 글은 하드 삭제 대신 소프트 삭제(status='deleted')해서 댓글이 참조하는 행을 보존한다
    private void deletePostCascade(PostVO post) {
        postReportMapper.deleteByPostId(post.getPostId());
        postLikeMapper.deleteByPostId(post.getPostId());
        postMapper.softDelete(post.getPostId());
        fileService.deleteFile(post.getImageUrl());
    }

    @Override
    public List<CommentVO> getComments(int postId) {
        return commentMapper.findByPostId(postId);
    }

    @Override
    @Transactional
    public void writeComment(CommentVO comment) {
        commentMapper.insert(comment);
    }

    @Override
    @Transactional
    public void removeComment(int commentId, int userId) {
        CommentVO comment = commentMapper.findById(commentId);
        if (comment == null || comment.getUserId() != userId) {
            throw new AccessDeniedException("본인이 작성한 댓글만 삭제할 수 있습니다.");
        }
        commentMapper.delete(commentId);
    }

    @Override
    @Transactional
    public void removeCommentAsPostOwner(int commentId, int userId) {
        CommentVO comment = commentMapper.findById(commentId);
        if (comment == null) return; // 이미 삭제된 경우 -- 조용히 무시
        PostVO post = postMapper.findByIdAny(comment.getPostId());
        if (post == null || post.getUserId() != userId) {
            throw new AccessDeniedException("본인 게시글의 댓글만 삭제할 수 있습니다.");
        }
        if ("visible".equals(post.getStatus())) {
            // 마이페이지 X 버튼은 게시글이 죽은 경우에만 노출되지만, 서버에서도 동일 규칙을 강제한다
            throw new AccessDeniedException("게시글이 삭제된 경우에만 댓글 기록을 정리할 수 있습니다.");
        }
        commentMapper.delete(commentId);
    }

    @Override
    public List<SalonVO> getSalonList() {
        return salonMapper.findAllWithMinimumPrice();
    }

    @Override
    @Transactional
    public void react(int postId, int userId, String type) {
        PostLikeVO existing = postLikeMapper.findByPostAndUser(postId, userId);
        if (existing == null) {
            postLikeMapper.insert(postId, userId, type);
            if ("like".equals(type)) postMapper.incrementLikeCount(postId);
            else                     postMapper.incrementDislikeCount(postId);
        } else if (existing.getReactionType().equals(type)) {
            postLikeMapper.delete(postId, userId);
            if ("like".equals(type)) postMapper.decrementLikeCount(postId);
            else                     postMapper.decrementDislikeCount(postId);
        } else {
            postLikeMapper.updateType(postId, userId, type);
            if ("like".equals(type)) {
                postMapper.incrementLikeCount(postId);
                postMapper.decrementDislikeCount(postId);
            } else {
                postMapper.decrementLikeCount(postId);
                postMapper.incrementDislikeCount(postId);
            }
        }
    }

    @Override
    public String getUserReaction(int postId, int userId) {
        PostLikeVO r = postLikeMapper.findByPostAndUser(postId, userId);
        return r != null ? r.getReactionType() : null;
    }

    @Override
    public List<PostVO> searchPosts(String searchType, String keyword, String sort, int page, int size) {
        int offset = (page - 1) * size;
        return postMapper.search(searchType, "%" + keyword + "%", sort, offset, size);
    }

    @Override
    public int getSearchCount(String searchType, String keyword) {
        return postMapper.countSearch(searchType, "%" + keyword + "%");
    }

    @Override
    @Transactional
    public void reportPost(int postId, int userId, String reason, String reasonDetail) {
        PostReportVO existing = postReportMapper.findByPostAndUser(postId, userId);
        if (existing != null) {
            throw new IllegalStateException("이미 신고한 게시글입니다.");
        }
        if (!REPORT_REASON_LABELS.containsKey(reason)) {
            throw new IllegalArgumentException("올바르지 않은 신고 사유입니다.");
        }
        postReportMapper.insert(postId, userId, reason, reasonDetail);
        postMapper.incrementReportCount(postId);

        PostVO post = postMapper.findByIdAny(postId);
        if (post != null
                && post.getReportCount() >= reportBlindThreshold
                && !"blinded".equals(post.getStatus())) {
            postMapper.blindPost(postId);
        }
    }

    @Override
    public boolean hasReported(int postId, int userId) {
        return postReportMapper.findByPostAndUser(postId, userId) != null;
    }

    @Override
    public List<PostVO> getBlindedPosts() {
        List<PostVO> posts = postMapper.findBlinded();
        for (PostVO post : posts) {
            post.setReportReasonSummary(buildReasonSummary(post.getPostId()));
        }
        return posts;
    }

    // 게시글별 신고 사유 집계를 "라벨 N건, 라벨 N건" 형태 문자열로 조합 (관리자 화면 표시 전용)
    private String buildReasonSummary(int postId) {
        List<Map<String, Object>> counts = postReportMapper.findReasonCounts(postId);
        StringBuilder sb = new StringBuilder();
        for (Map<String, Object> row : counts) {
            String label = REPORT_REASON_LABELS.getOrDefault((String) row.get("reason"), "기타");
            Object cnt = row.get("cnt");
            if (sb.length() > 0) sb.append(", ");
            sb.append(label).append(" ").append(cnt).append("건");
        }
        return sb.toString();
    }

    @Override
    public PostVO getPostForAdmin(int postId) {
        return postMapper.findByIdAny(postId);
    }

    @Override
    public List<String> getOtherReasonDetails(int postId) {
        return postReportMapper.findOtherReasonDetails(postId);
    }

    @Override
    @Transactional
    public void approveDeleteWithSanction(int postId, String sanctionType, String adminReason) {
        PostVO post = postMapper.findByIdAny(postId);
        if (post == null) return; // 이미 삭제/처리된 경우 -- 조용히 무시
        int userId = post.getUserId();
        String title = post.getTitle();
        deletePostCascade(post);
        userService.suspendUser(userId, sanctionType, postId, title, adminReason);
    }

    @Override
    public int sumReportCountByAuthor(int userId) {
        return postMapper.sumReportCountByAuthor(userId);
    }

    @Override
    @Transactional
    public void dismissReport(int postId) {
        postReportMapper.deleteByPostId(postId);
        postMapper.resetReportCount(postId);
        postMapper.unblindPost(postId);
    }

    @Override
    @Transactional
    public void reportComment(int commentId, int userId, String reason, String reasonDetail) {
        CommentReportVO existing = commentReportMapper.findByCommentAndUser(commentId, userId);
        if (existing != null) {
            throw new IllegalStateException("이미 신고한 댓글입니다.");
        }
        if (!REPORT_REASON_LABELS.containsKey(reason)) {
            throw new IllegalArgumentException("올바르지 않은 신고 사유입니다.");
        }
        commentReportMapper.insert(commentId, userId, reason, reasonDetail);
        // 게시글 신고와 달리 자동 블라인드 없음 -- 댓글은 관리자가 검토할 때까지 그대로 노출된다
    }

    @Override
    public boolean hasReportedComment(int commentId, int userId) {
        return commentReportMapper.findByCommentAndUser(commentId, userId) != null;
    }

    @Override
    public List<Integer> getReportedCommentIds(int postId, int userId) {
        return commentReportMapper.findReportedCommentIdsByUser(postId, userId);
    }

    @Override
    public List<CommentVO> getReportedComments() {
        List<CommentVO> comments = commentMapper.findReported();
        for (CommentVO comment : comments) {
            comment.setReportReasonSummary(buildCommentReasonSummary(comment.getCommentId()));
        }
        return comments;
    }

    // 댓글별 신고 사유 집계를 "라벨 N건, 라벨 N건" 형태 문자열로 조합 (관리자 화면 표시 전용, REPORT_REASON_LABELS 재사용)
    private String buildCommentReasonSummary(int commentId) {
        List<Map<String, Object>> counts = commentReportMapper.findReasonCounts(commentId);
        StringBuilder sb = new StringBuilder();
        for (Map<String, Object> row : counts) {
            String label = REPORT_REASON_LABELS.getOrDefault((String) row.get("reason"), "기타");
            Object cnt = row.get("cnt");
            if (sb.length() > 0) sb.append(", ");
            sb.append(label).append(" ").append(cnt).append("건");
        }
        return sb.toString();
    }

    @Override
    public List<String> getOtherCommentReasonDetails(int commentId) {
        return commentReportMapper.findOtherReasonDetails(commentId);
    }

    @Override
    @Transactional
    public void approveDeleteCommentWithSanction(int commentId, String sanctionType, String adminReason) {
        CommentVO comment = commentMapper.findById(commentId);
        if (comment == null) return; // 이미 삭제/처리된 경우 -- 조용히 무시
        int userId = comment.getUserId();
        String content = comment.getContent();
        int postId = comment.getPostId();
        PostVO post = postMapper.findByIdAny(postId); // 소속 글 제목 스냅샷용 (참고 정보)
        String postTitle = post != null ? post.getTitle() : null;

        commentMapper.delete(commentId); // FK ON DELETE CASCADE로 comment_reports 자동 정리
        userService.suspendUser(userId, sanctionType, postId, postTitle, commentId, content, adminReason);
    }

    @Override
    @Transactional
    public void dismissCommentReport(int commentId) {
        commentReportMapper.deleteByCommentId(commentId);
        // 댓글은 자동 블라인드가 없으므로 상태 복구 로직 불필요 -- 신고 기록만 지우면 목록에서 자연히 사라짐
    }

    @Override
    public List<PostVO> getMyPosts(int userId) {
        return postMapper.findByUserId(userId);
    }

    @Override
    public List<CommentVO> getMyComments(int userId) {
        return commentMapper.findByUserId(userId);
    }

    @Override
    public List<CommentVO> getRepliesToMyPosts(int userId) {
        return commentMapper.findRepliesToUserPosts(userId);
    }

    @Override
    public int countRepliesToMyPosts(int userId) {
        return commentMapper.countRepliesToUserPosts(userId);
    }
}
