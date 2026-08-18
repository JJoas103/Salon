<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | 페이지를 찾을 수 없음</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="/resources/css/common.css">
  <link rel="stylesheet" href="/resources/css/auth.css">
</head>
<body class="auth-page">
  <div class="auth-card error-card">
    <div class="error-icon"><i class="fas fa-map-signs"></i></div>
    <div class="error-code">404</div>
    <p class="error-message">페이지를 찾을 수 없습니다.<br>주소가 바뀌었거나 삭제된 페이지일 수 있어요.</p>
    <a href="${pageContext.request.contextPath}/" class="btn-modern btn-primary" style="width: 100%; text-decoration: none;">메인으로 돌아가기</a>
  </div>
</body>
</html>
