<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | 헤어샵 검색/예약</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="/resources/css/common.css">
  <link rel="stylesheet" href="/resources/css/user.css">
</head>
<body class="search-page">
  <jsp:include page="../includes/sidebar_common.jsp">
    <jsp:param name="menu" value="search" />
  </jsp:include>

  <div class="app-container">
    <header class="app-header"></header>
    <main class="app-content">
      <c:choose>
        <c:when test="${salonNotFound}">
          <div class="modern-card">
            <h2>헤어샵을 찾을 수 없습니다.</h2>
            <p style="margin-top: 10px; color: var(--text-sub);">메인 화면에서 헤어샵을 다시 선택해 주세요.</p>
            <button type="button" class="btn-modern btn-primary" style="margin-top: 20px;"
                    onclick="location.href='<c:url value="/"/>'">메인으로 돌아가기</button>
          </div>
        </c:when>
        <c:otherwise>
          <div class="search-layout">
            <div>
              <div class="modern-card" style="margin-bottom: 30px;">
                <h2 style="font-size: 24px;"><c:out value="${salon.salonName}"/></h2>
                <p style="color: var(-  -text-sub); margin-top: 10px;"><c:out value="${salon.address}"/></p>
                <p style="color: var(--text-sub); margin-top: 8px;"><c:out value="${salon.description}"/></p>
              </div>
              <h3 style="margin-bottom: 15px;">시술 메뉴 선택</h3>
              <c:forEach var="service" items="${services}" varStatus="status">
                <button type="button" class="menu-item-card ${status.first ? 'selected' : ''}"
                        style="width: 100%; text-align: left;"
                        data-service-name="<c:out value='${service.serviceName}'/>"
                        data-service-price="<fmt:formatNumber value='${service.price}' pattern='#,##0'/>">
                  <div>
                    <strong><c:out value="${service.serviceName}"/></strong>
                    <c:if test="${not empty service.description}">
                      <p style="margin-top: 5px; color: var(--text-sub);"><c:out value="${service.description}"/></p>
                    </c:if>
                  </div>
                  <strong><fmt:formatNumber value="${service.price}" pattern="#,##0"/>원</strong>
                </button>
              </c:forEach>
              <c:if test="${empty services}">
                <div class="modern-card">등록된 시술 메뉴가 없습니다.</div>
              </c:if>
            </div>
            <div class="summary-sticky-panel">
              <h3 style="margin-bottom: 20px; border-bottom: 2px solid var(--primary); padding-bottom: 10px;">선택 항목 요약</h3>
              <p style="margin-bottom: 10px;">매장: <c:out value="${salon.salonName}"/></p>
              <p style="margin-bottom: 10px;">메뉴: <span id="selected-service">선택해 주세요</span></p>
              <p style="margin-bottom: 20px; font-weight: 700;">최종 금액: <span id="selected-price">-</span></p>
              <button type="button" class="btn-modern btn-accent" style="width: 100%;" ${empty services ? 'disabled' : ''}>안전결제하기</button>
            </div>
          </div>
        </c:otherwise>
      </c:choose>
    </main>
  </div>

  <script>
    const menuCards = document.querySelectorAll('.menu-item-card');
    const selectedService = document.getElementById('selected-service');
    const selectedPrice = document.getElementById('selected-price');

    function selectService(card) {
      menuCards.forEach(item => item.classList.remove('selected'));
      card.classList.add('selected');
      selectedService.textContent = card.dataset.serviceName;
      selectedPrice.textContent = card.dataset.servicePrice + '원';
    }

    menuCards.forEach(card => card.addEventListener('click', () => selectService(card)));
    if (menuCards.length > 0) {
      selectService(menuCards[0]);
    }
  </script>
</body>
</html>
