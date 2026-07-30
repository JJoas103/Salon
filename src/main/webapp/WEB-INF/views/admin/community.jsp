<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | 커뮤니티 관리</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="/resources/css/common.css">
  <link rel="stylesheet" href="/resources/css/admin.css">
</head>
<body>
  <jsp:include page="../includes/sidebar_admin.jsp">
      <jsp:param name="menu" value="community" />
  </jsp:include>
  <div class="app-container">
    <header class="app-header">
      <div style="font-weight: 700; font-size: 18px;">커뮤니티 관리</div>
      <div id="openProfileModalBtn" style="display: flex; align-items: center; gap: 10px; cursor: pointer;">
        <span style="font-size: 14px; font-weight: 600;">${user.userName} 관리자님</span>
        <div style="width: 32px; height: 32px; border-radius: 50%; background: #333; color: #fff; display: flex; align-items: center; justify-content: center; font-size: 12px;">관</div>
      </div>
    </header>
    <main class="app-content">

      <!-- 더미데이터 화면입니다. 실제 신고 접수/처리 기능은 팀 논의 후 별도 구현 예정 -->
      <div class="section-switch" id="sectionSwitch">
        <button class="section-btn on" data-section="community"><i class="fas fa-list"></i> 커뮤니티</button>
        <button class="section-btn" data-section="reports"><i class="fas fa-flag"></i> 신고접수 <span class="cnt">4</span></button>
      </div>

      <!-- ========== 커뮤니티: 전체 게시글 ========== -->
      <div class="section-view on" id="view-community">
        <div class="cat-tabs">
          <div class="cat-tab on">전체</div>
          <div class="cat-tab">스타일 후기</div>
          <div class="cat-tab">질문</div>
          <div class="cat-tab">자유</div>
          <div class="cat-tab">공지</div>
        </div>
        <div class="modern-card" style="padding: 0; overflow: hidden;">
          <table class="modern-table">
            <thead><tr><th>제목</th><th>작성자</th><th>조회</th><th>좋아요</th><th>작성일</th><th>관리</th></tr></thead>
            <tbody>
              <tr>
                <td><strong>파마 후 며칠 지나야 드라이 가능한가요?</strong><br><span class="tag">질문</span></td>
                <td>이수민</td><td>128</td><td>7</td><td>2026-07-28</td>
                <td><button class="btn-modern btn-outline">보기</button> <button class="btn-modern btn-danger">삭제</button></td>
              </tr>
              <tr>
                <td><strong>라움헤어 강남점 다녀온 후기 (사진多)</strong><br><span class="tag">스타일 후기</span></td>
                <td>박지현</td><td>342</td><td>28</td><td>2026-07-27</td>
                <td><button class="btn-modern btn-outline">보기</button> <button class="btn-modern btn-danger">삭제</button></td>
              </tr>
              <tr>
                <td><strong>저렴한 후기 대행 해드립니다 (문의)</strong><br><span class="tag">자유</span></td>
                <td>user_23</td><td>51</td><td>0</td><td>2026-07-28</td>
                <td><button class="btn-modern btn-outline">보기</button> <button class="btn-modern btn-danger">삭제</button></td>
              </tr>
              <tr>
                <td><strong>여름철 두피 관리 꿀팁 공유해요</strong><br><span class="tag">자유</span></td>
                <td>김민재</td><td>96</td><td>14</td><td>2026-07-26</td>
                <td><button class="btn-modern btn-outline">보기</button> <button class="btn-modern btn-danger">삭제</button></td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- ========== 신고접수 ========== -->
      <div class="section-view" id="view-reports">
        <div class="subtab-row" id="reportSubtabs">
          <button class="subtab on" data-report="post"><i class="fas fa-file-lines"></i> 게시글 신고 <span class="cnt">3</span></button>
          <button class="subtab" data-report="user"><i class="fas fa-user"></i> 유저 신고 <span class="cnt">1</span></button>
        </div>

        <div class="report-view on" id="report-post">
          <div class="modern-card" style="padding: 0; overflow: hidden;">
            <table class="modern-table">
              <thead><tr><th>신고된 게시글</th><th>사유</th><th>신고자</th><th>신고일</th><th>상태</th><th>관리</th></tr></thead>
              <tbody>
                <tr>
                  <td>저렴한 후기 대행 해드립니다 (문의)</td>
                  <td><span class="reason-chip">스팸/광고</span></td><td>user_07</td><td>2026-07-28</td>
                  <td><span class="status-tag" style="background: #fff3bf; color: #f08c00;">대기중</span></td>
                  <td><button class="btn-modern btn-outline">게시글 확인</button> <button class="btn-modern btn-danger">삭제</button></td>
                </tr>
                <tr>
                  <td>환불 관련 문의합니다</td>
                  <td><span class="reason-chip">욕설/비방</span></td><td>user_18</td><td>2026-07-27</td>
                  <td><span class="status-tag" style="background: #fff3bf; color: #f08c00;">대기중</span></td>
                  <td><button class="btn-modern btn-outline">게시글 확인</button> <button class="btn-modern btn-danger">삭제</button></td>
                </tr>
                <tr>
                  <td>여기 정말 별로였어요...</td>
                  <td><span class="reason-chip">허위사실</span></td><td>user_31</td><td>2026-07-25</td>
                  <td><span class="status-tag" style="background: #fff3bf; color: #f08c00;">대기중</span></td>
                  <td><button class="btn-modern btn-outline">게시글 확인</button> <button class="btn-modern btn-danger">삭제</button></td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <div class="report-view" id="report-user">
          <div class="modern-card" style="padding: 0; overflow: hidden;">
            <table class="modern-table">
              <thead><tr><th>신고된 유저</th><th>사유</th><th>신고자</th><th>신고일</th><th>상태</th><th>관리</th></tr></thead>
              <tbody>
                <tr>
                  <td>user_23</td>
                  <td><span class="reason-chip">도배/스팸</span></td><td>user_07 외 2명</td><td>2026-07-28</td>
                  <td><span class="status-tag" style="background: #fff3bf; color: #f08c00;">대기중</span></td>
                  <td><button class="btn-modern btn-outline">활동 확인</button> <button class="btn-modern btn-danger">정지</button></td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

    </main>
  </div>

  <jsp:include page="../includes/profile_modal.jsp">
      <jsp:param name="roleLabel" value="관리자" />
  </jsp:include>

  <script>
    (function () {
      document.getElementById('sectionSwitch').addEventListener('click', function (e) {
        var btn = e.target.closest('.section-btn');
        if (!btn) return;
        document.querySelectorAll('.section-btn').forEach(function (b) { b.classList.toggle('on', b === btn); });
        var target = btn.dataset.section;
        document.getElementById('view-community').classList.toggle('on', target === 'community');
        document.getElementById('view-reports').classList.toggle('on', target === 'reports');
      });

      document.getElementById('reportSubtabs').addEventListener('click', function (e) {
        var btn = e.target.closest('.subtab');
        if (!btn) return;
        document.querySelectorAll('.subtab').forEach(function (b) { b.classList.toggle('on', b === btn); });
        var target = btn.dataset.report;
        document.getElementById('report-post').classList.toggle('on', target === 'post');
        document.getElementById('report-user').classList.toggle('on', target === 'user');
      });

      document.querySelectorAll('.cat-tab').forEach(function (tab) {
        tab.addEventListener('click', function () {
          document.querySelectorAll('.cat-tab').forEach(function (t) { t.classList.remove('on'); });
          tab.classList.add('on');
        });
      });
    })();
  </script>
</body>
</html>
