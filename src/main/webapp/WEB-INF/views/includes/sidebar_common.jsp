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
      <a href="<c:url value='/common/chat'/>" class="sidebar-notif-bell" title="알림 (1:1 상담 채팅)">
        <i class="fas fa-bell"></i>
        <span id="navUnread" class="sidebar-notif-badge" data-count="0"></span>
      </a>
    </sec:authorize>
  </div>
  <ul class="sidebar-menu">
    <li class="sidebar-item ${menu == 'home' ? 'active' : ''}"><a href="<c:url value='/common/home'/>"><i class="fas fa-home"></i> 홈 메인</a></li>
    <li class="sidebar-item ${menu == 'search' ? 'active' : ''}" data-protected="true"><a href="<c:url value='/common/salonmap'/>"><i class="fas fa-search"></i> 헤어샵 검색/예약</a></li>
    <li class="sidebar-item ${menu == 'chat' ? 'active' : ''}" data-protected="true"><a href="<c:url value='/common/chat'/>"><i class="fas fa-comments"></i> 1:1 상담 채팅</a></li>
    <li class="sidebar-item ${menu == 'community' ? 'active' : ''}" data-protected="true"><a href="<c:url value='/common/community'/>"><i class="fas fa-users"></i> 스타일 커뮤니티</a></li>
    <li class="sidebar-item ${menu == 'stylePreview' ? 'active' : ''}" data-protected="true"><a href="<c:url value='/common/style-preview'/>"><i class="fas fa-wand-magic-sparkles"></i> AI 스타일 미리보기</a></li>
    <li class="sidebar-item ${menu == 'reservations' ? 'active' : ''}" data-protected="true"><a href="<c:url value='/common/reservation?category=1'/>"><i class="fas fa-calendar-alt"></i> 예약 내역</a></li>
    <%-- 점주 요청은 자체 가입(로컬) 계정만 가능 — 소셜 계정은 메뉴 자체를 숨긴다 (서버는 SecurityConfig에서 이중 방어) --%>
    <sec:authorize access="!hasAuthority('SOCIAL_ACCOUNT')">
    <li class="sidebar-item ${menu == 'ownerRequest' ? 'active' : ''}" data-protected="true"><a href="<c:url value='/common/owner-request'/>"><i class="fas fa-store"></i> 점주 요청</a></li>
    </sec:authorize>
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
  </script>
  <%-- defer: 사이드바는 body 앞쪽이라 그대로 두면 아래 대화창 DOM 이 아직 없다 --%>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/sockjs-client/1.6.1/sockjs.min.js" defer></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/stomp.js/2.3.3/stomp.min.js" defer></script>
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
    <div class="auth-divider">또는</div>
    <div class="social-login-row">
      <a href="<c:url value='/oauth2/authorization/google'/>" class="btn-social btn-google"><i class="fab fa-google"></i> Google</a>
      <a href="<c:url value='/oauth2/authorization/naver'/>" class="btn-social btn-naver"><strong>N</strong> 네이버</a>
    </div>
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
    <div class="auth-divider">또는</div>
    <div class="social-login-row">
      <a href="<c:url value='/oauth2/authorization/google'/>" class="btn-social btn-google"><i class="fab fa-google"></i> Google</a>
      <a href="<c:url value='/oauth2/authorization/naver'/>" class="btn-social btn-naver"><strong>N</strong> 네이버</a>
    </div>
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

<%-- AI 시술 추천 챗봇 위젯 — 개인 예약이력을 다루므로 로그인 사용자에게만 노출 --%>
<sec:authorize access="isAuthenticated()">
<button type="button" id="aiChatFab" class="ai-chat-fab" aria-label="AI 시술 추천 상담">
  <i class="fas fa-wand-magic-sparkles"></i>
</button>

<div class="modal-overlay ai-chat-modal" id="aiChatModal">
  <div class="modal-box ai-chat-box">
    <div class="modal-header">
      <h3 style="font-size: 18px;"><i class="fas fa-wand-magic-sparkles" style="margin-right:8px; color:var(--accent);"></i>AI 시술 추천</h3>
      <button type="button" class="modal-close" id="closeAiChatBtn"><i class="fas fa-times"></i></button>
    </div>
    <div class="ai-chat-messages" id="aiChatMessages">
      <%-- pre-wrap 이라 줄바꿈이 그대로 보임. 한 줄로 유지 --%>
      <div class="ai-chat-msg bot">안녕하세요! 시술 추천과 매장 안내를 도와드려요. 최근 완료하신 시술 이력(최근 5건)도 함께 참고합니다.<c:if test="${not empty salon.salonId}"> 지금 보고 계신 <c:out value="${salon.salonName}"/> 시술을 먼저 찾아드립니다.</c:if> 고민이나 궁금한 점을 말씀해주세요.</div>
    </div>
    <%-- 칩 하나가 인텐트 갈래 하나씩을 태움 (chat/intent.py)
         첫 질문을 보내면 .is-compact 로 접힘 --%>
    <div class="ai-chat-suggestions" id="aiChatSuggestions">
      <p class="ai-chat-suggestions-label">이런 걸 물어보실 수 있어요. 눌러보시거나 직접 입력해 주세요.</p>
      <button type="button" class="ai-chat-suggestion-chip">손상모 케어 시술 추천해줘</button>
      <button type="button" class="ai-chat-suggestion-chip">제일 저렴한 시술이 뭐야?</button>
      <button type="button" class="ai-chat-suggestion-chip">평점 좋은 매장 추천해줘</button>
      <button type="button" class="ai-chat-suggestion-chip">내가 갔던 매장에 뭐가 있어?</button>
      <button type="button" class="ai-chat-suggestion-chip">저번에 받은 시술이랑 어울리는 스타일 추천해줘</button>
    </div>
    <form id="aiChatForm" class="ai-chat-input-row">
      <input type="text" id="aiChatInput" class="modern-input" placeholder="예: 저번 시술 참고해서 손상모 케어 추천해줘" maxlength="500" autocomplete="off">
      <button type="submit" class="btn-modern btn-primary" id="aiChatSendBtn"><i class="fas fa-paper-plane"></i></button>
    </form>
  </div>
