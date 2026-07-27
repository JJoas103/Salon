<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    <%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
      <%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
        <!DOCTYPE html>
        <html lang="ko">

        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>HAIR RESERVE | 회원가입</title>
          <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
          <link rel="stylesheet" href="/resources/css/common.css">
          <link rel="stylesheet" href="/resources/css/auth.css">
        </head>

        <body class="signup-page">
          <div class="auth-card">
            <div class="auth-header">
              <div class="auth-logo"><i class="fas fa-user-plus"></i> 신규 회원가입</div>
              <p style="font-size: 14px; color: var(--text-sub);">HAIR RESERVE 스마트 뷰티 시스템에 합류하세요</p>
            </div>
            <form action="/user/join" method="post">
              <input type="hidden" name="userType" value="customer">
              <div class="form-field">
                <label class="role-label">이름 / 상호명</label>
                <spring:bind path="joinUser.userName">
                  <div class="input-wrapper"><i class="far fa-user"></i><input type="text" name="name"
                      value="${status.value}" class="auth-input ${status.error ? 'input-error' : ''}"
                      placeholder="홍길동 또는 매장명"></div>
                  <c:if test="${status.error}"><small class="error-text">${status.errorMessage}</small></c:if>
                </spring:bind>
              </div>
              <div class="form-field form-field-email">
                <label class="role-label">이메일 주소</label>
                <spring:bind path="joinUser.email">
                  <div class="email-row">
                    <div class="input-wrapper"><i class="far fa-envelope"></i><input type="email" id="email"
                        name="email" value="${status.value}" class="auth-input ${status.error ? 'input-error' : ''}"
                        placeholder="example@hair.com"></div>
                    <button type="button" id="check-email-btn" class="btn-check">중복확인</button>
                  </div>
                  <small id="email-msg" class="${status.error ? 'error-text' : ''}" style="${status.error ? '' : 'display:none;'}">${status.error ? status.errorMessage : ''}</small>
                </spring:bind>
              </div>
              <div class="form-field">
                <label class="role-label">비밀번호 설정</label>
                <spring:bind path="joinUser.password">
                  <div class="input-wrapper"><i class="fas fa-lock"></i><input type="password" id="password"
                      name="password" class="auth-input ${status.error ? 'input-error' : ''}"
                      placeholder="8자리 이상 안전한 비밀번호"></div>
                  <c:if test="${status.error}"><small class="error-text">${status.errorMessage}</small></c:if>
                </spring:bind>
              </div>
              <div class="form-field">
                <label class="role-label">비밀번호 확인</label>
                <spring:bind path="joinUser.confirmPassword">
                  <div class="input-wrapper"><i class="fas fa-lock"></i><input type="password" id="confirmPassword"
                      name="confirmPassword" class="auth-input ${status.error ? 'input-error' : ''}"
                      placeholder="비밀번호를 다시 입력하세요"></div>
                  <small id="confirm-msg" class="error-text"
                    style="${status.error ? '' : 'display:none;'}">${status.error ? status.errorMessage : '비밀번호가 일치하지 않습니다'}</small>
                </spring:bind>
              </div>
              <button type="submit" class="btn-modern btn-primary" style="width: 100%; margin-top: 15px;">회원가입
                완료하기</button>
            </form>
            <div class="auth-footer">이미 계정이 있으신가요? <a href="/user/login" class="auth-link">로그인</a></div>
          </div>
          <script>
            const password = document.getElementById('password');
            const confirmPassword = document.getElementById('confirmPassword');
            const confirmMsg = document.getElementById('confirm-msg');

            function checkPasswordMatch() {
              if (confirmPassword.value.length === 0) {
                confirmMsg.style.display = 'none';
                confirmPassword.classList.remove('input-error');
                return;
              }
              const isMismatch = password.value !== confirmPassword.value;
              confirmMsg.style.display = isMismatch ? 'block' : 'none';
              confirmPassword.classList.toggle('input-error', isMismatch);
            }

            password.addEventListener('input', checkPasswordMatch);
            confirmPassword.addEventListener('input', checkPasswordMatch);

            // ---- 이메일 중복확인 및 형식 검증 ----
            const emailInput = document.getElementById('email');
            const checkEmailBtn = document.getElementById('check-email-btn');
            const emailMsg = document.getElementById('email-msg');

            const emailRegex = /^[\w.-]+@[\w.-]+\.[A-Za-z]{2,}$/;

            function showEmailMsg(text, ok) {
              emailMsg.textContent = text;
              emailMsg.className = ok ? 'success-text' : 'error-text';
              emailMsg.style.display = 'block';
              emailInput.classList.toggle('input-error', !ok);
            }

            checkEmailBtn.addEventListener('click', async () => {
              const email = emailInput.value.trim();
              if (email.length === 0) {
                showEmailMsg('이메일을 입력해주세요', false);
                return;
              }
              if (!emailRegex.test(email)) {
                showEmailMsg('이메일 형식이 올바르지 않습니다.', false);
                return;
              }
              try {
                const res = await fetch('/user/check-email?email=' + encodeURIComponent(email));
                const data = await res.json();
                showEmailMsg(
                  data.available ? '사용 가능한 이메일입니다' : '이미 사용 중인 이메일입니다',
                  data.available
                );
              } catch (e) {
                showEmailMsg('확인 중 오류가 발생했습니다', false);
              }
            });

            // 이메일을 다시 수정하면 이전 확인 결과를 지움
            emailInput.addEventListener('input', () => {
              emailMsg.style.display = 'none';
              emailInput.classList.remove('input-error');
            });
          </script>
        </body>

        </html>
