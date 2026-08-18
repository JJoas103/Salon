-- 점주가 매장을 추가로 등록 요청할 수 있게, 기존 "고객→점주 승격" 요청과 구분하는 컬럼 추가.
-- 기존 행은 전부 승격 요청이었으므로 DEFAULT 'promotion'으로 채워진다.
-- 실행: mysql -u root -p salu < sql/migration_owner_request_type.sql

ALTER TABLE OwnerRequests
  ADD COLUMN request_type ENUM('promotion','additional_salon') NOT NULL DEFAULT 'promotion' AFTER message;
