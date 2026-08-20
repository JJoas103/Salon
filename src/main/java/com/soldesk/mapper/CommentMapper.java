package com.soldesk.mapper;

import com.soldesk.vo.CommentVO;
import org.apache.ibatis.annotations.Param;
import java.util.List;

public interface CommentMapper {

    List<CommentVO> findByPostId(int postId);

    CommentVO findById(int commentId);

    void insert(CommentVO comment);

    void delete(int commentId);

    void deleteByPostId(int postId);

    // 신고 누적(comment_reports 존재)된 댓글 목록 -- 관리자 대시보드 (댓글엔 status/report_count 컬럼이 없으므로 JOIN 집계)
    List<CommentVO> findReported();

    // 마이페이지 "내가 쓴 댓글" 탭
    List<CommentVO> findByUserId(@Param("userId") int userId);

    // 마이페이지 "내 글에 달린 댓글" 탭 -- 본인이 자기 글에 단 댓글은 제외
    List<CommentVO> findRepliesToUserPosts(@Param("userId") int userId);

    // 마이페이지 카드 뱃지용 -- 목록 전체를 안 불러오고 개수만
    int countRepliesToUserPosts(@Param("userId") int userId);
}
