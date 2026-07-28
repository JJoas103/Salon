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
</head>
<body>
  <!-- 사이드바 -->
  <jsp:include page="../includes/sidebar_common.jsp">
      <jsp:param name="menu" value="mypage" />
  </jsp:include>

  <div class="app-container">
    <main class="app-content">
      <c:if test="${param.passwordChanged == 'true'}">
        <p class="success-text" style="margin-bottom:20px; font-size:14px;">비밀번호가 변경되었습니다.</p>
      </c:if>
      <div class="profile-hero">
        <div class="profile-avatar-lg">${fn:substring(user.userName,0,1)}</div>
        <div>
          <h2 style="margin-bottom: 6px; font-size: 24px;">${user.userName} <span style="font-size:14px; color:var(--accent); font-weight:700; margin-left:8px;">VIP 등급</span></h2>
          <p style="font-size: 14px; color: var(--text-sub);">등록 이메일: ${user.email} | 가입일: ${user.createdAt}</p>
        </div>
      </div>
      <div class="stat-grid">
        <div class="stat-card"><span style="font-size: 13px; color: var(--text-sub); display:block; margin-bottom:8px;">누적 이용 건수</span><strong style="font-size: 26px;">${reservationCount} 회</strong></div>
        <div class="stat-card"><span style="font-size: 13px; color: var(--text-sub); display:block; margin-bottom:8px;">보유 활성 쿠폰</span><span class="tag">준비중</span></div>
        <div class="stat-card"><span style="font-size: 13px; color: var(--text-sub); display:block; margin-bottom:8px;">적립 적립금</span><span class="tag">준비중</span></div>
      </div>
      <div class="menu-group">
        <a href="#" class="menu-item-modern" style="opacity:0.5; pointer-events:none;"><span><i class="fas fa-credit-card" style="margin-right:12px;"></i> 결제 수단 및 카드 관리</span><span class="tag">준비중</span></a>
        <a href="#" class="menu-item-modern" style="opacity:0.5; pointer-events:none;"><span><i class="fas fa-bell" style="margin-right:12px;"></i> 알림 설정</span><span class="tag">준비중</span></a>
        <a href="#" id="openPasswordModalBtn" class="menu-item-modern"><span><i class="fas fa-shield-alt" style="margin-right:12px;"></i> 보안 및 비밀번호 변경</span><i class="fas fa-chevron-right"></i></a>
      </div>
    </main>
  </div>

  <!-- 비밀번호 변경 모달 -->
  <div class="modal-overlay" id="passwordModal">
    <div class="modal-box">
      <div class="modal-header">
        <h3 style="font-size: 18px;"><i class="fas fa-shield-alt" style="margin-right:8px; color:var(--accent);"></i>비밀번호 변경</h3>
        <button type="button" class="modal-close" id="closePasswordModalBtn"><i class="fas fa-times"></i></button>
      </div>
      <form id="passwordForm">
        <div style="margin-bottom:16px;">
          <label style="display:block; font-size:13px; font-weight:700; color:var(--text-sub); margin-bottom:8px;">현재 비밀번호</label>
          <input type="password" name="currentPassword" class="modern-input">
        </div>
        <div style="margin-bottom:16px;">
          <label style="display:block; font-size:13px; font-weight:700; color:var(--text-sub); margin-bottom:8px;">새 비밀번호</label>
          <input type="password" name="newPassword" class="modern-input" placeholder="8자리 이상">
        </div>
        <div style="margin-bottom:16px;">
          <label style="display:block; font-size:13px; font-weight:700; color:var(--text-sub); margin-bottom:8px;">새 비밀번호 확인</label>
          <input type="password" name="confirmPassword" class="modern-input">
        </div>
        <button type="submit" class="btn-modern btn-primary" style="width:100%;">비밀번호 변경</button>
      </form>
    </div>
  </div>

  <script>
    (function () {
      const modal = document.getElementById('passwordModal');
      const form = document.getElementById('passwordForm');

      function openModal(e) {
        e.preventDefault();
        modal.classList.add('active');
      }
      function closeModal() {
        modal.classList.remove('active');
        form.reset();
        form.querySelectorAll('.error-text').forEach(function (el) { el.remove(); });
        form.querySelectorAll('.input-error').forEach(function (el) { el.classList.remove('input-error'); });
      }

      document.getElementById('openPasswordModalBtn').addEventListener('click', openModal);
      document.getElementById('closePasswordModalBtn').addEventListener('click', closeModal);
      modal.addEventListener('click', function (e) { if (e.target === modal) closeModal(); });

      form.addEventListener('submit', async function (e) {
        e.preventDefault();
        form.querySelectorAll('.error-text').forEach(function (el) { el.remove(); });
        form.querySelectorAll('.input-error').forEach(function (el) { el.classList.remove('input-error'); });

        try {
          const res = await fetch('<c:url value="/common/mypage/password"/>', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: new URLSearchParams(new FormData(form))
          });
          const data = await res.json();
          if (data.success) {
            location.href = '<c:url value="/common/mypage"/>?passwordChanged=true';
            return;
          }
          Object.keys(data.errors).forEach(function (field) {
            const input = form.querySelector('[name="' + field + '"]');
            if (!input) return;
            input.classList.add('input-error');
            const msg = document.createElement('small');
            msg.className = 'error-text';
            msg.textContent = data.errors[field];
            input.insertAdjacentElement('afterend', msg);
          });
        } catch (err) {
          alert('비밀번호 변경 중 오류가 발생했습니다.');
        }
      });
    })();
  </script>
</body>
</html>
