-- ============================================================
--  salu 스키마 catch-up (기존 DB 를 최신 schema.sql 과 같은 상태로 맞춘다)
--
--  실행:  mysql --default-character-set=utf8mb4 -u root -p salu < sql/migration_catchup.sql
--         (Windows 클라이언트는 기본 charset 이 cp949 라 옵션을 빼면 한글이 깨진다)
--
--  누구를 위한 파일인가
--    - 새로 DB 를 만드는 사람  → 이 파일 말고 sql/schema.sql 을 실행한다
--    - 이미 DB 가 있는 사람    → 이 파일을 실행한다
--    두 파일은 같은 최종 스키마를 만든다. schema.sql 을 고쳤으면 이 파일도 같이 고친다.
--
--  몇 번 실행해도 안전하다 (멱등)
--    이미 있는 컬럼/테이블/제약은 건너뛴다. 그래서 "내 DB 가 어느 시점인지"
--    몰라도 그냥 실행하면 된다. 7/28 이후의 모든 스키마 변경이 들어있다.
--
--  MySQL 8.0 은 ALTER TABLE ... ADD COLUMN IF NOT EXISTS 를 지원하지 않아서
--  (MariaDB 전용 문법) information_schema 를 보고 분기하는 프로시저를 쓴다.
--
--  데이터 전용 스크립트는 여기에 없다. 필요하면 따로 실행:
--    sql/archive/restore_original_salons_utf8.sql, sql/salon_coordinates.sql,
--    sql/seed_operating_hours.sql
-- ============================================================

SET NAMES utf8mb4;

-- ---------- 멱등 헬퍼 ----------
DROP PROCEDURE IF EXISTS salu_add_column;
DROP PROCEDURE IF EXISTS salu_add_constraint;
DROP PROCEDURE IF EXISTS salu_add_fk;

DELIMITER $$

CREATE PROCEDURE salu_add_column(IN p_table VARCHAR(64), IN p_column VARCHAR(64), IN p_ddl TEXT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS
                    WHERE TABLE_SCHEMA = DATABASE()
                      AND TABLE_NAME = p_table
                      AND COLUMN_NAME = p_column) THEN
        SET @s = CONCAT('ALTER TABLE `', p_table, '` ADD COLUMN ', p_ddl);
        PREPARE st FROM @s; EXECUTE st; DEALLOCATE PREPARE st;
    END IF;
END$$

CREATE PROCEDURE salu_add_constraint(IN p_table VARCHAR(64), IN p_name VARCHAR(64), IN p_ddl TEXT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.TABLE_CONSTRAINTS
                    WHERE TABLE_SCHEMA = DATABASE()
                      AND TABLE_NAME = p_table
                      AND CONSTRAINT_NAME = p_name) THEN
        SET @s = CONCAT('ALTER TABLE `', p_table, '` ADD CONSTRAINT `', p_name, '` ', p_ddl);
        PREPARE st FROM @s; EXECUTE st; DEALLOCATE PREPARE st;
    END IF;
END$$

-- FK 는 이름이 아니라 "그 컬럼에 FK 가 걸려 있는가" 로 판단한다.
-- 예전 schema.sql 은 Posts.salon_id FK 를 CONSTRAINT 이름 없이 선언했어서
-- (자동 이름이 붙는다) 이름으로만 검사하면 같은 FK 를 한 번 더 추가하게 된다.
CREATE PROCEDURE salu_add_fk(IN p_table VARCHAR(64), IN p_column VARCHAR(64),
                            IN p_name VARCHAR(64), IN p_ddl TEXT)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.KEY_COLUMN_USAGE
                    WHERE TABLE_SCHEMA = DATABASE()
                      AND TABLE_NAME = p_table
                      AND COLUMN_NAME = p_column
                      AND REFERENCED_TABLE_NAME IS NOT NULL) THEN
        SET @s = CONCAT('ALTER TABLE `', p_table, '` ADD CONSTRAINT `', p_name, '` ', p_ddl);
        PREPARE st FROM @s; EXECUTE st; DEALLOCATE PREPARE st;
    END IF;
END$$

DELIMITER ;

