<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="isEdit" value="${not empty post}" />
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | ${isEdit ? '글 수정' : '글쓰기'}</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="${ctx}/resources/css/common.css">
  <link rel="stylesheet" href="${ctx}/resources/css/user.css">
  <style>
    .write-card { background:var(--white); border-radius:var(--radius-lg); border:1px solid var(--border); padding:40px; max-width:800px; margin:0 auto; box-shadow:var(--shadow); }
    .write-card h2 { font-size:22px; font-weight:700; margin-bottom:28px; }
    .form-group { margin-bottom:20px; display:flex; flex-direction:column; gap:8px; }
    .form-group label { font-size:14px; font-weight:600; color:var(--text-sub); }
    .form-control { padding:12px 16px; border:1px solid var(--border); border-radius:var(--radius-md); font-size:15px; width:100%; color:var(--text-main); }
    .form-control:focus { outline:none; border-color:var(--accent); }
    textarea.form-control { resize:vertical; min-height:280px; line-height:1.7; }
    .form-actions { display:flex; gap:10px; justify-content:flex-end; margin-top:10px; }
    .image-preview { margin-top:10px; max-width:100%; max-height:200px; border-radius:var(--radius-md); border:1px solid var(--border); display:none; }
    .current-image { margin-top:8px; }
    .current-image img { max-width:100%; max-height:160px; border-radius:var(--radius-md); border:1px solid var(--border); }
    .file-input-wrap { position:relative; }
    .file-label { display:inline-flex; align-items:center; gap:8px; padding:10px 18px; border:1.5px dashed var(--border); border-radius:var(--radius-md); cursor:pointer; font-size:14px; color:var(--text-sub); background:var(--bg-sub); transition:border-color .2s; }
    .file-label:hover { border-color:var(--accent); color:var(--accent); }
    #imageFile { display:none; }
  </style>
</head>
<body>
  <aside class="sidebar">
    <div class="sidebar-brand">
      <i class="fas fa-scissors" style="color:var(--accent);"></i>
      <span>HAIR RESERVE</span>
    </div>
    <ul class="sidebar-menu">
      <li class="sidebar-item"><a href="${ctx}/"><i class="fas fa-home"></i> 홈 메인</a></li>
      <li class="sidebar-item"><a href="#"><i class="fas fa-search"></i> 헤어샵 검색/예약</a></li>
      <li class="sidebar-item"><a href="#"><i class="fas fa-comments"></i> 1:1 상담 채팅</a></li>
      <li class="sidebar-item active"><a href="${ctx}/community"><i class="fas fa-users"></i> 스타일 커뮤니티</a></li>
      <li class="sidebar-item"><a href="${ctx}/community/popular"><i class="fas fa-fire"></i> 인기글</a></li>
      <li class="sidebar-item"><a href="#"><i class="fas fa-calendar-alt"></i> 예약 내역</a></li>
      <li class="sidebar-item"><a href="#"><i class="fas fa-user"></i> 마이페이지</a></li>
    </ul>
  </aside>

  <div class="app-container">
    <main class="app-content">
      <div class="write-card">
        <h2>
          <i class="fas fa-pen" style="color:var(--accent); margin-right:10px;"></i>
          ${isEdit ? '글 수정' : '새 글 작성'}
        </h2>

        <c:choose>
          <c:when test="${isEdit}">
            <form action="${ctx}/community/${post.postId}/edit" method="post" enctype="multipart/form-data">
          </c:when>
          <c:otherwise>
            <form action="${ctx}/community/write" method="post" enctype="multipart/form-data">
          </c:otherwise>
        </c:choose>

          <div class="form-group">
            <label for="salonId">방문 미용실 <span style="font-weight:400; color:var(--text-light);">(선택)</span></label>
            <select name="salonId" id="salonId" class="form-control">
              <option value="0">-- 선택 안함 --</option>
              <c:forEach var="salon" items="${salons}">
                <option value="${salon.salonId}"
                  ${post.salonId == salon.salonId ? 'selected' : ''}>
                  <c:out value="${salon.name}" />
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
            <label>이미지 첨부 <span style="font-weight:400; color:var(--text-light);">(선택)</span></label>
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
                <p style="font-size:12px; color:var(--text-light); margin-bottom:6px;">현재 이미지</p>
                <img src="${ctx}/uploads/${post.imageUrl}" alt="현재 이미지">
              </div>
              <input type="hidden" name="imageUrl" value="${post.imageUrl}">
            </c:if>
          </div>

          <div class="form-actions">
            <a href="${ctx}/community" class="btn-modern btn-outline">취소</a>
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
