<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | 커뮤니티 제재</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="/resources/css/common.css">
  <link rel="stylesheet" href="/resources/css/admin.css">
</head>
<body>
  <aside class="sidebar">
    <div class="sidebar-brand"><i class="fas fa-shield-alt"></i> ADMIN PANEL</div>
    <ul class="sidebar-menu">
      <li class="sidebar-item"><a href="/admin/salons"><i class="fas fa-store"></i> 미용실관리</a></li>
      <li class="sidebar-item active"><a href="/admin/community"><i class="fas fa-user-shield"></i> 커뮤니티 제재</a></li>
      <li class="sidebar-item"><a href="/admin/members"><i class="fas fa-users"></i> 회원관리</a></li>
      <li class="sidebar-item"><a href="/admin/banners"><i class="fas fa-ad"></i> 광고와 배너관리</a></li>
    </ul>
  </aside>
  <div class="app-container">
    <header class="app-header">
      <div style="font-weight: 700; font-size: 18px;">커뮤니티 제재</div>
      <div style="display: flex; align-items: center; gap: 10px;">
        <span style="font-size: 14px; font-weight: 600;">최고관리자</span>
        <div style="width: 32px; height: 32px; border-radius: 50%; background: #333; color: #fff; display: flex; align-items: center; justify-content: center; font-size: 12px;">A</div>
      </div>
    </header>
    <main class="app-content">
      <div class="modern-card">
        <h3>신고된 게시글 및 유저</h3>
        <div style="margin-top: 20px;">
          <table class="modern-table">
            <thead><tr><th>유형</th><th>대상(ID/글)</th><th>사유</th><th>신고자</th><th>상태</th><th>조치</th></tr></thead>
            <tbody>
              <tr>
                <td>게시글</td><td>"여기 서비스 진짜 별로..."</td><td>허위사실 유포</td><td>강남본점</td><td><span class="status-tag" style="background: #fff3bf; color: #f08c00;">검토중</span></td>
                <td><button class="btn-modern btn-danger">삭제</button> <button class="btn-modern btn-outline">반려</button></td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </main>
  </div>
</body>
</html>
