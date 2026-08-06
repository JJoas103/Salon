ALTER TABLE Users ADD COLUMN point_balance INT NOT NULL DEFAULT 0;

CREATE TABLE Point_Transactions (
    point_tx_id    INT AUTO_INCREMENT PRIMARY KEY,
    user_id        INT NOT NULL,
    reservation_id INT NULL,
    tx_type        ENUM('earn','use','restore','revoke','expire','admin') NOT NULL,
    amount         INT NOT NULL,          -- 부호 있음: 적립 +, 사용 -
    balance_after  INT NOT NULL,
    description    VARCHAR(255),
    expires_at     DATETIME NULL,
    created_at     DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id)        REFERENCES Users(user_id),
    FOREIGN KEY (reservation_id) REFERENCES Reservations(reservation_id),
    INDEX idx_user_created (user_id, created_at),
    -- 같은 예약에 같은 종류의 원장이 두 번 쌓이지 않는다. 중복 적립/중복 원복을 DB 가 막는다.
    UNIQUE KEY uq_reservation_tx (reservation_id, tx_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;