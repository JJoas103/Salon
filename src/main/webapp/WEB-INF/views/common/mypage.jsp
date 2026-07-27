<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | 마이페이지</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="/resources/css/common.css">
  <link rel="stylesheet" href="/resources/css/user.css">
</head>
<body>
  <!-- 사이드바 -->
  <jsp:include page="../includes/sidebar_common.jsp">
      <jsp:param name="menu" value="mypage" />
  </jsp:include>

  <div class="app-container">
    <header class="app-header">
      <div class="user-badge"><span>${user.userName} 고객님</span><div class="user-avatar-sm">${fn:substring(user.userName,0,1)}</div></div>
    </header>
    <main class="app-content">
      <div class="profile-hero">
        <div class="profile-avatar-lg">${fn:substring(user.userName,0,1)}</div>
        <div>
          <h2 style="margin-bottom: 6px; font-size: 24px;">${user.userName} <span style="font-size:14px; color:var(--accent); font-weight:700; margin-left:8px;">VIP 등급</span></h2>
          <p style="font-size: 14px; color: var(--text-sub);">등록 이메일: ${user.email} | 가입일: ${user.createdAt}</p>
        </div>
      </div>
      <div class="stat-grid">
        <div class="stat-card"><span style="font-size: 13px; color: var(--text-sub); display:block; margin-bottom:8px;">누적 이용 건수</span><strong style="font-size: 26px;">12 회</strong></div>
        <div class="stat-card"><span style="font-size: 13px; color: var(--text-sub); display:block; margin-bottom:8px;">보유 활성 쿠폰</span><strong style="font-size: 26px; color:var(--accent);">3 장</strong></div>
        <div class="stat-card"><span style="font-size: 13px; color: var(--text-sub); display:block; margin-bottom:8px;">적립 적립금</span><strong style="font-size: 26px;">4,500 원</strong></div>
      </div>
      <div class="menu-group">
        <a href="#" class="menu-item-modern"><span><i class="fas fa-credit-card" style="margin-right:12px;"></i> 결제 수단 및 카드 관리</span><i class="fas fa-chevron-right"></i></a>
        <a href="#" class="menu-item-modern"><span><i class="fas fa-bell" style="margin-right:12px;"></i> 알림 설정</span><i class="fas fa-chevron-right"></i></a>
        <a href="#" class="menu-item-modern"><span><i class="fas fa-shield-alt" style="margin-right:12px;"></i> 보안 및 비밀번호 변경</span><i class="fas fa-chevron-right"></i></a>
      </div>
    </main>
  </div>
</body>
</html>
