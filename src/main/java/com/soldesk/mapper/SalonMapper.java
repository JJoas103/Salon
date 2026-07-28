package com.soldesk.mapper;

import java.util.List;

import com.soldesk.vo.SalonVO;
import com.soldesk.vo.ServiceVO;

public interface SalonMapper {

    List<SalonVO> findAllWithMinimumPrice();

    SalonVO findById(int salonId);

    List<ServiceVO> findServicesBySalonId(int salonId);
}
