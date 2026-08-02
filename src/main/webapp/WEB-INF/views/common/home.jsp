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
            <c:choose>
                <c:when test="${not empty advertisements}">
                    <section class="advertisement-slider" id="advertisementSlider"
                             aria-roledescription="carousel" aria-label="프로모션 광고">
                        <div class="advertisement-slides">
                            <c:forEach var="ad" items="${advertisements}" varStatus="status">
                                <article class="advertisement-slide ${status.first ? 'is-active' : ''}"
                                         data-index="${status.index}"
                                         data-target="<c:out value='${ad.targetUrl}'/>"
                                         aria-hidden="${status.first ? 'false' : 'true'}">
                                    <img src="<c:url value='${ad.imageUrl}'/>" alt="">
                                    <div class="advertisement-slide-overlay"></div>
                                    <div class="advertisement-slide-copy">
                                        <h1><c:out value="${ad.title}"/></h1>
                                        <c:if test="${not empty ad.description}"><p><c:out value="${ad.description}"/></p></c:if>
                                    </div>
                                </article>
                            </c:forEach>
                        </div>
                        <div class="advertisement-controls">
                            <div class="advertisement-pager">
                                <button type="button" class="advertisement-arrow advertisement-prev" aria-label="이전 광고"><i class="fas fa-chevron-left"></i></button>
                                <span class="advertisement-counter"><strong id="advertisementCurrent">1</strong><span>/</span><span id="advertisementTotal">${advertisements.size()}</span></span>
                                <button type="button" class="advertisement-arrow advertisement-next" aria-label="다음 광고"><i class="fas fa-chevron-right"></i></button>
                            </div>
                            <button type="button" class="advertisement-list-button" aria-label="전체 광고 목록 열기" aria-expanded="false"><i class="fas fa-bars"></i></button>
                        </div>
                        <div class="advertisement-list-overlay" aria-hidden="true">
                            <div class="advertisement-list-panel" role="dialog" aria-modal="true" aria-label="전체 광고 목록">
                                <div class="advertisement-list-header"><strong>전체 프로모션</strong><button type="button" class="advertisement-list-close" aria-label="목록 닫기"><i class="fas fa-times"></i></button></div>
                                <div class="advertisement-list-items">
                                    <c:forEach var="ad" items="${advertisements}" varStatus="status">
                                        <button type="button" class="advertisement-list-item ${status.first ? 'is-selected' : ''}" data-index="${status.index}">
                                            <img src="<c:url value='${ad.imageUrl}'/>" alt="">
                                            <span><c:out value="${ad.title}"/></span>
                                        </button>
                                    </c:forEach>
                                </div>
                            </div>
                        </div>
                    </section>
                </c:when>
                <c:otherwise>
                    <div class="hero-section">
                        <h1 style="font-size: 32px; font-weight: 800; margin-bottom: 12px;">나만을 위한 맞춤형 헤어 솔루션</h1>
                        <p style="font-size: 16px; color: var(--text-light); line-height: 1.6;">2026년 트렌드 스타일 분석부터 간편한 결제 및 실시간 예약 조율까지 한번에 경험해 보세요.</p>
                    </div>
                </c:otherwise>
            </c:choose>
            <div class="salon-recommendation-header">
                <h2 id="salonRecommendationTitle">인기 급상승 헤어샵 추천</h2>
                <div class="salon-category-selector" id="salonCategorySelector">
                    <span class="salon-category-current" id="salonCategoryCurrent">인기 급상승</span>
                    <button type="button" class="salon-category-button" id="salonCategoryButton"
                            aria-label="헤어샵 추천 카테고리 열기" aria-expanded="false">
                        <i class="fas fa-bars"></i>
                    </button>
                    <div class="salon-category-menu" id="salonCategoryMenu" role="menu" aria-hidden="true">
                        <button type="button" role="menuitem" data-category="popular" data-label="인기 급상승" class="is-selected">인기 급상승</button>
                        <button type="button" role="menuitem" data-category="distance" data-label="거리순">거리순</button>
                        <button type="button" role="menuitem" data-category="rating" data-label="평점순">평점순</button>
                    </div>
                </div>
            </div>
            <p class="salon-category-message" id="salonCategoryMessage" role="status" aria-live="polite"></p>
            <div class="home-grid" id="salonRecommendationGrid">
                <c:forEach var="salon" items="${salons}" varStatus="status">
                    <div class="modern-card salon-recommendation-card"
                         data-original-index="${status.index}"
                         data-rating="<c:out value='${salon.averageRating}'/>"
                         data-latitude="<c:out value='${salon.latitude}'/>"
                         data-longitude="<c:out value='${salon.longitude}'/>">
                        <c:choose>
                            <c:when test="${not empty salon.imageUrl}">
                                <img src="<c:out value='${salon.imageUrl}'/>" class="salon-card-image" alt="<c:out value='${salon.salonName}'/>"
                                     onerror="this.onerror=null;this.src='https://images.unsplash.com/photo-1560066984-138dadb4c035?auto=format&amp;fit=crop&amp;w=600&amp;q=80';">
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
                                <div class="salon-card-actions">
                                    <form class="wishlist-form" data-salon-id="${salon.salonId}" method="post" action="<c:url value='/common/salons/${salon.salonId}/wishlist'/>">
                                        <input type="hidden" name="source" value="home">
                                        <button type="submit" class="btn-modern btn-outline wishlist-btn ${wishlistedSalonIds.contains(salon.salonId) ? 'is-active' : ''}">
                                            <i class="${wishlistedSalonIds.contains(salon.salonId) ? 'fas' : 'far'} fa-heart"></i>
                                            ${wishlistedSalonIds.contains(salon.salonId) ? '찜완료' : '찜하기'}
                                        </button>
                                    </form>
                                    <button type="button" class="btn-modern btn-outline"
                                            onclick="location.href='<c:url value="/common/salons/${salon.salonId}/reviews"/>'">리뷰</button>
                                <button type="button" class="btn-modern btn-primary"
                                    onclick="location.href='<c:url value="/common/search"><c:param name="salonId" value="${salon.salonId}"/></c:url>'">
                                    예약하기
                                </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>        </main>
    </div>
