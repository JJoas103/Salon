<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | 찜 목록</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="/resources/css/common.css"><link rel="stylesheet" href="/resources/css/user.css">
</head>
<body>
  <jsp:include page="../includes/sidebar_common.jsp"><jsp:param name="menu" value="mypage"/></jsp:include>
  <div class="app-container"><main class="app-content">
    <div class="wishlist-page-header">
      <div><a class="back-btn" href="<c:url value='/common/mypage'/>"><i class="fas fa-arrow-left"></i> 마이페이지</a>
        <h1><i class="fas fa-heart"></i> 찜 목록</h1><p>다시 방문하고 싶은 헤어샵을 모아봤어요.</p></div>
      <strong><span data-wishlist-count>${salons.size()}</span>개</strong>
    </div>
    <c:choose>
      <c:when test="${empty salons}">
        <div class="wishlist-empty"><i class="far fa-heart"></i><h2>아직 찜한 헤어샵이 없습니다.</h2>
          <p>마음에 드는 헤어샵을 찜해두면 이곳에서 바로 확인할 수 있어요.</p>
          <a class="btn-modern btn-primary" href="<c:url value='/common/home'/>">헤어샵 둘러보기</a></div>
      </c:when>
      <c:otherwise>
        <%-- 마지막 찜을 해제하면 wishlist.js 가 이 자리를 빈 목록 안내로 바꾼다.
             그때 쓸 링크 주소를 컨텍스트 경로가 반영된 형태로 여기서 넘겨준다. --%>
        <div class="wishlist-grid" data-home-url="<c:url value='/common/home'/>">
          <c:forEach var="salon" items="${salons}">
            <article class="modern-card wishlist-card" data-wishlist-card="${salon.salonId}">
              <c:choose><c:when test="${not empty salon.imageUrl}"><img src="<c:out value='${salon.imageUrl}'/>" alt="<c:out value='${salon.salonName}'/>" onerror="this.onerror=null;this.src='https://images.unsplash.com/photo-1560066984-138dadb4c035?auto=format&amp;fit=crop&amp;w=900&amp;q=80';"></c:when>
                <c:otherwise><img src="https://images.unsplash.com/photo-1560066984-138dadb4c035?auto=format&amp;fit=crop&amp;w=900&amp;q=80" alt="기본 헤어샵 이미지"></c:otherwise></c:choose>
              <div class="salon-card-body"><div class="flex-between"><span class="tag"><c:out value="${salon.address}"/></span>
                <span class="rating-badge"><i class="fas fa-star"></i> <fmt:formatNumber value="${salon.averageRating}" pattern="0.0"/></span></div>
                <h2><c:out value="${salon.salonName}"/></h2><p><c:out value="${salon.description}"/></p>
                <div class="wishlist-card-actions">
                  <form class="wishlist-form" data-salon-id="${salon.salonId}" data-remove-card="true" method="post" action="<c:url value='/common/salons/${salon.salonId}/wishlist'/>">
                    <input type="hidden" name="source" value="wishlists">
                    <button class="btn-modern btn-outline wishlist-btn is-active" type="submit"><i class="fas fa-heart"></i> 찜완료</button>
                  </form>
                  <button class="btn-modern btn-outline" type="button" onclick="location.href='<c:url value="/common/salons/${salon.salonId}/reviews"/>'">리뷰</button>
                  <button class="btn-modern btn-primary" type="button" onclick="location.href='<c:url value="/common/reserve"><c:param name="salonId" value="${salon.salonId}"/></c:url>'">예약하기</button>
                </div>
              </div>
            </article>
          </c:forEach>
        </div>
      </c:otherwise>
    </c:choose>
  </main></div>
  <script src="<c:url value='/resources/js/wishlist.js'/>"></script>
</body></html>
