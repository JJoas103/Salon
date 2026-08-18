<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | 매장관리</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="/resources/css/common.css">
  <link rel="stylesheet" href="/resources/css/admin.css">
</head>
<body>
  <jsp:include page="../includes/sidebar_admin.jsp">
      <jsp:param name="menu" value="salons" />
  </jsp:include>
  <div class="app-container">
    <header class="app-header">
      <div style="font-weight: 700; font-size: 18px;">매장관리</div>
    </header>
    <main class="app-content">
      <c:if test="${not empty error}">
        <p class="error-text"><c:out value="${error}" /></p>
      </c:if>

      <div class="stats-grid">
        <div class="stat-card"><div class="stat-label">운영중인 매장</div><div class="stat-value">${activeSalonCount}개</div></div>
        <div class="stat-card"><div class="stat-label">이번 달 신규 등록</div><div class="stat-value">${newThisMonthCount}개</div></div>
        <div class="stat-card"><div class="stat-label">활성 예약 수</div><div class="stat-value">${activeReservationCount}건</div></div>
      </div>

      <div class="modern-card">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
          <h3>매장 목록</h3>
        </div>

        <c:url var="activeTabUrl" value="/admin/salons">
          <c:param name="keyword" value="${keyword}"/>
          <c:param name="size" value="${size}"/>
        </c:url>
        <c:url var="closedTabUrl" value="/admin/salons">
          <c:param name="keyword" value="${keyword}"/>
          <c:param name="size" value="${size}"/>
          <c:param name="status" value="closed"/>
        </c:url>
        <div style="display: flex; gap: 8px; margin-bottom: 16px;">
          <a href="${activeTabUrl}" class="btn-modern ${status == 'closed' ? 'btn-outline' : 'btn-primary'}"
             style="text-decoration: none; ${status == 'closed' ? 'color: var(--text-main);' : ''}">운영중 매장</a>
          <a href="${closedTabUrl}" class="btn-modern ${status == 'closed' ? 'btn-primary' : 'btn-outline'}"
             style="text-decoration: none; ${status == 'closed' ? '' : 'color: var(--text-main);'}">폐업 매장</a>
        </div>

        <form action="${ctx}/admin/salons" method="get"
              style="display: flex; gap: 10px; margin-bottom: 20px; flex-wrap: wrap;">
          <input type="hidden" name="status" value="${status}">
          <input type="text" name="keyword" value="${keyword}" class="modern-input"
                 style="width: auto; flex: 1; min-width: 200px;" placeholder="매장명, 주소 또는 점주명 검색">
          <select name="size" class="modern-input" style="width: auto;">
            <option value="10" ${size == 10 ? 'selected' : ''}>10개</option>
            <option value="20" ${size == 20 ? 'selected' : ''}>20개</option>
            <option value="50" ${size == 50 ? 'selected' : ''}>50개</option>
          </select>
          <button type="submit" class="btn-modern btn-primary"><i class="fas fa-search"></i> 검색</button>
          <c:if test="${not empty keyword}">
            <a href="${ctx}/admin/salons${status == 'closed' ? '?status=closed' : ''}" class="btn-modern btn-outline" style="text-decoration: none; color: var(--text-main);">초기화</a>
          </c:if>
        </form>

        <p style="color: var(--text-sub); font-size: 13px; margin-bottom: 10px;">
          총 <strong>${totalCount}</strong>개
        </p>

        <table class="modern-table">
          <thead><tr><th>매장 ID</th><th>매장명</th><th>위치</th><th>점주명</th><th>상태</th><th>관리</th></tr></thead>
          <tbody>
            <c:choose>
              <c:when test="${empty salons}">
                <tr><td colspan="6" style="text-align: center; color: var(--text-sub);">조회된 매장이 없습니다.</td></tr>
              </c:when>
              <c:otherwise>
                <c:forEach var="salon" items="${salons}">
                  <tr>
                    <td>#${salon.salonId}</td>
                    <td><c:out value="${salon.salonName}" /></td>
                    <td><c:out value="${salon.address}" /></td>
                    <td><c:out value="${salon.ownerName}" /></td>
                    <td>
                      <c:choose>
                        <c:when test="${status == 'closed'}">
                          <span class="status-tag status-inactive">폐업일: ${fn:substring(salon.closedAt, 0, 10)}</span>
                        </c:when>
                        <c:otherwise>
                          <span class="status-tag status-active">운영중</span>
                        </c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <c:choose>
                        <c:when test="${status == 'closed'}">
                          <form action="${ctx}/admin/salons/${salon.salonId}/reopen" method="post"
                                onsubmit="return confirm('이 매장을 다시 운영중으로 전환하시겠습니까?')" style="display: inline;">
                            <button type="submit" class="btn-modern btn-outline">폐업취소</button>
                          </form>
                        </c:when>
                        <c:otherwise>
                          <form action="${ctx}/admin/salons/${salon.salonId}/close" method="post"
                                onsubmit="return confirm('이 매장을 폐업 처리하시겠습니까?')" style="display: inline;">
                            <button type="submit" class="btn-modern btn-danger">폐업처리</button>
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
              <c:url var="pageUrl" value="/admin/salons">
                <c:param name="keyword" value="${keyword}"/>
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

  <jsp:include page="../includes/profile_modal.jsp">
      <jsp:param name="roleLabel" value="관리자" />
  </jsp:include>
</body>
</html>