<script>
(function () {
    const slider = document.getElementById('advertisementSlider');
    if (!slider) return;

    const slides = Array.from(slider.querySelectorAll('.advertisement-slide'));
    const listItems = Array.from(slider.querySelectorAll('.advertisement-list-item'));
    const previousButton = slider.querySelector('.advertisement-prev');
    const nextButton = slider.querySelector('.advertisement-next');
    const listButton = slider.querySelector('.advertisement-list-button');
    const listOverlay = slider.querySelector('.advertisement-list-overlay');
    const closeButton = slider.querySelector('.advertisement-list-close');
    const currentLabel = document.getElementById('advertisementCurrent');
    let currentIndex = 0;
    let timer = null;
    let paused = false;

    function showSlide(index) {
        currentIndex = (index + slides.length) % slides.length;
        slides.forEach(function (slide, slideIndex) {
            const active = slideIndex === currentIndex;
            slide.classList.toggle('is-active', active);
            slide.setAttribute('aria-hidden', active ? 'false' : 'true');
        });
        listItems.forEach(function (item, itemIndex) {
            item.classList.toggle('is-selected', itemIndex === currentIndex);
        });
        currentLabel.textContent = String(currentIndex + 1);
    }

    function stopAutoPlay() {
        if (timer) window.clearInterval(timer);
        timer = null;
    }

    function startAutoPlay() {
        stopAutoPlay();
        if (slides.length > 1 && !paused && !listOverlay.classList.contains('is-open')) {
            timer = window.setInterval(function () { showSlide(currentIndex + 1); }, 5000);
        }
    }

    function moveTo(index) {
        showSlide(index);
        startAutoPlay();
    }

    function openList() {
        paused = true;
        stopAutoPlay();
        listOverlay.classList.add('is-open');
        listOverlay.setAttribute('aria-hidden', 'false');
        listButton.setAttribute('aria-expanded', 'true');
        closeButton.focus();
    }

    function closeList() {
        listOverlay.classList.remove('is-open');
        listOverlay.setAttribute('aria-hidden', 'true');
        listButton.setAttribute('aria-expanded', 'false');
        paused = false;
        listButton.focus();
        startAutoPlay();
    }

    previousButton.addEventListener('click', function () { moveTo(currentIndex - 1); });
    nextButton.addEventListener('click', function () { moveTo(currentIndex + 1); });
    listButton.addEventListener('click', openList);
    closeButton.addEventListener('click', closeList);
    listOverlay.addEventListener('click', function (event) { if (event.target === listOverlay) closeList(); });
    listItems.forEach(function (item) {
        item.addEventListener('click', function () {
            showSlide(Number(item.dataset.index));
            closeList();
        });
    });
    slides.forEach(function (slide) {
        slide.addEventListener('click', function () {
            const target = slide.dataset.target;
            if (target) {
                window.open(target, '_blank', 'noopener,noreferrer');
            }
        });
    });
    slider.addEventListener('mouseenter', function () { paused = true; stopAutoPlay(); });
    slider.addEventListener('mouseleave', function () { paused = false; startAutoPlay(); });
    slider.addEventListener('focusin', function () { paused = true; stopAutoPlay(); });
    slider.addEventListener('focusout', function (event) {
        if (!slider.contains(event.relatedTarget) && !listOverlay.classList.contains('is-open')) {
            paused = false;
            startAutoPlay();
        }
    });
    document.addEventListener('keydown', function (event) {
        if (event.key === 'Escape' && listOverlay.classList.contains('is-open')) {
            closeList();
        } else if (!listOverlay.classList.contains('is-open') && event.key === 'ArrowLeft') {
            moveTo(currentIndex - 1);
        } else if (!listOverlay.classList.contains('is-open') && event.key === 'ArrowRight') {
            moveTo(currentIndex + 1);
        }
    });

    if (slides.length === 1) {
        previousButton.disabled = true;
        nextButton.disabled = true;
    }
    startAutoPlay();
}());

