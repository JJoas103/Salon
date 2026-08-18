<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | ${salon.salonName} 리뷰</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="/resources/css/common.css">
  <link rel="stylesheet" href="/resources/css/user.css">
</head>
<body>
  <jsp:include page="../includes/sidebar_common.jsp">
    <jsp:param name="menu" value="search"/>
  </jsp:include>
  <div class="app-container">
    <main class="app-content review-page">
      <a class="back-btn" href="<c:url value='/common/reserve'><c:param name='salonId' value='${salon.salonId}'/></c:url>">
        <i class="fas fa-arrow-left"></i> 헤어샵으로 돌아가기
      </a>
      <section class="review-salon-header">
        <c:choose>
          <c:when test="${not empty salon.imageUrl}"><img src="<c:out value='${salon.imageUrl}'/>" alt=""></c:when>
          <c:otherwise><div class="review-salon-placeholder"><i class="fas fa-cut"></i></div></c:otherwise>
        </c:choose>
        <div class="review-salon-info">
          <span class="tag"><c:out value="${salon.address}"/></span>
          <h1><c:out value="${salon.salonName}"/> 리뷰</h1>
          <div class="review-score"><i class="fas fa-star"></i>
            <strong><fmt:formatNumber value="${salon.averageRating}" pattern="0.0"/></strong>
            <span>리뷰 ${reviewCount}개</span>
          </div>
        </div>
        <form class="wishlist-form" data-salon-id="${salon.salonId}" method="post" action="<c:url value='/common/salons/${salon.salonId}/wishlist'/>">
          <input type="hidden" name="source" value="reviews">
          <button class="btn-modern btn-outline wishlist-btn ${wishlisted ? 'is-active' : ''}" type="submit">
            <i class="${wishlisted ? 'fas' : 'far'} fa-heart"></i> ${wishlisted ? '찜완료' : '찜하기'}
          </button>
        </form>
      </section>

      <c:if test="${not empty success}"><p class="review-alert success-text">${success}</p></c:if>
      <c:if test="${not empty error}"><p class="review-alert error-text">${error}</p></c:if>

      <div class="review-layout">
        <section class="review-list-section">
          <div class="review-section-title"><h2>방문자 리뷰</h2><span>${reviewCount}</span></div>
          <c:choose>
            <c:when test="${empty reviews}">
              <div class="review-empty"><i class="far fa-comment-dots"></i><p>아직 등록된 리뷰가 없습니다.</p><small>첫 리뷰를 작성해 보세요.</small></div>
            </c:when>
            <c:otherwise>
              <c:forEach var="review" items="${reviews}">
                <article class="review-item">
                  <div class="review-author-avatar">${fn:substring(review.userName, 0, 1)}</div>
                  <div class="review-item-body">
                    <div class="review-item-head">
                      <div><strong><c:out value="${review.userName}"/></strong>
                        <div class="review-stars" aria-label="${review.rating}점">
                          <c:forEach begin="1" end="5" var="star"><i class="${star <= review.rating ? 'fas' : 'far'} fa-star"></i></c:forEach>
                        </div>
                        <c:if test="${review.userId == currentUserId}">
                          <button type="button" class="review-item-edit-btn" id="reviewEditBtn${review.reviewId}"
                                  onclick="document.getElementById('reviewEditForm${review.reviewId}').hidden = false; this.hidden = true;">수정</button>
                        </c:if>
                      </div>
                      <time>${review.createdAt}</time>
                    </div>
                    <p><c:out value="${review.comment}"/></p>
                    <c:if test="${not empty review.imageUrl or not empty review.imageUrl2}">
                      <div class="review-item-photos">
                        <c:if test="${not empty review.imageUrl}">
                          <img src="<c:out value='${review.imageUrl}'/>" alt="" class="review-item-photo lightbox-img">
                        </c:if>
                        <c:if test="${not empty review.imageUrl2}">
                          <img src="<c:out value='${review.imageUrl2}'/>" alt="" class="review-item-photo lightbox-img">
                        </c:if>
                      </div>
                    </c:if>
                    <span class="verified-visit"><i class="fas fa-check-circle"></i> 실제 방문 인증</span>
                    <c:if test="${review.userId == currentUserId}">
                      <form class="review-item-edit-form" id="reviewEditForm${review.reviewId}" hidden
                            method="post" enctype="multipart/form-data"
                            action="<c:url value='/common/salons/${salon.salonId}/reviews/${review.reviewId}/update'/>">
                        <fieldset class="star-rating">
                          <legend>별점</legend>
                          <div>
                            <c:forEach begin="1" end="5" var="score">
                              <input type="radio" id="editRating${review.reviewId}_${score}" name="rating" value="${score}"
                                     ${score == review.rating ? 'checked' : ''}>
                              <label for="editRating${review.reviewId}_${score}" title="${score}점"><i class="fas fa-star"></i></label>
                            </c:forEach>
                          </div>
                        </fieldset>
                        <textarea class="review-textarea" name="comment" maxlength="1000" required><c:out value="${review.comment}"/></textarea>
                        <label>새 사진으로 교체 (선택, 비워두면 기존 사진 유지)</label>
                        <div class="review-photo-inputs">
                          <input type="file" name="imageFile" accept="image/jpeg,image/png,image/gif,image/webp">
                          <input type="file" name="imageFile2" accept="image/jpeg,image/png,image/gif,image/webp">
                        </div>
                        <div class="review-item-edit-actions">
                          <button type="submit" class="btn-modern btn-primary">저장</button>
                          <button type="button" class="btn-modern btn-outline"
                                  onclick="document.getElementById('reviewEditForm${review.reviewId}').hidden = true; document.getElementById('reviewEditBtn${review.reviewId}').hidden = false;">취소</button>
                        </div>
                      </form>
                    </c:if>
                  </div>
                </article>
              </c:forEach>
            </c:otherwise>
          </c:choose>
        </section>

        <aside class="review-write-card">
          <h2>리뷰 작성</h2>
          <c:choose>
            <c:when test="${not empty reviewableReservations}">
              <p class="review-write-help">완료된 예약을 선택하고 이용 경험을 남겨주세요.</p>
              <form method="post" action="<c:url value='/common/salons/${salon.salonId}/reviews'/>" enctype="multipart/form-data">
                <label for="reservationId">이용 내역</label>
                <select id="reservationId" name="reservationId" class="modern-input" required>
                  <c:forEach var="reservation" items="${reviewableReservations}">
                    <option value="${reservation.reservationId}">
                      <c:out value="${reservation.serviceName}"/> · <c:out value="${reservation.reservationTime}"/>
                    </option>
                  </c:forEach>
                </select>
                <fieldset class="star-rating">
                  <legend>별점</legend>
                  <div>
                    <c:forEach begin="1" end="5" var="score">
                      <input type="radio" id="rating${score}" name="rating" value="${score}" ${score == 5 ? 'checked' : ''}>
                      <label for="rating${score}" title="${score}점"><i class="fas fa-star"></i></label>
                    </c:forEach>
                  </div>
                </fieldset>
                <label for="comment">리뷰 내용</label>
                <textarea id="comment" name="comment" maxlength="1000" required
                          placeholder="시술과 서비스는 어떠셨나요?"></textarea>
                <label for="reviewPhoto1">사진 (선택, 최대 2장)</label>
                <div class="review-photo-inputs">
                  <input type="file" id="reviewPhoto1" name="imageFile" accept="image/jpeg,image/png,image/gif,image/webp">
                  <input type="file" id="reviewPhoto2" name="imageFile2" accept="image/jpeg,image/png,image/gif,image/webp">
                </div>
                <div class="review-form-footer"><span id="reviewLength">0 / 1000</span>
                  <button type="submit" class="btn-modern btn-primary">리뷰 등록</button></div>
              </form>
            </c:when>
            <c:otherwise>
              <div class="review-write-disabled"><i class="fas fa-receipt"></i>
                <p>리뷰를 작성할 수 있는 완료된 예약이 없습니다.</p>
                <a href="<c:url value='/common/reserve?category=2'/>">이용 내역 확인하기</a>
              </div>
            </c:otherwise>
          </c:choose>
        </aside>
      </div>
    </main>
  </div>
  <script>
    const reviewComment = document.getElementById('comment');
    const reviewLength = document.getElementById('reviewLength');
    if (reviewComment) reviewComment.addEventListener('input', function () {
      reviewLength.textContent = this.value.length + ' / 1000';
    });
  </script>
  <script src="<c:url value='/resources/js/wishlist.js'/>"></script>
  <script src="<c:url value='/resources/js/lightbox.js'/>"></script>
</body>
</html>
