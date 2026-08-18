<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | 내 커뮤니티 활동</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="/resources/css/common.css">
  <link rel="stylesheet" href="/resources/css/user.css">
</head>
<body>
  <jsp:include page="../includes/sidebar_common.jsp"><jsp:param name="menu" value="mypage"/></jsp:include>
  <div class="app-container">
    <main class="app-content my-review-page">
      <div class="my-review-header">
        <div>
          <a class="back-btn" href="<c:url value='/common/mypage'/>"><i class="fas fa-arrow-left"></i> 마이페이지</a>
          <h1><i class="fas fa-comments"></i> 내 커뮤니티 활동</h1>
          <p>내가 쓴 글과 댓글, 내 글에 달린 댓글을 한곳에서 확인할 수 있어요.</p>
        </div>
      </div>

      <div class="tabs-row" style="padding:0 0 4px;">
        <div class="category-tabs">
          <a href="?tab=posts" class="cat-tab ${tab == 'posts' ? 'active' : ''}">내가 쓴 글 ${fn:length(myPosts)}</a>
          <a href="?tab=comments" class="cat-tab ${tab == 'comments' ? 'active' : ''}">내가 쓴 댓글 ${fn:length(myComments)}</a>
          <a href="?tab=replies" class="cat-tab ${tab == 'replies' ? 'active' : ''}">내 글에 달린 댓글 ${fn:length(myReplies)}</a>
        </div>
      </div>

      <c:choose>
        <%-- 내가 쓴 댓글 --%>
        <c:when test="${tab == 'comments'}">
          <c:choose>
            <c:when test="${empty myComments}">
              <div class="my-review-empty"><i class="far fa-comment-dots"></i>
                <h2>아직 작성한 댓글이 없습니다.</h2>
                <p>스타일 커뮤니티에서 다른 사람의 글에 댓글을 남겨보세요.</p>
                <a class="btn-modern btn-primary" href="<c:url value='/common/community'/>">커뮤니티 둘러보기</a>
              </div>
            </c:when>
            <c:otherwise>
              <div class="comment-activity-list">
                <c:forEach var="cmt" items="${myComments}">
                  <c:choose>
                    <c:when test="${cmt.postStatus == 'visible'}">
                      <a href="${ctx}/common/community/${cmt.postId}" class="comment-activity-card">
                        <div class="comment-activity-post"><i class="fas fa-file-alt"></i> <c:out value="${cmt.postTitle}" /></div>
                        <p class="comment-activity-content"><c:out value="${cmt.content}" /></p>
                        <div class="comment-activity-meta"><span><i class="fas fa-clock"></i> ${fn:substring(cmt.createdAt, 0, 16)}</span></div>
                      </a>
                    </c:when>
                    <c:otherwise>
                      <div class="comment-activity-card is-dead">
                        <div class="comment-activity-post"><i class="fas fa-ban"></i> 삭제된 게시글입니다</div>
                        <p class="comment-activity-content"><c:out value="${cmt.content}" /></p>
                        <div class="comment-activity-meta">
                          <span><i class="fas fa-clock"></i> ${fn:substring(cmt.createdAt, 0, 16)}</span>
                          <form action="${ctx}/common/my-community/comments/${cmt.commentId}/delete" method="post"
                                onsubmit="return confirm('이 기록을 삭제하시겠습니까?')" class="inline-form">
                            <button type="submit" class="comment-delete-btn"><i class="fas fa-times"></i></button>
                          </form>
                        </div>
                      </div>
                    </c:otherwise>
                  </c:choose>
                </c:forEach>
              </div>
            </c:otherwise>
          </c:choose>
        </c:when>

        <%-- 내 글에 달린 댓글 --%>
        <c:when test="${tab == 'replies'}">
          <c:choose>
            <c:when test="${empty myReplies}">
              <div class="my-review-empty"><i class="far fa-comment-dots"></i>
                <h2>아직 내 글에 달린 댓글이 없습니다.</h2>
                <p>다른 사람이 내 글에 댓글을 남기면 여기에서 확인할 수 있어요.</p>
              </div>
            </c:when>
            <c:otherwise>
              <div class="comment-activity-list">
                <c:forEach var="cmt" items="${myReplies}">
                  <c:choose>
                    <c:when test="${cmt.postStatus == 'visible'}">
                      <a href="${ctx}/common/community/${cmt.postId}" class="comment-activity-card">
                        <div class="comment-activity-post">
                          <i class="fas fa-reply"></i> <strong><c:out value="${cmt.authorName}" /></strong>님이
                          "<c:out value="${cmt.postTitle}" />"에 댓글을 남겼습니다
                        </div>
                        <p class="comment-activity-content"><c:out value="${cmt.content}" /></p>
                        <div class="comment-activity-meta"><span><i class="fas fa-clock"></i> ${fn:substring(cmt.createdAt, 0, 16)}</span></div>
                      </a>
                    </c:when>
                    <c:otherwise>
                      <div class="comment-activity-card is-dead">
                        <div class="comment-activity-post">
                          <i class="fas fa-ban"></i> 삭제된 게시글입니다 (<c:out value="${cmt.authorName}" />님의 댓글)
                        </div>
                        <p class="comment-activity-content"><c:out value="${cmt.content}" /></p>
                        <div class="comment-activity-meta">
                          <span><i class="fas fa-clock"></i> ${fn:substring(cmt.createdAt, 0, 16)}</span>
                          <form action="${ctx}/common/my-community/replies/${cmt.commentId}/delete" method="post"
                                onsubmit="return confirm('이 기록을 삭제하시겠습니까?')" class="inline-form">
                            <button type="submit" class="comment-delete-btn"><i class="fas fa-times"></i></button>
                          </form>
                        </div>
                      </div>
                    </c:otherwise>
                  </c:choose>
                </c:forEach>
              </div>
            </c:otherwise>
          </c:choose>
        </c:when>

        <%-- 내가 쓴 글 (기본) --%>
        <c:otherwise>
          <c:choose>
            <c:when test="${empty myPosts}">
              <div class="my-review-empty"><i class="far fa-comment-dots"></i>
                <h2>아직 작성한 글이 없습니다.</h2>
                <p>스타일 커뮤니티에 첫 번째 글을 남겨보세요.</p>
                <a class="btn-modern btn-primary" href="<c:url value='/common/community/write'/>">글쓰기</a>
              </div>
            </c:when>
            <c:otherwise>
              <div class="post-card-list">
                <c:forEach var="post" items="${myPosts}">
                  <c:set var="score" value="${post.likeCount - post.dislikeCount}" />
                  <a href="${ctx}/common/community/${post.postId}" class="post-card">
                    <div class="post-card-body">
                      <c:if test="${not empty post.category}">
                        <span class="post-card-category"><c:out value="${post.category}" /></span>
                      </c:if>
                      <div class="post-card-title"><c:out value="${post.title}" /></div>
                      <div class="post-card-preview"><c:out value="${post.content}" /></div>
                      <div class="post-card-meta">
                        <span><i class="fas fa-clock"></i> ${fn:substring(post.createdAt, 0, 10)}</span>
                        <span><i class="fas fa-eye"></i> ${post.viewCount}</span>
                        <c:choose>
                          <c:when test="${score >= 0}">
                            <span class="meta-like"><i class="fas fa-thumbs-up"></i> ${score}</span>
                          </c:when>
                          <c:otherwise>
                            <span class="meta-dislike"><i class="fas fa-thumbs-down"></i> ${score}</span>
                          </c:otherwise>
                        </c:choose>
                      </div>
                    </div>
                    <c:if test="${not empty post.imageUrl}">
                      <img src="${ctx}/upload/${post.imageUrl}" class="post-card-thumb" alt="썸네일" />
                    </c:if>
                  </a>
                </c:forEach>
              </div>
            </c:otherwise>
          </c:choose>
        </c:otherwise>
      </c:choose>
    </main>
  </div>
</body>
</html>
