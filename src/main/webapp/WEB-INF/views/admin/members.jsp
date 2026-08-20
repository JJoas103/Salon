<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | 회원관리</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="/resources/css/common.css">
  <link rel="stylesheet" href="/resources/css/admin.css">
</head>
<body>
  <jsp:include page="../includes/sidebar_admin.jsp">
      <jsp:param name="menu" value="members" />
  </jsp:include>
  <div class="app-container">
    <header class="app-header">
      <div style="font-weight: 700; font-size: 18px;">회원관리</div>
    </header>
    <main class="app-content">
      <c:if test="${not empty error}">
        <p class="error-text"><c:out value="${error}" /></p>
      </c:if>

      <div class="stats-grid" style="grid-template-columns: repeat(4, 1fr);">
        <div class="stat-card"><div class="stat-label">총 가입 회원</div><div class="stat-value">${activeCount}명</div></div>
        <div class="stat-card"><div class="stat-label">신규 가입(이번 달)</div><div class="stat-value">${newThisMonthCount}명</div></div>
        <div class="stat-card"><div class="stat-label">탈퇴 회원</div><div class="stat-value">${deletedCount}명</div></div>
        <div class="stat-card"><div class="stat-label">권한 요청</div><div class="stat-value">${pendingOwnerRequestCount}명</div></div>
      </div>

      <div class="modern-card">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
          <h3>전체 회원 목록</h3>
        </div>

        <c:set var="roleTypeParam" value="${userType == 'ownerRequest' ? '' : userType}" />
        <c:url var="activeTabUrl" value="/admin/members">
          <c:param name="keyword" value="${keyword}"/>
          <c:param name="userType" value="${roleTypeParam}"/>
          <c:param name="size" value="${size}"/>
        </c:url>
        <c:url var="deletedTabUrl" value="/admin/members">
          <c:param name="keyword" value="${keyword}"/>
          <c:param name="userType" value="${roleTypeParam}"/>
          <c:param name="size" value="${size}"/>
          <c:param name="status" value="deleted"/>
        </c:url>
        <c:url var="ownerRequestTabUrl" value="/admin/members">
          <c:param name="keyword" value="${keyword}"/>
          <c:param name="size" value="${size}"/>
          <c:param name="userType" value="ownerRequest"/>
        </c:url>
        <c:set var="isOwnerRequestTab" value="${status != 'deleted' and userType == 'ownerRequest'}" />
        <div style="display: flex; gap: 8px; margin-bottom: 16px;">
          <a href="${activeTabUrl}" class="btn-modern ${status == 'deleted' or isOwnerRequestTab ? 'btn-outline' : 'btn-primary'}"
             style="text-decoration: none; ${status == 'deleted' or isOwnerRequestTab ? 'color: var(--text-main);' : ''}">활성 회원</a>
          <a href="${deletedTabUrl}" class="btn-modern ${status == 'deleted' ? 'btn-primary' : 'btn-outline'}"
             style="text-decoration: none; ${status == 'deleted' ? '' : 'color: var(--text-main);'}">탈퇴 회원</a>
          <a href="${ownerRequestTabUrl}" class="btn-modern ${isOwnerRequestTab ? 'btn-primary' : 'btn-outline'}"
             style="text-decoration: none; ${isOwnerRequestTab ? '' : 'color: var(--text-main);'}">점주 승격 요청 (${pendingOwnerRequestCount})</a>
        </div>

        <form action="${ctx}/admin/members" method="get"
              style="display: flex; gap: 10px; margin-bottom: 20px; flex-wrap: wrap;">
          <input type="hidden" name="status" value="${status}">
          <c:if test="${status != 'deleted'}">
            <select name="userType" class="modern-input" style="width: auto;">
              <option value="">전체 유형</option>
              <option value="customer" ${'customer' == userType ? 'selected' : ''}>고객</option>
              <option value="owner" ${'owner' == userType ? 'selected' : ''}>점주</option>
              <option value="admin" ${'admin' == userType ? 'selected' : ''}>관리자</option>
              <option value="ownerRequest" ${'ownerRequest' == userType ? 'selected' : ''}>권한요청</option>
            </select>
          </c:if>
          <input type="text" name="keyword" value="${keyword}" class="modern-input"
                 style="width: auto; flex: 1; min-width: 200px;" placeholder="이름 또는 이메일 검색">
          <select name="size" class="modern-input" style="width: auto;">
            <option value="10" ${size == 10 ? 'selected' : ''}>10명</option>
            <option value="20" ${size == 20 ? 'selected' : ''}>20명</option>
            <option value="50" ${size == 50 ? 'selected' : ''}>50명</option>
          </select>
          <button type="submit" class="btn-modern btn-primary"><i class="fas fa-search"></i> 검색</button>
          <c:if test="${not empty keyword or not empty userType}">
            <a href="${ctx}/admin/members" class="btn-modern btn-outline" style="text-decoration: none; color: var(--text-main);">초기화</a>
          </c:if>
        </form>

        <p style="color: var(--text-sub); font-size: 13px; margin-bottom: 10px;">
          총 <strong>${totalCount}</strong>명
        </p>

        <table class="modern-table">
          <thead>
            <tr><th>이메일</th><th>이름</th><th>전화번호</th><th>유형</th><th>가입일</th><th>관리</th></tr>
          </thead>
          <tbody>
            <c:choose>
              <c:when test="${empty members}">
                <tr><td colspan="6" style="text-align: center; color: var(--text-sub);">조회된 회원이 없습니다.</td></tr>
              </c:when>
              <c:otherwise>
                <c:forEach var="member" items="${members}">
                  <tr>
                    <td><c:out value="${member.email}" /></td>
                    <td><c:out value="${member.userName}" /></td>
                    <td><c:out value="${member.phoneNumber}" /></td>
                    <td>
                      <span class="tag">
                        <c:choose>
                          <c:when test="${member.userType == 'owner'}">점주</c:when>
                          <c:when test="${member.userType == 'admin'}">관리자</c:when>
                          <c:otherwise>고객</c:otherwise>
                        </c:choose>
                      </span>
                    </td>
                    <td>${fn:substring(member.createdAt, 0, 10)}</td>
                    <td>
                      <c:choose>
                        <c:when test="${status == 'deleted'}">
                          <span class="tag">탈퇴일: ${fn:substring(member.deletedAt, 0, 10)}</span>
                        </c:when>
                        <c:when test="${member.userType == 'customer'}">
                          <c:if test="${not empty member.pendingRequestId}">
                            <button type="button" class="tag owner-request-detail-btn"
                                    style="background: var(--accent-soft); color: var(--accent); border: none; cursor: pointer; margin-bottom: 6px; display: block;"
                                    data-request-id="${member.pendingRequestId}"
                                    data-request-type="${member.pendingRequestType}"
                                    data-applicant-name="<c:out value="${member.userName}"/>"
                                    data-applicant-email="<c:out value="${member.email}"/>"
                                    data-salon-name="<c:out value="${member.pendingSalonName}"/>"
                                    data-salon-phone="<c:out value="${member.pendingSalonPhone}"/>"
                                    data-message="<c:out value="${member.pendingMessage}"/>"
                                    data-requested-at="<c:out value="${fn:substring(member.pendingRequestedAt, 0, 16)}"/>">
                              점주 승격 요청 대기
                            </button>
                          </c:if>
                          <form action="${ctx}/admin/members/${member.userId}/withdraw" method="post"
                                onsubmit="return confirm('이 회원을 탈퇴 처리하시겠습니까?')" style="display: inline;">
                            <button type="submit" class="btn-modern btn-danger">탈퇴처리</button>
                          </form>
                        </c:when>
                        <c:when test="${member.userType == 'owner'}">
                          <c:if test="${not empty member.pendingRequestId}">
                            <span class="tag" style="background: var(--accent-soft); color: var(--accent); margin-bottom: 6px; display: block;" title="매장관리 > 매장 추가 요청 탭에서 승인/반려합니다.">
                              매장 추가 요청 대기 (매장관리에서 처리)
                            </span>
                          </c:if>
                          <form action="${ctx}/admin/members/${member.userId}/demote" method="post"
                                onsubmit="return confirm('일반회원으로 전환하시겠습니까? 전환 후에 탈퇴 처리가 가능합니다.')"
                                style="display: inline;">
                            <button type="submit" class="btn-modern btn-outline">일반회원으로 전환</button>
                          </form>
                        </c:when>
                        <c:otherwise>
                          <form action="${ctx}/admin/members/${member.userId}/demote" method="post"
                                onsubmit="return confirm('일반회원으로 전환하시겠습니까? 전환 후에 탈퇴 처리가 가능합니다.')"
                                style="display: inline;">
                            <button type="submit" class="btn-modern btn-outline">일반회원으로 전환</button>
                          </form>
                        </c:otherwise>
                      </c:choose>
                    </td>
                  </tr>
                </c:forEach>
              </c:otherwise>
            </c:choose>
          </tbody>
        </table>

        <c:if test="${totalPages > 1}">
          <div style="display: flex; justify-content: center; gap: 6px; margin-top: 20px;">
            <c:forEach begin="1" end="${totalPages}" var="p">
              <c:url var="pageUrl" value="/admin/members">
                <c:param name="keyword" value="${keyword}"/>
                <c:param name="userType" value="${userType}"/>
                <c:param name="status" value="${status}"/>
                <c:param name="size" value="${size}"/>
                <c:param name="page" value="${p}"/>
              </c:url>
              <c:choose>
                <c:when test="${p == page}">
                  <a href="${pageUrl}" class="btn-modern btn-primary" style="text-decoration: none;">${p}</a>
                </c:when>
                <c:otherwise>
                  <a href="${pageUrl}" class="btn-modern btn-outline" style="text-decoration: none; color: var(--text-main);">${p}</a>
                </c:otherwise>
              </c:choose>
            </c:forEach>
          </div>
        </c:if>
      </div>
    </main>
  </div>

  <div class="modal-overlay" id="ownerRequestDetailModal">
    <div class="modal-box" style="max-width: 480px;">
      <div class="modal-header">
        <h3 style="font-size: 18px;"><i class="fas fa-store" style="margin-right:8px; color:var(--accent);"></i>점주 승격 요청 상세</h3>
        <button type="button" class="modal-close" id="closeOwnerRequestDetailModalBtn"><i class="fas fa-times"></i></button>
      </div>
      <div style="display: flex; flex-direction: column; gap: 12px; font-size: 14px;">
        <div><strong>신청자</strong> &mdash; <span id="ownerRequestDetailApplicant"></span></div>
        <div><strong>매장명</strong> &mdash; <span id="ownerRequestDetailSalonName"></span></div>
        <div><strong>연락처</strong> &mdash; <span id="ownerRequestDetailSalonPhone"></span></div>
        <div><strong>신청일</strong> &mdash; <span id="ownerRequestDetailRequestedAt"></span></div>
        <div>
          <strong>신청 사유</strong>
          <p id="ownerRequestDetailMessage" style="white-space: pre-wrap; margin-top: 6px; color: var(--text-sub);"></p>
        </div>
      </div>
      <div style="display: flex; gap: 8px; margin-top: 20px;">
        <form id="ownerRequestApproveForm" method="post" style="flex: 1;">
          <button type="submit" class="btn-modern btn-primary" style="width: 100%;">승인</button>
        </form>
        <form id="ownerRequestRejectForm" method="post" style="flex: 1;">
          <button type="submit" class="btn-modern btn-outline" style="width: 100%;">반려</button>
        </form>
      </div>
    </div>
  </div>

  <script>
    (function () {
      var ctx = '${ctx}';
      var modal = document.getElementById('ownerRequestDetailModal');
      var approveForm = document.getElementById('ownerRequestApproveForm');
      var rejectForm = document.getElementById('ownerRequestRejectForm');
      document.querySelectorAll('.owner-request-detail-btn').forEach(function (btn) {
        btn.addEventListener('click', function () {
          document.getElementById('ownerRequestDetailApplicant').textContent =
            this.dataset.applicantName + ' (' + this.dataset.applicantEmail + ')';
          document.getElementById('ownerRequestDetailSalonName').textContent = this.dataset.salonName;
          document.getElementById('ownerRequestDetailSalonPhone').textContent = this.dataset.salonPhone;
          document.getElementById('ownerRequestDetailRequestedAt').textContent = this.dataset.requestedAt;
          document.getElementById('ownerRequestDetailMessage').textContent = this.dataset.message;
          approveForm.onsubmit = function () { return confirm('이 회원의 점주 승격 요청을 승인하시겠습니까?'); };
          rejectForm.onsubmit = function () { return confirm('이 회원의 점주 승격 요청을 반려하시겠습니까?'); };
          approveForm.action = ctx + '/admin/owner-requests/' + this.dataset.requestId + '/approve';
          rejectForm.action = ctx + '/admin/owner-requests/' + this.dataset.requestId + '/reject';
          modal.classList.add('active');
        });
      });
      document.getElementById('closeOwnerRequestDetailModalBtn').addEventListener('click', function () {
        modal.classList.remove('active');
      });
      modal.addEventListener('click', function (e) { if (e.target === modal) modal.classList.remove('active'); });
    })();
  </script>

  <jsp:include page="../includes/profile_modal.jsp">
      <jsp:param name="roleLabel" value="관리자" />
  </jsp:include>
</body>
</html>
