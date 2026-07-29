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
                </div>
                <p class="comment-content"><c:out value="${comment.content}" /></p>
              </div>
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

  <script>
    (function() {
      var el = document.getElementById('postBody');
      if (el && el.firstChild && el.firstChild.nodeType === 3) {
        el.firstChild.nodeValue = el.firstChild.nodeValue.replace(/^\s+/, '');
      }
    })();
  </script>
</body>
</html>
