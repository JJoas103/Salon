package com.soldesk.service;

import java.util.List;

import java.time.LocalDate;
import java.util.ArrayList;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.soldesk.mapper.StylistMapper;
import com.soldesk.mapper.StylistScheduleMapper;
import com.soldesk.vo.StylistScheduleVO;
import com.soldesk.vo.StylistVO;

@Service
public class StylistService {

    @Autowired
    private StylistMapper stylistMapper;

    @Autowired
    private StylistScheduleMapper scheduleMapper;

    @Transactional
    public List<StylistVO> findBySalonId(int salonId) {
        return stylistMapper.findBySalonId(salonId);
    }

    /** 예약 캘린더용 — 이 디자이너가 예약 가능으로 등록한 앞으로의 날짜 목록 (로그인/소유 여부와 무관하게 공개) */
    @Transactional(readOnly = true)
    public List<String> getAvailableDates(int stylistId) {
        LocalDate today = LocalDate.now();
        List<StylistScheduleVO> schedules = scheduleMapper.findByStylistId(stylistId);
        List<String> dates = new ArrayList<>();
        for (StylistScheduleVO s : schedules) {
            if (s.getIsAvailable() && !LocalDate.parse(s.getDate()).isBefore(today)) {
                dates.add(s.getDate());
            }
        }
        return dates;
    }

    @Transactional
    public StylistVO findByStylistId(int stylistId) {
        return stylistMapper.findById(stylistId);
    }
}
