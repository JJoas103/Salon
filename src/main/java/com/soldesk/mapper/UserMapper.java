package com.soldesk.mapper;

import java.util.List;
import org.apache.ibatis.annotations.Param;
import com.soldesk.vo.UserVO;

public interface UserMapper {

    /** 회원가입 */
    void insertUser(UserVO user);

    /** 이메일로 회원 조회 (로그인 / 중복확인) */
    UserVO findByEmail(String email);

    // user_id로 조회
    UserVO findById(int userId);

    // 이메일 기준 업데이트
    void updateUser(UserVO userVO);

    // 사용가능여부
    boolean isEmailAvailable(String userEmail);

    /** 이메일 중복 개수 */
    int countByEmail(String email);

    /** 전체 회원 수 (DB 연동 확인용) */
    int countAll();

    /* 회원 목록: 이름/이메일 부분검색 + role 필터 + 활성/탈퇴(status) 필터 + 페이지네이션 */
    List<UserVO> findMembers(@Param("keyword") String keyword, @Param("userType") String userType,
                             @Param("status") String status,
                             @Param("offset") int offset, @Param("size") int size);

    /* findMembers와 동일한 검색조건의 총 건수 */
    int countMembers(@Param("keyword") String keyword, @Param("userType") String userType, @Param("status") String status);

    /* 관리자 회원관리 대시보드 통계 카드용 */
    int countActiveMembers();
    int countNewMembersThisMonth();
    int countDeletedMembers();

    /* 점주/관리자 → 일반회원 강등 */
    void demoteToCustomer(int userId);

    /* 회원 삭제/탈퇴 */
    void softDeleteById(int userId);

    /* 회원 영구 삭제 */
    void deleteById(int userId);
}
