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
}