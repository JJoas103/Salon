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

          <%-- ---------- 할인 적용 ---------- --%>
          <section class="checkout-card">
            <div class="checkout-card-head">
              <h3>할인 적용</h3>
            </div>
            <div class="checkout-card-body">
              <%-- 쿠폰 — 못 쓰는 것도 사유와 함께 보여준다.
                   목록에서 빼버리면 "쿠폰이 사라졌다" 고 느끼고 왜 못 쓰는지 알 방법이 없다. --%>
              <div class="checkout-coupon">
                <div class="checkout-coupon-head">
                  <span><i class="fas fa-ticket" style="margin-right:8px;"></i> 쿠폰</span>
                  <span class="checkout-point-balance">
                    보유 <strong>${fn:length(quote.coupons)}</strong>장
                  </span>
                </div>

                <c:choose>
                  <c:when test="${empty quote.coupons}">
                    <p class="checkout-point-hint">사용할 수 있는 쿠폰이 없습니다.</p>
                  </c:when>
                  <c:otherwise>
                    <div class="checkout-coupon-list">
                      <%-- 예약당 1장이라 라디오다. 되돌릴 수 있게 "사용 안 함" 을 먼저 둔다. --%>
                      <label class="checkout-coupon-item is-none">
                        <input type="radio" name="couponPick" value="" checked>
                        <span class="checkout-coupon-name">쿠폰 사용 안 함</span>
                      </label>

                      <c:forEach var="coupon" items="${quote.coupons}">
                        <label class="checkout-coupon-item ${coupon.usable ? '' : 'is-disabled'}">
                          <input type="radio" name="couponPick" value="${coupon.userCouponId}"
                                 <c:if test="${not coupon.usable}">disabled</c:if>>
                          <span class="checkout-coupon-name">
                            <c:out value="${coupon.couponName}"/>
                            <c:if test="${not coupon.usable}">
                              <small><c:out value="${coupon.reason}"/></small>
                            </c:if>
                          </span>
                          <c:if test="${coupon.usable}">
                            <span class="checkout-coupon-amount">
                              -<fmt:formatNumber value="${coupon.discountAmount}" pattern="#,##0"/>원
                            </span>
                          </c:if>
                        </label>
                      </c:forEach>
                    </div>
                  </c:otherwise>
                </c:choose>
                <p class="checkout-point-hint is-warn" id="couponHint" hidden></p>
              </div>

              <div class="checkout-point">
                <div class="checkout-point-head">
                  <span><i class="fas fa-coins" style="margin-right:8px;"></i> 적립금</span>
                  <span class="checkout-point-balance">
                    보유 <strong id="pointBalance"><fmt:formatNumber value="${quote.pointBalance}" pattern="#,##0"/></strong>원
                  </span>
                </div>
                <div class="checkout-point-input">
                  <%-- 폼 밖에 두고 값만 hidden 으로 옮긴다. 입력 자체는 서버가 다시 검증하므로
                       여기서 막는 것은 편의일 뿐이고, 권위 있는 판정은 quote() 가 한다. --%>
                  <input type="number" id="pointInput" min="0" step="100" value="0"
                         max="${quote.maxPointUsable}" placeholder="0">
                  <button type="button" class="btn-modern btn-outline" id="pointAllBtn">전액 사용</button>
                </div>
                <p class="checkout-point-hint" id="pointHint">
                  <c:choose>
                    <c:when test="${quote.maxPointUsable > 0}">
                      최대 <fmt:formatNumber value="${quote.maxPointUsable}" pattern="#,##0"/>원까지 사용할 수 있습니다.
                    </c:when>
                    <c:otherwise>
                      사용할 수 있는 적립금이 없습니다.
                    </c:otherwise>
                  </c:choose>
                </p>
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
              <dd><fmt:formatNumber value="${quote.originalAmount}" pattern="#,##0"/>원</dd>
            </div>
            <%-- 쿠폰 줄은 Step 5 전까지 항상 0 이다. 자리를 미리 잡아두면
                 할인이 붙었을 때 금액이 어디서 깎였는지 그대로 보인다. --%>
            <div class="reserve-summary-row is-discount">
              <dt>쿠폰 할인</dt>
              <dd id="sumCoupon">-0원</dd>
            </div>
            <div class="reserve-summary-row is-discount">
              <dt>적립금 사용</dt>
              <dd id="sumPoint">-0원</dd>
            </div>
          </dl>

          <div class="reserve-summary-total">
            <span>최종 결제금액</span>
            <strong id="sumFinal"><fmt:formatNumber value="${quote.finalAmount}" pattern="#,##0"/>원</strong>
          </div>

          <p class="checkout-earn" id="sumEarn">
            이용 후 리뷰를 남기면 <strong><fmt:formatNumber value="${quote.earnPreview}" pattern="#,##0"/></strong>원이 적립됩니다.
          </p>

          <%-- 금액은 넘기지 않는다. 서버가 serviceId 로 가격을 다시 읽고
               같은 quote() 로 할인까지 재계산한다. 폼에 실린 금액을 믿으면
               1원짜리 결제를 만들 수 있다. --%>
          <form action="<c:url value='/common/reserve'/>" method="post" id="checkoutForm">
            <input type="hidden" name="salonId"         value="${salon.salonId}">
            <input type="hidden" name="serviceId"       value="${service.serviceId}">
            <input type="hidden" name="stylistId"       value="${stylist.stylistId}">
            <input type="hidden" name="reservationTime" value="<c:out value='${reservationTime}'/>">
            <input type="hidden" name="pointToUse"      id="fieldPointToUse" value="0">
            <input type="hidden" name="userCouponId"    id="fieldUserCouponId" value="">
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
    const QUOTE_URL = '<c:url value="/common/reserve/checkout/quote"/>';
    const SERVICE_ID = ${service.serviceId};

    const pointInput   = document.getElementById('pointInput');
    const pointAllBtn  = document.getElementById('pointAllBtn');
    const pointHint    = document.getElementById('pointHint');
    const couponHint   = document.getElementById('couponHint');
    const checkoutPayBtn = document.getElementById('checkoutPayBtn');

    const won = n => n.toLocaleString() + '원';

    /* 지금 고른 쿠폰. 빈 문자열이면 사용 안 함. */
    function pickedCouponId() {
      const checked = document.querySelector('input[name="couponPick"]:checked');
      return checked ? checked.value : '';
    }

    /* 쿠폰·적립금 선택이 바뀔 때마다 서버에 다시 물어본다.
       클라이언트에서 계산하지 않는 이유는, 화면 계산과 결제 계산이 두 벌이 되면
       반드시 어긋나기 때문이다. 상한/단위/할인액 판정이 전부 서버 몫이다. */
    async function refreshQuote() {
      const body = new URLSearchParams({
        serviceId: SERVICE_ID,
        pointToUse: pointInput.value || 0
      });
      /* 빈 값을 보내면 @RequestParam Integer 바인딩이 실패한다. 고른 경우에만 싣는다. */
      const couponId = pickedCouponId();
      if (couponId) body.append('userCouponId', couponId);

      const res = await fetch(QUOTE_URL, {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body
      });
      if (!res.ok) return;               /* 실패하면 화면을 건드리지 않는다 */
      const q = await res.json();

      /* 서버가 잘라낸 값으로 입력칸을 되돌린다 — 화면과 청구가 항상 같은 값을 본다 */
      pointInput.value = q.pointUsed;
      document.getElementById('fieldPointToUse').value = q.pointUsed;
      document.getElementById('fieldUserCouponId').value = q.couponDiscount > 0 ? couponId : '';

      /* 쿠폰이 적용되면 적립금 상한(쿠폰 적용 후 금액의 50%)이 함께 줄어든다 */
      pointInput.max = q.maxPointUsable;
      pointAllBtn.dataset.max = q.maxPointUsable;

      /* 고른 쿠폰이 그새 못 쓰게 된 경우(다른 탭에서 사용 등)의 안내 */
      const couponMessage = q.messages && q.messages.coupon;
      couponHint.textContent = couponMessage || '';
      couponHint.hidden = !couponMessage;

      document.getElementById('sumCoupon').textContent = '-' + won(q.couponDiscount);
      document.getElementById('sumPoint').textContent  = '-' + won(q.pointUsed);
      document.getElementById('sumFinal').textContent  = won(q.finalAmount);
      document.getElementById('sumEarn').innerHTML =
          '이용 후 리뷰를 남기면 <strong>' + q.earnPreview.toLocaleString() + '</strong>원이 적립됩니다.';

      /* 잘렸다면 왜 잘렸는지 알려준다 */
      const message = q.messages && q.messages.point;
      pointHint.textContent = message
          || (q.maxPointUsable > 0
                ? '최대 ' + won(q.maxPointUsable) + '까지 사용할 수 있습니다.'
                : '사용할 수 있는 적립금이 없습니다.');
      pointHint.classList.toggle('is-warn', !!message);

      /* 전액 할인이면 결제사를 거치지 않는다 */
      checkoutPayBtn.innerHTML = q.pgProvider === 'ZERO'
          ? '<i class="fas fa-check"></i> 적립금으로 결제 완료하기'
          : '<i class="fas fa-comment"></i> 카카오페이로 결제하기';
    }

    /* 타이핑마다 요청하면 과하므로 잠깐 멈췄을 때 한 번만 보낸다 */
    let quoteTimer;
    pointInput.addEventListener('input', () => {
      clearTimeout(quoteTimer);
      quoteTimer = setTimeout(refreshQuote, 350);
    });

    /* 상한은 쿠폰 적용 여부에 따라 바뀌므로 마지막 응답값을 쓴다 */
    pointAllBtn.dataset.max = ${quote.maxPointUsable};
    pointAllBtn.addEventListener('click', () => {
      pointInput.value = pointAllBtn.dataset.max;
      refreshQuote();
    });

    /* 쿠폰을 바꾸면 할인 후 금액이 달라져 적립금 상한도 다시 계산돼야 한다 */
    document.querySelectorAll('input[name="couponPick"]').forEach(radio => {
      radio.addEventListener('change', refreshQuote);
    });

    /* 결제는 되돌리기 어려운 동작이라 중복 제출을 막는다 (예약 화면과 같은 방식). */
    document.getElementById('checkoutForm').addEventListener('submit', () => {
      checkoutPayBtn.disabled = true;
      checkoutPayBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> 결제 진행 중...';
    });
  </script>
</body>
</html>
