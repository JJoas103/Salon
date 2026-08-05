# 미용실 관리 시스템 - 프론트엔드 구조

## 📁 프로젝트 구조

```
frontend/
├── pages/                    # 페이지별 HTML 파일
│   ├── auth.html            # 로그인/회원가입 페이지
│   ├── home.html            # 홈 페이지 (미용실 검색 및 추천)
│   ├── search.html          # 검색 결과 페이지
│   ├── reservations.html    # 예약내역 페이지
│   ├── mypage.html          # 마이페이지
│   ├── owner-center.html    # 점주센터 (미구현)
│   └── admin.html           # 관리자 페이지 (미구현)
│
├── styles/                   # CSS 스타일 파일
│   ├── common.css           # 공통 스타일 (레이아웃, 버튼, 입력 필드 등)
│   ├── auth.css             # 로그인/회원가입 페이지 전용 스타일
│   ├── home.css             # 홈 페이지 전용 스타일
│   ├── search.css           # 검색 페이지 전용 스타일
│   ├── reservations.css     # 예약내역 페이지 전용 스타일
│   └── mypage.css           # 마이페이지 전용 스타일
│
└── README.md                # 이 파일
```

## 🎨 디자인 시스템

### 색상 팔레트

| 용도 | 색상 코드 | 사용처 |
|------|---------|-------|
| 배경색 | `#f5f5f5` | 페이지 배경, 사이드바 |
| 텍스트 (주) | `#333` | 제목, 본문 텍스트 |
| 텍스트 (보조) | `#666` | 라벨, 메뉴 아이템 |
| 텍스트 (약한) | `#999` | 부제목, 설명 텍스트 |
| 테두리 | `#d0d0d0` | 입력 필드, 카드 테두리 |
| 버튼 (주) | `#333` | 기본 버튼 배경 |
| 버튼 (보조) | `rgba(46,44,42,0.06)` | 보조 버튼 배경 |

### 타이포그래피

- **폰트 패밀리**: `-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif`
- **기본 크기**: 14px
- **제목 크기**: 16px ~ 28px
- **라인 높이**: 1.5

### 간격 (Spacing)

- **기본 간격**: 8px, 12px, 16px, 24px, 32px
- **패딩**: 12px (입력 필드), 16px (카드), 24px (콘텐츠 영역)
- **마진**: 8px ~ 32px

### 버튼 스타일

#### 기본 버튼 (Primary)
- 배경: `#333` (검은색)
- 텍스트: `#fff` (흰색)
- 테두리: `1px solid #333`
- 패딩: `9px 18px`
- 호버: 배경 `#1a1a1a`

#### 보조 버튼 (Secondary)
- 배경: `rgba(46,44,42,0.06)` (연한 회색)
- 텍스트: `#333` (검은색)
- 테두리: `1px solid rgba(46,44,42,0.25)`
- 패딩: `9px 18px`
- 호버: 배경 `rgba(46,44,42,0.12)`

## 📄 페이지별 설명

### 1. 로그인/회원가입 페이지 (auth.html)

**파일**: `pages/auth.html`, `styles/auth.css`

사용자가 시스템에 처음 접근할 때 보는 페이지입니다.

**주요 구성요소**:
- 이메일 로그인 폼
- 소셜 로그인 (카카오, 네이버, 구글)
- 회원가입 링크

**CSS 클래스**:
- `.auth-container`: 전체 컨테이너
- `.auth-header`: 제목 섹션
- `.auth-form-section`: 이메일 로그인 폼
- `.social-login`: 소셜 로그인 섹션

### 2. 홈 페이지 (home.html)

**파일**: `pages/home.html`, `styles/home.css`

로그인 후 사용자가 처음 보는 페이지로, 미용실 검색 및 추천 기능을 제공합니다.

**주요 구성요소**:
- 검색 박스 (미용실 이름, 지역 검색)
- 필터 (지역, 시술 종류, 가격대, 평점)
- 추천 미용실 카드 그리드
- 지도/목록 보기 전환 버튼

**CSS 클래스**:
- `.search-section`: 검색 섹션
- `.filter-section`: 필터 섹션
- `.salon-grid`: 미용실 카드 그리드
- `.salon-card`: 개별 미용실 카드

### 3. 검색 결과 페이지 (search.html)

**파일**: `pages/search.html`, `styles/search.css`

사용자가 입력한 검색어에 대한 결과를 표시하는 페이지입니다.

