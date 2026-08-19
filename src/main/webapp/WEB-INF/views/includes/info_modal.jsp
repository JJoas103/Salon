<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%-- 일반사용자 "내 정보" 모달 (점주/관리자의 profile_modal.jsp에 대응하는 사용자용).
     사이드바에 포함되므로 페이지마다 user 모델을 채울 필요 없이, 열릴 때 /common/mypage/whoami 로 직접 불러온다.
     트리거는 sidebar_common.jsp의 "OO 고객님" 카드(id="openInfoModalBtn"). --%>
<div class="modal-overlay" id="infoModal">
  <div class="modal-box" style="max-width:560px;">
    <div class="modal-header">
      <h3 style="font-size: 18px;"><i class="fas fa-user" style="margin-right:8px; color:var(--accent);"></i>내 정보</h3>
      <button type="button" class="modal-close" id="closeInfoModalBtn"><i class="fas fa-times"></i></button>
    </div>

    <!-- 프로필 사진 -->
    <div style="display:flex; align-items:center; gap:18px; margin-bottom:22px;">
      <div style="position:relative; flex-shrink:0;">
        <div class="user-avatar-sm" id="infoAvatarPreview" style="width:64px; height:64px; font-size:22px;"></div>
        <label for="profileImageInput" style="position:absolute; bottom:-2px; right:-2px; width:24px; height:24px; border-radius:50%; background:var(--accent); color:#fff; display:flex; align-items:center; justify-content:center; font-size:11px; cursor:pointer; border:2px solid var(--white);">
          <i class="fas fa-camera"></i>
        </label>
        <input type="file" id="profileImageInput" accept="image/jpeg,image/png,image/gif,image/webp" style="display:none;">
      </div>
      <div>
        <div style="font-weight:800; font-size:16px;" id="infoDisplayName">&nbsp;</div>
        <div style="font-size:14px; color:var(--text-sub); margin-top:3px;" id="infoDisplayEmail">&nbsp;</div>
        <div style="font-size:13.5px; color:var(--text-sub); margin-top:2px;">가입일 <span id="infoDisplayCreatedAt">&nbsp;</span></div>
      </div>
    </div>
    <p id="photoError" class="error-text" style="display:none; margin:-10px 0 14px;"></p>

    <!-- 섹션 토글 버튼 3개 — 하나만 열림 -->
    <div style="display:flex; gap:8px;">
      <button type="button" class="btn-modern btn-outline info-section-btn" data-section="phone" style="flex:1; font-size:14px;"><i class="fas fa-phone" style="margin-right:5px;"></i>연락처</button>
      <button type="button" class="btn-modern btn-outline info-section-btn" data-section="password" style="flex:1; font-size:14px;"><i class="fas fa-shield-alt" style="margin-right:5px;"></i>비밀번호</button>
      <button type="button" class="btn-modern btn-outline info-section-btn" data-section="notif" style="flex:1; font-size:14px;"><i class="fas fa-bell" style="margin-right:5px;"></i>알림 설정</button>
    </div>

    <!-- 이메일 안내 (연락처 섹션에서만 의미 있어 항상 보이지 않고 그 섹션 안에 둠) -->

    <!-- 연락처 변경 섹션 -->
    <form id="infoForm" class="info-section" data-section="phone" style="display:none; margin-top:18px; padding-top:18px; border-top:1px solid var(--border);">
      <label style="display:block; font-size:13px; font-weight:700; color:var(--text-sub); margin-bottom:8px;">이름</label>
      <input type="text" name="userName" id="infoUserName" class="modern-input" required>
      <label style="display:block; font-size:13px; font-weight:700; color:var(--text-sub); margin:14px 0 8px;">전화번호</label>
      <input type="text" name="phoneNumber" id="infoPhoneNumber" class="modern-input"
             placeholder="010-1234-5678" pattern="[0-9-]{9,13}" title="숫자와 하이픈(-)만 입력해주세요." required>
      <label style="display:block; font-size:13px; font-weight:700; color:var(--text-sub); margin:14px 0 8px;">이메일</label>
      <input type="text" id="infoEmailReadonly" class="modern-input" disabled style="opacity:0.6;">
      <small style="display:block; font-size:12.5px; color:var(--text-sub); margin-top:6px;">이메일은 로그인 계정이라 직접 변경할 수 없습니다. 변경이 필요하면 관리자에게 문의해주세요.</small>
      <p id="infoError" class="error-text" style="display:none; margin-top:10px;"></p>
      <p id="infoSuccess" class="success-text" style="display:none; margin-top:10px;">저장되었습니다.</p>
      <button type="submit" class="btn-modern btn-primary" style="width:100%; margin-top:16px;">연락처 저장</button>
    </form>

    <!-- 비밀번호 변경 섹션 -->
    <form id="passwordForm" class="info-section" data-section="password" style="display:none; margin-top:18px; padding-top:18px; border-top:1px solid var(--border);">
      <label style="display:block; font-size:13px; font-weight:700; color:var(--text-sub); margin-bottom:8px;">현재 비밀번호</label>
      <input type="password" name="currentPassword" class="modern-input">
      <label style="display:block; font-size:13px; font-weight:700; color:var(--text-sub); margin:14px 0 8px;">새 비밀번호</label>
      <input type="password" name="newPassword" class="modern-input" placeholder="8자리 이상">
      <label style="display:block; font-size:13px; font-weight:700; color:var(--text-sub); margin:14px 0 8px;">새 비밀번호 확인</label>
      <input type="password" name="confirmPassword" class="modern-input">
      <p id="passwordSuccess" class="success-text" style="display:none; margin-top:10px;">비밀번호가 변경되었습니다.</p>
      <button type="submit" class="btn-modern btn-primary" style="width:100%; margin-top:16px;">비밀번호 변경</button>
    </form>

    <!-- 알림 설정 섹션 -->
    <div class="info-section" data-section="notif" style="display:none; margin-top:18px; padding-top:18px; border-top:1px solid var(--border);">
      <div style="display:flex; align-items:center; justify-content:space-between;">
        <div>
          <div style="font-weight:700; font-size:14.5px;">알림 받기</div>
          <div style="font-size:13px; color:var(--text-sub); margin-top:3px;">커뮤니티 · 1:1 면담 · 예약 관련 알림</div>
        </div>
        <label class="switch-toggle">
          <input type="checkbox" id="notificationsToggle">
          <span class="switch-toggle-slider"></span>
        </label>
      </div>
    </div>

  </div>
