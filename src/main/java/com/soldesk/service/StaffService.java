package com.soldesk.service;

import java.io.IOException;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.soldesk.mapper.ResvMapper;
import com.soldesk.mapper.SalonMapper;
import com.soldesk.mapper.StylistMapper;
import com.soldesk.mapper.StylistScheduleMapper;
import com.soldesk.vo.SalonVO;
import com.soldesk.vo.StylistVO;
import com.soldesk.vo.StylistScheduleVO;

@Service
public class StaffService {
    @Autowired
    private SalonMapper salonMapper;
    @Autowired
    private StylistMapper stylistMapper;
    @Autowired
    private StylistScheduleMapper scheduleMapper;
    @Autowired
    private ResvMapper resvMapper;
    @Autowired
    private FileService fileService;

    // 이 매장이 진짜 이 점주 것인지 확인 — 아니면 예외.
    // 등록/수정/삭제 전에 반드시 먼저 호출한다.
    private void assertOwnsSalon(int salonId, int ownerId) {
        SalonVO salon = salonMapper.findById(salonId);
        if (salon == null || salon.getOwnerId() != ownerId) {
            throw new IllegalArgumentException("본인 매장이 아닙니다.");
        }
    }

    // 이 디자이너가 진짜 이 점주 소유 매장 소속인지 확인 (스케줄 등록 시 사용)
    private StylistVO assertOwnsStylist(int stylistId, int ownerId) {
        StylistVO stylist = stylistMapper.findById(stylistId);
        if (stylist == null)
            throw new IllegalArgumentException("존재하지 않는 디자이너입니다.");
        assertOwnsSalon(stylist.getSalonId(), ownerId);
        return stylist;
    }

    // 이름 공백 검증 + 같은 매장 내 중복 이름 검증 (excludeStylistId: 수정 시 자기 자신은 제외, 없으면 -1)
    private void assertValidName(int salonId, String stylistName, int excludeStylistId) {
        if (stylistName == null || stylistName.trim().isEmpty()) {
            throw new IllegalArgumentException("디자이너 이름을 입력해주세요.");
        }
        for (StylistVO existing : stylistMapper.findBySalonId(salonId)) {
            if (existing.getStylistId() != excludeStylistId && existing.getStylistName().equals(stylistName.trim())) {
                throw new IllegalArgumentException("이미 등록된 이름입니다.");
            }
        }
    }

    @Transactional
    public List<StylistVO> getStylists(int salonId, int ownerId) {
        assertOwnsSalon(salonId, ownerId);
        return stylistMapper.findBySalonId(salonId);
    }

    @Transactional
    public void registerStylist(int salonId, int ownerId, StylistVO stylist, MultipartFile imageFile)
            throws IOException {
        assertOwnsSalon(salonId, ownerId);
        assertValidName(salonId, stylist.getStylistName(), -1);
        stylist.setStylistName(stylist.getStylistName().trim());
        stylist.setSalonId(salonId);
        String saved = fileService.saveFile(imageFile);
        if (saved != null) {
            stylist.setImageUrl("/upload/" + saved);
        }
        stylistMapper.insertStylist(stylist);
    }

    @Transactional
    public void updateStylist(int ownerId, StylistVO stylist, MultipartFile imageFile) throws IOException {
        StylistVO current = assertOwnsStylist(stylist.getStylistId(), ownerId);
        assertValidName(current.getSalonId(), stylist.getStylistName(), stylist.getStylistId());
        stylist.setStylistName(stylist.getStylistName().trim());
        String saved = fileService.saveFile(imageFile);
        if (saved != null) {
            fileService.deleteFile(stripUploadPrefix(current.getImageUrl()));
            stylist.setImageUrl("/upload/" + saved);
        } else {
            stylist.setImageUrl(current.getImageUrl());
        }
        stylistMapper.updateStylist(stylist);
    }

    @Transactional
    public void deleteStylist(int stylistId, int ownerId) {
        StylistVO stylist = assertOwnsStylist(stylistId, ownerId);
        if (!scheduleMapper.findByStylistId(stylistId).isEmpty()) {
            throw new IllegalArgumentException("등록된 스케줄이 있는 디자이너는 삭제할 수 없습니다. 스케줄을 먼저 정리해주세요.");
        }
        if (resvMapper.countByStylistId(stylistId) > 0) {
            throw new IllegalArgumentException("예약 이력이 있는 디자이너는 삭제할 수 없습니다.");
        }
        fileService.deleteFile(stripUploadPrefix(stylist.getImageUrl()));
        stylistMapper.deleteStylist(stylistId);
    }

    private String stripUploadPrefix(String imageUrl) {
        if (imageUrl != null && imageUrl.startsWith("/upload/")) {
            return imageUrl.substring("/upload/".length());
        }
        return null;
    }

    @Transactional
    public List<StylistScheduleVO> getSchedules(int stylistId, int ownerId) {
        assertOwnsStylist(stylistId, ownerId);
        return scheduleMapper.findByStylistId(stylistId);
    }

