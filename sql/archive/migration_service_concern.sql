-- ============================================================
--  2026-08-12  Services 에 concern 추가
--  AI 시술 추천 챗봇의 하이브리드 검색(concerns^2 부스트)이 참조하는 필드.
--  schema.sql / migration_catchup.sql 에 이미 통합되어 있다. 이 파일은 이력 보존용.
-- ============================================================
ALTER TABLE Services ADD COLUMN concern VARCHAR(255) NULL AFTER description;
