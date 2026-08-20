-- AI 시술 추천 챗봇(ai-service) 연동: 시술 카테고리 필터링용 컬럼
-- 컷/펌/염색/클리닉/세트 5종 고정값이지만, 추후 값이 늘어날 수 있어
-- ENUM 대신 VARCHAR 로 둔다 (issue_type 과 동일한 이유, migration_coupon.sql 참고)
-- 값이 없는 기존 시술은 필터 대상에서만 제외되면 되므로 NULL 허용
-- 실행: mysql -u root -p salu < sql/migration_service_category.sql

ALTER TABLE Services
    ADD COLUMN category VARCHAR(20) NULL AFTER service_name;
