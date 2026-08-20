package com.soldesk.service;

import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

import com.soldesk.mapper.SalonMapper;
import com.soldesk.vo.SalonOperatingHourVO;
import com.soldesk.vo.SalonVO;
import com.soldesk.vo.ServiceVO;
// import com.soldesk.vo.StylistVO;

@Service
public class SalonService {

    private static final Logger log = LoggerFactory.getLogger(SalonService.class);

    @Autowired
    private SalonSearchService salonSearchService;

    @Autowired
    private SalonMapper salonMapper;

    @Autowired
    private RestTemplate restTemplate;

    @Value("${fastapi.url}")
    private String fastApiUrl;

    @Transactional(readOnly = true)
    public List<SalonVO> getSalons() {
        return salonMapper.findAllWithMinimumPrice();
    }// 모든 미용실정보 가져오기 평점 내림차순

    @Transactional(readOnly = true)
    public SalonVO getSalon(int salonId) {
        return salonMapper.findById(salonId);
    }// ID로 미용실 정보 가져오기

    @Transactional(readOnly = true)
    public List<ServiceVO> getServices(int salonId) {
        return salonMapper.findServicesBySalonId(salonId);
    }// ID로 시술정보 가져오기

    /** 매장 구분 없는 전체 시술 카탈로그. AI 시술 추천 챗봇(ai-service)의 /api/services 호출용 */
    @Transactional(readOnly = true)
    public List<ServiceVO> getAllServices() {
        return salonMapper.findAllServices();
    }

    @Transactional(readOnly = true)
    public List<SalonVO> getSalonByOwner(int ownerId) {
        return salonMapper.findAllByOwnerId(ownerId);
    }// 점주 소유 매장 조회

    @Transactional(readOnly = true)
    public List<SalonVO> searchSalons(String keyword) throws Exception {
        // 검색창을 비우고 검색하면 지도가 원래대로(전체 미용실) 돌아온다
        if (keyword == null || keyword.isBlank()) {
            return getSalons();
        }

        return salonSearchService.search(keyword, 1, 50);
    }// 키워드(미용실 이름 / 주소)로 검색하기

    @Transactional(readOnly = true)
    public List<SalonVO> getSalonsForAdmin(String keyword, String status, int page, int size) {
        int offset = (page - 1) * size;
        return salonMapper.findSalonsForAdmin(keyword, status, offset, size);
    }// 관리자 매장 목록 (검색/운영상태 필터 + 페이지네이션)

    @Transactional(readOnly = true)
    public int countSalonsForAdmin(String keyword, String status) {
        return salonMapper.countSalonsForAdmin(keyword, status);
    }// 현재 검색조건의 총 건수 (총 페이지 수 계산용)

    @Transactional(readOnly = true)
    public int countActiveSalons() {
        return salonMapper.countActiveSalons();
    }

    @Transactional(readOnly = true)
    public int countNewSalonsThisMonth() {
        return salonMapper.countNewSalonsThisMonth();
    }

    @Transactional(readOnly = true)
    public int countActiveReservations() {
        return salonMapper.countActiveReservations();
    }

    @Transactional
    public void closeSalon(int salonId) {
        SalonVO salon = salonMapper.findById(salonId);
        if (salon == null) {
            throw new IllegalArgumentException("존재하지 않는 매장입니다.");
        }
        if (salon.getClosedAt() != null) {
            throw new IllegalArgumentException("이미 폐업 처리된 매장입니다.");
        }
        salonMapper.closeSalon(salonId);
    }// 매장 폐업 처리: 존재하지 않거나 이미 폐업된 매장 재처리 방지

    @Transactional
    public void reopenSalon(int salonId) {
        SalonVO salon = salonMapper.findById(salonId);
        if (salon == null) {
            throw new IllegalArgumentException("존재하지 않는 매장입니다.");
        }
        if (salon.getClosedAt() == null) {
            throw new IllegalArgumentException("이미 운영중인 매장입니다.");
        }
        salonMapper.reopenSalon(salonId);
    }// 매장 폐업 취소(재개): 존재하지 않거나 이미 운영중인 매장 재처리 방지

    @Transactional
    public void updateSalonInfo(int ownerId, SalonVO salon) {
        SalonVO existing = salonMapper.findById(salon.getSalonId());
        if (existing == null || existing.getOwnerId() != ownerId) {
            throw new IllegalArgumentException("본인 소유의 매장만 수정할 수 있습니다.");
        }
        if (salon.getSalonName() == null || salon.getSalonName().trim().isEmpty()) {
            throw new IllegalArgumentException("매장명을 입력해주세요.");
        }
        // 화면(pattern="[0-9-]{9,13}")과 같은 규칙 — 폼 검증을 우회해 바로 요청을 보내는 경우까지 막는다
        if (salon.getPhoneNumber() == null || !salon.getPhoneNumber().matches("[0-9-]{9,13}")) {
            throw new IllegalArgumentException("연락처는 숫자와 하이픈(-)만 사용해 입력해주세요.");
        }
        salon.setSalonName(salon.getSalonName().trim());
        salonMapper.updateSalonInfo(salon);
        // 검색은 엘라스틱서치가 답한다. 여기서 색인을 같이 갱신하지 않으면 점주가 주소를 고쳐도
        // 재기동 전까지 검색 결과에 옛 주소·좌표가 그대로 나온다.
        salonSearchService.indexSalon(salon.getSalonId());
    }// 점주가 매장정보 관리 화면에서 직접 수정 (소유 검증)

