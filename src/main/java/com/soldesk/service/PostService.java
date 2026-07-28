package com.soldesk.service;

import com.soldesk.vo.CommentVO;
import com.soldesk.vo.PostVO;
import com.soldesk.vo.SalonVO;
import java.io.IOException;
import java.util.List;
import org.springframework.web.multipart.MultipartFile;

public interface PostService {

    List<PostVO> getPostList(String category, String sort);

    PostVO getPost(int postId);

    void writePost(PostVO post, MultipartFile imageFile) throws IOException;

    void editPost(PostVO post, MultipartFile imageFile, int userId) throws IOException;

    void removePost(int postId, int userId);

    List<CommentVO> getComments(int postId);

    void writeComment(CommentVO comment);

    void removeComment(int commentId, int userId);

    List<SalonVO> getSalonList();

    void react(int postId, int userId, String type);

    String getUserReaction(int postId, int userId);

    List<PostVO> getPopularPosts();

    List<PostVO> searchPosts(String searchType, String keyword, String sort);
}
