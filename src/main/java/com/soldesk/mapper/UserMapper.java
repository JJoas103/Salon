package com.soldesk.mapper;

import java.time.LocalDateTime;
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

    // 회원 제재(정지) 상태 갱신, user_id 기준
    void updateSuspension(@Param("userId") int userId, @Param("status") String status,
                          @Param("suspendedUntil") LocalDateTime suspendedUntil);

    // user_id로 삭제
    void deleteById(int userId);

    // 사용가능여부
    boolean isEmailAvailable(String userEmail);

    /** 이메일 중복 개수 */
    int countByEmail(String email);

    /** 전체 회원 수 (DB 연동 확인용) */
    int countAll();

    // 현재 제재중(정지/영구정지)인 회원 목록 -- CustomUserDetails.currentlySuspended와 동일한 조건
    List<UserVO> findSanctionedUsers();
}
