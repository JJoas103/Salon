# 발표 피드백 반영 TODO

작성 2026-08-18. 발표 피드백으로 받은 항목을 **현재 코드와 대조해 정리한 문서**다.
아직 구현되지 않은 작업 목록이며, 결정이 필요한 항목은 `[결정 필요]` 로 표시했다.

피드백은 두 종류다.

- **말로 답할 것 (1~7, qna)** — 발표 Q&A 대비. 팀에서 직접 준비. 이 문서 §5에 근거 위치만 적어둔다.
- **코드로 고칠 것 (8 이하)** — 아래 §1~§4. 이 문서의 본론.

---

## 0. 한눈에 보기

| # | 항목 | 현재 상태 | 비용 | 우선순위 |
|---|---|---|---|---|
| A1 | 디자이너 연락처 숫자 한정·필수 | 미구현 | 하 | **1** |
| A2 | 매장 추가요청 연락처 숫자 한정·필수 | 미구현 | 하 | **1** |
| A3 | 세션 만료 표시 | 미구현 | 하 | **1** |
| A4 | 쿠폰코드 입력 기능 | 스키마·VO 완비, 화면/조회쿼리만 없음 | 하 | **1** |
| B1 | 마이페이지 내 정보 변경 (이름·전화·이메일) | 비밀번호 변경만 있음 | 중 | **2** |
| B2 | 사용자/점주·관리자 정보변경 UI 통일 | 점주·관리자만 모달 보유 | 중 | **2** |
| C1 | 카카오맵 주소 입력 → 위경도 저장 | 컬럼·SDK 모두 있음, 점주 입력 UI만 없음 | 중 | **2** |
| C2 | 운영시간 등록 UI | 테이블·VO·Mapper 있음, 화면 없음 | 중 | **2** |
| C3 | 이벤트/공지 → 매장정보 관리에 병합 | 별도 페이지로 분리돼 있음 | 중 | **3** |
| C4 | 매장 2단계 승인 | 미구현 (컬럼부터 없음) | 상 | **3** |
| D1 | 구글·네이버 OAuth | 미구현 | 상 | **4** |
| D2 | OAuth 파생 제약 3건 | D1 선행 | 중 | **4** |

---

## 1. 즉시 처리 (A) — 발표 전 확실히 끝나는 것

### A1. 디자이너 등록 연락처 검증

**대상**: `src/main/webapp/WEB-INF/views/owner/staff.jsp` 107행(등록), 128행(수정)

지금은 `type="text"` 에 `required` 도 없고 자리표시자만 `010-1234-5678` 이다.

바꿀 것:
- `required` 추가 (반드시 입력)
- 숫자만 허용 — `inputmode="numeric"` + `pattern` + JS 입력 필터
- 서버측도 함께 막을 것. 클라이언트 검증만으로는 우회된다.

`[결정 필요]` 하이픈 허용 여부. **권장: 입력은 숫자만 받고 저장 시 하이픈 자동 삽입.**
(`Stylists.phone_number` 는 `VARCHAR(20)` 이라 어느 쪽이든 들어간다.)

`[결정 필요]` 서버측 검증 위치. **권장: `validation/` 에 `StylistValidator` 신규 추가**,
`UserValidator` 와 동일하게 `@InitBinder("<modelAttributeName>")` 게이트 패턴을 따른다
(CLAUDE.md "Validation" 규칙).

### A2. 매장 추가요청 연락처 검증

**대상**: `src/main/webapp/WEB-INF/views/owner/salon-request.jsp` 44행

A1 과 동일 처리. 단 매장 연락처는 `02-1234-5678` 같은 지역번호 형태도 들어오므로
휴대폰 정규식(`010` 시작)으로 좁히지 말 것.

A1·A2 는 같은 규칙이므로 **JS 입력 필터를 공용 스크립트 한 곳에 두고 두 화면에서 재사용**한다.
페이지마다 따로 붙이면 CLAUDE.md 가 경고하는 "페이지별로 제각각" 패턴이 된다.

### A3. 세션 만료 표시

**대상**: `src/main/java/com/soldesk/config/SecurityConfig.java`

지금 `sessionManagement` 설정 자체가 없다. 세션이 끊기면 아무 안내 없이 로그인 화면으로 튄다.

바꿀 것: `sessionManagement` 에 `invalidSessionUrl("/user/login?expired=true")` 를 걸고,
`user/login.jsp` 에서 `param.expired` 가 `true` 일 때 안내 문구를 띄운다.

