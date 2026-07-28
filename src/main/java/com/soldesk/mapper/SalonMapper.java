package com.soldesk.mapper;

import com.soldesk.vo.SalonVO;

public interface SalonMapper {

    /** 점주(user_id) 기준 매장 조회 */
    SalonVO findByOwnerId(int ownerId);
}
