package com.soldesk.mapper;

import com.soldesk.vo.UserVO;

public interface UserMapper {

    /** 회원가입 */
    void insertUser(UserVO user);

    /** 이메일로 회원 조회 (로그인 / 중복확인) */
    UserVO findByEmail(String email);

    /** 이메일 중복 개수 */
    int countByEmail(String email);

    /** 전체 회원 수 (DB 연동 확인용) */
    int countAll();
}
