<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
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
</head>
<body>
    <!-- 사이드바 -->
    <jsp:include page="includes/sidebar.jsp">
        <jsp:param name="menu" value="home" />
    </jsp:include>

    <div class="app-container">
        <jsp:include page="/WEB-INF/views/includes/header.jsp" />
        <main class="app-content">
            <div class="hero-section">
                <h1 style="font-size: 32px; font-weight: 800; margin-bottom: 12px;">나만을 위한 맞춤형 헤어 솔루션</h1>
                <p style="font-size: 16px; color: var(--text-light); line-height: 1.6;">2026년 트렌드 스타일 분석부터 간편한 결제 및 실시간 예약 조율까지 한번에 경험해 보세요.</p>
            </div>
            <h2 style="font-size: 20px; font-weight: 700; margin-bottom: 20px;">인기 급상승 헤어샵 추천</h2>
            <div class="home-grid">
                <div class="modern-card">
                <img src="https://images.unsplash.com/photo-1560066984-138dadb4c035?auto=format&fit=crop&w=600&q=80" class="salon-card-image" alt="salon">
                <div class="salon-card-body">
                    <div class="flex-between" style="margin-bottom: 12px;"><span class="tag">마포구 합정동</span><div class="rating-badge"><i class="fas fa-star"></i> 4.8</div></div>
                    <h3 style="font-size: 18px; margin-bottom: 8px; font-weight: 700;">헤어 스튜디오 온</h3>
                    <p style="font-size: 14px; color: var(--text-sub); margin-bottom: 20px; min-height: 42px;">따뜻한 분위기 속에서 즐기는 프라이빗 커스텀 헤어 케어</p>
                    <div class="flex-between"><span style="font-weight: 800; font-size: 16px;">25,000원 ~</span><button class="btn-modern btn-primary" onclick="location.href='search.html'">예약하기</button></div>
                </div>
                </div>
                <!-- 추가 카드 생략 가능 (팀원용 샘플이므로) -->
            </div>
        </main>
    </div>
</body>
</html>
