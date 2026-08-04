package com.soldesk.mapper;

import java.util.List;

import com.soldesk.vo.StylistScheduleVO;

public interface StylistScheduleMapper {

    // 디자이너 개인 스케줄
    List<StylistScheduleVO> findByStylistId(int stylistId);

    StylistScheduleVO findByStylistIdAndDate(StylistScheduleVO condition);

    StylistScheduleVO findById(int scheduleId);

    void insertSchedule(StylistScheduleVO schedule);

    void updateSchedule(StylistScheduleVO schedule);

    void deleteSchedule(int scheduleId);
} 
