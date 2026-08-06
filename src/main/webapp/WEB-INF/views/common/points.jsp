<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | 적립금</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="/resources/css/common.css"><link rel="stylesheet" href="/resources/css/user.css">
</head>
<body>
  <jsp:include page="../includes/sidebar_common.jsp"><jsp:param name="menu" value="mypage"/></jsp:include>
  <div class="app-container"><main class="app-content my-review-page">

    <div class="my-review-header">
      <div>
        <a class="back-btn" href="<c:url value='/common/mypage'/>"><i class="fas fa-arrow-left"></i> 마이페이지</a>
        <h1><i class="fas fa-coins"></i> 적립금</h1>
        <p>결제 시 사용한 내역과 적립된 내역을 최신순으로 확인할 수 있어요.</p>
      </div>
      <strong><fmt:formatNumber value="${pointBalance}" pattern="#,##0"/>원</strong>
    </div>

    <c:choose>
      <c:when test="${empty pointHistory}">
        <div class="my-review-empty"><i class="fas fa-coins"></i>
          <h2>아직 적립금 내역이 없습니다.</h2>
          <p>헤어샵 이용을 마치면 결제 금액의 일부가 적립됩니다.</p>
          <a class="btn-modern btn-primary" href="<c:url value='/common/home'/>">헤어샵 둘러보기</a>
        </div>
      </c:when>
      <c:otherwise>
        <div class="point-list">
          <c:forEach var="tx" items="${pointHistory}">
            <%-- amount 는 부호 있는 값이다. 적립 +, 사용 - 이라 그대로 색과 기호를 정한다. --%>
            <article class="point-row ${tx.amount >= 0 ? 'is-plus' : 'is-minus'}">
              <div class="point-row-main">
                <strong>
                  <c:choose>
                    <c:when test="${tx.txType eq 'earn'}">방문 적립</c:when>
                    <c:when test="${tx.txType eq 'use'}">예약 결제 사용</c:when>
                    <c:when test="${tx.txType eq 'restore'}">결제 취소 환급</c:when>
                    <c:when test="${tx.txType eq 'revoke'}">적립 취소</c:when>
                    <c:when test="${tx.txType eq 'expire'}">기간 만료</c:when>
                    <c:otherwise>관리자 조정</c:otherwise>
                  </c:choose>
                </strong>
                <span class="point-row-sub">
                  <c:out value="${tx.createdAt}"/>
                  <c:if test="${not empty tx.reservationId}"> · 예약 #${tx.reservationId}</c:if>
                </span>
              </div>
              <div class="point-row-amount">
                <strong>
                  ${tx.amount >= 0 ? '+' : '-'}<fmt:formatNumber value="${tx.amount < 0 ? -tx.amount : tx.amount}" pattern="#,##0"/>원
                </strong>
                <span class="point-row-sub">
                  잔액 <fmt:formatNumber value="${tx.balanceAfter}" pattern="#,##0"/>원
                </span>
              </div>
            </article>
          </c:forEach>
        </div>
      </c:otherwise>
    </c:choose>

  </main></div>
</body>
</html>
