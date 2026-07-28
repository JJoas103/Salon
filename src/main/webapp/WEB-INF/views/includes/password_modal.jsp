<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- 비밀번호 변경 모달 (역할 공용) — 포함하는 페이지는 아래 두 가지가 필요함
     1) id="openPasswordModalBtn" 트리거 엘리먼트
     2) <jsp:param name="mypageUrl" value="/common/mypage"/> 형태로 성공 후 돌아갈 마이페이지 경로 전달 --%>
<c:url var="mypageUrl" value="${param.mypageUrl}" />

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
          location.href = '${mypageUrl}?passwordChanged=true';
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
