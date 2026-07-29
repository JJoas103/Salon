# 점주(Owner) 사이드바·페이지 연결 가이드

로그인/보안(SecurityConfig, UserController, UserDetailService 등)은 건드리지 않습니다.
이 문서는 **로그인 이후, 점주 화면이 실제 점주 메뉴로 보이게 만드는 작업**만 다룹니다.

---

## 0. 지금 준비된 것 / 안 된 것

이미 되어 있는 것 (백엔드는 완성됨):
- `OwnerController` — `/owner/mypage`, `/owner/store`, `/owner/staff`, `/owner/reservations`, `/owner/events`, `/owner/chat` 라우트 전부 존재
- `SecurityConfig` — `/owner/**`는 `ROLE_OWNER`만 접근 가능하도록 이미 막혀 있음
- `includes/password_modal.jsp` — 비밀번호 변경 모달 (고객/점주 공용, `owner/mypage.jsp`에서 이미 재사용 중)
- DB에 점주 테스트 계정 4개 이미 존재: `owner1@salu.com` ~ `owner4@salu.com` (각자 매장 2~3개씩 보유)

아직 안 된 것 (이 문서에서 고칠 것):
- `includes/sidebar_owner.jsp` — 아직 **고객용 메뉴(홈/검색/채팅/커뮤니티/마이페이지)를 그대로 복사**해온 상태. 점주 라우트를 하나도 안 가리킴
- `owner/{store,staff,reservations,events,chat}.jsp` 5개 — 각자 **자기만의 `<aside>` 사이드바를 하드코딩**하고 있고(`sidebar_owner.jsp`를 안 씀), CSS 경로가 상대경로(`../css/...`)라 실제 서버에서 깨지고, 헤더 이름도 "강남본점 점주님"으로 고정됨
- `OwnerController`의 `store()/staff()/reservations()/events()/chat()` — 지금은 그냥 뷰 이름만 반환하고 `user` 정보를 안 넘겨줌 (헤더에 실제 이름을 못 씀)

---

## 1. 기준으로 삼을 패턴: `sidebar_common.jsp`

지금 잘 동작하는 고객용 사이드바가 쓰는 방식을 그대로 따라 하면 됩니다.

```jsp
<c:set var="menu" value="${param.menu}" />
...
<li class="sidebar-item ${menu == 'home' ? 'active' : ''}">
  <a href="<c:url value='/common/home'/>">...</a>
</li>
```

- 페이지가 `<jsp:include>`할 때 `<jsp:param name="menu" value="..."/>`로 "지금 내가 어느 메뉴인지" 키를 넘긴다
- 사이드바는 그 키와 자기 항목의 키가 같으면 `active` 클래스를 붙인다
- 링크는 `<c:url value='...'/>`로 감싸서 컨텍스트 경로가 자동으로 붙게 한다 (하드코딩 금지)

---

## 2. Step 1 — `includes/sidebar_owner.jsp` 메뉴 교체

**현재 (고객용 메뉴가 그대로 남아있음):**
```jsp
<li class="sidebar-item ${menu == 'home' ? 'active' : ''}"><a href="<c:url value='/'/>">...홈 메인</a></li>
<li class="sidebar-item ${menu == 'search' ? 'active' : ''}"><a href="<c:url value='/search'/>">...헤어샵 검색/예약</a></li>
... (이하 고객용 항목들)
```

**바꿀 내용 — `OwnerController`에 이미 있는 라우트 5개로 교체:**
```jsp
<ul class="sidebar-menu">
  <li class="sidebar-item ${menu == 'store' ? 'active' : ''}">
    <a href="<c:url value='/owner/store'/>"><i class="fas fa-store"></i> 매장정보 관리</a>
  </li>
  <li class="sidebar-item ${menu == 'staff' ? 'active' : ''}">
    <a href="<c:url value='/owner/staff'/>"><i class="fas fa-users"></i> 직원관리</a>
  </li>
  <li class="sidebar-item ${menu == 'reservations' ? 'active' : ''}">
    <a href="<c:url value='/owner/reservations'/>"><i class="fas fa-calendar-check"></i> 예약현황관리</a>
  </li>
  <li class="sidebar-item ${menu == 'events' ? 'active' : ''}">
    <a href="<c:url value='/owner/events'/>"><i class="fas fa-bullhorn"></i> 이벤트/공지사항</a>
  </li>
  <li class="sidebar-item ${menu == 'chat' ? 'active' : ''}">
    <a href="<c:url value='/owner/chat'/>"><i class="fas fa-comments"></i> 1:1 면담</a>
  </li>
  <li class="sidebar-item ${menu == 'mypage' ? 'active' : ''}">
    <a href="<c:url value='/owner/mypage'/>"><i class="fas fa-user"></i> 마이페이지</a>
  </li>
</ul>
```

`sidebar-footer`의 로그아웃 링크는 이미 `/user/logout`으로 맞게 연결돼 있으니 그대로 둡니다.

메뉴 키(`store`/`staff`/`reservations`/`events`/`chat`/`mypage`)는 Step 2에서 각 페이지가 넘겨주는 `menu` 값과 반드시 이름이 같아야 `active` 표시가 맞습니다.

---

## 3. Step 2 — `owner/*.jsp` 5개 파일 각각 수정

