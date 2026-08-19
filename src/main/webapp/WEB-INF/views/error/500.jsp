<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | 서버 오류</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="/resources/css/common.css">
  <link rel="stylesheet" href="/resources/css/auth.css">
</head>
<body class="auth-page">
  <div class="auth-card error-card">
    <div class="error-icon"><i class="fas fa-triangle-exclamation"></i></div>
    <div class="error-code">500</div>
    <p class="error-message">일시적인 오류가 발생했습니다.<br>잠시 후 다시 시도해 주세요.</p>
    <a href="${pageContext.request.contextPath}/" class="btn-modern btn-primary" style="width: 100%; text-decoration: none;">메인으로 돌아가기</a>
  </div>
</body>
</html>