    // 연속된 날짜가 시작/종료시간·예약가능여부까지 전부 같으면 한 그룹으로 묶어서 목록에 보여준다 (스케줄 설정 모달의 표시 방식과 동일)
    @Transactional
    public List<Map<String, Object>> getScheduleGroups(int stylistId, int ownerId) {
        List<StylistScheduleVO> schedules = getSchedules(stylistId, ownerId);
        List<Map<String, Object>> groups = new ArrayList<>();
        int i = 0;
        while (i < schedules.size()) {
            StylistScheduleVO first = schedules.get(i);
            List<Integer> ids = new ArrayList<>();
            ids.add(first.getScheduleId());
            int j = i;
            while (j + 1 < schedules.size()) {
                StylistScheduleVO cur = schedules.get(j);
                StylistScheduleVO next = schedules.get(j + 1);
                boolean consecutive = LocalDate.parse(cur.getDate()).plusDays(1)
                        .equals(LocalDate.parse(next.getDate()));
                boolean sameTime = next.getStartTime().equals(first.getStartTime())
                        && next.getEndTime().equals(first.getEndTime())
                        && next.getIsAvailable() == first.getIsAvailable();
                if (consecutive && sameTime) {
                    j++;
                    ids.add(next.getScheduleId());
                } else {
                    break;
                }
            }
            Map<String, Object> group = new HashMap<>();
            group.put("label", formatRangeLabel(first.getDate(), schedules.get(j).getDate()));
            group.put("startTime", first.getStartTime());
            group.put("endTime", first.getEndTime());
            group.put("isAvailable", first.getIsAvailable());
            group.put("scheduleIds", ids);
            groups.add(group);
            i = j + 1;
        }
        return groups;
    }

    private static final String[] WEEKDAY_NAMES = { "월", "화", "수", "목", "금", "토", "일" }; // DayOfWeek.getValue(): 월=1
                                                                                         // ... 일=7

    // 단일 날짜: 2026-08-15(금) / 범위: 같은 달이면 2026-08-05~09, 다른 달이면 2026-07-31~08-03
    private String formatRangeLabel(String startStr, String endStr) {
        if (startStr.equals(endStr)) {
            DayOfWeek dow = LocalDate.parse(startStr).getDayOfWeek();
            return startStr + "(" + WEEKDAY_NAMES[dow.getValue() - 1] + ")";
        }
        String[] startParts = startStr.split("-");
        String[] endParts = endStr.split("-");
        String endLabel;
        if (!startParts[0].equals(endParts[0])) {
            endLabel = endStr;
        } else if (!startParts[1].equals(endParts[1])) {
            endLabel = endParts[1] + "-" + endParts[2];
        } else {
            endLabel = endParts[2];
        }
        return startStr + "~" + endLabel;
    }

    @Transactional
    public void deleteSchedules(List<Integer> scheduleIds, int ownerId) {
        for (Integer scheduleId : scheduleIds) {
            deleteSchedule(scheduleId, ownerId);
        }
    }

    // 캘린더에서 고른 날짜마다 각자 다른 시간대로 한 번에 등록. 이미 등록된 날짜는 건너뛰고 안내 메시지로 알린다.
    // schedules의 stylistId는 신뢰하지 않고 경로변수로 받은 stylistId로 덮어쓴다 (다른 디자이너 앞으로 등록되는 것
    // 방지).
    @Transactional
    public String registerSchedules(int ownerId, int stylistId, List<StylistScheduleVO> schedules) {
        assertOwnsStylist(stylistId, ownerId);
        List<String> skipped = new ArrayList<>();
        for (StylistScheduleVO schedule : schedules) {
            if (schedule.getDate() == null || schedule.getDate().trim().isEmpty())
                continue;
            if (schedule.getStartTime() == null || schedule.getEndTime() == null
                    || schedule.getEndTime().compareTo(schedule.getStartTime()) <= 0) {
                throw new IllegalArgumentException(schedule.getDate() + " 날짜는 종료 시간이 시작 시간보다 늦어야 합니다.");
            }
            schedule.setStylistId(stylistId);
            if (scheduleMapper.findByStylistIdAndDate(schedule) != null) {
                skipped.add(schedule.getDate());
                continue;
            }
            scheduleMapper.insertSchedule(schedule);
        }
        return skipped.isEmpty() ? null : String.join(", ", skipped) + " 날짜는 이미 등록되어 있어 건너뛰었습니다.";
    }

    @Transactional
    public void deleteSchedule(int scheduleId, int ownerId) {
        StylistScheduleVO schedule = scheduleMapper.findById(scheduleId);
        if (schedule == null)
            throw new IllegalArgumentException("존재하지 않는 스케줄입니다.");
        assertOwnsStylist(schedule.getStylistId(), ownerId);
        scheduleMapper.deleteSchedule(scheduleId);
    }

}
