<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | 광고 ${formMode == 'create' ? '등록' : '수정'}</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="<c:url value='/resources/css/common.css'/>">
  <link rel="stylesheet" href="<c:url value='/resources/css/admin.css'/>">
</head>
<body>
  <jsp:include page="../../includes/sidebar_admin.jsp"><jsp:param name="menu" value="advertisements" /></jsp:include>
  <div class="app-container">
    <header class="app-header">
      <div class="admin-page-title">광고 ${formMode == 'create' ? '등록' : '수정'}</div>
      <a class="btn-modern btn-outline admin-link-button" href="<c:url value='/admin/advertisements'/>"><i class="fas fa-arrow-left"></i> 목록</a>
    </header>
    <main class="app-content">
      <c:if test="${not empty errorMessage}"><div class="admin-alert admin-alert-error"><c:out value="${errorMessage}"/></div></c:if>
      <c:choose>
        <c:when test="${formMode == 'create'}"><c:url var="formAction" value="/admin/advertisements"/></c:when>
        <c:otherwise><c:url var="formAction" value="/admin/advertisements/${advertisement.advertisementId}"/></c:otherwise>
      </c:choose>
      <form class="advertisement-form" id="advertisementForm" method="post" enctype="multipart/form-data" action="${formAction}">
        <section class="modern-card advertisement-form-fields">
          <div class="admin-section-heading"><div><h2>광고 정보</h2><p>사용자 홈 슬라이드에 표시할 내용을 입력해 주세요.</p></div></div>
          <label class="admin-form-field"><span>광고 제목 <em>*</em></span><input class="modern-input" type="text" name="title" maxlength="200" required value="<c:out value='${advertisement.title}'/>"></label>
          <label class="admin-form-field"><span>광고 설명</span><textarea class="modern-input" name="description" maxlength="500" rows="4"><c:out value="${advertisement.description}"/></textarea></label>
          <label class="admin-form-field"><span>클릭 연결 URL</span><input class="modern-input" type="text" name="targetUrl" maxlength="1000" placeholder="/common/search 또는 https://example.com" value="<c:out value='${advertisement.targetUrl}'/>"><small>/로 시작하는 내부 경로 또는 http(s) 주소만 사용할 수 있습니다.</small></label>
          <div class="admin-form-row">
            <label class="admin-form-field"><span>노출 순서 <em>*</em></span><input class="modern-input" type="number" name="displayOrder" required min="0" max="9999" value="<c:out value='${advertisement.displayOrder}'/>"></label>
            <label class="admin-check-field"><input type="checkbox" name="active" value="true" ${advertisement.active ? 'checked' : ''}><span><strong>활성화</strong><small>기간 조건을 만족하면 사용자 홈에 노출</small></span></label>
          </div>
          <div class="admin-form-row">
            <label class="admin-form-field"><span>노출 시작일시</span><input class="modern-input" type="datetime-local" name="startAt" value="<c:out value='${advertisement.startAtInput}'/>"></label>
            <label class="admin-form-field"><span>노출 종료일시</span><input class="modern-input" type="datetime-local" name="endAt" value="<c:out value='${advertisement.endAtInput}'/>"></label>
          </div>
        </section>
        <aside class="modern-card advertisement-image-panel">
          <div class="admin-section-heading"><div><h2>배너 이미지</h2><p>이미지는 배너 영역에 맞게 자동 조정됩니다.</p></div></div>
          <div class="advertisement-image-preview ${empty advertisement.imageUrl ? 'is-empty' : ''}" id="imagePreview">
            <img id="previewImage" src="<c:if test='${not empty advertisement.imageUrl}'><c:url value='${advertisement.imageUrl}'/></c:if>" alt="배너 미리보기">
            <div class="advertisement-preview-placeholder"><i class="far fa-image"></i><span>이미지 미리보기</span></div>
          </div>
          <label class="advertisement-file-button" id="imageFileButton"><i class="fas fa-upload"></i> 이미지 선택 <c:if test="${formMode == 'create'}"><em>*</em></c:if><input id="imageFile" type="file" name="imageFile" accept=".jpg,.jpeg,.png,.webp,image/jpeg,image/png,image/webp"></label>
          <p class="advertisement-file-error" id="imageFileError" role="alert" aria-live="polite"></p>
          <p class="advertisement-file-help">jpg, jpeg, png, webp · 최대 5MB</p>
          <div class="advertisement-form-actions"><a class="btn-modern btn-outline admin-link-button" href="<c:url value='/admin/advertisements'/>">취소</a><button type="submit" class="btn-modern btn-primary">${formMode == 'create' ? '등록하기' : '수정하기'}</button></div>
        </aside>
      </form>
    </main>
  </div>
  <script>
    (function () {
      const input = document.getElementById('imageFile');
      const preview = document.getElementById('imagePreview');
      const image = document.getElementById('previewImage');
      const form = document.getElementById('advertisementForm');
      const fileButton = document.getElementById('imageFileButton');
      const fileError = document.getElementById('imageFileError');
      const imageRequired = ${formMode == 'create' ? 'true' : 'false'};
      let imageSelectionError = '';

      function showFileError(message) {
        fileError.textContent = message || '';
        fileButton.classList.toggle('has-error', Boolean(message));
      }

      input.addEventListener('change', function () {
        const file = this.files && this.files[0];
        showFileError('');
        imageSelectionError = '';
        if (!file) return;
        if (file.size > 5 * 1024 * 1024) {
          imageSelectionError = '이미지는 5MB 이하만 선택할 수 있습니다.';
          showFileError(imageSelectionError);
          this.value = '';
          return;
        }
        const objectUrl = URL.createObjectURL(file);
        const validationImage = new Image();
        validationImage.onload = function () {
          image.src = objectUrl;
          preview.classList.remove('is-empty');
        };
        validationImage.onerror = function () {
          imageSelectionError = 'jpg, jpeg, png, webp 형식의 올바른 이미지 파일만 선택해 주세요.';
          showFileError(imageSelectionError);
          input.value = '';
          URL.revokeObjectURL(objectUrl);
        };
        validationImage.src = objectUrl;
      });

      form.addEventListener('submit', function (event) {
        if (imageSelectionError) {
          event.preventDefault();
          showFileError(imageSelectionError);
          fileButton.scrollIntoView({ behavior: 'smooth', block: 'center' });
          return;
        }
        if (imageRequired && (!input.files || !input.files.length)) {
          event.preventDefault();
          showFileError('광고 등록을 위해 배너 이미지를 선택해 주세요.');
          fileButton.scrollIntoView({ behavior: 'smooth', block: 'center' });
        }
      });
    }());
  </script>
</body>
</html>
