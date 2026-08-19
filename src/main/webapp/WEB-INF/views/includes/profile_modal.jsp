<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- 마이페이지를 대체하는 "내 정보" 모달 (점주/관리자 공용). 일반사용자의 info_modal.jsp와 같은 구조 —
     연락처/비밀번호 버튼 중 하나만 펼쳐지는 아코디언. 열릴 때 whoami로 직접 불러오므로 페이지가 user 모델을
     안 채워도 된다. 포함하는 페이지는 아래가 필요함
     1) id="openProfileModalBtn" 트리거 엘리먼트
     2) <jsp:param name="roleLabel" value="점주"/> 형태로 배지 텍스트 전달 --%>
<div class="modal-overlay" id="profileModal">
  <div class="modal-box" style="max-width:560px;">
    <div class="modal-header">
      <h3 style="font-size: 18px;"><i class="fas fa-user" style="margin-right:8px; color:var(--accent);"></i>내 정보</h3>
      <button type="button" class="modal-close" id="closeProfileModalBtn"><i class="fas fa-times"></i></button>
    </div>

    <div style="display:flex; align-items:center; gap:18px; margin-bottom:22px;">
      <div style="position:relative; flex-shrink:0;">
        <div class="user-avatar-sm" id="profileAvatarPreview" style="width:64px; height:64px; font-size:22px;">&nbsp;</div>
        <label for="profileImageInput" style="position:absolute; bottom:-2px; right:-2px; width:24px; height:24px; border-radius:50%; background:var(--accent); color:#fff; display:flex; align-items:center; justify-content:center; font-size:11px; cursor:pointer; border:2px solid var(--white);">
          <i class="fas fa-camera"></i>
        </label>
        <input type="file" id="profileImageInput" accept="image/jpeg,image/png,image/gif,image/webp" style="display:none;">
      </div>
      <div>
        <div style="font-weight:800; font-size:16px;"><span id="profileDisplayName">&nbsp;</span> <span class="tag" style="margin-left:6px;">${param.roleLabel}</span></div>
        <div style="font-size:14px; color:var(--text-sub); margin-top:4px;" id="profileDisplayEmail">&nbsp;</div>
        <div style="font-size:13.5px; color:var(--text-sub); margin-top:2px;">가입일 <span id="profileDisplayCreatedAt">&nbsp;</span></div>
      </div>
    </div>
    <p id="profilePhotoError" class="error-text" style="display:none; margin:-10px 0 14px;"></p>

    <div style="display:flex; gap:8px;">
      <button type="button" class="btn-modern btn-outline profile-section-btn" data-section="phone" style="flex:1;"><i class="fas fa-phone" style="margin-right:6px;"></i>연락처</button>
      <button type="button" class="btn-modern btn-outline profile-section-btn" data-section="password" style="flex:1;"><i class="fas fa-shield-alt" style="margin-right:6px;"></i>비밀번호</button>
    </div>

    <!-- 연락처 변경 섹션 -->
    <form id="profileInfoForm" class="profile-section" data-section="phone" style="display:none; margin-top:18px; padding-top:18px; border-top:1px solid var(--border);">
      <label style="display:block; font-size:13px; font-weight:700; color:var(--text-sub); margin-bottom:8px;">이름</label>
      <input type="text" name="userName" id="profileUserName" class="modern-input" required>
      <label style="display:block; font-size:13px; font-weight:700; color:var(--text-sub); margin:14px 0 8px;">전화번호</label>
      <input type="text" name="phoneNumber" id="profilePhoneNumber" class="modern-input"
             placeholder="010-1234-5678" pattern="[0-9-]{9,13}" title="숫자와 하이픈(-)만 입력해주세요." required>
      <p id="profileInfoError" class="error-text" style="display:none; margin-top:10px;"></p>
      <p id="profileInfoSuccess" class="success-text" style="display:none; margin-top:10px;">저장되었습니다.</p>
      <button type="submit" class="btn-modern btn-primary" style="width:100%; margin-top:16px;">연락처 저장</button>
    </form>

    <!-- 비밀번호 변경 섹션 -->
    <form id="profilePasswordForm" class="profile-section" data-section="password" style="display:none; margin-top:18px; padding-top:18px; border-top:1px solid var(--border);">
      <label style="display:block; font-size:13px; font-weight:700; color:var(--text-sub); margin-bottom:8px;">현재 비밀번호</label>
      <input type="password" name="currentPassword" class="modern-input">
      <label style="display:block; font-size:13px; font-weight:700; color:var(--text-sub); margin:14px 0 8px;">새 비밀번호</label>
      <input type="password" name="newPassword" class="modern-input" placeholder="8자리 이상">
      <label style="display:block; font-size:13px; font-weight:700; color:var(--text-sub); margin:14px 0 8px;">새 비밀번호 확인</label>
      <input type="password" name="confirmPassword" class="modern-input">
      <p id="profilePasswordSuccess" class="success-text" style="display:none; margin-top:10px;">비밀번호가 변경되었습니다.</p>
      <button type="submit" class="btn-modern btn-primary" style="width:100%; margin-top:16px;">비밀번호 변경</button>
    </form>
  </div>
</div>

