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
  <link rel="stylesheet" href="/resources/css/auth.css">
</head>
<body>
  <!-- 사이드바 -->
  <jsp:include page="../includes/sidebar_common.jsp">
      <jsp:param name="menu" value="mypage" />
  </jsp:include>

  <div class="app-container">
    <main class="app-content">
      <c:if test="${param.passwordChanged == 'true'}">
        <p class="success-text" style="margin-bottom:20px; font-size:14px;">비밀번호가 변경되었습니다.</p>
      </c:if>
      <div class="profile-hero">
        <div class="profile-avatar-lg">${fn:substring(user.userName,0,1)}</div>
        <div>
          <h2 style="margin-bottom: 6px; font-size: 24px;">${user.userName} <span style="font-size:14px; color:var(--accent); font-weight:700; margin-left:8px;">VIP 등급</span></h2>
          <p style="font-size: 14px; color: var(--text-sub);">등록 이메일: ${user.email} | 가입일: ${user.createdAt}</p>
        </div>
      </div>
      <div class="stat-grid stat-grid-four">
        <div class="stat-card"><span style="font-size: 13px; color: var(--text-sub); display:block; margin-bottom:8px;">누적 예약 건수</span><strong style="font-size: 26px;">${reservationCount} 회</strong></div>
        <a class="stat-card stat-card-link" href="<c:url value='/common/coupons'/>">
          <span style="font-size:13px;color:var(--text-sub);display:block;margin-bottom:8px;">보유 활성 쿠폰</span>
          <strong style="font-size:26px;">${couponCount}장</strong>
          <small>쿠폰함 열기 <i class="fas fa-chevron-right"></i></small>
        </a>
        <a class="stat-card stat-card-link" href="<c:url value='/common/points'/>">
          <span style="font-size:13px;color:var(--text-sub);display:block;margin-bottom:8px;">보유 적립금</span>
          <strong style="font-size:26px;"><fmt:formatNumber value="${pointBalance}" pattern="#,##0"/>원</strong>
          <small>적립금 내역 보기 <i class="fas fa-chevron-right"></i></small>
        </a>
        <a class="stat-card stat-card-link" href="<c:url value='/common/wishlists'/>">
          <span style="font-size:13px;color:var(--text-sub);display:block;margin-bottom:8px;">찜 목록</span>
          <strong style="font-size:26px;">${wishlistCount}개</strong>
          <small>저장한 헤어샵 보기 <i class="fas fa-chevron-right"></i></small>
        </a>
      </div>
      <div class="menu-group">
        <a href="<c:url value='/common/my-reviews'/>" class="menu-item-modern">
          <span><i class="fas fa-star" style="margin-right:12px;"></i> 작성한 리뷰</span>
          <span><strong>${reviewCount}</strong>개 <i class="fas fa-chevron-right" style="margin-left:8px;"></i></span>
        </a>
        <a href="#" class="menu-item-modern" style="opacity:0.5; pointer-events:none;"><span><i class="fas fa-credit-card" style="margin-right:12px;"></i> 결제 수단 및 카드 관리</span><span class="tag">준비중</span></a>
        <a href="#" class="menu-item-modern" style="opacity:0.5; pointer-events:none;"><span><i class="fas fa-bell" style="margin-right:12px;"></i> 알림 설정</span><span class="tag">준비중</span></a>
        <a href="#" id="openPasswordModalBtn" class="menu-item-modern"><span><i class="fas fa-shield-alt" style="margin-right:12px;"></i> 보안 및 비밀번호 변경</span><i class="fas fa-chevron-right"></i></a>
      </div>
    </main>
  </div>

  <!-- 비밀번호 변경 모달 (역할 공용) -->
  <jsp:include page="../includes/password_modal.jsp">
      <jsp:param name="mypageUrl" value="/common/mypage" />
  </jsp:include>
</body>
</html>
