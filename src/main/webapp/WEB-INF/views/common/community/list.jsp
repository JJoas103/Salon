<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | 스타일 커뮤니티</title>
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

      <%-- 헤더: 타이틀 + 글쓰기 버튼 --%>
      <div class="community-header">
        <h1><i class="fas fa-users icon-accent"></i>스타일 커뮤니티</h1>
        <a href="${ctx}/common/community/write" class="btn-modern btn-accent">
          <i class="fas fa-pen"></i> 글쓰기
        </a>
      </div>

      <%-- 검색 바 --%>
      <div class="post-search">
        <form action="${ctx}/common/community" method="get" class="post-search-form">
          <select name="searchType" class="post-search-type">
            <option value="title_content" ${'title_content' == searchType ? 'selected' : ''}>제목+내용</option>
            <option value="content"       ${'content'       == searchType ? 'selected' : ''}>내용</option>
            <option value="comment"       ${'comment'       == searchType ? 'selected' : ''}>댓글</option>
            <option value="author"        ${'author'        == searchType ? 'selected' : ''}>닉네임</option>
            <option value="salon"         ${'salon'         == searchType ? 'selected' : ''}>방문 미용실</option>
          </select>
          <input type="text" name="keyword" value="${keyword}"
                 class="post-search-input" placeholder="검색어를 입력하세요...">
          <button type="submit" class="post-search-btn">
            <i class="fas fa-search"></i>
          </button>
          <c:if test="${not empty keyword}">
            <a href="${ctx}/common/community" class="post-search-clear">✕ 초기화</a>
          </c:if>
        </form>
      </div>

      <%-- 검색 결과 안내 --%>
      <c:if test="${not empty keyword}">
        <p class="post-search-result">
          <strong>"<c:out value="${keyword}" />"</strong> 검색 결과
          <strong>${fn:length(posts)}</strong>건
        </p>
      </c:if>

      <div class="tabs-row">
        <%-- 카테고리 탭 (검색 중에는 비활성) --%>
        <div class="category-tabs ${not empty keyword ? 'is-disabled' : ''}">
          <a href="${ctx}/common/community"
             class="cat-tab ${empty category ? 'active' : ''}">전체</a>
          <a href="${ctx}/common/community?category=%ED%97%A4%EC%96%B4%EC%8A%A4%ED%83%80%EC%9D%BC"
             class="cat-tab ${'헤어스타일' == category ? 'active' : ''}">헤어스타일</a>
          <a href="${ctx}/common/community?category=%EC%8B%9C%EC%88%A0%ED%9B%84%EA%B8%B0"
             class="cat-tab ${'시술후기' == category ? 'active' : ''}">시술후기</a>
          <a href="${ctx}/common/community?category=%EC%B6%94%EC%B2%9C%2F%EC%A7%88%EB%AC%B8"
             class="cat-tab ${'추천/질문' == category ? 'active' : ''}">추천/질문</a>
          <a href="${ctx}/common/community?category=%EC%9E%90%EC%9C%A0"
             class="cat-tab ${'자유' == category ? 'active' : ''}">자유</a>
        </div>

        <%-- 정렬 토글: 최신순 / 추천순 (현재 카테고리·검색 조건 유지) --%>
        <div class="sort-toggle">
          <c:url var="latestUrl" value="/common/community">
            <c:param name="category" value="${category}"/>
            <c:param name="keyword" value="${keyword}"/>
            <c:param name="searchType" value="${searchType}"/>
            <c:param name="sort" value="latest"/>
          </c:url>
          <c:url var="recommendUrl" value="/common/community">
            <c:param name="category" value="${category}"/>
            <c:param name="keyword" value="${keyword}"/>
            <c:param name="searchType" value="${searchType}"/>
            <c:param name="sort" value="recommend"/>
          </c:url>
          <a href="${latestUrl}" class="sort-tab ${sort != 'recommend' ? 'active' : ''}">
            <i class="fas fa-clock"></i> 최신순
          </a>
          <a href="${recommendUrl}" class="sort-tab ${sort == 'recommend' ? 'active' : ''}">
            <i class="fas fa-fire"></i> 추천순
          </a>
        </div>
      </div>

      <%-- 게시글 카드 목록 --%>
      <div class="post-card-list">
        <c:choose>
          <c:when test="${empty posts}">
            <div class="empty-state">
              <i class="fas fa-newspaper"></i>
              <p>게시글이 없습니다.<br>첫 번째 글을 작성해보세요!</p>
            </div>
          </c:when>
          <c:otherwise>
            <c:forEach var="post" items="${posts}">
              <c:set var="score" value="${post.likeCount - post.dislikeCount}" />
              <a href="${ctx}/common/community/${post.postId}" class="post-card">
                <div class="post-card-body">
                  <c:if test="${not empty post.category}">
                    <span class="post-card-category"><c:out value="${post.category}" /></span>
                  </c:if>
                  <c:if test="${score >= 10}">
                    <span class="hot-badge"><i class="fas fa-fire"></i> 인기</span>
                  </c:if>
                  <div class="post-card-title"><c:out value="${post.title}" /></div>
                  <div class="post-card-preview"><c:out value="${post.content}" /></div>
                  <div class="post-card-meta">
                    <span><i class="fas fa-user-circle"></i> <c:out value="${post.authorName}" /></span>
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
