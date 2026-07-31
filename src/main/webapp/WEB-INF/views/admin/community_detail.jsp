<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | 신고 게시글 상세</title>
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
      <a href="${ctx}/admin/community" style="display:inline-block; margin-bottom:16px; color:var(--text-sub); text-decoration:none;">
        <i class="fas fa-arrow-left"></i> 목록으로
      </a>
      <c:choose>
        <c:when test="${empty post}">
          <div class="modern-card">
            <p style="text-align:center; color:#868e96;">해당 게시글을 찾을 수 없습니다.</p>
          </div>
        </c:when>
        <c:otherwise>
          <div class="modern-card">
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:16px;">
              <h3>#${post.postId} - <c:out value="${post.title}" /></h3>
              <span class="status-tag" style="background: #ffe3e3; color: #c92a2a;">블라인드됨</span>
            </div>
            <p style="color:var(--text-sub); font-size:14px; margin-bottom:6px;">
              작성자 <c:out value="${post.authorName}" /> &nbsp;·&nbsp; ${fn:substring(post.createdAt, 0, 16)}
            </p>
            <p style="color:#c92a2a; font-size:14px; font-weight:700; margin-bottom:20px;">
              누적 신고 ${post.reportCount}건 (<c:out value="${post.reportReasonSummary}" />)
            </p>

            <c:if test="${not empty otherReasonDetails}">
              <div style="background:var(--bg-sub); border-radius:var(--radius-md); padding:14px 16px; margin-bottom:20px;">
                <p style="font-size:13px; font-weight:700; color:var(--text-sub); margin-bottom:8px;">기타 사유 상세</p>
                <ul style="margin:0; padding-left:18px; font-size:14px; line-height:1.6;">
                  <c:forEach var="detail" items="${otherReasonDetails}">
                    <li><c:out value="${detail}" /></li>
                  </c:forEach>
                </ul>
              </div>
            </c:if>

            <div style="background:var(--bg-sub); border-radius:var(--radius-md); padding:14px 16px; margin-bottom:20px;">
              <p style="font-size:13px; font-weight:700; color:var(--text-sub); margin-bottom:8px;">
                작성자 신고/제재 이력 (다른 글 포함 누적 신고 ${totalReportsOnOtherPosts}건)
              </p>
              <c:choose>
                <c:when test="${empty sanctionHistory}">
                  <p style="font-size:13px; color:#868e96; margin:0;">과거 제재 이력이 없습니다.</p>
                </c:when>
                <c:otherwise>
                  <ul style="margin:0; padding-left:18px; font-size:13px; line-height:1.7;">
                    <c:forEach var="s" items="${sanctionHistory}">
                      <li>${fn:substring(s.createdAt, 0, 10)} -
                        <c:choose>
                          <c:when test="${s.sanctionType == 'suspend_3d'}">3일 정지</c:when>
                          <c:when test="${s.sanctionType == 'suspend_7d'}">7일 정지</c:when>
                          <c:when test="${s.sanctionType == 'permanent'}">영구 정지</c:when>
                          <c:otherwise><c:out value="${s.sanctionType}" /></c:otherwise>
                        </c:choose>
                        (원인글: <c:out value="${s.postTitle}" />)</li>
                    </c:forEach>
                  </ul>
                </c:otherwise>
              </c:choose>
            </div>

            <c:if test="${not empty post.imageUrl}">
              <img src="${ctx}/upload/${post.imageUrl}" alt="첨부 이미지"
                   style="max-width:100%; border-radius:var(--radius-md); margin-bottom:20px;" />
            </c:if>

            <p style="white-space:pre-wrap; line-height:1.6; margin-bottom:24px;"><c:out value="${post.content}" /></p>

            <div>
              <form action="${ctx}/admin/community/${post.postId}/approve-delete" method="post"
                    onsubmit="return confirmAndReason(this, '게시글을 삭제하고 작성자를 3일 정지하시겠습니까?')"
                    class="inline-form">
                <input type="hidden" name="sanctionType" value="suspend_3d">
                <input type="hidden" name="adminReason" value="">
                <button type="submit" class="btn-modern btn-danger">삭제+3일정지</button>
              </form>
              <form action="${ctx}/admin/community/${post.postId}/approve-delete" method="post"
                    onsubmit="return confirmAndReason(this, '게시글을 삭제하고 작성자를 7일 정지하시겠습니까?')"
                    class="inline-form">
                <input type="hidden" name="sanctionType" value="suspend_7d">
                <input type="hidden" name="adminReason" value="">
                <button type="submit" class="btn-modern btn-danger">삭제+7일정지</button>
              </form>
              <form action="${ctx}/admin/community/${post.postId}/approve-delete" method="post"
                    onsubmit="return confirmAndReason(this, '게시글을 삭제하고 작성자를 영구 정지하시겠습니까? 되돌릴 수 없습니다.')"
                    class="inline-form">
                <input type="hidden" name="sanctionType" value="permanent">
                <input type="hidden" name="adminReason" value="">
                <button type="submit" class="btn-modern btn-danger">삭제+영구정지</button>
              </form>
              <form action="${ctx}/admin/community/${post.postId}/dismiss" method="post"
                    onsubmit="return confirm('신고를 기각하고 게시글을 복구하시겠습니까?')"
                    class="inline-form">
                <button type="submit" class="btn-modern btn-outline">반려</button>
              </form>
            </div>
          </div>
        </c:otherwise>
      </c:choose>
    </main>
  </div>

  <script>
    function confirmAndReason(form, confirmMsg) {
      if (!confirm(confirmMsg)) return false;
      var reason = prompt('제재 사유를 입력하세요 (제재당한 유저 화면에 표시됩니다):');
      if (reason === null || reason.trim() === '') return false;
      form.querySelector('input[name="adminReason"]').value = reason.trim();
      return true;
    }
  </script>
</body>
</html>
