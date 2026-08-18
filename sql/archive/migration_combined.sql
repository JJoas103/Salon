-- d9f69a5 → origin/main 사이에 추가된 마이그레이션 모음
-- 실행: mysql -u root -p salu < sql/migration_combined.sql

CREATE TABLE SalonNotices (
    notice_id INT AUTO_INCREMENT PRIMARY KEY,
    salon_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (salon_id) REFERENCES Salons(salon_id)
);

ALTER TABLE SalonNotices ADD COLUMN image_url VARCHAR(255) NULL AFTER content;

ALTER TABLE Reviews
  ADD COLUMN image_url VARCHAR(255) NULL AFTER comment,
  ADD COLUMN image_url2 VARCHAR(255) NULL AFTER image_url;

CREATE TABLE IF NOT EXISTS Coupons (
    coupon_id        INT AUTO_INCREMENT PRIMARY KEY,
    promotion_id     INT NULL,
    salon_id         INT NULL,
    service_id       INT NULL,
    coupon_name      VARCHAR(100) NOT NULL,
    coupon_code      VARCHAR(50) UNIQUE,
    discount_type    ENUM('percent','amount') NOT NULL,
    discount_value   DECIMAL(10,2) NOT NULL,
    max_discount     DECIMAL(10,2) NULL,
    min_order_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    valid_from       DATE NOT NULL,
    valid_until      DATE NOT NULL,
    issue_type       VARCHAR(20) NOT NULL,
    once_per_user    TINYINT(1) NOT NULL DEFAULT 0,
    is_active        TINYINT(1) NOT NULL DEFAULT 1,
    created_at       DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at       DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (promotion_id) REFERENCES Promotions(promotion_id),
    FOREIGN KEY (salon_id)     REFERENCES Salons(salon_id),
    FOREIGN KEY (service_id)   REFERENCES Services(service_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS User_Coupons (
    user_coupon_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id        INT NOT NULL,
    coupon_id      INT NOT NULL,
    status         ENUM('available','reserved','used','expired') NOT NULL DEFAULT 'available',
    reservation_id INT NULL,
    issued_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    expires_at     DATETIME NOT NULL,
    used_at        DATETIME NULL,
    FOREIGN KEY (user_id)        REFERENCES Users(user_id),
    FOREIGN KEY (coupon_id)      REFERENCES Coupons(coupon_id),
    FOREIGN KEY (reservation_id) REFERENCES Reservations(reservation_id),
    INDEX idx_user_status (user_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET @sql = IF(
    (SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS
      WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'Payments'
        AND CONSTRAINT_NAME = 'fk_payments_user_coupon') = 0,
    'ALTER TABLE Payments ADD CONSTRAINT fk_payments_user_coupon
       FOREIGN KEY (user_coupon_id) REFERENCES User_Coupons(user_coupon_id)',
    'SELECT ''skip: fk_payments_user_coupon 이미 존재'' AS msg');
PREPARE s FROM @sql; EXECUTE s; DEALLOCATE PREPARE s;