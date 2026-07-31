package com.soldesk.mapper;

import com.soldesk.vo.CommentVO;
import java.util.List;

public interface CommentMapper {

    List<CommentVO> findByPostId(int postId);

    CommentVO findById(int commentId);

    void insert(CommentVO comment);

    void delete(int commentId);

    void deleteByPostId(int postId);

    // 신고 누적(comment_reports 존재)된 댓글 목록 -- 관리자 대시보드 (댓글엔 status/report_count 컬럼이 없으므로 JOIN 집계)
    List<CommentVO> findReported();
}
