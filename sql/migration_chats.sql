-- ============================================================
-- 1:1 상담 채팅 (feature/websocket)
-- 규칙: Chats.user1_id = 고객, user2_id = 점주  ← 순서 고정
--       이 순서를 지켜야 UNIQUE 제약과 단일 조건 조회가 성립한다
-- ============================================================

ALTER TABLE Chats
  ADD COLUMN salon_id INT NOT NULL AFTER user2_id,                    -- 어느 매장 문의인지
  ADD CONSTRAINT fk_chats_salon
      FOREIGN KEY (salon_id) REFERENCES Salons(salon_id),
  ADD CONSTRAINT uq_chats_customer_salon
      UNIQUE (user1_id, salon_id);                                    -- 고객+매장당 방 하나

ALTER TABLE Messages
  ADD COLUMN is_read TINYINT(1) NOT NULL DEFAULT 0 AFTER message_content;  -- 안읽음 배지용