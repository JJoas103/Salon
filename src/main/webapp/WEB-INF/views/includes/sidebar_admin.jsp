<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="menu" value="${param.menu}" />
<aside class="sidebar">
  <div class="sidebar-brand"><i class="fas fa-scissors" style="color: var(--accent);"></i><span>HAIR RESERVE</span></div>
  <ul class="sidebar-menu">
    <li class="sidebar-item ${menu == 'salons' ? 'active' : ''}"><a href="<c:url value='/admin/salons'/>"><i class="fas fa-store"></i> 매장 관리</a></li>
    <li class="sidebar-item ${menu == 'members' ? 'active' : ''}"><a href="<c:url value='/admin/members'/>"><i class="fas fa-users"></i> 회원 관리</a></li>
    <li class="sidebar-item ${menu == 'community' ? 'active' : ''}"><a href="<c:url value='/admin/community'/>"><i class="fas fa-comments"></i> 커뮤니티 관리</a></li>
    <li class="sidebar-item ${menu == 'banners' ? 'active' : ''}"><a href="<c:url value='/admin/banners'/>"><i class="fas fa-bullhorn"></i> 배너 관리</a></li>
  </ul>
  <div class="sidebar-footer">
    <a href="<c:url value='/user/logout'/>" class="sidebar-item-logout"><i class="fas fa-sign-out-alt"></i> 로그아웃</a>
  </div>
</aside>
