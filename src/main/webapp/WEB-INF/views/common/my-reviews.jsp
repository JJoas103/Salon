<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | 작성한 리뷰</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="/resources/css/common.css"><link rel="stylesheet" href="/resources/css/user.css">
</head>
<body>
  <jsp:include page="../includes/sidebar_common.jsp"><jsp:param name="menu" value="mypage"/></jsp:include>
  <div class="app-container"><main class="app-content my-review-page">
    <div class="my-review-header">
      <div>
        <a class="back-btn" href="<c:url value='/common/mypage'/>"><i class="fas fa-arrow-left"></i> 마이페이지</a>
        <h1><i class="fas fa-star"></i> 작성한 리뷰</h1>
        <p>내가 남긴 헤어샵 리뷰를 최신순으로 확인할 수 있어요.</p>
      </div>
      <strong>${reviewCount}개</strong>
    </div>
    <c:choose>
      <c:when test="${empty reviews}">
        <div class="my-review-empty"><i class="far fa-comment-dots"></i>
          <h2>아직 작성한 리뷰가 없습니다.</h2>
          <p>이용을 완료한 헤어샵의 경험을 리뷰로 남겨보세요.</p>
          <a class="btn-modern btn-primary" href="<c:url value='/common/home'/>">헤어샵 둘러보기</a>
        </div>
      </c:when>
      <c:otherwise>
        <div class="my-review-list">
          <c:forEach var="review" items="${reviews}">
            <article class="my-review-card">
              <div class="my-review-card-head">
                <div><span class="verified-visit"><i class="fas fa-check-circle"></i> 실제 방문 인증</span>
                  <h2><c:out value="${review.salonName}"/></h2></div>
                <time><c:out value="${review.createdAt}"/></time>
              </div>
              <div class="review-stars" aria-label="${review.rating}점">
                <c:forEach begin="1" end="5" var="star"><i class="${star <= review.rating ? 'fas' : 'far'} fa-star"></i></c:forEach>
                <strong>${review.rating}.0</strong>
              </div>
              <p><c:out value="${review.comment}"/></p>
              <a href="<c:url value='/common/salons/${review.salonId}/reviews'/>">
                이 헤어샵 리뷰 전체 보기 <i class="fas fa-chevron-right"></i>
              </a>
            </article>
          </c:forEach>
        </div>
      </c:otherwise>
    </c:choose>
  </main></div>
</body></html>
