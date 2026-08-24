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
    .preview-panel textarea { min-height: 84px; padding: 12px 14px; resize: vertical; line-height: 1.6; }
    .preview-panel input[type="file"] { padding: 10px; }
    .preview-panel textarea:focus, .preview-panel input:focus { outline: 2px solid var(--accent); border-color: var(--accent); }
    .preview-help { margin: -8px 0 0; color: var(--text-sub); font-size: 12px; line-height: 1.6; }
    .preview-field { display: grid; gap: 11px; }
    .preview-field-title { font-size: 14px; font-weight: 700; color: var(--text-main); }
    .preview-group { display: grid; grid-template-columns: 28px minmax(0, 1fr); gap: 8px; align-items: start; }
    .preview-group-label { padding-top: 8px; color: var(--text-light); font-size: 12px; font-weight: 700; }
    .preview-chips { display: flex; flex-wrap: wrap; gap: 7px; }
    .preview-chip { padding: 7px 12px; border: 1px solid var(--border); border-radius: 999px;
                    background: var(--white); color: var(--text-sub); font: inherit; font-size: 13px;
                    cursor: pointer; }
    .preview-chip:hover { border-color: var(--accent); color: var(--accent); }
    .preview-chip.is-active { border-color: var(--accent); background: var(--accent); color: var(--white); }
    .preview-echo { margin: 0; padding: 9px 12px; border-radius: var(--radius-md); background: var(--bg-sub);
                    color: var(--text-sub); font-size: 12px; line-height: 1.6; word-break: keep-all; }
    .preview-echo b { color: var(--text-main); }
    .preview-link { justify-self: start; padding: 0; border: 0; background: none; color: var(--accent);
                    font: inherit; font-size: 13px; text-decoration: underline; cursor: pointer; }
    .preview-panel textarea[hidden] { display: none; }
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

          <div class="preview-field">
            <span class="preview-field-title">바꾸고 싶은 스타일</span>

            <div class="preview-group">
              <span class="preview-group-label">컷</span>
              <div class="preview-chips">
                <button type="button" class="preview-chip">레이어드컷</button>
                <button type="button" class="preview-chip">허쉬컷</button>
                <button type="button" class="preview-chip">샤기컷</button>
                <button type="button" class="preview-chip">히메컷</button>
                <button type="button" class="preview-chip">단발</button>
                <button type="button" class="preview-chip">숏컷</button>
                <button type="button" class="preview-chip">투블럭컷</button>
                <button type="button" class="preview-chip">스포츠컷</button>
              </div>
            </div>

            <div class="preview-group">
              <span class="preview-group-label">펌</span>
              <div class="preview-chips">
                <button type="button" class="preview-chip">히피펌</button>
                <button type="button" class="preview-chip">셋팅펌</button>
                <button type="button" class="preview-chip">디지털펌</button>
                <button type="button" class="preview-chip">보브펌</button>
                <button type="button" class="preview-chip">가르마펌</button>
                <button type="button" class="preview-chip">앞머리펌</button>
                <button type="button" class="preview-chip">볼륨매직</button>
              </div>
            </div>

            <div class="preview-group">
              <span class="preview-group-label">색</span>
              <div class="preview-chips">
                <button type="button" class="preview-chip">애쉬브라운</button>
                <button type="button" class="preview-chip">애쉬그레이</button>
                <button type="button" class="preview-chip">밀크브라운</button>
                <button type="button" class="preview-chip">블론드</button>
                <button type="button" class="preview-chip">핑크</button>
                <button type="button" class="preview-chip">레드</button>
                <button type="button" class="preview-chip">발레아쥬</button>
                <button type="button" class="preview-chip">투톤</button>
                <button type="button" class="preview-chip">새치커버</button>
              </div>
            </div>

            <p id="promptEcho" class="preview-echo">고르면 여기에 보낼 내용이 표시됩니다.</p>
            <button id="freeToggle" type="button" class="preview-link">직접 입력</button>
            <textarea id="prompt" maxlength="1000" hidden aria-label="직접 입력"
                      placeholder="위에 없는 시술명만 짧게 — 모르는 말은 반영되지 않습니다"></textarea>
          </div>
          <p class="preview-help">고른 것을 합쳐 보냅니다. 얼굴·옷·배경은 그대로 두고 머리만 바꿉니다.</p>

          <button id="generateButton" class="btn btn-primary" type="submit">미리보기 만들기</button>
        </form>
        <p id="status" class="preview-status" aria-live="polite">사진을 올리고 스타일을 골라 주세요.</p>
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

  // 칩 이름은 ai-service 사전의 표제어와 글자까지 같아야 함 — 어긋나면 한글이 그대로 나가 무시됨
  var chipGroups = form.querySelectorAll('.preview-chips');
  var promptEcho = document.getElementById('promptEcho');
  var freeToggle = document.getElementById('freeToggle');

  function composePrompt() {
    var picked = [];
    Array.prototype.forEach.call(chipGroups, function (group) {
      var active = group.querySelector('.preview-chip.is-active');
      if (active) picked.push(active.textContent);
    });
    // 사전이 한 문장에서 여러 개를 잡아내므로 이어 붙이기만 하면 됨
    var free = promptInput.hidden ? '' : promptInput.value.trim();
    if (free) picked.push(free);
    return picked.join(' ');
  }

  function refreshEcho() {
    var composed = composePrompt();
    if (composed) {
      promptEcho.textContent = '보낼 내용: ';
      var strong = document.createElement('b');
      strong.textContent = composed;
      promptEcho.appendChild(strong);
    } else {
      promptEcho.textContent = '고르면 여기에 보낼 내용이 표시됩니다.';
    }
  }

  Array.prototype.forEach.call(chipGroups, function (group) {
    group.addEventListener('click', function (event) {
      var chip = event.target.closest('.preview-chip');
      if (!chip) return;

      // 한 줄에서 하나만 고름 — 고른 것을 다시 누르면 해제됨
      var wasActive = chip.classList.contains('is-active');
      Array.prototype.forEach.call(group.querySelectorAll('.preview-chip'), function (other) {
        other.classList.remove('is-active');
      });
      if (!wasActive) chip.classList.add('is-active');
      refreshEcho();
    });
  });

  freeToggle.addEventListener('click', function () {
    promptInput.hidden = !promptInput.hidden;
    freeToggle.textContent = promptInput.hidden ? '직접 입력' : '직접 입력 닫기';
    if (!promptInput.hidden) promptInput.focus();
    refreshEcho();
  });

  promptInput.addEventListener('input', refreshEcho);
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
    if (!file || generateButton.disabled) return;

    var cleanPrompt = composePrompt();
    if (!cleanPrompt) {
      status.className = 'preview-status error';
      status.textContent = '바꾸고 싶은 스타일을 하나 이상 골라 주세요.';
      return;
    }

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
