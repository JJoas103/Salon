<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | 커뮤니티</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="/resources/css/common.css">
  <link rel="stylesheet" href="/resources/css/user.css">
</head>
<body>
  <!-- 사이드바 -->
  <jsp:include page="../../includes/sidebar_common.jsp">
    <jsp:param name="menu" value="community" />
  </jsp:include>

  <div class="app-container">
    <main class="app-content community-content">
      <div class="empty-state">
        <i class="fas fa-ban"></i>
        <p>제재당한 유저입니다.<br>커뮤니티 기능 이용이 제한되었습니다.</p>
        <c:if test="${not empty sanctionType}">
          <p class="suspend-badge">
            <c:choose>
              <c:when test="${sanctionType == 'suspend_3d'}">3일 정지</c:when>
              <c:when test="${sanctionType == 'suspend_7d'}">7일 정지</c:when>
              <c:when test="${sanctionType == 'permanent'}">영구 정지</c:when>
              <c:otherwise><c:out value="${sanctionType}" /></c:otherwise>
            </c:choose>
            <c:if test="${not empty suspendedUntilText}"> (~${suspendedUntilText}까지)</c:if>
          </p>
        </c:if>
      </div>
    </main>
  </div>
</body>
</html>
