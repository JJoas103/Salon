package com.soldesk.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.soldesk.mapper.SalonMapper;
import com.soldesk.vo.SalonVO;
import com.soldesk.vo.ServiceVO;

@Service
public class SalonService {

    @Autowired
    private SalonMapper salonMapper;

    @Transactional(readOnly = true)
    public List<SalonVO> getSalons() {  
        return salonMapper.findAllWithMinimumPrice();
    }//모든 미용실정보 가져오기 평점 내림차순

    @Transactional(readOnly = true)
    public SalonVO getSalon(int salonId) {
        return salonMapper.findById(salonId);
    }//ID로 미용실 정보 가져오기

    @Transactional(readOnly = true)
    public List<ServiceVO> getServices(int salonId) {
        return salonMapper.findServicesBySalonId(salonId);
    }//ID로 시술정보 가져오기
}