-- ============================================================
--  2026-07-28  migration_community.sql
-- ============================================================
CALL salu_add_column('Posts', 'image_url',     'image_url VARCHAR(255) AFTER category');
CALL salu_add_column('Posts', 'salon_id',      'salon_id INT AFTER image_url');
CALL salu_add_column('Posts', 'like_count',    'like_count INT DEFAULT 0 AFTER view_count');
CALL salu_add_column('Posts', 'dislike_count', 'dislike_count INT DEFAULT 0 AFTER like_count');
CALL salu_add_column('Posts', 'report_count',  'report_count INT DEFAULT 0 AFTER dislike_count');
CALL salu_add_column('Posts', 'status',
    "status ENUM('visible', 'blinded') DEFAULT 'visible' AFTER report_count");
CALL salu_add_fk('Posts', 'salon_id', 'fk_posts_salon',
    'FOREIGN KEY (salon_id) REFERENCES Salons(salon_id)');

CALL salu_add_column('Salons', 'latitude',  'latitude DECIMAL(10,7)');
CALL salu_add_column('Salons', 'longitude', 'longitude DECIMAL(10,7)');

CALL salu_add_column('Users', 'deleted_at', 'deleted_at DATETIME NULL DEFAULT NULL AFTER updated_at');
CALL salu_add_column('Users', 'status',
    "status ENUM('active', 'suspended', 'banned') DEFAULT 'active'");
CALL salu_add_column('Users', 'suspended_until', 'suspended_until DATETIME NULL');

