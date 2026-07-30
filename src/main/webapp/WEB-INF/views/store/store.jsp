<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | 매장정보 관리</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="../css/common.css">
  <link rel="stylesheet" href="../css/owner.css">
</head>
<body class="store-page">
  <aside class="sidebar">
    <div class="sidebar-brand"><i class="fas fa-cut"></i> HAIR RESERVE</div>
    <ul class="sidebar-menu">
      <li class="sidebar-item"><a href="reservations.html"><i class="fas fa-calendar-check"></i> 예약현황관리</a></li>
      <li class="sidebar-item"><a href="staff.html"><i class="fas fa-users"></i> 직원관리</a></li>
      <li class="sidebar-item active"><a href="store.html"><i class="fas fa-store"></i> 매장정보 관리</a></li>
      <li class="sidebar-item"><a href="chat.html"><i class="fas fa-comments"></i> 1대1 면담</a></li>
      <li class="sidebar-item"><a href="events.html"><i class="fas fa-bullhorn"></i> 이벤트/공지사항</a></li>
    </ul>
  </aside>
  <div class="app-container">
    <header class="app-header">
      <div style="font-size: 18px; font-weight: 700;">매장정보 관리</div>
      <div class="user-badge"><span>강남본점 점주님</span><div class="user-avatar-sm" style="width:32px; height:32px; border-radius:50%; background:#E0E0E0; display:inline-flex; align-items:center; justify-content:center; margin-left:10px;">점</div></div>
    </header>
    <main class="app-content">
      <div class="modern-card">
        <h3 style="margin-bottom: 20px;">매장 기본 정보</h3>
        <label style="font-size: 13px; font-weight: 700; color: var(--text-sub);">매장 소개</label>
        <textarea class="modern-input" style="height: 100px; resize: none;">트렌디한 스타일과 최상의 서비스를 제공하는 HAIR RESERVE 강남본점입니다.</textarea>
        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
          <div><label style="font-size: 13px; font-weight: 700;">영업 시간</label><input type="text" class="modern-input" value="10:00 - 21:00"></div>
          <div><label style="font-size: 13px; font-weight: 700;">연락처</label><input type="text" class="modern-input" value="02-1234-5678"></div>
        </div>
        <button class="btn-modern btn-primary">정보 저장</button>
      </div>
      <div class="modern-card">
        <div style="display: flex; justify-content: space-between; margin-bottom: 20px;">
          <h3>시술 메뉴 관리</h3>
          <button class="btn-modern btn-outline"><i class="fas fa-plus"></i> 메뉴 추가</button>
        </div>
        <div class="menu-grid">
          <div class="menu-card">
            <h4 style="margin-bottom: 8px;">남성 디자인 컷</h4>
            <p style="color: var(--accent); font-weight: 700; margin-bottom: 12px;">25,000원</p>
            <div style="display: flex; gap: 5px;"><button class="btn-modern btn-outline" style="flex: 1;">수정</button><button class="btn-modern btn-danger"><i class="fas fa-trash"></i></button></div>
          </div>
        </div>
      </div>
    </main>
  </div>
</body>
</html>
