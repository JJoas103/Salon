<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | 이벤트/공지사항</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="/resources/css/common.css">
  <link rel="stylesheet" href="/resources/css/owner.css">
</head>
<body class="store-page">
  <jsp:include page="../includes/sidebar_owner.jsp">
      <jsp:param name="menu" value="events" />
  </jsp:include>
  <jsp:include page="../includes/salon_gate_overlay.jsp" />
  <div class="app-container">
    <header class="app-header">
      <div style="font-size: 18px; font-weight: 700;">이벤트/공지사항</div>
    </header>
    <main class="app-content">
      <c:if test="${not empty error}">
        <p class="error-text"><c:out value="${error}" /></p>
      </c:if>
      <c:if test="${not empty success}">
        <p class="success-text"><c:out value="${success}" /></p>
      </c:if>

      <div class="modern-card">
        <div class="flex-between" style="margin-bottom: 20px;">
          <h3>이벤트 및 공지사항 관리</h3>
          <button type="button" id="noticeWriteBtn" class="btn-modern btn-primary"><i class="fas fa-plus"></i> 글쓰기</button>
        </div>
        <form id="noticeWriteForm" method="post" action="<c:url value='/owner/events'/>" enctype="multipart/form-data" style="display:none; flex-direction:column; gap:16px; margin-bottom: 20px;">
          <div>
            <label style="font-size: 13px; font-weight: 700; color: var(--text-sub);">제목</label>
            <input type="text" name="title" class="modern-input" maxlength="255" required>
          </div>
          <div>
            <label style="font-size: 13px; font-weight: 700; color: var(--text-sub);">내용</label>
            <textarea name="content" class="modern-input" style="height: 100px; resize: none;" required></textarea>
          </div>
          <div>
            <label style="font-size: 13px; font-weight: 700; color: var(--text-sub);">사진 (선택)</label>
            <input type="file" name="imageFile" accept="image/jpeg,image/png,image/gif,image/webp" class="modern-input">
          </div>
          <button type="submit" class="btn-modern btn-primary" style="align-self: flex-start;">등록</button>
        </form>
        <table class="modern-table">
          <thead>
            <tr><th>구분</th><th>제목</th><th>등록일</th><th>상태</th><th>관리</th></tr>
          </thead>
          <tbody>
            <c:forEach var="notice" items="${notices}">
              <tr>
                <td><span class="status-badge status-confirmed">공지사항</span></td>
                <td style="font-weight: 600;">
                  <div style="display:flex; align-items:center; gap:10px;">
                    <c:if test="${not empty notice.imageUrl}">
                      <img src="<c:url value='${notice.imageUrl}'/>" alt="" class="notice-thumb lightbox-img">
                    </c:if>
                    <span><c:out value="${notice.title}"/></span>
                  </div>
                </td>
                <td>${notice.createdAt}</td>
                <td><span class="status-badge status-confirmed">게시중</span></td>
                <td>
                  <form method="post" action="<c:url value='/owner/events/${notice.noticeId}/delete'/>"
                        onsubmit="return confirm('이 공지사항을 삭제하시겠습니까?')" style="display:inline;">
                    <button type="submit" class="btn-modern btn-danger">삭제</button>
                  </form>
                </td>
              </tr>
            </c:forEach>
            <c:if test="${empty notices}">
              <tr><td colspan="5" style="text-align:center; color: var(--text-sub);">등록된 공지사항이 없습니다.</td></tr>
            </c:if>
          </tbody>
        </table>
      </div>
    </main>
  </div>

  <jsp:include page="../includes/profile_modal.jsp">
      <jsp:param name="roleLabel" value="점주" />
  </jsp:include>
  <script>
    (function () {
      var btn = document.getElementById('noticeWriteBtn');
      var form = document.getElementById('noticeWriteForm');
      if (btn && form) {
        btn.addEventListener('click', function () {
          form.style.display = form.style.display === 'none' ? 'flex' : 'none';
        });
      }
    })();
  </script>
  <script src="<c:url value='/resources/js/lightbox.js'/>"></script>
</body>
</html>
