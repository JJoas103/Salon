-- 고객 알림함 (예약 상태변경 · 쿠폰발급 · 채팅 새메시지 · 매장 신규 공지사항)
-- ref_id 는 type 에 따라 가리키는 테이블이 달라 FK 를 걸지 않는다 (다형성 참조:
--   RESERVATION -> Reservations.reservation_id, COUPON -> User_Coupons.user_coupon_id,
--   CHAT -> Chats.chat_id, NOTICE -> SalonNotices.notice_id)
-- notifications_enabled(마이페이지 알림 설정 토글)가 꺼져 있으면 4곳의 트리거 모두 insert 자체를 건너뛴다.
-- 실행: mysql -u root -p salu < sql/migration_notifications.sql

CREATE TABLE IF NOT EXISTS Notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id      INT NOT NULL,                                          -- 알림 받는 사람 (고객)
    type         ENUM('RESERVATION','COUPON','CHAT','NOTICE') NOT NULL,
    title        VARCHAR(100) NOT NULL,
    message      VARCHAR(255) NOT NULL,
    link_url     VARCHAR(255),                                          -- 클릭 시 이동 경로
    ref_id       INT,                                                   -- type별 원본 PK
    is_read      TINYINT(1) NOT NULL DEFAULT 0,
    created_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    INDEX idx_user_unread (user_id, is_read, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
