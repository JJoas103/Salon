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
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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

    @Override
    public List<PostVO> getPostList(String category) {
        if (category == null || category.isEmpty()) {
            return postMapper.findAll();
        }
        return postMapper.findByCategory(category);
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
    public void writePost(PostVO post) {
        if (post.getContent() != null) post.setContent(post.getContent().trim());
        if (post.getTitle()   != null) post.setTitle(post.getTitle().trim());
        postMapper.insert(post);
    }

    @Override
    @Transactional
    public void editPost(PostVO post) {
        if (post.getContent() != null) post.setContent(post.getContent().trim());
        if (post.getTitle()   != null) post.setTitle(post.getTitle().trim());
        postMapper.update(post);
    }

    @Override
    @Transactional
    public void removePost(int postId) {
        commentMapper.deleteByPostId(postId);
        postMapper.delete(postId);
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
    public void removeComment(int commentId) {
        commentMapper.delete(commentId);
    }

    @Override
    public List<SalonVO> getSalonList() {
        return salonMapper.findAll();
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
    public List<PostVO> searchPosts(String searchType, String keyword) {
        return postMapper.search(searchType, "%" + keyword + "%");
    }
}
