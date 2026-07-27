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
  <link rel="stylesheet" href="${ctx}/resources/css/common.css">
  <link rel="stylesheet" href="${ctx}/resources/css/user.css">
  <style>
    .community-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 20px 24px 0;
    }
    .community-header h1 {
      font-size: 22px;
      font-weight: 700;
    }
    .category-tabs {
      display: flex;
      gap: 8px;
      padding: 14px 24px 0;
      flex-wrap: wrap;
    }
    .cat-tab {
      padding: 8px 18px;
      border-radius: var(--radius-full);
      font-size: 13px;
      font-weight: 600;
      text-decoration: none;
      border: 1.5px solid var(--border);
      color: var(--text-sub);
      background: var(--white);
      transition: all .15s;
      white-space: nowrap;
    }
    .cat-tab:hover, .cat-tab.active {
      background: var(--accent);
      color: #fff;
      border-color: var(--accent);
    }
    .post-card-list {
      padding: 14px 24px 24px;
      display: flex;
      flex-direction: column;
      gap: 12px;
    }
    .post-card {
      background: var(--white);
      border: 1px solid var(--border);
      border-radius: var(--radius-lg);
      padding: 22px 26px;
      text-decoration: none;
      color: inherit;
      display: flex;
      gap: 20px;
      align-items: flex-start;
      transition: box-shadow .15s, border-color .15s;
    }
    .post-card:hover {
      box-shadow: var(--shadow);
      border-color: var(--accent);
    }
    .post-card-body { flex: 1; min-width: 0; }
    .post-card-category {
      background: var(--accent-soft);
      color: var(--accent);
      padding: 3px 10px;
      border-radius: var(--radius-full);
      font-size: 11px;
      font-weight: 700;
      display: inline-block;
      margin-bottom: 8px;
    }
    .post-card-title {
      font-size: 16px;
      font-weight: 700;
      margin-bottom: 8px;
      overflow: hidden;
      white-space: nowrap;
      text-overflow: ellipsis;
    }
    .post-card-preview {
      font-size: 13px;
      color: var(--text-sub);
      margin-bottom: 12px;
      overflow: hidden;
      display: -webkit-box;
      -webkit-line-clamp: 2;
      -webkit-box-orient: vertical;
      line-height: 1.6;
    }
    .post-card-meta {
      display: flex;
      gap: 14px;
      font-size: 12px;
      color: var(--text-light);
      align-items: center;
      flex-wrap: wrap;
    }
    .post-card-thumb {
      width: 84px;
      height: 84px;
      object-fit: cover;
      border-radius: var(--radius-md);
      flex-shrink: 0;
      border: 1px solid var(--border);
    }
    .search-bar {
      padding: 12px 24px 0;
    }
    .search-form {
      display: flex;
      gap: 8px;
      align-items: center;
    }
    .search-type-select {
      padding: 9px 12px;
      border: 1.5px solid var(--border);
      border-radius: var(--radius-md);
      font-size: 13px;
      color: var(--text-sub);
      background: var(--white);
      cursor: pointer;
      flex-shrink: 0;
    }
    .search-type-select:focus { outline: none; border-color: var(--accent); }
    .search-input {
      flex: 1;
      padding: 9px 14px;
      border: 1.5px solid var(--border);
      border-radius: var(--radius-md);
      font-size: 14px;
      color: var(--text-main);
    }
    .search-input:focus { outline: none; border-color: var(--accent); }
    .search-btn {
      padding: 9px 18px;
      background: var(--accent);
      color: #fff;
      border: none;
      border-radius: var(--radius-md);
      font-size: 14px;
      cursor: pointer;
      flex-shrink: 0;
    }
    .search-btn:hover { opacity: .88; }
    .search-clear {
      padding: 8px 12px;
      font-size: 13px;
      color: var(--text-light);
      text-decoration: none;
      border: 1.5px solid var(--border);
      border-radius: var(--radius-md);
      flex-shrink: 0;
    }
    .search-clear:hover { color: var(--accent); border-color: var(--accent); }
    .search-result-info {
      padding: 8px 24px 0;
      font-size: 13px;
      color: var(--text-sub);
    }
    .search-result-info strong { color: var(--accent); }
    .empty-state {
      text-align: center;
      padding: 80px 0;
      color: var(--text-light);
    }
    .empty-state i { font-size: 44px; display: block; margin-bottom: 14px; }
  </style>
