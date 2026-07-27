package com.soldesk.service;

import com.soldesk.vo.CommentVO;
import com.soldesk.vo.PostVO;
import com.soldesk.vo.SalonVO;
import java.util.List;

public interface PostService {

    List<PostVO> getPostList(String category);

    PostVO getPost(int postId);

    void writePost(PostVO post);

    void editPost(PostVO post);

    void removePost(int postId);

    List<CommentVO> getComments(int postId);

    void writeComment(CommentVO comment);

    void removeComment(int commentId);

    List<SalonVO> getSalonList();

    void react(int postId, int userId, String type);

    String getUserReaction(int postId, int userId);

    List<PostVO> getPopularPosts();

    List<PostVO> searchPosts(String searchType, String keyword);
}
