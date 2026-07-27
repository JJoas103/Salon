<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | 예약 내역</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="../css/common.css">
  <link rel="stylesheet" href="../css/user.css">
</head>
<body>
  <aside class="sidebar">
    <div class="sidebar-brand"><i class="fas fa-scissors" style="color: var(--accent);"></i><span>HAIR RESERVE</span></div>
    <ul class="sidebar-menu">
      <li class="sidebar-item"><a href="home.html"><i class="fas fa-home"></i> 홈 메인</a></li>
      <li class="sidebar-item"><a href="search.html"><i class="fas fa-search"></i> 헤어샵 검색/예약</a></li>
      <li class="sidebar-item"><a href="chat.html"><i class="fas fa-comments"></i> 1:1 상담 채팅</a></li>
      <li class="sidebar-item"><a href="community.html"><i class="fas fa-users"></i> 스타일 커뮤니티</a></li>
      <li class="sidebar-item active"><a href="reservations.html"><i class="fas fa-calendar-alt"></i> 예약 내역</a></li>
      <li class="sidebar-item"><a href="mypage.html"><i class="fas fa-user"></i> 마이페이지</a></li>
    </ul>
  </aside>
  <div class="app-container">
    <header class="app-header">
      <div class="user-badge"><span>김다정 고객님</span><div class="user-avatar-sm">DJ</div></div>
    </header>
    <main class="app-content">
      <div class="res-tabs">
        <div class="res-tab active">전체 예약 히스토리</div>
        <div class="res-tab">확정 대기</div>
        <div class="res-tab">이용 완료</div>
      </div>
      <div class="res-card">
        <div class="res-card-header">
          <span style="font-size: 14px; color: var(--text-sub); font-weight: 600;">주문번호: HR-2026-0706</span>
          <span class="status-badge status-upcoming">이용 예정 (확정)</span>
        </div>
        <div class="res-card-body">
          <img src="https://images.unsplash.com/photo-1560066984-138dadb4c035?auto=format&fit=crop&w=300&q=80" style="width: 110px; height: 110px; border-radius: var(--radius-md); object-fit: cover;" alt="salon">
          <div class="res-info-grid">
            <div class="res-meta-item"><span>매장명</span><strong>헤어 스튜디오 온</strong></div>
            <div class="res-meta-item"><span>예약일시</span><strong>2026년 7월 6일 (월) 11:00</strong></div>
            <div class="res-meta-item"><span>시술 상품 / 소요 시간</span><strong>여성 디자인 레이어드 컷 / 60분 소요 예상</strong></div>
            <div class="res-meta-item"><span>결제 수단 및 금액</span><strong>카카오페이 선결제 (33,000원 완료)</strong></div>
          </div>
          <div style="display:flex; flex-direction:column; gap:8px;">
            <button class="btn-modern btn-outline" onclick="location.href='chat.html'">1:1 문의</button>
            <button class="btn-modern btn-primary" style="background:#FF4757; border-color:#FF4757;">예약 취소</button>
          </div>
        </div>
      </div>
    </main>
  </div>
</body>
</html>
