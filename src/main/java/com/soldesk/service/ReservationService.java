package com.soldesk.service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.soldesk.mapper.PaymentMapper;
import com.soldesk.mapper.ResvMapper;
import com.soldesk.mapper.SalonMapper;
import com.soldesk.mapper.StylistMapper;
import com.soldesk.mapper.StylistScheduleMapper;
import com.soldesk.vo.OwnerScheduleSlotVO;
import com.soldesk.vo.PaymentVO;
import com.soldesk.vo.ReservationVO;
import com.soldesk.vo.SalonOperatingHourVO;
import com.soldesk.vo.SalonVO;
import com.soldesk.vo.ScheduleBoardVO;
import com.soldesk.vo.ScheduleRowVO;
import com.soldesk.vo.ServiceVO;
import com.soldesk.vo.StylistScheduleVO;
import com.soldesk.vo.StylistVO;
import com.soldesk.vo.TimeSlotVO;

@Service
public class ReservationService {

    /** 예약 단위. 시술 소요시간과 무관하게 30분 간격으로만 시작할 수 있다. */
    private static final int SLOT_MINUTES = 30;

    /** 결제창에 들어간 예약이 자리를 잡아두는 시간. ResvMapper.xml 의 INTERVAL 10 MINUTE 과 같아야 한다. */
    private static final int PAYMENT_HOLD_MINUTES = 10;

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

    @Autowired
    private PaymentMapper paymentMapper;

    @Autowired
    private KakaoPayService kakaoPayService;

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

        LocalTime[] window = computeWorkWindow(stylist, targetDate, date);
        if (window == null) {
            return List.of();
        }
        LocalTime windowStart = window[0];
        LocalTime windowEnd = window[1];

        // 이미 찬 시각과, 오늘이라면 이미 지나간 시각
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

    // 매장 영업시간 ∩ 디자이너 근무시간. 겹치는 구간이 없으면(휴무 포함) null
    private LocalTime[] computeWorkWindow(StylistVO stylist, LocalDate targetDate, String date) {
        String dayKo = DAY_KO[targetDate.getDayOfWeek().getValue() - 1];
        StylistScheduleVO condition = new StylistScheduleVO();
        condition.setStylistId(stylist.getStylistId());
        condition.setDate(date);
        return workWindowOf(salonMapper.findOperatingHour(stylist.getSalonId(), dayKo),
                scheduleMapper.findByStylistIdAndDate(condition));
    }

    // 위 계산에서 조회를 뺀 부분. 현황판은 매장/스케줄을 한 번에 읽어와서 이쪽만 반복 호출한다
    private LocalTime[] workWindowOf(SalonOperatingHourVO hour, StylistScheduleVO schedule) {
        if (hour == null) {
            return null; // 그 요일 영업시간 행이 없으면 휴무다
        }
        LocalTime windowStart = LocalTime.parse(hour.getOpenTime());
        LocalTime windowEnd = LocalTime.parse(hour.getCloseTime());

        // 등록된 스케줄이 없으면 매장 영업시간 내내 근무하는 것으로 본다
        if (schedule != null) {
            if (!schedule.getIsAvailable()) {
                return null; // 점주가 그 날 쉬는 것으로 등록했다
            }
            LocalTime scheduleStart = LocalTime.parse(schedule.getStartTime());
            LocalTime scheduleEnd = LocalTime.parse(schedule.getEndTime());
            if (scheduleStart.isAfter(windowStart)) windowStart = scheduleStart;
            if (scheduleEnd.isBefore(windowEnd)) windowEnd = scheduleEnd;
        }

        return windowStart.isBefore(windowEnd) ? new LocalTime[] { windowStart, windowEnd } : null;
    }

