<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | 쿠폰함</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="/resources/css/common.css"><link rel="stylesheet" href="/resources/css/user.css">
</head>
<body>
  <jsp:include page="../includes/sidebar_common.jsp"><jsp:param name="menu" value="mypage"/></jsp:include>
  <div class="app-container"><main class="app-content my-review-page">

    <div class="my-review-header">
      <div>
        <a class="back-btn" href="<c:url value='/common/mypage'/>"><i class="fas fa-arrow-left"></i> 마이페이지</a>
        <h1><i class="fas fa-ticket"></i> 쿠폰함</h1>
        <p>예약 결제 시 한 장까지 사용할 수 있어요.</p>
      </div>
      <strong>${couponCount}장</strong>
    </div>

    <c:choose>
      <c:when test="${empty myCoupons}">
        <div class="my-review-empty"><i class="fas fa-ticket"></i>
          <h2>보유한 쿠폰이 없습니다.</h2>
          <p>이벤트나 프로모션을 통해 쿠폰을 받아보세요.</p>
          <a class="btn-modern btn-primary" href="<c:url value='/common/home'/>">헤어샵 둘러보기</a>
        </div>
      </c:when>
      <c:otherwise>
        <div class="coupon-list">
          <c:forEach var="coupon" items="${myCoupons}">
            <%-- 만료분은 status 를 바꾸지 않고 조회 조건으로만 걸러왔다(쿠폰은 자리 같은
                 자원을 점유하지 않아 정리 배치가 없다). 그래서 화면에서도 status 와 기한을
                 함께 봐야 실제 사용 가능 여부가 나온다.

                 expiresAt 은 LocalDateTime 이라 EL 에서 "2027-08-10T23:59:59" 로 찍힌다.
                 앞 10글자가 날짜라 문자열 비교만으로 오늘과 견줄 수 있다. --%>
            <c:set var="expiresOn" value="${fn:substring(coupon.expiresAt, 0, 10)}" />
            <c:set var="expired" value="${expiresOn lt today}" />
            <c:set var="usable" value="${coupon.status eq 'available' and not expired}" />

            <article class="coupon-card ${usable ? '' : 'is-dead'}">
              <div class="coupon-card-amount">
                <c:choose>
                  <c:when test="${coupon.discountType eq 'percent'}">
                    <strong><fmt:formatNumber value="${coupon.discountValue}" pattern="0"/>%</strong>
                    <c:if test="${not empty coupon.maxDiscount}">
                      <span>최대 <fmt:formatNumber value="${coupon.maxDiscount}" pattern="#,##0"/>원</span>
                    </c:if>
                  </c:when>
                  <c:otherwise>
                    <strong><fmt:formatNumber value="${coupon.discountValue}" pattern="#,##0"/>원</strong>
                    <span>정액 할인</span>
                  </c:otherwise>
                </c:choose>
              </div>

              <div class="coupon-card-body">
                <h2><c:out value="${coupon.couponName}"/></h2>
                <p class="coupon-card-terms">
                  <c:choose>
                    <c:when test="${coupon.minOrderAmount > 0}">
                      <fmt:formatNumber value="${coupon.minOrderAmount}" pattern="#,##0"/>원 이상 결제 시
                    </c:when>
                    <c:otherwise>금액 조건 없음</c:otherwise>
                  </c:choose>
                  <c:if test="${not empty coupon.couponSalonId}"> · 특정 매장 전용</c:if>
                  <c:if test="${not empty coupon.couponServiceId}"> · 특정 시술 전용</c:if>
                </p>
                <p class="coupon-card-date">${fn:replace(expiresOn, '-', '.')}까지</p>
              </div>

              <div class="coupon-card-state">
                <c:choose>
                  <c:when test="${coupon.status eq 'used'}"><span class="tag">사용 완료</span></c:when>
                  <c:when test="${coupon.status eq 'reserved'}"><span class="tag">결제 진행 중</span></c:when>
                  <c:when test="${expired or coupon.status eq 'expired'}"><span class="tag">기간 만료</span></c:when>
                  <c:otherwise><span class="tag coupon-tag-live">사용 가능</span></c:otherwise>
                </c:choose>
              </div>
            </article>
          </c:forEach>
        </div>
      </c:otherwise>
    </c:choose>

  </main></div>
</body>
</html>