</head>
<body>
  <aside class="sidebar">
    <div class="sidebar-brand">
      <i class="fas fa-scissors" style="color: var(--accent);"></i>
      <span>HAIR RESERVE</span>
    </div>
    <ul class="sidebar-menu">
      <li class="sidebar-item"><a href="${ctx}/"><i class="fas fa-home"></i> 홈 메인</a></li>
      <li class="sidebar-item"><a href="#"><i class="fas fa-search"></i> 헤어샵 검색/예약</a></li>
      <li class="sidebar-item"><a href="#"><i class="fas fa-comments"></i> 1:1 상담 채팅</a></li>
      <li class="sidebar-item active"><a href="${ctx}/community"><i class="fas fa-users"></i> 스타일 커뮤니티</a></li>
      <li class="sidebar-item"><a href="${ctx}/community/popular"><i class="fas fa-fire"></i> 인기글</a></li>
      <li class="sidebar-item"><a href="#"><i class="fas fa-calendar-alt"></i> 예약 내역</a></li>
      <li class="sidebar-item"><a href="#"><i class="fas fa-user"></i> 마이페이지</a></li>
    </ul>
  </aside>

  <div class="app-container">
    <main class="app-content" style="overflow-y: auto; padding: 0;">

      <%-- 헤더: 타이틀 + 글쓰기 버튼 --%>
      <div class="community-header">
        <h1><i class="fas fa-users" style="color: var(--accent); margin-right: 10px;"></i>스타일 커뮤니티</h1>
        <a href="${ctx}/community/write" class="btn-modern btn-accent">
          <i class="fas fa-pen"></i> 글쓰기
        </a>
      </div>

      <%-- 검색 바 --%>
      <div class="search-bar">
        <form action="${ctx}/community" method="get" class="search-form">
          <select name="searchType" class="search-type-select">
            <option value="title_content" ${'title_content' == searchType ? 'selected' : ''}>제목+내용</option>
            <option value="content"       ${'content'       == searchType ? 'selected' : ''}>내용</option>
            <option value="comment"       ${'comment'       == searchType ? 'selected' : ''}>댓글</option>
            <option value="author"        ${'author'        == searchType ? 'selected' : ''}>닉네임</option>
            <option value="salon"         ${'salon'         == searchType ? 'selected' : ''}>방문 미용실</option>
          </select>
          <input type="text" name="keyword" value="${keyword}"
                 class="search-input" placeholder="검색어를 입력하세요...">
          <button type="submit" class="search-btn">
            <i class="fas fa-search"></i>
          </button>
          <c:if test="${not empty keyword}">
            <a href="${ctx}/community" class="search-clear">✕ 초기화</a>
          </c:if>
        </form>
      </div>

      <%-- 검색 결과 안내 --%>
      <c:if test="${not empty keyword}">
        <p class="search-result-info">
          <strong>"<c:out value="${keyword}" />"</strong> 검색 결과
          <strong>${fn:length(posts)}</strong>건
        </p>
      </c:if>

      <%-- 카테고리 탭 --%>
      <div class="category-tabs" style="${not empty keyword ? 'opacity:.4; pointer-events:none;' : ''}">
        <a href="${ctx}/community"
           class="cat-tab ${empty category ? 'active' : ''}">전체</a>
        <a href="${ctx}/community?category=%ED%97%A4%EC%96%B4%EC%8A%A4%ED%83%80%EC%9D%BC"
           class="cat-tab ${'헤어스타일' == category ? 'active' : ''}">헤어스타일</a>
        <a href="${ctx}/community?category=%EC%8B%9C%EC%88%A0%ED%9B%84%EA%B8%B0"
           class="cat-tab ${'시술후기' == category ? 'active' : ''}">시술후기</a>
        <a href="${ctx}/community?category=%EC%B6%94%EC%B2%9C%2F%EC%A7%88%EB%AC%B8"
           class="cat-tab ${'추천/질문' == category ? 'active' : ''}">추천/질문</a>
        <a href="${ctx}/community?category=%EC%9E%90%EC%9C%A0"
           class="cat-tab ${'자유' == category ? 'active' : ''}">자유</a>
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
              <a href="${ctx}/community/${post.postId}" class="post-card">
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
                        <span style="color:#e8007d; font-weight:600;"><i class="fas fa-thumbs-up"></i> ${score}</span>
                      </c:when>
                      <c:otherwise>
                        <span style="color:#4a6cf7; font-weight:600;"><i class="fas fa-thumbs-down"></i> ${score}</span>
                      </c:otherwise>
                    </c:choose>
                    <c:if test="${not empty post.salonName}">
                      <span style="color: var(--accent); font-weight: 600;">
                        <i class="fas fa-scissors"></i> <c:out value="${post.salonName}" />
                      </span>
                    </c:if>
                  </div>
                </div>
                <c:if test="${not empty post.imageUrl}">
                  <img src="${ctx}/uploads/${post.imageUrl}"
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
