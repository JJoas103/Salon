# 1:1 상담 채팅 (WebSocket / STOMP)

`feature/websocket` 브랜치. 고객 ↔ 매장 점주 간 1:1 문의를 실시간으로 주고받는 기능이다.

이 문서는 **코드를 처음 읽는 사람을 위한 안내서**다. 커밋 순서대로 읽지 말 것 —
잘못 짚었다가 되돌린 과정(스캔 위치, 임시 ping 핸들러, 중복 매핑)이 섞여 있어 오히려 헷갈린다.
아래 기능 축으로 읽는 편이 빠르다.

---

## 무엇이 되어 있나

- 고객이 매장 상세/예약내역에서 **1:1 문의**를 열면 방이 생기고(이미 있으면 재사용) 대화를 시작한다
- 점주는 사이드바에서 **고른 매장**의 문의 목록을 본다
- 메시지는 실시간으로 도착하고, DB에 남아 새로고침해도 유지된다
- 카카오톡처럼 **읽음 표시("1")** 가 붙고, 상대가 읽으면 즉시 사라진다
- 다른 페이지에 있어도 **사이드바 메뉴에 안읽음 배지**가 뜬다
- 연결이 끊기면 자동 재연결하고, 세션이 만료된 경우는 구분해서 안내한다

## 파일 지도

| 영역 | 파일 |
|---|---|
| 배선 | `pom.xml`, `web.xml`, `dispatcher-servlet.xml`, [WebSocketConfig](../src/main/java/com/soldesk/ws/WebSocketConfig.java), [StompAuthChannelInterceptor](../src/main/java/com/soldesk/handler/StompAuthChannelInterceptor.java) |
| DB | [migration_chats.sql](../sql/migration_chats.sql), [ChatMapper.xml](../src/main/resources/mapper/ChatMapper.xml) |
| VO | [ChatVO](../src/main/java/com/soldesk/vo/ChatVO.java), [MessageVO](../src/main/java/com/soldesk/vo/MessageVO.java), [ChatRoomVO](../src/main/java/com/soldesk/vo/ChatRoomVO.java), [SocketEventMessage](../src/main/java/com/soldesk/vo/SocketEventMessage.java) |
| 서버 로직 | [ChatService](../src/main/java/com/soldesk/service/ChatService.java), [ChatSocketController](../src/main/java/com/soldesk/controller/ChatSocketController.java), [CommonController](../src/main/java/com/soldesk/controller/CommonController.java), [OwnerController](../src/main/java/com/soldesk/controller/OwnerController.java) |
| 화면 | [chat.js](../src/main/webapp/resources/js/chat.js), [common/chat.jsp](../src/main/webapp/WEB-INF/views/common/chat.jsp), [owner/chat.jsp](../src/main/webapp/WEB-INF/views/owner/chat.jsp), [sidebar_common.jsp](../src/main/webapp/WEB-INF/views/includes/sidebar_common.jsp), [sidebar_owner.jsp](../src/main/webapp/WEB-INF/views/includes/sidebar_owner.jsp) |

---

# 읽는 순서

**1 → 2장이 핵심이고, 3~6장은 순서를 바꿔도 된다.**

## 1장. 배선 — 연결이 성립하기까지

이게 없으면 나머지가 한 줄도 안 돈다. 정작 코드는 제일 적다.

```
pom.xml                    spring-websocket / spring-messaging
                           javax.websocket-api 는 provided (톰캣9가 이미 갖고 있다)
web.xml                    async-supported 3곳 (서블릿 + 필터 2개)
dispatcher-servlet.xml     component-scan 에 com.soldesk.ws
ws/WebSocketConfig.java    엔드포인트 1개 + 접두사 3종
handler/StompAuthChannelInterceptor.java
```

**던져볼 질문**

