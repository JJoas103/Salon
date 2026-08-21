<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | 스타일 미리보기</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="/resources/css/common.css"><link rel="stylesheet" href="/resources/css/user.css">
  <style>
    .preview-workspace { display: grid; grid-template-columns: minmax(280px, 360px) minmax(0, 1fr); gap: 20px; }
    .preview-panel { padding: 22px; border: 1px solid var(--border); border-radius: var(--radius-lg);
                     background: var(--white); box-shadow: var(--shadow); }
    .preview-panel form { display: grid; gap: 16px; }
    .preview-panel label { display: grid; gap: 7px; font-size: 14px; font-weight: 700; color: var(--text-main); }
    .preview-panel textarea, .preview-panel input[type="file"] {
      width: 100%; border: 1px solid var(--border); border-radius: var(--radius-md);
      background: var(--white); color: var(--text-main); font: inherit; }
    .preview-panel textarea { min-height: 150px; padding: 12px 14px; resize: vertical; line-height: 1.6; }
    .preview-panel input[type="file"] { padding: 10px; }
    .preview-panel textarea:focus, .preview-panel input:focus { outline: 2px solid var(--accent); border-color: var(--accent); }
    .preview-help { margin: -8px 0 0; color: var(--text-sub); font-size: 12px; line-height: 1.6; }
    .preview-status { min-height: 24px; margin: 16px 0 0; color: var(--text-sub); font-size: 13px; line-height: 1.6; }
    .preview-status.error { color: var(--danger); }
    .preview-status.success { color: var(--success); }
    .preview-results { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 16px; }
    .preview-results figure { margin: 0; }
    .preview-results figcaption { margin-bottom: 9px; font-size: 14px; font-weight: 700; color: var(--text-main); }
    .preview-box { display: grid; min-height: 420px; place-items: center; overflow: hidden;
                   border: 1px dashed var(--border); border-radius: var(--radius-md);
                   background: var(--bg-sub); color: var(--text-light); text-align: center; padding: 12px; }
    .preview-box img { display: block; width: 100%; height: 100%; max-height: 560px; object-fit: contain; }
    .preview-download { display: none; margin-top: 14px; padding: 10px 14px; border: 1px solid var(--border);
                        border-radius: var(--radius-md); color: var(--accent); font-size: 14px;
                        font-weight: 700; text-align: center; text-decoration: none; }
    .preview-download.is-visible { display: block; }
    @media (max-width: 900px) {
      .preview-workspace, .preview-results { grid-template-columns: 1fr; }
      .preview-box { min-height: 320px; }
    }
  </style>
</head>
<body>
  <jsp:include page="../includes/sidebar_common.jsp"><jsp:param name="menu" value="stylePreview"/></jsp:include>
  <div class="app-container"><main class="app-content">

    <div class="my-review-header">
      <div>
        <h1><i class="fas fa-wand-magic-sparkles"></i> 스타일 미리보기</h1>
        <p>사진과 바꾸고 싶은 내용을 보내면 AI 가 새 스타일을 그려줍니다.</p>
      </div>
    </div>

    <div class="preview-workspace">
      <section class="preview-panel" aria-label="이미지 생성 입력">
        <form id="imageForm">
          <label>
            내 사진
            <input id="imageFile" name="image" type="file" accept="image/png,image/jpeg" required>
          </label>
          <p class="preview-help">PNG, JPG, JPEG · 최대 5MB</p>

          <label>
            바꾸고 싶은 내용
            <textarea id="prompt" name="prompt" maxlength="1000"
                      placeholder="예: 얼굴과 배경은 그대로 두고 머리만 단발 레이어드컷으로 바꿔 줘"
                      required></textarea>
          </label>
          <p class="preview-help">유지할 부분과 바꿀 부분을 나눠서 적으면 결과가 안정적입니다.</p>

          <button id="generateButton" class="btn btn-primary" type="submit">미리보기 만들기</button>
        </form>
        <p id="status" class="preview-status" aria-live="polite">사진과 문구를 입력해 주세요.</p>
      </section>

      <section class="preview-panel preview-results" aria-label="이미지 생성 결과">
        <figure>
          <figcaption>내 사진</figcaption>
          <div id="referenceBox" class="preview-box">사진을 선택하면 미리보기가 표시됩니다.</div>
        </figure>
        <figure>
          <figcaption>생성 결과</figcaption>
          <div id="generatedBox" class="preview-box">생성 결과가 여기에 표시됩니다.</div>
          <a id="downloadLink" class="preview-download" download="style-preview.png">결과 이미지 저장</a>
        </figure>
      </section>
    </div>

  </main></div>

<script>
  var apiUrl = '<c:url value="/api/image"/>';
  var form = document.getElementById('imageForm');
  var imageFile = document.getElementById('imageFile');
  var promptInput = document.getElementById('prompt');
  var generateButton = document.getElementById('generateButton');
  var status = document.getElementById('status');
  var referenceBox = document.getElementById('referenceBox');
  var generatedBox = document.getElementById('generatedBox');
  var downloadLink = document.getElementById('downloadLink');
  var referenceUrl = null;

  imageFile.addEventListener('change', function () {
    if (referenceUrl) { URL.revokeObjectURL(referenceUrl); referenceUrl = null; }

    var file = imageFile.files[0];
    if (!file) {
      referenceBox.textContent = '사진을 선택하면 미리보기가 표시됩니다.';
      return;
    }
    referenceUrl = URL.createObjectURL(file);
    var preview = document.createElement('img');
    preview.src = referenceUrl;
    preview.alt = '선택한 사진';
    referenceBox.replaceChildren(preview);
  });

  form.addEventListener('submit', function (event) {
    event.preventDefault();

    var file = imageFile.files[0];
    var cleanPrompt = promptInput.value.trim();
    if (!file || !cleanPrompt || generateButton.disabled) return;

    var body = new FormData();
    body.append('prompt', cleanPrompt);
    body.append('image', file);

    generateButton.disabled = true;
    generateButton.textContent = '만드는 중';
    status.className = 'preview-status';
    status.textContent = '이미지를 만들고 있습니다. 몇 분 걸릴 수 있습니다.';
    generatedBox.textContent = '응답을 기다리는 중입니다.';
    downloadLink.classList.remove('is-visible');

    fetch(apiUrl, { method: 'POST', body: body })
      .then(function (res) {
        return res.json().then(function (data) { return { ok: res.ok, data: data }; });
      })
      .then(function (result) {
        if (!result.ok) {
          throw new Error(result.data.message || result.data.detail || '이미지 생성에 실패했습니다.');
        }
        var imageUrl = 'data:' + result.data.mediaType + ';base64,' + result.data.imageBase64;
        var generated = document.createElement('img');
        generated.src = imageUrl;
        generated.alt = '생성된 이미지';
        generatedBox.replaceChildren(generated);

        downloadLink.href = imageUrl;
        downloadLink.classList.add('is-visible');
        status.className = 'preview-status success';
        status.textContent = '완료되었습니다.';
      })
      .catch(function (error) {
        generatedBox.textContent = '결과를 표시할 수 없습니다.';
        status.className = 'preview-status error';
        status.textContent = '오류: ' + error.message;
      })
      .finally(function () {
        generateButton.disabled = false;
        generateButton.textContent = '미리보기 만들기';
      });
  });
</script>
</body>
</html>
