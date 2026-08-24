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

    // 등록 시 요일 선택으로 자동 생성된 휴무 스케줄만 지운다(향후 날짜, 00:00~23:59, is_available=0
    // 패턴). 점주가 스케줄 설정에서 직접 만든 다른 행은 이 패턴과 다르므로 안 건드린다.
    // 디자이너 정보 수정에서 휴무일을 바꿀 때, 새로 생성하기 전에 먼저 호출한다.
    void deleteAutoDayOffSchedules(int stylistId);
}
