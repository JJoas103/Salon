package com.soldesk.mapper;

import com.soldesk.vo.PostLikeVO;
import org.apache.ibatis.annotations.Param;

public interface PostLikeMapper {
    PostLikeVO findByPostAndUser(@Param("postId") int postId, @Param("userId") int userId);
    void insert(@Param("postId") int postId, @Param("userId") int userId, @Param("type") String type);
    void delete(@Param("postId") int postId, @Param("userId") int userId);
    void updateType(@Param("postId") int postId, @Param("userId") int userId, @Param("type") String type);
    void deleteByPostId(@Param("postId") int postId);
}
