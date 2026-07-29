<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%-- 마이페이지를 대체하는 "내 정보 + 비밀번호 변경" 모달 (점주/관리자 공용) — 포함하는 페이지는 아래가 필요함
     1) ${user} 모델
     2) id="openProfileModalBtn" 트리거 엘리먼트
     3) <jsp:param name="roleLabel" value="점주"/> 형태로 배지 텍스트 전달 --%>
<div class="modal-overlay" id="profileModal">
  <div class="modal-box">
    <div class="modal-header">
      <h3 style="font-size: 18px;"><i class="fas fa-user" style="margin-right:8px; color:var(--accent);"></i>내 정보</h3>
      <button type="button" class="modal-close" id="closeProfileModalBtn"><i class="fas fa-times"></i></button>
    </div>

    <div style="display:flex; align-items:center; gap:16px; margin-bottom:18px;">
      <div class="user-avatar-sm" style="width:56px; height:56px; font-size:20px;">${fn:substring(user.userName,0,1)}</div>
      <div>
        <div style="font-weight:800; font-size:16px;">${user.userName} <span class="tag" style="margin-left:6px;">${param.roleLabel}</span></div>
        <div style="font-size:12.5px; color:var(--text-sub); margin-top:4px;">${user.email}</div>
      </div>
    </div>
    <div style="font-size:13px; color:var(--text-sub); margin-bottom:20px; display:flex; flex-direction:column; gap:4px;">
      <span>연락처: ${user.phoneNumber}</span>
      <span>가입일: ${user.createdAt}</span>
    </div>

    <hr style="border:none; border-top:1px solid var(--border); margin-bottom:20px;">

    <h4 style="font-size:14px; margin-bottom:14px;">비밀번호 변경</h4>
    <form id="profilePasswordForm">
      <div style="margin-bottom:14px;">
        <label style="display:block; font-size:13px; font-weight:700; color:var(--text-sub); margin-bottom:8px;">현재 비밀번호</label>
        <input type="password" name="currentPassword" class="modern-input">
      </div>
      <div style="margin-bottom:14px;">
        <label style="display:block; font-size:13px; font-weight:700; color:var(--text-sub); margin-bottom:8px;">새 비밀번호</label>
        <input type="password" name="newPassword" class="modern-input" placeholder="8자리 이상">
      </div>
      <div style="margin-bottom:14px;">
        <label style="display:block; font-size:13px; font-weight:700; color:var(--text-sub); margin-bottom:8px;">새 비밀번호 확인</label>
        <input type="password" name="confirmPassword" class="modern-input">
      </div>
      <p id="profilePasswordSuccess" class="success-text" style="display:none;">비밀번호가 변경되었습니다.</p>
      <button type="submit" class="btn-modern btn-primary" style="width:100%;">비밀번호 변경</button>
    </form>
  </div>
</div>

<script>
  (function () {
    var modal = document.getElementById('profileModal');
    var form = document.getElementById('profilePasswordForm');
    var successMsg = document.getElementById('profilePasswordSuccess');
    var trigger = document.getElementById('openProfileModalBtn');

    function openModal(e) {
      e.preventDefault();
      modal.classList.add('active');
    }
    function closeModal() {
      modal.classList.remove('active');
      form.reset();
      successMsg.style.display = 'none';
      form.querySelectorAll('.error-text').forEach(function (el) { el.remove(); });
      form.querySelectorAll('.input-error').forEach(function (el) { el.classList.remove('input-error'); });
    }

    if (trigger) trigger.addEventListener('click', openModal);
    document.getElementById('closeProfileModalBtn').addEventListener('click', closeModal);
    modal.addEventListener('click', function (e) { if (e.target === modal) closeModal(); });

    form.addEventListener('submit', async function (e) {
      e.preventDefault();
      form.querySelectorAll('.error-text').forEach(function (el) { el.remove(); });
      form.querySelectorAll('.input-error').forEach(function (el) { el.classList.remove('input-error'); });
      successMsg.style.display = 'none';

      try {
        const res = await fetch('<c:url value="/common/mypage/password"/>', {
          method: 'POST',
          headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
          body: new URLSearchParams(new FormData(form))
        });
        const data = await res.json();
        if (data.success) {
          form.reset();
          successMsg.style.display = 'block';
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
