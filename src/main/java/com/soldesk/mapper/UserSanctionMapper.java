package com.soldesk.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.soldesk.vo.UserSanctionVO;

public interface UserSanctionMapper {
    void insert(UserSanctionVO sanction);

    // 회원별 제재 이력 (최신순)
    List<UserSanctionVO> findByUserId(@Param("userId") int userId);
}
