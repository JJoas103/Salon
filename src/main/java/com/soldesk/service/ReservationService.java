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

import com.soldesk.mapper.PaymentMapper;
import com.soldesk.mapper.ResvMapper;
import com.soldesk.mapper.SalonMapper;
import com.soldesk.mapper.StylistMapper;
import com.soldesk.mapper.StylistScheduleMapper;
import com.soldesk.vo.PaymentVO;
import com.soldesk.vo.PriceQuoteVO;
import com.soldesk.vo.ReservationVO;
import com.soldesk.vo.SalonGradeVO;
import com.soldesk.vo.SalonOperatingHourVO;
import com.soldesk.vo.ServiceVO;
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
     * 매장별 등급. 매장마다 점주가 서로 다른 별개 사업자라, 한 매장에서 쌓은 단골 이력이
     * 다른 매장 등급에 영향을 주면 안 된다 — 그래서 전체 합산이 아니라 매장별로 따로 계산한다.
     * (마이페이지 상단의 "누적 이용 건수"는 이 계산과 별개로 전체 활동량 참고용으로 남겨둔다)
     */
    @Transactional(readOnly = true)
    public List<SalonGradeVO> getSalonGrades(int userId){
        List<SalonGradeVO> grades = resvMapper.findCompletedCountsBySalon(userId);
        for (SalonGradeVO g : grades){
            g.setGrade(gradeOf(g.getCompletedCount()));
        }
        return grades;
    }

    /**
     * 완료 예약 건수 기준 등급 매핑. 기준 횟수(0~2 / 3~9 / 10+)는 실제 방문 분포를
     * 분석해 정한 게 아니라 상식적으로 잡은 임시값 — 서비스가 자리 잡으면 다시 조정해야 한다.
     */
    public String gradeOf(int completedCount){
        if (completedCount >= 10) return "VIP";
        if (completedCount >= 3) return "단골";
        return "새싹";
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
        //    폼 값만 믿으면 다른 매장의 싼 시술 가격으로 예약을 만들 수 있다.
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
        //    썼던 것과 똑같은 CheckoutService.quote() 를 부른다. 두 벌로 계산하면
        //    화면 금액과 청구 금액이 어긋난다.
        PriceQuoteVO quote = checkoutService.quote(userId, serviceId, userCouponId, pointToUse);

        // 5) 적립금 차감. 잔액이 모자라면 예외가 나고 이 트랜잭션이 통째로 롤백되므로,
        //    방금 만든 예약도 함께 사라진다. 되돌릴 것이 없다.
        pointService.use(userId, reservation.getReservationId(), quote.getPointUsed());

        // 6) 결제 행 (Payments.reservation_id 가 NOT NULL 1:1 이라 예약이 먼저 있어야 한다)
        PaymentVO payment = new PaymentVO();
        payment.setReservationId(reservation.getReservationId());
        payment.setUserId(userId);
        payment.setAmount(java.math.BigDecimal.valueOf(quote.getFinalAmount()));
        payment.setOriginalAmount(java.math.BigDecimal.valueOf(quote.getOriginalAmount()));
        payment.setCouponDiscount(java.math.BigDecimal.valueOf(quote.getCouponDiscount()));
        payment.setPointUsed(quote.getPointUsed());
        payment.setPgProvider(quote.getPgProvider());
        paymentMapper.insertPayment(payment);

        reservation.setServiceName(service.getServiceName());
        reservation.setAmount(quote.getFinalAmount());
        reservation.setPgProvider(quote.getPgProvider());
        return reservation;
    }

    @Transactional
    public ServiceVO validateCombination(int salonId, int stylistId, int serviceId){
        StylistVO stylist = stylistMapper.findById(stylistId);
        if(stylist == null || stylist.getSalonId() != salonId){
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
        if(paymentMapper.markCompleted(reservationId, paymentMethod) == 1) {   
            resvMapper.updateStatus(reservationId, "confirmed");
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
        if(paymentMapper.markFailed(reservationId) == 1){
            resvMapper.updateStatus(reservationId, "cancelled");
            pointService.restore(reservationId);
        }
    }

    @Transactional(readOnly = true)
    public ReservationVO getReservation(int reservationId) {
        return resvMapper.findById(reservationId);
    }

    @Transactional(readOnly = true)
    public PaymentVO getPayment(int reservationId) {
        return paymentMapper.findByReservationId(reservationId);
    }
}
