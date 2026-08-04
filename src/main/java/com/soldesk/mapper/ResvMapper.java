package com.soldesk.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.soldesk.vo.ReservationVO;

public interface ResvMapper {

    List<ReservationVO> getRevList(
            @Param("userId") int userId);

    int countCompleted(@Param("userId") int userId);// 완료된 예약 건수

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

    /** 결제 결과에 따라 pending → confirmed / cancelled */
    int updateStatus(@Param("reservationId") int reservationId,
                     @Param("status") String status);
}