5개 파일(`store.jsp`, `staff.jsp`, `reservations.jsp`, `events.jsp`, `chat.jsp`) 전부 **같은 3가지 문제**를 갖고 있어서, 같은 방식으로 반복 수정하면 됩니다.

### 3-1. 하드코딩된 `<aside>` 삭제 → `sidebar_owner.jsp` include로 교체

**현재 (예: `store.jsp`):**
```jsp
<body class="store-page">
  <aside class="sidebar">
    <div class="sidebar-brand">...</div>
    <ul class="sidebar-menu">
      <li class="sidebar-item"><a href="reservations.html">...</a></li>
      ... (html 파일 링크라서 실제로는 다 깨져 있음)
    </ul>
  </aside>
  <div class="app-container">
```

**바꿀 내용:**
```jsp
<body class="store-page">
  <jsp:include page="../includes/sidebar_owner.jsp">
      <jsp:param name="menu" value="store" />
  </jsp:include>
  <div class="app-container">
```

파일별로 `value` 부분만 다르게:

| 파일 | menu 값 |
|---|---|
| `store.jsp` | `store` |
| `staff.jsp` | `staff` |
| `reservations.jsp` | `reservations` |
| `events.jsp` | `events` |
| `chat.jsp` | `chat` |

### 3-2. CSS 경로를 절대경로로

**현재:**
```jsp
<link rel="stylesheet" href="../css/common.css">
<link rel="stylesheet" href="../css/owner.css">
```

**바꿀 내용** (다른 JSP들이 전부 이 방식을 씀 — `resources/css/`가 `/resources/**`로 서빙됨):
```jsp
<link rel="stylesheet" href="/resources/css/common.css">
<link rel="stylesheet" href="/resources/css/owner.css">
```

### 3-3. 헤더의 하드코딩된 이름을 실제 로그인 사용자로

**현재 (5개 파일 전부 동일):**
```jsp
<div class="user-badge"><span>강남본점 점주님</span>...</div>
```

**바꿀 내용:**
```jsp
<div class="user-badge"><span>${user.userName} 점주님</span>...</div>
```

이걸 쓰려면 컨트롤러가 `user`를 모델에 넣어줘야 합니다 → Step 3에서 처리.

---

## 4. Step 3 — `OwnerController`에 `user` 모델 채워주기

지금 `store()`/`staff()`/`reservations()`/`events()`/`chat()`는 파라미터가 없어서 3-3에서 쓴 `${user.userName}`이 항상 빈 값입니다. `mypage()`가 이미 하고 있는 패턴을 그대로 복사하면 됩니다.

**현재:**
```java
@GetMapping("/store")
public String store(){
    return "owner/store";
}
```

**바꿀 내용 (5개 메서드 전부 동일 패턴):**
```java
@GetMapping("/store")
public String store(Authentication authentication, Model model){
    model.addAttribute("user", userService.getUser(authentication.getName()));
    return "owner/store";
}
```

`Authentication`, `Model` import는 이미 파일 상단에 있으니 추가로 넣을 import는 없습니다.

---

## 5. 검증 방법

**어느 계정으로 테스트할지**: DB에 이미 `owner1@salu.com` ~ `owner4@salu.com` 4개 계정이 있고 각자 매장을 2~3개씩 갖고 있습니다 (`owner1`이 3개로 제일 많음). 비밀번호는 `dummydata_original.sql`에 평문으로 안 남아있어서 알 수가 없습니다 — 알고 계시면 그걸로 로그인하시고, 모르시면 말씀해주시면 SQL로 원하는 비밀번호로 리셋해드릴 수 있습니다.

**체크리스트**:
1. 점주 계정으로 로그인 → `/owner/mypage` 도착
2. 사이드바에 매장정보/직원관리/예약현황관리/이벤트공지/1:1면담/마이페이지 6개 메뉴가 보이는지
3. 각 메뉴 클릭 → 페이지 이동 + 클릭한 메뉴에 `active` 스타일(강조 배경) 붙는지
4. 각 페이지 헤더에 실제 로그인한 이름(예: "이원장 점주님")이 뜨는지 — "강남본점 점주님" 하드코딩이 사라졌는지
5. CSS가 깨지지 않고 제대로 로드되는지 (레이아웃이 무너지면 경로 오타 의심)
6. 마이페이지의 "운영 매장" 카드에 실제 DB 매장 정보(매장명/주소/전화)가 뜨는지

**알아두면 좋은 기존 제약**: `SalonService.getSalonByOwner()`가 `LIMIT 1`이라, owner1처럼 매장을 여러 개 가진 계정도 마이페이지에는 **첫 번째 매장 하나만** 보입니다. 지금 당장 고칠 필요는 없고, 나중에 "매장 여러 개 관리"가 실제 기능으로 필요해지면 그때 목록 조회로 확장하면 됩니다.

---

## 요약 순서

1. `sidebar_owner.jsp` 메뉴 6개를 점주 라우트로 교체
2. `owner/*.jsp` 5개 파일: `<aside>` 삭제 → include, CSS 절대경로, 헤더 EL로 교체 (반복 작업)
3. `OwnerController`의 store/staff/reservations/events/chat 5개 메서드에 `user` 모델 추가
4. 점주 계정으로 로그인해서 6개 메뉴 다 클릭+헤더 이름 확인
