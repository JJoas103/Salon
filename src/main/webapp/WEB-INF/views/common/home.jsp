<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | 홈 메인</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="/resources/css/common.css">
  <link rel="stylesheet" href="/resources/css/user.css">
  <link rel="stylesheet" href="/resources/css/auth.css">
</head>
<body>
    <!-- 사이드바 -->
    <jsp:include page="../includes/sidebar_common.jsp">
        <jsp:param name="menu" value="home" />
    </jsp:include>

    <div class="app-container">
        <main class="app-content">
            <div class="hero-section">
                <h1 style="font-size: 32px; font-weight: 800; margin-bottom: 12px;">나만을 위한 맞춤형 헤어 솔루션</h1>
                <p style="font-size: 16px; color: var(--text-light); line-height: 1.6;">2026년 트렌드 스타일 분석부터 간편한 결제 및 실시간 예약 조율까지 한번에 경험해 보세요.</p>
            </div>
            <h2 style="font-size: 20px; font-weight: 700; margin-bottom: 20px;">인기 급상승 헤어샵 추천</h2>
            <div class="home-grid">
                <c:forEach var="salon" items="${salons}">
                    <div class="modern-card">
                        <c:choose>
                            <c:when test="${not empty salon.imageUrl}">
                                <img src="<c:out value='${salon.imageUrl}'/>" class="salon-card-image" alt="<c:out value='${salon.salonName}'/>">
                            </c:when>
                            <c:otherwise>
                                <img src="https://images.unsplash.com/photo-1560066984-138dadb4c035?auto=format&amp;fit=crop&amp;w=600&amp;q=80" class="salon-card-image" alt="salon">
                            </c:otherwise>
                        </c:choose>
                        <div class="salon-card-body">
                            <div class="flex-between" style="margin-bottom: 12px;">
                                <span class="tag"><c:out value="${salon.address}" /></span>
                                <div class="rating-badge"><i class="fas fa-star"></i> <fmt:formatNumber value="${salon.averageRating}" pattern="0.0" /></div>
                            </div>
                            <h3 style="font-size: 18px; margin-bottom: 8px; font-weight: 700;"><c:out value="${salon.salonName}" /></h3>
                            <p style="font-size: 14px; color: var(--text-sub); margin-bottom: 20px; min-height: 42px;"><c:out value="${salon.description}" /></p>
                            <div class="flex-between">
                                <span style="font-weight: 800; font-size: 16px;">
                                    <c:choose>
                                        <c:when test="${not empty salon.minimumPrice}"><fmt:formatNumber value="${salon.minimumPrice}" pattern="#,##0" />원~</c:when>
                                        <c:otherwise>가격 문의</c:otherwise>
                                    </c:choose>
                                </span>
                                <button type="button" class="btn-modern btn-primary"
                                    onclick="location.href='<c:url value="/common/search"><c:param name="salonId" value="${salon.salonId}"/></c:url>'">
                                    예약하기
                                </button>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>        </main>
    </div>
</body>
</html>
