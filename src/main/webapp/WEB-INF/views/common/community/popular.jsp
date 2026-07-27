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
  <link rel="stylesheet" href="${ctx}/resources/css/common.css">
  <link rel="stylesheet" href="${ctx}/resources/css/user.css">
  <style>
    .community-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 20px 24px 0;
    }
    .community-header h1 { font-size: 22px; font-weight: 700; }
    .popular-desc {
      padding: 8px 24px 0;
      font-size: 13px;
      color: var(--text-light);
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
      position: relative;
    }
    .post-card:hover { box-shadow: var(--shadow); border-color: var(--accent); }
    .rank-badge {
      position: absolute;
      top: 16px;
      left: -4px;
      width: 28px;
      height: 28px;
      border-radius: 50%;
      background: var(--accent);
      color: #fff;
      font-size: 12px;
      font-weight: 800;
      display: flex;
      align-items: center;
      justify-content: center;
      box-shadow: 0 2px 6px rgba(0,0,0,.15);
    }
    .rank-badge.top1 { background: #e8b800; }
    .rank-badge.top2 { background: #9e9e9e; }
    .rank-badge.top3 { background: #b06a2e; }
    .post-card-body { flex: 1; min-width: 0; padding-left: 20px; }
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
    .like-highlight { color: #e8007d; font-weight: 700; }
    .post-card-thumb {
      width: 84px;
      height: 84px;
      object-fit: cover;
      border-radius: var(--radius-md);
      flex-shrink: 0;
      border: 1px solid var(--border);
    }
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
      <li class="sidebar-item"><a href="${ctx}/community"><i class="fas fa-users"></i> 스타일 커뮤니티</a></li>
      <li class="sidebar-item active"><a href="${ctx}/community/popular"><i class="fas fa-fire"></i> 인기글</a></li>
      <li class="sidebar-item"><a href="#"><i class="fas fa-calendar-alt"></i> 예약 내역</a></li>
      <li class="sidebar-item"><a href="#"><i class="fas fa-user"></i> 마이페이지</a></li>
    </ul>
  </aside>

  <div class="app-container">
    <main class="app-content" style="overflow-y: auto; padding: 0;">

      <div class="community-header">
        <h1><i class="fas fa-fire" style="color: #e8007d; margin-right: 10px;"></i>인기글</h1>
        <a href="${ctx}/community" class="btn-modern btn-outline" style="font-size:13px;">
          <i class="fas fa-list"></i> 전체 목록
        </a>
      </div>
      <p class="popular-desc">좋아요를 많이 받은 글 순서로 보여드려요</p>

      <div class="post-card-list">
        <c:choose>
          <c:when test="${empty posts}">
            <div class="empty-state">
              <i class="fas fa-fire"></i>
              <p>아직 인기글이 없어요.<br>좋아요를 남겨 인기글을 만들어보세요!</p>
            </div>
          </c:when>
          <c:otherwise>
            <c:forEach var="post" items="${posts}" varStatus="s">
              <a href="${ctx}/community/${post.postId}" class="post-card">
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
                        <span style="color:#e8007d; font-weight:700;"><i class="fas fa-thumbs-up"></i> ${score}</span>
                      </c:when>
                      <c:otherwise>
                        <span style="color:#4a6cf7; font-weight:700;"><i class="fas fa-thumbs-down"></i> ${score}</span>
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
