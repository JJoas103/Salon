# 예약 플로우 코드 리뷰 진행 계획

이 문서는 **"예약 → 결제 코드를 어떤 순서로 읽고 무엇을 확인할 것인가"** 다.
기능을 고치는 문서가 아니라 **이해하기 위한 문서**다.

- 무엇을 만들었는지(구현 순서·설계 의도)는 [checkout-handoff.md](checkout-handoff.md) / [checkout-todo.md](checkout-todo.md) 참고.
- 이 문서는 그 결과물을 사후에 읽어 내려가는 리뷰 계획이다.

## 배경

예약·결제 플로우는 Claude 와 함께 만들어져서, 코드는 동작하지만 **작성자가 흐름 전체를
자기 말로 설명하지 못하는 상태**다. 목표는 다음 두 가지다.

1. 각 파일이 왜 그 자리에 그렇게 있는지 스스로 설명할 수 있게 되는 것
2. 읽는 과정에서 발견되는 실제 결함을 목록으로 남기는 것 (§5)

**수정은 리뷰가 끝난 뒤에 한다.** 읽다가 고치기 시작하면 흐름 파악이 끊긴다.
발견한 것은 §5 에 적어두고 계속 읽는다.

## 진행 현황

| 세션 | 범위 | 상태 |
|---|---|---|
| 1 | 데이터 모델 + 컨트롤러 지도 | ⬜ 다음 |
| 2 | 슬롯 계산 (`getAvailableSlots`) | ⬜ |
| 3 | 자리 선점 (`createPendingReservation`) | ⬜ |
| 4 | 화면 (`reserve.jsp`) — 확인용 | ⬜ |
| 5~ | 결제 플로우 | ⬜ 예약 리뷰 완료 후 별도 계획 |

---

## 전체 그림 (읽기 전에 알아둘 것)

예약 화면은 5단계지만, **DB 에 무언가 쓰이는 것은 마지막 1단계뿐이다.**

```
[1] GET  /common/reserve                  매장·시술·디자이너 목록      (읽기)
[2] GET  /common/reserve/stylist-schedule 예약 가능 '날짜' JSON        (읽기)
[3] GET  /common/reserve/slots            그 날짜의 '시간대' JSON      (읽기)
[4] GET  /common/reserve/checkout         확인 화면 + 금액 계산        (읽기)
─────────────────────────────────────────────────────────────────────
[5] POST /common/reserve                  자리 선점 + 결제행 생성      (쓰기)  ← 여기서 결제 플로우 시작
```

