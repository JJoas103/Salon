package com.soldesk.mapper;

import java.util.List;

import com.soldesk.vo.StylistVO;

// import org.apache.ibatis.annotations.Param;

public interface StylistMapper {

    // 매장 소속 디자이너 전체 조회
    List<StylistVO> findBySalonId(int salonId);

    StylistVO findById(int stylistId);

    void insertStylist(StylistVO stylist);

    void updateStylist(StylistVO stylist);

    void deleteStylist(int stylist);
}