    /**
     * 결제 전 예약을 pending 으로 만들고 결제 행까지 같이 세운다.
     *
     * 금액은 화면에서 받지 않고 서비스 가격을 DB 에서 다시 읽는다. 폼에 실린 금액을 믿으면
     * 1원짜리 결제를 만들 수 있다.
     *
     * @return 만들어진 예약 (reservationId 가 채워져 있다)
     * @throws IllegalArgumentException 입력이 그 매장 것이 아니거나 이미 찬 자리일 때
     */
    @Transactional
    public ReservationVO createPendingReservation(int userId, int salonId, int stylistId,
            int serviceId, String reservationTime) {

        // 1) 넘어온 조합이 실제로 그 매장 것인지 확인한다.
        //    폼 값만 믿으면 다른 매장의 싼 시술 가격으로 예약을 만들 수 있다.
        StylistVO stylist = stylistMapper.findById(stylistId);
        if (stylist == null || stylist.getSalonId() != salonId) {
            throw new IllegalArgumentException("선택한 디자이너가 이 매장 소속이 아닙니다.");
        }
        ServiceVO service = salonMapper.findServicesBySalonId(salonId).stream()
                .filter(s -> s.getServiceId() == serviceId)
                .findFirst()
                .orElseThrow(() -> new IllegalArgumentException("선택한 시술이 이 매장 메뉴가 아닙니다."));

        // 2) 그 시각이 애초에 고를 수 있는 자리였는지 (영업시간/근무시간 밖이 아닌지)
        String date = reservationTime.substring(0, 10);
        String time = reservationTime.substring(11, 16);
        boolean offered = getAvailableSlots(stylistId, date).stream()
                .anyMatch(slot -> slot.getTime().equals(time) && slot.isAvailable());
        if (!offered) {
            throw new IllegalArgumentException("선택할 수 없는 시간입니다. 다른 시간을 골라주세요.");
        }

        // 3) 빈 자리일 때만 들어가는 INSERT. 슬롯을 본 뒤 누가 먼저 채갔다면 여기서 0행이다.
        ReservationVO reservation = new ReservationVO();
        reservation.setUserId(userId);
        reservation.setSalonId(salonId);
        reservation.setStylistId(stylistId);
        reservation.setServiceId(serviceId);
        reservation.setReservationTime(reservationTime + ":00");
        if (resvMapper.insertIfSlotFree(reservation) == 0) {
            throw new IllegalArgumentException("방금 다른 분이 예약했습니다. 다른 시간을 골라주세요.");
        }

        // 4) 결제 행도 같이 세워둔다 (Payments.reservation_id 가 NOT NULL 1:1 이라 예약이 먼저 있어야 한다)
        PaymentVO payment = new PaymentVO();
        payment.setReservationId(reservation.getReservationId());
        payment.setUserId(userId);
        payment.setAmount(service.getPrice());
        payment.setPaymentMethod("KAKAOPAY");
        paymentMapper.insertPayment(payment);

        reservation.setServiceName(service.getServiceName());
        reservation.setAmount(service.getPrice().intValue());
        return reservation;
    }

    /** ready 응답으로 받은 tid 보관 */
    @Transactional
    public void saveTransactionId(int reservationId, String tid) {
        paymentMapper.updateTransactionId(reservationId, tid);
    }

    /**
     * 결제 승인 결과 반영. 승인 응답의 금액이 우리가 기록해 둔 금액과 같을 때만 확정한다.
     *
     * @param approvedAmount 카카오페이가 실제로 승인한 금액
     * @throws IllegalStateException 금액이 어긋날 때
     */
    @Transactional
    public void confirmPayment(int reservationId, int approvedAmount, String paymentMethod) {
        PaymentVO payment = paymentMapper.findByReservationId(reservationId);
        if (payment == null) {
            throw new IllegalStateException("결제 정보를 찾을 수 없습니다.");
        }
        if (payment.getAmount().intValue() != approvedAmount) {
            // 여기까지 왔다면 금액이 중간에 조작된 것이다. 확정하지 않는다.
            throw new IllegalStateException("결제 금액이 예약 금액과 일치하지 않습니다.");
        }
        paymentMapper.markCompleted(reservationId, paymentMethod);
        resvMapper.updateStatus(reservationId, "confirmed");
    }

