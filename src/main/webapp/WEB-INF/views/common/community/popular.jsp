<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | 인기글</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="/resources/css/common.css">
  <link rel="stylesheet" href="/resources/css/user.css">
  <link rel="stylesheet" href="/resources/css/auth.css">
</head>
<body>
  <!-- 사이드바 -->
  <jsp:include page="../../includes/sidebar_common.jsp">
    <jsp:param name="menu" value="popular" />
  </jsp:include>

  <div class="app-container">
    <main class="app-content community-content">

      <div class="community-header">
        <h1><i class="fas fa-fire icon-hot"></i>인기글</h1>
        <a href="${ctx}/common/community" class="btn-modern btn-outline btn-sm">
          <i class="fas fa-list"></i> 전체 목록
        </a>
      </div>
      <p class="community-desc">좋아요를 많이 받은 글 순서로 보여드려요</p>

      <div class="post-card-list ranked">
        <c:choose>
          <c:when test="${empty posts}">
            <div class="empty-state">
              <i class="fas fa-fire"></i>
              <p>아직 인기글이 없어요.<br>좋아요를 남겨 인기글을 만들어보세요!</p>
            </div>
          </c:when>
          <c:otherwise>
            <c:forEach var="post" items="${posts}" varStatus="s">
              <a href="${ctx}/common/community/${post.postId}" class="post-card">
                <c:choose>
                  <c:when test="${s.index == 0}"><span class="rank-badge top1">1</span></c:when>
                  <c:when test="${s.index == 1}"><span class="rank-badge top2">2</span></c:when>
                  <c:when test="${s.index == 2}"><span class="rank-badge top3">3</span></c:when>
                  <c:otherwise><span class="rank-badge">${s.index + 1}</span></c:otherwise>
                </c:choose>

                <div class="post-card-body">
                  <c:if test="${not empty post.category}">
                    <span class="post-card-category"><c:out value="${post.category}" /></span>
                  </c:if>
                  <div class="post-card-title"><c:out value="${post.title}" /></div>
                  <div class="post-card-preview"><c:out value="${post.content}" /></div>
                  <div class="post-card-meta">
                    <span><i class="fas fa-user-circle"></i> <c:out value="${post.authorName}" /></span>
                    <span><i class="fas fa-clock"></i> ${fn:substring(post.createdAt, 0, 10)}</span>
                    <span><i class="fas fa-eye"></i> ${post.viewCount}</span>
                    <c:set var="score" value="${post.likeCount - post.dislikeCount}" />
                    <c:choose>
                      <c:when test="${score >= 0}">
                        <span class="meta-like"><i class="fas fa-thumbs-up"></i> ${score}</span>
                      </c:when>
                      <c:otherwise>
                        <span class="meta-dislike"><i class="fas fa-thumbs-down"></i> ${score}</span>
                      </c:otherwise>
                    </c:choose>
                    <c:if test="${not empty post.salonName}">
                      <span class="meta-salon">
                        <i class="fas fa-scissors"></i> <c:out value="${post.salonName}" />
                      </span>
                    </c:if>
                  </div>
                </div>
                <c:if test="${not empty post.imageUrl}">
                  <img src="${ctx}/upload/${post.imageUrl}"
                       class="post-card-thumb" alt="썸네일" />
                </c:if>
              </a>
            </c:forEach>
          </c:otherwise>
        </c:choose>
      </div>

    </main>
  </div>
</body>
</html>
