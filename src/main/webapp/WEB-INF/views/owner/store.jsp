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
            <div><label style="font-size: 13px; font-weight: 700;">연락처</label><input type="text" name="phoneNumber" class="modern-input" value="${salon.phoneNumber}" placeholder="02-1234-5678"></div>
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
  </script>
</body>
</html>