    /** 결제 취소/실패 — 예약도 같이 접는다 */
    @Transactional
    public void failPayment(int reservationId) {
        paymentMapper.markFailed(reservationId);
        resvMapper.updateStatus(reservationId, "cancelled");
    }

    @Transactional(readOnly = true)
    public ReservationVO getReservation(int reservationId) {
        return resvMapper.findById(reservationId);
    }

    @Transactional(readOnly = true)
    public PaymentVO getPayment(int reservationId) {
        return paymentMapper.findByReservationId(reservationId);
    }

    // 점주 예약현황관리: 본인 매장의 예약 목록 한 페이지 (소유 검증)
    @Transactional(readOnly = true)
    public List<ReservationVO> getReservationsForOwner(int salonId, int ownerId, int page, int size) {
        requireOwnedSalon(salonId, ownerId);
        List<ReservationVO> list = resvMapper.findBySalonId(salonId, (page - 1) * size, size);
        list.forEach(this::fillDisplayFields);
        return list;
    }

    @Transactional(readOnly = true)
    public int countReservationsForOwner(int salonId, int ownerId) {
        requireOwnedSalon(salonId, ownerId);
        return resvMapper.countBySalonId(salonId);
    }

    private SalonVO requireOwnedSalon(int salonId, int ownerId) {
        SalonVO salon = salonMapper.findById(salonId);
        if (salon == null || salon.getOwnerId() != ownerId) {
            throw new IllegalArgumentException("본인 매장의 예약만 조회할 수 있습니다.");
        }
        return salon;
    }

    /**
     * 하루치 예약현황판. 세로축이 시각, 가로축이 디자이너다.
     *
     * 줄(시각)은 "디자이너들의 근무시간 슬롯 ∪ 실제 예약 시각"의 합집합으로 만든다.
     * 근무시간만으로 만들면 점주가 근무시간을 줄이거나 휴무로 바꿨을 때 이미 잡힌 예약이
     * 화면에서 사라져 손님을 놓친다. 틀 밖 예약은 isOutsideHours 로 따로 표시한다.
     */
    @Transactional(readOnly = true)
    public ScheduleBoardVO getScheduleBoard(int salonId, int ownerId, LocalDate targetDate) {
        requireOwnedSalon(salonId, ownerId);
        String date = targetDate.toString();

        // 디자이너 수와 무관하게 조회는 네 번이면 끝난다
        List<StylistVO> stylists = stylistMapper.findBySalonId(salonId);
        String dayKo = DAY_KO[targetDate.getDayOfWeek().getValue() - 1];
        SalonOperatingHourVO openHour = salonMapper.findOperatingHour(salonId, dayKo);
        Map<Integer, StylistScheduleVO> scheduleByStylist = new HashMap<>();
        for (StylistScheduleVO s : scheduleMapper.findBySalonIdAndDate(salonId, date)) {
            scheduleByStylist.put(s.getStylistId(), s);
        }
        List<ReservationVO> reservations = resvMapper.findBySalonIdAndDate(salonId, date);
        reservations.forEach(this::fillDisplayFields);

        // 디자이너별 근무 구간 (null 이면 그 날 근무 없음)
        Map<Integer, LocalTime[]> windows = new HashMap<>();
        for (StylistVO stylist : stylists) {
            windows.put(stylist.getStylistId(),
                    workWindowOf(openHour, scheduleByStylist.get(stylist.getStylistId())));
        }

        // 줄로 세울 시각 모으기 — 근무 슬롯 + 예약 시각(근무시간 밖이어도)
        Set<LocalTime> times = new TreeSet<>();
        for (LocalTime[] window : windows.values()) {
            if (window == null) continue;
            for (LocalTime t = window[0]; t.isBefore(window[1]); t = t.plusMinutes(SLOT_MINUTES)) {
                times.add(t);
            }
        }
        Map<Integer, Map<LocalTime, ReservationVO>> startsAt = new HashMap<>();
        for (ReservationVO r : reservations) {
            LocalTime start = startTimeOf(r);
            times.add(start);
            startsAt.computeIfAbsent(r.getStylistId(), k -> new HashMap<>()).put(start, r);
        }

        LocalDateTime now = LocalDateTime.now();
        List<ScheduleRowVO> rows = new ArrayList<>();
        for (LocalTime t : times) {
            ScheduleRowVO row = new ScheduleRowVO();
            row.setTime(t.format(HHMM));
            row.setPast(targetDate.atTime(t).plusMinutes(SLOT_MINUTES).isBefore(now));
            row.setCurrent(!targetDate.atTime(t).isAfter(now)
                    && targetDate.atTime(t).plusMinutes(SLOT_MINUTES).isAfter(now));

            List<OwnerScheduleSlotVO> cells = new ArrayList<>();
            for (StylistVO stylist : stylists) {
                LocalTime[] window = windows.get(stylist.getStylistId());
                boolean working = window != null && !t.isBefore(window[0]) && t.isBefore(window[1]);
                OwnerScheduleSlotVO cell = new OwnerScheduleSlotVO(working);
                Map<LocalTime, ReservationVO> mine = startsAt.get(stylist.getStylistId());
                if (mine != null) {
                    cell.setReservation(mine.get(t));
                    cell.setOccupied(cell.getReservation() == null && coveredBy(mine.values(), t));
                }
                cells.add(cell);
            }
            row.setCells(cells);
            rows.add(row);
        }

        ScheduleBoardVO board = new ScheduleBoardVO();
        board.setStylists(stylists);
        board.setRows(rows);
        board.setBookedCount(reservations.size());
        return board;
    }

