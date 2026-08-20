package com.soldesk.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.soldesk.vo.OwnerRequestVO;

public interface OwnerRequestMapper {

    /** 점주 승격 요청 등록 */
    void insertRequest(OwnerRequestVO request);

    /** request_id로 조회 */
    OwnerRequestVO findById(int requestId);

    /** 대기중(pending)인 요청 수 — 관리자 회원관리 통계 카드용 */
    int countPending();

    /** 대기중인 요청 수를 종류별로 — "점주 승격 요청"/"매장 추가 요청" 탭을 따로 만들면서 필요해짐 */
    int countPendingByType(String requestType);

    /** 종류별 대기중인 요청 목록(신청자 이름/이메일 포함) — 매장관리 "매장 추가 요청" 탭용 */
    List<OwnerRequestVO> findPendingByType(String requestType);

    /** 이 회원이 이미 대기중인 요청을 갖고 있는지 — 승격/매장추가 요청 중복 제출 방지용 */
    int countPendingByUserId(int userId);

    /** 승인: 상태 변경 + 처리자/처리일시 기록 */
    void approve(@Param("requestId") int requestId, @Param("adminUserId") int adminUserId);

    /** 반려: 상태 변경 + 처리자/처리일시 기록 */
    void reject(@Param("requestId") int requestId, @Param("adminUserId") int adminUserId);
}
