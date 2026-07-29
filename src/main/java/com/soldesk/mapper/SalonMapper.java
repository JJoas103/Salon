package com.soldesk.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.soldesk.vo.SalonVO;
import com.soldesk.vo.ServiceVO;

public interface SalonMapper {

    List<SalonVO> findAllWithMinimumPrice();

    SalonVO findById(int salonId);

    List<ServiceVO> findServicesBySalonId(int salonId);

    /** 점주(user_id) 기준 매장 조회 */
    List<SalonVO> findAllByOwnerId(int ownerId);
    //키워드로 검색하기. XML 에서 #{keyword} 를 두 번 쓰므로 @Param 으로 이름을 고정한다
    List<SalonVO> searchByKeyword(@Param("keyword") String keyword);
}
