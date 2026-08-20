-- 매장 등록 2단계 관리자 승인 — 1차(점주 승격 승인)는 기존 그대로,
-- 여기서는 손님에게 실제로 보이는지(2차 승인 여부)만 추가한다.
-- 기존 매장은 전부 이미 정상 운영 중이었으므로 DEFAULT 'active'로 소급 처리된다.
-- 실행: mysql -u root -p salu < sql/migration_salon_activation.sql

ALTER TABLE Salons
  ADD COLUMN activation_status ENUM('preparing','active') NOT NULL DEFAULT 'active' AFTER closed_at;
