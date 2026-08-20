-- 마이페이지 "알림 설정" on/off 토글 저장용
-- 실행: mysql -u root -p salu < sql/migration_notifications_enabled.sql

ALTER TABLE Users
  ADD COLUMN notifications_enabled TINYINT(1) NOT NULL DEFAULT 1 AFTER status;
