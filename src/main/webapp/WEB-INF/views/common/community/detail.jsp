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
  <link rel="stylesheet" href="${ctx}/resources/css/common.css">
  <link rel="stylesheet" href="${ctx}/resources/css/user.css">
  <style>
    .detail-wrap { max-width: 900px; margin: 0 auto; padding: 12px 20px 48px; }
    .back-btn {
      display: inline-flex;
      align-items: center;
      gap: 7px;
      font-size: 14px;
      color: var(--text-sub);
      text-decoration: none;
      margin-bottom: 12px;
      padding: 6px 12px;
      border-radius: var(--radius-md);
      transition: background .15s, color .15s;
    }
    .back-btn:hover { background: var(--bg-sub); color: var(--accent); }
    .detail-card {
      background: var(--white);
      border: 1px solid var(--border);
      border-radius: var(--radius-lg);
      box-shadow: var(--shadow);
      overflow: hidden;
    }
    .detail-header { padding: 20px 32px 14px; border-bottom: 1px solid var(--border); }
    .reaction-bar {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 12px;
      padding: 16px 32px;
    }
    .react-btn {
      display: inline-flex;
      align-items: center;
      gap: 7px;
      padding: 9px 22px;
      border-radius: var(--radius-full);
      font-size: 14px;
      font-weight: 600;
      border: 2px solid var(--border);
      background: var(--white);
      cursor: pointer;
      transition: all .15s;
      text-decoration: none;
      color: var(--text-sub);
    }
    .react-btn:hover { border-color: var(--accent); color: var(--accent); }
    .react-btn.active-like  { background: #fff0f6; border-color: #e8007d; color: #e8007d; }
    .react-btn.active-dislike { background: #f0f4ff; border-color: #4a6cf7; color: #4a6cf7; }
    .react-count { font-weight: 700; }
    .category-badge {
      background: var(--accent-soft);
      color: var(--accent);
      padding: 4px 12px;
      border-radius: var(--radius-full);
      font-size: 12px;
      font-weight: 700;
      display: inline-block;
      margin-bottom: 12px;
    }
    .detail-title-row {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      gap: 16px;
      margin-bottom: 16px;
    }
    .detail-title-row h1 {
      font-size: 22px;
      font-weight: 700;
      flex: 1;
      line-height: 1.45;
    }
    .detail-actions { display: flex; gap: 8px; flex-shrink: 0; }
    .btn-sm { padding: 6px 14px; font-size: 13px; border-radius: var(--radius-sm); cursor: pointer; }
    .btn-danger { background: #fff0f0; color: #e74c3c; border: 1px solid #ffc9c9; }
    .detail-meta {
      display: flex;
      gap: 18px;
      font-size: 13px;
      color: var(--text-light);
      flex-wrap: wrap;
    }
    .detail-body {
      padding: 0 32px 24px;
      font-size: 15px;
      line-height: 1.85;
      color: var(--text-main);
      white-space: pre-wrap;
      word-break: break-word;
    }
    .post-image {
      width: 100%;
      max-height: 500px;
      object-fit: contain;
      border-radius: var(--radius-md);
      margin-bottom: 24px;
      border: 1px solid var(--border);
      background: var(--bg-sub);
      display: block;
    }
    .comment-section { padding: 24px 32px; background: var(--bg-sub); }
    .comment-section-title { font-weight: 700; font-size: 15px; margin-bottom: 16px; }
    .comment-item {
      background: var(--white);
      border-radius: var(--radius-md);
      padding: 14px 18px;
      margin-bottom: 10px;
      border: 1px solid var(--border);
    }
    .comment-meta {
      font-size: 12px;
      color: var(--text-light);
      margin-bottom: 7px;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    .comment-content { font-size: 14px; color: var(--text-main); line-height: 1.6; }
    .comment-form { display: flex; gap: 10px; margin-top: 16px; }
    .comment-input {
      flex: 1;
      padding: 10px 16px;
      border: 1px solid var(--border);
      border-radius: var(--radius-md);
      font-size: 14px;
      resize: none;
      font-family: inherit;
    }
    .comment-input:focus { outline: none; border-color: var(--accent); }
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
      <div class="detail-wrap">

        <a href="${ctx}/community" class="back-btn">
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
              <div class="detail-actions">
                <a href="${ctx}/community/${selectedPost.postId}/edit"
                   class="btn-modern btn-outline btn-sm">수정</a>
                <form action="${ctx}/community/${selectedPost.postId}/delete" method="post"
                      onsubmit="return confirm('정말 삭제하시겠습니까?')" style="margin: 0;">
                  <button type="submit" class="btn-modern btn-danger btn-sm">삭제</button>
                </form>
              </div>
            </div>
            <div class="detail-meta">
              <span><i class="fas fa-user-circle"></i> <c:out value="${selectedPost.authorName}" /></span>
              <span><i class="fas fa-clock"></i> ${fn:substring(selectedPost.createdAt, 0, 16)}</span>
              <span><i class="fas fa-eye"></i> 조회 ${selectedPost.viewCount}</span>
              <c:if test="${not empty selectedPost.salonName}">
                <span style="color: var(--accent); font-weight: 600;">
                  <i class="fas fa-scissors"></i> <c:out value="${selectedPost.salonName}" />
                </span>
              </c:if>
            </div>
          </div>

          <%-- 글 본문 --%>
          <div class="detail-body">
            <c:if test="${not empty selectedPost.imageUrl}">
              <img src="${ctx}/uploads/${selectedPost.imageUrl}"
                   alt="첨부 이미지" class="post-image" />
            </c:if>
            <span id="postBody"><c:out value="${selectedPost.content}" /></span>
          </div>

          <%-- 좋아요 / 별로예요 --%>
          <div class="reaction-bar">
            <form action="${ctx}/community/${selectedPost.postId}/react" method="post" style="margin:0;">
              <input type="hidden" name="type" value="like">
              <button type="submit"
                      class="react-btn ${'like' == userReaction ? 'active-like' : ''}">
                &#128077; 좋아요 <span class="react-count">${selectedPost.likeCount}</span>
              </button>
            </form>
            <form action="${ctx}/community/${selectedPost.postId}/react" method="post" style="margin:0;">
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
              댓글 <span style="color: var(--accent);">${fn:length(comments)}</span>개
            </p>

            <c:forEach var="comment" items="${comments}">
              <div class="comment-item">
                <div class="comment-meta">
                  <span>
                    <i class="fas fa-user-circle"></i>
                    <c:out value="${comment.authorName}" />
                    &nbsp;·&nbsp; ${fn:substring(comment.createdAt, 0, 16)}
                  </span>
                  <form action="${ctx}/community/${selectedPost.postId}/comment/${comment.commentId}/delete"
                        method="post"
                        onsubmit="return confirm('댓글을 삭제하시겠습니까?')"
                        style="margin: 0;">
                    <button type="submit"
                            style="background: none; border: none; color: var(--text-light); cursor: pointer; font-size: 12px;">
                      <i class="fas fa-times"></i>
                    </button>
                  </form>
                </div>
                <p class="comment-content"><c:out value="${comment.content}" /></p>
              </div>
            </c:forEach>

            <form action="${ctx}/community/${selectedPost.postId}/comment" method="post">
              <div class="comment-form">
                <textarea name="content" class="comment-input" rows="2"
                          placeholder="댓글을 입력하세요..." required></textarea>
                <button type="submit" class="btn-modern btn-primary" style="white-space: nowrap;">
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
