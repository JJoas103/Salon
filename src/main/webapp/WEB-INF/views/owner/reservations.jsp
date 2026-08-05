<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | 예약현황관리</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="/resources/css/common.css">
  <link rel="stylesheet" href="/resources/css/owner.css">
</head>
<body class="store-page">
  <jsp:include page="../includes/sidebar_owner.jsp">
      <jsp:param name="menu" value="reservations" />
  </jsp:include>
  <jsp:include page="../includes/salon_gate_overlay.jsp" />
  <div class="app-container">
    <header class="app-header">
      <div style="font-size: 18px; font-weight: 700;">예약현황관리</div>
    </header>
    <main class="app-content">
      <div class="modern-card">
        <div class="flex-between" style="margin-bottom: 20px;">
          <h3>오늘의 예약 현황</h3>
          <div class="tag">총 8건</div>
        </div>
        <table class="modern-table">
          <thead>
            <tr><th>예약시간</th><th>고객명</th><th>담당 디자이너</th><th>시술메뉴</th><th>상태</th><th>관리</th></tr>
          </thead>
          <tbody>
            <tr>
              <td>11:00</td><td>김철수</td><td>레오 실장</td><td>남성 컷 + 다운펌</td>
              <td><span class="status-badge status-pending">대기중</span></td>
              <td><button class="btn-modern btn-accent">확정</button> <button class="btn-modern btn-outline">거절</button></td>
            </tr>
            <tr>
              <td>13:30</td><td>이영희</td><td>사라 원장</td><td>레이어드 컷 + C컬펌</td>
              <td><span class="status-badge status-confirmed">확정됨</span></td>
              <td><button class="btn-modern btn-outline">상세보기</button></td>
            </tr>
          </tbody>
        </table>
      </div>
    </main>
  </div>

  <jsp:include page="../includes/profile_modal.jsp">
      <jsp:param name="roleLabel" value="점주" />
  </jsp:include>
</body>
</html>
