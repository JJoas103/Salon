<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | 예약 내역</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="/resources/css/common.css">
  <link rel="stylesheet" href="/resources/css/user.css">
  <link rel="stylesheet" href="/resources/css/auth.css">
  <link rel="stylesheet" href="<c:url value='/resources/css/calendar.css'/>">
</head>
<body>
  <!-- 사이드바 -->
  <jsp:include page="../includes/sidebar_common.jsp">
    <jsp:param name="menu" value="reservations" />
  </jsp:include>

  <div class="app-container">
    <main class="app-content">
      <div class="res-tabs">
        <div class="res-tab ${categoryIdx == 1 ? 'active' : ''}">
          <a href="/common/reservation?category=1">전체 예약 히스토리</a>
        </div>

        <div class="res-tab">
          <a href="${pageContext.request.contextPath}/common/calendar">
            예약 캘린더
          </a>
        </div>
      </div>

      <div class="res-card">
        <c:choose>
          <c:when test="${empty reservs}">
            <div class="res-card-body">등록된 예약정보가 없습니다.</div>
          </c:when>

          <c:otherwise>
            <c:forEach var="reserve" items="${reservs}">
              <div class="res-card-header">
                <span style="font-size: 14px; color: var(--text-sub); font-weight: 600;">
                  주문번호: ${reserve.transactionId}
                </span>

                <c:choose>
                  <c:when test="${reserve.status eq 'pending'}">
                    <span class="status-badge status-upcoming">확정 대기</span>
                  </c:when>

                  <c:when test="${reserve.status eq 'confirmed'}">
                    <span class="status-badge status-upcoming">이용 예정 (확정)</span>
                  </c:when>

                  <c:when test="${reserve.status eq 'completed'}">
                    <span class="status-badge">이용 완료</span>
                  </c:when>

                  <c:when test="${reserve.status eq 'cancelled'}">
                    <span class="status-badge">예약 취소</span>
                  </c:when>

                  <c:otherwise>
                    <span class="status-badge">${reserve.status}</span>
                  </c:otherwise>
                </c:choose>
              </div>

              <div class="res-card-body">
                <img
                  src="https://images.unsplash.com/photo-1560066984-138dadb4c035?auto=format&fit=crop&w=300&q=80"
                  style="width: 110px; height: 110px; border-radius: var(--radius-md); object-fit: cover;"
                  alt="salon"
                >

                <div class="res-info-grid">
                  <div class="res-meta-item">
                    <span>매장명</span>
                    <strong>${reserve.salonName}</strong>
                  </div>

                  <div class="res-meta-item">
                    <span>예약일시</span>
                    <strong>${reserve.reservationTime}</strong>
                  </div>

                  <div class="res-meta-item">
                    <span>시술 상품 / 소요 시간</span>
                    <strong>${reserve.serviceName} / 60분 소요 예상</strong>
                  </div>

                  <div class="res-meta-item">
                    <span>결제 수단 및 금액</span>
                    <strong>${reserve.paymentMethod} / (${reserve.amount}원 완료)</strong>
                  </div>
                </div>

                <div style="display:flex; flex-direction:column; gap:8px;">
                  <%-- 방이 없으면 만들고 있으면 재사용한 뒤 그 방으로 리다이렉트된다 (ChatService.openRoom) --%>
                  <form action="<c:url value='/common/chat/room'/>" method="post">
                    <input type="hidden" name="salonId" value="${reserve.salonId}">
                    <button type="submit" class="btn-modern btn-outline" style="width:100%;">1:1 문의</button>
                  </form>
                  <c:if test="${reserve.status eq 'pending' or reserve.status eq 'confirmed'}">
                    <button
                      class="btn-modern btn-primary"
                      style="background:#FF4757; border-color:#FF4757;">
                      예약 취소
                    </button>
                  </c:if>                  
                </div>
              </div>
            </c:forEach>
          </c:otherwise>
        </c:choose>
      </div>
    </main>
  </div>
</body>
</html>
