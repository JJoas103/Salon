<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | 로그인</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="/resources/css/common.css">
  <link rel="stylesheet" href="/resources/css/auth.css">
</head>
<body>
  <div class="auth-card">
    <div class="auth-header">
      <div class="auth-logo"><i class="fas fa-scissors"></i> HAIR RESERVE</div>
      <p style="font-size: 14px; color: var(--text-sub);">접속하실 계정의 시스템 권한을 선택해 주세요</p>
    </div>
    <c:if test="${param.error != null}">
      <div class="auth-alert"><i class="fas fa-circle-exclamation"></i> 이메일 또는 비밀번호가 올바르지 않습니다.</div>
    </c:if>
    <div class="role-selector-container">
      <label class="role-label">시스템 권한 선택</label>
      <div class="role-radio-group">
        <input type="radio" id="role-customer" name="user-role" value="CUSTOMER" checked>
        <label for="role-customer" class="role-radio-label">일반 사용자</label>
        <input type="radio" id="role-owner" name="user-role" value="OWNER">
        <label for="role-owner" class="role-radio-label">매장 점주</label>
        <input type="radio" id="role-admin" name="user-role" value="ADMIN">
        <label for="role-admin" class="role-radio-label">최고 관리자</label>
      </div>
    </div>
    <form action="/user/login" method="post">
        <div>
        <label class="role-label">이메일 계정</label>
        <div class="input-wrapper"><i class="far fa-envelope"></i><input type="email" name="userEmail" class="auth-input" placeholder="master@hairreserve.com"></div>
        </div>
        <div>
        <label class="role-label">비밀번호</label>
        <div class="input-wrapper"><i class="fas fa-lock"></i><input type="password" name="userPassword" class="auth-input" value=""></div>
        </div>
        <button class="btn-modern btn-primary" style="width: 100%; margin-top: 15px;">로그인 및 대시보드 이동</button>
    </form>
    <div class="auth-footer">아직 계정이 없으신가요? <a href="/user/join" class="auth-link">회원가입</a></div>
  </div>
</body>
</html>