주의: AJAX 요청(`common/chat.jsp`, checkout quote 등)이 만료되면 HTML 로그인 페이지가
JSON 자리에 돌아온다. `security/AjaxAwareAuthenticationFailureHandler` 가 이미 있으니
같은 방식으로 AJAX 만료도 401 + JSON 으로 응답하도록 맞춘다.

### A4. 쿠폰코드 입력 기능

**대상**: `src/main/webapp/WEB-INF/views/common/coupons.jsp` (지금은 보유 쿠폰 조회 전용)

**이건 생각보다 싸다.** 인프라가 이미 다 있다.

- `Coupons.coupon_code VARCHAR(50) UNIQUE` — `sql/migration_coupon.sql:8`
  (주석에 "NULL = 코드 입력형이 아님" 이라고 이미 설계돼 있음)
- `Coupons.issue_type` 에 `signup / admin / code` — `sql/migration_coupon.sql:17`
- `CouponVO.couponCode`, `CouponVO.issueType`, `CouponVO.oncePerUser` 필드 존재
- `CouponMapper.issueCoupon(userId, couponId)` — 발급
- `CouponMapper.countOwnedByUser(userId, couponId)` — 중복 발급 차단용

없는 것은 **딱 세 개**:
1. `CouponMapper.findByCouponCode(String code)` + XML 쿼리
2. `CouponService.redeemByCode(userId, code)` — 유효성 검사 후 `issueCoupon` 호출
3. `coupons.jsp` 상단 코드 입력 폼 + `CommonController` 의 POST 핸들러

검사 순서 (실패 사유별로 다른 메시지를 줄 것):

```
코드 존재? → is_active? → valid_from ~ valid_until 기간 내?
  → once_per_user 인데 이미 보유? → 발급
```

---

## 2. 사용자 정보 변경 (B)

### B1 + B2 를 한 작업으로 묶는다

피드백이 두 줄로 나뉘어 있지만 실제로는 같은 작업이다.

**현재 상태**:
- `includes/profile_modal.jsp` — 점주·관리자용. 이름·이메일·연락처·가입일을 **읽기 전용으로 표시만** 하고,
  실제 수정 가능한 건 비밀번호뿐이다.
- `includes/password_modal.jsp` — 비밀번호 변경 전용. `common/mypage.jsp` 가 이걸 include 한다.
- 즉 **어느 역할도 이름·전화번호를 바꿀 수 없다.** 사용자만 없는 게 아니라 전부 없다.

**목표**: 이름·전화번호를 수정 가능하게 만들고, 세 역할이 **같은 모달 하나**를 공유한다.

`[결정 필요]` 통일 방향. **권장: `profile_modal.jsp` 를 "정보 수정 + 비밀번호 변경" 겸용으로 확장하고,
`common/mypage.jsp` 도 `password_modal.jsp` 대신 이걸 include** 한다.
(사용자용을 새로 만들면 모달이 3개가 되어 피드백의 "통일" 요구와 반대로 간다.)

**이메일은 수정 불가로 둔다** — `Users.email` 이 로그인 ID(`UNIQUE NOT NULL`)이고
`SecurityConfig` 의 `userEmail` 파라미터와 `UserDetailService` 조회 키다.
화면에서는 비활성 필드로 보여주고 "변경은 관리자 요청" 안내를 붙인다 (§5 qna 1번 답변과 연결).

필드별 검증:

| 필드 | 규칙 |
|---|---|
| 이름 | 필수, 1~100자 (`user_name VARCHAR(100)`) |
| 전화번호 | 필수, 숫자만 — **A1 과 같은 규칙·같은 스크립트 재사용** |
| 이메일 | `readonly` + 안내 문구 |

서버측은 `validation/UserValidator` 가 이미 `updateMember` 모델명에 게이트를 걸어두었으므로
그 분기를 재사용한다.

---

## 3. 매장 등록 플로우 (C)

### C1. 주소 입력을 카카오맵 API 로

**대상**: `src/main/webapp/WEB-INF/views/owner/store.jsp` 44행 (지금은 그냥 텍스트 입력)

**인프라가 이미 있다**:
- `Salons.latitude DECIMAL(10,7)` / `longitude DECIMAL(10,7)` 컬럼 — `sql/schema.sql`
  (주석: "NULL 이면 지도에 표시하지 않는다")
- `SalonVO.latitude` / `SalonVO.longitude` 필드
- 카카오 SDK 를 이미 `libraries=services` 로 로드 중 — `common/salonmap.jsp:181`
  → **geocoder(주소→좌표) 를 추가 설정 없이 쓸 수 있다.**
- 사용자 지도 렌더링도 완성돼 있음 — `salonmap.jsp:715` 부근 `LatLngBounds` / 마커 / `CustomOverlay`
- `sql/salon_coordinates.sql` 로 기존 매장 좌표는 이미 채워져 있음

