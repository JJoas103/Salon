package com.soldesk.mapper;

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

    // user_id로 삭제
    void deleteById(int userId);

    // 사용가능여부
    boolean isEmailAvailable(String userEmail);

    /** 이메일 중복 개수 */
    int countByEmail(String email);

    /** 전체 회원 수 (DB 연동 확인용) */
    int countAll();
}