    @Transactional(readOnly = true)
    public SalonVO getSalonForOwner(int salonId, int ownerId) {
        SalonVO salon = salonMapper.findById(salonId);
        if (salon == null || salon.getOwnerId() != ownerId) {
            throw new IllegalArgumentException("본인 소유의 매장만 조회할 수 있습니다.");
        }
        return salon;
    }// 매장정보 관리 화면 조회용 (소유 검증) — select-salon 자체는 소유 검증이 없어 세션의 selectedSalonId가 타인
     // 매장일 수 있음

    private void assertOwnsSalon(int salonId, int ownerId) {
        SalonVO salon = salonMapper.findById(salonId);
        if (salon == null || salon.getOwnerId() != ownerId) {
            throw new IllegalArgumentException("본인 소유의 매장만 관리할 수 있습니다.");
        }
    }

    @Transactional
    public void registerService(int ownerId, ServiceVO service) {
        assertOwnsSalon(service.getSalonId(), ownerId);
        salonMapper.insertService(service);
        triggerAiReindex();
    }// 점주 시술 메뉴 등록 (소유 검증)

    @Transactional
    public void updateService(int ownerId, ServiceVO service) {
        ServiceVO existing = salonMapper.findServiceById(service.getServiceId());
        if (existing == null) {
            throw new IllegalArgumentException("존재하지 않는 메뉴입니다.");
        }
        assertOwnsSalon(existing.getSalonId(), ownerId);
        service.setSalonId(existing.getSalonId());
        salonMapper.updateService(service);
        triggerAiReindex();
    }// 점주 시술 메뉴 수정 (소유 검증)

    @Transactional
    public void deleteService(int ownerId, int serviceId) {
        ServiceVO existing = salonMapper.findServiceById(serviceId);
        if (existing == null) {
            throw new IllegalArgumentException("존재하지 않는 메뉴입니다.");
        }
        assertOwnsSalon(existing.getSalonId(), ownerId);
        salonMapper.deleteService(serviceId);
        triggerAiReindex();
    }// 점주 시술 메뉴 삭제 (소유 검증)

    @Transactional(readOnly = true)
    public List<SalonOperatingHourVO> getOperatingHours(int salonId) {
        return salonMapper.findAllOperatingHours(salonId);
    }// 매장정보 관리 화면의 영업시간 표 채우기용

    /**
     * 영업시간 전체를 지우고 다시 넣는다. 요일별로 열려있는지/시간이 뭔지는 화면에서
     * 이미 걸러서 보내주므로(휴무면 그 요일은 hours 에 아예 없음), 여기서는 소유 검증만 하고 그대로 반영한다.
     */
    @Transactional
    public void updateOperatingHours(int ownerId, int salonId, List<SalonOperatingHourVO> hours) {
        assertOwnsSalon(salonId, ownerId);
        salonMapper.deleteOperatingHours(salonId);
        for (SalonOperatingHourVO hour : hours) {
            hour.setSalonId(salonId);
            salonMapper.insertOperatingHour(hour);
        }
    }// 점주가 매장정보 관리에서 직접 저장하는 영업시간 (소유 검증)

    @Transactional(readOnly = true)
    public List<SalonVO> getPreparingSalons() {
        return salonMapper.findPreparingSalons();
    }// 관리자 "심사 대기" 큐 (2차 승인 전)

    @Transactional
    public void activateSalon(int salonId) {
        SalonVO salon = salonMapper.findById(salonId);
        if (salon == null) {
            throw new IllegalArgumentException("존재하지 않는 매장입니다.");
        }
        if (salonMapper.activateSalon(salonId) == 0) {
            throw new IllegalArgumentException("이미 활성화되었거나 승인 대기 상태가 아닙니다.");
        }
    }// 관리자 2차 승인 — 손님에게 정상 노출
    /** 시술 메뉴가 바뀔 때마다 ai-service 의 검색 인덱스를 즉시 새로고침한다.
     *  ai-service 가 꺼져 있어도 점주의 메뉴 등록/수정/삭제 자체는 막으면 안 되므로 예외를 삼킨다 —
     *  다음 CRUD 나 ai-service 재기동 시 어차피 최신 상태로 다시 맞춰진다. */
    private void triggerAiReindex() {
        try {
            restTemplate.postForEntity(fastApiUrl + "/api/reindex", null, Void.class);
        } catch (RestClientException e) {
            log.warn("ai-service 재색인 요청 실패 (ai-service 가 꺼져 있을 수 있음): {}", e.getMessage());
        }
    }
}