없는 것: **점주가 주소를 입력할 때 좌표를 같이 받아 저장하는 경로.**

작업:
1. `store.jsp` 주소 필드를 `readonly` 로 바꾸고 [주소 검색] 버튼 추가
2. Daum 우편번호 서비스로 주소 선택 → 카카오 `services.Geocoder.addressSearch()` 로 좌표 변환
3. `latitude` / `longitude` 를 hidden input 으로 같이 전송
4. `/owner/store/update` 핸들러와 `SalonMapper` 의 update 쿼리에 두 컬럼 추가
5. 미리보기 지도를 모달 안에 띄워 마커 위치를 점주가 확인하게 한다 (피드백의 "마커에 띄울 수 있게")

주의: Daum 우편번호 스크립트는 **새로 들어오는 외부 리소스**다. CLAUDE.md 의
"CDN vs 로컬 로딩 일관성" 규칙에 따라 기존 카카오 SDK 와 같은 방식(HTTPS CDN, 페이지 하단 로드)으로 맞춘다.

`[결정 필요]` API 키 노출. `salonmap.jsp` 는 `kakaoMapApiKey` 를 모델에서 받아 쓴다.
`store.jsp` 도 같은 모델 속성을 쓰도록 컨트롤러에 추가할 것 — JSP 에 키를 하드코딩하지 말 것.

### C2. 운영시간 등록 UI

**대상**: 점주 화면 신규 (`owner/store.jsp` 안에 섹션 추가)

현재:
- `Salon_Operating_Hours` 테이블 있음 (`day_of_week` ENUM 월~일, `open_time`, `close_time`)
- `SalonOperatingHourVO` 있음
- `SalonMapper` 에 조회/삽입 있음, `sql/seed_operating_hours.sql` 도 있음
- `ReservationService` 가 이 값으로 예약 가능 시간을 계산한다 — **이미 예약 로직이 의존 중**
- `OwnerRequestService.approve()` 75행이 승인 시 `insertDefaultOperatingHours(salonId, "10:00", "20:00")`
  로 **7일 전부 동일한 기본값을 박아넣는다.** 주석에도 "영업시간 행이 하나도 없으면
  findOperatingHour 가 항상 휴무로 보므로" 라고 적혀 있다.

즉 **점주가 자기 매장 영업시간을 한 번도 못 바꾸는 상태**다. 이게 피드백의 핵심.

작업:
1. `store.jsp` 에 요일 7행 테이블 (요일 / 오픈 / 마감 / 휴무 체크박스)
2. 휴무 표현 방식 `[결정 필요]` — `open_time`/`close_time` 이 `NOT NULL` 이라 행을 지우거나
   `is_closed` 컬럼을 추가해야 한다. **권장: `is_closed BOOLEAN DEFAULT FALSE` 컬럼 추가.**
   행 삭제 방식은 `ReservationService` 가 "행 없음 = 휴무" 로 이미 동작하므로 당장은 돌아가지만,
   점주가 의도적으로 쉬는 날인지 데이터가 안 들어간 건지 구분이 안 된다.
3. 저장은 해당 매장 7행 전체 delete → insert (부분 갱신보다 단순하고 요일 누락이 없다)
4. C4 의 2차 승인 심사 대상에 "운영시간을 기본값에서 바꿨는가" 를 포함

### C3. 이벤트/공지사항을 매장정보 관리에 병합

**대상**: `owner/events.jsp` → `owner/store.jsp` 로 흡수, `includes/sidebar_owner.jsp` 34~36행 메뉴 제거

현재 `events.jsp` 는 101행짜리 독립 페이지이고 사이드바에 별도 메뉴가 있다.
`/owner/events` (등록), `/owner/events/{noticeId}/delete` 핸들러와
`SalonNoticeService` / `SalonNoticeVO` / `SalonNoticeMapper` 는 그대로 재사용한다.

작업:
1. `events.jsp` 본문을 `store.jsp` 하위 섹션(카드)으로 이동 — 시술 메뉴 관리 섹션과 같은 패턴
2. 사이드바에서 `events` 메뉴 항목 삭제
3. `/owner/events` GET 은 `/owner/store` 로 리다이렉트 (기존 링크·북마크 보호)
4. POST 엔드포인트는 유지하되 성공 후 `redirect:/owner/store` 로

주의: `events.jsp` 는 `enctype="multipart/form-data"` 파일 업로드를 쓴다.
`store.jsp` 의 기존 매장정보 폼과 **하나로 합치지 말 것** — 별도 form 으로 유지한다.

