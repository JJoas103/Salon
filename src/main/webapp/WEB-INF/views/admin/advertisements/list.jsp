<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | 광고 관리</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="<c:url value='/resources/css/common.css'/>">
  <link rel="stylesheet" href="<c:url value='/resources/css/admin.css'/>">
</head>
<body>
  <jsp:include page="../../includes/sidebar_admin.jsp"><jsp:param name="menu" value="advertisements" /></jsp:include>
  <div class="app-container">
    <header class="app-header">
      <div class="admin-page-title">광고 관리</div>
      <a class="btn-modern btn-primary admin-link-button" href="<c:url value='/admin/advertisements/new'/>"><i class="fas fa-plus"></i> 광고 등록</a>
    </header>
    <main class="app-content">
      <c:if test="${not empty message}"><div class="admin-alert admin-alert-success"><c:out value="${message}"/></div></c:if>
      <c:if test="${not empty errorMessage}"><div class="admin-alert admin-alert-error"><c:out value="${errorMessage}"/></div></c:if>
      <div class="modern-card advertisement-list-card">
        <div class="admin-section-heading">
          <div><h2>메인 슬라이드 광고</h2><p>활성 상태와 노출 기간을 모두 만족하는 광고만 사용자 홈에 표시됩니다.</p></div>
          <span class="advertisement-count"><c:out value="${advertisements.size()}"/>개</span>
        </div>
        <c:choose>
          <c:when test="${empty advertisements}">
            <div class="admin-empty-state"><i class="far fa-image"></i><strong>등록된 광고가 없습니다.</strong><span>첫 광고를 등록하면 사용자 홈의 기본 배너가 슬라이드로 교체됩니다.</span></div>
          </c:when>
          <c:otherwise>
            <div class="advertisement-table-wrap">
              <table class="modern-table advertisement-table">
                <thead><tr><th>순서</th><th>광고</th><th>노출 기간</th><th>상태</th><th>관리</th></tr></thead>
                <tbody>
                <c:forEach var="ad" items="${advertisements}">
                  <tr>
                    <td><strong><c:out value="${ad.displayOrder}"/></strong></td>
                    <td><div class="advertisement-summary"><img src="<c:url value='${ad.imageUrl}'/>" alt=""><div><strong><c:out value="${ad.title}"/></strong><span><c:out value="${ad.description}"/></span></div></div></td>
                    <td class="advertisement-period"><span>시작: <c:out value="${empty ad.startAt ? '제한 없음' : ad.startAt}"/></span><span>종료: <c:out value="${empty ad.endAt ? '제한 없음' : ad.endAt}"/></span></td>
                    <td><span class="status-tag ${ad.active ? 'status-active' : 'status-inactive'}">${ad.active ? '활성' : '비활성'}</span></td>
                    <td><div class="advertisement-actions">
                      <a class="btn-modern btn-outline admin-link-button" href="<c:url value='/admin/advertisements/${ad.advertisementId}/edit'/>">수정</a>
                      <form method="post" action="<c:url value='/admin/advertisements/${ad.advertisementId}/delete'/>" onsubmit="return confirm('이 광고를 삭제하시겠습니까? 삭제한 광고와 이미지는 복구할 수 없습니다.');"><button type="submit" class="btn-modern btn-danger">삭제</button></form>
                    </div></td>
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

  <jsp:include page="../../includes/profile_modal.jsp">
      <jsp:param name="roleLabel" value="관리자" />
  </jsp:include>
</body>
</html>
