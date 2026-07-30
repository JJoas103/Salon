<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | 이벤트/공지사항</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="/resources/css/common.css">
  <link rel="stylesheet" href="/resources/css/owner.css">
</head>
<body class="store-page">
  <jsp:include page="../includes/sidebar_owner.jsp">
      <jsp:param name="menu" value="events" />
  </jsp:include>
  <jsp:include page="../includes/salon_gate_overlay.jsp" />
  <div class="app-container">
    <header class="app-header">
      <div style="font-size: 18px; font-weight: 700;">이벤트/공지사항</div>
      <div class="user-badge" id="openProfileModalBtn" style="cursor:pointer;"><span>${user.userName} 점주님</span><div class="user-avatar-sm" style="width:32px; height:32px; border-radius:50%; background:#E0E0E0; display:inline-flex; align-items:center; justify-content:center; margin-left:10px;">점</div></div>
    </header>
    <main class="app-content">
      <div class="modern-card">
        <div class="flex-between" style="margin-bottom: 20px;">
          <h3>이벤트 및 공지사항 관리</h3>
          <button class="btn-modern btn-primary"><i class="fas fa-plus"></i> 글쓰기</button>
        </div>
        <table class="modern-table">
          <thead>
            <tr><th>구분</th><th>제목</th><th>등록일</th><th>상태</th><th>관리</th></tr>
          </thead>
          <tbody>
            <tr>
              <td><span class="status-badge status-confirmed">이벤트</span></td>
              <td style="font-weight: 600;">[첫 방문 혜택] 레이어드 컷 20% 특별 타임 세일</td>
              <td>2026-07-01</td>
              <td><span class="status-badge status-confirmed">진행중</span></td>
              <td><button class="btn-modern btn-outline">수정</button> <button class="btn-modern btn-danger"><i class="fas fa-trash"></i></button></td>
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
