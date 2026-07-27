<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | 1:1 상담 채팅</title>
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
      <li class="sidebar-item active"><a href="chat.html"><i class="fas fa-comments"></i> 1:1 상담 채팅</a></li>
      <li class="sidebar-item"><a href="community.html"><i class="fas fa-users"></i> 스타일 커뮤니티</a></li>
      <li class="sidebar-item"><a href="reservations.html"><i class="fas fa-calendar-alt"></i> 예약 내역</a></li>
      <li class="sidebar-item"><a href="mypage.html"><i class="fas fa-user"></i> 마이페이지</a></li>
    </ul>
  </aside>
  <div class="app-container">
    <header class="app-header">
      <div class="user-badge"><span>김다정 고객님</span><div class="user-avatar-sm">DJ</div></div>
    </header>
    <main class="app-content">
      <div class="chat-layout">
        <div class="chat-sidebar">
          <div class="chat-room-item active">
            <img src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=100&q=80" style="width: 42px; height: 42px; border-radius: 50%;" alt="salon">
            <div style="flex:1;"><strong>헤어 스튜디오 온</strong><p style="font-size: 12px; color: var(--text-sub);">네 예약하신 시간에 조심히 오세요!</p></div>
          </div>
        </div>
        <div class="chat-main">
          <div class="chat-header"><strong>헤어 스튜디오 온 (민지 원장)</strong></div>
          <div class="chat-body">
            <div class="msg-wrapper incoming"><div class="msg-bubble">안녕하세요 김다정 고객님! 맞춤 상담 도와드릴게요.</div></div>
            <div class="msg-wrapper outgoing"><div class="msg-bubble">안녕하세요! 레이어드 컷 예약 관련해서 문의드려요.</div></div>
          </div>
          <div class="chat-footer">
            <input type="text" class="modern-input" placeholder="메시지를 입력하세요...">
            <button class="btn-modern btn-primary">보내기</button>
          </div>
        </div>
      </div>
    </main>
  </div>
</body>
</html>
