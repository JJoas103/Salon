<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | 쿠폰 관리</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="<c:url value='/resources/css/common.css'/>">
  <link rel="stylesheet" href="<c:url value='/resources/css/admin.css'/>">
</head>
<body>
  <jsp:include page="../../includes/sidebar_admin.jsp"><jsp:param name="menu" value="coupons" /></jsp:include>
  <div class="app-container">
    <header class="app-header">
      <div class="admin-page-title">쿠폰 관리</div>
      <a class="btn-modern btn-primary admin-link-button" href="<c:url value='/admin/coupons/new'/>"><i class="fas fa-plus"></i> 쿠폰 등록</a>
    </header>
    <main class="app-content">
      <c:if test="${not empty message}"><div class="admin-alert admin-alert-success"><c:out value="${message}"/></div></c:if>
      <c:if test="${not empty errorMessage}"><div class="admin-alert admin-alert-error"><c:out value="${errorMessage}"/></div></c:if>

      <div class="modern-card">
        <div class="admin-section-heading">
          <div>
            <h2>쿠폰 정책</h2>
            <p>중지된 쿠폰은 새로 발급되지 않지만, 이미 나간 쿠폰은 유효기간까지 사용할 수 있습니다.</p>
          </div>
          <span class="advertisement-count"><c:out value="${coupons.size()}"/>개</span>
        </div>

        <c:choose>
          <c:when test="${empty coupons}">
            <div class="admin-empty-state"><i class="fas fa-ticket"></i>
              <strong>등록된 쿠폰이 없습니다.</strong>
              <span>발급 경로를 "회원가입 자동" 으로 등록하면 신규 가입자에게 바로 나갑니다.</span>
            </div>
          </c:when>
          <c:otherwise>
            <div class="advertisement-table-wrap">
              <table class="modern-table">
                <thead>
                  <tr><th>쿠폰</th><th>할인</th><th>조건</th><th>기간</th><th>발급 / 사용</th><th>상태</th><th>관리</th></tr>
                </thead>
                <tbody>
                <c:forEach var="coupon" items="${coupons}">
                  <tr>
                    <td>
                      <strong><c:out value="${coupon.couponName}"/></strong>
                      <span class="coupon-admin-sub"><c:out value="${coupon.couponCode}"/></span>
                    </td>
                    <td>
                      <c:choose>
                        <c:when test="${coupon.discountType eq 'percent'}">
                          <strong><fmt:formatNumber value="${coupon.discountValue}" pattern="0"/>%</strong>
                          <span class="coupon-admin-sub">
                            <c:choose>
                              <c:when test="${not empty coupon.maxDiscount}">최대 <fmt:formatNumber value="${coupon.maxDiscount}" pattern="#,##0"/>원</c:when>
                              <c:otherwise>상한 없음</c:otherwise>
                            </c:choose>
                          </span>
                        </c:when>
                        <c:otherwise>
                          <strong><fmt:formatNumber value="${coupon.discountValue}" pattern="#,##0"/>원</strong>
                          <span class="coupon-admin-sub">정액</span>
                        </c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <c:choose>
                        <c:when test="${coupon.minOrderAmount > 0}"><fmt:formatNumber value="${coupon.minOrderAmount}" pattern="#,##0"/>원 이상</c:when>
                        <c:otherwise>금액 조건 없음</c:otherwise>
                      </c:choose>
                      <span class="coupon-admin-sub">
                        ${coupon.salonLimited ? '특정 매장 전용' : '전 매장 공통'}
                        <c:if test="${coupon.oncePerUser}"> · 1인 1매</c:if>
                      </span>
                    </td>
                    <td>
                      <c:out value="${coupon.validUntil}"/>까지
                      <span class="coupon-admin-sub">
                        ${coupon.issueType eq 'signup' ? '회원가입 자동' : '관리자 발급'}
                      </span>
                    </td>
                    <td><strong>${coupon.issuedCount}</strong> / ${coupon.usedCount}</td>
                    <td><span class="status-tag ${coupon.isActive ? 'status-active' : 'status-inactive'}">${coupon.isActive ? '활성' : '중지'}</span></td>
                    <td>
                      <div class="advertisement-actions">
                        <button type="button" class="btn-modern btn-outline"
                                onclick="openIssueModal(${coupon.couponId}, '<c:out value="${coupon.couponName}"/>', ${coupon.oncePerUser})">발급</button>
                        <form method="post" action="<c:url value='/admin/coupons/${coupon.couponId}/toggle'/>">
                          <button type="submit" class="btn-modern ${coupon.isActive ? 'btn-danger' : 'btn-primary'}">
                            ${coupon.isActive ? '중지' : '재개'}
                          </button>
                        </form>
                      </div>
                    </td>
                  </tr>
                </c:forEach>
                </tbody>
              </table>
            </div>
          </c:otherwise>
        </c:choose>
      </div>
    </main>
  </div>

  <%-- 지정 발급 — 회원 목록을 오가지 않고 이메일로 바로 찾는다 --%>
  <div class="modal-overlay" id="issueModal">
    <div class="modal-box">
      <div class="modal-header">
        <h3>쿠폰 발급</h3>
        <button type="button" class="modal-close" onclick="closeIssueModal()"><i class="fas fa-times"></i></button>
      </div>
      <form method="post" id="issueForm">
        <p class="coupon-issue-target" id="issueCouponName"></p>
        <p class="coupon-issue-note" id="issueOnceNote" hidden>
          <i class="fas fa-circle-info"></i> 1인 1매 쿠폰입니다. 이미 받은 회원에게는 발급되지 않습니다.
        </p>
        <label class="coupon-issue-label" for="issueEmail">회원 이메일</label>
        <input type="email" id="issueEmail" name="email" required placeholder="user@example.com">
        <div class="coupon-issue-actions">
          <button type="button" class="btn-modern btn-outline" onclick="closeIssueModal()">취소</button>
          <button type="submit" class="btn-modern btn-primary">발급</button>
        </div>
      </form>
    </div>
  </div>

  <script>
    const issueModal = document.getElementById('issueModal');
    const issueForm  = document.getElementById('issueForm');

    function openIssueModal(couponId, couponName, oncePerUser) {
      issueForm.action = '<c:url value="/admin/coupons"/>/' + couponId + '/issue';
      document.getElementById('issueCouponName').textContent = couponName;
      document.getElementById('issueOnceNote').hidden = !oncePerUser;
      document.getElementById('issueEmail').value = '';
      issueModal.classList.add('active');
      document.getElementById('issueEmail').focus();
    }

    function closeIssueModal() {
      issueModal.classList.remove('active');
    }

    /* 바깥을 눌러도 닫히게 — 모달 안쪽 클릭은 걸러낸다 */
    issueModal.addEventListener('click', e => {
      if (e.target === issueModal) closeIssueModal();
    });
  </script>
</body>
</html>
