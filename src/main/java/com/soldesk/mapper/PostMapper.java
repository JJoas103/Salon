package com.soldesk.mapper;

import com.soldesk.vo.PostVO;
import org.apache.ibatis.annotations.Param;
import java.util.List;

public interface PostMapper {

    List<PostVO> findAll(@Param("sort") String sort, @Param("offset") int offset, @Param("size") int size);

    int countAll();

    List<PostVO> findByCategory(@Param("category") String category, @Param("sort") String sort,
                                 @Param("offset") int offset, @Param("size") int size);

    int countByCategory(@Param("category") String category);

    // 마이페이지 "내가 쓴 글" 탭 -- 개수가 작아 페이지네이션 없이 전체 조회
    List<PostVO> findByUserId(@Param("userId") int userId);

    PostVO findById(int postId);

    PostVO findByIdAny(int postId); // 상태(블라인드) 무시하고 조회 -- 관리자 전용

    List<PostVO> findBlinded(); // 블라인드된 게시글 목록 -- 관리자 대시보드

    void insert(PostVO post);

    void update(PostVO post);

    void delete(int postId);

    // 글 삭제 -- 하드 삭제 대신 소프트 삭제 (댓글이 참조하는 행을 남겨 마이페이지 로그로 보존)
    void softDelete(int postId);

    void incrementViewCount(int postId);

    void incrementLikeCount(int postId);
    void decrementLikeCount(int postId);
    void incrementDislikeCount(int postId);
    void decrementDislikeCount(int postId);

    void incrementReportCount(int postId);
    void blindPost(int postId);
    void unblindPost(int postId);
    void resetReportCount(int postId);

    // 작성자 기준 현재 살아있는 글들의 신고 누적 합계 (관리자 화면 표시 전용)
    int sumReportCountByAuthor(@Param("userId") int userId);

    List<PostVO> search(@Param("searchType") String searchType, @Param("keyword") String keyword,
                         @Param("sort") String sort, @Param("offset") int offset, @Param("size") int size);

    int countSearch(@Param("searchType") String searchType, @Param("keyword") String keyword);
}
