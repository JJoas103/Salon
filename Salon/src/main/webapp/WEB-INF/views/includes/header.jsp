<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%-- 로그인 상태에 따라 로그인/회원가입 ↔ 이름/로그아웃 을 보여주는 공통 헤더 --%>
<header class="app-header">
    <sec:authorize access="isAuthenticated()">
        <div class="user-badge">
            <span><sec:authentication property="principal.userName"/> 고객님</span>
            <a href="<c:url value='/user/logout'/>">로그아웃</a>
        </div>
    </sec:authorize>
    <sec:authorize access="!isAuthenticated()">
        <div class="user-badge">
            <a href="<c:url value='/user/login'/>">로그인</a>
            <a href="<c:url value='/user/join'/>">회원가입</a>
        </div>
    </sec:authorize>
</header>