**예약 플로우와 결제 플로우의 경계선**은 [ReserveController.java:143](../src/main/java/com/soldesk/controller/ReserveController.java#L143)
의 `createPendingReservation()` 호출이다. 이 리뷰(세션 1~4)는 그 선까지만 다룬다.

> 참고: `/common/reserve/**` 는 `SecurityConfig` 의 `anyRequest().authenticated()` 에 걸려
> **전 구간 로그인 필수**다. 그래서 컨트롤러의 `authentication` 은 null 이 될 수 없다.
> (CLAUDE.md 의 "except /reserve/info" 설명은 오래된 내용이다.)

---

## 세션 1 — 데이터 모델 + 컨트롤러 지도

가장 먼저 할 일. 상태값과 URL 지도를 잡아야 나머지가 읽힌다.

### 읽을 것

| 파일 | 범위 |
|---|---|
| [sql/schema.sql](../sql/schema.sql#L96-L110) | `Reservations` 96–110 (10줄) |
| [ReserveController.java](../src/main/java/com/soldesk/controller/ReserveController.java) | 전체 (376줄, 결제 콜백 제외하면 절반) |

### 확인할 것

**`Reservations` 에서 볼 것은 두 가지뿐이다.**

- `status ENUM('pending','confirmed','completed','cancelled')`
  → 예약의 전 생애가 이 4개다. 자바 코드의 모든 상태 분기가 이 값들을 비교한다.
- `(stylist_id, reservation_time)` 에 **UNIQUE 제약이 없다**
  → "같은 디자이너·같은 시각 중복 예약 금지"를 DB 가 아니라 애플리케이션 SQL 이 지킨다.
  세션 3 에서 이게 왜 중요한지 나온다.

**컨트롤러는 위 5단계 표와 1:1로 맞춰보면 된다.** 스스로 답해볼 질문:

- 4단계(확인 화면)가 DB 에 아무것도 쓰지 않는 이유는? 쓰면 무엇이 나빠지나?
- `/slots` 와 `/stylist-schedule` 이 나뉘어 있는 이유는? (캘린더 날짜 회색처리 vs 시간 목록)
- `reserveSlots()` 가 `salonId` 를 파라미터로 받지 않고 `stylistId` 에서 거슬러 올라가는 이유는?
  ([:100-102](../src/main/java/com/soldesk/controller/ReserveController.java#L100-L102) 주석)
- `reserveFailView()` 하나로 모든 실패를 처리한다. 이게 어떤 화면으로 가나?

### 완료 기준

5단계 표를 보지 않고 URL → 하는 일 → 다음 단계를 말할 수 있으면 끝.

---

## 세션 2 — 슬롯 계산

가장 어렵고 가장 값어치 있는 부분. 예약의 심장.

### 읽을 것

| 파일 | 범위 |
|---|---|
| [ReservationService.java](../src/main/java/com/soldesk/service/ReservationService.java#L178-L263) | `getAvailableSlots` + `computeWorkWindow` + `workWindowOf` (178–263) |
| [ResvMapper.xml](../src/main/resources/mapper/ResvMapper.xml) | `findReservedTimes` |

### 한 줄 요약

```
매장 영업시간 ∩ 디자이너 근무시간 → 30분 단위로 자름 → 이미 찬 시각·지난 시각을 unavailable 로 표시
```

### 확인할 것

- **시술 소요시간이 계산에 안 들어간다.** 10:30(1시간)과 11:00(30분)이 겹칠 수 있다.
  이건 버그가 아니라 정책이다 ([:183-185](../src/main/java/com/soldesk/service/ReservationService.java#L183-L185) 주석).
  이 정책에 동의하는지 판단할 것.
- `workWindowOf()` 가 `null` 을 돌려주는 경우가 3가지다. 각각이 무엇인지 짚어볼 것.
  (영업시간 행 없음 / 스케줄이 휴무 / 교집합이 빈 구간)
- 스케줄이 **등록돼 있지 않으면** 영업시간 내내 근무로 본다 ([:248](../src/main/java/com/soldesk/service/ReservationService.java#L248)).
  등록이 없는 것과 휴무 등록이 다르게 취급된다 — 의도한 게 맞나?
- `DAY_KO` 배열 ([:51](../src/main/java/com/soldesk/service/ReservationService.java#L51))이 존재하는 이유:
  DB 의 `day_of_week` 가 한글 ENUM 이라 `java.time.DayOfWeek` 를 그대로 못 쓴다.
- **`getAvailableSlots()` 가 첫 줄에서 `expireStalePending()` 을 부른다** ([:196](../src/main/java/com/soldesk/service/ReservationService.java#L196)).
  조회 메서드가 쓰기를 한다. 별도 스케줄러 없이 만료를 정리하려는 선택인데,
  대가가 무엇인지 생각해볼 것 (§5-2).

---

## 세션 3 — 자리 선점

동시성이 걸린 부분. 세션 1 에서 본 "UNIQUE 없음"이 여기서 회수된다.

### 읽을 것

| 파일 | 범위 |
|---|---|
| [ReservationService.java](../src/main/java/com/soldesk/service/ReservationService.java#L264-L347) | `createPendingReservation` + `validateCombination` (264–347) |
| [ResvMapper.xml](../src/main/resources/mapper/ResvMapper.xml#L170-L184) | `insertIfSlotFree` (170–184) |

### 확인할 것

메서드에 1~7 단계 주석이 붙어 있으니 그 순서대로 따라간다.

- **2단계에서 슬롯을 확인하고, 3단계에서 `WHERE NOT EXISTS` 로 또 확인하는 이유는?**
  → 확인과 INSERT 사이에 남이 채갈 수 있다. 2단계는 "고를 수 없는 시간"(영업시간 밖)을,
  3단계는 "방금 뺏긴 자리"를 걸러낸다. 에러 메시지가 다른 것도 이 때문.
- `insertIfSlotFree` 의 `WHERE NOT EXISTS` 조건을 읽어볼 것. 자리를 막는 것은:
  `confirmed`/`completed` 상태 **또는** 10분이 안 지난 `pending`.
  → 10분 지난 pending 은 자동으로 자리를 놓아준다. 이게 홀드 만료의 실체다.
- 서브쿼리가 `FROM (SELECT ... FROM Reservations) r` 로 한 번 감싸져 있다.
  MySQL 이 "INSERT 대상 테이블을 같은 문장에서 SELECT 못 함"을 우회하는 관용구다.
- **금액을 폼에서 받지 않고 `quote()` 로 다시 계산한다** ([:300-303](../src/main/java/com/soldesk/service/ReservationService.java#L300-L303)).
  폼 금액을 믿으면 1원 결제를 만들 수 있다.
- **적립금 차감(5)·쿠폰 점유(6)가 INSERT 뒤에 있고, 실패하면 롤백에 맡긴다.**
  보상 코드를 안 쓰는 대신 트랜잭션에 의존하는 설계다. `@Transactional` 이 빠지면 무너진다.
- 쿠폰은 **할인이 실제로 붙었을 때만** 묶는다 ([:314](../src/main/java/com/soldesk/service/ReservationService.java#L314)).
  안 그러면 할인은 못 받고 쿠폰만 소멸한다.

---

## 세션 4 — 화면 (확인용)

576줄이지만 **전부 읽지 않는다.**

[reserve.jsp](../src/main/webapp/WEB-INF/views/common/reserve.jsp) 에서 `fetch(` 를 검색해,
세션 1 의 [2]·[3] 엔드포인트를 각각 언제 부르는지만 맞춰본다.
JS 가 서버 응답(`TimeSlotVO.available`)을 어떻게 화면에 반영하는지까지 확인하면 끝.

---

## §5 발견 사항 (읽으면서 채울 것)

리뷰 중 발견한 결함·의문을 여기 모은다. **여기서 고치지 않고 기록만 한다.**

미리 눈에 띈 것 (검증 필요):

1. **`WHERE NOT EXISTS` 가 정말 동시 요청을 막는가** — `(stylist_id, reservation_time)` 에
   인덱스도 UNIQUE 도 없다. 동시에 들어온 두 요청이 둘 다 조건을 통과할 수 있는지
   확인이 필요하다. 안전하게 하려면 유니크 인덱스를 추가하고 중복 키 예외를 잡는 쪽이 확실하다.
   (세션 3)
2. **조회 API 가 매번 쓰기를 한다** — `GET /slots` 를 부를 때마다 `expireStalePending()`
   이 UPDATE 를 시도한다. 캘린더에서 날짜를 누를 때마다 쓰기 트랜잭션이 열린다.
   스케줄러로 뺄지, 그대로 둘지 판단 필요. (세션 2)
3. **`reservationTime` 형식 검증이 없다** — [ReserveController.java:312-313](../src/main/java/com/soldesk/controller/ReserveController.java#L312-L313)
   과 [ReservationService.java:281-282](../src/main/java/com/soldesk/service/ReservationService.java#L281-L282)
   이 검사 없이 `substring(0,10)` / `substring(11,16)` 을 한다. 짧은 값이 오면
   `StringIndexOutOfBoundsException` → 500. (세션 1 또는 3)
4. **`validateCombination` 이 `@Transactional`(쓰기)** — 읽기만 하므로 `readOnly = true` 가 맞다.
5. **컨트롤러의 try-catch 중복** — `reserveFailView` 로 끝나는 catch 가 4곳 반복.
   `@ControllerAdvice` 로 모을 후보. 단 `failPayment()` 호출(보상 트랜잭션)은 옮기면 안 된다.
   → 이건 결제 리뷰(세션 5~) 범위.

---

## 다음 세션 시작하는 법

새 세션에서 이렇게 시작하면 된다.

> `docs/reserve-code-review.md` 읽고 세션 N 진행해줘.

리뷰 방식은 **코드를 낭독하지 말고, 왜 그 자리에 그렇게 있는지 설명 + 이상한 곳 지적**.
세션이 끝나면 위 진행 현황 표와 §5 를 갱신한다.