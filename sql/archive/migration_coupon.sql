-- ---------- 쿠폰 정책 ----------
CREATE TABLE IF NOT EXISTS Coupons (
    coupon_id        INT AUTO_INCREMENT PRIMARY KEY,
    promotion_id     INT NULL,                              -- 이 쿠폰을 광고하는 프로모션(선택)
    salon_id         INT NULL,                              -- NULL = 전 매장 공통
    service_id       INT NULL,                              -- NULL = 전 시술 공통
    coupon_name      VARCHAR(100) NOT NULL,
    coupon_code      VARCHAR(50) UNIQUE,                    -- NULL = 코드 입력형이 아님
    discount_type    ENUM('percent','amount') NOT NULL,
    discount_value   DECIMAL(10,2) NOT NULL,                -- percent 면 10.00 = 10%
    max_discount     DECIMAL(10,2) NULL,                    -- percent 형의 상한 (NULL = 무제한)
    min_order_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    valid_from       DATE NOT NULL,
    valid_until      DATE NOT NULL,
    -- 발급 경로. 앞으로 등급 기반 등이 늘어날 자리라 ENUM 대신 VARCHAR 로 둔다
    -- (ENUM 은 값을 추가할 때마다 ALTER TABLE MODIFY 가 필요하다)
    issue_type       VARCHAR(20) NOT NULL,                  -- signup / admin / code ...
    -- 관리자가 정책을 만들 때 체크한다. 1 이면 한 회원에게 한 번만 발급된다.
    -- 이미 사용한 쿠폰이 있어도 재발급하지 않는다 — 그러지 않으면 1인 1매의 의미가 없다.
    once_per_user    TINYINT(1) NOT NULL DEFAULT 0,
    is_active        TINYINT(1) NOT NULL DEFAULT 1,
    created_at       DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at       DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (promotion_id) REFERENCES Promotions(promotion_id),
    FOREIGN KEY (salon_id)     REFERENCES Salons(salon_id),
    FOREIGN KEY (service_id)   REFERENCES Services(service_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------- 사용자가 보유한 쿠폰 ----------
CREATE TABLE IF NOT EXISTS User_Coupons (
    user_coupon_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id        INT NOT NULL,
    coupon_id      INT NOT NULL,
    -- available → reserved(결제 시작) → used(승인 성공)
    --                  └──────────────→ available (취소·실패)
    status         ENUM('available','reserved','used','expired') NOT NULL DEFAULT 'available',
    reservation_id INT NULL,                                -- reserved/used 일 때 어느 예약에 묶였는지
    issued_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    -- 발급 시점에 Coupons.valid_until 을 복사한다. 정책의 기간을 나중에 줄여도
    -- 이미 나간 쿠폰의 유효기간이 소급해서 바뀌면 안 된다.
    expires_at     DATETIME NOT NULL,
    used_at        DATETIME NULL,
    FOREIGN KEY (user_id)        REFERENCES Users(user_id),
    FOREIGN KEY (coupon_id)      REFERENCES Coupons(coupon_id),
    FOREIGN KEY (reservation_id) REFERENCES Reservations(reservation_id),
    INDEX idx_user_status (user_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------- Payments.user_coupon_id 에 FK ----------
-- 컬럼은 migration_payment.sql 에서 이미 만들었다. 참조할 테이블이 이제 생겼으므로 FK 만 붙인다.
SET @sql = IF(
    (SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS
      WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'Payments'
        AND CONSTRAINT_NAME = 'fk_payments_user_coupon') = 0,
    'ALTER TABLE Payments ADD CONSTRAINT fk_payments_user_coupon
       FOREIGN KEY (user_coupon_id) REFERENCES User_Coupons(user_coupon_id)',
    'SELECT ''skip: fk_payments_user_coupon 이미 존재'' AS msg');
PREPARE s FROM @sql; EXECUTE s; DEALLOCATE PREPARE s;