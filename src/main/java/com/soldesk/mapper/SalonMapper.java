package com.soldesk.mapper;

import java.util.List;

import com.soldesk.vo.SalonVO;

public interface SalonMapper {
    
    List<SalonVO> getSalonById(int salonId);    //id로 미용실 정보들 가져오기
}
