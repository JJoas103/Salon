<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | 커뮤니티 제재</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="/resources/css/common.css">
  <link rel="stylesheet" href="/resources/css/admin.css">
</head>
<body>
  <aside class="sidebar">
    <div class="sidebar-brand"><i class="fas fa-shield-alt"></i> ADMIN PANEL</div>
    <ul class="sidebar-menu">
      <li class="sidebar-item"><a href="/admin/salons"><i class="fas fa-store"></i> 미용실관리</a></li>
      <li class="sidebar-item active"><a href="/admin/community"><i class="fas fa-user-shield"></i> 커뮤니티 제재</a></li>
      <li class="sidebar-item"><a href="/admin/members"><i class="fas fa-users"></i> 회원관리</a></li>
      <li class="sidebar-item"><a href="/admin/banners"><i class="fas fa-ad"></i> 광고와 배너관리</a></li>
    </ul>
  </aside>
  <div class="app-container">
    <header class="app-header">
      <div style="font-weight: 700; font-size: 18px;">커뮤니티 제재</div>
      <div style="display: flex; align-items: center; gap: 10px;">
        <span style="font-size: 14px; font-weight: 600;">최고관리자</span>
        <div style="width: 32px; height: 32px; border-radius: 50%; background: #333; color: #fff; display: flex; align-items: center; justify-content: center; font-size: 12px;">A</div>
      </div>
    </header>
    <main class="app-content">
      <div class="admin-tabs">
        <button type="button" class="admin-tab-btn active js-admin-tab-btn" data-target="reportedPostsPanel">
          신고된 게시글 (${fn:length(reportedPosts)})
        </button>
        <button type="button" class="admin-tab-btn js-admin-tab-btn" data-target="reportedCommentsPanel">
          신고된 댓글 (${fn:length(reportedComments)})
        </button>
        <button type="button" class="admin-tab-btn js-admin-tab-btn" data-target="sanctionedUsersPanel">
          제재당한 유저 (${fn:length(sanctionedUsers)})
        </button>
      </div>

      <div class="modern-card admin-tab-panel active" id="reportedPostsPanel">
        <div>
          <table class="modern-table">
            <thead><tr><th>유형</th><th>대상(ID/글)</th><th>사유</th><th>작성자</th><th>상태</th><th>조치</th></tr></thead>
            <tbody>
              <c:forEach var="post" items="${reportedPosts}">
                <tr>
                  <td>게시글</td>
                  <td><a href="${ctx}/admin/community/${post.postId}">#${post.postId} - <c:out value="${post.title}" /></a></td>
                  <td><c:out value="${post.reportReasonSummary}" /></td>
                  <td><c:out value="${post.authorName}" /></td>
                  <td><span class="status-tag" style="background: #ffe3e3; color: #c92a2a;">블라인드됨</span></td>
                  <td>
                    <div class="action-dropdown">
                      <button type="button" class="btn-modern btn-outline js-action-toggle">조치 <i class="fas fa-caret-down"></i></button>
                      <div class="action-menu">
                        <button type="button" class="action-menu-item danger"
                                data-confirm="게시글을 삭제하고 작성자를 3일 정지하시겠습니까?"
                                data-form="post-s3-${post.postId}">삭제 + 3일 정지</button>
                        <button type="button" class="action-menu-item danger"
                                data-confirm="게시글을 삭제하고 작성자를 7일 정지하시겠습니까?"
                                data-form="post-s7-${post.postId}">삭제 + 7일 정지</button>
                        <button type="button" class="action-menu-item danger"
                                data-confirm="게시글을 삭제하고 작성자를 영구 정지하시겠습니까? 되돌릴 수 없습니다."
                                data-form="post-perm-${post.postId}">삭제 + 영구 정지</button>
                        <button type="button" class="action-menu-item"
                                data-confirm="신고를 기각하고 게시글을 복구하시겠습니까?"
                                data-form="post-dismiss-${post.postId}">반려 (신고 기각)</button>
                      </div>
                    </div>
                    <form id="post-s3-${post.postId}" class="hidden-action-form" method="post"
                          action="${ctx}/admin/community/${post.postId}/approve-delete">
                      <input type="hidden" name="sanctionType" value="suspend_3d">
                      <input type="hidden" name="adminReason" value="">
                    </form>
                    <form id="post-s7-${post.postId}" class="hidden-action-form" method="post"
                          action="${ctx}/admin/community/${post.postId}/approve-delete">
                      <input type="hidden" name="sanctionType" value="suspend_7d">
                      <input type="hidden" name="adminReason" value="">
                    </form>
                    <form id="post-perm-${post.postId}" class="hidden-action-form" method="post"
                          action="${ctx}/admin/community/${post.postId}/approve-delete">
                      <input type="hidden" name="sanctionType" value="permanent">
                      <input type="hidden" name="adminReason" value="">
                    </form>
                    <form id="post-dismiss-${post.postId}" class="hidden-action-form" method="post"
                          action="${ctx}/admin/community/${post.postId}/dismiss"></form>
                  </td>
                </tr>
              </c:forEach>
              <c:if test="${empty reportedPosts}">
                <tr><td colspan="6" style="text-align:center; color:#868e96;">블라인드된 게시글이 없습니다.</td></tr>
              </c:if>
            </tbody>
          </table>
        </div>
      </div>

      <div class="modern-card admin-tab-panel" id="reportedCommentsPanel">
        <div>
          <table class="modern-table">
            <thead><tr><th>소속 글</th><th>댓글 내용</th><th>사유</th><th>작성자</th><th>신고 수</th><th>조치</th></tr></thead>
            <tbody>
              <c:forEach var="comment" items="${reportedComments}">
                <tr>
                  <td><a href="${ctx}/common/community/${comment.postId}"><c:out value="${comment.postTitle}" /></a></td>
                  <td><c:out value="${comment.content}" /></td>
                  <td><c:out value="${comment.reportReasonSummary}" /></td>
                  <td><c:out value="${comment.authorName}" /></td>
                  <td>${comment.reportCount}</td>
                  <td>
                    <div class="action-dropdown">
                      <button type="button" class="btn-modern btn-outline js-action-toggle">조치 <i class="fas fa-caret-down"></i></button>
                      <div class="action-menu">
                        <button type="button" class="action-menu-item danger"
                                data-confirm="댓글을 삭제하고 작성자를 3일 정지하시겠습니까?"
                                data-form="comment-s3-${comment.commentId}">삭제 + 3일 정지</button>
                        <button type="button" class="action-menu-item danger"
                                data-confirm="댓글을 삭제하고 작성자를 7일 정지하시겠습니까?"
                                data-form="comment-s7-${comment.commentId}">삭제 + 7일 정지</button>
                        <button type="button" class="action-menu-item danger"
                                data-confirm="댓글을 삭제하고 작성자를 영구 정지하시겠습니까? 되돌릴 수 없습니다."
                                data-form="comment-perm-${comment.commentId}">삭제 + 영구 정지</button>
                        <button type="button" class="action-menu-item"
                                data-confirm="신고를 기각하시겠습니까? 댓글은 그대로 유지됩니다."
                                data-form="comment-dismiss-${comment.commentId}">반려 (신고 기각)</button>
                      </div>
                    </div>
                    <form id="comment-s3-${comment.commentId}" class="hidden-action-form" method="post"
                          action="${ctx}/admin/community/comment/${comment.commentId}/approve-delete">
                      <input type="hidden" name="sanctionType" value="suspend_3d">
                      <input type="hidden" name="adminReason" value="">
                    </form>
                    <form id="comment-s7-${comment.commentId}" class="hidden-action-form" method="post"
                          action="${ctx}/admin/community/comment/${comment.commentId}/approve-delete">
                      <input type="hidden" name="sanctionType" value="suspend_7d">
                      <input type="hidden" name="adminReason" value="">
                    </form>
                    <form id="comment-perm-${comment.commentId}" class="hidden-action-form" method="post"
                          action="${ctx}/admin/community/comment/${comment.commentId}/approve-delete">
                      <input type="hidden" name="sanctionType" value="permanent">
                      <input type="hidden" name="adminReason" value="">
                    </form>
                    <form id="comment-dismiss-${comment.commentId}" class="hidden-action-form" method="post"
                          action="${ctx}/admin/community/comment/${comment.commentId}/dismiss"></form>
                  </td>
                </tr>
              </c:forEach>
              <c:if test="${empty reportedComments}">
                <tr><td colspan="6" style="text-align:center; color:#868e96;">신고된 댓글이 없습니다.</td></tr>
              </c:if>
            </tbody>
          </table>
        </div>
      </div>

      <div class="modern-card admin-tab-panel" id="sanctionedUsersPanel">
        <div>
          <table class="modern-table">
            <thead><tr><th>회원</th><th>제재 상태</th><th>사유</th><th>제재일시</th><th>조치</th></tr></thead>
            <tbody>
              <c:forEach var="user" items="${sanctionedUsers}">
                <c:set var="latest" value="${latestSanctions[user.userId]}" />
                <tr>
                  <td><c:out value="${user.userName}" /> (<c:out value="${user.email}" />)</td>
                  <td>
                    <c:choose>
                      <c:when test="${user.status == 'banned'}">
                        <span class="status-tag status-banned">영구정지</span>
                      </c:when>
                      <c:otherwise>
                        <span class="status-tag status-suspended">정지중 (~${suspendedUntilText[user.userId]})</span>
                      </c:otherwise>
                    </c:choose>
                  </td>
                  <td>
                    <c:choose>
                      <c:when test="${not empty latest.commentContent}">댓글: <c:out value="${latest.commentContent}" /></c:when>
                      <c:when test="${not empty latest.postTitle}">게시글: <c:out value="${latest.postTitle}" /></c:when>
                      <c:otherwise>-</c:otherwise>
                    </c:choose>
                    <c:if test="${not empty latest.adminReason}">
                      <br><span style="color:var(--text-sub); font-size:12px;">사유: <c:out value="${latest.adminReason}" /></span>
                    </c:if>
                  </td>
                  <td>${fn:substring(latest.createdAt, 0, 16)}</td>
                  <td>
                    <form action="${ctx}/admin/community/user/${user.userId}/lift-sanction" method="post"
                          onsubmit="return confirm('이 회원의 제재를 해제하시겠습니까?')" class="inline-form">
                      <button type="submit" class="btn-modern btn-outline">제재 해제</button>
                    </form>
                  </td>
                </tr>
              </c:forEach>
              <c:if test="${empty sanctionedUsers}">
                <tr><td colspan="5" style="text-align:center; color:#868e96;">현재 제재중인 회원이 없습니다.</td></tr>
              </c:if>
            </tbody>
          </table>
        </div>
      </div>
    </main>
  </div>

  <script>
    (function() {
      // 탭 전환
      document.querySelectorAll('.js-admin-tab-btn').forEach(function (btn) {
        btn.addEventListener('click', function () {
          document.querySelectorAll('.js-admin-tab-btn').forEach(function (b) { b.classList.remove('active'); });
          document.querySelectorAll('.admin-tab-panel').forEach(function (p) { p.classList.remove('active'); });
          btn.classList.add('active');
          document.getElementById(btn.getAttribute('data-target')).classList.add('active');
        });
      });

      // 조치 드롭다운 열기/닫기
      document.querySelectorAll('.js-action-toggle').forEach(function (btn) {
        btn.addEventListener('click', function (e) {
          e.stopPropagation();
          var menu = btn.nextElementSibling;
          var wasOpen = menu.classList.contains('open');
          document.querySelectorAll('.action-menu.open').forEach(function (m) { m.classList.remove('open'); });
          if (!wasOpen) menu.classList.add('open');
        });
      });
      document.addEventListener('click', function () {
        document.querySelectorAll('.action-menu.open').forEach(function (m) { m.classList.remove('open'); });
      });

      // 드롭다운 항목 클릭 -> 기존 confirm 문구 -> (삭제+정지 항목이면 사유 입력) -> 숨은 폼 제출
      document.querySelectorAll('.action-menu-item').forEach(function (item) {
        item.addEventListener('click', function () {
          var msg = item.getAttribute('data-confirm');
          if (msg && !confirm(msg)) return;
          var form = document.getElementById(item.getAttribute('data-form'));
          if (!form) return;
          if (item.classList.contains('danger')) {
            var reason = prompt('제재 사유를 입력하세요 (제재당한 유저 화면에 표시됩니다):');
            if (reason === null || reason.trim() === '') return;
            var reasonInput = form.querySelector('input[name="adminReason"]');
            if (reasonInput) reasonInput.value = reason.trim();
          }
          form.submit();
        });
      });
    })();
  </script>
</body>
</html>
