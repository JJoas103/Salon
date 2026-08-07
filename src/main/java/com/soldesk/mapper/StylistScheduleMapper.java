package com.soldesk.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.soldesk.vo.StylistScheduleVO;

public interface StylistScheduleMapper {

    // 디자이너 개인 스케줄
    List<StylistScheduleVO> findByStylistId(int stylistId);

    StylistScheduleVO findByStylistIdAndDate(StylistScheduleVO condition);

    // 예약현황판: 매장 전체 디자이너의 그 날 스케줄을 한 번에 (디자이너마다 조회하면 N+1)
    List<StylistScheduleVO> findBySalonIdAndDate(@Param("salonId") int salonId,
                                                  @Param("date") String date);

    StylistScheduleVO findById(int scheduleId);

    void insertSchedule(StylistScheduleVO schedule);

    void updateSchedule(StylistScheduleVO schedule);

    void deleteSchedule(int scheduleId);
} 
