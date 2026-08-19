<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | 매장관리</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="/resources/css/common.css">
  <link rel="stylesheet" href="/resources/css/admin.css">
</head>
<body>
  <jsp:include page="../includes/sidebar_admin.jsp">
      <jsp:param name="menu" value="salons" />
  </jsp:include>
  <div class="app-container">
    <header class="app-header">
      <div style="font-weight: 700; font-size: 18px;">매장관리</div>
    </header>
    <main class="app-content">
      <c:if test="${not empty error}">
        <p class="error-text"><c:out value="${error}" /></p>
      </c:if>
      <c:if test="${not empty success}">
        <p style="color: var(--success); font-size: 13px; margin-bottom: 14px;"><c:out value="${success}" /></p>
      </c:if>

      <div class="stats-grid">
        <div class="stat-card"><div class="stat-label">운영중인 매장</div><div class="stat-value">${activeSalonCount}개</div></div>
        <div class="stat-card"><div class="stat-label">이번 달 신규 등록</div><div class="stat-value">${newThisMonthCount}개</div></div>
        <div class="stat-card"><div class="stat-label">활성 예약 수</div><div class="stat-value">${activeReservationCount}건</div></div>
      </div>

      <div class="modern-card">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
          <h3>매장 목록</h3>
        </div>

        <c:set var="isPreparingTab" value="${status == 'preparing'}" />
        <c:set var="isRequestsTab" value="${status == 'requests'}" />
        <c:url var="activeTabUrl" value="/admin/salons">
          <c:param name="keyword" value="${keyword}"/>
          <c:param name="size" value="${size}"/>
        </c:url>
        <c:url var="closedTabUrl" value="/admin/salons">
          <c:param name="keyword" value="${keyword}"/>
          <c:param name="size" value="${size}"/>
          <c:param name="status" value="closed"/>
        </c:url>
        <c:url var="preparingTabUrl" value="/admin/salons">
          <c:param name="size" value="${size}"/>
          <c:param name="status" value="preparing"/>
        </c:url>
        <c:url var="requestsTabUrl" value="/admin/salons">
          <c:param name="size" value="${size}"/>
          <c:param name="status" value="requests"/>
        </c:url>
        <div style="display: flex; gap: 8px; margin-bottom: 16px;">
          <a href="${activeTabUrl}" class="btn-modern ${status == 'closed' or isPreparingTab or isRequestsTab ? 'btn-outline' : 'btn-primary'}"
             style="text-decoration: none; ${status == 'closed' or isPreparingTab or isRequestsTab ? 'color: var(--text-main);' : ''}">운영중 매장</a>
          <a href="${closedTabUrl}" class="btn-modern ${status == 'closed' ? 'btn-primary' : 'btn-outline'}"
             style="text-decoration: none; ${status == 'closed' ? '' : 'color: var(--text-main);'}">폐업 매장</a>
          <a href="${preparingTabUrl}" class="btn-modern ${isPreparingTab ? 'btn-primary' : 'btn-outline'}"
             style="text-decoration: none; ${isPreparingTab ? '' : 'color: var(--text-main);'}">심사 대기 (${preparingSalonCount})</a>
          <a href="${requestsTabUrl}" class="btn-modern ${isRequestsTab ? 'btn-primary' : 'btn-outline'}"
             style="text-decoration: none; ${isRequestsTab ? '' : 'color: var(--text-main);'}">매장 추가 요청 (${additionalSalonRequestCount})</a>
        </div>

        <c:if test="${not isPreparingTab and not isRequestsTab}">
          <form action="${ctx}/admin/salons" method="get"
                style="display: flex; gap: 10px; margin-bottom: 20px; flex-wrap: wrap;">
            <input type="hidden" name="status" value="${status}">
            <input type="text" name="keyword" value="${keyword}" class="modern-input"
                   style="width: auto; flex: 1; min-width: 200px;" placeholder="매장명, 주소 또는 점주명 검색">
            <select name="size" class="modern-input" style="width: auto;">
              <option value="10" ${size == 10 ? 'selected' : ''}>10개</option>
              <option value="20" ${size == 20 ? 'selected' : ''}>20개</option>
              <option value="50" ${size == 50 ? 'selected' : ''}>50개</option>
            </select>
            <button type="submit" class="btn-modern btn-primary"><i class="fas fa-search"></i> 검색</button>
            <c:if test="${not empty keyword}">
              <a href="${ctx}/admin/salons${status == 'closed' ? '?status=closed' : ''}" class="btn-modern btn-outline" style="text-decoration: none; color: var(--text-main);">초기화</a>
            </c:if>
          </form>
        </c:if>

        <p style="color: var(--text-sub); font-size: 13px; margin-bottom: 10px;">
          총 <strong>${totalCount}</strong>개
        </p>

        <c:choose>
          <c:when test="${isPreparingTab}">
            <table class="modern-table">
              <thead><tr><th>매장 ID</th><th>매장명</th><th>점주명</th><th>등록 필수항목</th><th>관리</th></tr></thead>
              <tbody>
                <c:choose>
                  <c:when test="${empty salons}">
                    <tr><td colspan="5" style="text-align: center; color: var(--text-sub);">심사 대기중인 매장이 없습니다.</td></tr>
                  </c:when>
                  <c:otherwise>
                    <c:forEach var="salon" items="${salons}">
                      <c:set var="addrOk" value="${hasAddress[salon.salonId]}" />
                      <c:set var="hoursOk" value="${hoursCount[salon.salonId] > 0}" />
                      <c:set var="menuOk" value="${serviceCount[salon.salonId] > 0}" />
                      <c:set var="allOk" value="${addrOk and hoursOk and menuOk}" />
                      <tr>
                        <td>#${salon.salonId}</td>
                        <td><c:out value="${salon.salonName}" /></td>
                        <td><c:out value="${salon.ownerName}" /></td>
                        <td>
                          <button type="button" class="btn-modern btn-outline checklist-btn"
                                  data-salon-name="<c:out value='${salon.salonName}'/>"
                                  data-addr-ok="${addrOk}" data-hours-ok="${hoursOk}" data-menu-ok="${menuOk}">
                            <i class="fas fa-list-check" style="margin-right:6px;"></i>체크리스트 ${allOk ? '(완료)' : ''}
                          </button>
                        </td>
                        <td>
                          <form action="${ctx}/admin/salons/${salon.salonId}/activate" method="post"
                                onsubmit="return confirm('이 매장을 승인하고 손님에게 노출하시겠습니까?')" style="display: inline;">
                            <button type="submit" class="btn-modern btn-primary" ${allOk ? '' : 'disabled style="opacity:.5; cursor:not-allowed;"'}>활성화</button>
                          </form>
                        </td>
                      </tr>
                    </c:forEach>
                  </c:otherwise>
                </c:choose>
              </tbody>
            </table>
          </c:when>
          <c:when test="${isRequestsTab}">
            <table class="modern-table">
              <thead><tr><th>신청 점주</th><th>매장명</th><th>연락처</th><th>신청일</th><th>사유</th><th>관리</th></tr></thead>
              <tbody>
                <c:choose>
                  <c:when test="${empty additionalSalonRequests}">
                    <tr><td colspan="6" style="text-align: center; color: var(--text-sub);">대기중인 매장 추가 요청이 없습니다.</td></tr>
                  </c:when>
                  <c:otherwise>
                    <c:forEach var="req" items="${additionalSalonRequests}">
                      <tr>
                        <td><c:out value="${req.applicantName}" /><br><span style="color:var(--text-sub); font-size:12px;"><c:out value="${req.applicantEmail}" /></span></td>
                        <td><c:out value="${req.salonName}" /></td>
                        <td><c:out value="${req.salonPhone}" /></td>
                        <td>${fn:substring(req.requestedAt, 0, 16)}</td>
                        <td>
                          <c:choose>
                            <c:when test="${not empty req.message}">
                              <button type="button" class="btn-modern btn-outline salon-request-message-btn"
                                      data-message="<c:out value='${req.message}'/>">사유 보기</button>
                            </c:when>
                            <c:otherwise>
                              <span style="color:var(--text-sub); font-size:12px;">-</span>
                            </c:otherwise>
                          </c:choose>
                        </td>
                        <td>
                          <div style="display:flex; gap:6px;">
                            <form action="${ctx}/admin/salons/requests/${req.requestId}/approve" method="post"
                                  onsubmit="return confirm('이 점주에게 매장을 하나 더 등록해 주시겠습니까?')" style="display:inline;">
                              <button type="submit" class="btn-modern btn-primary">승인</button>
                            </form>
                            <form action="${ctx}/admin/salons/requests/${req.requestId}/reject" method="post"
                                  onsubmit="return confirm('이 매장 추가 요청을 반려하시겠습니까?')" style="display:inline;">
                              <button type="submit" class="btn-modern btn-outline">반려</button>
                            </form>
                          </div>
                        </td>
                      </tr>
                    </c:forEach>
                  </c:otherwise>
                </c:choose>
              </tbody>
            </table>
          </c:when>
          <c:otherwise>
            <table class="modern-table">
              <thead><tr><th>매장 ID</th><th>매장명</th><th>위치</th><th>점주명</th><th>상태</th><th>관리</th></tr></thead>
              <tbody>
                <c:choose>
                  <c:when test="${empty salons}">
                    <tr><td colspan="6" style="text-align: center; color: var(--text-sub);">조회된 매장이 없습니다.</td></tr>
                  </c:when>
                  <c:otherwise>
                    <c:forEach var="salon" items="${salons}">
                      <tr>
                        <td>#${salon.salonId}</td>
                        <td><c:out value="${salon.salonName}" /></td>
                        <td><c:out value="${salon.address}" /></td>
                        <td><c:out value="${salon.ownerName}" /></td>
                        <td>
                          <c:choose>
                            <c:when test="${status == 'closed'}">
                              <span class="status-tag status-inactive">폐업일: ${fn:substring(salon.closedAt, 0, 10)}</span>
                            </c:when>
                            <c:otherwise>
                              <span class="status-tag status-active">운영중</span>
                            </c:otherwise>
                          </c:choose>
                        </td>
                        <td>
                          <c:choose>
                            <c:when test="${status == 'closed'}">
                              <form action="${ctx}/admin/salons/${salon.salonId}/reopen" method="post"
                                    onsubmit="return confirm('이 매장을 다시 운영중으로 전환하시겠습니까?')" style="display: inline;">
                                <button type="submit" class="btn-modern btn-outline">폐업취소</button>
                              </form>
                            </c:when>
                            <c:otherwise>
                              <form action="${ctx}/admin/salons/${salon.salonId}/close" method="post"
                                    onsubmit="return confirm('이 매장을 폐업 처리하시겠습니까?')" style="display: inline;">
                                <button type="submit" class="btn-modern btn-danger">폐업처리</button>
                              </form>
                            </c:otherwise>
                          </c:choose>
                        </td>
                      </tr>
                    </c:forEach>
                  </c:otherwise>
                </c:choose>
              </tbody>
            </table>
          </c:otherwise>
        </c:choose>

        <c:if test="${totalPages > 1}">
          <div style="display: flex; justify-content: center; gap: 6px; margin-top: 20px;">
            <c:forEach begin="1" end="${totalPages}" var="p">
              <c:url var="pageUrl" value="/admin/salons">
                <c:param name="keyword" value="${keyword}"/>
                <c:param name="status" value="${status}"/>
                <c:param name="size" value="${size}"/>
                <c:param name="page" value="${p}"/>
              </c:url>
              <c:choose>
                <c:when test="${p == page}">
                  <a href="${pageUrl}" class="btn-modern btn-primary" style="text-decoration: none;">${p}</a>
                </c:when>
                <c:otherwise>
                  <a href="${pageUrl}" class="btn-modern btn-outline" style="text-decoration: none; color: var(--text-main);">${p}</a>
                </c:otherwise>
              </c:choose>
            </c:forEach>
          </div>
        </c:if>
      </div>
    </main>
  </div>

  <jsp:include page="../includes/profile_modal.jsp">
      <jsp:param name="roleLabel" value="관리자" />
  </jsp:include>

  <!-- 심사 대기 체크리스트 모달 — 표 안 작은 글씨 대신 체크박스로 명확하게 -->
  <div class="modal-overlay" id="checklistModal">
    <div class="modal-box" style="max-width:420px;">
      <div class="modal-header">
        <h3 style="font-size: 18px;"><i class="fas fa-list-check" style="margin-right:8px; color:var(--accent);"></i><span id="checklistSalonName"></span></h3>
        <button type="button" class="modal-close" id="closeChecklistModalBtn"><i class="fas fa-times"></i></button>
      </div>
      <div style="display:flex; flex-direction:column; gap:14px;">
        <label style="display:flex; align-items:center; gap:10px; font-size:14px;">
          <input type="checkbox" id="checklistAddr" disabled style="width:18px; height:18px;"> 주소 입력
        </label>
        <label style="display:flex; align-items:center; gap:10px; font-size:14px;">
          <input type="checkbox" id="checklistHours" disabled style="width:18px; height:18px;"> 영업시간 등록
        </label>
        <label style="display:flex; align-items:center; gap:10px; font-size:14px;">
          <input type="checkbox" id="checklistMenu" disabled style="width:18px; height:18px;"> 시술 메뉴 1개 이상
        </label>
      </div>
    </div>
  </div>

  <!-- 매장 추가 요청 사유 보기 모달 -->
  <div class="modal-overlay" id="salonRequestMessageModal">
    <div class="modal-box" style="max-width:420px;">
      <div class="modal-header">
        <h3 style="font-size: 18px;"><i class="fas fa-comment-dots" style="margin-right:8px; color:var(--accent);"></i>신청 사유</h3>
        <button type="button" class="modal-close" id="closeSalonRequestMessageModalBtn"><i class="fas fa-times"></i></button>
      </div>
      <p id="salonRequestMessageText" style="white-space:pre-wrap; font-size:14px; color:var(--text-sub);"></p>
    </div>
  </div>

  <script>
    (function () {
      var modal = document.getElementById('checklistModal');
      var salonNameEl = document.getElementById('checklistSalonName');
      var addrBox = document.getElementById('checklistAddr');
      var hoursBox = document.getElementById('checklistHours');
      var menuBox = document.getElementById('checklistMenu');

      document.querySelectorAll('.checklist-btn').forEach(function (btn) {
        btn.addEventListener('click', function () {
          salonNameEl.textContent = btn.dataset.salonName;
          addrBox.checked = btn.dataset.addrOk === 'true';
          hoursBox.checked = btn.dataset.hoursOk === 'true';
          menuBox.checked = btn.dataset.menuOk === 'true';
          modal.classList.add('active');
        });
      });
      document.getElementById('closeChecklistModalBtn').addEventListener('click', function () {
        modal.classList.remove('active');
      });
      modal.addEventListener('click', function (e) { if (e.target === modal) modal.classList.remove('active'); });

      var msgModal = document.getElementById('salonRequestMessageModal');
      var msgText = document.getElementById('salonRequestMessageText');
      document.querySelectorAll('.salon-request-message-btn').forEach(function (btn) {
        btn.addEventListener('click', function () {
          msgText.textContent = btn.dataset.message;
          msgModal.classList.add('active');
        });
      });
      document.getElementById('closeSalonRequestMessageModalBtn').addEventListener('click', function () {
        msgModal.classList.remove('active');
      });
      msgModal.addEventListener('click', function (e) { if (e.target === msgModal) msgModal.classList.remove('active'); });
    })();
  </script>
</body>
</html>
