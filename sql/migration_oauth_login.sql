-- 구글/네이버 소셜 로그인
-- 소셜 전용 계정은 로컬 비밀번호가 없으므로 password를 NULL 허용으로 바꾸고,
-- 로그인 수단을 구분하는 provider/provider_id를 추가한다.
-- 이메일이 같은 기존 로컬 계정으로 소셜 로그인하면 provider/provider_id만 갱신해 자동 연동한다(계정 분리 없음).
-- 실행: mysql -u root -p salu < sql/migration_oauth_login.sql

ALTER TABLE Users
    MODIFY COLUMN password VARCHAR(255) NULL;

ALTER TABLE Users
    ADD COLUMN provider ENUM('local', 'google', 'naver') NOT NULL DEFAULT 'local' AFTER user_type,
    ADD COLUMN provider_id VARCHAR(255) NULL AFTER provider;

-- MySQL은 UNIQUE 제약에서 NULL끼리는 중복으로 보지 않으므로,
-- provider_id가 NULL인 기존 로컬 계정들끼리는 충돌하지 않는다.
ALTER TABLE Users
    ADD UNIQUE KEY uq_users_provider_id (provider, provider_id);
