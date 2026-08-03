package com.soldesk.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.soldesk.vo.ReservationVO;

public interface ResvMapper {

    List<ReservationVO> getRevList(
            @Param("userId") int userId);

    int countCompleted(@Param("userId") int userId);// 완료된 예약 건수

    int countByStylistId(int stylistId);// 이 디자이너를 참조하는 예약 건수 (삭제 가능 여부 판단용)
}