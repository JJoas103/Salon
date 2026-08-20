-- 점주 예약현황관리: 예약 취소 사유 + 취소 유형
--
-- 점주가 확정(confirmed)된 예약을 정리하면 status 는 cancelled 로 바뀌고,
--   reject_reason : 사유 텍스트
--   cancel_type   : 어떤 성격의 취소인지 ('rejected' = 점주 거절+환불 / 'no_show' = 노쇼+환불없음)
-- 가 남는다.
--
-- 구분 정리:
--   cancelled + cancel_type='rejected'  → 점주가 부득이 취소하고 환불해 준 건
--   cancelled + cancel_type='no_show'   → 손님이 오지 않아 노쇼로 마감(선불 금액은 매장 정산)
--   cancelled + cancel_type IS NULL     → 결제 실패/이탈로 자리만 비운 건 (reject_reason 도 NULL)
-- (손님 자가 취소가 생기면 'customer' 같은 값을 여기에 추가하면 된다)
--
-- 실행: mysql -u root -p salu < sql/migration_reservation_reject.sql

ALTER TABLE Reservations
    ADD COLUMN reject_reason VARCHAR(255) NULL DEFAULT NULL AFTER status;

ALTER TABLE Reservations
    ADD COLUMN cancel_type VARCHAR(20) NULL DEFAULT NULL AFTER reject_reason;
