<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | 1대1 면담</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="/resources/css/common.css">
  <link rel="stylesheet" href="/resources/css/owner.css">
</head>
<body>
 <body class="store-page">
  <jsp:include page="../includes/sidebar_owner.jsp">
      <jsp:param name="menu" value="chat" />
  </jsp:include>
  <div class="app-container">
    <header class="app-header">
      <div style="font-size: 18px; font-weight: 700;">1대1 면담</div>
      <div class="user-badge"><span>강남본점 점주님</span><div class="user-avatar-sm" style="width:32px; height:32px; border-radius:50%; background:#E0E0E0; display:inline-flex; align-items:center; justify-content:center; margin-left:10px;">점</div></div>
    </header>
    <main class="app-content">
      <div class="chat-layout">
        <div class="chat-list">
          <div class="chat-item active"><strong>김철수 고객님</strong><p style="font-size: 12px; color: var(--text-sub);">내일 예약 시간 변경 가능할까요?</p></div>
          <div class="chat-item"><strong>이영희 고객님</strong><p style="font-size: 12px; color: var(--text-sub);">감사합니다!</p></div>
        </div>
        <div class="chat-window">
          <div style="padding: 15px 20px; border-bottom: 1px solid var(--border); font-weight: 700;">김철수 고객님과의 대화</div>
          <div class="chat-body">
            <div style="align-self: flex-start; background: #fff; padding: 10px 15px; border-radius: 10px; border: 1px solid var(--border); max-width: 70%; font-size: 14px;">안녕하세요, 내일 오후 2시 예약을 4시로 변경할 수 있을까요?</div>
            <div style="align-self: flex-end; background: var(--primary); color: #fff; padding: 10px 15px; border-radius: 10px; max-width: 70%; font-size: 14px;">잠시만요, 스케줄 확인해보겠습니다.</div>
          </div>
          <div class="chat-footer"><input type="text" class="modern-input" placeholder="메시지를 입력하세요..."><button class="btn-modern btn-primary">전송</button></div>
        </div>
      </div>
    </main>
  </div>
</body>
</html>