### C4. 매장 2단계 승인 프로세스

피드백 원문:

```
등록요청 → (정상적인 점주인지) 관리자 1차 승인 (폐쇄상태)
        → 승인 확인되면 매장관리에 정보 입력
        → (양식 준수했는지) 관리자 2차 승인 (홈에 정상 접근 가능)
```

**현재 상태 — 승인이 1단계뿐이다.**
- `OwnerRequestVO.status` = `pending / approved / rejected` — 이건 **요청** 단위 상태다
- `OwnerRequestService.approve()` 가 승인 즉시 `salonMapper.insertSalon()` 으로 매장을 만들고
  기본 운영시간까지 넣는다 → **그 순간부터 매장이 공개된다**
- `Salons` 에는 승인 상태 컬럼이 **없다**. `closed_at` 은 폐업용(`sql/migration_salon_status.sql`)이라
  용도가 다르니 재사용하지 말 것
- `includes/salon_gate_overlay.jsp` 라는 게이트 오버레이가 이미 있다 — 2차 승인 대기 화면으로 재활용 가능

작업:
1. 마이그레이션 신규 — `sql/migration_salon_approval.sql` 에
   `Salons.approval_status ENUM('setup','review','approved')` 추가
   `[결정 필요]` 기존 매장의 기본값. **권장: `approved`** — 기존 데이터가 전부 심사대기로
   빠지면 발표 시연이 깨진다.
2. `OwnerRequestService.approve()` 가 매장을 `setup` 상태로 생성하도록 변경
3. `setup` 상태 매장은 점주에게만 보이고 고객 화면에서 제외 —
   `SalonMapper` 의 목록/검색/지도 쿼리 전부에 필터를 걸어야 한다.
   `[주의]` Elasticsearch 색인(`es/ElasticSearchConfig`, `SalonSearchService`, `SalonsDocument`)도
   같이 걸러야 한다. **DB만 막고 ES 를 빼먹으면 검색 결과에는 그대로 노출된다.**
4. 점주가 정보 입력 완료 후 [심사 요청] → `review` 상태로 전환
5. 관리자 화면(`admin/salons.jsp`)에 2차 승인 대기 목록 + 승인/반려 액션
6. 반려 사유를 점주에게 표시 — `salon_gate_overlay.jsp` 재활용

`[결정 필요]` 2차 승인의 "양식 준수" 기준을 무엇으로 볼 것인가.
**권장 최소 조건**: 주소+좌표 있음 / 연락처 있음 / 시술 메뉴 1개 이상 / 운영시간이 기본값이 아님.
자동 체크리스트로 보여주고 최종 판단은 관리자가 한다.

---

## 4. 소셜 로그인 (D)

### D1. 구글 · 네이버 OAuth

`pom.xml` 에 `spring-security-oauth2-client` 의존성이 없다. 완전 신규 작업.

작업:
1. `pom.xml` — `spring-security-oauth2-client`, `spring-security-oauth2-jose` 추가
   (Spring Security 5 계열이므로 버전을 기존 security 버전에 맞출 것)
2. 마이그레이션 — `Users` 에 `provider VARCHAR(20) NOT NULL DEFAULT 'local'`(local/google/naver),
   `provider_id VARCHAR(255) NULL`, 그리고 두 컬럼의 복합 UNIQUE 인덱스 추가
3. `SecurityConfig` 에 `oauth2Login()` 추가 + `CustomOAuth2UserService`
4. `password NOT NULL` 문제 `[결정 필요]` — OAuth 회원은 비밀번호가 없다.
   **권장: 컬럼을 NULL 허용으로 바꾸고, 비밀번호 변경 모달을 `provider='local'` 에서만 노출.**
   더미값을 넣으면 나중에 그 값으로 로그인이 되는지 아무도 확신할 수 없게 된다.
5. 네이버는 표준 OIDC 가 아니라 `userNameAttribute` 커스텀 설정이 필요하다
   (응답이 `response` 로 한 겹 감싸져서 온다)

`[주의]` CLAUDE.md 규칙 — 인증/권한 판단은 `SecurityConfig.filterChain()` 안에만 둔다.
OAuth 분기를 컨트롤러마다 넣지 말 것.

### D2. OAuth 파생 제약 3건

D1 이 끝나야 의미가 있다. 전부 `provider` 컬럼 하나로 갈린다.

| 제약 | 구현 위치 |
|---|---|
| 점주 요청은 자체 가입 회원만 | `SecurityConfig` 에서 점주 요청 경로 접근 제한 + `common/owner-request.jsp` 안내 |
| 가입 자동 쿠폰은 자체 가입 회원만 | 회원가입 시 `findByIssueType("signup")` 발급 분기에 `provider='local'` 조건 |
| OAuth 회원은 일부 정보 변경 불가 | B1 모달에서 provider 별로 필드 `readonly` 처리 |

