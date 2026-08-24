package com.soldesk.service;

import java.io.IOException;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

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

    // 화면(pattern="[0-9-]{9,13}")과 같은 규칙 — 폼 검증을 우회해 바로 요청을 보내는 경우까지 막는다
    private void assertValidPhone(String phoneNumber) {
        if (phoneNumber == null || !phoneNumber.matches("[0-9-]{9,13}")) {
            throw new IllegalArgumentException("연락처는 숫자와 하이픈(-)만 사용해 입력해주세요.");
        }
    }

    @Transactional
    public List<StylistVO> getStylists(int salonId, int ownerId) {
        assertOwnsSalon(salonId, ownerId);
        return stylistMapper.findBySalonId(salonId);
    }

    @Transactional
    public void registerStylist(int salonId, int ownerId, StylistVO stylist, String dayOffDays, MultipartFile imageFile)
            throws IOException {
        assertOwnsSalon(salonId, ownerId);
        assertValidName(salonId, stylist.getStylistName(), -1);
        assertValidPhone(stylist.getPhoneNumber());
        stylist.setStylistName(stylist.getStylistName().trim());
        stylist.setSalonId(salonId);
        String saved = fileService.saveFile(imageFile);
        if (saved != null) {
            stylist.setImageUrl("/upload/" + saved);
        }
        stylistMapper.insertStylist(stylist);
        generateDayOffSchedules(stylist.getStylistId(), dayOffDays);
    }

    // 등록 시 선택한 휴무 요일을 실제 예약 가능 여부에도 반영한다 — 스케줄에 아무 행도 없으면
    // "매장 영업시간 내내 근무"로 간주되므로(ReservationService.workWindowOf), 휴무 요일은
    // isAvailable=false 행을 직접 만들어줘야 진짜로 예약이 막힌다.
    // 요일이 "영원히" 반복되는 개념은 스키마에 없어 앞으로 DAYOFF_AUTO_SCHEDULE_WEEKS 주치 실제 날짜만
    // 만들어두고, 그 이후는 점주가 스케줄 설정에서 직접 갱신해야 한다.
    private static final int DAYOFF_AUTO_SCHEDULE_WEEKS = 12;

    private void generateDayOffSchedules(int stylistId, String dayOffDays) {
        if (dayOffDays == null || dayOffDays.trim().isEmpty()) {
            return;
        }
        Set<DayOfWeek> days = new HashSet<>();
        for (String token : dayOffDays.split(",")) {
            DayOfWeek dow = parseKoreanDayOfWeek(token.trim());
            if (dow != null) {
                days.add(dow);
            }
        }
        if (days.isEmpty()) {
            return;
        }
        LocalDate cursor = LocalDate.now();
        LocalDate end = cursor.plusWeeks(DAYOFF_AUTO_SCHEDULE_WEEKS);
        while (!cursor.isAfter(end)) {
            if (days.contains(cursor.getDayOfWeek())) {
                StylistScheduleVO schedule = new StylistScheduleVO();
                schedule.setStylistId(stylistId);
                schedule.setDate(cursor.toString());
                schedule.setStartTime("00:00");
                schedule.setEndTime("23:59");
                schedule.setIsAvailable(false);
                scheduleMapper.insertSchedule(schedule);
            }
            cursor = cursor.plusDays(1);
        }
    }

    private DayOfWeek parseKoreanDayOfWeek(String label) {
        for (int i = 0; i < WEEKDAY_NAMES.length; i++) {
            if (WEEKDAY_NAMES[i].equals(label)) {
                return DayOfWeek.of(i + 1);
            }
        }
        return null;
    }

    @Transactional
    public void updateStylist(int ownerId, StylistVO stylist, String dayOffDays, boolean dayOffChanged,
            MultipartFile imageFile) throws IOException {
        StylistVO current = assertOwnsStylist(stylist.getStylistId(), ownerId);
        assertValidName(current.getSalonId(), stylist.getStylistName(), stylist.getStylistId());
        assertValidPhone(stylist.getPhoneNumber());
        stylist.setStylistName(stylist.getStylistName().trim());
        String saved = fileService.saveFile(imageFile);
        if (saved != null) {
            fileService.deleteFile(stripUploadPrefix(current.getImageUrl()));
            stylist.setImageUrl("/upload/" + saved);
        } else {
            stylist.setImageUrl(current.getImageUrl());
        }
        stylistMapper.updateStylist(stylist);
        // 등록 때와 똑같이, 휴무 요일 변경도 실제 예약 가능 시간대에 반영한다.
        // 이번 수정에서 휴무 요일을 실제로 건드린 경우에만 자동 생성분을 지우고 다시 만든다 —
        // 안 건드렸는데도 매번 지우고 다시 만들면 dayOffDays 가 빈 값으로 넘어올 때
        // 기존 휴무 스케줄이 조용히 사라지는 회귀가 생긴다.
        if (dayOffChanged) {
            scheduleMapper.deleteAutoDayOffSchedules(stylist.getStylistId());
            generateDayOffSchedules(stylist.getStylistId(), dayOffDays);
        }
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
    //
    // 휴무 요일 선택으로 자동 생성된 행(00:00~23:59, is_available=0, deleteAutoDayOffSchedules와 같은
    // 패턴)은 이 목록에서 제외한다 — 매주 하루씩이라 날짜가 연속되지 않아 그룹으로 안 묶이고 1년치가
    // 낱개 줄로 죽 나열되어 버린다. 실제 예약 차단(Stylist_Schedules 행 자체)에는 손대지 않고, 점주가
    // 보는 이 화면에서만 숨긴다 — 휴무 요일 관리는 "휴무일" 체크박스로, 이 목록은 점주가 직접 잡은
    // 스케줄만 보여주기 위함.
    private static final String DAYOFF_AUTO_START = "00:00:00";
    private static final String DAYOFF_AUTO_END = "23:59:00";

    private boolean isAutoDayOffRow(StylistScheduleVO s) {
        return !s.getIsAvailable()
                && DAYOFF_AUTO_START.equals(s.getStartTime())
                && DAYOFF_AUTO_END.equals(s.getEndTime());
    }

    @Transactional
    public List<Map<String, Object>> getScheduleGroups(int stylistId, int ownerId) {
        List<StylistScheduleVO> schedules = new ArrayList<>();
        for (StylistScheduleVO s : getSchedules(stylistId, ownerId)) {
            if (!isAutoDayOffRow(s)) {
                schedules.add(s);
            }
        }
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
