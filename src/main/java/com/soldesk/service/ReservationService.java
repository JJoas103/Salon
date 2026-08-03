package com.soldesk.service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.soldesk.mapper.ResvMapper;
import com.soldesk.mapper.SalonMapper;
import com.soldesk.mapper.StylistMapper;
import com.soldesk.mapper.StylistScheduleMapper;
import com.soldesk.vo.ReservationVO;
import com.soldesk.vo.SalonOperatingHourVO;
import com.soldesk.vo.StylistScheduleVO;
import com.soldesk.vo.StylistVO;
import com.soldesk.vo.TimeSlotVO;

@Service
public class ReservationService {

    /** 예약 단위. 시술 소요시간과 무관하게 30분 간격으로만 시작할 수 있다. */
    private static final int SLOT_MINUTES = 30;

    /** DB 의 day_of_week 는 ENUM('월','화',...) 한글이라 java 의 DayOfWeek 를 그대로 못 쓴다. */
    private static final String[] DAY_KO = { "월", "화", "수", "목", "금", "토", "일" };

    private static final DateTimeFormatter HHMM = DateTimeFormatter.ofPattern("HH:mm");

    @Autowired
    private ResvMapper resvMapper;

    @Autowired
    private SalonMapper salonMapper;

    @Autowired
    private StylistMapper stylistMapper;

    @Autowired
    private StylistScheduleMapper scheduleMapper;

    @Transactional
    public List<ReservationVO> getRevList(int userId){
        List<ReservationVO> list = resvMapper.getRevList(userId);
        return list;
    }

    @Transactional
    public int countCompleted(int userId){
        return resvMapper.countCompleted(userId);
    }

    /**
     * 한 디자이너의 특정 날짜에 고를 수 있는 시간대를 만든다.
     *
     *   매장 영업시간 ∩ 디자이너 근무시간  →  30분 간격으로 자름  →  이미 찬 시각 / 지난 시각 표시
     *
     * 시술 소요시간은 여기에 관여하지 않는다. 10:30(1시간)과 11:00(30분)이 겹쳐도
     * 디자이너가 감당할 수 있으면 문제없다는 것이 이 서비스의 규칙이고,
     * 감당이 안 되는 자리는 점주가 직접 막는다.
     *
     * @param stylistId 디자이너
     * @param date      'yyyy-MM-dd'
     * @return 마감분까지 포함한 그 날의 전체 시간대. 휴무거나 근무가 없으면 빈 목록.
     */
    @Transactional(readOnly = true)
    public List<TimeSlotVO> getAvailableSlots(int stylistId, String date) {
        LocalDate targetDate = LocalDate.parse(date);

        // 지난 날짜는 아예 볼 필요가 없다
        if (targetDate.isBefore(LocalDate.now())) {
            return List.of();
        }

        StylistVO stylist = stylistMapper.findById(stylistId);
        if (stylist == null) {
            return List.of();
        }

        // 1) 매장 영업시간 — 그 요일 행이 없으면 휴무다
        String dayKo = DAY_KO[targetDate.getDayOfWeek().getValue() - 1];
        SalonOperatingHourVO hour = salonMapper.findOperatingHour(stylist.getSalonId(), dayKo);
        if (hour == null) {
            return List.of();
        }
        LocalTime windowStart = LocalTime.parse(hour.getOpenTime());
        LocalTime windowEnd = LocalTime.parse(hour.getCloseTime());

        // 2) 디자이너 근무시간으로 한 번 더 좁힌다.
        //    등록된 스케줄이 없으면 매장 영업시간 내내 근무하는 것으로 본다.
        //    (점주가 스케줄을 넣지 않았다고 예약이 아예 막히면 오히려 곤란하다)
        StylistScheduleVO condition = new StylistScheduleVO();
        condition.setStylistId(stylistId);
        condition.setDate(date);
        StylistScheduleVO schedule = scheduleMapper.findByStylistIdAndDate(condition);

        if (schedule != null) {
            if (!schedule.getIsAvailable()) {
                return List.of(); // 점주가 그 날 쉬는 것으로 등록했다
            }
            LocalTime scheduleStart = LocalTime.parse(schedule.getStartTime());
            LocalTime scheduleEnd = LocalTime.parse(schedule.getEndTime());
            if (scheduleStart.isAfter(windowStart)) windowStart = scheduleStart;
            if (scheduleEnd.isBefore(windowEnd)) windowEnd = scheduleEnd;
        }

        if (!windowStart.isBefore(windowEnd)) {
            return List.of(); // 겹치는 구간이 없다
        }

        // 3) 이미 찬 시각과, 오늘이라면 이미 지나간 시각
        Set<String> reserved = new HashSet<>(resvMapper.findReservedTimes(stylistId, date));
        LocalDateTime now = LocalDateTime.now();

        List<TimeSlotVO> slots = new ArrayList<>();
        for (LocalTime t = windowStart; t.isBefore(windowEnd); t = t.plusMinutes(SLOT_MINUTES)) {
            String label = t.format(HHMM);
            boolean past = targetDate.atTime(t).isBefore(now);
            slots.add(new TimeSlotVO(label, !past && !reserved.contains(label)));
        }
        return slots;
    }
}
