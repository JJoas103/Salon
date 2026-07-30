<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | <c:out value="${selectedPost.title}" /></title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="/resources/css/common.css">
  <link rel="stylesheet" href="/resources/css/user.css">
  <link rel="stylesheet" href="/resources/css/auth.css">
</head>
<body>
  <!-- 사이드바 -->
  <jsp:include page="../../includes/sidebar_common.jsp">
    <jsp:param name="menu" value="community" />
  </jsp:include>

  <div class="app-container">
    <main class="app-content community-content">
      <div class="detail-wrap">

        <a href="${ctx}/common/community" class="back-btn">
          <i class="fas fa-arrow-left"></i> 목록으로
        </a>

        <div class="detail-card">

          <c:if test="${param.reported == 'true'}">
            <p class="success-text" style="margin-bottom:16px;">신고가 접수되었습니다.</p>
          </c:if>
          <c:if test="${param.reported == 'duplicate'}">
            <p class="error-text" style="margin-bottom:16px;">이미 신고한 게시글입니다.</p>
          </c:if>
          <c:if test="${param.reported == 'invalid'}">
            <p class="error-text" style="margin-bottom:16px;">신고 사유를 선택해주세요.</p>
          </c:if>

          <%-- 글 헤더 --%>
          <div class="detail-header">
            <c:if test="${not empty selectedPost.category}">
              <span class="category-badge"><c:out value="${selectedPost.category}" /></span>
            </c:if>
            <div class="detail-title-row">
              <h1><c:out value="${selectedPost.title}" /></h1>
              <c:if test="${selectedPost.userId == currentUserId}">
                <div class="detail-actions">
                  <a href="${ctx}/common/community/${selectedPost.postId}/edit"
                     class="btn-modern btn-outline btn-sm">수정</a>
                  <form action="${ctx}/common/community/${selectedPost.postId}/delete" method="post"
                        onsubmit="return confirm('정말 삭제하시겠습니까?')" class="inline-form">
                    <button type="submit" class="btn-modern btn-danger btn-sm">삭제</button>
                  </form>
                </div>
              </c:if>
              <c:if test="${currentUserId != null && selectedPost.userId != currentUserId}">
                <div class="detail-actions">
                  <c:choose>
                    <c:when test="${hasReported}">
                      <button type="button" class="btn-modern btn-outline btn-sm" disabled>신고 완료</button>
                    </c:when>
                    <c:otherwise>
                      <button type="button" class="btn-modern btn-outline btn-sm" id="openReportModalBtn">신고</button>
                    </c:otherwise>
                  </c:choose>
                </div>
              </c:if>
            </div>
            <div class="detail-meta">
              <span><i class="fas fa-user-circle"></i> <c:out value="${selectedPost.authorName}" /></span>
              <span><i class="fas fa-clock"></i> ${fn:substring(selectedPost.createdAt, 0, 16)}</span>
              <span><i class="fas fa-eye"></i> 조회 ${selectedPost.viewCount}</span>
              <c:if test="${not empty selectedPost.salonName}">
                <span class="meta-salon">
                  <i class="fas fa-scissors"></i> <c:out value="${selectedPost.salonName}" />
                </span>
              </c:if>
            </div>
          </div>

          <%-- 글 본문 --%>
          <div class="detail-body">
            <c:if test="${not empty selectedPost.imageUrl}">
              <img src="${ctx}/upload/${selectedPost.imageUrl}"
                   alt="첨부 이미지" class="post-image" />
            </c:if>
            <span id="postBody"><c:out value="${selectedPost.content}" /></span>
          </div>

          <%-- 좋아요 / 별로예요 --%>
          <div class="reaction-bar">
            <form action="${ctx}/common/community/${selectedPost.postId}/react" method="post" class="inline-form">
              <input type="hidden" name="type" value="like">
              <button type="submit"
                      class="react-btn ${'like' == userReaction ? 'active-like' : ''}">
                &#128077; 좋아요 <span class="react-count">${selectedPost.likeCount}</span>
              </button>
            </form>
            <form action="${ctx}/common/community/${selectedPost.postId}/react" method="post" class="inline-form">
              <input type="hidden" name="type" value="dislike">
              <button type="submit"
                      class="react-btn ${'dislike' == userReaction ? 'active-dislike' : ''}">
                &#128078; 별로예요 <span class="react-count">${selectedPost.dislikeCount}</span>
              </button>
            </form>
          </div>

          <%-- 댓글 --%>
          <div class="comment-section">
            <p class="comment-section-title">
              댓글 <span class="comment-count">${fn:length(comments)}</span>개
            </p>

            <c:forEach var="comment" items="${comments}">
              <div class="comment-item">
                <div class="comment-meta">
                  <span>
                    <i class="fas fa-user-circle"></i>
                    <c:out value="${comment.authorName}" />
                    &nbsp;·&nbsp; ${fn:substring(comment.createdAt, 0, 16)}
                  </span>
                  <div class="comment-meta-actions">
                    <c:if test="${comment.userId == currentUserId}">
                      <form action="${ctx}/common/community/${selectedPost.postId}/comment/${comment.commentId}/delete"
                            method="post"
                            onsubmit="return confirm('댓글을 삭제하시겠습니까?')"
                            class="inline-form">
                        <button type="submit" class="comment-delete-btn">
                          <i class="fas fa-times"></i>
                        </button>
                      </form>
                    </c:if>
                    <c:if test="${currentUserId != null && comment.userId != currentUserId}">
                      <c:choose>
                        <c:when test="${reportedCommentIds.contains(comment.commentId)}">
                          <button type="button" class="comment-report-btn" disabled>신고 완료</button>
                        </c:when>
                        <c:otherwise>
                          <button type="button" class="comment-report-btn js-open-comment-report"
                                  data-target="commentReportModal-${comment.commentId}">신고</button>
                        </c:otherwise>
                      </c:choose>
                    </c:if>
                  </div>
                </div>
                <p class="comment-content"><c:out value="${comment.content}" /></p>
              </div>

              <c:if test="${currentUserId != null && comment.userId != currentUserId && !reportedCommentIds.contains(comment.commentId)}">
                <div class="modal-overlay js-comment-report-modal" id="commentReportModal-${comment.commentId}">
                  <div class="modal-box">
                    <div class="modal-header">
                      <h3 style="font-size: 18px;"><i class="fas fa-flag" style="margin-right:8px; color:var(--accent);"></i>댓글 신고</h3>
                      <button type="button" class="modal-close js-close-comment-report"><i class="fas fa-times"></i></button>
                    </div>
                    <form action="${ctx}/common/community/${selectedPost.postId}/comment/${comment.commentId}/report" method="post">
                      <label class="role-label">신고 사유를 선택해주세요</label>
                      <div class="report-reason-list">
                        <label class="report-reason-option"><input type="radio" name="reason" value="spam" required> 스팸/광고</label>
                        <label class="report-reason-option"><input type="radio" name="reason" value="illegal"> 음란물/불법 정보</label>
                        <label class="report-reason-option"><input type="radio" name="reason" value="abuse"> 욕설/비하/도배</label>
                        <label class="report-reason-option"><input type="radio" name="reason" value="privacy"> 개인정보 노출</label>
                        <label class="report-reason-option"><input type="radio" name="reason" value="other" class="js-comment-reason-other"> 기타 (직접 입력)</label>
                      </div>
                      <div class="js-comment-detail-wrap" style="display:none;">
                        <textarea name="reasonDetail" class="report-detail-input" rows="3" placeholder="신고 사유를 입력해주세요"></textarea>
                      </div>
                      <button type="submit" class="btn-modern btn-primary" style="width:100%; margin-top:15px;">신고하기</button>
                    </form>
                  </div>
                </div>
              </c:if>
            </c:forEach>

            <form action="${ctx}/common/community/${selectedPost.postId}/comment" method="post">
              <div class="comment-form">
                <textarea name="content" class="comment-input" rows="2"
                          placeholder="댓글을 입력하세요..." required></textarea>
                <button type="submit" class="btn-modern btn-primary comment-submit">
                  등록
                </button>
              </div>
            </form>
          </div>

        </div>
      </div>
    </main>
  </div>

  <c:if test="${currentUserId != null && selectedPost.userId != currentUserId && !hasReported}">
    <!-- 신고 사유 선택 모달 -->
    <div class="modal-overlay" id="reportModal">
      <div class="modal-box">
        <div class="modal-header">
          <h3 style="font-size: 18px;"><i class="fas fa-flag" style="margin-right:8px; color:var(--accent);"></i>게시글 신고</h3>
          <button type="button" class="modal-close" id="closeReportModalBtn"><i class="fas fa-times"></i></button>
        </div>
        <form action="${ctx}/common/community/${selectedPost.postId}/report" method="post" id="reportForm">
          <label class="role-label">신고 사유를 선택해주세요</label>
          <div class="report-reason-list">
            <label class="report-reason-option"><input type="radio" name="reason" value="spam" required> 스팸/광고</label>
            <label class="report-reason-option"><input type="radio" name="reason" value="illegal"> 음란물/불법 정보</label>
            <label class="report-reason-option"><input type="radio" name="reason" value="abuse"> 욕설/비하/도배</label>
            <label class="report-reason-option"><input type="radio" name="reason" value="privacy"> 개인정보 노출</label>
            <label class="report-reason-option"><input type="radio" name="reason" value="other" id="reportReasonOther"> 기타 (직접 입력)</label>
          </div>
          <div id="reportDetailWrap" style="display:none;">
            <textarea name="reasonDetail" id="reportDetailInput" class="report-detail-input" rows="3" placeholder="신고 사유를 입력해주세요"></textarea>
          </div>
          <button type="submit" class="btn-modern btn-primary" style="width:100%; margin-top:15px;">신고하기</button>
        </form>
      </div>
    </div>
  </c:if>

  <script>
    (function() {
      var el = document.getElementById('postBody');
      if (el && el.firstChild && el.firstChild.nodeType === 3) {
        el.firstChild.nodeValue = el.firstChild.nodeValue.replace(/^\s+/, '');
      }
    })();
  </script>

  <script>
    (function() {
      var openBtn = document.getElementById('openReportModalBtn');
      var modal = document.getElementById('reportModal');
      if (!openBtn || !modal) return;

      var closeBtn = document.getElementById('closeReportModalBtn');
      var otherRadio = document.getElementById('reportReasonOther');
      var detailWrap = document.getElementById('reportDetailWrap');
      var detailInput = document.getElementById('reportDetailInput');

      openBtn.addEventListener('click', function () { modal.classList.add('active'); });
      closeBtn.addEventListener('click', function () { modal.classList.remove('active'); });
      modal.addEventListener('click', function (e) { if (e.target === modal) modal.classList.remove('active'); });

      document.querySelectorAll('#reportForm input[name="reason"]').forEach(function (radio) {
        radio.addEventListener('change', function () {
          var isOther = otherRadio.checked;
          detailWrap.style.display = isOther ? 'block' : 'none';
          detailInput.required = isOther;
        });
      });
    })();
  </script>

  <script>
    (function() {
      document.querySelectorAll('.js-open-comment-report').forEach(function (btn) {
        btn.addEventListener('click', function () {
          var modal = document.getElementById(btn.getAttribute('data-target'));
          if (modal) modal.classList.add('active');
        });
      });

      document.querySelectorAll('.js-comment-report-modal').forEach(function (modal) {
        var closeBtn = modal.querySelector('.js-close-comment-report');
        var otherRadio = modal.querySelector('.js-comment-reason-other');
        var detailWrap = modal.querySelector('.js-comment-detail-wrap');
        var detailInput = detailWrap ? detailWrap.querySelector('textarea') : null;

        if (closeBtn) closeBtn.addEventListener('click', function () { modal.classList.remove('active'); });
        modal.addEventListener('click', function (e) { if (e.target === modal) modal.classList.remove('active'); });

        modal.querySelectorAll('input[name="reason"]').forEach(function (radio) {
          radio.addEventListener('change', function () {
            var isOther = otherRadio.checked;
            if (detailWrap) detailWrap.style.display = isOther ? 'block' : 'none';
            if (detailInput) detailInput.required = isOther;
          });
        });
      });
    })();
  </script>
</body>
</html>
