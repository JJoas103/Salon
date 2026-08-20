-- 관리자 매장관리: 매장 운영상태(운영중/폐업)
-- Salons.closed_at 이 NULL 이면 운영중, 값이 있으면 폐업.
-- Users.deleted_at 과 동일 패턴 (하드 delete 대신 soft delete) —
-- Services/Stylists/Reservations/Reviews/Salon_Operating_Hours/Wishlists/Posts/Promotions
-- 8개 테이블이 salon_id 를 ON DELETE CASCADE 없이 참조하고 있어 하드 delete는 FK 에러가 남.
-- 실행: mysql -u root -p salu < sql/migration_salon_status.sql

ALTER TABLE Salons
    ADD COLUMN closed_at DATETIME NULL DEFAULT NULL AFTER updated_at;
