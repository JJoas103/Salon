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

import com.soldesk.mapper.CouponMapper;
import com.soldesk.mapper.PaymentMapper;
import com.soldesk.mapper.ResvMapper;
import com.soldesk.mapper.SalonMapper;
import com.soldesk.mapper.StylistMapper;
import com.soldesk.mapper.StylistScheduleMapper;
import com.soldesk.vo.OwnerScheduleSlotVO;
import com.soldesk.vo.PaymentVO;
import com.soldesk.vo.PriceQuoteVO;
import com.soldesk.vo.ReservationVO;
import com.soldesk.vo.SalonGradeVO;
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

    // 결제창에 들어간 예약이 자리를 잡아두는 시간. ResvMapper.xml 의 INTERVAL 10 MINUTE 과 같아야 함
    // main의 findStalePendingIds 도 같은 정책
    private static final int PAYMENT_HOLD_MINUTES = 10;

    /** DB 의 day_of_week 는 ENUM('월','화',...) 한글이라 java 의 DayOfWeek 를 그대로 못 쓴다. */
    private static final String[] DAY_KO = { "월", "화", "수", "목", "금", "토", "일" };

    private static final DateTimeFormatter HHMM = DateTimeFormatter.ofPattern("HH:mm");

    @Autowired
    private PointService pointService;

    @Autowired
    private CheckoutService checkoutService;

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

    @Autowired
    private CouponMapper couponMapper;

    @Autowired
    private CouponService couponService;

    @Transactional
    public List<ReservationVO> getRevList(int userId) {
        List<ReservationVO> list = resvMapper.getRevList(userId);
        list.forEach(this::fillPaymentLabel);
        return list;
    }

    /**
     * 화면에 보여줄 결제수단 문구를 만든다.
     *
     * 두 컬럼의 성격이 다르다. pg_provider 는 어느 결제사를 거쳤는지(금액 계산 때 정해져 항상 값이 있고),
     * payment_method 는 그 결제사 안에서 실제로 뭘 썼는지(승인 응답에서 오므로 승인 전에는 비어 있다).
     * 그래서 결제사를 주 표시로 삼고 수단은 있을 때만 괄호로 덧붙인다.
     * payment_method 만 쓰면 취소·실패 건이 통째로 빈칸이 된다.
     *
     * 카카오가 주는 원문(CARD/MONEY)을 사람 말로 바꾸는 것도 여기 한 곳에서 한다.
     * 화면마다 <c:choose> 로 흩어놓으면 문구가 서로 갈린다.
     *
     * 두 컬럼을 실어오는 조회(getRevList / findById)에서만 부른다. 점주 쪽 ownerColumns 에는
     * 아직 결제 컬럼이 없어서, 거기서 부르면 전부 "결제 정보 없음" 이 된다.
     */
    private void fillPaymentLabel(ReservationVO reservation) {
        String provider = reservation.getPgProvider();

        // LEFT JOIN Payments 라 결제까지 못 간 예약은 결제행 자체가 없다
        if (provider == null) {
            reservation.setDisplayPayment("결제 정보 없음");
            return;
        }
        if ("ZERO".equals(provider)) {
            // 쿠폰·적립금이 정가를 전부 덮어 외부 결제사를 거치지 않은 건 (ZeroAmountGateway)
            reservation.setDisplayPayment("적립금·쿠폰으로 전액 결제");
            return;
        }

        String method = methodLabelOf(reservation.getPaymentMethod());
        String providerLabel = "KAKAOPAY".equals(provider) ? "카카오페이" : provider;
        reservation.setDisplayPayment(
                method == null ? providerLabel : providerLabel + " (" + method + ")");
    }

    /**
     * payments.payment_method 원문 → 사람이 읽는 말.
     *
     * 카카오페이 단건결제 승인 응답의 payment_method_type 은 CARD 아니면 MONEY 다.
     * 그 밖의 값은 원문 그대로 내보낸다 — 카카오가 수단을 늘렸을 때 말없이 빈칸이 되는 것보다,
     * 모르는 값이라도 보이는 편이 무엇을 추가해야 하는지 바로 드러난다.
     */
    private String methodLabelOf(String method) {
        if (method == null || method.isBlank()) {
            return null; // 아직 승인 전이거나 취소된 건
        }
        switch (method) {
            case "CARD":
                return "카드";
            case "MONEY":
                return "카카오페이머니";
            default:
                return method;
        }
    }

    @Transactional
    public int countCompleted(int userId) {
        return resvMapper.countCompleted(userId);
    }

    /**
     * 매장별 등급. 매장마다 점주가 서로 다른 별개 사업자라, 한 매장에서 쌓은 단골 이력이
     * 다른 매장 등급에 영향을 주면 안 된다 — 그래서 전체 합산이 아니라 매장별로 따로 계산한다.
     * (마이페이지 상단의 "누적 이용 건수"는 이 계산과 별개로 전체 활동량 참고용으로 남겨둔다)
     */
    @Transactional(readOnly = true)
    public List<SalonGradeVO> getSalonGrades(int userId) {
        List<SalonGradeVO> grades = resvMapper.findCompletedCountsBySalon(userId);
        for (SalonGradeVO g : grades) {
            g.setGrade(gradeOf(g.getCompletedCount()));
        }
        return grades;
    }

    /**
     * 완료 예약 건수 기준 등급 매핑. 기준 횟수(0~2 / 3~9 / 10+)는 실제 방문 분포를
     * 분석해 정한 게 아니라 상식적으로 잡은 임시값 — 서비스가 자리 잡으면 다시 조정해야 한다.
     */
    public String gradeOf(int completedCount) {
        if (completedCount >= 10)
            return "VIP";
        if (completedCount >= 3)
            return "단골";
        return "새싹";
    }

    /**
     * 한 디자이너의 특정 날짜에 고를 수 있는 시간대를 만든다.
     *
     * 매장 영업시간 ∩ 디자이너 근무시간 → 30분 간격으로 자름 → 이미 찬 시각 / 지난 시각 표시
     *
     * 시술 소요시간은 여기에 관여하지 않는다. 10:30(1시간)과 11:00(30분)이 겹쳐도
     * 디자이너가 감당할 수 있으면 문제없다는 것이 이 서비스의 규칙이고,
     * 감당이 안 되는 자리는 점주가 직접 막는다.
     *
     * @param stylistId 디자이너
     * @param date      'yyyy-MM-dd'
     * @return 마감분까지 포함한 그 날의 전체 시간대. 휴무거나 근무가 없으면 빈 목록.
     */
    @Transactional
    public List<TimeSlotVO> getAvailableSlots(int stylistId, String date) {
        // 자리를 계산하기 전에 만료된 홀드부터 접는다. 슬롯을 읽는 모든 경로가
        // 이 메서드를 지나므로 여기 한 곳이면 별도 스케줄러 없이 정리된다.
        // (조회 전용이 아니게 되므로 readOnly 를 뗀다)
        expireStalePending();

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
            if (scheduleStart.isAfter(windowStart))
                windowStart = scheduleStart;
            if (scheduleEnd.isBefore(windowEnd))
                windowEnd = scheduleEnd;
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
            int serviceId, String reservationTime, Integer userCouponId, int pointToUse) {

        // 1) 넘어온 조합이 실제로 그 매장 것인지 확인한다.
        // 폼 값만 믿으면 다른 매장의 싼 시술 가격으로 예약을 만들 수 있다.
        ServiceVO service = validateCombination(salonId, stylistId, serviceId);
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

        // 4) 금액을 다시 계산한다. 화면이 보낸 금액은 쓰지 않고, 확인 화면이 보여줄 때
        // 썼던 것과 똑같은 CheckoutService.quote() 를 부른다. 두 벌로 계산하면
        // 화면 금액과 청구 금액이 어긋난다.
        PriceQuoteVO quote = checkoutService.quote(userId, serviceId, userCouponId, pointToUse);

        // 5) 적립금 차감. 잔액이 모자라면 예외가 나고 이 트랜잭션이 통째로 롤백되므로,
        // 방금 만든 예약도 함께 사라진다. 되돌릴 것이 없다.
        pointService.use(userId, reservation.getReservationId(), quote.getPointUsed());

        // 6) 쿠폰 점유. 예외가 나면 위와 마찬가지로 통째로 롤백된다.
        //
        // 할인이 실제로 붙었을 때만 묶는다. 사용자가 쿠폰을 골랐어도 quote() 가
        // "사용 불가" 로 판정했으면 할인은 0인데, 그때 묶어버리면 할인은 못 받고
        // 쿠폰만 없어진다.
        boolean couponApplied = userCouponId != null && quote.getCouponDiscount() > 0;
        if (couponApplied) {
            couponService.reserve(userCouponId, userId, reservation.getReservationId());
        }

        // 7) 결제 행 (Payments.reservation_id 가 NOT NULL 1:1 이라 예약이 먼저 있어야 한다)
        PaymentVO payment = new PaymentVO();
        payment.setReservationId(reservation.getReservationId());
        payment.setUserId(userId);
        payment.setAmount(java.math.BigDecimal.valueOf(quote.getFinalAmount()));
        payment.setOriginalAmount(java.math.BigDecimal.valueOf(quote.getOriginalAmount()));
        payment.setCouponDiscount(java.math.BigDecimal.valueOf(quote.getCouponDiscount()));
        payment.setPointUsed(quote.getPointUsed());
        payment.setPgProvider(quote.getPgProvider());
        payment.setUserCouponId(couponApplied ? userCouponId : null);
        paymentMapper.insertPayment(payment);

        reservation.setServiceName(service.getServiceName());
        reservation.setAmount(quote.getFinalAmount());
        reservation.setPgProvider(quote.getPgProvider());
        return reservation;
    }

    @Transactional
    public ServiceVO validateCombination(int salonId, int stylistId, int serviceId) {
        StylistVO stylist = stylistMapper.findById(stylistId);
        if (stylist == null || stylist.getSalonId() != salonId) {
            throw new IllegalArgumentException("선택한 디자이너가 이 매장 소속이 아닙니다.");
        }
        return salonMapper.findServicesBySalonId(salonId).stream()
                .filter(s -> s.getServiceId() == serviceId)
                .findFirst()
                .orElseThrow(() -> new IllegalArgumentException("선택한 시술이 이 매장 메뉴가 아닙니다."));
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
        if (paymentMapper.markCompleted(reservationId, paymentMethod) == 1) {
            resvMapper.updateStatus(reservationId, "confirmed");
            couponService.confirm(reservationId);
        }
    }

    /**
     * 결제창에서 이탈해 10분이 지난 예약·결제를 접는다.
     *
     * 결제창을 그냥 닫거나 뒤로가기로 빠져나온 사용자는 cancel 콜백을 보내지 않는다.
     * 그런 예약을 정리해 주는 것이 이 메서드이고, 그래서 결제 중단 처리로 들어오는 길은
     * "콜백이 온 경우"와 "여기서 걸린 경우" 둘이다.
     *
     * 다만 둘 다 failPayment() 로 모이므로, 쿠폰/적립금 원복은 그 한 곳에만 넣으면 된다.
     */
    @Transactional
    public void expireStalePending() {
        // 접을 대상을 먼저 확보한다. UPDATE 를 먼저 돌리면 어느 예약이 접혔는지 알 방법이 없다.
        for (int reservationId : resvMapper.findStalePendingIds()) {
            // 결제창에서 [취소] 를 누른 경우와 똑같이 처리한다. 원복 로직을 두 벌로 쓰지 않기 위해서다.
            // failPayment 안의 rowcount 가드가 중복 처리도 막아준다.
            failPayment(reservationId);
        }
    }

    /** 그 자리를 지금 잡고 있는 결제 미완료 예약 (없으면 null) */
    @Transactional(readOnly = true)
    public ReservationVO findPendingHold(int stylistId, String reservationTime) {
        return resvMapper.findPendingHold(stylistId, reservationTime);
    }

    /**
     * 결제 취소/실패 — 예약도 같이 접는다.
     *
     * 결제창 [취소] 콜백과 만료 정리(expireStalePending)가 모두 이리로 들어온다.
     * rowcount 가드 덕분에 같은 예약이 두 경로로 들어와도 한 번만 처리된다.
     * Step 4·5 의 적립금 환급 / 쿠폰 반납은 이 if 블록 안에 넣는다.
     */
    @Transactional
    public void failPayment(int reservationId) {
        if (paymentMapper.markFailed(reservationId) == 1) {
            resvMapper.updateStatus(reservationId, "cancelled");
            pointService.restore(reservationId);
            couponService.release(reservationId);
        }
    }

    @Transactional(readOnly = true)
    public ReservationVO getReservation(int reservationId) {
        ReservationVO reservation = resvMapper.findById(reservationId);
        if (reservation != null) {
            fillPaymentLabel(reservation);
        }
        return reservation;
    }

    @Transactional(readOnly = true)
    public PaymentVO getPayment(int reservationId) {
        return paymentMapper.findByReservationId(reservationId);
    }

    // 점주 매장 예약현황관리: 본인 매장의 예약 목록 조회 (소유 검증)
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

    // 세션의 selectedSalonId 는 사용자가 URL 로 바꿔 넣을 수 있어서, 조회 전에 소유주를 확인함
    private SalonVO requireOwnedSalon(int salonId, int ownerId) {
        SalonVO salon = salonMapper.findById(salonId);
        if (salon == null || salon.getOwnerId() != ownerId) {
            throw new IllegalArgumentException("본인 매장의 예약만 조회할 수 있습니다.");
        }
        return salon;
    }

    // 하루치 예약현황판 표 생성 (Grid)
    //
    // 표의 줄(시각)은 디자이너들의 근무시간 슬롯과 실제 예약 시각을 합쳐서 만듦
    // 점주가 나중에 근무시간을 줄이거나 휴무로 바꿨을 때 이미 잡혀 있던 예약이 표에서 통째로 사라져 손님을 놓치게 됨을 방지.
    // 그래서 근무시간 밖이라도 예약이 있으면 줄을 만들고 대신 isOutsideHours 로 경고 표시
    @Transactional(readOnly = true)
    public ScheduleBoardVO getScheduleBoard(int salonId, int ownerId, LocalDate targetDate) {
        requireOwnedSalon(salonId, ownerId);
        String date = targetDate.toString();

        // 디자이너 목록 / 영업시간 / 그 날 스케줄 / 그 날 예약
        // 디자이너 수와 무관하게 조회는 네 번으로 고정
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

        // 줄로 세울 시각 모으기, 근무 슬롯 + 예약 시각(근무시간 밖 예약 포함).
        // (TreeSet)중복 제거, 시각순 정렬이 한 번에
        Set<LocalTime> times = new TreeSet<>();
        for (LocalTime[] window : windows.values()) {
            if (window == null)
                continue;
            for (LocalTime t = window[0]; t.isBefore(window[1]); t = t.plusMinutes(SLOT_MINUTES)) {
                times.add(t);
            }
        }
        // 디자이너 → (시작시각 → 예약). 아래에서 칸마다 바로 꺼내 쓰려고 미리 묶어둠
        Map<Integer, Map<LocalTime, ReservationVO>> startsAt = new HashMap<>();
        for (ReservationVO r : reservations) {
            LocalTime start = startTimeOf(r);
            times.add(start);
            startsAt.computeIfAbsent(r.getStylistId(), k -> new HashMap<>()).put(start, r);
        }

        // 줄(시각)마다 칸(디자이너)을 채움. 칸 상태는 근무여부 / 예약 / 앞 시술의 점유 세 가지
        // past 는 그 30분 칸이 이미 끝난 줄, current 는 지금이 그 30분 안에 들어있는 줄
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
                    // 펌처럼 30분 이상 소요되는 시술이 이전 시간에 시작되어 현재 시간까지 점유중인지 판별
                    cell.setOccupied(cell.getReservation() == null && coveredBy(mine.values(), t));
                }
                cells.add(cell);
            }
            row.setCells(cells);
            rows.add(row);
        }

        // 최종 반환
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

    // 화면 표시 전용 값 채우기 (displayStatus / endTime / rejectable)
    //
    // DB의 status를 손대지 않고, 지금 시각과 시술 소요시간만 가지고 지금 어떻게 보일지를 계산
    // ex) 커트 30분과 펌 90분이 서로 다른 시점에 "완료"로 바뀜
    // status 를 실제로 completed 로 넘기는 건 결제/리뷰 쪽과 같이 정할 문제라 여기서는 안 함
    // 완료는 시각이 지난 확정 예약을 확인할 뿐, 손님이 실제로 왔는지는 알 수 없음
    // 안 온 경우는 점주가 노쇼로 마감했을 때만 노쇼로
    private void fillDisplayFields(ReservationVO reservation) {
        LocalDateTime start = LocalDateTime.parse(
                reservation.getReservationTime().substring(0, 16).replace(' ', 'T'));
        LocalDateTime end = start.plusMinutes(Math.max(reservation.getDurationMinutes(), SLOT_MINUTES));
        LocalDateTime now = LocalDateTime.now();
        reservation.setEndTime(end.toLocalTime().format(HHMM));

        String status = reservation.getStatus();
        if ("pending".equals(status)) {
            // 손님이 결제창에서 그냥 나가버려도 카카오페이가 알려주지 않아 pending 인 채로 남음.
            // 자리는 10분이 지나면 이미 놓아준 상태라(findReservedTimes 와 같은 기준),
            // 점주 화면에도 결제중이 아니라 "결제 미완료"로 보여줌
            boolean abandoned = reservation.getCreatedAt() != null && LocalDateTime.parse(
                    reservation.getCreatedAt().substring(0, 16).replace(' ', 'T'))
                    .isBefore(now.minusMinutes(PAYMENT_HOLD_MINUTES));
            reservation.setDisplayStatus(abandoned ? "결제 미완료" : "결제중");
        } else if ("cancelled".equals(status)) {
            // 같은 cancelled 라도 cancel_type / reject_reason 유무로 성격이 갈림
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

        // 확정된 예약이면 시술이 시작됐든 끝났든 점주가 정리할 수 있음 (거절/노쇼는 점주 재량).
        // 대신 시점에 따라 화면이 환불/노쇼 기본값을 다르게 잡아줌
        reservation.setRejectable("confirmed".equals(status));
    }

    // 점주가 확정 예약을 정리. 두 갈래로 나눈 건 돈을 돌려줘야 하는지가 갈리기 때문
    //
    // rejected : 매장 사정으로 취소 > 결제 완료건이면 카카오페이 환불까지
    // no_show : 손님이 안 옴 > 선불 금액은 매장이 가짐 (환불 없음)
    //
    // 아래 검증은 순서가 곧 방어 순서 - 값 > 예약 존재 > 소유 > 상태 > 시점
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
        // 아직 오지도 않은 손님을 노쇼로 만들 수는 없으므로, 노쇼는 예약 시각이 지난 뒤에만 가능
        if (noShow && !started) {
            throw new IllegalArgumentException("아직 예약 시간이 되지 않아 노쇼로 처리할 수 없습니다.");
        }

        // 환불은 거절일 때만. 노쇼는 결제 상태를 그대로 둠
        // 카카오 취소가 실패하면 예외로 트랜잭션이 통째로 롤백돼서, 예약은 confirmed 인 채로
        // (환불은 안 됐는데 예약만 취소되는 상태가 제일 위험해서 순서를 이렇게 잡음)
        if (!noShow) {
            PaymentVO payment = paymentMapper.findByReservationId(reservationId);
            if (payment != null && "completed".equals(payment.getPaymentStatus())) {
                try {
                    kakaoPayService.cancel(payment.getTransactionId(), payment.getAmount());
                } catch (IllegalStateException e) {
                    // 카카오 쪽 원문 메시지가 그대로 뜨면 점주는 처리가 된 건지조차 알 수 없어서 문구를 바꿔 던짐
                    throw new IllegalStateException("환불에 실패해 처리가 취소되었습니다. 잠시 후 다시 시도해 주세요.", e);
                }
                // 돈을 되돌렸으면 적립금·쿠폰도 함께 되돌린다. 매장 사정으로 취소된 것이라
                // 사용자가 쓴 할인 수단까지 잃을 이유가 없다.
                //
                // 노쇼(위 if 밖)에서는 되돌리지 않는다. 환불이 없어 매장이 결제액을 그대로
                // 가지므로, 적립금만 돌려주면 그 몫을 플랫폼이 떠안게 된다.
                // 원복 여부는 환불 여부와 항상 같이 간다.
                if (paymentMapper.markRefunded(reservationId) == 1) {
                    pointService.restore(reservationId);
                    // release 가 아니라 refund 다. 확정된 쿠폰은 used 상태라 release 로는 안 잡힌다.
                    couponService.refund(reservationId);
                }
            }
        }

        // UPDATE 쪽에도 status='confirmed' 조건이 걸려 있어서, 위 검증 통과 뒤에 누가 먼저
        // 처리했으면 0행이 됨. 그 경우도 실패로 보고 롤백시킴
        String cancelType = noShow ? "no_show" : "rejected";
        if (resvMapper.rejectReservation(reservationId, reason.trim(), cancelType) == 0) {
            throw new IllegalArgumentException("이미 처리된 예약입니다.");
        }
    }

    /** 사용자가 자신의 확정 예약을 취소 */
    @Transactional
    public void cancelReservation(int reservationId, int userId) {
        int result = resvMapper.cancelReservation(reservationId, userId);
        if (result == 0) {
            throw new IllegalArgumentException("취소할 수 없는 예약입니다.");
        }
    }
}
