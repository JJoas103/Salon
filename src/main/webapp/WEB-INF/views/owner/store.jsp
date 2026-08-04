<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
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
          <button class="btn-modern btn-outline"><i class="fas fa-plus"></i> 메뉴 추가</button>
        </div>
        <div class="menu-grid">
          <div class="menu-card">
            <h4 style="margin-bottom: 8px;">남성 디자인 컷</h4>
            <p style="color: var(--accent); font-weight: 700; margin-bottom: 12px;">25,000원</p>
            <div style="display: flex; gap: 5px;"><button class="btn-modern btn-outline" style="flex: 1;">수정</button><button class="btn-modern btn-danger"><i class="fas fa-trash"></i></button></div>
          </div>
        </div>
      </div>
    </main>
  </div>

  <jsp:include page="../includes/profile_modal.jsp">
      <jsp:param name="roleLabel" value="점주" />
  </jsp:include>
</body>
</html>
