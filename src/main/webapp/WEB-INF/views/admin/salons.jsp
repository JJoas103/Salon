<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | 미용실관리</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="/resources/css/common.css">
  <link rel="stylesheet" href="/resources/css/admin.css">
</head>
<body>
  <aside class="sidebar">
    <div class="sidebar-brand"><i class="fas fa-shield-alt"></i> ADMIN PANEL</div>
    <ul class="sidebar-menu">
      <li class="sidebar-item active"><a href="/admin/salons"><i class="fas fa-store"></i> 미용실관리</a></li>
      <li class="sidebar-item"><a href="/admin/community"><i class="fas fa-user-shield"></i> 커뮤니티 제재</a></li>
      <li class="sidebar-item"><a href="/admin/members"><i class="fas fa-users"></i> 회원관리</a></li>
      <li class="sidebar-item"><a href="/admin/banners"><i class="fas fa-ad"></i> 광고와 배너관리</a></li>
    </ul>
  </aside>
  <div class="app-container">
    <header class="app-header">
      <div style="font-weight: 700; font-size: 18px;">미용실관리</div>
      <div style="display: flex; align-items: center; gap: 10px;">
        <span style="font-size: 14px; font-weight: 600;">최고관리자</span>
        <div style="width: 32px; height: 32px; border-radius: 50%; background: #333; color: #fff; display: flex; align-items: center; justify-content: center; font-size: 12px;">A</div>
      </div>
    </header>
    <main class="app-content">
      <div class="stats-grid">
        <div class="stat-card"><div class="stat-label">전체 등록 매장</div><div class="stat-value">128개</div></div>
        <div class="stat-card"><div class="stat-label">이번 달 신규 등록</div><div class="stat-value">12개</div></div>
        <div class="stat-card"><div class="stat-label">활성 예약 수</div><div class="stat-value">1,420건</div></div>
      </div>
      <div class="modern-card">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
          <h3>매장 목록 (CRUD)</h3>
          <button class="btn-modern btn-primary"><i class="fas fa-plus"></i> 신규 매장 등록</button>
        </div>
        <table class="modern-table">
          <thead><tr><th>매장 ID</th><th>매장명</th><th>위치</th><th>점주명</th><th>상태</th><th>관리</th></tr></thead>
          <tbody>
            <tr><td>#1001</td><td>HAIR RESERVE 강남본점</td><td>서울 강남구</td><td>이점주</td><td><span class="status-tag status-active">운영중</span></td><td><button class="btn-modern btn-outline">수정</button> <button class="btn-modern btn-danger">삭제</button></td></tr>
          </tbody>
        </table>
      </div>
    </main>
  </div>
</body>
</html>