    // 이 시각이 앞서 시작한 시술의 소요시간 안에 들어가는지 (펌처럼 긴 시술이 자리를 물고 있는 구간)
    private boolean coveredBy(Collection<ReservationVO> reservations, LocalTime t) {
        for (ReservationVO r : reservations) {
            LocalTime start = startTimeOf(r);
            if (start.isBefore(t) && start.plusMinutes(Math.max(r.getDurationMinutes(), SLOT_MINUTES)).isAfter(t)) {
                return true;
            }
        }
        return false;
    }

    private LocalTime startTimeOf(ReservationVO reservation) {
        return LocalTime.parse(reservation.getReservationTime().substring(11, 16));
    }

    /**
     * 화면에만 쓰는 값을 채운다.
     *
     * 시술이 언제 끝나는지는 Services.duration_minutes 가 알고 있으므로, 커트 30분과 펌 90분이
     * 각각 다른 시점에 "완료"가 된다. status 컬럼 자체는 건드리지 않는다 —
     * completed 로 넘기는 일은 리뷰 기능과 함께 정해야 하는 별도 문제다.
     *
     * "완료"는 시각이 지난 확정 예약을 낙관적으로 그렇게 보는 것일 뿐, 손님이 실제로 왔는지는
     * 시스템이 모른다. 손님이 오지 않은 경우는 점주가 노쇼로 마감하면 "노쇼"로 갈린다.
     */
    private void fillDisplayFields(ReservationVO reservation) {
        LocalDateTime start = LocalDateTime.parse(
                reservation.getReservationTime().substring(0, 16).replace(' ', 'T'));
        LocalDateTime end = start.plusMinutes(Math.max(reservation.getDurationMinutes(), SLOT_MINUTES));
        LocalDateTime now = LocalDateTime.now();
        reservation.setEndTime(end.toLocalTime().format(HHMM));

        String status = reservation.getStatus();
        if ("pending".equals(status)) {
            // 결제창에서 이탈하면 카카오페이가 알려주지 않아 pending 인 채로 남는다.
            // 자리는 이미 놓아준 상태이므로(findReservedTimes 와 같은 10분 기준) 점주에게도 그렇게 보여준다.
            boolean abandoned = reservation.getCreatedAt() != null && LocalDateTime.parse(
                    reservation.getCreatedAt().substring(0, 16).replace(' ', 'T'))
                    .isBefore(now.minusMinutes(PAYMENT_HOLD_MINUTES));
            reservation.setDisplayStatus(abandoned ? "결제 미완료" : "결제중");
        } else if ("cancelled".equals(status)) {
            if ("no_show".equals(reservation.getCancelType())) {
                reservation.setDisplayStatus("노쇼");
            } else if (reservation.getRejectReason() != null) {
                reservation.setDisplayStatus("거절됨");
            } else {
                reservation.setDisplayStatus("취소됨"); // 결제 이탈로 자리만 비운 건
            }
        } else if (now.isBefore(start)) {
            reservation.setDisplayStatus("예약됨");
        } else if (now.isBefore(end)) {
            reservation.setDisplayStatus("진행중");
        } else {
            reservation.setDisplayStatus("완료");
        }

        // 확정된 예약은 시술 여부와 무관하게 점주가 정리할 수 있다 (거절/노쇼는 점주 재량).
        // 시점(예약됨/진행중/완료)에 따라 화면이 환불·노쇼 기본값을 다르게 잡는다.
        reservation.setRejectable("confirmed".equals(status));
    }

