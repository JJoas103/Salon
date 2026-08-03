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
          <a href="/common/reserve?category=1">전체 예약 히스토리</a>
        </div>

        <div class="res-tab active">
          <a href="${pageContext.request.contextPath}/common/calendar">
            예약 캘린더
          </a>
        </div>
      </div>
      <section class="calendar-card">

    <header class="calendar-page-header">
        <div>
            <h1 class="calendar-heading">
                <i class="fa-regular fa-calendar-check"></i>
                예약 캘린더
            </h1>

            <p class="calendar-description">
                예약 일정을 월별 캘린더와 목록으로 확인할 수 있습니다.
            </p>
        </div>

        <div class="view-switcher">
            <button type="button"
                    id="monthViewButton"
                    class="view-switch-button active">
                <i class="fa-regular fa-calendar"></i>
                월
            </button>

            <button type="button"
                    id="listViewButton"
                    class="view-switch-button">
                <i class="fa-solid fa-list"></i>
                목록
            </button>
        </div>
    </header>

    <section id="calendarView">
        <div id="calendar"></div>
    </section>

    <section id="listView" class="hidden">
        <div class="list-toolbar">
            <div class="list-month-navigation">
                <button type="button"
                        id="previousListMonth"
                        class="month-navigation-button">
                    <i class="fa-solid fa-chevron-left"></i>
                </button>

                <strong id="listMonthTitle"
                        class="list-month-title">
                </strong>

                <button type="button"
                        id="nextListMonth"
                        class="month-navigation-button">
                    <i class="fa-solid fa-chevron-right"></i>
                </button>
            </div>

            <p class="reservation-count">
                총 <strong id="reservationCount">0</strong>건의 예약
            </p>
        </div>

        <div id="reservationList"
             class="reservation-list">
        </div>
    </section>
</section>

    </main>
  </div>
  <!-- 예약 상세 모달 -->
<div id="reservationModal" class="reservation-modal">

    <div id="modalBackdrop"
         class="reservation-modal-backdrop">
    </div>

    <div class="reservation-modal-content">

        <div class="reservation-modal-header">

            <div>
                <span id="modalStatus"
                      class="modal-status">
                </span>

                <h2 id="modalServiceName">
                    예약 상세
                </h2>
            </div>

            <button id="modalCloseButton"
                    type="button"
                    class="modal-close-button"
                    aria-label="모달 닫기">
                <i class="fa-solid fa-xmark"></i>
            </button>

        </div>

        <div class="reservation-modal-body">

            <dl class="modal-detail-list">

                <div class="modal-detail-row">
                    <dt>미용실</dt>
                    <dd id="modalSalonName">-</dd>
                </div>

                <div class="modal-detail-row">
                    <dt>예약 날짜</dt>
                    <dd id="modalDate">-</dd>
                </div>

                <div class="modal-detail-row">
                    <dt>예약 시간</dt>
                    <dd id="modalTime">-</dd>
                </div>

                <div class="modal-detail-row">
                    <dt>디자이너</dt>
                    <dd id="modalStylist">-</dd>
                </div>

                <div class="modal-detail-row">
                    <dt>결제 금액</dt>
                    <dd id="modalPrice">-</dd>
                </div>

                <div class="modal-detail-row">
                    <dt>요청 사항</dt>
                    <dd id="modalRequest">요청 사항 없음</dd>
                </div>

            </dl>

        </div>

        <div class="reservation-modal-footer">

            <button id="modalGoogleButton"
                    type="button"
                    class="btn-modern btn-outline">
                <i class="fa-brands fa-google"></i>
                캘린더 추가
            </button>

            <button id="modalCancelButton"
                    type="button"
                    class="btn-modern btn-danger">
                예약 취소
            </button>

            <button id="modalConfirmButton"
                    type="button"
                    class="btn-modern btn-primary">
                확인
            </button>

        </div>

    </div>

</div>
  
  <script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.15/index.global.min.js"></script>

<script>
  const calendarContextPath = '${pageContext.request.contextPath}';
  
</script>

<script src="<c:url value='/resources/js/calendar.js'/>"></script>

</body>
</html>