package com.soldesk.mapper;

import org.apache.ibatis.annotations.Param;

import com.soldesk.vo.OwnerRequestVO;

public interface OwnerRequestMapper {

    /** 점주 승격 요청 등록 */
    void insertRequest(OwnerRequestVO request);

    /** request_id로 조회 */
    OwnerRequestVO findById(int requestId);

    /** 대기중(pending)인 요청 수 — 관리자 회원관리 통계 카드용 */
    int countPending();

    /** 승인: 상태 변경 + 처리자/처리일시 기록 */
    void approve(@Param("requestId") int requestId, @Param("adminUserId") int adminUserId);

    /** 반려: 상태 변경 + 처리자/처리일시 기록 */
    void reject(@Param("requestId") int requestId, @Param("adminUserId") int adminUserId);
}
