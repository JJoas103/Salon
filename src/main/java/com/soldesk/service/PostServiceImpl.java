package com.soldesk.service;

import com.soldesk.mapper.CommentMapper;
import com.soldesk.mapper.PostLikeMapper;
import com.soldesk.mapper.PostMapper;
import com.soldesk.mapper.SalonMapper;
import com.soldesk.vo.CommentVO;
import com.soldesk.vo.PostLikeVO;
import com.soldesk.vo.PostVO;
import com.soldesk.vo.SalonVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

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
    private FileService fileService;

    @Override
    public List<PostVO> getPostList(String category, String sort) {
        if (category == null || category.isEmpty()) {
            return postMapper.findAll(sort);
        }
        return postMapper.findByCategory(category, sort);
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
        commentMapper.deleteByPostId(postId);
        postMapper.delete(postId);
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
    public List<PostVO> getPopularPosts() {
        return postMapper.findPopular();
    }

    @Override
    public List<PostVO> searchPosts(String searchType, String keyword, String sort) {
        return postMapper.search(searchType, "%" + keyword + "%", sort);
    }
}
