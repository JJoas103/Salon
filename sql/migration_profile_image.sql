-- 일반사용자 마이페이지 프로필 사진
-- 실행: mysql -u root -p salu < sql/migration_profile_image.sql

ALTER TABLE Users
  ADD COLUMN profile_image_url VARCHAR(255) NULL DEFAULT NULL AFTER phone_number;
