<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | 마이페이지</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="/resources/css/common.css">
  <link rel="stylesheet" href="/resources/css/admin.css">
</head>
<body>
  <jsp:include page="../includes/sidebar_admin.jsp">
      <jsp:param name="menu" value="mypage" />
  </jsp:include>

  <div class="app-container">
    <header class="app-header">
      <div style="font-size: 18px; font-weight: 700;">마이페이지</div>
      <div class="user-badge"><span>${user.userName} 관리자님</span><div class="user-avatar-sm" style="width:32px; height:32px; font-size:12px;">${fn:substring(user.userName,0,1)}</div></div>
    </header>
    <main class="app-content">
      <c:if test="${param.passwordChanged == 'true'}">
        <p class="success-text" style="margin-bottom:20px; font-size:14px;">비밀번호가 변경되었습니다.</p>
      </c:if>

      <div class="modern-card" style="display:flex; align-items:center; gap:25px;">
        <div class="user-avatar-sm" style="width:70px; height:70px; font-size:26px;">${fn:substring(user.userName,0,1)}</div>
        <div>
          <h2 style="margin-bottom: 6px; font-size: 22px;">${user.userName} <span class="tag" style="margin-left:8px;">관리자</span></h2>
          <p style="font-size: 14px; color: var(--text-sub);">등록 이메일: ${user.email} | 연락처: ${user.phoneNumber} | 가입일: ${user.createdAt}</p>
        </div>
      </div>

      <div class="menu-group">
        <a href="<c:url value='/admin/salons'/>" class="menu-item-modern"><span><i class="fas fa-store" style="margin-right:12px;"></i> 매장 관리</span><i class="fas fa-chevron-right"></i></a>
        <a href="<c:url value='/admin/members'/>" class="menu-item-modern"><span><i class="fas fa-users" style="margin-right:12px;"></i> 회원 관리</span><i class="fas fa-chevron-right"></i></a>
        <a href="<c:url value='/admin/community'/>" class="menu-item-modern"><span><i class="fas fa-comments" style="margin-right:12px;"></i> 커뮤니티 관리</span><i class="fas fa-chevron-right"></i></a>
        <a href="<c:url value='/admin/banners'/>" class="menu-item-modern"><span><i class="fas fa-bullhorn" style="margin-right:12px;"></i> 배너 관리</span><i class="fas fa-chevron-right"></i></a>
        <a href="#" id="openPasswordModalBtn" class="menu-item-modern"><span><i class="fas fa-shield-alt" style="margin-right:12px;"></i> 보안 및 비밀번호 변경</span><i class="fas fa-chevron-right"></i></a>
      </div>
    </main>
  </div>

  <jsp:include page="../includes/password_modal.jsp">
      <jsp:param name="mypageUrl" value="/admin/mypage" />
  </jsp:include>
</body>
</html>
