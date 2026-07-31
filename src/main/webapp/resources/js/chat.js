/* 1:1 상담 채팅 - 고객(common/chat.jsp)·점주(owner/chat.jsp) 공용 스크립트.
 *
 * 역할 분담:
 *   - 방 목록과 과거 대화 이력은 JSP 가 이미 그려둔다 (평범한 HTTP 로 받은 것)
 *   - 이 파일은 "연결 이후 새로 오는 메시지"만 담당한다
 *
 * JSP 가 아래 값을 window.CHAT_CONFIG 로 넘겨준다.
 *   wsUrl         : SockJS 엔드포인트 (컨텍스트 경로 포함)
 *   currentUserId : 로그인한 내 user_id (내 말풍선/상대 말풍선 구분용)
 *   chatId        : 지금 열려 있는 방. 방이 하나도 없으면 null
 */
(function () {

  var config = window.CHAT_CONFIG;
  if (!config) return;

  var body    = document.getElementById('chatBody');
  var status  = document.getElementById('wsStatus');
  var input   = document.getElementById('msgInput');
  var sendBtn = document.getElementById('sendBtn');
  var stompClient = null;

  function setStatus(text, connected) {
    if (!status) return;
    status.textContent = text;
    status.classList.toggle('connected', !!connected);
  }

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
    bubble.textContent = message.messageContent;

    wrap.appendChild(bubble);
    body.appendChild(wrap);
    body.scrollTop = body.scrollHeight;
  }

  /* 지금 보고 있지 않은 방에 메시지가 오면 목록의 안읽음 배지만 올린다 */
  function bumpUnread(chatId) {
    var badge = document.querySelector('[data-chat-id="' + chatId + '"] .chat-unread');
    if (!badge) return;   // 목록에 없는 방 (점주가 다른 매장을 보고 있는 경우 등)
    var next = Number(badge.dataset.count || 0) + 1;
    badge.dataset.count = next;
    badge.textContent = next;
  }

  function connect() {
    var socket = new SockJS(config.wsUrl);
    stompClient = Stomp.over(socket);
    stompClient.debug = null;   // 콘솔에 프레임 전문이 쏟아지는 것을 끈다

    stompClient.connect({}, function () {
      setStatus('연결됨', true);

      // 방마다 구독하지 않는다. 구독은 "내게 오는 것" 하나뿐이고,
      // 어느 방 메시지인지는 payload 의 chatId 로 가른다.
      stompClient.subscribe('/user/queue/messages', function (frame) {
        var payload = JSON.parse(frame.body);
        if (payload.event !== 'newMessage') return;

        var message = payload.data;
        if (message.chatId === config.chatId) {
          addBubble(message);
        } else {
          bumpUnread(message.chatId);
        }
      });
    }, function () {
      setStatus('연결 끊김', false);
    });
  }

  function send() {
    var text = input.value.trim();
    if (text.length === 0) return;
    if (config.chatId === null) return;              // 열린 방이 없으면 보낼 곳이 없다
    if (stompClient === null || !stompClient.connected) return;

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

  connect();
})();
