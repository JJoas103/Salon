<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- 현재 페이지가 넘겨준 메뉴 키. 예) <jsp:param name="menu" value="reservations"/> --%>
<c:set var="menu" value="${param.menu}" />
<aside class="sidebar">
  <div class="sidebar-brand"><i class="fas fa-scissors" style="color: var(--accent);"></i><span>HAIR RESERVE</span></div>
  <ul class="sidebar-menu">
  <li class="sidebar-item ${menu == 'store' ? 'active' : ''}">
    <a href="<c:url value='/owner/store'/>"><i class="fas fa-store"></i> 매장정보 관리</a>
  </li>
  <li class="sidebar-item ${menu == 'staff' ? 'active' : ''}">
    <a href="<c:url value='/owner/staff'/>"><i class="fas fa-users"></i> 직원관리</a>
  </li>
  <li class="sidebar-item ${menu == 'reservations' ? 'active' : ''}">
    <a href="<c:url value='/owner/reservations'/>"><i class="fas fa-calendar-check"></i> 예약현황관리</a>
  </li>
  <li class="sidebar-item ${menu == 'events' ? 'active' : ''}">
    <a href="<c:url value='/owner/events'/>"><i class="fas fa-bullhorn"></i> 이벤트/공지사항</a>
  </li>
  <li class="sidebar-item ${menu == 'chat' ? 'active' : ''}">
    <a href="<c:url value='/owner/chat'/>"><i class="fas fa-comments"></i> 1:1 면담</a>
  </li>
  <li class="sidebar-item ${menu == 'mypage' ? 'active' : ''}">
    <a href="<c:url value='/owner/mypage'/>"><i class="fas fa-user"></i> 마이페이지</a>
  </li>
</ul>
  <div class="sidebar-footer">
    <a href="<c:url value='/user/logout'/>" class="sidebar-item-logout"><i class="fas fa-sign-out-alt"></i> 로그아웃</a>
  </div>
</aside>
