<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | 광고와 배너관리</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="/resources/css/common.css">
  <link rel="stylesheet" href="/resources/css/admin.css">
</head>
<body>
  <jsp:include page="../includes/sidebar_admin.jsp">
      <jsp:param name="menu" value="banners" />
  </jsp:include>
  <div class="app-container">
    <header class="app-header">
      <div style="font-weight: 700; font-size: 18px;">광고와 배너관리</div>
      <div id="openProfileModalBtn" style="display: flex; align-items: center; gap: 10px; cursor: pointer;">
        <span style="font-size: 14px; font-weight: 600;">${user.userName} 관리자님</span>
        <div style="width: 32px; height: 32px; border-radius: 50%; background: #333; color: #fff; display: flex; align-items: center; justify-content: center; font-size: 12px;">관</div>
      </div>
    </header>
    <main class="app-content">
      <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px;">
        <div class="modern-card">
          <h3>메인 배너 설정</h3>
          <p style="font-size: 13px; color: var(--text-sub); margin-bottom: 20px;">사용자 홈 화면 상단에 노출되는 배너입니다.</p>
          <div style="border: 1px solid var(--border); padding: 15px; border-radius: var(--radius-md); margin-bottom: 15px;">
            <div class="banner-preview">배너 이미지 1 (1200x400)</div>
            <div style="display: flex; justify-content: space-between; align-items: center;">
              <div><h4 style="font-size: 14px;">여름 맞이 전품목 20% 할인</h4><p style="font-size: 12px; color: var(--text-light);">노출기간: 2026.07.01 ~ 2026.08.31</p></div>
              <input type="checkbox" checked>
            </div>
          </div>
          <button class="btn-modern btn-primary" style="width: 100%;">배너 추가하기</button>
        </div>
        <div class="modern-card">
          <h3>추천/노출 매장 관리</h3>
          <p style="font-size: 13px; color: var(--text-sub); margin-bottom: 20px;">검색 결과 상단에 노출될 프리미엄 매장을 관리합니다.</p>
          <div style="padding: 12px; background: var(--bg-sub); border-radius: var(--radius-md); display: flex; justify-content: space-between; margin-bottom: 10px;">
            <span>HAIR RESERVE 강남본점</span><span style="color: var(--accent); font-weight: 700;">광고중</span>
          </div>
          <div style="padding: 12px; background: var(--bg-sub); border-radius: var(--radius-md); display: flex; justify-content: space-between;">
            <span>HAIR RESERVE 홍대점</span><span style="color: var(--accent); font-weight: 700;">광고중</span>
          </div>
        </div>
      </div>
    </main>
  </div>

  <jsp:include page="../includes/profile_modal.jsp">
      <jsp:param name="roleLabel" value="관리자" />
  </jsp:include>
</body>
</html>
