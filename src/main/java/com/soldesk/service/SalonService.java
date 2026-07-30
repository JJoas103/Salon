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
    private SalonSearchService salonSearchService;

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

    @Transactional(readOnly = true)
    public List<SalonVO> getSalonByOwner(int ownerId){
        return salonMapper.findAllByOwnerId(ownerId);
    }//점주 소유 매장 조회

    @Transactional(readOnly = true)
    public List<SalonVO> searchSalons(String keyword) throws Exception{
        //검색창을 비우고 검색하면 지도가 원래대로(전체 미용실) 돌아온다
        if(keyword == null || keyword.isBlank()){
            return getSalons();
        }

        return salonSearchService.search(keyword, 1, 50);
    }//키워드(미용실 이름 / 주소)로 검색하기
}
