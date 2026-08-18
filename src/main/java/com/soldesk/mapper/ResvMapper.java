package com.soldesk.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.soldesk.vo.ReservationVO;
import com.soldesk.vo.SalonGradeVO;

public interface ResvMapper {

    List<ReservationVO> getRevList(@Param("userId") int userId);

    int countCompleted(@Param("userId") int userId);// 완료된 예약 건수

    /** 매장별 등급 산정용 — 완료 예약이 하나라도 있는 매장만, 매장별 완료 건수 */
    List<SalonGradeVO> findCompletedCountsBySalon(@Param("userId") int userId);

    int countByStylistId(int stylistId);// 이 디자이너를 참조하는 예약 건수 (삭제 가능 여부 판단용)

    /**
     * 한 디자이너의 특정 날짜에 이미 잡혀 있는 예약 시각들 ('HH:mm').
     * 결제 전(pending) 예약도 자리를 잡고 있어야 두 사람이 같은 시각을 동시에 고르는 일이 없다.
     * 단 결제창에서 이탈한 예약이 자리를 영원히 차지하면 안 되므로 10분이 지난 pending 은 제외한다.
     */
    List<String> findReservedTimes(@Param("stylistId") int stylistId,
                                    @Param("date") String date);

    /**
     * 그 자리가 아직 비어 있을 때만 예약을 넣는다.
     *
     * 슬롯 목록을 본 시점과 결제 버튼을 누른 시점 사이에 다른 사람이 같은 자리를
     * 채갈 수 있다. UNIQUE 제약으로는 막을 수 없는데, 취소된 예약도 같은
     * (stylist_id, reservation_time) 을 계속 차지해 그 시각을 영영 막아버리기 때문이다.
     * 그래서 "없을 때만 넣는" 한 문장으로 처리한다.
     *
     * @return 1이면 성공, 0이면 그 사이에 누가 먼저 잡은 것
     */
    int insertIfSlotFree(ReservationVO reservation);

    ReservationVO findById(int reservationId);

    /**
     * 그 자리를 지금 잡고 있는 결제 미완료 예약 1건.
     *
     * 확인 화면이 "자리가 찼다"고 판단했을 때, 막고 있는 것이 본인의 미완료 결제인지
     * 남의 예약인지 구분하려고 쓴다. 조건은 findReservedTimes 의 pending 쪽과 같다.
     *
     * @return 없으면 null
     */
    ReservationVO findPendingHold(@Param("stylistId") int stylistId,
                                  @Param("reservationTime") String reservationTime);

    /**
     * 결제창에서 이탈해 10분이 지난 예약들의 번호.
     *
     * 한 문장짜리 UPDATE 로 한꺼번에 접지 않고 번호를 먼저 뽑는다.
     * UPDATE 는 몇 건인지만 알려주고 어느 건인지는 알려주지 않는데,
     * 적립금·쿠폰은 예약번호로 묶여 있어 번호를 모르면 무엇을 되돌릴지 알 수 없기 때문이다.
     *
     * @return 접어야 할 예약번호 목록 (없으면 빈 목록)
     */
    List<Integer> findStalePendingIds();

    /** 결제 결과에 따라 pending → confirmed / cancelled */
    int updateStatus(@Param("reservationId") int reservationId,
                     @Param("status") String status);

    /** 사용자가 자신의 확정 예약을 취소 */
    int cancelReservation(@Param("reservationId") int reservationId,
                          @Param("userId") int userId);

    // 점주 예약현황관리: 이 매장의 전체 예약 목록 한 페이지 (고객명/연락처/디자이너명 포함, 최신순)
    List<ReservationVO> findBySalonId(@Param("salonId") int salonId,
                                       @Param("offset") int offset,
                                       @Param("limit") int limit);

    int countBySalonId(int salonId);

    // 점주가 확정된 예약을 정리(거절/노쇼). 대기/이미 취소된 건은 건드리지 않는다. 1이면 성공
    int rejectReservation(@Param("reservationId") int reservationId,
                           @Param("rejectReason") String rejectReason,
                           @Param("cancelType") String cancelType);

    // 예약현황판: 매장 전체의 그 날 예약을 한 번에 (디자이너마다 조회하면 N+1)
    List<ReservationVO> findBySalonIdAndDate(@Param("salonId") int salonId,
                                              @Param("date") String date);
}