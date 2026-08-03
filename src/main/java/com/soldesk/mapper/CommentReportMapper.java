package com.soldesk.mapper;

import com.soldesk.vo.CommentReportVO;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

public interface CommentReportMapper {
    CommentReportVO findByCommentAndUser(@Param("commentId") int commentId, @Param("userId") int userId);
    void insert(@Param("commentId") int commentId, @Param("userId") int userId,
                @Param("reason") String reason, @Param("reasonDetail") String reasonDetail);
    void deleteByCommentId(@Param("commentId") int commentId);

    // 댓글별 신고 사유 집계 (관리자 화면 요약 표시 전용)
    List<Map<String, Object>> findReasonCounts(@Param("commentId") int commentId);

    // "기타" 사유로 남겨진 직접 입력 텍스트 목록 (관리자 화면 표시 전용)
    List<String> findOtherReasonDetails(@Param("commentId") int commentId);

    // 특정 게시글 내에서 로그인 사용자가 이미 신고한 댓글 ID 목록 (댓글별 "신고 완료" 표시용)
    List<Integer> findReportedCommentIdsByUser(@Param("postId") int postId, @Param("userId") int userId);
}