- `/app`, `/topic`, `/queue`, `/user` — 넷은 각각 누가 쓰는 접두사인가?
- 왜 `WebSocketConfig` 가 **루트가 아니라 dispatcher** 컨텍스트여야 하나?
- 인증은 언제 몇 번 하나? SUBSCRIBE·SEND 때는 왜 안 하나?

## 2장. 메시지 한 통의 왕복 — 가장 중요한 축

파일을 넘나들지만 흐름은 하나다. 순서대로 따라갈 것.

```
chat.js  send()
  → ChatSocketController.send()          @MessageMapping("/chat/send")
    → ChatService.sendMessage()          검증 → INSERT → touchRoom
      → convertAndSendToUser() × 2       상대 + 나(에코)
        → chat.js  handleEvent()         event 로 분기
          → addBubble()
```

**던져볼 질문**

- 클라이언트가 보낸 `senderId` 를 왜 버리고 `principal` 에서 가져오나?
- `send()` 의 반환 타입이 왜 `void` 인가? `@SendToUser` 로는 왜 안 되나?
- 보내자마자 말풍선을 그리지 않고 **서버 에코를 기다리는** 이유는?

## 3장. 방과 이력 — 소켓이 아닌 부분

**여기가 웹소켓과 무관하다는 걸 아는 게 포인트다.** 평범한 HTTP + MyBatis다.

```
sql/migration_chats.sql          salon_id, UNIQUE, is_read
vo/ChatVO.java                   user1=고객, user2=점주 순서 고정
mapper/ChatMapper.xml            findRoom / insertRoom / findRoomsBy*
service/ChatService.openRoom()   DuplicateKeyException 분기
controller/CommonController      GET /chat, POST /chat/room
views/common/chat.jsp            <c:forEach> 로 목록·이력 렌더
```

**던져볼 질문**

- `Chats` 테이블 없이 `Messages` 만으로 만들면 뭘 잃나?
- `user1/user2` 순서를 고정하면 쿼리가 어떻게 짧아지나?
- `UNIQUE` 제약과 `catch (DuplicateKeyException)` 은 무엇을 막나?

## 4장. 읽음 처리와 "1" 표시 — 양방향 통지

```
ChatMapper.xml  markAsRead
service/ChatService.markReadAndNotify()   ← 핵심
vo/SocketEventMessage.java
chat.js  handleEvent → 'messagesRead' → clearReadMarks()
chat.js  isWatchingRoom()
```

**던져볼 질문**

- DB만 바꾸면 왜 부족한가? "역방향 통지"가 왜 필요한가?
- `visibilityState` 와 `hasFocus()` 는 뭐가 다른가? 왜 둘 다 필요한가?
- `updated == 0` 이면 왜 통지를 안 보내나?

## 5장. 알림 배지 — 소켓이 사이드바로 올라간 이유

**구조가 한 번 바뀐 지점**이라 따로 봐야 한다.

```
includes/sidebar_common.jsp   CHAT_CONFIG + defer 스크립트 3개
includes/sidebar_owner.jsp    동일
resources/js/chat.js          맨 위 "두 역할" 주석부터 읽을 것
ChatMapper.xml  countUnread
CommonController  GET /chat/unread-count
ChatService.markReadAndNotify → 'unreadCount' 이벤트
```

**던져볼 질문**

- 소켓을 채팅 페이지에서만 열면 왜 알림이 불가능한가?
- 배지 감소를 **클라이언트가 -1 하지 않고** 서버 합계를 받는 이유는? (방 2개일 때를 생각해볼 것)
- 점주 배지는 왜 선택한 매장이 아니라 **전 매장** 합계인가?
- `defer` 가 없으면 뭐가 깨지나?

## 6장. 끊김과 복구 — 실패 경로

정상 동작만 보면 안 보이는 부분이다.

```
chat.js  connect() 의 두 번째 콜백(에러)
         scheduleReconnect()   지수 백오프 1초 → 30초
         probeSession()        세션 만료 vs 서버 다운 구분
         giveUp()
```

**던져볼 질문**

