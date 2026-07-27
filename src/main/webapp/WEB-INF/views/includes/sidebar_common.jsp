<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- 현재 페이지가 넘겨준 메뉴 키. 예) <jsp:param name="menu" value="reservations"/> --%>
<c:set var="menu" value="${param.menu}" />
<aside class="sidebar">
  <div class="sidebar-brand"><i class="fas fa-scissors" style="color: var(--accent);"></i><span>HAIR RESERVE</span></div>
  <ul class="sidebar-menu">
    <li class="sidebar-item ${menu == 'home' ? 'active' : ''}"><a href="<c:url value='/common/home'/>"><i class="fas fa-home"></i> 홈 메인</a></li>
    <li class="sidebar-item ${menu == 'search' ? 'active' : ''}"><a href="<c:url value='/common/search'/>"><i class="fas fa-search"></i> 헤어샵 검색/예약</a></li>
    <li class="sidebar-item ${menu == 'chat' ? 'active' : ''}"><a href="<c:url value='/common/chat'/>"><i class="fas fa-comments"></i> 1:1 상담 채팅</a></li>
    <li class="sidebar-item ${menu == 'community' ? 'active' : ''}"><a href="<c:url value='/common/community'/>"><i class="fas fa-users"></i> 스타일 커뮤니티</a></li>
    <li class="sidebar-item ${menu == 'reservations' ? 'active' : ''}"><a href="<c:url value='/common/reserve/info?category=1'/>"><i class="fas fa-calendar-alt"></i> 예약 내역</a></li>
    <li class="sidebar-item ${menu == 'mypage' ? 'active' : ''}"><a href="<c:url value='/common/mypage'/>"><i class="fas fa-user"></i> 마이페이지</a></li>
  </ul>
</aside>
