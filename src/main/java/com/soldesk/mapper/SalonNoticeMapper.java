package com.soldesk.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.soldesk.vo.SalonNoticeVO;

public interface SalonNoticeMapper {

    List<SalonNoticeVO> findBySalonId(int salonId);
    SalonNoticeVO findByIdAndSalonId(@Param("noticeId") int noticeId, @Param("salonId") int salonId);
    int insert(SalonNoticeVO notice);
    int deleteByIdAndSalonId(@Param("noticeId") int noticeId, @Param("salonId") int salonId);
}
