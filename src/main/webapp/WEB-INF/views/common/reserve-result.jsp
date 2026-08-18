<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | 예약 결과</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="/resources/css/common.css">
  <link rel="stylesheet" href="/resources/css/user.css">
  <link rel="stylesheet" href="/resources/css/auth.css">
</head>
<body class="reserve-page">
  <jsp:include page="../includes/sidebar_common.jsp">
    <jsp:param name="menu" value="reservations" />
  </jsp:include>

  <div class="app-container">
    <header class="app-header"></header>
    <main class="app-content">
      <%-- success 는 컨트롤러가 넣어주는 boolean. 결제 승인까지 끝났을 때만 true --%>
      <div class="reserve-result-card ${success ? 'is-success' : 'is-fail'}">
        <div class="reserve-result-icon">
          <i class="fas ${success ? 'fa-circle-check' : 'fa-circle-xmark'}"></i>
        </div>

        <h1 class="reserve-result-title">
          <c:choose>
            <c:when test="${success}">예약이 확정되었습니다</c:when>
            <c:otherwise>예약이 완료되지 않았습니다</c:otherwise>
          </c:choose>
        </h1>

        <p class="reserve-result-message">
          <c:choose>
            <c:when test="${success}">
              결제가 정상적으로 완료되어 예약이 확정되었습니다.
            </c:when>
            <c:when test="${not empty errorMessage}">
              <c:out value="${errorMessage}"/>
            </c:when>
            <c:otherwise>
              결제가 취소되었거나 처리 중 문제가 발생했습니다. 예약은 저장되지 않았습니다.
            </c:otherwise>
          </c:choose>
        </p>

        <%-- 예약 정보는 승인에 성공했을 때만 의미가 있다 --%>
        <c:if test="${success and not empty reservation}">
          <dl class="reserve-result-list">
            <div class="reserve-result-row">
              <dt>매장</dt>
              <dd><c:out value="${reservation.salonName}"/></dd>
            </div>
            <div class="reserve-result-row">
              <dt>시술</dt>
              <dd><c:out value="${reservation.serviceName}"/></dd>
            </div>
            <div class="reserve-result-row">
              <dt>일시</dt>
              <dd><c:out value="${reservation.reservationTime}"/></dd>
            </div>
            <div class="reserve-result-row">
              <dt>결제수단</dt>
              <dd><c:out value="${reservation.displayPayment}"/></dd>
            </div>
            <div class="reserve-result-row">
              <dt>결제금액</dt>
              <dd><fmt:formatNumber value="${reservation.amount}" pattern="#,##0"/>원</dd>
            </div>
            <div class="reserve-result-row">
              <dt>주문번호</dt>
              <dd class="reserve-result-txid"><c:out value="${reservation.transactionId}"/></dd>
            </div>
          </dl>
        </c:if>

        <div class="reserve-result-actions">
          <c:choose>
            <c:when test="${success}">
              <button type="button" class="btn-modern btn-primary"
                      onclick="location.href='<c:url value="/common/reservation"/>'">예약 내역 보기</button>
              <button type="button" class="btn-modern btn-outline"
                      onclick="location.href='<c:url value="/common/salonmap"/>'">헤어샵 더 둘러보기</button>
            </c:when>
            <c:otherwise>
              <%-- 본인의 미완료 결제가 그 자리를 잡고 있는 경우에만 나온다.
                   결제창에서 뒤로가기로 빠져나오면 콜백이 오지 않아 예약이 pending 으로 남는데,
                   그대로 두면 10분을 기다려야 해서 되돌릴 방법을 여기서 준다.
                   결제 중단 콜백과 같은 주소를 그대로 쓴다. --%>
              <c:if test="${not empty pendingReservationId}">
                <button type="button" class="btn-modern btn-primary"
                        onclick="location.href='<c:url value="/common/reserve/payment/${pendingProvider}/cancel"><c:param name="reservationId" value="${pendingReservationId}"/></c:url>'">
                  이전 결제 취소하기
                </button>
              </c:if>
              <%-- 실패했을 때는 방금 고르던 매장으로 곧장 돌려보낸다 --%>
              <c:if test="${not empty salonId}">
                <button type="button" class="btn-modern btn-primary"
                        onclick="location.href='<c:url value="/common/reserve"><c:param name="salonId" value="${salonId}"/></c:url>'">다시 예약하기</button>
              </c:if>
              <button type="button" class="btn-modern btn-outline"
                      onclick="location.href='<c:url value="/common/salonmap"/>'">지도로 돌아가기</button>
            </c:otherwise>
          </c:choose>
        </div>
      </div>
    </main>
  </div>
</body>
</html>
