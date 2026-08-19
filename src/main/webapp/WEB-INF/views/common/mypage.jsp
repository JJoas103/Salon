<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | 마이페이지</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="/resources/css/common.css">
  <link rel="stylesheet" href="/resources/css/user.css">
  <link rel="stylesheet" href="/resources/css/auth.css">
</head>
<body>
  <!-- 사이드바 -->
  <jsp:include page="../includes/sidebar_common.jsp">
      <jsp:param name="menu" value="mypage" />
  </jsp:include>

  <div class="app-container">
    <main class="app-content">
      <div class="profile-hero">
        <div class="profile-avatar-lg" id="profileHeroAvatar" style="${not empty user.profileImageUrl ? 'background-image:url(\''.concat(user.profileImageUrl).concat('\'); background-size:cover; background-position:center;') : ''}">
          <c:if test="${empty user.profileImageUrl}">${fn:substring(user.userName,0,1)}</c:if>
        </div>
        <div>
          <h2 style="margin-bottom: 8px; font-size: 24px;">${user.userName}</h2>
          <p style="font-size: 14px; color: var(--text-sub); margin-bottom:12px;">등록 이메일: ${user.email} | 가입일: ${user.createdAt}</p>
          <button type="button" id="openGradeModalBtn" class="achievement-badge-btn">
            <span class="achievement-badge-icon"><i class="fas fa-medal"></i></span>
            <span class="achievement-badge-text">
              <strong>나의 이용내역</strong>
              <small>매장별 등급 확인하기</small>
            </span>
            <i class="fas fa-chevron-right" style="font-size:11px; opacity:.5;"></i>
          </button>
        </div>
      </div>
      <div class="stat-grid stat-grid-five">
        <div class="stat-card"><span style="font-size: 13px; color: var(--text-sub); display:block; margin-bottom:8px;">누적 이용 건수</span><strong style="font-size: 26px;">${reservationCount} 회</strong></div>
        <a class="stat-card stat-card-link" href="<c:url value='/common/coupons'/>">
          <span style="font-size:13px;color:var(--text-sub);display:block;margin-bottom:8px;">보유 활성 쿠폰</span>
          <strong style="font-size:26px;">${couponCount}장</strong>
          <small>쿠폰함 열기 <i class="fas fa-chevron-right"></i></small>
        </a>
        <a class="stat-card stat-card-link" href="<c:url value='/common/points'/>">
          <span style="font-size:13px;color:var(--text-sub);display:block;margin-bottom:8px;">보유 적립금</span>
          <strong style="font-size:26px;"><fmt:formatNumber value="${pointBalance}" pattern="#,##0"/>원</strong>
          <small>적립금 내역 보기 <i class="fas fa-chevron-right"></i></small>
        </a>
        <a class="stat-card stat-card-link" href="<c:url value='/common/wishlists'/>">
          <span style="font-size:13px;color:var(--text-sub);display:block;margin-bottom:8px;">찜 목록</span>
          <strong style="font-size:26px;">${wishlistCount}개</strong>
          <small>저장한 헤어샵 보기 <i class="fas fa-chevron-right"></i></small>
        </a>
        <a class="stat-card stat-card-link" href="<c:url value='/common/my-reviews'/>">
          <span style="font-size:13px;color:var(--text-sub);display:block;margin-bottom:8px;">작성한 리뷰</span>
          <strong style="font-size:26px;">${reviewCount}개</strong>
          <small>내가 작성한 리뷰 보기 <i class="fas fa-chevron-right"></i></small>
        </a>
      </div>
    </main>
  </div>

  <!-- 매장별 등급 모달 — 등급은 매장마다 점주가 다른 별개 사업자라 매장별로 따로 보여준다 -->
  <div class="modal-overlay" id="gradeModal">
    <div class="modal-box" style="max-width:460px;">
      <div class="modal-header">
        <div>
          <h3 style="font-size: 17px; margin-bottom:5px;">내 매장별 등급</h3>
          <p style="font-size:12.3px; color:var(--text-sub); margin:0;">이용한 매장마다 방문 횟수에 따라 등급이 따로 매겨집니다.</p>
        </div>
        <button type="button" class="modal-close" id="closeGradeModalBtn"><i class="fas fa-times"></i></button>
      </div>
      <c:choose>
        <c:when test="${empty salonGrades}">
          <p style="font-size:13px; color:var(--text-sub); padding:0 0 8px;">아직 완료된 예약이 없습니다. 예약을 완료하면 매장별 등급이 여기에 표시됩니다.</p>
        </c:when>
        <c:otherwise>
          <div style="display:flex; flex-direction:column; gap:10px;">
            <c:forEach var="sg" items="${salonGrades}">
              <div style="display:flex; align-items:center; gap:13px; padding:13px 15px; border:1px solid var(--border); border-radius:var(--radius-md);">
                <div style="width:40px; height:40px; border-radius:10px; background:var(--bg-sub); display:flex; align-items:center; justify-content:center; font-size:15px; color:var(--text-sub); flex-shrink:0;"><i class="fas fa-scissors"></i></div>
                <div style="flex:1; min-width:0;">
                  <div style="font-size:13.8px; font-weight:700; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;"><c:out value="${sg.salonName}"/></div>
                  <div style="font-size:11.5px; color:var(--text-sub); margin-top:2px;">완료 예약 ${sg.completedCount}회</div>
                </div>
                <c:set var="tierColor" value="${sg.grade == 'VIP' ? '#B8860E' : (sg.grade == '단골' ? 'var(--accent)' : '#3F7D4C')}" />
                <span style="font-size:11px; font-weight:800; padding:5px 11px; border-radius:var(--radius-full); flex-shrink:0; color:${tierColor}; background:${sg.grade == 'VIP' ? 'rgba(184,134,14,.1)' : (sg.grade == '단골' ? 'var(--accent-soft)' : 'rgba(63,125,76,.1)')};">${sg.grade}</span>
              </div>
            </c:forEach>
          </div>
          <p style="font-size:11.5px; color:var(--text-sub); margin:16px 0 0; padding-top:14px; border-top:1px solid var(--border);">전체 누적 ${reservationCount}회는 위 통계와 별개로, 등급은 매장마다 따로 계산됩니다.</p>
        </c:otherwise>
      </c:choose>
    </div>
  </div>

  <script>
    (function () {
      var modal = document.getElementById('gradeModal');
      document.getElementById('openGradeModalBtn').addEventListener('click', function () {
        modal.classList.add('active');
      });
      document.getElementById('closeGradeModalBtn').addEventListener('click', function () {
        modal.classList.remove('active');
      });
      modal.addEventListener('click', function (e) {
        if (e.target === modal) modal.classList.remove('active');
      });
    })();
  </script>
</body>
</html>
