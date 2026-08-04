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

    /** 관리자 매장목록: 매장명/주소/점주명 검색 + 운영상태 필터 + 페이지네이션 */
    List<SalonVO> findSalonsForAdmin(@Param("keyword") String keyword,
                                      @Param("status") String status,
                                      @Param("offset") int offset,
                                      @Param("size") int size);

    /** findSalonsForAdmin과 동일 조건의 총 건수 */
    int countSalonsForAdmin(@Param("keyword") String keyword, @Param("status") String status);

    /** 관리자 대시보드 통계: 운영중 매장 수 */
    int countActiveSalons();

    /** 관리자 대시보드 통계: 이번 달 신규 등록 매장 수 */
    int countNewSalonsThisMonth();

    /** 관리자 대시보드 통계: 활성 예약 수 (pending/confirmed) */
    int countActiveReservations();

    /** 매장 폐업 처리 (soft delete, 이미 폐업된 매장 재처리 방지는 WHERE절에서 방어) */
    void closeSalon(int salonId);

    /** 매장 폐업 취소(재개) — 운영중인 매장 재처리 방지는 WHERE절에서 방어 */
    void reopenSalon(int salonId);

    /** 점주 승격 승인 시 매장 신규 생성 (매장명/연락처만 채우고 나머지는 점주가 직접 입력) */
    void insertSalon(SalonVO salon);

    /** 점주가 매장정보 관리 화면에서 직접 수정 */
    void updateSalonInfo(SalonVO salon);
}
