package com.soldesk.mapper;

import com.soldesk.vo.PostReportVO;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

public interface PostReportMapper {
    PostReportVO findByPostAndUser(@Param("postId") int postId, @Param("userId") int userId);
    void insert(@Param("postId") int postId, @Param("userId") int userId,
                @Param("reason") String reason, @Param("reasonDetail") String reasonDetail);
    void deleteByPostId(@Param("postId") int postId);

    // 게시글별 신고 사유 집계 (관리자 화면 요약 표시 전용, 별도 VO를 둘 만큼 재사용되지 않는 1회성 조회)
    List<Map<String, Object>> findReasonCounts(@Param("postId") int postId);

    // "기타" 사유로 남겨진 직접 입력 텍스트 목록 (관리자 상세보기 전용)
    List<String> findOtherReasonDetails(@Param("postId") int postId);
}
