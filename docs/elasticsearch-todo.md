# 엘라스틱서치 미용실 검색 — 현황 & 추후 개선사항

`feature/elasticsearch` 브랜치. 지도 페이지(`/common/salonmap`)의 검색창을 엘라스틱서치로 처리한다.

> 이 문서는 **바뀌는 정보**(진행 상황, 할 일)를 담는다. 구조적인 규칙은 `CLAUDE.md` 로.

---

## 1. 현재 구현 상태 (동작 확인 완료)

### 흐름

```
검색창 → fetch → GET /common/salons/search?keyword=
              → CommonController.searchSalons()
              → SalonService.searchSalons()
              → SalonSearchService.search(keyword, 1, 50)   ← ES
              → JSON(List<SalonVO>) → renderSalons() 가 마커 + 목록 갱신
```

키워드가 비면 ES를 타지 않고 `SalonService.getSalons()`(MySQL)로 전체를 돌려준다.

### 구성 요소

| 파일 | 역할 |
|---|---|
| `com.soldesk.es.ElasticSearchConfig` | `RestClient` → `ElasticsearchTransport` → `ElasticsearchClient` 빈 |
| `com.soldesk.vo.SalonsDocument` | ES 문서 ↔ `SalonVO` 변환 (`from()` / `toSalonVO()`) |
| `com.soldesk.service.SalonSearchService` | 인덱스 생성 / 전체 색인 / 검색 |
| `com.soldesk.service.SalonService` | `searchSalons()` 가 ES로 위임 |
| `com.soldesk.controller.CommonController` | `GET /common/salons/search` → JSON |
| `views/common/salonmap.jsp` | fetch → `renderSalons()` → 마커 + 결과 목록 |

`ElasticSearchConfig` 를 `com.soldesk.es` 에 둔 이유: `com.soldesk.config` 는 루트 컨텍스트와 웹 컨텍스트가 **둘 다** 스캔해서 클라이언트가 두 개 생성된다. 지금은 `applicationContext.xml` 의 component-scan 에만 등록되어 있다.

### 인덱스

- 이름: `salons` (`app.properties` 의 `elasticsearch.index`)
- 한글 필드(`salonName` / `address` / `description`)는 `text` + `analyzer: nori`
- 좌표는 `double` — `integer` 로 두면 `37.4638` 이 `37` 로 잘려 마커가 엉뚱한 곳에 찍힌다
- `phoneNumber` 는 `keyword` (형태소 분석 대상 아님)
- 검색: `multi_match`, `salonName^3` / `address^2` / `description`, 정렬은 `_score` 내림차순(기본)

### 환경

- ES 8.15.0 (도커 `elasticsearch` 컨테이너, `9200:9200`)
- `analysis-nori` 플러그인 설치됨
- `xpack.security.enabled=false`, `discovery.type=single-node`
- 볼륨 `es_data` 로 인덱스 유지

---

## 2. 추후 개선사항

### 🔴 A. 색인 동기화 — 가장 먼저 필요해질 것

지금은 **톰캣 기동 시 1회 전체 재색인**(`afterPropertiesSet()`)뿐이다. 기동 이후 MySQL 의 미용실이 추가·수정·삭제되면 **ES 는 모른다.** 재기동 전까지 검색 결과가 낡은 채로 남는다.

미용실 등록/수정/삭제 기능을 만들 때 같이 해야 할 일:

- `SalonSearchService.indexSalon(SalonVO)` / `deleteSalon(int salonId)` 추가
- 미용실 등록·수정 성공 시 `indexSalon()`, 삭제 시 `deleteSalon()` 호출
- 색인 실패가 미용실 등록 자체를 실패시키지 않도록 예외 처리 분리
  (MySQL 이 원본이고 ES 는 복사본이므로, 색인이 실패해도 등록은 성공해야 한다)

`reindexAll()` 도 지금은 문서를 **하나씩** `index()` 로 넣는다. 건수가 늘면 `bulk()` 로 바꿀 것.

### 🔴 B. ES 장애 시 폴백

ES 가 죽으면 검색이 통째로 실패한다(500 → 화면에 alert). 미용실 목록 자체는 MySQL 에 있으므로 검색만 품질이 떨어지는 형태로 버티는 게 낫다.

- `SalonService.searchSalons()` 에서 ES 호출을 `try/catch` 하고, 실패 시 `salonMapper.searchByKeyword()`(LIKE)로 폴백
- **`SalonMapper.searchByKeyword()` 는 지금 아무도 호출하지 않는 상태다.** ES 전환 전 단계에서 쓰던 것이 남아 있는데, 지우지 말고 폴백 경로로 살리면 된다
- 폴백이 동작했음을 로그로 남길 것 (조용히 품질이 떨어지면 아무도 모른다)

### 🟡 C. 검색 정확도 튜닝

현재 `multi_match` 는 기본이 **OR** 매칭이라 토큰 하나만 맞아도 결과에 들어온다.

실제 사례 — `"강남역 근처 펌 잘하는 미용실"` 검색 시 `위드헤어`가 걸렸는데, 이유는 설명의 `"실속형"` 에서 `실` 한 글자였다.

- `minimum_should_match("50%")` — 토큰 절반 이상 일치 요구
- `fuzziness` — 오타 보정 (`라운헤어` → `라움헤어`)
- 필드 가중치 재조정 (지금 `^3` / `^2` 는 감으로 잡은 값)
- 동의어 사전 — `펌`/`파마`, `미용실`/`헤어샵`/`살롱`, `커트`/`컷`
- 사용자 사전 — 노리가 미용 용어를 이상하게 쪼개는 경우 대비

