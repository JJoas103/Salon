<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | 헤어샵 검색/예약</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="/resources/css/common.css">
  <link rel="stylesheet" href="/resources/css/user.css">
</head>
<body class="search-page">
  <!-- 사이드바 -->
  <jsp:include page="../includes/sidebar_common.jsp">
    <jsp:param name="menu" value="search" />
  </jsp:include>

  <div class="app-container">
    <header class="app-header">
      <div class="user-badge"><span>김다정 고객님</span><div class="user-avatar-sm">DJ</div></div>
    </header>
    <main class="app-content">
      <div class="search-layout">
        <div>
          <div class="modern-card" style="margin-bottom: 30px;">
            <h2 style="font-size: 24px;">헤어 스튜디오 온</h2>
            <p style="color: var(--text-sub); margin-top: 10px;">합정역 도보 3분 | 1인 미용실</p>
          </div>
          <h3 style="margin-bottom: 15px;">시술 메뉴 선택</h3>
          <div class="menu-item-card selected"><div><strong>여성 디자인 레이어드 컷</strong></div><strong>33,000원</strong></div>
          <div class="menu-item-card"><div><strong>시그니처 볼륨 매직 셋팅</strong></div><strong>165,000원</strong></div>
        </div>
        <div class="summary-sticky-panel">
          <h3 style="margin-bottom: 20px; border-bottom: 2px solid var(--primary); padding-bottom: 10px;">선택 항목 요약</h3>
          <p style="margin-bottom: 10px;">매장: 헤어 스튜디오 온</p>
          <p style="margin-bottom: 10px;">메뉴: 여성 디자인 레이어드 컷</p>
          <p style="margin-bottom: 20px; font-weight: 700;">최종 금액: 33,000원</p>
          <button class="btn-modern btn-accent" style="width: 100%;">안전결제하기</button>
        </div>
      </div>
    </main>
  </div>
</body>
</html>