`[결정 필요]` OAuth 회원의 이름·전화번호 변경 허용 여부.
**권장: 이름은 제공자 값 고정(readonly), 전화번호는 수정 허용.**
전화번호는 예약 확인 연락에 쓰이는데 소셜 제공자가 안 주는 경우가 많다.

---

## 5. 발표 Q&A 항목 (코드 작업 아님)

팀에서 직접 답변을 준비한다. 여기에는 **근거가 코드 어디에 있는지만** 적는다.

| # | 질문 | 근거 위치 |
|---|---|---|
| 1 | 흐름 설명 | `CLAUDE.md` "Architecture", `docs/checkout-todo.md` §2 흐름도 |
| 2 | 초기 데이터 부족 보완 | `dummydata_original.sql`, `sql/seed_operating_hours.sql`, `sql/salon_coordinates.sql` |
| 3 | 기존 플랫폼과 차별점 | 매장별 등급제(`SalonGradeVO`, `mypage.jsp` 등급 모달), 1:1 실시간 면담(`ws/`, `ChatSocketController`), 적립금(`PointService`) |
| 4 | 주 사용자 계층 | — (팀 정의 필요) |
| 5 | 왜 Spring 인가 | `docs/초기세팅가이드.md` |
| 6 | 커뮤니티·리뷰 악성 유저 관리 | **이미 구현돼 있음** — 아래 참고 |
| 7 | 발표 동선 | 아래 §6 |
| qna 1 | 왜 이메일 변경 불가? | `Users.email` 이 `UNIQUE NOT NULL` 로그인 ID, `SecurityConfig` 의 `userEmail` 파라미터, `UserDetailService` 조회 키. → 관리자 요청 방식. B1 참고 |

**6번은 그대로 시연하면 되는 수준으로 구현돼 있다**:
- 신고 — `PostReportMapper`, `CommentReportMapper`
- 자동 블라인드 — `Posts.status ENUM('visible','blinded')` (`sql/schema.sql:208`)
- 관리자 제재/해제 — `AdminController:187` `approveDelete(sanctionType)`,
  `:202` `approveDeleteComment`, `:216` `lift-sanction`
- 제재 이력 — `UserSanctionMapper`, `AdminController:179` `getSanctionHistory`
- 제재 상태 — `Users.status ENUM('active','suspended','banned')` + `suspended_until`
- 정지 회원 안내 화면 — `common/community/suspended.jsp`, `CommunityController:59`

---

## 6. 발표 동선

피드백 원문: *팀장 간략 소개 → 각 팀원 기능 발표 → 마무리*, 시연 축은 **예약 / 매장등록 / 결제**.

제안 순서 (화면 전환이 앞뒤로 튀지 않는 순서):

```
1. 팀장  — 서비스 소개, 아키텍처, 기술 선택 이유 (Q&A 1·3·4·5 선제 답변)
2. 매장등록 — 점주 가입 요청 → 관리자 1차 승인 → 매장정보 입력(주소·운영시간·메뉴)
              → 2차 승인 → 홈 노출              [C1·C2·C3·C4 완료 전제]
3. 예약     — 검색/지도 → 매장 상세 → 시술·디자이너·시간 선택
4. 결제     — 체크아웃(쿠폰·적립금) → 카카오페이 → 결과       [docs/checkout-todo.md]
5. 커뮤니티·운영 — 리뷰/게시글 → 신고 → 자동 블라인드 → 관리자 제재  (Q&A 6번 답변 겸용)
6. 마이페이지  — 예약내역·쿠폰(코드 입력)·적립금·등급·정보변경   [A4·B1 완료 전제]
7. 마무리   — 남은 과제 (OAuth 등)
```

2번이 **1차 승인 → 정보입력 → 2차 승인** 을 그대로 보여주므로,
C4 를 먼저 끝내면 발표 동선 자체가 피드백에 대한 답이 된다.

---

## 7. 권장 진행 순서

1. **A1~A4** — 전부 국소 변경. 발표 리스크를 먼저 없앤다.
2. **B1+B2** — 한 작업으로 묶어서. 모달이 3개가 되지 않게 주의.
3. **C1~C4** — 발표 동선 2번의 핵심. C4 가 제일 크므로 C1·C2 를 먼저 끝내고 붙인다.
4. **D1~D2** — 발표 후로 미뤄도 되는 유일한 덩어리. 마무리에서 "남은 과제" 로 언급.
