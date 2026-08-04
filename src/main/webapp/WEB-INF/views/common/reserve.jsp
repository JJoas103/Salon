<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | 예약하기</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="/resources/css/common.css">
  <link rel="stylesheet" href="/resources/css/user.css">
  <link rel="stylesheet" href="/resources/css/auth.css">
</head>
<body class="reserve-page">
  <jsp:include page="../includes/sidebar_common.jsp">
    <jsp:param name="menu" value="search" />
  </jsp:include>

  <div class="app-container">
    <header class="app-header"></header>
    <main class="app-content">
      <c:choose>
        <%-- 매장을 못 찾은 경우: 단계 UI 자체를 띄우지 않는다 --%>
        <c:when test="${salonNotFound}">
          <div class="modern-card reserve-empty-card">
            <h2>헤어샵을 찾을 수 없습니다.</h2>
            <p>지도에서 헤어샵을 다시 선택해 주세요.</p>
            <button type="button" class="btn-modern btn-primary"
                    onclick="location.href='<c:url value="/common/salonmap"/>'">지도로 돌아가기</button>
          </div>
        </c:when>

        <c:otherwise>
          <div class="reserve-layout">
            <%-- ============ 왼쪽: 단계별 아코디언 ============ --%>
            <div class="reserve-main">

              <%-- 매장 요약 헤더 --%>
              <div class="reserve-salon-head">
                <div>
                  <h1><c:out value="${salon.salonName}"/></h1>
                  <p class="reserve-salon-address">
                    <i class="fas fa-location-dot"></i> <c:out value="${salon.address}"/>
                  </p>
                </div>
                <span class="rating-badge">
                  <i class="fas fa-star"></i>
                  <fmt:formatNumber value="${salon.averageRating}" pattern="0.0"/>
                </span>
              </div>

              <%-- ---------- STEP 1 : 시술 메뉴 ---------- --%>
              <%-- 시술을 가장 먼저 고르게 한다. 금액과 소요시간이 이후 단계의 안내 문구에 쓰인다. --%>
              <section class="reserve-step is-open" data-step="1" id="reserveStep1">
                <button type="button" class="reserve-step-head">
                  <span class="reserve-step-no">1</span>
                  <span class="reserve-step-title">시술 메뉴</span>
                  <span class="reserve-step-picked"></span>
                  <i class="fas fa-chevron-down reserve-step-caret"></i>
                </button>
                <div class="reserve-step-body">
                  <div class="reserve-step-inner">
                    <c:choose>
                      <c:when test="${empty services}">
                        <p class="reserve-blank">등록된 시술 메뉴가 없습니다.</p>
                      </c:when>
                      <c:otherwise>
                        <div class="reserve-service-list">
                          <c:forEach var="service" items="${services}">
                            <button type="button" class="reserve-service-card"
                                    data-service-id="${service.serviceId}"
                                    data-service-name="<c:out value='${service.serviceName}'/>"
                                    data-price="${service.price}"
                                    data-duration="${service.durationMinutes}">
                              <span class="reserve-service-info">
                                <strong><c:out value="${service.serviceName}"/></strong>
                                <c:if test="${not empty service.description}">
                                  <span class="reserve-service-desc"><c:out value="${service.description}"/></span>
                                </c:if>
                                <c:if test="${service.durationMinutes > 0}">
                                  <span class="reserve-service-duration">
                                    <i class="far fa-clock"></i> 약 ${service.durationMinutes}분 소요
                                  </span>
                                </c:if>
                              </span>
                              <span class="reserve-service-price">
                                <fmt:formatNumber value="${service.price}" pattern="#,##0"/>원
                              </span>
                            </button>
                          </c:forEach>
                        </div>
                      </c:otherwise>
                    </c:choose>
                  </div>
                </div>
              </section>

              <%-- ---------- STEP 2 : 디자이너 ---------- --%>
              <section class="reserve-step is-locked" data-step="2" id="reserveStep2">
                <button type="button" class="reserve-step-head">
                  <span class="reserve-step-no">2</span>
                  <span class="reserve-step-title">디자이너</span>
                  <span class="reserve-step-picked"></span>
                  <i class="fas fa-chevron-down reserve-step-caret"></i>
                </button>
                <div class="reserve-step-body">
                  <div class="reserve-step-inner">
                    <c:choose>
                      <c:when test="${empty stylists}">
                        <p class="reserve-blank">등록된 디자이너가 없습니다.</p>
                      </c:when>
                      <c:otherwise>
                        <div class="reserve-stylist-grid">
                          <c:forEach var="stylist" items="${stylists}">
                            <button type="button" class="reserve-stylist-card"
                                    data-stylist-id="${stylist.stylistId}"
                                    data-stylist-name="<c:out value='${stylist.stylistName}'/>">
                              <c:choose>
                                <c:when test="${not empty stylist.imageUrl}">
                                  <img src="<c:out value='${stylist.imageUrl}'/>" alt=""
                                       class="reserve-stylist-photo">
                                </c:when>
                                <c:otherwise>
                                  <span class="reserve-stylist-photo reserve-stylist-photo-blank">
                                    <i class="fas fa-user"></i>
                                  </span>
                                </c:otherwise>
                              </c:choose>
                              <strong><c:out value="${stylist.stylistName}"/></strong>
                              <c:if test="${not empty stylist.description}">
                                <span class="reserve-stylist-desc"><c:out value="${stylist.description}"/></span>
                              </c:if>
                            </button>
                          </c:forEach>
                        </div>
                      </c:otherwise>
                    </c:choose>
                  </div>
                </div>
              </section>

              <%-- ---------- STEP 3 : 날짜 · 시간 ----------
                   달력 오른쪽 빈 공간에 시간대를 함께 놓는다. 날짜를 고르면 그 자리에서
                   바로 시간이 채워지므로 단계를 하나 더 두지 않는다. --%>
              <section class="reserve-step is-locked" data-step="3" id="reserveStep3">
                <button type="button" class="reserve-step-head">
                  <span class="reserve-step-no">3</span>
                  <span class="reserve-step-title">날짜 &middot; 시간</span>
                  <span class="reserve-step-picked"></span>
                  <i class="fas fa-chevron-down reserve-step-caret"></i>
                </button>
                <div class="reserve-step-body">
                  <div class="reserve-step-inner">
                    <div class="reserve-datetime">
                      <%-- 격자(.mini-cal-*)는 점주 스케줄 모달과 공유하는 공용 캘린더다 (common.css).
                           휴무일 여부는 영업시간을 클라이언트가 모르므로 여기서 막지 않고,
                           날짜를 고른 뒤 서버 슬롯 응답이 비어 있는 것으로 알린다. --%>
                      <div class="reserve-calendar">
                        <div class="mini-cal-nav">
                          <button type="button" class="btn-modern btn-outline reserve-cal-nav-btn"
                                  id="reserveCalPrev" aria-label="이전 달">&lsaquo;</button>
                          <span class="reserve-cal-label" id="reserveCalLabel"></span>
                          <button type="button" class="btn-modern btn-outline reserve-cal-nav-btn"
                                  id="reserveCalNext" aria-label="다음 달">&rsaquo;</button>
                        </div>
                        <div class="mini-cal-weekdays">
                          <span class="is-sunday">일</span><span>월</span><span>화</span><span>수</span>
                          <span>목</span><span>금</span><span class="is-saturday">토</span>
                        </div>
                        <div class="mini-cal-grid" id="reserveCalGrid"></div>
                      </div>

                      <div class="reserve-timepick">
                        <h4 class="reserve-timepick-title" id="reserveTimeTitle">시간 선택</h4>
                        <div class="reserve-slot-status" id="reserveSlotStatus">
                          왼쪽에서 날짜를 먼저 선택해 주세요.
                        </div>
                        <div class="reserve-slot-grid" id="reserveSlotGrid"></div>
                        <p class="reserve-slot-legend">
                          <span class="reserve-slot-legend-item"><i class="reserve-dot reserve-dot-open"></i> 예약 가능</span>
                          <span class="reserve-slot-legend-item"><i class="reserve-dot reserve-dot-closed"></i> 마감</span>
                        </p>
                      </div>
                    </div>
                  </div>
                </div>
              </section>
            </div>

            <%-- ============ 오른쪽: 예약 확인 + 결제 ============ --%>
            <aside class="reserve-summary">
              <h3 class="reserve-summary-title">예약 확인</h3>

              <dl class="reserve-summary-list">
                <div class="reserve-summary-row">
                  <dt>매장</dt>
                  <dd><c:out value="${salon.salonName}"/></dd>
                </div>
                <div class="reserve-summary-row" id="sumServiceRow">
                  <dt>시술</dt>
                  <dd class="is-blank" id="sumService">선택 전</dd>
                </div>
                <div class="reserve-summary-row" id="sumStylistRow">
                  <dt>디자이너</dt>
                  <dd class="is-blank" id="sumStylist">선택 전</dd>
                </div>
                <div class="reserve-summary-row" id="sumWhenRow">
                  <dt>일시</dt>
                  <dd class="is-blank" id="sumWhen">선택 전</dd>
                </div>
              </dl>

              <div class="reserve-summary-total">
                <span>결제 금액</span>
                <strong id="sumPrice">-</strong>
              </div>

              <%-- 결제는 상태를 바꾸는 일이라 GET 이 아니라 POST 로 보낸다.
                   서버가 예약(pending)을 만든 뒤 카카오페이 결제창으로 리다이렉트한다. --%>
              <form action="<c:url value='/common/reserve'/>" method="post" id="reserveForm">
                <input type="hidden" name="salonId" value="${salon.salonId}">
                <input type="hidden" name="serviceId" id="fieldServiceId">
                <input type="hidden" name="stylistId" id="fieldStylistId">
                <input type="hidden" name="reservationTime" id="fieldReservationTime">
                <button type="submit" class="btn-modern btn-accent reserve-pay-btn" id="reservePayBtn" disabled>
                  <i class="fas fa-comment"></i> 카카오페이로 결제하기
                </button>
              </form>

              <p class="reserve-summary-note">
                결제가 완료되면 예약이 확정됩니다. 결제창에서 10분 내 진행하지 않으면
                선택한 시간이 자동으로 해제됩니다.
              </p>
            </aside>
          </div>
        </c:otherwise>
      </c:choose>
    </main>
  </div>

