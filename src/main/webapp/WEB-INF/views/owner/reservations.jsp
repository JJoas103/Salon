<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | 예약현황관리</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="/resources/css/common.css">
  <link rel="stylesheet" href="/resources/css/owner.css">
</head>
<body class="store-page">
  <jsp:include page="../includes/sidebar_owner.jsp">
      <jsp:param name="menu" value="reservations" />
  </jsp:include>
  <jsp:include page="../includes/salon_gate_overlay.jsp" />
  <div class="app-container">
    <header class="app-header">
      <div style="font-size: 18px; font-weight: 700;">예약현황관리</div>
      <div class="user-badge" id="openProfileModalBtn" style="cursor:pointer;"><span>${user.userName} 점주님</span><div class="user-avatar-sm" style="width:32px; height:32px; border-radius:50%; background:#E0E0E0; display:inline-flex; align-items:center; justify-content:center; margin-left:10px;">점</div></div>
    </header>
    <main class="app-content">
      <c:if test="${not empty error}">
        <p class="error-text"><c:out value="${error}" /></p>
      </c:if>
      <c:if test="${not empty success}">
        <p class="success-text"><c:out value="${success}" /></p>
      </c:if>

      <div class="modern-card">
        <div class="flex-between board-head">
          <div class="board-title">
            <h3>${fn:replace(scheduleDate, '-', '.')} (${dayLabel})</h3>
            <c:if test="${scheduleDate == today}"><span class="tag tag-accent">오늘</span></c:if>
            <span class="tag">예약 ${board.bookedCount}건</span>
          </div>
          <div class="board-datenav">
            <a class="btn-modern btn-outline" href="${ctx}/owner/reservations?date=${prevDate}" aria-label="이전 날">&lsaquo;</a>
            <button type="button" class="btn-modern btn-outline" id="openDatePickerBtn">날짜 선택</button>
            <a class="btn-modern btn-outline" href="${ctx}/owner/reservations?date=${nextDate}" aria-label="다음 날">&rsaquo;</a>
            <a class="btn-modern btn-primary" href="${ctx}/owner/reservations">오늘</a>
          </div>
        </div>

        <c:choose>
          <c:when test="${empty board.stylists}">
            <p class="board-empty">등록된 디자이너가 없습니다. 직원관리에서 디자이너를 먼저 등록해주세요.</p>
          </c:when>
          <c:when test="${empty board.rows}">
            <p class="board-empty">이 날은 영업하지 않습니다.</p>
          </c:when>
          <c:otherwise>
            <div class="board-scroll">
              <table class="board-table">
                <thead>
                  <tr>
                    <th class="board-timecol">시간</th>
                    <c:forEach var="st" items="${board.stylists}">
                      <th><c:out value="${st.stylistName}" /></th>
                    </c:forEach>
                  </tr>
                </thead>
                <tbody>
                  <c:forEach var="row" items="${board.rows}">
                    <tr class="${row.past ? 'is-past' : ''} ${row.current ? 'is-current' : ''}">
                      <th class="board-timecol">${row.time}</th>
                      <c:forEach var="cell" items="${row.cells}">
                        <c:choose>
                          <%-- 예약이 있는 칸: 근무시간 밖이어도 반드시 보여준다 --%>
                          <c:when test="${not empty cell.reservation}">
                            <c:set var="r" value="${cell.reservation}" />
                            <td class="board-cell is-booked ${cell.outsideHours ? 'is-outside' : ''}">
                              <div class="board-book">
                                <div class="board-book-top">
                                  <strong><c:out value="${r.customerName}" /></strong>
                                  <span class="status-badge status-${r.displayStatus == '진행중' ? 'ongoing'
                                    : r.displayStatus == '예약됨' ? 'confirmed'
                                    : r.displayStatus == '완료' ? 'completed' : 'pending'}">${r.displayStatus}</span>
                                </div>
                                <div class="board-book-sub">
                                  <c:out value="${r.serviceName}" />
                                  <span class="board-book-time">${row.time}~${r.endTime}</span>
                                </div>
                                <c:if test="${cell.outsideHours}">
                                  <div class="board-book-warn"><i class="fas fa-triangle-exclamation"></i> 근무시간 외</div>
                                </c:if>
                                <c:if test="${r.rejectable}">
                                  <button type="button" class="btn-modern btn-outline board-reject reject-btn"
                                          data-reservation-id="${r.reservationId}"
                                          data-customer-name="<c:out value='${r.customerName}' />"
                                          data-customer-phone="<c:out value='${r.customerPhone}' />"
                                          data-service-name="<c:out value='${r.serviceName}' />"
                                          data-amount="<fmt:formatNumber value='${r.amount}' pattern='#,##0' />"
                                          data-phase="${r.displayStatus == '예약됨' ? 'before' : (r.displayStatus == '진행중' ? 'during' : 'after')}"
                                          data-when="${fn:replace(scheduleDate, '-', '.')} ${row.time}">${r.displayStatus == '예약됨' ? '거절' : '정리'}</button>
                                </c:if>
                              </div>
                            </td>
                          </c:when>
                          <%-- 앞 시각에 시작한 시술이 물고 있는 칸 (겹침은 막지 않되 점유는 보여준다) --%>
                          <c:when test="${cell.occupied}">
                            <td class="board-cell is-occupied"><span>시술 중</span></td>
                          </c:when>
                          <c:when test="${cell.working}">
                            <td class="board-cell is-open"><span>예약 가능</span></td>
                          </c:when>
                          <c:otherwise>
                            <td class="board-cell is-off"></td>
                          </c:otherwise>
                        </c:choose>
                      </c:forEach>
                    </tr>
                  </c:forEach>
                </tbody>
              </table>
            </div>
            <p class="board-legend">
              <span class="board-legend-item"><i class="board-dot dot-open"></i> 예약 가능</span>
              <span class="board-legend-item"><i class="board-dot dot-booked"></i> 예약</span>
              <span class="board-legend-item"><i class="board-dot dot-occupied"></i> 시술 중</span>
              <span class="board-legend-item"><i class="board-dot dot-off"></i> 근무 없음</span>
            </p>
          </c:otherwise>
        </c:choose>
      </div>

      <div class="modern-card">
        <div class="flex-between" style="margin-bottom: 20px;">
          <h3>전체 예약 내역</h3>
          <div class="tag">총 ${totalCount}건</div>
        </div>
        <table class="modern-table">
          <thead>
            <tr><th>예약시간</th><th>고객명</th><th>담당 디자이너</th><th>시술메뉴</th><th>상태</th><th>관리</th></tr>
          </thead>
          <tbody>
            <c:if test="${empty reservations}">
              <tr><td colspan="6" class="board-empty">예약 내역이 없습니다.</td></tr>
            </c:if>
            <c:forEach var="r" items="${reservations}">
              <tr>
                <td>${fn:substring(r.reservationTime, 0, 16)}</td>
                <td><c:out value="${r.customerName}" /></td>
                <td><c:out value="${not empty r.stylistName ? r.stylistName : '미지정'}" /></td>
                <td><c:out value="${r.serviceName}" /></td>
                <td>
                  <span class="status-badge status-${r.displayStatus == '진행중' ? 'ongoing'
                    : r.displayStatus == '예약됨' ? 'confirmed'
                    : r.displayStatus == '완료' ? 'completed'
                    : r.displayStatus == '노쇼' ? 'noshow'
                    : r.displayStatus == '거절됨' || r.displayStatus == '취소됨' ? 'cancelled' : 'pending'}">${r.displayStatus}</span>
                  <c:if test="${not empty r.rejectReason}">
                    <span class="board-reason" title="<c:out value='${r.rejectReason}' />"><c:out value="${r.rejectReason}" /></span>
                  </c:if>
                </td>
                <td>
                  <c:choose>
                    <c:when test="${r.rejectable}">
                      <button type="button" class="btn-modern btn-outline reject-btn"
                              data-reservation-id="${r.reservationId}"
                              data-customer-name="<c:out value='${r.customerName}' />"
                              data-customer-phone="<c:out value='${r.customerPhone}' />"
                              data-service-name="<c:out value='${r.serviceName}' />"
                              data-amount="<fmt:formatNumber value='${r.amount}' pattern='#,##0' />"
                              data-phase="${r.displayStatus == '예약됨' ? 'before' : (r.displayStatus == '진행중' ? 'during' : 'after')}"
                              data-when="${fn:substring(r.reservationTime, 0, 16)}">${r.displayStatus == '예약됨' ? '거절' : '정리'}</button>
                    </c:when>
                    <c:otherwise>-</c:otherwise>
                  </c:choose>
                </td>
              </tr>
            </c:forEach>
          </tbody>
        </table>

        <c:if test="${totalPages > 1}">
          <div class="board-pagination">
            <c:forEach var="p" begin="1" end="${totalPages}">
              <a class="board-page ${p == page ? 'is-active' : ''}"
                 href="${ctx}/owner/reservations?date=${scheduleDate}&page=${p}&size=${size}">${p}</a>
            </c:forEach>
          </div>
        </c:if>
      </div>
    </main>
  </div>

  <div class="modal-overlay" id="datePickerModal">
    <div class="modal-box" style="max-width: 340px;">
      <div class="modal-header">
        <h3 style="font-size: 18px;">날짜 선택</h3>
        <button type="button" class="modal-close" id="closeDatePickerBtn"><i class="fas fa-times"></i></button>
      </div>
      <div class="mini-cal-nav">
        <button type="button" id="calPrevBtn" class="btn-modern btn-outline" style="padding:4px 10px;">&lsaquo;</button>
        <span id="calMonthLabel" style="font-weight:700; font-size:14px;"></span>
        <button type="button" id="calNextBtn" class="btn-modern btn-outline" style="padding:4px 10px;">&rsaquo;</button>
      </div>
      <div class="mini-cal-weekdays"><span>일</span><span>월</span><span>화</span><span>수</span><span>목</span><span>금</span><span>토</span></div>
      <div class="mini-cal-grid" id="calGrid"></div>
    </div>
  </div>

  <div class="modal-overlay" id="rejectModal">
    <div class="modal-box">
      <div class="modal-header">
        <h3 style="font-size: 18px;" id="rejectTitle">예약 거절</h3>
        <button type="button" class="modal-close" id="closeRejectModalBtn"><i class="fas fa-times"></i></button>
      </div>
      <form id="rejectForm" method="post">
        <%-- 처리 후 보고 있던 날짜/페이지로 되돌아오도록 함께 넘긴다 --%>
        <input type="hidden" name="date" value="${scheduleDate}">
        <input type="hidden" name="page" value="${page}">
        <input type="hidden" name="size" value="${size}">
        <dl class="reject-summary">
          <dt>고객</dt><dd id="rejectCustomer"></dd>
          <dt>연락처</dt><dd><a id="rejectPhoneLink" href="#"></a></dd>
          <dt>예약</dt><dd id="rejectWhen"></dd>
          <dt>시술</dt><dd id="rejectService"></dd>
        </dl>

        <%-- 시술 시각이 지난 예약은 노쇼(환불 없음)와 취소(환불) 중 점주가 고른다.
             예약 전(before)이면 노쇼가 성립하지 않으므로 취소+환불만 노출한다. --%>
        <div class="reject-resolution" id="resolutionChoice">
          <label class="reject-radio" id="optRejected">
            <input type="radio" name="resolution" value="rejected"> 취소하고 전액 환불
          </label>
          <label class="reject-radio" id="optNoShow">
            <input type="radio" name="resolution" value="no_show"> 노쇼 처리 (환불 없음)
          </label>
        </div>

        <p class="reject-refund" id="refundNote"></p>

        <label for="rejectReasonInput" class="reject-label">사유</label>
        <textarea id="rejectReasonInput" name="rejectReason" class="modern-input"
                  style="height:80px; resize:none;" required
                  placeholder="예) 디자이너 병가로 부득이하게 예약을 취소합니다."></textarea>
        <button type="submit" id="rejectSubmit" class="btn-modern btn-danger" style="width:100%; margin-top:16px;">거절하고 환불하기</button>
      </form>
    </div>
  </div>

  <jsp:include page="../includes/profile_modal.jsp">
      <jsp:param name="roleLabel" value="점주" />
  </jsp:include>

  <script>
    var ctx = '${ctx}';

    /* ---- 예약 정리(거절/노쇼) 모달 ---- */
    var rejectModal = document.getElementById('rejectModal');
    var rejectForm = document.getElementById('rejectForm');
    var optNoShow = document.getElementById('optNoShow');
    var refundNote = document.getElementById('refundNote');
    var rejectSubmit = document.getElementById('rejectSubmit');
    var rejectTitle = document.getElementById('rejectTitle');
    var curAmount = '0';

    // 선택된 처리(취소+환불 / 노쇼)에 따라 안내문과 버튼을 바꾼다
    function syncResolution() {
      var noShow = rejectForm.querySelector('input[name=resolution]:checked').value === 'no_show';
      if (noShow) {
        refundNote.className = 'reject-refund is-noshow';
        refundNote.textContent = '환불 없이 노쇼로 마감합니다. 결제 금액은 매장에 정산됩니다.';
        rejectSubmit.textContent = '노쇼로 처리하기';
      } else {
        refundNote.className = 'reject-refund';
        refundNote.innerHTML = '<strong>' + curAmount + '원</strong>이 자동 환불되며 되돌릴 수 없습니다. 먼저 고객에게 연락해주세요.';
        rejectSubmit.textContent = '거절하고 환불하기';
      }
    }
    rejectForm.querySelectorAll('input[name=resolution]').forEach(function (radio) {
      radio.addEventListener('change', syncResolution);
    });

    document.querySelectorAll('.reject-btn').forEach(function (btn) {
      btn.addEventListener('click', function () {
        var phone = btn.dataset.customerPhone;
        curAmount = btn.dataset.amount || '0';
        document.getElementById('rejectCustomer').textContent = btn.dataset.customerName;
        document.getElementById('rejectWhen').textContent = btn.dataset.when;
        document.getElementById('rejectService').textContent = btn.dataset.serviceName;

        var link = document.getElementById('rejectPhoneLink');
        link.textContent = phone || '등록된 연락처 없음';
        if (phone) { link.href = 'tel:' + phone.replace(/-/g, ''); }
        else { link.removeAttribute('href'); }

        // 시점(before/during/after)에 따라 노쇼 노출 여부와 기본 선택을 정한다
        var phase = btn.dataset.phase; // before | during | after
        if (phase === 'before') {
          optNoShow.style.display = 'none';               // 아직 안 온 예약은 노쇼가 성립하지 않음
          rejectForm.querySelector('input[value=rejected]').checked = true;
          rejectTitle.textContent = '예약 거절';
        } else {
          optNoShow.style.display = '';
          rejectTitle.textContent = '예약 정리';
          // 시술이 끝난 시각이면 노쇼가 기본, 진행 중이면 취소+환불이 기본
          rejectForm.querySelector(phase === 'after' ? 'input[value=no_show]' : 'input[value=rejected]').checked = true;
        }
        syncResolution();

        document.getElementById('rejectReasonInput').value = '';
        rejectForm.action = ctx + '/owner/reservations/' + btn.dataset.reservationId + '/reject';
        rejectModal.classList.add('active');
      });
    });
    document.getElementById('closeRejectModalBtn').addEventListener('click', function () {
      rejectModal.classList.remove('active');
    });
    rejectModal.addEventListener('click', function (e) { if (e.target === rejectModal) rejectModal.classList.remove('active'); });

    /* ---- 날짜 선택 (예약 페이지와 같은 .mini-cal-* 격자를 쓴다) ---- */
    var dateModal = document.getElementById('datePickerModal');
    var calGrid = document.getElementById('calGrid');
    var calLabel = document.getElementById('calMonthLabel');
    var selectedDate = '${scheduleDate}';
    var todayStr = '${today}';
    var view = { year: +selectedDate.slice(0, 4), month: +selectedDate.slice(5, 7) - 1 };

    function renderCal() {
      calLabel.textContent = view.year + '년 ' + (view.month + 1) + '월';
      calGrid.innerHTML = '';
      var first = new Date(view.year, view.month, 1).getDay();
      var days = new Date(view.year, view.month + 1, 0).getDate();
      for (var i = 0; i < first; i++) { calGrid.appendChild(document.createElement('span')); }
      for (var d = 1; d <= days; d++) {
        var iso = view.year + '-' + String(view.month + 1).padStart(2, '0') + '-' + String(d).padStart(2, '0');
        var cell = document.createElement('button');
        cell.type = 'button';
        cell.className = 'mini-cal-day';
        cell.textContent = d;
        if (iso === todayStr) cell.classList.add('is-today');
        if (iso === selectedDate) cell.classList.add('is-selected');
        cell.addEventListener('click', (function (picked) {
          return function () { location.href = ctx + '/owner/reservations?date=' + picked; };
        })(iso));
        calGrid.appendChild(cell);
      }
    }
    document.getElementById('openDatePickerBtn').addEventListener('click', function () {
      renderCal();
      dateModal.classList.add('active');
    });
    document.getElementById('closeDatePickerBtn').addEventListener('click', function () {
      dateModal.classList.remove('active');
    });
    dateModal.addEventListener('click', function (e) { if (e.target === dateModal) dateModal.classList.remove('active'); });
    document.getElementById('calPrevBtn').addEventListener('click', function () {
      if (--view.month < 0) { view.month = 11; view.year--; }
      renderCal();
    });
    document.getElementById('calNextBtn').addEventListener('click', function () {
      if (++view.month > 11) { view.month = 0; view.year++; }
      renderCal();
    });
  </script>
</body>
</html>