- 재연결 간격을 왜 늘리나? 1초 고정이면 뭐가 문제인가?
- 세션 만료와 서버 다운을 왜 **구분**해야 하나? 안 하면 사용자가 뭘 보게 되나?

---

# 설계 결정과 이유

## 목적지 규칙 (외울 건 이 3줄뿐)

```
클라 → /app/…      컨트롤러로 (가공·저장 자리)
서버 → /topic/…    구독자 전원에게 (권한 검사 없음)
서버 → /user/…     그 사람에게만 (principal 기준)
```

## `/topic` 을 쓰지 않는 이유

`enableSimpleBroker` 는 **구독 권한을 검사하지 않는다.** `/topic/chat/5` 로 뿌리면
로그인만 한 아무나 그 목적지를 구독해 남의 상담을 볼 수 있다.
`/user/…` 는 CONNECT 때 심어둔 principal 로 목적지를 갈라주므로 그 구멍이 없다.

## 구독은 하나, 이벤트로 분기

방마다 구독하지 않는다. 구독은 `/user/queue/messages` **하나**이고,
`SocketEventMessage {event, data}` 의 `event` 로 갈라 쓴다.
알림 종류가 늘어도 구독을 새로 파지 않아도 된다.

| event | 받는 사람 | 의미 |
|---|---|---|
| `newMessage` | 상대 + 발신자(에코) | 새 메시지 |
| `messagesRead` | 원래 발신자 | 내 메시지 옆 "1" 을 지워라 |
| `unreadCount` | 읽은 사람 | 사이드바 배지를 이 값으로 맞춰라 |

## 소켓과 HTTP의 역할 분담

- **HTTP** — 방 생성, 방 목록, 과거 이력, 안읽음 합계
- **소켓** — "연결된 뒤 새로 생기는 것"만

이 경계를 섞으면 설계가 꼬인다. 채팅 페이지를 열 때 이력이 이미 그려져 있는 것은
소켓이 아니라 `CommonController.chat()` 이 모델에 실어 보냈기 때문이다.

## 권한 검사를 두 군데로 나눈 이유

- **URL 단위** (`/ws/**`, `/common/chat/**` 접근 가능 여부) → `SecurityConfig.filterChain()`
- **행 단위** ("이 사람이 이 방 참여자인가") → `ChatService.requireParticipant()`

후자는 URL로 표현할 수 없다. CLAUDE.md 의 "인증/권한은 SecurityConfig 에만" 규칙과
충돌하지 않는 지점이다.

## 점주 방 목록은 `ownerId` 가 아니라 `salonId` 기준

점주가 매장을 여러 개 가지면 `ownerId` 로 뽑을 때 매장별 문의가 섞인다.
사이드바에서 이미 매장을 고르게 해뒀으므로(`session.selectedSalonId`) 그 값으로 찾는다.
단 **알림 배지만은 전 매장 합계**다 — 고르지 않은 매장의 문의를 놓치면 안 되기 때문.

---

# 이 프로젝트 특유의 함정

한 번씩 다 밟았던 것들이다.

**① `WebSocketConfig` 는 dispatcher 컨텍스트에만**

`@EnableWebSocketMessageBroker` 가 만드는 메시지 핸들러는 `@MessageMapping` 을 찾을 때
**자기 컨텍스트의 빈만 훑는다(조상 미포함).** 컨트롤러는 dispatcher 컨텍스트에 있으므로
설정이 루트에 있으면 핸들러를 영영 못 찾는다.

증상이 최악이다 — **핸드셰이크는 성공하고 연결 로그도 찍히는데, 보낸 메시지만
아무 예외 없이 사라진다.** (`HandlerMapping` 은 DispatcherServlet 이 조상까지 뒤져서 찾아내기 때문)

**② `web.xml` 의 `<async-supported>true</async-supported>`**

XML 방식이라 자동으로 붙지 않는다. dispatcher 서블릿 + `encodingFilter` +
`springSecurityFilterChain` **세 곳 모두** 필요하다. 하나라도 빠지면 핸드셰이크가 실패한다.