**주요 구성요소**:
- 검색 결과 목록 (리스트 형식)
- 미용실 정보 (이름, 위치, 평점, 서비스, 가격)
- 예약하기 버튼

**CSS 클래스**:
- `.search-results`: 검색 결과 컨테이너
- `.result-item`: 개별 검색 결과 항목
- `.result-content`: 결과 상세 정보

### 4. 예약내역 페이지 (reservations.html)

**파일**: `pages/reservations.html`, `styles/reservations.css`

사용자의 예약 현황을 관리하는 페이지입니다.

**주요 구성요소**:
- 예약 상태 탭 (전체, 예정, 완료, 취소)
- 예약 항목 목록
- 예약 상세 정보 (날짜, 서비스, 스타일리스트, 가격)
- 예약 변경/취소, 리뷰 작성 버튼

**CSS 클래스**:
- `.reservation-tabs`: 상태 탭
- `.reservation-item`: 개별 예약 항목
- `.reservation-status`: 상태 배지
- `.detail-row`: 상세 정보 행

### 5. 마이페이지 (mypage.html)

**파일**: `pages/mypage.html`, `styles/mypage.css`

사용자의 프로필 및 계정 설정을 관리하는 페이지입니다.

**주요 구성요소**:
- 프로필 정보 (이름, 이메일, 전화번호)
- 찜한 미용실 목록
- 계정 설정 메뉴 (비밀번호 변경, 알림 설정, 로그아웃)

**CSS 클래스**:
- `.profile-section`: 프로필 섹션
- `.wishlist-section`: 찜한 미용실 섹션
- `.account-section`: 계정 설정 섹션

## 🔧 공통 CSS (common.css)

모든 페이지에서 사용되는 공통 스타일을 정의합니다.

### 주요 클래스

| 클래스 | 용도 |
|-------|------|
| `.app-container` | 전체 앱 레이아웃 컨테이너 |
| `.sidebar` | 좌측 사이드바 |
| `.main-content` | 메인 콘텐츠 영역 |
| `.header` | 헤더 |
| `.content-area` | 콘텐츠 영역 |
| `.btn` | 기본 버튼 |
| `.btn-primary` | 기본 버튼 스타일 |
| `.btn-secondary` | 보조 버튼 스타일 |
| `.card` | 카드 컴포넌트 |
| `.grid` | 그리드 레이아웃 |
| `.form-group` | 폼 그룹 |
| `.text-label` | 텍스트 라벨 |
| `.text-subtitle` | 부제목 텍스트 |

## 📱 반응형 디자인

모든 페이지는 다음 브레이크포인트에서 반응형으로 작동합니다:

- **데스크톱**: 1440px 이상
- **태블릿**: 768px ~ 1439px
- **모바일**: 767px 이하

### 주요 변경사항 (모바일)

- 사이드바: 수평 메뉴로 변경
- 그리드: 단일 열로 변경
- 버튼: 전체 너비 적용
- 폰트 크기: 축소
- 패딩/마진: 축소

## 🚀 사용 방법

### 1. HTML 파일 연결

각 HTML 파일의 `<head>` 섹션에서 CSS 파일을 연결합니다:

```html
<link rel="stylesheet" href="../styles/common.css">
<link rel="stylesheet" href="../styles/[page-name].css">
```

### 2. 페이지 네비게이션

사이드바 메뉴 항목을 통해 페이지 간 이동:

```html
<a href="home.html" class="menu-item">홈</a>
<a href="search.html" class="menu-item">검색</a>
```

### 3. 커스터마이징

페이지별 CSS 파일에서 스타일을 수정하거나 새로운 클래스를 추가할 수 있습니다.

## 📝 주의사항

1. **CSS 파일 순서**: `common.css`를 먼저 로드한 후 페이지별 CSS를 로드해야 합니다.
2. **상대 경로**: 모든 파일은 현재 구조를 기준으로 상대 경로를 사용합니다.
3. **폰트**: 시스템 폰트를 사용하므로 별도의 폰트 파일이 필요하지 않습니다.

## 🔮 향후 개선 사항

- [ ] 점주센터 페이지 구현
- [ ] 관리자 페이지 구현
- [ ] 다크 모드 지원
- [ ] 애니메이션 효과 추가
- [ ] JavaScript 인터랙션 구현
- [ ] 접근성(Accessibility) 개선

---

**작성자**: Manus AI
**작성일**: 2026년 6월 30일
