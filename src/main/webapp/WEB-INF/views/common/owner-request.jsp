<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | 점주 요청</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="/resources/css/common.css">
  <link rel="stylesheet" href="/resources/css/user.css">
</head>
<body class="owner-request-page">
  <!-- 사이드바 -->
  <jsp:include page="../includes/sidebar_common.jsp">
      <jsp:param name="menu" value="ownerRequest" />
  </jsp:include>

  <div class="app-container">
    <header class="app-header"></header>
    <main class="app-content">

      <div class="profile-hero">
        <div class="profile-avatar-lg"><i class="fas fa-store"></i></div>
        <div>
          <h2 style="margin-bottom: 6px; font-size: 24px;">점주 승격 요청</h2>
          <p style="font-size: 14px; color: var(--text-sub);">매장을 운영하고 계신가요? 신청서를 보내면 관리자 검토 후 점주 권한으로 전환해드립니다.</p>
        </div>
      </div>

      <c:if test="${param.submitted == 'true'}">
        <p class="success-text" style="margin-bottom:14px;">신청이 접수되었습니다. 관리자 검토 후 점주 권한으로 전환됩니다.</p>
      </c:if>

      <div class="modern-card" style="max-width: 620px;">
        <form id="ownerRequestForm" action="<c:url value='/common/owner-request'/>" method="post">
          <div style="margin-bottom:22px;">
            <label style="display:block; font-size:13px; font-weight:700; color:var(--text-sub); margin-bottom:8px;">매장명 (가칭)</label>
            <input type="text" name="salonName" class="modern-input" placeholder="예: 라움헤어 강남점">
          </div>
          <div style="margin-bottom:22px;">
            <label style="display:block; font-size:13px; font-weight:700; color:var(--text-sub); margin-bottom:8px;">매장 연락처</label>
            <input type="text" name="salonPhone" class="modern-input" placeholder="02-1234-5678">
          </div>
          <div style="margin-bottom:22px;">
            <label style="display:block; font-size:13px; font-weight:700; color:var(--text-sub); margin-bottom:8px;">신청 사유 / 매장 소개</label>
            <textarea name="message" class="modern-input" style="height:160px; line-height:1.7; resize:none;" placeholder="운영 중인 매장이나 신청 사유를 간단히 적어주세요"></textarea>
          </div>
          <button type="submit" class="btn-modern btn-primary" style="width:100%;">신청하기</button>
        </form>
      </div>

    </main>
  </div>
</body>
</html>
