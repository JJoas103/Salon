/* 1:1 상담 채팅.
 *
 * 이 파일은 사이드바(sidebar_common.jsp / sidebar_owner.jsp)에서 로드되므로
 * 로그인한 사용자의 "모든 페이지"에서 돈다. 역할이 둘이다.
 *
 *   1) 어느 페이지에 있든  : 새 메시지가 오면 사이드바 1:1 메뉴의 알림 배지를 올린다
 *   2) 채팅 페이지에서만   : 말풍선 렌더 · 전송 · 읽음 처리
 *
 * 2)번 요소(#chatBody 등)는 채팅 페이지에만 있으므로 전부 null 검사를 하고 넘어간다.
 *
 * JSP 가 window.CHAT_CONFIG 로 넘겨주는 값:
 *   wsUrl          : SockJS 엔드포인트 (컨텍스트 경로 포함)
 *   unreadCountUrl : 알림 배지 초기값을 받아올 주소
 *   currentUserId  : 로그인한 내 user_id
 *   chatId         : 지금 열려 있는 방. 채팅 페이지가 아니거나 방이 없으면 null
 */
(function () {

  var config = window.CHAT_CONFIG;
  if (!config) return;

  // 채팅 페이지에만 있는 것들
  var body    = document.getElementById('chatBody');
  var status  = document.getElementById('wsStatus');
  var input   = document.getElementById('msgInput');
  var sendBtn = document.getElementById('sendBtn');
  // 사이드바 - 모든 페이지에 있다
  var navBadge = document.getElementById('navUnread');

  var stompClient = null;
  var reconnectTimer = null;
  var reconnectDelay = 1000;          // 실패할수록 늘린다 (서버가 죽었을 때 재연결 폭주 방지)
  var MAX_RECONNECT_DELAY = 30000;

  function setStatus(text, connected) {
    if (!status) return;
    status.textContent = text;
    status.classList.toggle('connected', !!connected);
  }

  // ---------------- 사이드바 알림 배지 ----------------

  function renderNavBadge(count) {
    if (!navBadge) return;
    navBadge.dataset.count = count;
    navBadge.textContent = count > 99 ? '99+' : count;
  }

  function bumpNavBadge() {
    if (!navBadge) return;
    renderNavBadge(Number(navBadge.dataset.count || 0) + 1);
  }

  function loadNavBadge() {
    if (!navBadge) return;
    fetch(config.unreadCountUrl, { credentials: 'same-origin' })
      .then(function (res) { return res.json(); })
      .then(function (data) { renderNavBadge(data.count); })
      .catch(function () { /* 배지는 부가 정보라 실패해도 화면을 막지 않는다 */ });
  }

  // ---------------- 대화창 (채팅 페이지 전용) ----------------

  function addBubble(message) {
    if (!body) return;

    var empty = body.querySelector('.chat-empty');
    if (empty) empty.remove();

    var wrap = document.createElement('div');
    // senderId 로 판단한다. 화면에 "내 말풍선"을 오른쪽에 붙이기 위한 것뿐이고,
    // 실제 권한 판단은 전부 서버(ChatService)가 한다.
    wrap.className = 'msg-wrapper ' + (message.senderId === config.currentUserId ? 'outgoing' : 'incoming');

    var bubble = document.createElement('div');
    bubble.className = 'msg-bubble';
    // textContent 라서 태그가 섞여 있어도 글자로만 들어간다 (innerHTML 을 쓰면 XSS)
    bubble.textContent = message.messageContent;
    wrap.appendChild(bubble);

    // 내가 보낸 메시지는 상대가 읽기 전까지 "1" 을 달아둔다
    if (message.senderId === config.currentUserId && !message.isRead) {
      var mark = document.createElement('span');
      mark.className = 'msg-read-mark';
      mark.textContent = '1';
      wrap.appendChild(mark);
    }

    body.appendChild(wrap);
    body.scrollTop = body.scrollHeight;
  }

  /* 상대가 방을 읽으면 내 화면의 "1" 을 전부 지운다.
     한 번 읽으면 그 방의 내 메시지는 모두 읽힌 것이므로 개별 id 를 따질 필요가 없다. */
  function clearReadMarks() {
    if (!body) return;
    body.querySelectorAll('.msg-read-mark').forEach(function (mark) {
      mark.remove();
    });
  }

  /* 지금 보고 있지 않은 방에 메시지가 오면 방 목록의 안읽음 배지만 올린다 */
  function bumpRoomBadge(chatId) {
    var badge = document.querySelector('[data-chat-id="' + chatId + '"] .chat-unread');
    if (!badge) return;   // 목록에 없는 방 (채팅 페이지가 아니거나 다른 매장인 경우)
    var next = Number(badge.dataset.count || 0) + 1;
    badge.dataset.count = next;
    badge.textContent = next;
  }

  function clearRoomBadge(chatId) {
    var badge = document.querySelector('[data-chat-id="' + chatId + '"] .chat-unread');
    if (!badge) return;
    badge.dataset.count = 0;
    badge.textContent = '0';
  }

  function isConnected() {
    return stompClient !== null && stompClient.connected;
  }

  /* 열려 있는 방을 "실제로 보고 있을 때만" 읽음 처리한다.
     visibilityState 만으로는 부족하다 — 창 두 개를 나란히 띄우면 둘 다 'visible' 이라
     뒤에 있는 창까지 읽음 처리된다. 포커스까지 봐야 "내가 보고 있는 창"이 된다. */
  function isWatchingRoom() {
    return config.chatId !== null
        && document.visibilityState === 'visible'
        && document.hasFocus();
  }

  function markReadIfWatching() {
    if (!isWatchingRoom()) return;
    if (!isConnected()) return;

    stompClient.send('/app/chat/read', {}, JSON.stringify({ chatId: config.chatId }));

    // 지금 보고 있는 방의 배지는 즉시 0. (사이드바 합계는 서버가 unreadCount 로 알려준다)
    clearRoomBadge(config.chatId);
  }

  // ---------------- 연결 ----------------

  /* 로그인 세션이 살아있는지 확인한다.
     true = 정상, false = 세션 만료(재연결해도 소용없음), null = 서버가 안 떠 있음(계속 재시도) */
  function probeSession() {
    return fetch(config.wsUrl + '/info', { credentials: 'same-origin' })
      .then(function (res) {
        // 미인증이면 시큐리티가 로그인 페이지로 돌려보내므로 JSON 이 아닌 HTML 이 온다
        var type = res.headers.get('content-type') || '';
        return !res.redirected && type.indexOf('json') !== -1;
      })
      .catch(function () { return null; });
  }

  function giveUp() {
    setStatus('로그인이 만료되었습니다 - 새로고침 해주세요', false);
    if (input) input.disabled = true;
    if (sendBtn) sendBtn.disabled = true;
  }

  function scheduleReconnect() {
    if (reconnectTimer !== null) return;   // 이미 예약돼 있으면 중복으로 잡지 않는다
    setStatus('연결 끊김 - 다시 연결 중…', false);

    reconnectTimer = setTimeout(function () {
      reconnectTimer = null;
      // 세션이 끊긴 거라면 몇 번을 다시 붙어도 시큐리티가 막는다.
      // 무한히 실패하는 대신 사용자에게 알린다.
      probeSession().then(function (alive) {
        if (alive === false) {
          giveUp();
          return;
        }
        connect();
      });
    }, reconnectDelay);

    reconnectDelay = Math.min(reconnectDelay * 2, MAX_RECONNECT_DELAY);
  }

  function handleEvent(payload) {

    // 상대가 내 메시지를 읽었다는 통지
    if (payload.event === 'messagesRead') {
      if (payload.data.chatId === config.chatId) clearReadMarks();
      return;
    }

    // 내가 뭔가를 읽어서 안읽음 합계가 바뀌었다는 통지 (서버가 계산한 값)
    if (payload.event === 'unreadCount') {
      renderNavBadge(payload.data.count);
      return;
    }

    if (payload.event !== 'newMessage') return;

    var message = payload.data;

    // 내가 보낸 것의 에코 — 말풍선만 그리고 알림은 올리지 않는다
    if (message.senderId === config.currentUserId) {
      if (message.chatId === config.chatId) addBubble(message);
      return;
    }

    if (message.chatId === config.chatId) {
      addBubble(message);
      if (isWatchingRoom()) {
        markReadIfWatching();   // 보고 있으니 읽음 처리 → 배지를 올리지 않는다
      } else {
        // 방은 열려 있지만 다른 창을 보고 있는 중 — 목록과 사이드바 양쪽에 표시
        bumpRoomBadge(message.chatId);
        bumpNavBadge();
      }
      return;
    }

    // 다른 방(또는 다른 페이지에 있는 중)
    bumpRoomBadge(message.chatId);
    bumpNavBadge();
  }

  function connect() {
    var socket = new SockJS(config.wsUrl);
    stompClient = Stomp.over(socket);
    stompClient.debug = null;   // 콘솔에 프레임 전문이 쏟아지는 것을 끈다

    stompClient.connect({}, function () {
      setStatus('연결됨', true);
      reconnectDelay = 1000;    // 붙었으면 대기시간을 원래대로

      // 방마다 구독하지 않는다. 구독은 "내게 오는 것" 하나뿐이고,
      // 어느 방 메시지인지는 payload 의 chatId 로 가른다.
      stompClient.subscribe('/user/queue/messages', function (frame) {
        handleEvent(JSON.parse(frame.body));
      });

    }, function () {
      // 연결 실패와 연결 끊김 모두 이 콜백으로 온다.
      scheduleReconnect();
    });
  }

  function send() {
    var text = input.value.trim();
    if (text.length === 0) return;
    if (config.chatId === null) return;   // 열린 방이 없으면 보낼 곳이 없다

    if (!isConnected()) {
      // 입력값을 지우지 않는다 — 다시 연결되면 그대로 보낼 수 있게
      setStatus('연결이 끊겨 전송할 수 없습니다', false);
      return;
    }

    stompClient.send('/app/chat/send', {}, JSON.stringify({
      chatId: config.chatId,
      messageContent: text
    }));

    // 여기서 말풍선을 그리지 않는다. 서버가 저장에 성공한 뒤 나에게도 되돌려주므로
    // 그때 그린다 → 저장 실패한 메시지가 화면에 남는 일이 없다.
    input.value = '';
  }

  if (sendBtn) sendBtn.addEventListener('click', send);
  if (input) {
    input.addEventListener('keydown', function (e) {
      if (e.key === 'Enter') send();
    });
  }

  // JSP 가 그려둔 과거 이력은 위쪽부터 보이므로, 열자마자 최신 메시지로 내려준다
  if (body) body.scrollTop = body.scrollHeight;

  // 다른 탭/창에 있다가 돌아왔을 때, 그동안 쌓인 메시지를 읽음 처리.
  // 탭 전환은 visibilitychange, 창 전환은 focus 로 잡힌다 (둘 다 필요하다)
  document.addEventListener('visibilitychange', markReadIfWatching);
  window.addEventListener('focus', markReadIfWatching);

  loadNavBadge();
  connect();
})();