<c:if test="${not salonNotFound}">
  <script>
    /* 슬롯 조회 주소. 컨트롤러가 [{time:"10:00", available:true}, ...] 를 돌려준다. */
    const SLOT_URL = '<c:url value="/common/reserve/slots"/>';

    /* 사용자가 지금까지 고른 값. 단계가 열리는 조건과 요약 패널이 모두 이 객체만 본다. */
    const picked = {
      serviceId: null, serviceName: '', price: 0, duration: 0,
      stylistId: null, stylistName: '',
      date: null, dateLabel: '',
      time: null
    };

    const steps = [...document.querySelectorAll('.reserve-step')];
    const stepOf = n => steps.find(s => s.dataset.step === String(n));

    /* ---------- 단계 열기/닫기 ---------- */

    /* 한 번에 한 단계만 펼친다. 잠긴(is-locked) 단계는 열리지 않는다. */
    function openStep(n, scroll) {
      const target = stepOf(n);
      if (!target || target.classList.contains('is-locked')) return;

      steps.forEach(s => s.classList.remove('is-open'));
      target.classList.add('is-open');

      /* 스크롤 컨테이너가 .app-content 라 scrollIntoView 가 그 안에서 동작한다.
         단계를 고른 직후에만 따라가고, 사용자가 헤더를 눌러 되돌아본 경우엔 가만히 둔다. */
      if (scroll) {
        setTimeout(() => target.scrollIntoView({ behavior: 'smooth', block: 'start' }), 120);
      }
    }

    /* 헤더 오른쪽에 지금까지 고른 값을 적는다 (아직 완료는 아닐 수 있다). */
    function setPickedLabel(n, label) {
      stepOf(n).querySelector('.reserve-step-picked').textContent = label;
    }

    /* 단계를 완료 표시하고 헤더에 고른 값을 적는다. */
    function markDone(n, label) {
      stepOf(n).classList.add('is-done');
      setPickedLabel(n, label);
    }

    function unlock(n) {
      stepOf(n).classList.remove('is-locked');
    }

    /* 뒤쪽 단계를 초기화한다. 앞 단계를 다시 고르면 그 뒤 선택은 의미가 없어진다.
       예) 디자이너를 바꾸면 이미 고른 시간은 그 디자이너의 시간이 아니다. */
    function resetFrom(n) {
      for (let i = n; i <= 3; i++) {
        const step = stepOf(i);
        step.classList.add('is-locked');
        step.classList.remove('is-done', 'is-open');
        setPickedLabel(i, '');
        step.querySelectorAll('.is-selected').forEach(el => el.classList.remove('is-selected'));
      }
      if (n <= 2) { picked.stylistId = null; picked.stylistName = ''; }
      if (n <= 3) {
        picked.date = null; picked.dateLabel = ''; picked.time = null;
        clearSlots();
      }
    }

    /* 헤더를 누르면 이미 지난 단계로 되돌아갈 수 있다. */
    steps.forEach(step => {
      step.querySelector('.reserve-step-head').addEventListener('click', () => {
        if (step.classList.contains('is-locked')) return;
        if (step.classList.contains('is-open')) step.classList.remove('is-open');
        else openStep(Number(step.dataset.step), false);
      });
    });

    /* ---------- STEP 1 : 시술 ---------- */
    document.querySelectorAll('.reserve-service-card').forEach(card => {
      card.addEventListener('click', () => {
        document.querySelectorAll('.reserve-service-card')
                .forEach(c => c.classList.remove('is-selected'));
        card.classList.add('is-selected');

        picked.serviceId   = card.dataset.serviceId;
        picked.serviceName = card.dataset.serviceName;
        picked.price       = Number(card.dataset.price);
        picked.duration    = Number(card.dataset.duration);

        resetFrom(2);
        markDone(1, picked.serviceName);
        unlock(2);
        openStep(2, true);
        refreshSummary();
      });
    });

    /* ---------- STEP 2 : 디자이너 ---------- */
    document.querySelectorAll('.reserve-stylist-card').forEach(card => {
      card.addEventListener('click', () => {
        document.querySelectorAll('.reserve-stylist-card')
                .forEach(c => c.classList.remove('is-selected'));
        card.classList.add('is-selected');

        picked.stylistId   = card.dataset.stylistId;
        picked.stylistName = card.dataset.stylistName;

        resetFrom(3);
        renderCalendar();
        markDone(2, picked.stylistName + ' 디자이너');
        unlock(3);
        openStep(3, true);
        refreshSummary();
      });
    });

    /* ---------- STEP 3 : 날짜 (월 단위 캘린더) ---------- */
    const DAY_KO = ['일', '월', '화', '수', '목', '금', '토'];

    const calGrid  = document.getElementById('reserveCalGrid');
    const calLabel = document.getElementById('reserveCalLabel');
    const calPrev  = document.getElementById('reserveCalPrev');
    const calNext  = document.getElementById('reserveCalNext');

    const today    = new Date();
    const todayStr = formatDate(today);
    /* 지금 펼쳐 보고 있는 달 */
    const calView  = { year: today.getFullYear(), month: today.getMonth() };

    function formatDate(d) {
      return d.getFullYear() + '-'
           + String(d.getMonth() + 1).padStart(2, '0') + '-'
           + String(d.getDate()).padStart(2, '0');
    }

    function renderCalendar() {
      calLabel.textContent = calView.year + '년 ' + (calView.month + 1) + '월';
      calGrid.innerHTML = '';

      /* 이번 달 1일이 무슨 요일인지에 맞춰 앞쪽을 빈 칸으로 채운다 */
      const firstDow    = new Date(calView.year, calView.month, 1).getDay();
      const daysInMonth = new Date(calView.year, calView.month + 1, 0).getDate();
      for (let i = 0; i < firstDow; i++) calGrid.appendChild(document.createElement('div'));

      for (let d = 1; d <= daysInMonth; d++) {
        const date    = new Date(calView.year, calView.month, d);
        const dateStr = formatDate(date);
        const dow     = date.getDay();

        const cell = document.createElement('button');
        cell.type = 'button';
        cell.className = 'mini-cal-day';
        cell.textContent = d;

        if (dateStr < todayStr) {
          /* 지난 날짜는 고를 수 없다 */
          cell.disabled = true;
          cell.classList.add('is-past');
        } else {
          if (dateStr === todayStr) cell.classList.add('is-today');
          if (dow === 0) cell.classList.add('is-sunday');
          if (dow === 6) cell.classList.add('is-saturday');
          if (picked.date === dateStr) cell.classList.add('is-selected');

          cell.addEventListener('click', () => {
            picked.date      = dateStr;
            picked.dateLabel = (calView.month + 1) + '월 ' + d + '일 (' + DAY_KO[dow] + ')';
            /* 날짜가 바뀌면 이미 고른 시간은 그 날의 시간이 아니다 */
            picked.time = null;

            renderCalendar();
            /* 시간까지 골라야 완료다. 날짜만으로는 헤더 표시만 갱신한다. */
            stepOf(3).classList.remove('is-done');
            setPickedLabel(3, picked.dateLabel);
            refreshSummary();
            loadSlots();
          });
        }
        calGrid.appendChild(cell);
      }

      /* 이번 달보다 과거로는 넘어갈 이유가 없다 */
      calPrev.disabled = (calView.year === today.getFullYear() && calView.month === today.getMonth());
    }

    function moveMonth(delta) {
      const m = new Date(calView.year, calView.month + delta, 1);
      calView.year  = m.getFullYear();
      calView.month = m.getMonth();
      renderCalendar();
    }

    calPrev.addEventListener('click', () => moveMonth(-1));
    calNext.addEventListener('click', () => moveMonth(1));
    renderCalendar();

    /* ---------- STEP 3 오른쪽 : 시간 ---------- */
    const slotGrid   = document.getElementById('reserveSlotGrid');
    const slotStatus = document.getElementById('reserveSlotStatus');
    const timeTitle  = document.getElementById('reserveTimeTitle');

    /* 아직 날짜를 안 골랐거나 앞 단계가 바뀐 상태로 되돌린다 */
    function clearSlots() {
      slotGrid.innerHTML = '';
      slotStatus.textContent = '왼쪽에서 날짜를 먼저 선택해 주세요.';
      slotStatus.className = 'reserve-slot-status';
      timeTitle.textContent = '시간 선택';
    }

    function loadSlots() {
      slotGrid.innerHTML = '';
      timeTitle.textContent = picked.dateLabel;
      slotStatus.textContent = '예약 가능한 시간을 불러오는 중입니다...';
      slotStatus.className = 'reserve-slot-status is-loading';

      const query = '?stylistId=' + encodeURIComponent(picked.stylistId)
                  + '&date=' + encodeURIComponent(picked.date);

      fetch(SLOT_URL + query, { headers: { 'Accept': 'application/json' } })
        .then(res => {
          if (!res.ok) throw new Error('slot fetch failed');
          return res.json();
        })
        .then(slots => renderSlots(slots))
        .catch(() => {
          slotStatus.textContent = '시간을 불러오지 못했습니다. 잠시 후 다시 시도해 주세요.';
          slotStatus.className = 'reserve-slot-status is-error';
        });
    }

    function renderSlots(slots) {
      slotGrid.innerHTML = '';

      if (!slots || slots.length === 0) {
        slotStatus.textContent = '이 날은 예약할 수 있는 시간이 없습니다. 다른 날짜를 선택해 주세요.';
        slotStatus.className = 'reserve-slot-status is-error';
        return;
      }

      const openCount = slots.filter(s => s.available).length;
      if (openCount === 0) {
        slotStatus.textContent = '이 날은 모두 마감되었습니다. 다른 날짜를 선택해 주세요.';
        slotStatus.className = 'reserve-slot-status is-error';
      } else {
        slotStatus.textContent = '예약 가능한 시간 ' + openCount + '개';
        slotStatus.className = 'reserve-slot-status';
      }

      slots.forEach(slot => {
        const btn = document.createElement('button');
        btn.type = 'button';
        btn.className = 'reserve-slot' + (slot.available ? '' : ' is-closed');
        btn.textContent = slot.time;
        btn.disabled = !slot.available;

        if (slot.available) {
          btn.addEventListener('click', () => {
            slotGrid.querySelectorAll('.reserve-slot')
                    .forEach(b => b.classList.remove('is-selected'));
            btn.classList.add('is-selected');

            picked.time = slot.time;
            markDone(3, picked.dateLabel + ' ' + slot.time);
            refreshSummary();

            /* 마지막 선택이라 다음에 열 단계가 없다. 요약 패널이 옆에 붙어 있는 넓은 화면에서는
               결제 버튼이 이미 보이지만, 아래로 쌓이는 좁은 화면에서는 직접 데려가야 한다. */
            if (window.matchMedia('(max-width: 1280px)').matches) {
              setTimeout(() => {
                document.querySelector('.reserve-summary')
                        .scrollIntoView({ behavior: 'smooth', block: 'end' });
              }, 120);
            }
          });
        }
        slotGrid.appendChild(btn);
      });
    }

    /* ---------- 요약 패널 ---------- */
    const payBtn = document.getElementById('reservePayBtn');

    function setSummary(id, value) {
      const el = document.getElementById(id);
      el.textContent = value || '선택 전';
      el.classList.toggle('is-blank', !value);
    }

    function refreshSummary() {
      setSummary('sumService', picked.serviceName);
      setSummary('sumStylist', picked.stylistName ? picked.stylistName + ' 디자이너' : '');
      setSummary('sumWhen', (picked.date && picked.time)
          ? picked.dateLabel + ' ' + picked.time : '');

      document.getElementById('sumPrice').textContent =
          picked.serviceId ? picked.price.toLocaleString() + '원' : '-';

      /* 네 단계가 모두 채워져야 결제 버튼이 열린다 */
      const ready = picked.serviceId && picked.stylistId && picked.date && picked.time;
      payBtn.disabled = !ready;

      /* 앞 단계를 다시 고르면 뒤 선택이 풀리므로, 남아 있던 값도 같이 비운다 */
      document.getElementById('fieldServiceId').value = ready ? picked.serviceId : '';
      document.getElementById('fieldStylistId').value = ready ? picked.stylistId : '';
      /* 서버는 'yyyy-MM-dd HH:mm' 형태로 받는다 */
      document.getElementById('fieldReservationTime').value =
          ready ? picked.date + ' ' + picked.time : '';
    }

    /* 결제는 되돌리기 어려운 동작이라 한 번 더 확인받고, 중복 제출을 막는다. */
    document.getElementById('reserveForm').addEventListener('submit', e => {
      if (payBtn.disabled) { e.preventDefault(); return; }
      payBtn.disabled = true;
      payBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> 결제창으로 이동 중...';
    });
  </script>
</c:if>
</body>
</html>
