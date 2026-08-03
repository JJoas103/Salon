<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | 직원관리</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="/resources/css/common.css">
  <link rel="stylesheet" href="/resources/css/owner.css">
</head>
<body class="staff-page">
  <jsp:include page="../includes/sidebar_owner.jsp">
      <jsp:param name="menu" value="staff" />
  </jsp:include>
  <jsp:include page="../includes/salon_gate_overlay.jsp" />
  <div class="app-container">
    <header class="app-header">
      <div style="font-size: 18px; font-weight: 700;">직원관리</div>
      <div class="user-badge" id="openProfileModalBtn" style="cursor:pointer;"><span>${user.userName} 점주님</span><div class="user-avatar-sm" style="width:32px; height:32px; font-size:12px; margin-left:10px;">점</div></div>
    </header>
    <main class="app-content">
      <c:if test="${not empty error}">
        <p class="error-text"><c:out value="${error}" /></p>
      </c:if>

      <div class="modern-card">
        <div class="flex-between" style="margin-bottom: 20px;">
          <h3>디자이너 목록</h3>
          <button type="button" class="btn-modern btn-primary" id="openRegisterStylistBtn"><i class="fas fa-plus"></i> 디자이너 등록</button>
        </div>
        <div class="menu-grid">
          <c:if test="${empty stylists}">
            <p style="color: var(--text-sub); font-size: 13px;">등록된 디자이너가 없습니다.</p>
          </c:if>
          <c:forEach var="stylist" items="${stylists}">
            <div class="menu-card">
              <div style="display: flex; gap: 18px; align-items: center;">
                <c:choose>
                  <c:when test="${not empty stylist.imageUrl}">
                    <img src="${ctx}${stylist.imageUrl}" alt="${stylist.stylistName}" style="width:88px; height:88px; border-radius:50%; object-fit:cover; flex-shrink:0;">
                  </c:when>
                  <c:otherwise>
                    <div class="user-avatar-sm" style="width:88px; height:88px; font-size:28px; flex-shrink:0;">${fn:substring(stylist.stylistName,0,1)}</div>
                  </c:otherwise>
                </c:choose>
                <div>
                  <h4 style="margin-bottom: 4px; font-size:17px;"><c:out value="${stylist.stylistName}" /></h4>
                  <div style="display: flex; align-items: center; gap: 8px;">
                    <p class="tag">${empty stylist.description ? '휴무일 미등록' : stylist.description}</p>
                    <button type="button" class="edit-stylist-btn" style="border:none; background:none; padding:0; font-size:12px; color:var(--accent); font-weight:600; cursor:pointer;"
                            data-stylist-id="${stylist.stylistId}" data-stylist-name="${stylist.stylistName}"
                            data-stylist-phone="${stylist.phoneNumber}" data-stylist-description="${stylist.description}">정보 변경</button>
                  </div>
                </div>
              </div>
              <div style="margin-top: 15px; border-top: 1px solid var(--border); padding-top: 15px;">
                <c:set var="groups" value="${schedulesByStylist[stylist.stylistId]}" />
                <c:choose>
                  <c:when test="${not empty groups}">
                    <div style="display: flex; flex-direction: column; gap: 6px; margin-bottom: 10px;">
                      <c:forEach var="grp" items="${groups}">
                        <div style="display:flex; justify-content:space-between; align-items:center; font-size:13px; color: var(--text-sub);">
                          <span>스케줄: ${grp.label} ${fn:substring(grp.startTime,0,5)}~${fn:substring(grp.endTime,0,5)} <c:if test="${!grp.isAvailable}">(휴무)</c:if></span>
                          <form action="${ctx}/owner/staff/schedule/delete" method="post"
                                onsubmit="return confirm('이 스케줄을 초기화하시겠습니까?')" style="display:inline;">
                            <c:forEach var="sid" items="${grp.scheduleIds}">
                              <input type="hidden" name="scheduleIds" value="${sid}">
                            </c:forEach>
                            <button type="submit" class="btn-modern btn-outline" style="padding:2px 10px; font-size:11.5px;">초기화</button>
                          </form>
                        </div>
                      </c:forEach>
                    </div>
                  </c:when>
                  <c:otherwise>
                    <p style="font-size: 13px; color: var(--text-sub); margin-bottom: 10px;">등록된 스케줄이 없습니다.</p>
                  </c:otherwise>
                </c:choose>
                <button type="button" class="btn-modern btn-outline schedule-btn" style="width: 100%;"
                        data-stylist-id="${stylist.stylistId}" data-stylist-name="${stylist.stylistName}">스케줄 설정</button>
                <form action="${ctx}/owner/staff/${stylist.stylistId}/delete" method="post"
                      onsubmit="return confirm('이 디자이너를 삭제하시겠습니까?')" style="margin-top:8px;">
                  <button type="submit" class="btn-modern btn-danger" style="width: 100%;">삭제</button>
                </form>
              </div>
            </div>
          </c:forEach>
        </div>
      </div>
    </main>
  </div>

  <!-- 디자이너 등록 모달 -->
  <div class="modal-overlay" id="registerStylistModal">
    <div class="modal-box">
      <div class="modal-header">
        <h3 style="font-size: 18px;">디자이너 등록</h3>
        <button type="button" class="modal-close" id="closeRegisterStylistBtn"><i class="fas fa-times"></i></button>
      </div>
      <form action="${ctx}/owner/staff/register" method="post" enctype="multipart/form-data">
        <label style="display:block; font-size:13px; font-weight:700; color:var(--text-sub); margin-bottom:8px;">이름</label>
        <input type="text" name="stylistName" class="modern-input" required>
        <label style="display:block; font-size:13px; font-weight:700; color:var(--text-sub); margin:14px 0 8px;">연락처</label>
        <input type="text" name="phoneNumber" class="modern-input" placeholder="010-1234-5678">
        <label style="display:block; font-size:13px; font-weight:700; color:var(--text-sub); margin:14px 0 8px;">휴무일</label>
        <input type="text" name="description" class="modern-input" placeholder="예: 매주 월요일 휴무">
        <label style="display:block; font-size:13px; font-weight:700; color:var(--text-sub); margin:14px 0 8px;">프로필 사진</label>
        <input type="file" name="imageFile" accept="image/jpeg,image/png,image/gif,image/webp" class="modern-input">
        <button type="submit" class="btn-modern btn-primary" style="width:100%; margin-top:16px;">등록하기</button>
      </form>
    </div>
  </div>

  <!-- 디자이너 정보 변경 모달 (디자이너 공용, JS가 대상을 채움) -->
  <div class="modal-overlay" id="editStylistModal">
    <div class="modal-box">
      <div class="modal-header">
        <h3 style="font-size: 18px;">정보 변경 — <span id="editModalStylistName"></span></h3>
        <button type="button" class="modal-close" id="closeEditStylistBtn"><i class="fas fa-times"></i></button>
      </div>
      <form id="editStylistForm" method="post" enctype="multipart/form-data">
        <label style="display:block; font-size:13px; font-weight:700; color:var(--text-sub); margin-bottom:8px;">이름</label>
        <input type="text" name="stylistName" id="editStylistName" class="modern-input" required>
        <label style="display:block; font-size:13px; font-weight:700; color:var(--text-sub); margin:14px 0 8px;">연락처</label>
        <input type="text" name="phoneNumber" id="editStylistPhone" class="modern-input" placeholder="010-1234-5678">
        <label style="display:block; font-size:13px; font-weight:700; color:var(--text-sub); margin:14px 0 8px;">휴무일</label>
        <input type="text" name="description" id="editStylistDescription" class="modern-input" placeholder="예: 매주 월요일 휴무">
        <label style="display:block; font-size:13px; font-weight:700; color:var(--text-sub); margin:14px 0 8px;">프로필 사진 (변경 시에만 선택)</label>
        <input type="file" name="imageFile" accept="image/jpeg,image/png,image/gif,image/webp" class="modern-input">
        <button type="submit" class="btn-modern btn-primary" style="width:100%; margin-top:16px;">저장하기</button>
      </form>
    </div>
  </div>

  <!-- 스케줄 설정 모달 (디자이너 공용, JS가 대상을 채움) -->
  <div class="modal-overlay" id="scheduleModal">
    <div class="modal-box" style="max-width: 480px;">
      <div class="modal-header">
        <h3 style="font-size: 18px;">스케줄 설정 — <span id="scheduleModalStylistName"></span></h3>
        <button type="button" class="modal-close" id="closeScheduleModalBtn"><i class="fas fa-times"></i></button>
      </div>

      <div class="mini-calendar">
        <div class="mini-cal-mode-toggle">
          <button type="button" id="calModeRangeBtn" class="mini-cal-mode-btn is-active">범위 선택</button>
          <button type="button" id="calModeSingleBtn" class="mini-cal-mode-btn">개별 선택</button>
        </div>
        <div class="mini-cal-nav">
          <button type="button" id="calPrevBtn" class="btn-modern btn-outline" style="padding:4px 10px;">‹</button>
          <span id="calMonthLabel" style="font-weight:700; font-size:14px;"></span>
          <button type="button" id="calNextBtn" class="btn-modern btn-outline" style="padding:4px 10px;">›</button>
        </div>
        <div class="mini-cal-weekdays"><span>일</span><span>월</span><span>화</span><span>수</span><span>목</span><span>금</span><span>토</span></div>
        <div class="mini-cal-grid" id="calGrid"></div>
        <p style="font-size:11.5px; color:var(--text-sub); margin-top:8px;" id="calHint">시작일을 클릭한 뒤 종료일을 클릭하세요.</p>
      </div>

      <div id="scheduleBulkApply" style="display:none; margin-top:16px; padding:12px; background:var(--bg-sub); border-radius:var(--radius-md);">
        <p style="font-size:12.5px; font-weight:700; color:var(--text-sub); margin-bottom:8px;">선택한 날짜 전체에 적용</p>
        <div style="display:flex; gap:8px; align-items:center; flex-wrap:wrap;">
          <input type="time" id="bulkStartTime" class="modern-input" style="width:auto;" value="10:00">
          <span>~</span>
          <input type="time" id="bulkEndTime" class="modern-input" style="width:auto;" value="19:00">
          <label style="display:flex; align-items:center; gap:4px; font-size:13px;"><input type="checkbox" id="bulkAvailable" checked> 예약 가능</label>
          <button type="button" id="applyBulkBtn" class="btn-modern btn-outline" style="padding:6px 12px; font-size:12.5px;">전체 적용</button>
        </div>
      </div>

      <div id="scheduleDateList" style="margin-top:14px; margin-left:-35px; margin-right:-35px; padding:0 12px; display:flex; flex-direction:column; gap:8px; max-height:240px; overflow-y:auto;"></div>

      <form id="scheduleForm" method="post" style="margin-top:16px;">
        <input type="hidden" name="scheduleData" id="scheduleDataInput">
        <button type="submit" class="btn-modern btn-primary" style="width:100%;">저장</button>
      </form>
    </div>
  </div>

  <jsp:include page="../includes/profile_modal.jsp">
      <jsp:param name="roleLabel" value="점주" />
  </jsp:include>

  <script>
    var ctx = '${ctx}';

    var registerModal = document.getElementById('registerStylistModal');
    document.getElementById('openRegisterStylistBtn').addEventListener('click', function () {
      registerModal.classList.add('active');
    });
    document.getElementById('closeRegisterStylistBtn').addEventListener('click', function () {
      registerModal.classList.remove('active');
    });

    var scheduleModal = document.getElementById('scheduleModal');
    var scheduleForm = document.getElementById('scheduleForm');

    // ---- 스케줄 캘린더 ----
    var calendarState = { year: 0, month: 0 };
    var calendarMode = 'range'; // 'range' | 'single'
    var rangeStart = null; // range 모드에서 시작일 클릭 후 종료일 클릭 대기 중일 때만 값이 있음
    var scheduleEntries = {}; // { 'YYYY-MM-DD': { startTime, endTime, isAvailable } }

    function formatDate(d) {
      var mm = String(d.getMonth() + 1).padStart(2, '0');
      var dd = String(d.getDate()).padStart(2, '0');
      return d.getFullYear() + '-' + mm + '-' + dd;
    }

    function isNextDay(d1, d2) {
      var a = new Date(d1 + 'T00:00:00');
      a.setDate(a.getDate() + 1);
      return formatDate(a) === d2;
    }

    function renderCalendar() {
      var y = calendarState.year, m = calendarState.month;
      document.getElementById('calMonthLabel').textContent = y + '년 ' + (m + 1) + '월';
      var grid = document.getElementById('calGrid');
      grid.innerHTML = '';
      var firstDay = new Date(y, m, 1).getDay();
      var daysInMonth = new Date(y, m + 1, 0).getDate();
      var todayStr = formatDate(new Date());
      for (var i = 0; i < firstDay; i++) {
        grid.appendChild(document.createElement('div'));
      }
      for (var d = 1; d <= daysInMonth; d++) {
        var dateStr = formatDate(new Date(y, m, d));
        var cell = document.createElement('button');
        cell.type = 'button';
        cell.textContent = d;
        cell.className = 'mini-cal-day';
        if (dateStr < todayStr) {
          cell.disabled = true;
          cell.classList.add('is-past');
        } else {
          if (dateStr === todayStr) cell.classList.add('is-today');
          if (scheduleEntries[dateStr]) cell.classList.add('is-selected');
          if (calendarMode === 'range' && rangeStart === dateStr) cell.classList.add('is-selected');
          cell.addEventListener('click', (function (ds) { return function () { onDayClick(ds); }; })(dateStr));
        }
        grid.appendChild(cell);
      }
    }

    function onDayClick(dateStr) {
      var bulkStart = document.getElementById('bulkStartTime').value || '10:00';
      var bulkEnd = document.getElementById('bulkEndTime').value || '19:00';
      var bulkAvail = document.getElementById('bulkAvailable').checked;
      var hint = document.getElementById('calHint');

      if (calendarMode === 'single') {
        // 개별 선택 모드: 클릭할 때마다 그 날짜 하나만 토글 (비연속 다중 선택용)
        if (scheduleEntries[dateStr]) {
          delete scheduleEntries[dateStr];
        } else {
          scheduleEntries[dateStr] = { startTime: bulkStart, endTime: bulkEnd, isAvailable: bulkAvail };
        }
        hint.textContent = '개별 선택 모드 — 클릭할 때마다 그 날짜 하나만 켜지거나 꺼집니다.';
      } else {
        // 범위 선택 모드: 시작일 클릭 → 종료일 클릭 (특수 키 불필요, 터치에서도 동일하게 동작)
        // 확정된 범위는 지우지 않고 계속 더해간다 — 3~17일 근무, 휴가로 공백, 20~25일 근무처럼
        // 한 달 안에 떨어진 구간이 여러 개 있는 경우를 그대로 지원하기 위함.
        if (rangeStart === null) {
          if (scheduleEntries[dateStr]) {
            // 이미 선택된 날짜를 다시 클릭 — 새 범위 시작이 아니라 그 날짜 하나만 바로 취소
            delete scheduleEntries[dateStr];
            hint.innerHTML = '<b>' + dateStr + '</b> 선택을 취소했습니다.';
          } else {
            rangeStart = dateStr;
            scheduleEntries[dateStr] = { startTime: bulkStart, endTime: bulkEnd, isAvailable: bulkAvail };
            hint.innerHTML = '시작일 <b>' + dateStr + '</b> 선택됨 — 이제 종료일을 클릭하세요.';
          }
        } else {
          var start = rangeStart < dateStr ? rangeStart : dateStr;
          var end = rangeStart < dateStr ? dateStr : rangeStart;
          var cur = new Date(start + 'T00:00:00');
          var endD = new Date(end + 'T00:00:00');
          while (cur <= endD) {
            scheduleEntries[formatDate(cur)] = { startTime: bulkStart, endTime: bulkEnd, isAvailable: bulkAvail };
            cur.setDate(cur.getDate() + 1);
          }
          rangeStart = null;
          hint.textContent = '범위 추가됨 — 다른 구간을 이어서 고르거나 저장하세요. (휴가 등으로 비는 구간은 그대로 두고 다음 구간을 선택하면 됩니다)';
        }
      }
      renderCalendar();
      renderDateList();
    }

    function setCalendarMode(mode) {
      calendarMode = mode;
      rangeStart = null;
      scheduleEntries = {};
      document.getElementById('calModeRangeBtn').classList.toggle('is-active', mode === 'range');
      document.getElementById('calModeSingleBtn').classList.toggle('is-active', mode === 'single');
      document.getElementById('calHint').textContent = mode === 'range'
        ? '시작일을 클릭한 뒤 종료일을 클릭하세요.'
        : '개별 선택 모드 — 클릭할 때마다 그 날짜 하나만 켜지거나 꺼집니다. 연속 아닌 날짜를 자유롭게 고를 때 씁니다.';
      renderCalendar();
      renderDateList();
    }
    document.getElementById('calModeRangeBtn').addEventListener('click', function () { setCalendarMode('range'); });
    document.getElementById('calModeSingleBtn').addEventListener('click', function () { setCalendarMode('single'); });

    // 연속된 날짜가 같은 시간·가능여부면 한 줄로 묶어서 보여준다
    function groupConsecutiveDates(dates) {
      var groups = [];
      var i = 0;
      while (i < dates.length) {
        var entry = scheduleEntries[dates[i]];
        var j = i;
        while (j + 1 < dates.length) {
          var next = scheduleEntries[dates[j + 1]];
          var sameTime = next.startTime === entry.startTime && next.endTime === entry.endTime && next.isAvailable === entry.isAvailable;
          if (isNextDay(dates[j], dates[j + 1]) && sameTime) { j++; } else { break; }
        }
        groups.push(dates.slice(i, j + 1));
        i = j + 1;
      }
      return groups;
    }

    function renderDateList() {
      var container = document.getElementById('scheduleDateList');
      var bulkApply = document.getElementById('scheduleBulkApply');
      var dates = Object.keys(scheduleEntries).sort();
      bulkApply.style.display = dates.length > 0 ? 'block' : 'none';
      container.innerHTML = '';
      var weekdayNames = ['일', '월', '화', '수', '목', '금', '토'];
      // 단일 날짜: 2026-07-28(화) / 범위: 2026-07-28~08-01 (같은 달이면 2026-07-28~30, 해가 다르면 끝쪽에 연도까지)
      function formatRangeLabel(startStr, endStr) {
        if (startStr === endStr) {
          var s = new Date(startStr + 'T00:00:00');
          return startStr + '(' + weekdayNames[s.getDay()] + ')';
        }
        var startParts = startStr.split('-'); // [YYYY, MM, DD]
        var endParts = endStr.split('-');
        var endLabel;
        if (startParts[0] !== endParts[0]) {
          endLabel = endStr;
        } else if (startParts[1] !== endParts[1]) {
          endLabel = endParts[1] + '-' + endParts[2];
        } else {
          endLabel = endParts[2];
        }
        return startStr + '~' + endLabel;
      }

      groupConsecutiveDates(dates).forEach(function (group) {
        var entry = scheduleEntries[group[0]];
        var row = document.createElement('div');
        row.className = 'schedule-date-row';
        var labelText = formatRangeLabel(group[0], group[group.length - 1]);
        row.innerHTML =
          '<span class="schedule-date-label" style="width:auto; margin-right:4px;">' + labelText + '</span>' +
          '<input type="time" class="modern-input row-start" value="' + entry.startTime + '">' +
          '<span>~</span>' +
          '<input type="time" class="modern-input row-end" value="' + entry.endTime + '">' +
          '<label><input type="checkbox" class="row-available"' + (entry.isAvailable ? ' checked' : '') + '> 가능</label>' +
          '<button type="button" class="btn-modern btn-outline remove-date-row" style="padding:2px 10px;">×</button>';
        row.querySelector('.row-start').addEventListener('change', function () {
          group.forEach(function (ds) { scheduleEntries[ds].startTime = this.value; }, this);
        });
        row.querySelector('.row-end').addEventListener('change', function () {
          group.forEach(function (ds) { scheduleEntries[ds].endTime = this.value; }, this);
        });
        row.querySelector('.row-available').addEventListener('change', function () {
          group.forEach(function (ds) { scheduleEntries[ds].isAvailable = this.checked; }, this);
        });
        row.querySelector('.remove-date-row').addEventListener('click', function () {
          group.forEach(function (ds) { delete scheduleEntries[ds]; });
          renderCalendar();
          renderDateList();
        });
        container.appendChild(row);
      });
    }

    document.getElementById('applyBulkBtn').addEventListener('click', function () {
      var st = document.getElementById('bulkStartTime').value;
      var et = document.getElementById('bulkEndTime').value;
      var av = document.getElementById('bulkAvailable').checked;
      Object.keys(scheduleEntries).forEach(function (dateStr) {
        scheduleEntries[dateStr].startTime = st;
        scheduleEntries[dateStr].endTime = et;
        scheduleEntries[dateStr].isAvailable = av;
      });
      renderDateList();
    });

    document.getElementById('calPrevBtn').addEventListener('click', function () {
      calendarState.month--;
      if (calendarState.month < 0) { calendarState.month = 11; calendarState.year--; }
      renderCalendar();
    });
    document.getElementById('calNextBtn').addEventListener('click', function () {
      calendarState.month++;
      if (calendarState.month > 11) { calendarState.month = 0; calendarState.year = calendarState.year + 1; }
      renderCalendar();
    });

    scheduleForm.addEventListener('submit', function (e) {
      var dates = Object.keys(scheduleEntries);
      if (dates.length === 0) {
        e.preventDefault();
        alert('날짜를 하나 이상 선택해주세요.');
        return;
      }
      var payload = dates.sort().map(function (d) {
        var entry = scheduleEntries[d];
        return { date: d, startTime: entry.startTime, endTime: entry.endTime, isAvailable: entry.isAvailable };
      });
      document.getElementById('scheduleDataInput').value = JSON.stringify(payload);
    });

    document.querySelectorAll('.schedule-btn').forEach(function (btn) {
      btn.addEventListener('click', function () {
        var stylistId = btn.dataset.stylistId;
        document.getElementById('scheduleModalStylistName').textContent = btn.dataset.stylistName;
        scheduleForm.action = ctx + '/owner/staff/' + stylistId + '/schedule';
        // 모달은 디자이너 공용이라 이전 선택 상태를 초기화한다 (기본 모드: 범위 선택)
        var today = new Date();
        calendarState.year = today.getFullYear();
        calendarState.month = today.getMonth();
        setCalendarMode('range');
        scheduleModal.classList.add('active');
      });
    });
    document.getElementById('closeScheduleModalBtn').addEventListener('click', function () {
      scheduleModal.classList.remove('active');
    });

    var editModal = document.getElementById('editStylistModal');
    var editForm = document.getElementById('editStylistForm');
    document.querySelectorAll('.edit-stylist-btn').forEach(function (btn) {
      btn.addEventListener('click', function () {
        var stylistId = btn.dataset.stylistId;
        document.getElementById('editModalStylistName').textContent = btn.dataset.stylistName;
        document.getElementById('editStylistName').value = btn.dataset.stylistName;
        document.getElementById('editStylistPhone').value = btn.dataset.stylistPhone;
        document.getElementById('editStylistDescription').value = btn.dataset.stylistDescription;
        editForm.action = ctx + '/owner/staff/' + stylistId + '/update';
        editModal.classList.add('active');
      });
    });
    document.getElementById('closeEditStylistBtn').addEventListener('click', function () {
      editModal.classList.remove('active');
    });

    [registerModal, scheduleModal, editModal].forEach(function (modal) {
      modal.addEventListener('click', function (e) { if (e.target === modal) modal.classList.remove('active'); });
    });
  </script>
</body>
</html>
