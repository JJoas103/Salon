package com.soldesk.mapper;

import com.soldesk.vo.PostVO;
import org.apache.ibatis.annotations.Param;
import java.util.List;

public interface PostMapper {

    List<PostVO> findAll();

    List<PostVO> findByCategory(String category);

    PostVO findById(int postId);

    void insert(PostVO post);

    void update(PostVO post);

    void delete(int postId);

    void incrementViewCount(int postId);

    List<PostVO> findPopular();

    void incrementLikeCount(int postId);
    void decrementLikeCount(int postId);
    void incrementDislikeCount(int postId);
    void decrementDislikeCount(int postId);

    List<PostVO> search(@Param("searchType") String searchType, @Param("keyword") String keyword);
}
