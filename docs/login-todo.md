# 로그인 / 회원가입 기능 — 진행 상황

> 다음 대화(세션)에서 이어서 작업하기 위한 메모입니다. 팀 전체 로드맵이 아니라
> **로그인/회원가입(`feature/auth`) 담당자 기준**으로만 작성합니다.
> 조장이 없어서 예약/점주센터/관리자 등 다른 기능의 우선순위는 여기서 다루지 않습니다.

## 브랜치
`feature/auth`

## 지금까지 구현된 것
- 회원가입: `/user/join` (GET 폼 / POST 제출) — `UserController.joinForm/joinSubmit`
- 회원가입 검증(`UserValidator`): 이메일/비밀번호/이름 필수, 이메일 형식, 비밀번호 8자 이상,
  비밀번호 확인 일치, 전화번호 형식(`010-1234-5678`)
- 비밀번호는 `UserService.join()`에서 BCrypt로 암호화 후 저장
- 로그인: `/user/login` — Spring Security 폼 로그인(`SecurityConfig`), 파라미터명 `userEmail`/`userPassword`
- 권한: `UserDetailService`가 `Users.user_type` 값을 `ADMIN`/`OWNER`/`CUSTOMER` 롤로 변환

## 현재 작업 중 (uncommitted)
- `join.jsp`에 "비밀번호 확인" 입력란 추가
- `UserVO.confirmPassword` 필드 추가 (DB 미저장, 폼 검증 전용)
- `UserValidator`에 비밀번호 확인 일치 검증 추가
- `join.jsp`에 JS 실시간 일치 확인 (`.error-text`/`.input-error` 사용) — **화면 표시는 아직 JS만, 서버 검증 결과 표시는 미구현**
- `common.css`에 `--danger`/`--container-max` 토큰 + `.error-text`/`.input-error` 유틸 흡수 (출처: `styles/modern-common.css`)
- `join.jsp`/`login.jsp` 상호 링크를 목업(`login.html`/`signup.html`) → 실제 라우트(`/user/login`, `/user/join`)로 수정
- `styles/modern-common.css`는 삭제하지 않고 **참고용으로 keep** (대시보드 계열 컴포넌트 출처, CLAUDE.md에 명시)
- `.gitignore`에 `deploy.sh` 추가 — 커밋 전에 팀과 공유해도 되는 스크립트인지 확인

## 완료 (uncommitted, git add 전)
- [x] 이메일 중복확인: `UserController.checkEmail` (`GET /user/check-email`) 추가,
      `join.jsp`에 "중복확인" 버튼 + fetch로 연결, 결과는 `.success-text`/`.error-text`로 표시
- [x] 로그인 실패 메시지: `login.jsp`가 `${param.error}` 읽어서 `.auth-alert` 배너로 표시
- [x] 회원가입 폼 `userType` 라디오 값을 `customer`/`owner`(소문자)로 통일 — DB enum과 일치
- [x] `join.jsp` 이메일 줄(`.email-row`) 아래 여백 없던 것 수정 (`margin-bottom: 16px` 추가, auth.css)

- [x] 이메일 중복확인 서버 재검증: `UserValidator`에 `UserService` 주입, `joinUser`일 때
      형식 통과한 이메일에 한해 `isEmailAvailable()` 재조회 → 중복이면 `email.duplicate`로 reject.
      "중복확인" 버튼 없이 강제 제출해도 이제 `joinSubmit`의 `result.hasErrors()`에서 막힘 (insert 안 됨)
- [x] `join.jsp` 이메일 중복 메시지가 입력칸과 붙어야 하는데 사이 여백이 생기던 문제 —
      `.email-row`가 아니라 그걸 감싸는 `<div class="form-field-email">`에 `margin-bottom:16px`을 줘서
      해결 (auth.css). row 자체엔 마진 없음 → 메시지가 바로 아래 붙고, 다음 필드와의 간격은 유지

## 다음에 확인/진행할 것
- [ ] **(설계 논의) 회원가입은 일반 회원만** — `join.jsp`의 "매장 점주" 라디오를 없애고 가입은
      항상 `user_type = customer`로 시작, 점주 전환은 로그인 후 "가맹점 등록" 같은 별도 기능에서
      처리하는 방향으로 의견 나옴. DB가 `Users` 단일 테이블 + `user_type` enum 구조라 이 방식과도
      잘 맞음 (점주 전환 시 `user_type` UPDATE + `Salons` insert). 아직 구현 안 함 — 다음 세션에서 진행
- [ ] `OWNER`로 가입할 때 매장(`Salons`) 정보를 입력받는 흐름이 없음 —
      위 항목과 같은 논의: 점주 가입 후 매장 등록을 어떻게 이어붙일지 결정 필요
- [ ] 회원정보 수정/탈퇴: `UserMapper.updateUser`/`deleteById`는 매퍼에 있지만 서비스/컨트롤러 미구현
- [ ] 테스트 코드 없음 (수동 확인만 하는 중)
- [ ] 위 "완료" 항목들 git add/commit 하기 (db.properties는 `skip-worktree` 걸어놔서 status에 안 뜸,
      실수로 딸려갈 걱정 없음)

## 참고
- 전체 아키텍처/컨벤션: `CLAUDE.md`
- 다른 기능(예약/점주센터/관리자 등)의 진행상황 문서는 담당자가 정해지면 각자 추가