(function () {
    const selector = document.getElementById('salonCategorySelector');
    const categoryButton = document.getElementById('salonCategoryButton');
    const categoryMenu = document.getElementById('salonCategoryMenu');
    const currentLabel = document.getElementById('salonCategoryCurrent');
    const title = document.getElementById('salonRecommendationTitle');
    const message = document.getElementById('salonCategoryMessage');
    const grid = document.getElementById('salonRecommendationGrid');
    if (!selector || !categoryButton || !categoryMenu || !grid) return;

    const menuItems = Array.from(categoryMenu.querySelectorAll('[data-category]'));
    const cards = Array.from(grid.querySelectorAll('.salon-recommendation-card'));

    function openMenu() {
        categoryMenu.classList.add('is-open');
        categoryMenu.setAttribute('aria-hidden', 'false');
        categoryButton.setAttribute('aria-expanded', 'true');
    }

    function closeMenu() {
        categoryMenu.classList.remove('is-open');
        categoryMenu.setAttribute('aria-hidden', 'true');
        categoryButton.setAttribute('aria-expanded', 'false');
    }

    function renderCards(sortedCards) {
        sortedCards.forEach(function (card) { grid.appendChild(card); });
    }

    function setCategory(item) {
        const category = item.dataset.category;
        const label = item.dataset.label;
        currentLabel.textContent = label;
        title.textContent = label + ' 헤어샵 추천';
        message.textContent = '';
        menuItems.forEach(function (menuItem) {
            menuItem.classList.toggle('is-selected', menuItem === item);
        });
        closeMenu();

        if (category === 'popular') {
            renderCards(cards.slice().sort(function (a, b) {
                return Number(a.dataset.originalIndex) - Number(b.dataset.originalIndex);
            }));
            return;
        }
        if (category === 'rating') {
            renderCards(cards.slice().sort(function (a, b) {
                const difference = (Number(b.dataset.rating) || 0) - (Number(a.dataset.rating) || 0);
                return difference || Number(a.dataset.originalIndex) - Number(b.dataset.originalIndex);
            }));
            return;
        }

        message.textContent = '현재 위치를 확인하고 있습니다.';
        if (!navigator.geolocation) {
            message.textContent = '이 브라우저에서는 위치 기반 정렬을 사용할 수 없습니다.';
            return;
        }
        navigator.geolocation.getCurrentPosition(function (position) {
            const userLatitude = position.coords.latitude;
            const userLongitude = position.coords.longitude;
            const withDistance = cards.map(function (card) {
                const latitudeText = (card.dataset.latitude || '').trim();
                const longitudeText = (card.dataset.longitude || '').trim();
                const latitude = latitudeText === '' ? Number.NaN : Number(latitudeText);
                const longitude = longitudeText === '' ? Number.NaN : Number(longitudeText);
                return {
                    card: card,
                    distance: Number.isFinite(latitude) && Number.isFinite(longitude)
                        ? calculateDistance(userLatitude, userLongitude, latitude, longitude)
                        : Number.POSITIVE_INFINITY
                };
            });
            withDistance.sort(function (a, b) {
                return a.distance - b.distance
                    || Number(a.card.dataset.originalIndex) - Number(b.card.dataset.originalIndex);
            });
            renderCards(withDistance.map(function (item) { return item.card; }));

            const locatedCount = withDistance.filter(function (item) {
                return Number.isFinite(item.distance);
            }).length;
            if (locatedCount === 0) {
                message.textContent = '위치 좌표가 등록된 헤어샵이 없어 거리순으로 정렬할 수 없습니다.';
            } else if (locatedCount < withDistance.length) {
                message.textContent = '현재 위치에서 가까운 순서입니다. 좌표가 없는 '
                    + String(withDistance.length - locatedCount) + '개 매장은 뒤에 표시됩니다.';
            } else {
                message.textContent = '현재 위치에서 가까운 순서로 정렬했습니다.';
            }
        }, function () {
            message.textContent = '거리순 정렬을 사용하려면 브라우저의 위치 권한을 허용해 주세요.';
        }, { enableHighAccuracy: false, timeout: 10000, maximumAge: 300000 });
    }

    function calculateDistance(lat1, lon1, lat2, lon2) {
        const earthRadius = 6371;
        const toRadians = function (degree) { return degree * Math.PI / 180; };
        const latitudeDifference = toRadians(lat2 - lat1);
        const longitudeDifference = toRadians(lon2 - lon1);
        const value = Math.sin(latitudeDifference / 2) * Math.sin(latitudeDifference / 2)
            + Math.cos(toRadians(lat1)) * Math.cos(toRadians(lat2))
            * Math.sin(longitudeDifference / 2) * Math.sin(longitudeDifference / 2);
        return earthRadius * 2 * Math.atan2(Math.sqrt(value), Math.sqrt(1 - value));
    }

    categoryButton.addEventListener('click', function () {
        if (categoryMenu.classList.contains('is-open')) closeMenu();
        else openMenu();
    });
    menuItems.forEach(function (item) {
        item.addEventListener('click', function () { setCategory(item); });
    });
    document.addEventListener('click', function (event) {
        if (!selector.contains(event.target)) closeMenu();
    });
    document.addEventListener('keydown', function (event) {
        if (event.key === 'Escape') closeMenu();
    });
}());
</script>
<script src="<c:url value='/resources/js/wishlist.js'/>"></script>
</body>
</html>