**③ `javax.websocket-api` 는 `provided`**

톰캣9가 `websocket-api.jar` 를 이미 갖고 있다. WAR 에 같이 넣으면 중복된다.

**④ `MessageVO.getIsRead()` 라는 어색한 게터 이름**

`isRead()` / `setRead()` 로 두면 MyBatis·EL 이 보는 프로퍼티명이 `read` 가 되어
`resultMap` 의 `property="isRead"` 와 어긋난다. 일부러 `getIsRead` 로 뒀다.

**⑤ 스크롤이 안 생기고 박스가 늘어나면 `overflow: hidden`**

flex/grid 항목의 `min-height: auto` 는 `overflow` 가 `visible` 일 때만
콘텐츠 기반 최소 크기로 해석된다(automatic minimum size). `overflow: hidden` 이나
`min-height: 0` 을 주면 항목이 컨테이너 높이까지 줄어들어 자식의 `overflow-y: auto` 가 살아난다.

**⑥ JSP 안 `<script>` 의 EL 은 IDE 가 오류로 표시한다**

`currentUserId: ${user.userId}` 같은 코드는 IDE 가 순수 JS 로 파싱해서 빨간 줄이 뜬다.
서버가 렌더링하면 `currentUserId: 3` 이 되므로 **무시해도 된다.**

---

# 직접 부숴보기

읽기만 하는 것보다 학습 효과가 크다. 하나씩 되돌려놓고 증상을 확인해볼 것.
**증상이 원인을 어떻게 감추는지**가 핵심이다.

| 부술 것 | 예상 증상 |
|---|---|
| `dispatcher-servlet.xml` 에서 `com.soldesk.ws` 를 빼고 루트로 옮기기 | 연결·로그는 정상인데 메시지만 조용히 사라짐 |
| `web.xml` 의 `async-supported` 하나 제거 | 핸드셰이크 단계에서 실패 |
| `@SendToUser` → `@SendTo("/topic/…")` | 남의 상담이 내 화면에 보임 |
| `markReadAndNotify` 의 reader 통지 제거 | 배지가 오르기만 하고 안 내려감 |
| `isWatchingRoom()` 에서 `hasFocus()` 제거 | 창을 나란히 띄우면 안 보고 있어도 읽음 처리됨 |
| `owner.css` 의 `overflow: hidden` 제거 | 스크롤 대신 박스가 늘어남 |
| 사이드바의 `defer` 제거 | 채팅 페이지에서 말풍선이 안 그려짐 |

---

# 아직 남은 것

**손봐야 할 것**

- **커넥션 풀이 없다** — `DriverManagerDataSource` 는 요청마다 커넥션을 새로 뚫는다.
  채팅은 메시지 한 통마다 DB를 치므로 여기가 먼저 무너진다. HikariCP 전환 필요.
- **메시지 길이 제한이 없다** — 서버는 빈 문자열만 막는다. 1MB 텍스트도 그대로 저장된다.
- **트랜잭션 커밋 전에 전송한다** — `sendMessage` 가 `@Transactional` 안에서 소켓 전송까지 한다.
  전송 후 커밋이 실패하면 "상대는 받았는데 DB에는 없는" 메시지가 생긴다.
- **세션 만료 후 재연결을 영원히 시도하지 않도록** 안내는 하지만, 자동 로그인 유도는 없다.

**안 쓰는 코드**

- `GET /common/chat/{chatId}/messages` — AJAX 방 전환용으로 만들었으나 아무도 호출하지 않는다.
  현재 방 전환은 링크 클릭 → 페이지 새로고침 방식이다. 붙이거나 지울 것.

**없는 기능**

- 메시지 시각 표시 (`sentAt` 을 받아만 놓고 화면에 안 씀)
- 헤더 토스트 알림
- 입력 중 표시, 이미지 전송
