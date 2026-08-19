<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | 매장정보 관리</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="/resources/css/common.css">
  <link rel="stylesheet" href="/resources/css/owner.css">
</head>
<body class="store-page">
  <jsp:include page="../includes/sidebar_owner.jsp">
      <jsp:param name="menu" value="store" />
  </jsp:include>
  <jsp:include page="../includes/salon_gate_overlay.jsp" />
  <div class="app-container">
    <header class="app-header">
      <div style="font-size: 18px; font-weight: 700; display:flex; align-items:center; gap:10px;">
        매장정보 관리
        <c:if test="${salon.activationStatus == 'preparing'}">
          <button type="button" id="openPrepChecklistBtn" style="flex-shrink:0; background:#6b6b6b; color:#fff; font-size:11px; font-weight:800; padding:5px 12px; border-radius:var(--radius-full); border:none; cursor:pointer; display:inline-flex; align-items:center; gap:6px;">
            준비중 <i class="fas fa-circle-question" style="font-size:10px; opacity:.8;"></i>
          </button>
        </c:if>
      </div>
    </header>
    <main class="app-content">
      <c:if test="${not empty error}">
        <p class="error-text"><c:out value="${error}" /></p>
      </c:if>
      <c:if test="${not empty success}">
        <p class="success-text"><c:out value="${success}" /></p>
      </c:if>

      <div class="store-tab-row">
        <button type="button" class="store-tab-btn active" data-tab="basic">기본정보</button>
        <button type="button" class="store-tab-btn" data-tab="hours">영업시간</button>
        <button type="button" class="store-tab-btn" data-tab="menu">시술메뉴</button>
        <button type="button" class="store-tab-btn" data-tab="notice">이벤트·공지사항</button>
      </div>

      <div class="store-tab-panel active" data-panel="basic">
        <div class="modern-card">
          <h3 style="margin-bottom: 20px;">매장 기본 정보</h3>
          <form method="post" action="<c:url value='/owner/store/update'/>" style="display:flex; flex-direction:column; gap:16px;">
            <div>
              <label style="font-size: 13px; font-weight: 700;">매장명</label>
              <input type="text" name="salonName" class="modern-input" value="${salon.salonName}" required>
            </div>
            <div>
              <label style="font-size: 13px; font-weight: 700; color: var(--text-sub);">매장 소개</label>
              <textarea name="description" class="modern-input" style="height: 100px; resize: none;">${salon.description}</textarea>
            </div>
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
              <div><label style="font-size: 13px; font-weight: 700;">주소</label><input type="text" name="address" class="modern-input" value="${salon.address}" placeholder="주소를 입력해주세요"></div>
              <div><label style="font-size: 13px; font-weight: 700;">연락처</label><input type="text" name="phoneNumber" class="modern-input" value="${salon.phoneNumber}" placeholder="02-1234-5678" pattern="[0-9-]{9,13}" title="숫자와 하이픈(-)만 입력해주세요." required></div>
            </div>
            <button type="submit" class="btn-modern btn-primary">정보 저장</button>
          </form>
        </div>
      </div>

      <div class="store-tab-panel" data-panel="hours">
        <div class="modern-card">
          <h3 style="margin-bottom: 20px;">영업시간</h3>
          <form method="post" action="<c:url value='/owner/store/hours'/>">
            <table style="width:100%; border-collapse:collapse; font-size:13.5px;">
              <c:set var="mon" value="${operatingHours['월']}" /><c:set var="tue" value="${operatingHours['화']}" />
              <c:set var="wed" value="${operatingHours['수']}" /><c:set var="thu" value="${operatingHours['목']}" />
              <c:set var="fri" value="${operatingHours['금']}" /><c:set var="sat" value="${operatingHours['토']}" />
              <c:set var="sun" value="${operatingHours['일']}" />
              <tr style="border-bottom:1px solid var(--border);">
                <td style="padding:10px 8px; width:90px;"><label style="display:flex; align-items:center; gap:8px; font-weight:700;"><input type="checkbox" name="open_MON" ${not empty mon ? 'checked' : ''}> 월요일</label></td>
                <td style="padding:10px 8px;"><input type="time" name="openTime_MON" class="modern-input hours-time-input" value="${not empty mon ? mon.openTime : '10:00'}"><span style="color:var(--text-sub); margin:0 6px;">~</span><input type="time" name="closeTime_MON" class="modern-input hours-time-input" value="${not empty mon ? mon.closeTime : '20:00'}"></td>
              </tr>
              <tr style="border-bottom:1px solid var(--border);">
                <td style="padding:10px 8px;"><label style="display:flex; align-items:center; gap:8px; font-weight:700;"><input type="checkbox" name="open_TUE" ${not empty tue ? 'checked' : ''}> 화요일</label></td>
                <td style="padding:10px 8px;"><input type="time" name="openTime_TUE" class="modern-input hours-time-input" value="${not empty tue ? tue.openTime : '10:00'}"><span style="color:var(--text-sub); margin:0 6px;">~</span><input type="time" name="closeTime_TUE" class="modern-input hours-time-input" value="${not empty tue ? tue.closeTime : '20:00'}"></td>
              </tr>
              <tr style="border-bottom:1px solid var(--border);">
                <td style="padding:10px 8px;"><label style="display:flex; align-items:center; gap:8px; font-weight:700;"><input type="checkbox" name="open_WED" ${not empty wed ? 'checked' : ''}> 수요일</label></td>
                <td style="padding:10px 8px;"><input type="time" name="openTime_WED" class="modern-input hours-time-input" value="${not empty wed ? wed.openTime : '10:00'}"><span style="color:var(--text-sub); margin:0 6px;">~</span><input type="time" name="closeTime_WED" class="modern-input hours-time-input" value="${not empty wed ? wed.closeTime : '20:00'}"></td>
              </tr>
              <tr style="border-bottom:1px solid var(--border);">
                <td style="padding:10px 8px;"><label style="display:flex; align-items:center; gap:8px; font-weight:700;"><input type="checkbox" name="open_THU" ${not empty thu ? 'checked' : ''}> 목요일</label></td>
                <td style="padding:10px 8px;"><input type="time" name="openTime_THU" class="modern-input hours-time-input" value="${not empty thu ? thu.openTime : '10:00'}"><span style="color:var(--text-sub); margin:0 6px;">~</span><input type="time" name="closeTime_THU" class="modern-input hours-time-input" value="${not empty thu ? thu.closeTime : '20:00'}"></td>
              </tr>
              <tr style="border-bottom:1px solid var(--border);">
                <td style="padding:10px 8px;"><label style="display:flex; align-items:center; gap:8px; font-weight:700;"><input type="checkbox" name="open_FRI" ${not empty fri ? 'checked' : ''}> 금요일</label></td>
                <td style="padding:10px 8px;"><input type="time" name="openTime_FRI" class="modern-input hours-time-input" value="${not empty fri ? fri.openTime : '10:00'}"><span style="color:var(--text-sub); margin:0 6px;">~</span><input type="time" name="closeTime_FRI" class="modern-input hours-time-input" value="${not empty fri ? fri.closeTime : '20:00'}"></td>
              </tr>
              <tr style="border-bottom:1px solid var(--border);">
                <td style="padding:10px 8px;"><label style="display:flex; align-items:center; gap:8px; font-weight:700;"><input type="checkbox" name="open_SAT" ${not empty sat ? 'checked' : ''}> 토요일</label></td>
                <td style="padding:10px 8px;"><input type="time" name="openTime_SAT" class="modern-input hours-time-input" value="${not empty sat ? sat.openTime : '10:00'}"><span style="color:var(--text-sub); margin:0 6px;">~</span><input type="time" name="closeTime_SAT" class="modern-input hours-time-input" value="${not empty sat ? sat.closeTime : '20:00'}"></td>
              </tr>
              <tr>
                <td style="padding:10px 8px;"><label style="display:flex; align-items:center; gap:8px; font-weight:700;"><input type="checkbox" name="open_SUN" ${not empty sun ? 'checked' : ''}> 일요일</label></td>
                <td style="padding:10px 8px;"><input type="time" name="openTime_SUN" class="modern-input hours-time-input" value="${not empty sun ? sun.openTime : '10:00'}"><span style="color:var(--text-sub); margin:0 6px;">~</span><input type="time" name="closeTime_SUN" class="modern-input hours-time-input" value="${not empty sun ? sun.closeTime : '20:00'}"></td>
              </tr>
            </table>
            <p style="font-size:12px; color:var(--text-sub); margin-top:10px;">체크 해제한 요일은 휴무로 저장됩니다.</p>
            <button type="submit" class="btn-modern btn-primary" style="margin-top:10px;">영업시간 저장</button>
          </form>
        </div>
      </div>

      <div class="store-tab-panel" data-panel="menu">
        <div class="modern-card">
          <div style="display: flex; justify-content: space-between; margin-bottom: 20px;">
            <h3>시술 메뉴 관리</h3>
            <button type="button" class="btn-modern btn-outline" id="openRegisterServiceBtn"><i class="fas fa-plus"></i> 메뉴 추가</button>
          </div>
          <c:choose>
            <c:when test="${empty services}">
              <p style="font-size:13px; color:var(--text-sub);">등록된 메뉴가 없습니다. "메뉴 추가"로 첫 시술 메뉴를 등록해보세요.</p>
            </c:when>
            <c:otherwise>
              <div class="menu-grid">
                <c:forEach var="svc" items="${services}">
                  <div class="menu-card">
                    <h4 style="margin-bottom: 8px;"><c:out value="${svc.serviceName}" /></h4>
                    <p style="color: var(--accent); font-weight: 700; margin-bottom: 4px;"><fmt:formatNumber value="${svc.price}" pattern="#,##0" />원</p>
                    <p class="tag" style="margin-bottom: 12px;">
                      <c:choose>
                        <c:when test="${svc.durationMinutes > 0}">${svc.durationMinutes}분 소요</c:when>
                        <c:otherwise>소요시간 미등록</c:otherwise>
                      </c:choose>
                    </p>
                    <div style="display: flex; gap: 5px;">
                      <button type="button" class="btn-modern btn-outline edit-service-btn" style="flex: 1;"
                              data-service-id="${svc.serviceId}" data-service-name="${svc.serviceName}"
                              data-service-price="${svc.price}" data-service-duration="${svc.durationMinutes}"
                              data-service-description="${svc.description}">수정</button>
                      <form action="${ctx}/owner/store/service/${svc.serviceId}/delete" method="post"
                            onsubmit="return confirm('이 메뉴를 삭제하시겠습니까?')" style="display:inline;">
                        <button type="submit" class="btn-modern btn-danger"><i class="fas fa-trash"></i></button>
                      </form>
                    </div>
                  </div>
                </c:forEach>
              </div>
            </c:otherwise>
          </c:choose>
        </div>
      </div>

      <div class="store-tab-panel" data-panel="notice">
        <div class="modern-card">
          <div class="flex-between" style="margin-bottom: 20px;">
            <h3>이벤트 및 공지사항 관리</h3>
            <button type="button" id="noticeWriteBtn" class="btn-modern btn-primary"><i class="fas fa-plus"></i> 글쓰기</button>
          </div>
          <form id="noticeWriteForm" method="post" action="<c:url value='/owner/events'/>" enctype="multipart/form-data" style="display:none; flex-direction:column; gap:16px; margin-bottom: 20px;">
            <div>
              <label style="font-size: 13px; font-weight: 700; color: var(--text-sub);">제목</label>
              <input type="text" name="title" class="modern-input" maxlength="255" required>
            </div>
            <div>
              <label style="font-size: 13px; font-weight: 700; color: var(--text-sub);">내용</label>
              <textarea name="content" class="modern-input" style="height: 100px; resize: none;" required></textarea>
            </div>
            <div>
              <label style="font-size: 13px; font-weight: 700; color: var(--text-sub);">사진 (선택)</label>
              <input type="file" name="imageFile" accept="image/jpeg,image/png,image/gif,image/webp" class="modern-input">
            </div>
            <button type="submit" class="btn-modern btn-primary" style="align-self: flex-start;">등록</button>
          </form>
          <table class="modern-table">
            <thead>
              <tr><th>구분</th><th>제목</th><th>등록일</th><th>상태</th><th>관리</th></tr>
            </thead>
            <tbody>
              <c:forEach var="notice" items="${notices}">
                <tr>
                  <td><span class="status-badge status-confirmed">공지사항</span></td>
                  <td style="font-weight: 600;">
                    <div style="display:flex; align-items:center; gap:10px;">
                      <c:if test="${not empty notice.imageUrl}">
                        <img src="<c:url value='${notice.imageUrl}'/>" alt="" class="notice-thumb lightbox-img">
                      </c:if>
                      <span><c:out value="${notice.title}"/></span>
                    </div>
                  </td>
                  <td>${notice.createdAt}</td>
                  <td><span class="status-badge status-confirmed">게시중</span></td>
                  <td>
                    <form method="post" action="<c:url value='/owner/events/${notice.noticeId}/delete'/>"
                          onsubmit="return confirm('이 공지사항을 삭제하시겠습니까?')" style="display:inline;">
                      <button type="submit" class="btn-modern btn-danger">삭제</button>
                    </form>
                  </td>
                </tr>
              </c:forEach>
              <c:if test="${empty notices}">
                <tr><td colspan="5" style="text-align:center; color: var(--text-sub);">등록된 공지사항이 없습니다.</td></tr>
              </c:if>
            </tbody>
          </table>
        </div>
      </div>
    </main>
  </div>

  <div class="modal-overlay" id="registerServiceModal">
    <div class="modal-box">
      <div class="modal-header">
        <h3 style="font-size: 18px;">메뉴 추가</h3>
        <button type="button" class="modal-close" id="closeRegisterServiceBtn"><i class="fas fa-times"></i></button>
      </div>
      <form action="${ctx}/owner/store/service/register" method="post">
        <label style="display:block; font-size:13px; font-weight:700; color:var(--text-sub); margin-bottom:8px;">메뉴명</label>
        <input type="text" name="serviceName" class="modern-input" required>
        <label style="display:block; font-size:13px; font-weight:700; color:var(--text-sub); margin:14px 0 8px;">가격(원)</label>
        <input type="number" name="price" class="modern-input" min="0" step="100" required>
        <label style="display:block; font-size:13px; font-weight:700; color:var(--text-sub); margin:14px 0 8px;">소요시간(분)</label>
        <input type="number" name="durationMinutes" class="modern-input" min="0" step="5" placeholder="예: 60">
        <label style="display:block; font-size:13px; font-weight:700; color:var(--text-sub); margin:14px 0 8px;">설명</label>
        <textarea name="description" class="modern-input" style="height:80px; resize:none;"></textarea>
        <button type="submit" class="btn-modern btn-primary" style="width:100%; margin-top:16px;">등록하기</button>
      </form>
    </div>
  </div>

  <div class="modal-overlay" id="editServiceModal">
    <div class="modal-box">
      <div class="modal-header">
        <h3 style="font-size: 18px;">메뉴 수정 — <span id="editModalServiceName"></span></h3>
        <button type="button" class="modal-close" id="closeEditServiceBtn"><i class="fas fa-times"></i></button>
      </div>
      <form id="editServiceForm" method="post">
        <label style="display:block; font-size:13px; font-weight:700; color:var(--text-sub); margin-bottom:8px;">메뉴명</label>
        <input type="text" name="serviceName" id="editServiceName" class="modern-input" required>
        <label style="display:block; font-size:13px; font-weight:700; color:var(--text-sub); margin:14px 0 8px;">가격(원)</label>
        <input type="number" name="price" id="editServicePrice" class="modern-input" min="0" step="100" required>
        <label style="display:block; font-size:13px; font-weight:700; color:var(--text-sub); margin:14px 0 8px;">소요시간(분)</label>
        <input type="number" name="durationMinutes" id="editServiceDuration" class="modern-input" min="0" step="5">
        <label style="display:block; font-size:13px; font-weight:700; color:var(--text-sub); margin:14px 0 8px;">설명</label>
        <textarea name="description" id="editServiceDescription" class="modern-input" style="height:80px; resize:none;"></textarea>
        <button type="submit" class="btn-modern btn-primary" style="width:100%; margin-top:16px;">저장하기</button>
      </form>
    </div>
  </div>

  <jsp:include page="../includes/profile_modal.jsp">
      <jsp:param name="roleLabel" value="점주" />
  </jsp:include>

  <c:if test="${salon.activationStatus == 'preparing'}">
    <!-- 준비중 진행상황 자가 확인 모달 — 관리자 심사대기 체크리스트와 같은 3항목 -->
    <div class="modal-overlay" id="prepChecklistModal">
      <div class="modal-box" style="max-width:420px;">
        <div class="modal-header">
          <div>
            <h3 style="font-size: 17px; margin-bottom:5px;">활성화까지 남은 항목</h3>
            <p style="font-size:12.3px; color:var(--text-sub); margin:0;">셋 다 채우면 관리자 승인 후 손님에게 노출됩니다.</p>
          </div>
          <button type="button" class="modal-close" id="closePrepChecklistBtn"><i class="fas fa-times"></i></button>
        </div>
        <div style="display:flex; flex-direction:column; gap:14px;">
          <label style="display:flex; align-items:center; gap:10px; font-size:14px;">
            <input type="checkbox" disabled ${not empty salon.address ? 'checked' : ''} style="width:18px; height:18px;"> 주소 입력 — "기본정보" 탭
          </label>
          <label style="display:flex; align-items:center; gap:10px; font-size:14px;">
            <input type="checkbox" disabled ${not empty operatingHours ? 'checked' : ''} style="width:18px; height:18px;"> 영업시간 등록 — "영업시간" 탭
          </label>
          <label style="display:flex; align-items:center; gap:10px; font-size:14px;">
            <input type="checkbox" disabled ${not empty services ? 'checked' : ''} style="width:18px; height:18px;"> 시술 메뉴 1개 이상 — "시술메뉴" 탭
          </label>
        </div>
      </div>
    </div>
    <script>
      (function () {
        var modal = document.getElementById('prepChecklistModal');
        document.getElementById('openPrepChecklistBtn').addEventListener('click', function () {
          modal.classList.add('active');
        });
        document.getElementById('closePrepChecklistBtn').addEventListener('click', function () {
          modal.classList.remove('active');
        });
        modal.addEventListener('click', function (e) { if (e.target === modal) modal.classList.remove('active'); });
      })();
    </script>
  </c:if>

  <script>
    var ctx = '${ctx}';
    var registerServiceModal = document.getElementById('registerServiceModal');
    document.getElementById('openRegisterServiceBtn').addEventListener('click', function () {
      registerServiceModal.classList.add('active');
    });
    document.getElementById('closeRegisterServiceBtn').addEventListener('click', function () {
      registerServiceModal.classList.remove('active');
    });

    var editServiceModal = document.getElementById('editServiceModal');
    var editServiceForm = document.getElementById('editServiceForm');
    document.querySelectorAll('.edit-service-btn').forEach(function (btn) {
      btn.addEventListener('click', function () {
        document.getElementById('editModalServiceName').textContent = btn.dataset.serviceName;
        document.getElementById('editServiceName').value = btn.dataset.serviceName;
        document.getElementById('editServicePrice').value = btn.dataset.servicePrice;
        document.getElementById('editServiceDuration').value = btn.dataset.serviceDuration;
        document.getElementById('editServiceDescription').value = btn.dataset.serviceDescription;
        editServiceForm.action = ctx + '/owner/store/service/' + btn.dataset.serviceId + '/update';
        editServiceModal.classList.add('active');
      });
    });
    document.getElementById('closeEditServiceBtn').addEventListener('click', function () {
      editServiceModal.classList.remove('active');
    });
    [registerServiceModal, editServiceModal].forEach(function (modal) {
      modal.addEventListener('click', function (e) { if (e.target === modal) modal.classList.remove('active'); });
    });

    // 탭 전환 — 공지사항 글쓰기/삭제는 리다이렉트로 이 페이지에 돌아오므로, #notice 해시가 있으면 그 탭으로 연다
    (function () {
      var tabBtns = document.querySelectorAll('.store-tab-btn');
      var panels = document.querySelectorAll('.store-tab-panel');
      function showTab(key) {
        tabBtns.forEach(function (b) { b.classList.toggle('active', b.dataset.tab === key); });
        panels.forEach(function (p) { p.classList.toggle('active', p.dataset.panel === key); });
      }
      tabBtns.forEach(function (btn) {
        btn.addEventListener('click', function () { showTab(btn.dataset.tab); });
      });
      // 저장 후 리다이렉트로 돌아왔을 때 방금 쓰던 탭 그대로 — 매번 "기본정보"로 튕기면 저장했는지 헷갈린다
      var hashTab = location.hash.replace('#', '');
      if (hashTab && document.querySelector('.store-tab-panel[data-panel="' + hashTab + '"]')) {
        showTab(hashTab);
      }
    })();

    var noticeWriteBtn = document.getElementById('noticeWriteBtn');
    var noticeWriteForm = document.getElementById('noticeWriteForm');
    if (noticeWriteBtn && noticeWriteForm) {
      noticeWriteBtn.addEventListener('click', function () {
        noticeWriteForm.style.display = noticeWriteForm.style.display === 'none' ? 'flex' : 'none';
      });
    }
  </script>
  <script src="<c:url value='/resources/js/lightbox.js'/>"></script>
</body>
</html>