<script>
  (function () {
    var modal = document.getElementById('profileModal');
    var trigger = document.getElementById('openProfileModalBtn');
    var avatar = document.getElementById('profileAvatarPreview');
    var displayName = document.getElementById('profileDisplayName');
    var displayEmail = document.getElementById('profileDisplayEmail');
    var displayCreatedAt = document.getElementById('profileDisplayCreatedAt');
    var photoInput = document.getElementById('profileImageInput');
    var photoError = document.getElementById('profilePhotoError');

    function setAvatar(url, initial) {
      if (url) {
        avatar.style.backgroundImage = "url('" + url + "')";
        avatar.style.backgroundSize = 'cover';
        avatar.style.backgroundPosition = 'center';
        avatar.textContent = '';
      } else if (initial) {
        avatar.style.backgroundImage = '';
        avatar.textContent = initial;
      }
    }

    var infoForm = document.getElementById('profileInfoForm');
    var infoError = document.getElementById('profileInfoError');
    var infoSuccess = document.getElementById('profileInfoSuccess');
    var passwordForm = document.getElementById('profilePasswordForm');
    var passwordSuccess = document.getElementById('profilePasswordSuccess');

    // 버튼 2개 중 하나만 섹션이 열린다 — 같은 걸 다시 누르면 닫힘
    var sectionButtons = document.querySelectorAll('.profile-section-btn');
    var sections = document.querySelectorAll('.profile-section');
    function showSection(key) {
      sections.forEach(function (el) { el.style.display = (el.dataset.section === key) ? 'block' : 'none'; });
      sectionButtons.forEach(function (btn) {
        var isActive = btn.dataset.section === key;
        btn.classList.toggle('btn-primary', isActive);
        btn.classList.toggle('btn-outline', !isActive);
      });
    }
    sectionButtons.forEach(function (btn) {
      btn.addEventListener('click', function () {
        var key = btn.dataset.section;
        var alreadyOpen = Array.prototype.some.call(sections, function (el) {
          return el.dataset.section === key && el.style.display === 'block';
        });
        showSection(alreadyOpen ? null : key);
      });
    });

    function openModal(e) {
      e.preventDefault();
      showSection(null);
      infoError.style.display = 'none';
      infoSuccess.style.display = 'none';
      photoError.style.display = 'none';
      passwordSuccess.style.display = 'none';
      modal.classList.add('active');
      fetch('<c:url value="/common/mypage/whoami"/>')
        .then(function (res) { return res.json(); })
        .then(function (data) {
          displayName.textContent = data.userName;
          displayEmail.textContent = data.email;
          displayCreatedAt.textContent = data.createdAt ? data.createdAt.substring(0, 10) : '-';
          setAvatar(data.profileImageUrl, data.userName ? data.userName.charAt(0) : '?');
          document.getElementById('profileUserName').value = data.userName;
          document.getElementById('profilePhoneNumber').value = data.phoneNumber || '';
        }).catch(function () {});
    }
    function closeModal() {
      modal.classList.remove('active');
      passwordForm.reset();
      passwordForm.querySelectorAll('.error-text').forEach(function (el) { el.remove(); });
      passwordForm.querySelectorAll('.input-error').forEach(function (el) { el.classList.remove('input-error'); });
    }

    if (trigger) trigger.addEventListener('click', openModal);
    document.getElementById('closeProfileModalBtn').addEventListener('click', closeModal);
    modal.addEventListener('click', function (e) { if (e.target === modal) closeModal(); });

    photoInput.addEventListener('change', function () {
      var file = photoInput.files[0];
      if (!file) return;
      photoError.style.display = 'none';
      var data = new FormData();
      data.append('userName', document.getElementById('profileUserName').value);
      data.append('phoneNumber', document.getElementById('profilePhoneNumber').value);
      data.append('profileImage', file);
      fetch('<c:url value="/common/mypage/info"/>', { method: 'POST', body: data })
        .then(function (res) { return res.json(); })
        .then(function (result) {
          if (result.success) {
            setAvatar(result.profileImageUrl, null);
          } else {
            photoError.textContent = result.message || '사진 저장에 실패했습니다.';
            photoError.style.display = 'block';
          }
        }).catch(function () {
          photoError.textContent = '사진 저장 중 오류가 발생했습니다.';
          photoError.style.display = 'block';
        });
    });

    infoForm.addEventListener('submit', function (e) {
      e.preventDefault();
      infoError.style.display = 'none';
      infoSuccess.style.display = 'none';
      fetch('<c:url value="/common/mypage/info"/>', { method: 'POST', body: new FormData(infoForm) })
        .then(function (res) { return res.json(); })
        .then(function (data) {
          if (data.success) {
            infoSuccess.style.display = 'block';
            displayName.textContent = document.getElementById('profileUserName').value;
          } else {
            infoError.textContent = data.message || '저장에 실패했습니다.';
            infoError.style.display = 'block';
          }
        }).catch(function () {
          infoError.textContent = '저장 중 오류가 발생했습니다.';
          infoError.style.display = 'block';
        });
    });

    passwordForm.addEventListener('submit', function (e) {
      e.preventDefault();
      passwordForm.querySelectorAll('.error-text').forEach(function (el) { el.remove(); });
      passwordForm.querySelectorAll('.input-error').forEach(function (el) { el.classList.remove('input-error'); });
      passwordSuccess.style.display = 'none';
      fetch('<c:url value="/common/mypage/password"/>', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams(new FormData(passwordForm))
      }).then(function (res) { return res.json(); })
        .then(function (data) {
          if (data.success) {
            passwordForm.reset();
            passwordSuccess.style.display = 'block';
            return;
          }
          Object.keys(data.errors).forEach(function (field) {
            var input = passwordForm.querySelector('[name="' + field + '"]');
            if (!input) return;
            input.classList.add('input-error');
            var msg = document.createElement('small');
            msg.className = 'error-text';
            msg.textContent = data.errors[field];
            input.insertAdjacentElement('afterend', msg);
          });
        }).catch(function () {
          alert('비밀번호 변경 중 오류가 발생했습니다.');
        });
    });
  })();
</script>
