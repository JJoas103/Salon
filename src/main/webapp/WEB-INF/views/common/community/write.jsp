<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<%-- 검증 실패 시 새 글 작성 폼에도 post(입력값)가 되돌아오므로 postId로 수정/작성을 구분한다 --%>
<c:set var="isEdit" value="${not empty post and post.postId > 0}" />
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | ${isEdit ? '글 수정' : '글쓰기'}</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="/resources/css/common.css">
  <link rel="stylesheet" href="/resources/css/user.css">
  <link rel="stylesheet" href="/resources/css/auth.css">
</head>
<body>
  <!-- 사이드바 -->
  <jsp:include page="../../includes/sidebar_common.jsp">
    <jsp:param name="menu" value="community" />
  </jsp:include>

  <div class="app-container">
    <main class="app-content">
      <div class="write-card">
        <h2>
          <i class="fas fa-pen icon-accent"></i>
          ${isEdit ? '글 수정' : '새 글 작성'}
        </h2>

        <c:if test="${not empty errorMessage}">
          <p class="error-text"><c:out value="${errorMessage}" /></p>
        </c:if>

        <c:choose>
          <c:when test="${isEdit}">
            <form action="${ctx}/common/community/${post.postId}/edit" method="post" enctype="multipart/form-data">
          </c:when>
          <c:otherwise>
            <form action="${ctx}/common/community/write" method="post" enctype="multipart/form-data">
          </c:otherwise>
        </c:choose>

          <div class="form-group">
            <label for="salonId">방문 미용실 <span class="label-optional">(선택)</span></label>
            <select name="salonId" id="salonId" class="form-control">
              <option value="0">-- 선택 안함 --</option>
              <c:forEach var="salon" items="${salons}">
                <option value="${salon.salonId}"
                  ${post.salonId == salon.salonId ? 'selected' : ''}>
                  <c:out value="${salon.salonName} "/>
                </option>
              </c:forEach>
            </select>
          </div>

          <div class="form-group">
            <label for="category">카테고리</label>
            <select name="category" id="category" class="form-control">
              <option value="">-- 선택 --</option>
              <option value="헤어스타일" ${post.category == '헤어스타일' ? 'selected' : ''}>헤어스타일</option>
              <option value="시술후기"   ${post.category == '시술후기'   ? 'selected' : ''}>시술후기</option>
              <option value="추천/질문"  ${post.category == '추천/질문'  ? 'selected' : ''}>추천/질문</option>
              <option value="자유"       ${post.category == '자유'       ? 'selected' : ''}>자유</option>
            </select>
          </div>

          <div class="form-group">
            <label for="title">제목</label>
            <input type="text" name="title" id="title" class="form-control"
                   placeholder="제목을 입력하세요" required
                   value="<c:out value='${post.title}' />">
          </div>

          <div class="form-group">
            <label for="content">내용</label>
            <textarea name="content" id="content" class="form-control"
                      placeholder="내용을 입력하세요" required><c:out value="${post.content}" /></textarea>
          </div>

          <div class="form-group">
            <label>이미지 첨부 <span class="label-optional">(선택)</span></label>
            <div class="file-input-wrap">
              <label for="imageFile" class="file-label">
                <i class="fas fa-image"></i> 이미지 선택
              </label>
              <input type="file" name="imageFile" id="imageFile"
                     accept="image/*" onchange="previewImage(this)">
            </div>
            <img id="imgPreview" class="image-preview" alt="미리보기">

            <%-- 수정 시: 기존 이미지 표시 + hidden으로 값 유지 --%>
            <c:if test="${isEdit and not empty post.imageUrl}">
              <div class="current-image">
                <p>현재 이미지</p>
                <img src="${ctx}/upload/${post.imageUrl}" alt="현재 이미지">
              </div>
              <input type="hidden" name="imageUrl" value="${post.imageUrl}">
            </c:if>
          </div>

          <div class="form-actions">
            <a href="${ctx}/common/community" class="btn-modern btn-outline">취소</a>
            <button type="submit" class="btn-modern btn-accent">
              ${isEdit ? '수정 완료' : '작성 완료'}
            </button>
          </div>
        </form>
      </div>
    </main>
  </div>

  <script>
    function previewImage(input) {
      var preview = document.getElementById('imgPreview');
      if (input.files && input.files[0]) {
        var reader = new FileReader();
        reader.onload = function(e) {
          preview.src = e.target.result;
          preview.style.display = 'block';
        };
        reader.readAsDataURL(input.files[0]);
      } else {
        preview.style.display = 'none';
      }
    }
  </script>
</body>
</html>