    /**
     * 점주가 확정 예약을 정리한다. 두 갈래 — 환불 안전성이 시점에 따라 다르기 때문이다.
     *
     *   resolution = "rejected" : 부득이 취소하고 환불한다 (결제 완료건이면 카카오페이 환불까지).
     *   resolution = "no_show"  : 손님이 오지 않아 노쇼로 마감한다. 선불 금액은 매장이 갖는다(환불 없음).
     *
     * 시술 시작 전에는 거절만 성립하고, 노쇼는 시각이 지난 예약에만 성립한다.
     * 환불 호출이 실패하면 예외로 트랜잭션이 롤백되어 confirmed 상태 그대로 남는다.
     */
    @Transactional
    public void rejectReservation(int reservationId, int ownerId, String reason, String resolution) {
        if (reason == null || reason.trim().isEmpty()) {
            throw new IllegalArgumentException("사유를 입력해주세요.");
        }
        boolean noShow = "no_show".equals(resolution);
        if (!noShow && !"rejected".equals(resolution)) {
            throw new IllegalArgumentException("잘못된 요청입니다.");
        }
        ReservationVO reservation = resvMapper.findById(reservationId);
        if (reservation == null) {
            throw new IllegalArgumentException("존재하지 않는 예약입니다.");
        }
        SalonVO salon = salonMapper.findById(reservation.getSalonId());
        if (salon == null || salon.getOwnerId() != ownerId) {
            throw new IllegalArgumentException("본인 매장의 예약만 처리할 수 있습니다.");
        }
        if (!"confirmed".equals(reservation.getStatus())) {
            throw new IllegalArgumentException("이미 처리된 예약입니다.");
        }
        boolean started = !LocalDateTime.now().isBefore(LocalDateTime.parse(
                reservation.getReservationTime().substring(0, 16).replace(' ', 'T')));
        // 아직 오지도 않은 예약을 노쇼로 마감할 수는 없다
        if (noShow && !started) {
            throw new IllegalArgumentException("아직 예약 시간이 되지 않아 노쇼로 처리할 수 없습니다.");
        }

        // 환불은 '거절'일 때만. 노쇼는 결제 상태를 건드리지 않는다.
        if (!noShow) {
            PaymentVO payment = paymentMapper.findByReservationId(reservationId);
            if (payment != null && "completed".equals(payment.getPaymentStatus())) {
                try {
                    kakaoPayService.cancel(payment.getTransactionId(), payment.getAmount());
                } catch (IllegalStateException e) {
                    // 결제 문구가 그대로 나오면 점주는 처리가 됐는지조차 알 수 없다
                    throw new IllegalStateException("환불에 실패해 처리가 취소되었습니다. 잠시 후 다시 시도해 주세요.", e);
                }
                paymentMapper.markRefunded(reservationId);
            }
        }

        String cancelType = noShow ? "no_show" : "rejected";
        if (resvMapper.rejectReservation(reservationId, reason.trim(), cancelType) == 0) {
            throw new IllegalArgumentException("이미 처리된 예약입니다.");
        }
    }
}
