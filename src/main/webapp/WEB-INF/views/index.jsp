<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HAIR RESERVE | 통합 로그인 센터</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <style>
    :root {
      --primary: #2D3436; --accent: #0984E3; --bg-sub: #F8F9FA; --text-main: #2D3436;
      --text-sub: #636E72; --border: #DFE6E9; --white: #FFFFFF;
      --shadow-lg: 0 10px 30px rgba(0, 0, 0, 0.06); --radius-sm: 8px; --radius-md: 12px; --radius-lg: 20px; --radius-full: 9999px;
    }
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: 'Pretendard', -apple-system, sans-serif; background-color: var(--bg-sub); color: var(--text-main); display: flex; align-items: center; justify-content: center; min-height: 100vh; }
    
    .index-fullscreen { position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; background: linear-gradient(rgba(17,17,17,0.7), rgba(17,17,17,0.8)), url('https://images.unsplash.com/photo-1521590832167-7bcbfaa6381f?auto=format&fit=crop&w=1920&q=80') center/cover no-repeat; display: flex; align-items: center; justify-content: center; text-align: center; color: var(--white); z-index: 10; }
    .index-content { max-width: 800px; padding: 0 20px; }
    .index-logo { font-size: 40px; font-weight: 900; margin-bottom: 20px; display: inline-flex; align-items: center; gap: 15px; }
    .index-title { font-size: 46px; font-weight: 800; line-height: 1.3; margin-bottom: 24px; }
    
    .btn-modern { padding: 16px 24px; border-radius: var(--radius-md); font-weight: 700; font-size: 15px; cursor: pointer; transition: all 0.2s ease; border: none; }
    .btn-primary { background-color: var(--accent); color: var(--white); }
    .btn-primary:hover { opacity: 0.9; transform: translateY(-2px); }
  </style>
</head>
<body>

  <div id="page-index" class="index-fullscreen">
    <div class="index-content">
      <div class="index-logo"><i class="fas fa-scissors"></i> HAIR RESERVE</div>
      <h1 class="index-title">나만을 위한 완벽한 헤어스타일,<br>스마트 뷰티 에코시스템</h1>
      <div style="margin-top: 40px;">
        <button class="btn-modern btn-primary" style="padding: 18px 40px; font-size: 18px; border-radius: var(--radius-full);" onclick="location.href='/user/login'">통합 플랫폼 로그인</button>
      </div>
    </div>
  </div>

</body>
</html>