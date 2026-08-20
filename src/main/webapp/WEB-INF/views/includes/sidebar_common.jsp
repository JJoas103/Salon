<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%-- 현재 페이지가 넘겨준 메뉴 키. 예) <jsp:param name="menu" value="reservations"/> --%>
<c:set var="menu" value="${param.menu}" />
<aside class="sidebar">
  <div class="sidebar-brand">
    <i class="fas fa-scissors" style="color: var(--accent);"></i><span>HAIR RESERVE</span>
    <sec:authorize access="isAuthenticated()">
      <button type="button" id="notifBellBtn" class="sidebar-notif-bell" title="알림함">
        <i class="fas fa-bell"></i>
        <span id="navUnread" class="sidebar-notif-badge" data-count="0"></span>
      </button>
    </sec:authorize>
  </div>

  <sec:authorize access="isAuthenticated()">
    <div class="notif-panel" id="notifPanel" style="display:none;">
      <div class="notif-panel-head">
        <div class="notif-panel-title">알림</div>
        <button type="button" class="notif-panel-readall" id="notifReadAllBtn">모두 읽음</button>
      </div>
      <div class="notif-list" id="notifList">
        <div class="notif-empty"><i class="fas fa-bell-slash"></i>새로운 알림이 없습니다</div>
      </div>
    </div>
  </sec:authorize>
  <ul class="sidebar-menu">
    <li class="sidebar-item ${menu == 'home' ? 'active' : ''}"><a href="<c:url value='/common/home'/>"><i class="fas fa-home"></i> 홈 메인</a></li>
    <li class="sidebar-item ${menu == 'search' ? 'active' : ''}" data-protected="true"><a href="<c:url value='/common/salonmap'/>"><i class="fas fa-search"></i> 헤어샵 검색/예약</a></li>
    <li class="sidebar-item ${menu == 'chat' ? 'active' : ''}" data-protected="true"><a href="<c:url value='/common/chat'/>"><i class="fas fa-comments"></i> 1:1 상담 채팅</a></li>
    <li class="sidebar-item ${menu == 'community' ? 'active' : ''}" data-protected="true"><a href="<c:url value='/common/community'/>"><i class="fas fa-users"></i> 스타일 커뮤니티</a></li>
    <li class="sidebar-item ${menu == 'reservations' ? 'active' : ''}" data-protected="true"><a href="<c:url value='/common/reservation?category=1'/>"><i class="fas fa-calendar-alt"></i> 예약 내역</a></li>
    <li class="sidebar-item ${menu == 'ownerRequest' ? 'active' : ''}" data-protected="true"><a href="<c:url value='/common/owner-request'/>"><i class="fas fa-store"></i> 점주 요청</a></li>
    <li class="sidebar-item ${menu == 'mypage' ? 'active' : ''}" data-protected="true"><a href="<c:url value='/common/mypage'/>"><i class="fas fa-user"></i> 마이페이지</a></li>
  </ul>
  <div class="sidebar-footer">
    <sec:authorize access="isAuthenticated()">
      <sec:authentication property="principal.userName" var="currentUserName" />
      <div class="sidebar-user-card" id="openInfoModalBtn">
        <div class="sidebar-user-avatar">${fn:substring(currentUserName,0,1)}</div>
        <div class="sidebar-user-info">
          <div class="sidebar-user-name">${currentUserName} 고객님</div>
          <div class="sidebar-user-hint">클릭해서 정보 수정</div>
        </div>
      </div>
      <a href="<c:url value='/user/logout'/>" class="sidebar-item-logout"><i class="fas fa-sign-out-alt"></i> 로그아웃</a>
    </sec:authorize>
    <sec:authorize access="!isAuthenticated()">
      <div id="sidebarAuthNotice" class="sidebar-auth-notice">로그인이 필요한 메뉴입니다</div>
      <a href="#" id="openAuthLoginBtn" class="sidebar-item-logout"><i class="fas fa-sign-in-alt"></i> 로그인</a>
      <a href="#" id="openAuthJoinBtn" class="sidebar-item-logout"><i class="fas fa-user-plus"></i> 회원가입</a>
    </sec:authorize>
  </div>
</aside>