</div>

<script>
(function () {
  var fab = document.getElementById('aiChatFab');
  var modal = document.getElementById('aiChatModal');
  var closeBtn = document.getElementById('closeAiChatBtn');
  var messages = document.getElementById('aiChatMessages');
  var suggestions = document.getElementById('aiChatSuggestions');
  var form = document.getElementById('aiChatForm');
  var input = document.getElementById('aiChatInput');
  var sendBtn = document.getElementById('aiChatSendBtn');

  // 매장 상세 화면이면 그 매장으로 후보를 좁힘. 서버가 영업 중인 매장인지 다시 확인함
  var pageSalonId = ${empty salon.salonId ? 'null' : salon.salonId};

  // ai-service 는 매장 id 와 이름만 주므로 주소는 여기서 조립함
  var reserveUrl = '<c:url value="/common/reserve"/>';

  // 세션ID는 페이지 로드 단위 — MCP 가 이 값으로 대화 맥락을 이어감
  // sessionStorage 에 두면 새로고침해도 살아남아, 화면 말풍선은 비었는데 서버는 대화를 기억하는 상태가 됨
  // 그러면 첫 턴에만 도는 도메인 게이트도 건너뛰어 "대진대학교가 어디있어" 가 통과함
  var sessionId = (window.crypto && crypto.randomUUID)
    ? crypto.randomUUID()
    : (Date.now() + '-' + Math.random().toString(16).slice(2));

  // 답변을 기다리는 동안 두 번째 요청을 막음 — 서버가 상담을 한 건씩 처리해 뒤엣것이 최대 25초 대기함
  var isSending = false;

  function setSending(on) {
    isSending = on;
    input.disabled = on;
    sendBtn.disabled = on;
    if (suggestions) {
      Array.prototype.forEach.call(
        suggestions.querySelectorAll('.ai-chat-suggestion-chip'),
        function (chip) { chip.disabled = on; });
    }
  }

  function openModal() { modal.classList.add('active'); input.focus(); }
  function closeModal() { modal.classList.remove('active'); }

  fab.addEventListener('click', openModal);
  closeBtn.addEventListener('click', closeModal);
  modal.addEventListener('click', function (e) { if (e.target === modal) closeModal(); });

  function appendMessage(text, who) {
    var el = document.createElement('div');
    el.className = 'ai-chat-msg ' + who;
    el.textContent = text;
    messages.appendChild(el);
    messages.scrollTop = messages.scrollHeight;
    return el;
  }

  // 답변에 등장한 매장을 예약 링크로 붙임
  // LLM 이 문장 안에 링크를 쓰게 하면 없는 매장을 지어내므로 확인된 목록만 받아서 만듦
  function appendLinks(salons) {
    if (!salons || !salons.length) return;

    var wrap = document.createElement('div');
    wrap.className = 'ai-chat-links';
    salons.forEach(function (salon) {
      if (!salon || !salon.salonId) return;
      var link = document.createElement('a');
      link.className = 'ai-chat-link';
      link.href = reserveUrl + '?salonId=' + encodeURIComponent(salon.salonId);
      // 예약은 새 탭으로 보내 상담을 남겨둠
      link.target = '_blank';
      link.rel = 'noopener';
      link.innerHTML = '<i class="fas fa-calendar-check"></i>';
      // 매장명은 마크업이 아니라 텍스트로 넣음
      link.appendChild(document.createTextNode(' ' + (salon.salonName || '이 매장') + ' 예약하기'));
      wrap.appendChild(link);
    });

    if (!wrap.children.length) return;
    messages.appendChild(wrap);
    messages.scrollTop = messages.scrollHeight;
  }

  // 예시 질문 버튼과 직접 입력이 같은 경로를 타도록 공용 함수로 뺌
  function sendQuestion(question) {
    if (!question || isSending) return;
    // 지우지 않고 접음 — 다른 갈래를 이어서 눌러보는 흐름이 많음
    if (suggestions) suggestions.classList.add('is-compact');

    appendMessage(question, 'user');
    input.value = '';
    setSending(true);
    var pending = appendMessage('생각하는 중...', 'bot pending');

    fetch('<c:url value="/api/chat"/>', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ question: question, sessionId: sessionId, salonId: pageSalonId })
    }).then(function (res) {
      return res.json();
    }).then(function (data) {
      pending.remove();
      appendMessage(data.answer || '답변을 받지 못했습니다.', 'bot');
      appendLinks(data.salons);
    }).catch(function () {
      pending.remove();
      appendMessage('상담 서버에 연결할 수 없습니다.', 'bot');
    }).finally(function () {
      setSending(false);
      input.focus();
    });
  }

  form.addEventListener('submit', function (e) {
    e.preventDefault();
    sendQuestion(input.value.trim());
  });

  if (suggestions) {
    suggestions.addEventListener('click', function (e) {
      var chip = e.target.closest('.ai-chat-suggestion-chip');
      if (!chip) return;
      sendQuestion(chip.textContent.trim());
    });
  }
})();
</script>
</sec:authorize>
