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
      <div style="font-size: 18px; font-weight: 700;">매장정보 관리</div>
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
            <div><label style="font-size: 13px; font-weight: 700;">연락처</label><input type="text" name="phoneNumber" class="modern-input" value="${salon.phoneNumber}" placeholder="02-1234-5678"></div>
          </div>

          <%-- 주소 검색이 채우는 좌표. 저장된 값으로 초기화해 두므로, 주소를 건드리지 않고
               저장해도 원래 좌표가 그대로 돌아간다 (updateSalonInfo 가 매번 덮어쓴다). --%>
          <input type="hidden" name="latitude"  id="salonLatitude"  value="${salon.latitude}">
          <input type="hidden" name="longitude" id="salonLongitude" value="${salon.longitude}">

          <div>
            <label style="font-size: 13px; font-weight: 700;">지도 위치</label>
            <p class="address-map-hint" id="addressMapHint">주소를 검색하면 지도에 위치가 표시됩니다.</p>
            <div class="address-map" id="salonAddressMap"></div>
          </div>

          <button type="submit" class="btn-modern btn-primary">정보 저장</button>
        </form>
      </div>
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
                  <h4 style="margin-bottom: 8px;">
                    <c:out value="${svc.serviceName}" />
                    <c:if test="${not empty svc.category}"> <span class="tag">${svc.category}</span></c:if>
                  </h4>
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
                            data-service-category="${svc.category}"
                            data-service-price="${svc.price}" data-service-duration="${svc.durationMinutes}"
                            data-service-description="${svc.description}"
                            data-service-concern="${svc.concern}">수정</button>
                    <form action="${ctx}/owner/store/service/${svc.serviceId}/delete" method="post"
                          onsubmit="return confirm('이 메뉴를 삭제하시겠습니까?')" style="display:inline;">
                      <button type="submit" class="btn-modern btn-danger"><i class="fas fa-trash"></i></button>
                    </form>
                  </div>
                </div>
              </div>
              <div><label style="font-size: 13px; font-weight: 700;">연락처</label><input type="text" name="phoneNumber" class="modern-input" value="${salon.phoneNumber}" placeholder="02-1234-5678" pattern="[0-9-]{9,13}" title="숫자와 하이픈(-)만 입력해주세요." required></div>
            </div>

            <%-- 주소 검색이 채우는 좌표. 저장된 값으로 초기화해 두므로, 주소를 건드리지 않고
                 저장해도 원래 좌표가 그대로 돌아간다 (updateSalonInfo 가 매번 덮어쓴다). --%>
            <input type="hidden" name="latitude"  id="salonLatitude"  value="${salon.latitude}">
            <input type="hidden" name="longitude" id="salonLongitude" value="${salon.longitude}">

            <div>
              <label style="font-size: 13px; font-weight: 700;">지도 위치</label>
              <p class="address-map-hint" id="addressMapHint">주소를 검색하면 지도에 위치가 표시됩니다.</p>
              <div class="address-map" id="salonAddressMap"></div>
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
          <form id="noticeWriteForm" method="post" action="<c:url value='/owner/store/notices'/>" enctype="multipart/form-data" style="display:none; flex-direction:column; gap:16px; margin-bottom: 20px;">
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
                    <form method="post" action="<c:url value='/owner/store/notices/${notice.noticeId}/delete'/>"
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
        <label style="display:block; font-size:13px; font-weight:700; color:var(--text-sub); margin:14px 0 8px;">카테고리</label>
        <select name="category" class="modern-input">
          <option value="">미분류</option>
          <option value="컷">컷</option>
          <option value="펌">펌</option>
          <option value="염색">염색</option>
          <option value="클리닉">클리닉</option>
          <option value="세트">세트</option>
        </select>
        <label style="display:block; font-size:13px; font-weight:700; color:var(--text-sub); margin:14px 0 8px;">가격(원)</label>
        <input type="number" name="price" class="modern-input" min="0" step="100" required>
        <label style="display:block; font-size:13px; font-weight:700; color:var(--text-sub); margin:14px 0 8px;">소요시간(분)</label>
        <input type="number" name="durationMinutes" class="modern-input" min="0" step="5" placeholder="예: 60">
        <label style="display:block; font-size:13px; font-weight:700; color:var(--text-sub); margin:14px 0 8px;">설명</label>
        <textarea name="description" class="modern-input" style="height:80px; resize:none;"></textarea>
        <label style="display:block; font-size:13px; font-weight:700; color:var(--text-sub); margin:14px 0 8px;">추천 고민 (선택)</label>
        <input type="text" name="concern" class="modern-input" placeholder="예: 곱슬머리, 손상모, 볼륨 다운">
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
        <label style="display:block; font-size:13px; font-weight:700; color:var(--text-sub); margin:14px 0 8px;">카테고리</label>
        <select name="category" id="editServiceCategory" class="modern-input">
          <option value="">미분류</option>
          <option value="컷">컷</option>
          <option value="펌">펌</option>
          <option value="염색">염색</option>
          <option value="클리닉">클리닉</option>
          <option value="세트">세트</option>
        </select>
        <label style="display:block; font-size:13px; font-weight:700; color:var(--text-sub); margin:14px 0 8px;">가격(원)</label>
        <input type="number" name="price" id="editServicePrice" class="modern-input" min="0" step="100" required>
        <label style="display:block; font-size:13px; font-weight:700; color:var(--text-sub); margin:14px 0 8px;">소요시간(분)</label>
        <input type="number" name="durationMinutes" id="editServiceDuration" class="modern-input" min="0" step="5">
        <label style="display:block; font-size:13px; font-weight:700; color:var(--text-sub); margin:14px 0 8px;">설명</label>
        <textarea name="description" id="editServiceDescription" class="modern-input" style="height:80px; resize:none;"></textarea>
        <label style="display:block; font-size:13px; font-weight:700; color:var(--text-sub); margin:14px 0 8px;">추천 고민 (선택)</label>
        <input type="text" name="concern" id="editServiceConcern" class="modern-input" placeholder="예: 곱슬머리, 손상모, 볼륨 다운">
        <button type="submit" class="btn-modern btn-primary" style="width:100%; margin-top:16px;">저장하기</button>
      </form>
    </div>
  </div>

  <jsp:include page="../includes/profile_modal.jsp">
      <jsp:param name="roleLabel" value="점주" />
  </jsp:include>

  <!-- 다음 우편번호 서비스(주소 검증) + 카카오맵 SDK(좌표 변환·마커).
       libraries=services 가 있어야 Geocoder 를 쓸 수 있다 — salonmap.jsp 와 같은 방식으로 로드한다. -->
  <script src="https://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
  <script src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=${kakaoMapApiKey}&libraries=services&autoload=true"></script>
  <script>
    /* 주소 검색 → 좌표 변환 → 마커.
       주소는 우편번호 API 가 검증한 도로명주소만 받고(Salons.address 한 컬럼),
       그 주소를 그대로 Geocoder 에 넘겨 좌표를 얻는다. */
    (function () {
      var button       = document.getElementById('searchAddressBtn');
      var addressInput = document.getElementById('salonAddress');
      var mapBox       = document.getElementById('salonAddressMap');
      if (!button || !mapBox) return;   // 매장 미선택 상태

      var latInput = document.getElementById('salonLatitude');
      var lngInput = document.getElementById('salonLongitude');
      var hint     = document.getElementById('addressMapHint');

      function setHint(text, isError) {
        hint.textContent = text;
        hint.classList.toggle('error-text', isError === true);
        hint.style.display = '';
      }

      /* 지도는 카카오 SDK 가 떠야 쓸 수 있다. SDK 로드가 막히면(사내망·키 도메인 불일치 등)
         지도만 포기하고 주소 검색은 그대로 살린다 — 주소를 못 고치는 쪽이 더 나쁘다. */
      var mapReady = typeof kakao !== 'undefined' && kakao.maps && kakao.maps.services;
      var map = null, marker = null, geocoder = null;

      if (mapReady) {
        var SEOUL = new kakao.maps.LatLng(37.5665, 126.9780);   // 좌표가 없을 때 보여줄 기본 위치
        var saved = (latInput.value && lngInput.value)
            ? new kakao.maps.LatLng(parseFloat(latInput.value), parseFloat(lngInput.value))
            : null;

        map = new kakao.maps.Map(mapBox, { center: saved || SEOUL, level: saved ? 3 : 8 });
        marker = new kakao.maps.Marker({ position: saved || SEOUL, map: saved ? map : null });
        geocoder = new kakao.maps.services.Geocoder();

        if (saved) {
          hint.style.display = 'none';
        }
      } else {
        mapBox.style.display = 'none';
        setHint('지도를 불러오지 못했습니다. 주소는 검색해서 저장할 수 있습니다.', true);
      }

      button.addEventListener('click', function () {
        new daum.Postcode({
          oncomplete: function (data) {
            // 도로명이 없는 옛 주소는 roadAddress 가 빈 문자열로 와서 선택한 주소로 되돌린다
            var road = data.roadAddress || data.address;
            addressInput.value = road;
            if (!mapReady) return;

            geocoder.addressSearch(road, function (result, status) {
              if (status !== kakao.maps.services.Status.OK || !result.length) {
                // 좌표를 못 찾아도 저장은 막지 않는다. 좌표가 비면 고객 지도에서
                // 마커를 그리지 않을 뿐이다 (salonmap.jsp 의 renderSalons).
                latInput.value = '';
                lngInput.value = '';
                marker.setMap(null);
                setHint('이 주소의 좌표를 찾지 못했습니다. 주소는 저장되지만 지도에는 표시되지 않습니다.', true);
                return;
              }

              // 카카오는 x = 경도, y = 위도 순서다. 뒤집으면 마커가 엉뚱한 곳에 찍힌다.
              var latitude  = result[0].y;
              var longitude = result[0].x;
              latInput.value = latitude;
              lngInput.value = longitude;

              var position = new kakao.maps.LatLng(parseFloat(latitude), parseFloat(longitude));
              marker.setPosition(position);
              marker.setMap(map);
              map.setLevel(3);
              map.setCenter(position);

              hint.style.display = 'none';
              hint.classList.remove('error-text');
            });
          }
        }).open();
      });
    })();
  </script>

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
        document.getElementById('editServiceCategory').value = btn.dataset.serviceCategory || '';
        document.getElementById('editServicePrice').value = btn.dataset.servicePrice;
        document.getElementById('editServiceDuration').value = btn.dataset.serviceDuration;
        document.getElementById('editServiceDescription').value = btn.dataset.serviceDescription;
        document.getElementById('editServiceConcern').value = btn.dataset.serviceConcern || '';
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
