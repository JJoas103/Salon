package com.soldesk.mapper;

import java.util.List;

import com.soldesk.vo.SalonVO;
import com.soldesk.vo.ServiceVO;

public interface SalonMapper {

    List<SalonVO> findAllWithMinimumPrice();

    SalonVO findById(int salonId);

    List<ServiceVO> findServicesBySalonId(int salonId);

    /** 점주(user_id) 기준 매장 조회 */
    SalonVO findByOwnerId(int ownerId);
}
