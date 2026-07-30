<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | 1:1 상담 채팅</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="/resources/css/common.css">
  <link rel="stylesheet" href="/resources/css/user.css">
</head>
<body>
  <!-- 사이드바 -->
  <jsp:include page="../includes/sidebar_common.jsp">
      <jsp:param name="menu" value="chat" />
  </jsp:include>
  <div class="app-container">
    <main class="app-content">
      <div class="chat-layout">
        <div class="chat-sidebar">
          <div class="chat-room-item active">
            <img src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=100&q=80" style="width: 42px; height: 42px; border-radius: 50%;" alt="salon">
            <div style="flex:1;"><strong>${salon.salonName}</strong><p style="font-size: 12px; color: var(--text-sub);">네 예약하신 시간에 조심히 오세요!</p></div>
          </div>
        </div>
        <div class="chat-main">
          <div class="chat-header"><strong>${salon.salonName} (${salon.userName} 원장)</strong></div>
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