<%-- 채팅 소켓은 사이드바에서 연다. 채팅 페이지에서만 열면 다른 화면에 있을 때
     새 메시지를 받을 방법이 없어 알림 배지를 올릴 수 없다.
     chat.js 는 채팅 페이지 전용 요소(#chatBody 등)가 없으면 알림 역할만 한다. --%>
<sec:authorize access="isAuthenticated()">
  <script>
    window.CHAT_CONFIG = {
      wsUrl: '<c:url value="/ws"/>',
      unreadCountUrl: '<c:url value="/common/chat/unread-count"/>',
      currentUserId: <sec:authentication property="principal.userId"/>,
      chatId: ${empty chatId ? 'null' : chatId}
    };
    window.NOTIF_CONFIG = {
      baseUrl: '<c:url value="/common/notifications"/>',
      unreadCountUrl: '<c:url value="/common/notifications/unread-count"/>',
      readAllUrl: '<c:url value="/common/notifications/read-all"/>'
    };
  </script>
  <%-- defer: 사이드바는 body 앞쪽이라 그대로 두면 아래 대화창 DOM 이 아직 없다 --%>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/sockjs-client/1.6.1/sockjs.min.js" defer></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/stomp.js/2.3.3/stomp.min.js" defer></script>
  <%-- notifications.js 를 먼저 둔다. chat.js 는 window.NotifBridge 존재 여부로
       배지 소유권을 판단하는데, 이 순서가 바뀌면(혹은 notifications.js 가 404/에러로
       못 뜨면) chat.js 가 항상 자기 배지 관리로 되돌아가 안전하게 동작한다. --%>
  <script src="/resources/js/notifications.js" defer></script>
  <script src="/resources/js/chat.js" defer></script>
  <jsp:include page="info_modal.jsp" />
</sec:authorize>

<sec:authorize access="!isAuthenticated()">
<!-- 로그인 모달 -->
<div class="modal-overlay" id="authLoginModal">
  <div class="modal-box">
    <div class="modal-header">
      <h3 style="font-size: 18px;"><i class="fas fa-sign-in-alt" style="margin-right:8px; color:var(--accent);"></i>로그인</h3>
      <button type="button" class="modal-close" id="closeAuthLoginBtn"><i class="fas fa-times"></i></button>
    </div>
    <form id="authLoginForm" action="<c:url value='/user/login'/>" method="post">
      <div id="authLoginError" class="auth-alert" style="display:none;"><i class="fas fa-circle-exclamation"></i> <span></span></div>
      <div>
        <label class="role-label">이메일 계정</label>
        <div class="input-wrapper"><i class="far fa-envelope"></i><input type="email" name="userEmail" class="auth-input" placeholder="master@hairreserve.com"></div>
      </div>
      <div>
        <label class="role-label">비밀번호</label>
        <div class="input-wrapper"><i class="fas fa-lock"></i><input type="password" name="userPassword" class="auth-input"></div>
      </div>
      <button class="btn-modern btn-primary" style="width: 100%; margin-top: 15px;">로그인</button>
    </form>
    <div class="auth-footer">아직 계정이 없으신가요? <a href="#" id="switchToJoinBtn" class="auth-link">회원가입</a></div>
  </div>
</div>

<!-- 회원가입 모달 -->
<div class="modal-overlay" id="authJoinModal">
  <div class="modal-box">
    <div class="modal-header">
      <h3 style="font-size: 18px;"><i class="fas fa-user-plus" style="margin-right:8px; color:var(--accent);"></i>회원가입</h3>
      <button type="button" class="modal-close" id="closeAuthJoinBtn"><i class="fas fa-times"></i></button>
    </div>
    <form action="<c:url value='/user/join'/>" method="post">
      <input type="hidden" name="userType" value="customer">
      <div class="form-field">
        <label class="role-label">이름</label>
        <div class="input-wrapper"><i class="far fa-user"></i><input type="text" name="userName" class="auth-input" placeholder="홍길동"></div>
      </div>
      <div class="form-field form-field-email">
        <label class="role-label">이메일 주소</label>
        <div class="email-row">
          <div class="input-wrapper"><i class="far fa-envelope"></i><input type="email" id="modalJoinEmail" name="email" class="auth-input" placeholder="example@hair.com"></div>
          <button type="button" id="modalJoinCheckEmailBtn" class="btn-check">중복확인</button>
        </div>
        <small id="modalJoinEmailMsg" style="display:none;"></small>
      </div>
      <div class="form-field">
        <label class="role-label">비밀번호 설정</label>
        <div class="input-wrapper"><i class="fas fa-lock"></i><input type="password" id="modalJoinPassword" name="password" class="auth-input" placeholder="8자리 이상 안전한 비밀번호"></div>
      </div>
      <div class="form-field">
        <label class="role-label">비밀번호 확인</label>
        <div class="input-wrapper"><i class="fas fa-lock"></i><input type="password" id="modalJoinConfirmPassword" name="confirmPassword" class="auth-input" placeholder="비밀번호를 다시 입력하세요"></div>
        <small id="modalJoinConfirmMsg" class="error-text" style="display:none;">비밀번호가 일치하지 않습니다</small>
      </div>
      <button type="submit" class="btn-modern btn-primary" style="width: 100%; margin-top: 15px;">회원가입 완료하기</button>
    </form>
    <div class="auth-footer">이미 계정이 있으신가요? <a href="#" id="switchToLoginBtn" class="auth-link">로그인</a></div>
  </div>
</div>

<script>
(function () {
  var loginModal = document.getElementById('authLoginModal');
  var joinModal = document.getElementById('authJoinModal');
  var notice = document.getElementById('sidebarAuthNotice');
  var noticeTimer = null;

  function openModal(modal) { modal.classList.add('active'); }
  function closeModal(modal) { modal.classList.remove('active'); }

  function showNotice() {
    if (!notice) return;
    notice.classList.add('show');
    clearTimeout(noticeTimer);
    noticeTimer = setTimeout(function () { notice.classList.remove('show'); }, 3000);
  }

  document.getElementById('openAuthLoginBtn').addEventListener('click', function (e) { e.preventDefault(); openModal(loginModal); });
  document.getElementById('openAuthJoinBtn').addEventListener('click', function (e) { e.preventDefault(); openModal(joinModal); });
  document.getElementById('switchToJoinBtn').addEventListener('click', function (e) { e.preventDefault(); closeModal(loginModal); openModal(joinModal); });
  document.getElementById('switchToLoginBtn').addEventListener('click', function (e) { e.preventDefault(); closeModal(joinModal); openModal(loginModal); });

  [loginModal, joinModal].forEach(function (modal) {
    modal.querySelector('.modal-close').addEventListener('click', function () { closeModal(modal); });
    modal.addEventListener('click', function (e) { if (e.target === modal) closeModal(modal); });
  });

  document.querySelectorAll('.sidebar-menu .sidebar-item[data-protected="true"] a').forEach(function (link) {
    link.addEventListener('click', function (e) {
      e.preventDefault();
      showNotice();
    });
  });

  // ---- 로그인 모달: fetch 제출, 실패 시 모달 안에서 에러 표시 (성공 시엔 '/'로 이동해 IndexController의 role 분기를 그대로 재사용) ----
  var loginForm = document.getElementById('authLoginForm');
  var loginError = document.getElementById('authLoginError');

  loginForm.addEventListener('submit', function (e) {
    e.preventDefault();
    loginError.style.display = 'none';

    fetch(loginForm.action, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'X-Requested-With': 'XMLHttpRequest'
      },
      body: new URLSearchParams(new FormData(loginForm))
    }).then(function (res) {
      if (res.ok) {
        location.href = '<c:url value="/"/>';
        return;
      }
      return res.json().then(function (data) {
        loginError.querySelector('span').textContent = data.message || '로그인에 실패했습니다.';
        loginError.style.display = 'block';
      });
    }).catch(function () {
      loginError.querySelector('span').textContent = '로그인 중 오류가 발생했습니다.';
      loginError.style.display = 'block';
    });
  });

  // ---- 회원가입 모달: 비밀번호 확인 (join.jsp 로직 포팅) ----
  var password = document.getElementById('modalJoinPassword');
  var confirmPassword = document.getElementById('modalJoinConfirmPassword');
  var confirmMsg = document.getElementById('modalJoinConfirmMsg');

  function checkPasswordMatch() {
    if (confirmPassword.value.length === 0) {
      confirmMsg.style.display = 'none';
      confirmPassword.classList.remove('input-error');
      return;
    }
    var isMismatch = password.value !== confirmPassword.value;
    confirmMsg.style.display = isMismatch ? 'block' : 'none';
    confirmPassword.classList.toggle('input-error', isMismatch);
  }
  password.addEventListener('input', checkPasswordMatch);
  confirmPassword.addEventListener('input', checkPasswordMatch);

  // ---- 회원가입 모달: 이메일 중복확인 (join.jsp 로직 포팅) ----
  var emailInput = document.getElementById('modalJoinEmail');
  var checkEmailBtn = document.getElementById('modalJoinCheckEmailBtn');
  var emailMsg = document.getElementById('modalJoinEmailMsg');
  var emailRegex = /^[\w.-]+@[\w.-]+\.[A-Za-z]{2,}$/;

  function showEmailMsg(text, ok) {
    emailMsg.textContent = text;
    emailMsg.className = ok ? 'success-text' : 'error-text';
    emailMsg.style.display = 'block';
    emailInput.classList.toggle('input-error', !ok);
  }

  checkEmailBtn.addEventListener('click', function () {
    var email = emailInput.value.trim();
    if (email.length === 0) { showEmailMsg('이메일을 입력해주세요', false); return; }
    if (!emailRegex.test(email)) { showEmailMsg('이메일 형식이 올바르지 않습니다.', false); return; }
    fetch('<c:url value="/user/check-email"/>?email=' + encodeURIComponent(email))
      .then(function (res) { return res.json(); })
      .then(function (data) {
        showEmailMsg(data.available ? '사용 가능한 이메일입니다' : '이미 사용 중인 이메일입니다', data.available);
      })
      .catch(function () { showEmailMsg('확인 중 오류가 발생했습니다', false); });
  });
  emailInput.addEventListener('input', function () {
    emailMsg.style.display = 'none';
    emailInput.classList.remove('input-error');
  });
})();
</script>
</sec:authorize>
