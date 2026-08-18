<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%-- 현재 페이지가 넘겨준 메뉴 키. 예) <jsp:param name="menu" value="reservations"/>
     포함하는 컨트롤러는 ${salons} 모델(점주 소유 매장 목록)을 채워줘야 매장 선택 모달이 뜬다. --%>
<c:set var="menu" value="${param.menu}" />
<c:set var="selectedSalonName" value="" />
<c:forEach var="s" items="${salons}">
  <c:if test="${s.salonId == sessionScope.selectedSalonId}"><c:set var="selectedSalonName" value="${s.salonName}" /></c:if>
</c:forEach>
<aside class="sidebar">
  <div class="sidebar-brand"><i class="fas fa-scissors" style="color: var(--accent);"></i><span>HAIR RESERVE</span></div>

  <div class="salon-select-card" id="openSalonSelectBtn" title="매장 선택">
    <div class="salon-select-thumb"><i class="fas fa-store"></i></div>
    <div class="salon-select-info">
      <div class="salon-select-label">선택된 매장</div>
      <div class="salon-select-name">${empty selectedSalonName ? '매장을 선택해주세요' : selectedSalonName}</div>
    </div>
    <i class="fas fa-chevron-down salon-select-chev"></i>
  </div>

  <ul class="sidebar-menu">
    <li class="sidebar-item ${menu == 'store' ? 'active' : ''}" data-needs-salon="true">
      <a href="<c:url value='/owner/store'/>"><i class="fas fa-store"></i> 매장정보 관리</a>
    </li>
    <li class="sidebar-item ${menu == 'staff' ? 'active' : ''}" data-needs-salon="true">
      <a href="<c:url value='/owner/staff'/>"><i class="fas fa-users"></i> 직원관리</a>
    </li>
    <li class="sidebar-item ${menu == 'reservations' ? 'active' : ''}" data-needs-salon="true">
      <a href="<c:url value='/owner/reservations'/>"><i class="fas fa-calendar-check"></i> 예약현황관리</a>
    </li>
    <li class="sidebar-item ${menu == 'chat' ? 'active' : ''}" data-needs-salon="true">
      <a href="<c:url value='/owner/chat'/>"><i class="fas fa-comments"></i> 1:1 면담<span id="navUnread" class="nav-unread" data-count="0"></span></a>
    </li>
  </ul>

  <%-- 채팅 소켓은 사이드바에서 연다. 채팅 페이지에서만 열면 다른 화면(예약현황 등)에 있을 때
       새 메시지를 받을 방법이 없어 알림 배지를 올릴 수 없다.
       chat.js 는 채팅 페이지 전용 요소(#chatBody 등)가 없으면 알림 역할만 한다. --%>
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

  <div class="sidebar-salon-notice" id="salonNotice">매장을 선택해주세요</div>

  <div class="sidebar-footer">
    <a href="<c:url value='/user/logout'/>" class="sidebar-item-logout"><i class="fas fa-sign-out-alt"></i> 로그아웃</a>
  </div>
</aside>

<!-- 매장 선택 모달 -->
<div class="modal-overlay" id="salonSelectModal">
  <div class="modal-box" style="max-width:640px;">
    <div class="modal-header">
      <h3 style="font-size: 18px;"><i class="fas fa-store" style="margin-right:8px; color:var(--accent);"></i>매장 선택</h3>
      <button type="button" class="modal-close" id="closeSalonSelectBtn"><i class="fas fa-times"></i></button>
    </div>
    <c:choose>
      <c:when test="${not empty salons}">
        <div class="carousel-wrap">
          <div class="carousel-nav prev" id="salonSelectPrevBtn">&lsaquo;</div>
          <div class="carousel-nav next" id="salonSelectNextBtn">&rsaquo;</div>
          <div class="carousel-track" id="salonSelectTrack">
            <c:forEach var="s" items="${salons}">
              <a class="salon-card" style="text-decoration:none; color:inherit; ${sessionScope.selectedSalonId == s.salonId ? 'outline:2px solid var(--accent);' : ''}"
                 href="<c:url value='/owner/select-salon'><c:param name="salonId" value="${s.salonId}"/></c:url>">
                <div class="salon-thumb"><i class="fas fa-store"></i></div>
                <div class="salon-body">
                  <div class="salon-name">${s.salonName}</div>
                  <div class="salon-meta">
                    <span>${s.address}</span>
                    <span>${s.phoneNumber}</span>
                  </div>
                </div>
              </a>
            </c:forEach>
          </div>
        </div>
      </c:when>
      <c:otherwise>
        <p style="font-size:14px; color:var(--text-sub);">등록된 매장이 없습니다.</p>
      </c:otherwise>
    </c:choose>
  </div>
</div>

<script>
  (function () {
    var salonSelected = ${not empty sessionScope.selectedSalonId ? 'true' : 'false'};

    if (!salonSelected) {
      document.querySelectorAll('.sidebar-item[data-needs-salon="true"]').forEach(function (li) {
        li.classList.add('is-locked');
      });
      var selectBtn = document.getElementById('openSalonSelectBtn');
      if (selectBtn) selectBtn.classList.add('needs-attention');
    }

    var salonModal = document.getElementById('salonSelectModal');
    var openBtn = document.getElementById('openSalonSelectBtn');
    if (openBtn) {
      openBtn.addEventListener('click', function (e) {
        e.preventDefault();
        salonModal.classList.add('active');
      });
    }
    document.getElementById('closeSalonSelectBtn').addEventListener('click', function () {
      salonModal.classList.remove('active');
    });
    salonModal.addEventListener('click', function (e) {
      if (e.target === salonModal) salonModal.classList.remove('active');
    });

    var track = document.getElementById('salonSelectTrack');
    if (track) {
      var cardWidth = 240 + 16;
      var prevBtn = document.getElementById('salonSelectPrevBtn');
      var nextBtn = document.getElementById('salonSelectNextBtn');
      if (prevBtn) prevBtn.addEventListener('click', function () { track.scrollBy({ left: -cardWidth, behavior: 'smooth' }); });
      if (nextBtn) nextBtn.addEventListener('click', function () { track.scrollBy({ left: cardWidth, behavior: 'smooth' }); });
    }

    var notice = document.getElementById('salonNotice');
    var noticeTimer = null;
    function showNotice() {
      notice.classList.add('show');
      clearTimeout(noticeTimer);
      noticeTimer = setTimeout(function () { notice.classList.remove('show'); }, 3000);
    }

    document.querySelectorAll('.sidebar-item[data-needs-salon="true"] a').forEach(function (link) {
      link.addEventListener('click', function (e) {
        if (!salonSelected) {
          e.preventDefault();
          showNotice();
        }
      });
    });
  })();
</script>
