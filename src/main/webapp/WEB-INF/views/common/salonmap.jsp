<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
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
<body class="map-search-page">
  <!-- 사이드바 -->
  <jsp:include page="../includes/sidebar_common.jsp">
    <jsp:param name="menu" value="search" />
  </jsp:include>

  <div class="app-container">
    <jsp:include page="/WEB-INF/views/includes/header.jsp" />

    <main class="app-content">
      <!-- 검색 바 -->
      <form class="map-search-bar" onsubmit="return false;">
        <i class="fas fa-search"></i>
        <input type="text" id="keyword" class="map-search-input" placeholder="지역 또는 헤어샵을 검색해 보세요">
        <button type="submit" class="btn-modern btn-accent map-search-btn">검색</button>
      </form>

      <div class="map-layout">
        <!-- 지도 영역 (카카오맵 API 연동 예정) -->
        <div class="map-panel">
          <div id="kakao-map"></div>

          <!-- 지도 로드 전 자리표시. 카카오맵이 붙으면 지우면 된다 -->
          <div class="map-placeholder" id="map-placeholder">
            <i class="fas fa-map-location-dot"></i>
            <span>지도 영역 (카카오맵 API 연동 예정)</span>
          </div>

          <div class="map-legend">
            <div class="map-legend-item"><i class="fas fa-map-marker-alt pin-selected"></i> 선택한 헤어샵</div>
            <div class="map-legend-item"><i class="fas fa-map-marker-alt pin-normal"></i> 헤어샵 위치</div>
          </div>

          <button type="button" class="map-locate-btn" id="btn-locate" title="현재 위치">
            <i class="fas fa-location-crosshairs"></i>
          </button>
        </div>

        <!-- 선택한 헤어샵 상세 -->
        <div class="salon-detail-card">
          <img id="detail-image" class="salon-detail-image" src="" alt="헤어샵 사진">
          <div class="salon-detail-body">
            <div class="salon-detail-title-row">
              <div>
                <h2 id="detail-name">-</h2>
                <p class="salon-detail-address" id="detail-address">-</p>
              </div>
              <div class="rating-badge"><i class="fas fa-star"></i> <span id="detail-rating">-</span></div>
            </div>

            <div class="salon-detail-info">
              <div class="salon-info-row">
                <div class="salon-info-icon"><i class="far fa-clock"></i></div>
                <span class="salon-info-label">운영시간</span>
                <span class="salon-info-value" id="detail-hours">-</span>
              </div>
              <div class="salon-info-row">
                <div class="salon-info-icon"><i class="fas fa-tag"></i></div>
                <span class="salon-info-label">가격대</span>
                <span class="salon-info-value" id="detail-price">-</span>
              </div>
            </div>

            <button type="button" class="btn-modern btn-accent btn-reserve" id="btn-reserve">예약하기</button>
          </div>
        </div>
      </div>
    </main>
  </div>

  <script>
    /* ------------------------------------------------------------------
       목업 데이터. 카카오맵 연동 시 이 배열을 서버 데이터로 갈아끼우고
       마커 클릭 핸들러에서 selectSalon(i) 를 호출하면 우측 카드가 바뀐다.
       ------------------------------------------------------------------ */
    const SALONS = [
      { salonId: 1, name: '헤어 스튜디오 온', address: '마포구 합정동', rating: '4.8',
        hours: '10:00 - 20:00', price: '커트 25,000원부터', lat: 37.5495, lng: 126.9137,
        image: 'https://images.unsplash.com/photo-1560066984-138dadb4c035?auto=format&fit=crop&w=800&q=80' },
      { salonId: 2, name: '살롱 드 미르', address: '마포구 서교동', rating: '4.6',
        hours: '11:00 - 21:00', price: '커트 30,000원부터', lat: 37.5533, lng: 126.9214,
        image: 'https://images.unsplash.com/photo-1521590832167-7bcbfaa6381f?auto=format&fit=crop&w=800&q=80' },
      { salonId: 3, name: '바버샵 노드', address: '마포구 상수동', rating: '4.5',
        hours: '12:00 - 22:00', price: '커트 22,000원부터', lat: 37.5478, lng: 126.9224,
        image: 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?auto=format&fit=crop&w=800&q=80' }
    ];

    const CONTEXT_PATH = '<c:url value="/"/>';
    let selectedIndex = 0;

    function selectSalon(index) {
      const salon = SALONS[index];
      if (!salon) return;
      selectedIndex = index;

      document.getElementById('detail-image').src = salon.image;
      document.getElementById('detail-image').alt = salon.name;
      document.getElementById('detail-name').textContent = salon.name;
      document.getElementById('detail-address').textContent = salon.address;
      document.getElementById('detail-rating').textContent = salon.rating;
      document.getElementById('detail-hours').textContent = salon.hours;
      document.getElementById('detail-price').textContent = salon.price;
    }

    /* 예약하기 → 기존 시술 선택 페이지로 이동 */
    document.getElementById('btn-reserve').addEventListener('click', function () {
      location.href = CONTEXT_PATH + 'common/search?salonId=' + SALONS[selectedIndex].salonId;
    });

    /* 검색 / 현재위치 — 카카오맵 연동 후 실제 동작 연결 */
    document.getElementById('keyword').closest('form').addEventListener('submit', function () {
      console.log('검색어:', document.getElementById('keyword').value);
    });
    document.getElementById('btn-locate').addEventListener('click', function () {
      console.log('현재 위치로 이동');
    });

    selectSalon(0);

    /* ------------------------------------------------------------------
       [카카오맵 연동 자리]
       1) <head> 에 SDK 추가
          <script src="//dapi.kakao.com/v2/maps/sdk.js?appkey=발급받은키"><\/script>
       2) 아래 주석 해제
       ------------------------------------------------------------------
    const map = new kakao.maps.Map(document.getElementById('kakao-map'), {
      center: new kakao.maps.LatLng(SALONS[0].lat, SALONS[0].lng),
      level: 4
    });
    document.getElementById('map-placeholder').remove();

    SALONS.forEach(function (salon, i) {
      const marker = new kakao.maps.Marker({
        map: map,
        position: new kakao.maps.LatLng(salon.lat, salon.lng)
      });
      kakao.maps.event.addListener(marker, 'click', function () { selectSalon(i); });
    });
    */
  </script>
</body>
</html>
