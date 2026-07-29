<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | 회원관리</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="/resources/css/common.css">
  <link rel="stylesheet" href="/resources/css/admin.css">
</head>
<body>
  <jsp:include page="../includes/sidebar_admin.jsp">
      <jsp:param name="menu" value="members" />
  </jsp:include>
  <div class="app-container">
    <header class="app-header">
      <div style="font-weight: 700; font-size: 18px;">회원관리</div>
      <div id="openProfileModalBtn" style="display: flex; align-items: center; gap: 10px; cursor: pointer;">
        <span style="font-size: 14px; font-weight: 600;">${user.userName} 관리자님</span>
        <div style="width: 32px; height: 32px; border-radius: 50%; background: #333; color: #fff; display: flex; align-items: center; justify-content: center; font-size: 12px;">관</div>
      </div>
    </header>
    <main class="app-content">
      <div class="stats-grid">
        <div class="stat-card"><div class="stat-label">총 가입 회원</div><div class="stat-value">15,420명</div></div>
        <div class="stat-card"><div class="stat-label">신규 가입(이번 달)</div><div class="stat-value">342명</div></div>
        <div class="stat-card"><div class="stat-label">정지된 회원</div><div class="stat-value">18명</div></div>
      </div>
      <div class="modern-card">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
          <h3>전체 회원 목록</h3>
          <button class="btn-modern btn-outline"><i class="fas fa-download"></i> 엑셀 다운로드</button>
        </div>
        <table class="modern-table">
          <thead><tr><th>회원 ID</th><th>이름</th><th>가입일</th><th>최근 접속</th><th>상태</th><th>관리</th></tr></thead>
          <tbody>
            <tr><td>user_001</td><td>김고객</td><td>2025-01-15</td><td>2026-07-08</td><td><span class="status-tag status-active">정상</span></td><td><button class="btn-modern btn-outline">상세</button> <button class="btn-modern btn-danger">차단</button></td></tr>
          </tbody>
        </table>
      </div>
    </main>
  </div>

  <jsp:include page="../includes/profile_modal.jsp">
      <jsp:param name="roleLabel" value="관리자" />
  </jsp:include>
</body>
</html>
