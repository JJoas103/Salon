<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | 쿠폰 등록</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="<c:url value='/resources/css/common.css'/>">
  <link rel="stylesheet" href="<c:url value='/resources/css/admin.css'/>">
</head>
<body>
  <jsp:include page="../../includes/sidebar_admin.jsp"><jsp:param name="menu" value="coupons" /></jsp:include>
  <div class="app-container">
    <header class="app-header">
      <div class="admin-page-title">쿠폰 등록</div>
      <a class="btn-modern btn-outline admin-link-button" href="<c:url value='/admin/coupons'/>">목록으로</a>
    </header>
    <main class="app-content">
      <c:if test="${not empty errorMessage}"><div class="admin-alert admin-alert-error"><c:out value="${errorMessage}"/></div></c:if>

      <div class="modern-card" style="padding:28px;">
        <form method="post" action="<c:url value='/admin/coupons'/>">

          <%-- 라벨 텍스트와 별표는 반드시 한 <span> 안에 둔다.
               .admin-form-field 가 flex-direction:column 이라, 밖에 두면 별표가 아랫줄로 내려간다. --%>
          <div class="admin-form-row">
            <label class="admin-form-field">
              <span>쿠폰명 <em>*</em></span>
              <input class="modern-input" type="text" name="couponName" required maxlength="100"
                     value="<c:out value='${coupon.couponName}'/>" placeholder="신규 가입 감사 쿠폰">
            </label>
            <label class="admin-form-field">
              <span>쿠폰 코드 <em>*</em></span>
              <input class="modern-input" type="text" name="couponCode" required maxlength="50"
                     value="<c:out value='${coupon.couponCode}'/>" placeholder="WELCOME2026">
              <small>중복될 수 없습니다. 같은 쿠폰이 두 번 등록되는 것을 막습니다.</small>
            </label>
          </div>

          <div class="admin-form-row">
            <label class="admin-form-field">
              <span>할인 방식 <em>*</em></span>
              <select class="modern-input" name="discountType" id="discountType">
                <option value="percent" ${coupon.discountType eq 'percent' ? 'selected' : ''}>정률 (%)</option>
                <option value="amount"  ${coupon.discountType eq 'amount'  ? 'selected' : ''}>정액 (원)</option>
              </select>
            </label>
            <label class="admin-form-field">
              <span>할인값 <em>*</em></span>
              <input class="modern-input" type="number" name="discountValue" required min="1" step="1"
                     value="<c:out value='${coupon.discountValue}'/>" placeholder="10">
              <small id="discountValueHint">정률이면 10 = 10% 입니다.</small>
            </label>
          </div>

          <div class="admin-form-row">
            <label class="admin-form-field" id="maxDiscountField">
              <span>최대 할인액</span>
              <input class="modern-input" type="number" name="maxDiscount" min="0" step="100"
                     value="<c:out value='${coupon.maxDiscount}'/>" placeholder="5000">
              <small>비워두면 상한 없음</small>
            </label>
            <label class="admin-form-field">
              <span>최소 결제금액</span>
              <input class="modern-input" type="number" name="minOrderAmount" min="0" step="1000"
                     value="${empty coupon.minOrderAmount ? 0 : coupon.minOrderAmount}" placeholder="20000">
              <small>정가가 이 금액 미만이면 사용 불가</small>
            </label>
          </div>

          <div class="admin-form-row">
            <label class="admin-form-field">
              <span>유효기간 시작 <em>*</em></span>
              <input class="modern-input" type="date" name="validFrom" required
                     value="<c:out value='${coupon.validFrom}'/>">
            </label>
            <label class="admin-form-field">
              <span>유효기간 종료 <em>*</em></span>
              <input class="modern-input" type="date" name="validUntil" required
                     value="<c:out value='${coupon.validUntil}'/>">
              <small>발급 시 쿠폰에 복사됩니다</small>
            </label>
          </div>

          <div class="admin-form-row">
            <label class="admin-form-field">
              <span>발급 경로 <em>*</em></span>
              <select class="modern-input" name="issueType">
                <option value="admin"  ${coupon.issueType eq 'admin'  ? 'selected' : ''}>관리자 지정 발급</option>
                <option value="signup" ${coupon.issueType eq 'signup' ? 'selected' : ''}>회원가입 자동 발급</option>
              </select>
              <small>회원가입 자동으로 두면 이후 가입자에게 바로 나갑니다.</small>
            </label>
            <label class="admin-form-field">
              <span>적용 범위</span>
              <select class="modern-input" name="salonId">
                <option value="">전 매장 공통</option>
                <c:forEach var="salon" items="${salons}">
                  <option value="${salon.salonId}" ${coupon.salonId eq salon.salonId ? 'selected' : ''}>
                    <c:out value="${salon.salonName}"/>
                  </option>
                </c:forEach>
              </select>
            </label>
          </div>

          <label class="admin-check-field">
            <input type="checkbox" name="oncePerUser" value="true" ${coupon.oncePerUser ? 'checked' : ''}>
            <span>1인 1매만 발급 <small>이미 받은 회원에게는 다시 발급되지 않습니다. 사용한 쿠폰도 보유로 봅니다.</small></span>
          </label>

          <input type="hidden" name="isActive" value="true">

          <div class="coupon-issue-actions" style="margin-top:24px;">
            <a class="btn-modern btn-outline admin-link-button" href="<c:url value='/admin/coupons'/>">취소</a>
            <button type="submit" class="btn-modern btn-primary">등록</button>
          </div>
        </form>
      </div>
    </main>
  </div>

  <script>
    /* 정액 할인에는 최대 할인액이 의미가 없다. 값이 남아 서버로 실려가지 않게 비우고 잠근다. */
    const discountType = document.getElementById('discountType');
    const maxDiscountField = document.getElementById('maxDiscountField');
    const maxDiscountInput = maxDiscountField.querySelector('input');
    const discountValueHint = document.getElementById('discountValueHint');

    function syncDiscountType() {
      const percent = discountType.value === 'percent';
      maxDiscountInput.disabled = !percent;
      if (!percent) maxDiscountInput.value = '';
      maxDiscountField.style.opacity = percent ? '1' : '.45';
      discountValueHint.textContent = percent
          ? '정률이면 10 = 10% 입니다.'
          : '결제금액에서 이 금액만큼 빠집니다.';
    }

    discountType.addEventListener('change', syncDiscountType);
    syncDiscountType();
  </script>
</body>
</html>