### 🟡 D. geo_point + 위치 기반 검색

지도 화면이므로 이게 가장 큰 효과를 낼 개선이다.

- `location` 필드(`geo_point`)를 **추가** — 기존 필드의 타입 변경은 불가하지만 **필드 추가는 가능**하다
- `geo_distance` — "내 위치 반경 3km 이내" (이미 현재위치 버튼이 있다)
- `geo_bounding_box` + `map.getBounds()` — **보이는 지도 영역 안의 미용실만** 목록에 표시. 카카오맵/배민 방식
  - 이걸 넣으면 "결과를 몇 건까지 보여줄까" 라는 고민 자체가 사라진다
  - 지도를 움직이면 "이 지역에서 재검색" 버튼

`latitude` / `longitude` 는 JSP 가 그대로 읽으므로 남겨두고, `location` 을 나란히 넣는 편이 변경이 적다.

### 🟡 E. 결과 개수 상한

- **검색 시**: `search(keyword, 1, 50)` 으로 상위 50건 상한이 걸려 있다 — 문제 없음
- **빈 검색어**: `getSalons()` 로 빠지는데 여기엔 **상한이 없다.** 미용실이 수백 개가 되면 첫 화면에 전부 그려진다
  - `getSalons()` 는 `/common/home` 도 쓰므로 건드리지 말고, 지도용 상위 N건 메서드를 따로 만들 것

### 🟡 F. 페이징 (홈 검색창을 만들 때)

`search(String keyword, int page, int size)` 로 시그니처는 이미 준비되어 있다. 지도는 페이지 개념이 사용자에게 보이지 않아 `page=1` 고정으로 쓰는 중.

목록형 검색 화면을 만들 때 추가로 필요한 것:

- **총 건수** — 페이지 번호(`1 2 3 …`)를 그리려면 필수. `response.hits().total().value()` 로 얻을 수 있는데 지금은 `List` 만 반환해서 버려진다
- 반환 타입을 `List<SalonVO>` 에서 "결과 + 총 건수" 를 담는 것으로 변경 (학습 가이드의 `PageBean` 역할)
- **지금 미리 만들지 말 것** — 지도는 총 건수가 필요 없어서 쓰는 데가 없다. 실제 화면을 만들 때 호출처가 2곳뿐이라 변경 비용이 작다

`from + size` 는 깊은 페이지에서 느려지고 기본적으로 `from + size > 10000` 이면 에러다(`index.max_result_window`). 그 수준이 되면 `search_after`.

### 🟢 G. 인덱스 운영

- **매핑 변경은 인덱스 재생성이 필요하다.** `createIndexIfNotExists()` 는 인덱스가 있으면 건너뛰므로, 자바 코드의 매핑을 고쳐도 **반영되지 않는다.**
  ```
  curl -X DELETE "http://localhost:9200/salons"   # 후 재기동
  ```
- 운영 중이라면 위 방법은 검색 중단을 부른다. **alias + 새 인덱스 재색인 후 alias 전환** 패턴을 쓸 것
- ES 는 기본 1초마다 refresh 한다. 색인 직후 검색하면 0건이 나올 수 있다(`refresh(Refresh.True)` 로 강제 가능)

### 🟢 H. 설정 / 운영

- 클라이언트 `8.13.4` vs 서버 `8.15.0` 버전 차이. 지금은 동작하지만 맞춰두는 편이 안전
- `elasticsearch.host` / `port` 가 `app.properties` 에 하드코딩. 배포 환경에서는 `upload.path` 처럼 시스템 프로퍼티로 덮어쓸 수 있게 할 것
- 도커 컨테이너가 `Exit 137`(메모리 부족)로 죽은 이력이 있다. 재발하면 `ES_JAVA_OPTS="-Xms512m -Xmx512m"` 로 힙 제한 (컨테이너 재생성 필요)
- ES 가 꺼져 있어도 톰캣은 뜬다(초기화 실패를 `catch` 함). 대신 검색이 안 되므로 헬스체크 수단이 필요

### 🟢 I. 지도 UI

- 결과 목록의 순번 배지(`.salon-list-rank`) — 마커 번호를 뺀 뒤로는 **관련도 순위**를 뜻한다. 유지 여부 미정
- 마커가 수백 개가 되면 카카오맵 `MarkerClusterer` 검토 (현재 데이터 10건 규모에선 불필요)
- 결과 0건일 때 지도는 그대로 두고 안내만 띄우는 현재 동작 유지 중

---

## 3. 검증 방법 메모

```bash
# 색인 건수 (MySQL 미용실 수와 같아야 함)
curl "http://localhost:9200/salons/_count"

# 매핑 확인 — 좌표가 double 인지, 한글 필드에 nori 가 걸렸는지
curl "http://localhost:9200/salons/_mapping?pretty"

# 노리가 어떻게 쪼개는지 (검색이 안 될 때 여기부터 본다)
curl -X POST "http://localhost:9200/_analyze" -H 'Content-Type: application/json' \
     --data-binary "@query.json"
```

> **Git Bash 에서 한글이 깨진다.** `-d '{"text":"강남"}'` 처럼 인라인으로 넘기면 CP949 로 나가서 400 이 난다.
> UTF-8 파일로 저장한 뒤 `--data-binary "@파일"` 로 보낼 것. (자바 클라이언트에서는 발생하지 않는 문제)

비교용 검색어 — LIKE 방식으로는 **0건**, ES 로는 관련도 순 4건이 나온다:

```
강남역 근처 펌 잘하는 미용실
```