CREATE TABLE IF NOT EXISTS post_likes (
    like_id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    reaction_type ENUM('like', 'dislike') NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_post_user (post_id, user_id),
    FOREIGN KEY (post_id) REFERENCES Posts(post_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

CREATE TABLE IF NOT EXISTS post_reports (
    report_id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    reason ENUM('spam', 'illegal', 'abuse', 'privacy', 'other') NOT NULL DEFAULT 'other',
    reason_detail VARCHAR(255),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_post_user (post_id, user_id),
    FOREIGN KEY (post_id) REFERENCES Posts(post_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);
-- 신고 사유 없이 만들어진 구버전 테이블 보강
CALL salu_add_column('post_reports', 'reason',
    "reason ENUM('spam', 'illegal', 'abuse', 'privacy', 'other') NOT NULL DEFAULT 'other'");
CALL salu_add_column('post_reports', 'reason_detail', 'reason_detail VARCHAR(255)');

CREATE TABLE IF NOT EXISTS comment_reports (
    report_id INT AUTO_INCREMENT PRIMARY KEY,
    comment_id INT NOT NULL,
    user_id INT NOT NULL,
    reason ENUM('spam', 'illegal', 'abuse', 'privacy', 'other') NOT NULL DEFAULT 'other',
    reason_detail VARCHAR(255),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_comment_user (comment_id, user_id),
    FOREIGN KEY (comment_id) REFERENCES Comments(comment_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

CREATE TABLE IF NOT EXISTS user_sanctions (
    sanction_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    post_id INT,
    post_title VARCHAR(255),
    comment_id INT,
    comment_content TEXT,
    admin_reason VARCHAR(255),
    sanction_type ENUM('suspend_3d', 'suspend_7d', 'permanent') NOT NULL,
    suspended_until DATETIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);
-- 게시글 제재만 있던 구버전 테이블 보강
CALL salu_add_column('user_sanctions', 'comment_id',      'comment_id INT AFTER post_title');
CALL salu_add_column('user_sanctions', 'comment_content', 'comment_content TEXT AFTER comment_id');
CALL salu_add_column('user_sanctions', 'admin_reason',    'admin_reason VARCHAR(255) AFTER comment_content');

-- ============================================================
--  2026-07-29  migration_advertisements.sql
-- ============================================================
CREATE TABLE IF NOT EXISTS Advertisements (
    advertisement_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    description VARCHAR(500),
    image_url VARCHAR(500) NOT NULL,
    target_url VARCHAR(1000),
    display_order INT NOT NULL DEFAULT 0,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    start_at DATETIME NULL,
    end_at DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_advertisements_exposure (active, start_at, end_at, display_order),
    CONSTRAINT chk_advertisements_period
        CHECK (end_at IS NULL OR start_at IS NULL OR end_at >= start_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
--  2026-07-30  migration_owner_request.sql
-- ============================================================
CREATE TABLE IF NOT EXISTS OwnerRequests (
    request_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    salon_name VARCHAR(255) NOT NULL,
    salon_phone VARCHAR(20),
    message TEXT,
    status ENUM('pending','approved','rejected') NOT NULL DEFAULT 'pending',
    requested_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    processed_at DATETIME NULL,
    processed_by INT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (processed_by) REFERENCES Users(user_id)
);

-- ============================================================
--  2026-07-30  migration_salon_status.sql
-- ============================================================
CALL salu_add_column('Salons', 'closed_at', 'closed_at DATETIME NULL DEFAULT NULL AFTER updated_at');

-- ============================================================
--  2026-07-31  migration_chats.sql
--  주의: salon_id 는 NOT NULL 이다. Chats 에 이미 행이 있는 DB 라면
--        salon_id 가 0 으로 채워져 FK 추가가 실패한다.
--        그런 경우엔 기존 채팅방을 지우고(개발 데이터) 다시 실행한다:
--            DELETE FROM Messages; DELETE FROM Chats;
-- ============================================================
CALL salu_add_column('Chats', 'salon_id', 'salon_id INT NOT NULL AFTER user2_id');
CALL salu_add_fk('Chats', 'salon_id', 'fk_chats_salon',
    'FOREIGN KEY (salon_id) REFERENCES Salons(salon_id)');
CALL salu_add_constraint('Chats', 'uq_chats_customer_salon', 'UNIQUE (user1_id, salon_id)');

CALL salu_add_column('Messages', 'is_read', 'is_read TINYINT(1) NOT NULL DEFAULT 0 AFTER message_content');

-- ============================================================
--  2026-08-04  migration_payment.sql
--  amount = original_amount - coupon_discount - point_used
-- ============================================================
CALL salu_add_column('Payments', 'original_amount', 'original_amount DECIMAL(10,2) NOT NULL DEFAULT 0');
CALL salu_add_column('Payments', 'coupon_discount', 'coupon_discount DECIMAL(10,2) NOT NULL DEFAULT 0');
CALL salu_add_column('Payments', 'point_used',      'point_used INT NOT NULL DEFAULT 0');
CALL salu_add_column('Payments', 'pg_provider',     "pg_provider VARCHAR(20) NOT NULL DEFAULT 'KAKAOPAY'");
CALL salu_add_column('Payments', 'user_coupon_id',  'user_coupon_id INT NULL');

-- 컬럼 추가 이전의 결제건은 할인 없이 정가로 결제된 것으로 본다
UPDATE Payments SET original_amount = amount WHERE original_amount = 0;

-- ============================================================
--  2026-08-05  migration_salon_notices.sql (+ _image)
-- ============================================================
CREATE TABLE IF NOT EXISTS SalonNotices (
    notice_id INT AUTO_INCREMENT PRIMARY KEY,
    salon_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    image_url VARCHAR(255) NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (salon_id) REFERENCES Salons(salon_id)
);
CALL salu_add_column('SalonNotices', 'image_url', 'image_url VARCHAR(255) NULL AFTER content');

-- ============================================================
--  2026-08-05  migration_reviews_images.sql
-- ============================================================
CALL salu_add_column('Reviews', 'image_url',  'image_url VARCHAR(255) NULL AFTER comment');
CALL salu_add_column('Reviews', 'image_url2', 'image_url2 VARCHAR(255) NULL AFTER image_url');

-- ============================================================
--  2026-08-05  migration_Point.sql
-- ============================================================
CALL salu_add_column('Users', 'point_balance', 'point_balance INT NOT NULL DEFAULT 0');

CREATE TABLE IF NOT EXISTS Point_Transactions (
    point_tx_id    INT AUTO_INCREMENT PRIMARY KEY,
    user_id        INT NOT NULL,
    reservation_id INT NULL,
    tx_type        ENUM('earn','use','restore','revoke','expire','admin') NOT NULL,
    amount         INT NOT NULL,
    balance_after  INT NOT NULL,
    description    VARCHAR(255),
    expires_at     DATETIME NULL,
    created_at     DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id)        REFERENCES Users(user_id),
    FOREIGN KEY (reservation_id) REFERENCES Reservations(reservation_id),
    INDEX idx_user_created (user_id, created_at),
    UNIQUE KEY uq_reservation_tx (reservation_id, tx_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
--  2026-08-06  migration_reservation_reject.sql
--  점주가 확정된 예약을 정리할 때 남는 취소 사유 + 취소 유형
-- ============================================================
CALL salu_add_column('Reservations', 'reject_reason',
    'reject_reason VARCHAR(255) NULL DEFAULT NULL AFTER status');
CALL salu_add_column('Reservations', 'cancel_type',
    'cancel_type VARCHAR(20) NULL DEFAULT NULL AFTER reject_reason');

-- ============================================================
--  2026-08-10  migration_coupon.sql
-- ============================================================
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

-- 컬럼은 위 migration_payment 단계에서 만들었다. 참조할 테이블이 이제 생겼으므로 FK 만 붙인다.
CALL salu_add_fk('Payments', 'user_coupon_id', 'fk_payments_user_coupon',
    'FOREIGN KEY (user_coupon_id) REFERENCES User_Coupons(user_coupon_id)');

-- ============================================================
--  2026-08-12  migration_service_category.sql
-- ============================================================
CALL salu_add_column('Services', 'category', 'category VARCHAR(20) NULL AFTER service_name');

-- ============================================================
--  2026-08-12  migration_service_concern.sql
-- ============================================================
CALL salu_add_column('Services', 'concern', 'concern VARCHAR(255) NULL AFTER description');

-- ============================================================
--  2026-08-14  migration_oauth_login.sql
-- ============================================================
ALTER TABLE Users MODIFY COLUMN password VARCHAR(255) NULL;
CALL salu_add_column('Users', 'provider',
    "provider ENUM('local', 'google', 'naver') NOT NULL DEFAULT 'local' AFTER user_type");
CALL salu_add_column('Users', 'provider_id', 'provider_id VARCHAR(255) NULL AFTER provider');
CALL salu_add_constraint('Users', 'uq_users_provider_id', 'UNIQUE KEY (provider, provider_id)');

-- ============================================================
--  2026-08-16  migration_salon_activation.sql
-- ============================================================
CALL salu_add_column('Salons', 'activation_status',
    "activation_status ENUM('preparing','active') NOT NULL DEFAULT 'active' AFTER closed_at");

-- ============================================================
--  2026-08-18  migration_owner_request_type.sql
-- ============================================================
CALL salu_add_column('OwnerRequests', 'request_type',
    "request_type ENUM('promotion','additional_salon') NOT NULL DEFAULT 'promotion' AFTER message");

-- ============================================================
--  2026-08-19  migration_profile_image.sql
-- ============================================================
CALL salu_add_column('Users', 'profile_image_url',
    'profile_image_url VARCHAR(255) NULL DEFAULT NULL AFTER phone_number');

-- ============================================================
--  2026-08-20  migration_my_community.sql / migration_comment_log.sql
-- ============================================================
CALL salu_add_column('Users', 'last_reply_check_at',
    'last_reply_check_at DATETIME NULL AFTER point_balance');
ALTER TABLE Posts
    MODIFY COLUMN status ENUM('visible', 'blinded', 'deleted') DEFAULT 'visible';

-- ============================================================
--  2026-08-21  migration_notifications.sql (+ _enabled)
-- ============================================================
CALL salu_add_column('Users', 'notifications_enabled',
    'notifications_enabled TINYINT(1) NOT NULL DEFAULT 1 AFTER status');

CREATE TABLE IF NOT EXISTS Notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id      INT NOT NULL,
    type         ENUM('RESERVATION','COUPON','CHAT','NOTICE') NOT NULL,
    title        VARCHAR(100) NOT NULL,
    message      VARCHAR(255) NOT NULL,
    link_url     VARCHAR(255),
    ref_id       INT,
    is_read      TINYINT(1) NOT NULL DEFAULT 0,
    created_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    INDEX idx_user_unread (user_id, is_read, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------- 헬퍼 정리 ----------
DROP PROCEDURE IF EXISTS salu_add_column;
DROP PROCEDURE IF EXISTS salu_add_constraint;
DROP PROCEDURE IF EXISTS salu_add_fk;
