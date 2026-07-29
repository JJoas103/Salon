package com.soldesk.mapper;

import com.soldesk.vo.CommentVO;
import java.util.List;

public interface CommentMapper {

    List<CommentVO> findByPostId(int postId);

    CommentVO findById(int commentId);

    void insert(CommentVO comment);

    void delete(int commentId);

    void deleteByPostId(int postId);
}
