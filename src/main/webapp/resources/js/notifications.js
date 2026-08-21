/* 알림 드롭다운 (사이드바 벨).
 *
 * 실시간 push는 chat.js 가 이미 갖고 있는 /user/queue/messages 구독을 그대로 재사용한다.
 * chat.js 의 handleEvent() 가 "newNotification" 이벤트를 받으면 window.NotifBridge.onNotification()
 * 을 호출해주므로, 여기서는 새 소켓 연결 없이 그 결과만 받아 배지/목록을 갱신한다.
 */
(function () {

  var config = window.NOTIF_CONFIG;
  if (!config) return;

  var bellBtn  = document.getElementById('notifBellBtn');
  var panel    = document.getElementById('notifPanel');
  var list     = document.getElementById('notifList');
  var badge    = document.getElementById('navUnread');
  var readAllBtn = document.getElementById('notifReadAllBtn');
  if (!bellBtn || !panel) return;

  var unreadCount = 0;

  var TYPE_ICON = {
    RESERVATION: 'fa-calendar-check',
    COUPON: 'fa-ticket',
    CHAT: 'fa-comment-dots',
    NOTICE: 'fa-gift'
  };

  function renderBadge(count) {
    unreadCount = count;
    if (!badge) return;
    badge.dataset.count = count;
    badge.textContent = count > 99 ? '99+' : count;
  }

  function loadUnreadCount() {
    fetch(config.unreadCountUrl, { credentials: 'same-origin' })
      .then(function (res) { return res.json(); })
      .then(function (data) { renderBadge(data.count); })
      .catch(function () { /* 배지는 부가 정보라 실패해도 화면을 막지 않는다 */ });
  }

  function timeAgo(iso) {
    if (!iso) return '';
    var diffMs = Date.now() - new Date(iso).getTime();
    var min = Math.floor(diffMs / 60000);
    if (min < 1) return '방금 전';
    if (min < 60) return min + '분 전';
    var hour = Math.floor(min / 60);
    if (hour < 24) return hour + '시간 전';
    var day = Math.floor(hour / 24);
    if (day < 7) return day + '일 전';
    return new Date(iso).toLocaleDateString();
  }

  function renderList(items) {
    list.innerHTML = '';

    if (!items || items.length === 0) {
      var empty = document.createElement('div');
      empty.className = 'notif-empty';
      empty.innerHTML = '<i class="fas fa-bell-slash"></i>새로운 알림이 없습니다';
      list.appendChild(empty);
      return;
    }

    items.forEach(function (item) {
      var row = document.createElement('div');
      row.className = 'notif-item' + (item.read ? '' : ' unread');

      var icon = document.createElement('div');
      icon.className = 'notif-icon type-' + item.type;
      icon.innerHTML = '<i class="fas ' + (TYPE_ICON[item.type] || 'fa-bell') + '"></i>';

      var body = document.createElement('div');
      body.className = 'notif-body';

      var title = document.createElement('div');
      title.className = 'notif-title';
      title.textContent = item.title;

      var msg = document.createElement('div');
      msg.className = 'notif-msg';
      msg.textContent = item.message;

      var time = document.createElement('div');
      time.className = 'notif-time';
      time.textContent = timeAgo(item.createdAt);

      body.appendChild(title);
      body.appendChild(msg);
      body.appendChild(time);
      row.appendChild(icon);
      row.appendChild(body);

      row.addEventListener('click', function () {
        fetch(config.baseUrl + '/' + item.notificationId + '/read', {
          method: 'POST', credentials: 'same-origin'
        }).catch(function () {});
        if (!item.read) renderBadge(Math.max(0, unreadCount - 1));
        if (item.linkUrl) location.href = item.linkUrl;
      });

      list.appendChild(row);
    });
  }

  function loadList() {
    fetch(config.baseUrl, { credentials: 'same-origin' })
      .then(function (res) { return res.json(); })
      .then(renderList)
      .catch(function () {
        list.innerHTML = '<div class="notif-empty">알림을 불러오지 못했습니다</div>';
      });
  }

  function openPanel() {
    panel.style.display = 'flex';
    loadList();
  }

  function closePanel() {
    panel.style.display = 'none';
  }

  bellBtn.addEventListener('click', function (e) {
    e.stopPropagation();
    if (panel.style.display === 'flex') {
      closePanel();
    } else {
      openPanel();
    }
  });

  document.addEventListener('click', function (e) {
    if (panel.style.display === 'flex' && !panel.contains(e.target) && e.target !== bellBtn) {
      closePanel();
    }
  });

  if (readAllBtn) {
    readAllBtn.addEventListener('click', function (e) {
      e.stopPropagation();
      fetch(config.readAllUrl, { method: 'POST', credentials: 'same-origin' })
        .then(function () {
          loadList();
          renderBadge(0);
        })
        .catch(function () {});
    });
  }

  // chat.js 가 웹소켓으로 받은 "newNotification" 이벤트를 넘겨주는 창구.
  window.NotifBridge = {
    onNotification: function () {
      renderBadge(unreadCount + 1);
      if (panel.style.display === 'flex') loadList();
    }
  };

  loadUnreadCount();
})();
