<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | 직원관리</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="/resources/css/common.css">
  <link rel="stylesheet" href="/resources/css/owner.css">
</head>
<body>
  <body class="store-page">
  <jsp:include page="../includes/sidebar_owner.jsp">
      <jsp:param name="menu" value="staff" />
  </jsp:include>
  <div class="app-container">
    <header class="app-header">
      <div style="font-size: 18px; font-weight: 700;">직원관리</div>
      <div class="user-badge"><span>강남본점 점주님</span><div class="user-avatar-sm" style="width:32px; height:32px; font-size:12px; margin-left:10px;">점</div></div>
    </header>
    <main class="app-content">
      <div class="modern-card">
        <div class="flex-between" style="margin-bottom: 20px;">
          <h3>디자이너 목록</h3>
          <button class="btn-modern btn-primary"><i class="fas fa-plus"></i> 디자이너 등록</button>
        </div>
        <div class="menu-grid">
          <div class="menu-card">
            <div style="display: flex; gap: 15px; align-items: center;">
              <div class="user-avatar-sm">사</div>
              <div><h4 style="margin-bottom: 4px;">사라 원장</h4><p class="tag">매주 월요일 휴무</p></div>
            </div>
            <div style="margin-top: 15px; border-top: 1px solid var(--border); padding-top: 15px;">
              <p style="font-size: 13px; color: var(--text-sub); margin-bottom: 10px;">스케줄: 10:00 ~ 19:00</p>
              <button class="btn-modern btn-outline" style="width: 100%;">스케줄 설정</button>
            </div>
          </div>
          <div class="menu-card">
            <div style="display: flex; gap: 15px; align-items: center;">
              <div class="user-avatar-sm">레</div>
              <div><h4 style="margin-bottom: 4px;">레오 실장</h4><p class="tag">매주 수요일 휴무</p></div>
            </div>
            <div style="margin-top: 15px; border-top: 1px solid var(--border); padding-top: 15px;">
              <p style="font-size: 13px; color: var(--text-sub); margin-bottom: 10px;">스케줄: 11:00 ~ 21:00</p>
              <button class="btn-modern btn-outline" style="width: 100%;">스케줄 설정</button>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</body>
</html>
