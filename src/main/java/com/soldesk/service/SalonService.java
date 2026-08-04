package com.soldesk.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.soldesk.mapper.SalonMapper;
import com.soldesk.vo.SalonVO;
import com.soldesk.vo.ServiceVO;
import com.soldesk.vo.StylistVO;

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

    @Transactional(readOnly = true)
    public List<SalonVO> getSalonsForAdmin(String keyword, String status, int page, int size){
        int offset = (page - 1) * size;
        return salonMapper.findSalonsForAdmin(keyword, status, offset, size);
    }//관리자 매장 목록 (검색/운영상태 필터 + 페이지네이션)

    @Transactional(readOnly = true)
    public int countSalonsForAdmin(String keyword, String status){
        return salonMapper.countSalonsForAdmin(keyword, status);
    }//현재 검색조건의 총 건수 (총 페이지 수 계산용)

    @Transactional(readOnly = true)
    public int countActiveSalons(){
        return salonMapper.countActiveSalons();
    }

    @Transactional(readOnly = true)
    public int countNewSalonsThisMonth(){
        return salonMapper.countNewSalonsThisMonth();
    }

    @Transactional(readOnly = true)
    public int countActiveReservations(){
        return salonMapper.countActiveReservations();
    }

    @Transactional
    public void closeSalon(int salonId){
        SalonVO salon = salonMapper.findById(salonId);
        if(salon == null){
            throw new IllegalArgumentException("존재하지 않는 매장입니다.");
        }
        if(salon.getClosedAt() != null){
            throw new IllegalArgumentException("이미 폐업 처리된 매장입니다.");
        }
        salonMapper.closeSalon(salonId);
    }//매장 폐업 처리: 존재하지 않거나 이미 폐업된 매장 재처리 방지

    @Transactional
    public void reopenSalon(int salonId){
        SalonVO salon = salonMapper.findById(salonId);
        if(salon == null){
            throw new IllegalArgumentException("존재하지 않는 매장입니다.");
        }
        if(salon.getClosedAt() == null){
            throw new IllegalArgumentException("이미 운영중인 매장입니다.");
        }
        salonMapper.reopenSalon(salonId);
    }//매장 폐업 취소(재개): 존재하지 않거나 이미 운영중인 매장 재처리 방지

    @Transactional
    public void updateSalonInfo(int ownerId, SalonVO salon){
        SalonVO existing = salonMapper.findById(salon.getSalonId());
        if(existing == null || existing.getOwnerId() != ownerId){
            throw new IllegalArgumentException("본인 소유의 매장만 수정할 수 있습니다.");
        }
        salonMapper.updateSalonInfo(salon);
    }//점주가 매장정보 관리 화면에서 직접 수정 (소유 검증)

    @Transactional(readOnly = true)
    public SalonVO getSalonForOwner(int salonId, int ownerId){
        SalonVO salon = salonMapper.findById(salonId);
        if(salon == null || salon.getOwnerId() != ownerId){
            throw new IllegalArgumentException("본인 소유의 매장만 조회할 수 있습니다.");
        }
        return salon;
    }//매장정보 관리 화면 조회용 (소유 검증) — select-salon 자체는 소유 검증이 없어 세션의 selectedSalonId가 타인 매장일 수 있음
}
