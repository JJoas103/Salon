<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | 1대1 면담</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="/resources/css/common.css">
  <link rel="stylesheet" href="/resources/css/owner.css">
</head>
<body class="store-page">
  <jsp:include page="../includes/sidebar_owner.jsp">
      <jsp:param name="menu" value="chat" />
  </jsp:include>
  <jsp:include page="../includes/salon_gate_overlay.jsp" />

  <div class="app-container">
    <header class="app-header">
      <div style="font-size: 18px; font-weight: 700;">1대1 면담</div>
    </header>
    <main class="app-content">
      <div class="chat-layout">

        <!-- 방 목록 : 사이드바에서 고른 매장의 문의만 -->
        <div class="chat-list">
          <c:choose>
            <c:when test="${empty rooms}">
              <div class="chat-empty">들어온 문의가 없습니다.</div>
            </c:when>
            <c:otherwise>
              <c:forEach var="room" items="${rooms}">
                <a class="chat-room-link" data-chat-id="${room.chatId}"
                   href="<c:url value='/owner/chat'><c:param name="chatId" value="${room.chatId}"/></c:url>">
                  <div class="chat-item ${room.chatId == chatId ? 'active' : ''}">
                    <div class="chat-room-title">
                      <%-- 고객 이름은 사용자가 정한 값이므로 반드시 c:out 으로 이스케이프한다 --%>
                      <strong><c:out value="${room.partnerName}"/> 고객님</strong>
                      <span class="chat-unread" data-count="${room.unreadCount}">${room.unreadCount}</span>
                    </div>
                    <p class="chat-room-preview">
                      <c:out value="${empty room.lastMessage ? '대화를 시작해보세요' : room.lastMessage}"/>
                    </p>
                  </div>
                </a>
              </c:forEach>
            </c:otherwise>
          </c:choose>
        </div>

        <!-- 대화창 -->
        <div class="chat-window">
          <c:choose>
            <c:when test="${empty chatId}">
              <div class="chat-body">
                <div class="chat-empty">왼쪽에서 대화를 선택하세요.</div>
              </div>
            </c:when>
            <c:otherwise>
              <c:forEach var="room" items="${rooms}">
                <c:if test="${room.chatId == chatId}">
                  <div style="padding: 15px 20px; border-bottom: 1px solid var(--border); font-weight: 700;">
                    <c:out value="${room.partnerName}"/> 고객님과의 대화
                    <span id="wsStatus" class="chat-status">연결 중…</span>
                  </div>
                </c:if>
              </c:forEach>

              <div class="chat-body" id="chatBody">
                <c:choose>
                  <c:when test="${empty messages}">
                    <div class="chat-empty">첫 메시지를 보내보세요.</div>
                  </c:when>
                  <c:otherwise>
                    <c:forEach var="msg" items="${messages}">
                      <div class="msg-wrapper ${msg.senderId == user.userId ? 'outgoing' : 'incoming'}">
                        <div class="msg-bubble"><c:out value="${msg.messageContent}"/></div>
                        <%-- 내가 보냈는데 상대가 아직 안 읽은 것만 "1" 표시 --%>
                        <c:if test="${msg.senderId == user.userId and not msg.isRead}">
                          <span class="msg-read-mark">1</span>
                        </c:if>
                      </div>
                    </c:forEach>
                  </c:otherwise>
                </c:choose>
              </div>

              <div class="chat-footer">
                <input type="text" id="msgInput" class="modern-input" placeholder="메시지를 입력하세요..." style="flex:1;">
                <button type="button" id="sendBtn" class="btn-modern btn-primary">전송</button>
              </div>
            </c:otherwise>
          </c:choose>
        </div>

      </div>
    </main>
  </div>

  <jsp:include page="../includes/profile_modal.jsp">
      <jsp:param name="roleLabel" value="점주" />
  </jsp:include>

  <%-- 소켓 연결·스크립트 로드는 sidebar_owner.jsp 가 담당한다
       (모든 페이지에서 알림을 받아야 해서 사이드바로 올렸다) --%>
</body>
</html>
