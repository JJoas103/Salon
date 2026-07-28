<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>

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
  
  <script src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=${kakaoMapApiKey}&libraries=services&autoload=true"></script>
  <script>
    /* SalonVO 목록을 컨트롤러에서 JSON 으로 직렬화해 넘겨받는다. 키 이름은 VO 필드명 그대로다. */
    const SALONS = ${salonsJson};

    const CONTEXT_PATH = '<c:url value="/"/>';
    /* imageUrl 이 비어 있는 미용실용 대체 이미지 (home.jsp 와 동일) */
    const FALLBACK_IMAGE = 'https://images.unsplash.com/photo-1560066984-138dadb4c035?auto=format&fit=crop&w=800&q=80';
    let selectedIndex = -1;
    /* 지도 마커. PINS[미용실 index] = { element, overlay } — 좌표 없는 미용실 자리는 비어 있다 */
    const PINS = [];

    /* 선택된 마커만 색/크기를 바꾼다 (범례의 pin-selected / pin-normal 과 동일한 색) */
    function updatePinStyles() {
      PINS.forEach(function (pin, i) {
        const isSelected = (i === selectedIndex);
        pin.element.classList.toggle('pin-selected', isSelected);
        pin.element.classList.toggle('pin-normal', !isSelected);
        pin.overlay.setZIndex(isSelected ? 10 : 1);
      });
    }

    function formatPrice(price) {
      if (price === null || price === undefined) return '-';
      return Number(price).toLocaleString('ko-KR') + '원부터';
    }

    function selectSalon(index) {
      const salon = SALONS[index];
      if (!salon) return;
      selectedIndex = index;

      const image = document.getElementById('detail-image');
      image.src = salon.imageUrl || FALLBACK_IMAGE;
      image.alt = salon.salonName;
      document.getElementById('detail-name').textContent = salon.salonName;
      document.getElementById('detail-address').textContent = salon.address;
      document.getElementById('detail-rating').textContent = salon.averageRating != null ? salon.averageRating : '-';
      /* 운영시간은 Salon_Operating_Hours 를 아직 조회하지 않아 표시할 값이 없다 */
      document.getElementById('detail-hours').textContent = '-';
      document.getElementById('detail-price').textContent = formatPrice(salon.minimumPrice);
      updatePinStyles();
    }

    /* 예약하기 → 기존 시술 선택 페이지로 이동 */
    document.getElementById('btn-reserve').addEventListener('click', function () {
      const salon = SALONS[selectedIndex];
      if (!salon) return;
      location.href = CONTEXT_PATH + 'common/search?salonId=' + salon.salonId;
    });
    
    /* 검색 — 지역 검색이냐 헤어샵 이름 검색이냐 정한 뒤 연결한다 */
    document.getElementById('keyword').closest('form').addEventListener('submit', function () {
      console.log('검색어:', document.getElementById('keyword').value);
    });

    selectSalon(0);

    /* ------------------------------------------------------------------
       지도 — Salons.latitude / longitude 를 그대로 쓴다.
       좌표가 없는(NULL) 미용실은 마커를 만들지 않는다. 미용실 등록 기능을 만들 때
       등록 시점에 주소 → 좌표를 한 번 변환해 저장하면 여기는 손댈 필요가 없다.
       ------------------------------------------------------------------ */
    const map = new kakao.maps.Map(document.getElementById('kakao-map'), {
      center: new kakao.maps.LatLng(37.5665, 126.9780), // 서울시청. 마커가 있으면 아래에서 다시 맞춘다
      level: 8
    });
    document.getElementById('map-placeholder').remove();

    const bounds = new kakao.maps.LatLngBounds();
    let markerCount = 0;

    SALONS.forEach(function (salon, i) {
      if (salon.latitude == null || salon.longitude == null) {
        console.warn('좌표 없음 — 마커 생략:', salon.salonName, salon.address);
        return;
      }

      const position = new kakao.maps.LatLng(salon.latitude, salon.longitude);

      /* 기본 마커 대신 아이콘을 직접 그려서 선택/일반 색을 구분한다 */
      const element = document.createElement('i');
      element.className = 'fas fa-map-marker-alt map-pin pin-normal';
      element.title = salon.salonName;
      element.addEventListener('click', function () {
        selectSalon(i);
        map.panTo(position);
      });

      const overlay = new kakao.maps.CustomOverlay({
        map: map,
        position: position,
        content: element,
        xAnchor: 0.5,   // 아이콘 가로 중앙이
        yAnchor: 1.0,   // 아이콘 아래 끝이 좌표에 오도록
        clickable: true,
        zIndex: 1
      });

      PINS[i] = { element: element, overlay: overlay };
      bounds.extend(position);
      markerCount++;
    });

    /* 마커가 하나뿐이면 setBounds 가 최대로 확대돼 버려서 중심만 옮긴다 */
    if (markerCount === 1) {
      map.setCenter(bounds.getCenter());
      map.setLevel(5);
    } else if (markerCount > 1) {
      map.setBounds(bounds);
    }

    /* selectSalon(0) 이 마커 생성보다 먼저 실행되므로 여기서 한 번 색을 맞춰준다 */
    updatePinStyles();

    /* ---- 현재 위치 ---- */
    let hereOverlay = null;

    document.getElementById('btn-locate').addEventListener('click', function () {
      const button = this;

      if (!navigator.geolocation) {
        alert('이 브라우저에서는 현재 위치를 사용할 수 없습니다.');
        return;
      }

      button.disabled = true;
      navigator.geolocation.getCurrentPosition(
        function (result) {
          button.disabled = false;
          const here = new kakao.maps.LatLng(result.coords.latitude, result.coords.longitude);

          if (hereOverlay === null) {
            const dot = document.createElement('div');
            dot.className = 'map-here';
            dot.title = '현재 위치';
            hereOverlay = new kakao.maps.CustomOverlay({
              map: map, position: here, content: dot, xAnchor: 0.5, yAnchor: 0.5, zIndex: 20
            });
          } else {
            hereOverlay.setPosition(here);
            hereOverlay.setMap(map);
          }

          map.setLevel(5);
          map.panTo(here);
        },
        function (error) {
          button.disabled = false;
          console.warn('현재 위치 확인 실패:', error.message);
          alert('현재 위치를 가져오지 못했습니다. 브라우저의 위치 권한을 확인해 주세요.');
        },
        { enableHighAccuracy: true, timeout: 8000 }
      );
    });

  </script>
</body>
</html>
