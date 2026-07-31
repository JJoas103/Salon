<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | 1:1 상담 채팅</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="/resources/css/common.css">
  <link rel="stylesheet" href="/resources/css/user.css">
</head>
<body>
  <!-- 사이드바 -->
  <jsp:include page="../includes/sidebar_common.jsp">
      <jsp:param name="menu" value="chat" />
  </jsp:include>

  <div class="app-container">
    <main class="app-content">
      <div class="chat-layout">

        <!-- 방 목록 -->
        <div class="chat-sidebar">
          <c:choose>
            <c:when test="${empty rooms}">
              <div class="chat-empty">
                아직 문의한 매장이 없습니다.<br>
                매장 상세에서 <strong>1:1 문의</strong>를 눌러 시작해보세요.
              </div>
            </c:when>
            <c:otherwise>
              <c:forEach var="room" items="${rooms}">
                <a class="chat-room-link" data-chat-id="${room.chatId}"
                   href="<c:url value='/common/chat'><c:param name="chatId" value="${room.chatId}"/></c:url>">
                  <div class="chat-room-item ${room.chatId == chatId ? 'active' : ''}">
                    <div style="flex:1;">
                      <div class="chat-room-title">
                        <%-- 매장명·이름은 사용자가 정한 값이므로 반드시 c:out 으로 이스케이프한다 --%>
                        <strong><c:out value="${room.salonName}"/></strong>
                        <span class="chat-unread" data-count="${room.unreadCount}">${room.unreadCount}</span>
                      </div>
                      <p class="chat-room-preview">
                        <c:out value="${empty room.lastMessage ? '대화를 시작해보세요' : room.lastMessage}"/>
                      </p>
                    </div>
                  </div>
                </a>
              </c:forEach>
            </c:otherwise>
          </c:choose>
        </div>

        <!-- 대화창 -->
        <div class="chat-main">
          <c:choose>
            <c:when test="${empty chatId}">
              <div class="chat-body">
                <div class="chat-empty">왼쪽에서 대화를 선택하세요.</div>
              </div>
            </c:when>
            <c:otherwise>
              <c:forEach var="room" items="${rooms}">
                <c:if test="${room.chatId == chatId}">
                  <div class="chat-header">
                    <strong><c:out value="${room.salonName}"/> (<c:out value="${room.partnerName}"/> 원장)</strong>
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
                <button type="button" id="sendBtn" class="btn-modern btn-primary">보내기</button>
              </div>
            </c:otherwise>
          </c:choose>
        </div>

      </div>
    </main>
  </div>

  <%-- 소켓 연결·스크립트 로드는 sidebar_common.jsp 가 담당한다
       (모든 페이지에서 알림을 받아야 해서 사이드바로 올렸다) --%>
</body>
</html>
