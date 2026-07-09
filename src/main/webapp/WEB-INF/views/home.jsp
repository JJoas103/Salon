<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>Salu - 미용실 관리 시스템</title>
    <style>
        body { font-family: system-ui, sans-serif; display: flex;
               align-items: center; justify-content: center; height: 100vh; margin: 0;
               background: #f5f5f7; }
        .card { text-align: center; padding: 40px 60px; background: #fff;
                border-radius: 16px; box-shadow: 0 8px 24px rgba(0,0,0,.08); }
        h1 { margin: 0 0 8px; color: #6b4eff; }
        p { color: #555; }
    </style>
</head>
<body>
    <div class="card">
        <h1>💇 Salu</h1>
        <p><c:out value="${message}" /></p>
        <p>Spring MVC 5 + MyBatis + JSP</p>
    </div>
</body>
</html>
