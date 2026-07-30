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

        <!-- 우측 패널 : 검색 결과 목록 ⇄ 선택한 헤어샵 상세.
             둘 중 하나만 보인다 (JS 의 showList() / showDetail() 이 hidden 을 토글). -->
        <div class="salon-side-panel">

          <!-- 검색 결과 목록 -->
          <div class="salon-list-panel" id="salon-list-panel">
            <div class="salon-list-header" id="salon-list-count">검색 결과</div>
            <ul class="salon-list" id="salon-list"></ul>
            <p class="salon-list-empty" id="salon-list-empty" hidden>
              검색 결과가 없습니다.<br>다른 검색어로 찾아보세요.
            </p>
          </div>

          <!-- 선택한 헤어샵 상세 : 목록에서 하나를 고르면 보인다 -->
          <div id="salon-detail-panel" hidden>
            <button type="button" class="salon-back-btn" id="btn-back-to-list">
              <i class="fas fa-arrow-left"></i> 목록으로
            </button>

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
        </div>
      </div>
    </main>
  </div>
  
  <script src="https://dapi.kakao.com/v2/maps/sdk.js?appkey=${kakaoMapApiKey}&libraries=services&autoload=true"></script>
  <script>
    /* SalonVO 목록을 컨트롤러에서 JSON 으로 직렬화해 넘겨받는다. 키 이름은 VO 필드명 그대로다.
       ALL_SALONS 는 서버에서 받은 원본이라 바뀌지 않는다. 검색은 항상 이 배열을 대상으로 한다. */
    const ALL_SALONS = ${salonsJson};
    /* salons 는 지금 지도에 그려져 있는 목록. renderSalons() 가 통째로 갈아끼운다 */
    let salons = ALL_SALONS;

    const CONTEXT_PATH = '<c:url value="/"/>';
    /* imageUrl 이 비어 있는 미용실용 대체 이미지 (home.jsp 와 동일) */
    const FALLBACK_IMAGE = 'https://images.unsplash.com/photo-1560066984-138dadb4c035?auto=format&fit=crop&w=800&q=80';
    let selectedIndex = -1;
    /* 지도 마커. PINS[salons 의 index] = { element, overlay } — 좌표 없는 미용실 자리는 비어 있다 */
    const PINS = [];

    /* 지도는 renderSalons() 가 쓰므로 먼저 만들어 둔다 */
    const map = new kakao.maps.Map(document.getElementById('kakao-map'), {
      center: new kakao.maps.LatLng(37.5665, 126.9780), // 서울시청. 마커가 있으면 renderSalons() 가 다시 맞춘다
      level: 8
    });
    document.getElementById('map-placeholder').remove();

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

    /* ---- 우측 패널 전환 (목록 ⇄ 상세) ---- */
    function showList() {
      document.getElementById('salon-list-panel').hidden = false;
      document.getElementById('salon-detail-panel').hidden = true;
    }

    function showDetail() {
      document.getElementById('salon-list-panel').hidden = true;
      document.getElementById('salon-detail-panel').hidden = false;
    }

    document.getElementById('btn-back-to-list').addEventListener('click', showList);

    /* ---- 검색 결과 목록 ----
       마커와 같은 순번을 붙여서, 목록의 ②가 지도의 ②라는 걸 바로 알 수 있게 한다. */
    function renderSalonList(list) {
      const listElement = document.getElementById('salon-list');
      listElement.replaceChildren();   // 이전 결과 제거

      document.getElementById('salon-list-count').textContent = '검색 결과 ' + list.length + '건';
      document.getElementById('salon-list-empty').hidden = (list.length > 0);

      list.forEach(function (salon, i) {
        const item = document.createElement('li');
        item.className = 'salon-list-item';
        /* 마크업은 고정 문자열, 값은 textContent 로 넣는다 (미용실 이름에 <, & 가 있어도 안전) */
        item.innerHTML =
            '<span class="salon-list-rank"></span>'
          + '<div class="salon-list-body">'
          +   '<div class="salon-list-title-row">'
          +     '<span class="salon-list-name"></span>'
          +     '<span class="rating-badge"><i class="fas fa-star"></i> <span class="salon-list-rating"></span></span>'
          +   '</div>'
          +   '<p class="salon-list-address"></p>'
          +   '<p class="salon-list-price"></p>'
          + '</div>';

        item.querySelector('.salon-list-rank').textContent = i + 1;
        item.querySelector('.salon-list-name').textContent = salon.salonName;
        item.querySelector('.salon-list-rating').textContent = salon.averageRating != null ? salon.averageRating : '-';
        item.querySelector('.salon-list-address').textContent = salon.address;
        item.querySelector('.salon-list-price').textContent = formatPrice(salon.minimumPrice);

        /* 목록 ↔ 지도 연동 : 항목에 마우스를 올리면 해당 마커가 튀어나온다 */
        item.addEventListener('mouseenter', function () { hoverPin(i, true); });
        item.addEventListener('mouseleave', function () { hoverPin(i, false); });
        item.addEventListener('click', function () {
          hoverPin(i, false);
          selectSalon(i);
          const pin = PINS[i];
          if (pin) map.panTo(pin.overlay.getPosition());
        });

        listElement.appendChild(item);
      });
    }

    /* 지도 → 목록. 마커에 올린 미용실을 목록에서 강조하고, 목록 밖에 있으면 그 위치로 스크롤한다.
       block:'nearest' 라야 목록 안에서만 움직이고 페이지 전체가 스크롤되지 않는다. */
    function hoverListItem(index, on) {
      const item = document.querySelectorAll('.salon-list-item')[index];
      if (!item) return;
      item.classList.toggle('is-hover', on);
      if (on) item.scrollIntoView({ block: 'nearest', behavior: 'smooth' });
    }

    /* 목록 → 지도. 목록에서 hover 중인 항목의 마커를 잠깐 키운다 */
    function hoverPin(index, on) {
      const pin = PINS[index];
      if (!pin) return;   // 좌표가 없어 마커를 안 만든 미용실
      pin.element.classList.toggle('is-hover', on);
      pin.overlay.setZIndex(on ? 15 : (index === selectedIndex ? 10 : 1));
    }

    /* 지금 선택된 항목을 목록에서도 강조한다 (목록으로 돌아왔을 때 어디였는지 보이게) */
    function updateListActive() {
      document.querySelectorAll('.salon-list-item').forEach(function (item, i) {
        item.classList.toggle('is-active', i === selectedIndex);
      });
    }

    function selectSalon(index) {
      const salon = salons[index];
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
      document.getElementById('btn-reserve').disabled = false;
      updatePinStyles();
      updateListActive();
      showDetail();
    }

    /* 새로 검색하면 이전에 보던 미용실이 상세 카드에 남아 있으므로 비운다 */
    function clearDetail() {
      const image = document.getElementById('detail-image');
      image.src = FALLBACK_IMAGE;
      image.alt = '';
      document.getElementById('detail-name').textContent = '-';
      document.getElementById('detail-address').textContent = '-';
      document.getElementById('detail-rating').textContent = '-';
      document.getElementById('detail-hours').textContent = '-';
      document.getElementById('detail-price').textContent = '-';
      document.getElementById('btn-reserve').disabled = true;
    }

    /* 예약하기 → 기존 시술 선택 페이지로 이동 */
    document.getElementById('btn-reserve').addEventListener('click', function () {
      const salon = salons[selectedIndex];
      if (!salon) return;
      location.href = CONTEXT_PATH + 'common/search?salonId=' + salon.salonId;
    });
    
    /* ------------------------------------------------------------------
       지도에 그려진 미용실 목록을 list 로 통째로 갈아끼운다.
       두 번 이상 호출되므로 "이전 마커 제거 → 상태 교체 → 다시 그리기" 순서를
       지켜야 한다. 제거를 빼먹으면 검색할 때마다 핀이 지도에 쌓인다.

       마커는 Salons.latitude / longitude 를 그대로 쓴다. 좌표가 없는(NULL) 미용실은
       마커를 만들지 않는다. 미용실 등록 기능을 만들 때 등록 시점에 주소 → 좌표를
       한 번 변환해 저장하면 여기는 손댈 필요가 없다.
       ------------------------------------------------------------------ */
    function renderSalons(list) {
      /* ① 이전 마커 제거 — 지도에서 떼고 배열도 비운다 */
      PINS.forEach(function (pin) { pin.overlay.setMap(null); });
      PINS.length = 0;

      /* ② 상태 교체 — 이후 selectSalon / 예약하기가 보는 목록이 바뀐다 */
      salons = list;
      selectedIndex = -1;

      /* ③ 새 마커 */
      const bounds = new kakao.maps.LatLngBounds();
      let markerCount = 0;
      let lastPosition = null;   // 마커가 하나뿐일 때 그 좌표로 중심을 옮기려고 들고 있는다

      salons.forEach(function (salon, i) {
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

        /* 지도 → 목록 연동. 목록 → 지도(hoverPin)의 반대 방향이라,
           둘을 합치면 어느 쪽에 마우스를 올려도 나머지 한쪽이 어디인지 알 수 있다.
           마커에 번호를 붙이지 않아도 되는 이유가 이것이다. */
        element.addEventListener('mouseenter', function () { hoverListItem(i, true); });
        element.addEventListener('mouseleave', function () { hoverListItem(i, false); });

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
        lastPosition = position;
        markerCount++;
      });

      /* ④ 지도 범위. 마커가 하나뿐이면 setBounds 가 최대로 확대돼 버려서 중심만 옮긴다.
         카카오 LatLngBounds 에는 getCenter() 가 없으므로(구글 맵스 API 쪽 메서드다)
         마지막으로 만든 좌표를 그대로 쓴다. 마커가 하나면 그게 곧 그 마커의 좌표다. */
      if (markerCount === 1) {
        map.setCenter(lastPosition);
        map.setLevel(5);
      } else if (markerCount > 1) {
        map.setBounds(bounds);
      }

      /* ⑤ 우측 패널. 새 검색 결과는 항상 "목록"부터 보여준다.
         하나를 고르는 건 사용자 몫이라 여기서 selectSalon 을 부르지 않는다. */
      renderSalonList(salons);
      clearDetail();
      showList();
    }

    /* 검색 — 거르는 일은 서버(/common/salons/search)가 하고 여기는 결과를 그리기만 한다.
       엘라스틱서치를 붙여도 이 코드는 그대로다. 바뀌는 건 서버 안쪽뿐이다. */
    const searchButton = document.querySelector('.map-search-btn');

    document.getElementById('keyword').closest('form').addEventListener('submit', function() {
      const keyword = document.getElementById('keyword').value.trim();
      /* 연타하면 늦게 도착한 이전 응답이 나중 결과를 덮어쓸 수 있어 요청 중에는 막는다 */
      searchButton.disabled = true;
      fetch(CONTEXT_PATH + 'common/salons/search?keyword=' + encodeURIComponent(keyword))
      .then(function(response) {
        if(!response.ok) {
          throw new Error('검색 실패 (HTTP ' + response.status + ')');
        }
        /* 세션이 끊기면 스프링 시큐리티가 로그인 페이지로 리다이렉트하고,
           fetch 는 그걸 따라가서 HTML 을 200 으로 받아온다. response.ok 로는 못 거른다 */
        const contentType = response.headers.get('content-type') || '';
        if(!contentType.includes('application/json')) {
          throw new Error('로그인이 필요합니다. 다시 로그인해주세요');
        }
        return response.json();
      })
      .then(renderSalons)
      .catch(function (error) {
        console.error('검색 실패: ', error);
        alert(error.message);
      })
      .finally(function () {
        searchButton.disabled = false;
      });
    });
    renderSalons(ALL_SALONS);

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
