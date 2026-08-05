<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | 결제 확인</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="/resources/css/common.css">
  <link rel="stylesheet" href="/resources/css/user.css">
  <link rel="stylesheet" href="/resources/css/auth.css">
</head>
<body class="reserve-page">
  <jsp:include page="../includes/sidebar_common.jsp">
    <jsp:param name="menu" value="search" />
  </jsp:include>

  <div class="app-container">
    <header class="app-header"></header>
    <main class="app-content">
      <%-- 컨트롤러가 조합 검증과 슬롯 확인을 통과시킨 뒤에만 이 화면이 뜬다.
           검증에 걸리면 reserve-result 로 빠지므로 여기서 오류 분기를 다루지 않는다. --%>
      <div class="reserve-layout">

        <%-- ============ 왼쪽: 확인 · 할인 · 결제수단 ============ --%>
        <div class="reserve-main">

          <div class="reserve-salon-head">
            <div>
              <h1><c:out value="${salon.salonName}"/></h1>
              <p class="reserve-salon-address">
                <i class="fas fa-location-dot"></i> <c:out value="${salon.address}"/>
              </p>
            </div>
            <span class="rating-badge">
              <i class="fas fa-star"></i>
              <fmt:formatNumber value="${salon.averageRating}" pattern="0.0"/>
            </span>
          </div>

          <%-- ---------- 예약 정보 ---------- --%>
          <section class="checkout-card">
            <div class="checkout-card-head">
              <h3>예약 정보</h3>
              <%-- 되돌아가면 선택이 처음부터다. 예약 화면이 단계 상태를 서버에 두지 않기 때문. --%>
              <a class="btn-modern btn-outline"
                 href="<c:url value='/common/reserve'><c:param name='salonId' value='${salon.salonId}'/></c:url>">
                <i class="fas fa-pen"></i> 수정
              </a>
            </div>
            <div class="checkout-card-body">
              <dl>
                <div class="checkout-info-row">
                  <dt>시술</dt>
                  <dd>
                    <c:out value="${service.serviceName}"/>
                    <c:if test="${service.durationMinutes > 0}">
                      <span class="reserve-service-duration">· 약 ${service.durationMinutes}분</span>
                    </c:if>
                  </dd>
                </div>
                <div class="checkout-info-row">
                  <dt>디자이너</dt>
                  <dd><c:out value="${stylist.stylistName}"/> 디자이너</dd>
                </div>
                <div class="checkout-info-row">
                  <dt>일시</dt>
                  <%-- reservationTime 은 'yyyy-MM-dd HH:mm' (reserve.jsp 가 이 형식으로 만든다) --%>
                  <dd>${fn:substring(reservationTime, 0, 10)} ${fn:substring(reservationTime, 11, 16)}</dd>
                </div>
              </dl>
            </div>
          </section>

          <%-- ---------- 할인 적용 (Step 4·5 에서 채운다) ---------- --%>
          <section class="checkout-card">
            <div class="checkout-card-head">
              <h3>할인 적용</h3>
            </div>
            <div class="checkout-card-body">
              <div class="checkout-soon">
                <span><i class="fas fa-ticket" style="margin-right:8px;"></i> 쿠폰</span>
                <span class="tag">준비중</span>
              </div>
              <div class="checkout-soon">
                <span><i class="fas fa-coins" style="margin-right:8px;"></i> 적립금</span>
                <span class="tag">준비중</span>
              </div>
            </div>
          </section>

          <%-- ---------- 결제수단 ----------
               지금은 카카오페이 하나뿐이라 항상 선택된 상태로 둔다.
               Step 3 에서 결제사가 늘어나면 여기에 선택지가 붙고,
               고른 값이 아래 폼의 pgProvider 로 실려 나간다. --%>
          <section class="checkout-card">
            <div class="checkout-card-head">
              <h3>결제수단</h3>
            </div>
            <div class="checkout-card-body">
              <label class="checkout-pay-option">
                <input type="radio" name="pgProviderPick" value="KAKAOPAY" checked>
                <i class="fas fa-comment"></i> 카카오페이
              </label>
            </div>
          </section>
        </div>

        <%-- ============ 오른쪽: 금액 요약 + 결제 ============ --%>
        <aside class="reserve-summary">
          <h3 class="reserve-summary-title">결제 금액</h3>

          <dl class="reserve-summary-list">
            <div class="reserve-summary-row">
              <dt>시술 금액</dt>
              <dd><fmt:formatNumber value="${service.price}" pattern="#,##0"/>원</dd>
            </div>
            <%-- 아래 두 줄은 Step 4·5 전까지 항상 0 이다. 자리를 미리 잡아두면
                 할인이 붙었을 때 금액이 어디서 깎였는지 그대로 보인다. --%>
            <div class="reserve-summary-row is-discount">
              <dt>쿠폰 할인</dt>
              <dd>-0원</dd>
            </div>
            <div class="reserve-summary-row is-discount">
              <dt>적립금 사용</dt>
              <dd>-0원</dd>
            </div>
          </dl>

          <div class="reserve-summary-total">
            <span>최종 결제금액</span>
            <strong><fmt:formatNumber value="${service.price}" pattern="#,##0"/>원</strong>
          </div>

          <%-- 금액은 넘기지 않는다. 서버가 serviceId 로 가격을 다시 읽는다.
               폼에 실린 금액을 믿으면 1원짜리 결제를 만들 수 있다. --%>
          <form action="<c:url value='/common/reserve'/>" method="post" id="checkoutForm">
            <input type="hidden" name="salonId"         value="${salon.salonId}">
            <input type="hidden" name="serviceId"       value="${service.serviceId}">
            <input type="hidden" name="stylistId"       value="${stylist.stylistId}">
            <input type="hidden" name="reservationTime" value="<c:out value='${reservationTime}'/>">
            <button type="submit" class="btn-modern btn-accent reserve-pay-btn" id="checkoutPayBtn">
              <i class="fas fa-comment"></i> 카카오페이로 결제하기
            </button>
          </form>

          <p class="reserve-summary-note">
            결제가 완료되면 예약이 확정됩니다. 결제창에서 10분 내 진행하지 않으면
            선택한 시간이 자동으로 해제됩니다.
          </p>
        </aside>
      </div>
    </main>
  </div>

  <script>
    /* 결제는 되돌리기 어려운 동작이라 중복 제출을 막는다 (예약 화면과 같은 방식). */
    const checkoutPayBtn = document.getElementById('checkoutPayBtn');
    document.getElementById('checkoutForm').addEventListener('submit', () => {
      checkoutPayBtn.disabled = true;
      checkoutPayBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> 결제창으로 이동 중...';
    });
  </script>
</body>
</html>