</div>

<script>
  (function () {
    var infoModal = document.getElementById('infoModal');
    var infoForm = document.getElementById('infoForm');
    var infoError = document.getElementById('infoError');
    var infoSuccess = document.getElementById('infoSuccess');
    var passwordForm = document.getElementById('passwordForm');
    var passwordSuccess = document.getElementById('passwordSuccess');
    var photoInput = document.getElementById('profileImageInput');
    var photoError = document.getElementById('photoError');
    var avatarPreview = document.getElementById('infoAvatarPreview');
    var displayName = document.getElementById('infoDisplayName');
    var displayEmail = document.getElementById('infoDisplayEmail');
    var displayCreatedAt = document.getElementById('infoDisplayCreatedAt');
    var openBtn = document.getElementById('openInfoModalBtn');

    function setAvatar(url, initial) {
      // 마이페이지처럼 큰 아바타(#profileHeroAvatar)가 같은 화면에 있으면 그것도 같이 맞춰준다
      var targets = [avatarPreview, document.getElementById('profileHeroAvatar')];
      targets.forEach(function (el) {
        if (!el) return;
        if (url) {
          el.style.backgroundImage = "url('" + url + "')";
          el.style.backgroundSize = 'cover';
          el.style.backgroundPosition = 'center';
          el.textContent = '';
        } else if (initial) {
          el.style.backgroundImage = '';
          el.textContent = initial;
        }
      });
    }

    // 버튼 3개 중 하나만 섹션이 열린다 — 같은 걸 다시 누르면 닫힘
    var sectionButtons = document.querySelectorAll('.info-section-btn');
    var sections = document.querySelectorAll('.info-section');
    function showSection(key) {
      sections.forEach(function (el) {
        el.style.display = (el.dataset.section === key) ? 'block' : 'none';
      });
      sectionButtons.forEach(function (btn) {
        var isActive = btn.dataset.section === key;
        btn.classList.toggle('btn-primary', isActive);
        btn.classList.toggle('btn-outline', !isActive);
      });
    }
    sectionButtons.forEach(function (btn) {
      btn.addEventListener('click', function () {
        var key = btn.dataset.section;
        var alreadyOpen = sections[0] && Array.prototype.some.call(sections, function (el) {
          return el.dataset.section === key && el.style.display === 'block';
        });
        showSection(alreadyOpen ? null : key);
      });
    });

    if (openBtn) {
      openBtn.addEventListener('click', function (e) {
        e.preventDefault();
        showSection(null);
        infoError.style.display = 'none';
        infoSuccess.style.display = 'none';
        photoError.style.display = 'none';
        passwordSuccess.style.display = 'none';
        infoModal.classList.add('active');
        fetch('<c:url value="/common/mypage/whoami"/>')
          .then(function (res) { return res.json(); })
          .then(function (data) {
            document.getElementById('infoUserName').value = data.userName;
            document.getElementById('infoPhoneNumber').value = data.phoneNumber || '';
            document.getElementById('infoEmailReadonly').value = data.email;
            document.getElementById('notificationsToggle').checked = data.notificationsEnabled;
            displayName.textContent = data.userName;
            displayEmail.textContent = data.email;
            displayCreatedAt.textContent = data.createdAt ? data.createdAt.substring(0, 10) : '-';
            setAvatar(data.profileImageUrl, data.userName ? data.userName.charAt(0) : '?');
          }).catch(function () {});
      });
    }
    document.getElementById('closeInfoModalBtn').addEventListener('click', function () {
      infoModal.classList.remove('active');
    });
    infoModal.addEventListener('click', function (e) { if (e.target === infoModal) infoModal.classList.remove('active'); });

    photoInput.addEventListener('change', function () {
      var file = photoInput.files[0];
      if (!file) return;
      photoError.style.display = 'none';
      var data = new FormData();
      data.append('userName', document.getElementById('infoUserName').value);
      data.append('phoneNumber', document.getElementById('infoPhoneNumber').value);
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
            displayName.textContent = document.getElementById('infoUserName').value;
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

    document.getElementById('notificationsToggle').addEventListener('change', function () {
      fetch('<c:url value="/common/mypage/notifications"/>', { method: 'POST' })
        .then(function (res) { return res.json(); })
        .catch(function () {});
    });
  })();
</script>
