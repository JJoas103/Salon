-- ============================================================
--  salu (미용실 예약 플랫폼) 스키마
--  MySQL 8.0 / utf8mb4
--  실행:  mysql -u root -p < sql/schema.sql
--
--  이 파일은 "지금 시점의 완성된 스키마" 하나만 담는다.
--  새 DB 를 만들 때는 이 파일만 실행하면 되고, 아래 마이그레이션들을
--  따로 실행할 필요는 없다 (이미 전부 반영되어 있다).
-- ============================================================
--  반영된 마이그레이션 이력 (적용 순서대로)
--
--   1. 2026-07-27  restore_original_salons_utf8.sql
--                  → 더미데이터 한글 복구. 스키마 변경 없음(데이터 전용)
--   2. 2026-07-28  migration_community.sql
--                  → Posts 에 image_url / salon_id / like_count / dislike_count
--                  → post_likes 테이블 신설
--                  → Salons 에 latitude / longitude
--                  → Users 에 deleted_at (회원 탈퇴 soft delete)
--   3. 2026-07-28  salon_coordinates.sql
--                  → 더미 미용실 좌표 채우기. 스키마 변경 없음(데이터 전용)
--   4. 2026-07-29  migration_advertisements.sql
--                  → Advertisements 테이블 신설 (관리자 광고 슬라이드 배너)
--   5. 2026-08-11  migration_payment.sql
--                  → Payments 에 original_amount / coupon_discount / point_used / pg_provider / user_coupon_id
--   6. 2026-08-11  migration_coupon.sql
--                  → Coupons / User_Coupons 테이블 신설, Payments.user_coupon_id 에 FK
--   7. 2026-08-11  migration_reservation_reject.sql
--                  → Reservations 에 reject_reason / cancel_type (점주 예약 거절·노쇼 처리)
--   8. 2026-08-11  migration_Point.sql
--                  → Users 에 point_balance, Point_Transactions 테이블 신설
--
--  기존 마이그레이션 파일은 진행 이력으로 sql/ 에 그대로 남겨둔다.
--  앞으로 스키마를 바꿀 때도 같은 방식으로:
--    (1) 팀원은 migration_*.sql 을 새로 만들어 올린다 (기존 DB 를 갱신하는 용도)
--    (2) 이 파일로의 통합과 위 이력 갱신은 팀장이 한다
--  두 곳이 어긋나면 새로 DB 를 만든 사람만 기능이 깨져서 원인을 찾기 어렵다.
-- ============================================================

CREATE DATABASE IF NOT EXISTS salu
    DEFAULT CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE salu;

-- ---------- Users (사용자) ----------
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,               -- 사용자 고유 식별자
    email VARCHAR(255) UNIQUE NOT NULL,                   -- 이메일 (로그인 ID)
    password VARCHAR(255) NOT NULL,                       -- 비밀번호
    user_name VARCHAR(100),
    phone_number VARCHAR(20),
    user_type ENUM('customer', 'owner', 'admin') NOT NULL, -- 사용자 유형 (고객, 점주, 관리자)
    status ENUM('active', 'suspended', 'banned') DEFAULT 'active', -- 커뮤니티 이용 제한 상태
    suspended_until DATETIME NULL,                          -- 정지 만료 시각 (영구정지면 NULL)
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL DEFAULT NULL,                -- 탈퇴 일시 (NULL 이면 활성 회원. 행을 지우지 않는 soft delete)
    point_balance INT NOT NULL DEFAULT 0,                 -- 포인트 잔액
    last_reply_check_at DATETIME NULL                     -- 마이페이지 "내 글에 달린 댓글" 탭 마지막 확인 시각 (안읽음 배지용)
);

-- ---------- Salons (미용실) ----------
CREATE TABLE Salons (
    salon_id INT AUTO_INCREMENT PRIMARY KEY,
    owner_id INT NOT NULL,
    salon_name VARCHAR(255) NOT NULL,
    address VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20),
    description TEXT,
    average_rating DECIMAL(2,1) DEFAULT 0.0,
    image_url VARCHAR(255),
    latitude DECIMAL(10,7),   -- 위도 (지도 마커용. NULL 이면 지도에 표시하지 않는다)
    longitude DECIMAL(10,7),  -- 경도
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (owner_id) REFERENCES Users(user_id)
);

-- ---------- Services (시술/서비스) ----------
CREATE TABLE Services (
    service_id INT AUTO_INCREMENT PRIMARY KEY,
    salon_id INT NOT NULL,
    service_name VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    duration_minutes INT,
    description TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (salon_id) REFERENCES Salons(salon_id)
);

-- ---------- Stylists (스타일리스트) ----------
CREATE TABLE Stylists (
    stylist_id INT AUTO_INCREMENT PRIMARY KEY,
    salon_id INT NOT NULL,
    stylist_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20),
    description TEXT,
    image_url VARCHAR(255),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (salon_id) REFERENCES Salons(salon_id)
);

-- ---------- Reservations (예약) ----------
CREATE TABLE Reservations (
    reservation_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    salon_id INT NOT NULL,
    stylist_id INT,
    service_id INT NOT NULL,
    reservation_time DATETIME NOT NULL,
    status ENUM('pending', 'confirmed', 'completed', 'cancelled') NOT NULL,
    reject_reason VARCHAR(255) NULL DEFAULT NULL,         -- 취소 사유 텍스트
    cancel_type VARCHAR(20) NULL DEFAULT NULL,            -- 'rejected'=점주 거절+환불 / 'no_show'=노쇼+환불없음 / NULL=결제 실패·이탈
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (salon_id) REFERENCES Salons(salon_id),
    FOREIGN KEY (stylist_id) REFERENCES Stylists(stylist_id),
    FOREIGN KEY (service_id) REFERENCES Services(service_id)
);

-- ---------- Reviews (리뷰) ----------
CREATE TABLE Reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    salon_id INT NOT NULL,
    reservation_id INT UNIQUE NOT NULL,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (salon_id) REFERENCES Salons(salon_id),
    FOREIGN KEY (reservation_id) REFERENCES Reservations(reservation_id)
);

-- ---------- Salon_Operating_Hours (미용실 영업시간) ----------
CREATE TABLE Salon_Operating_Hours (
    hour_id INT AUTO_INCREMENT PRIMARY KEY,
    salon_id INT NOT NULL,
    day_of_week ENUM('월', '화', '수', '목', '금', '토', '일') NOT NULL,
    open_time TIME NOT NULL,
    close_time TIME NOT NULL,
    FOREIGN KEY (salon_id) REFERENCES Salons(salon_id)
);

-- ---------- Stylist_Schedules (스타일리스트 스케줄) ----------
CREATE TABLE Stylist_Schedules (
    schedule_id INT AUTO_INCREMENT PRIMARY KEY,
    stylist_id INT NOT NULL,
    date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_available BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (stylist_id) REFERENCES Stylists(stylist_id)
);

-- ---------- Payments (결제) ----------
CREATE TABLE Payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,           -- 결제 고유 식별자
    reservation_id INT UNIQUE NOT NULL,                  -- 관련 예약 ID
    user_id INT NOT NULL,                                -- 결제한 고객 ID
    amount DECIMAL(10,2) NOT NULL,                       -- 결제 금액 (원가 - 쿠폰할인 - 포인트사용)
    original_amount DECIMAL(10,2) NOT NULL DEFAULT 0,    -- 할인 적용 전 원가
    coupon_discount DECIMAL(10,2) NOT NULL DEFAULT 0,    -- 쿠폰 할인액
    point_used INT NOT NULL DEFAULT 0,                   -- 사용한 포인트
    pg_provider VARCHAR(20) NOT NULL DEFAULT 'KAKAOPAY',  -- PG사
    user_coupon_id INT NULL,                             -- 사용한 보유쿠폰 (User_Coupons FK, 테이블 정의 이후에 붙임)
    payment_method VARCHAR(50),                          -- 결제 수단 (예: 신용카드, 간편결제)
    payment_status ENUM('pending', 'completed', 'failed', 'refunded') NOT NULL, -- 결제 상태
    transaction_id VARCHAR(255) UNIQUE,                  -- 결제 시스템 트랜잭션 ID
    paid_at DATETIME DEFAULT CURRENT_TIMESTAMP,          -- 결제 일시
    FOREIGN KEY (reservation_id) REFERENCES Reservations(reservation_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- ---------- Wishlists (찜 목록) ----------
CREATE TABLE Wishlists (
    wishlist_id INT AUTO_INCREMENT PRIMARY KEY,          -- 찜 목록 고유 식별자
    user_id INT NOT NULL,                                -- 찜한 고객 ID
    salon_id INT NOT NULL,                               -- 찜한 미용실 ID
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id, salon_id),                          -- 고객별 미용실 하나만 찜 가능
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (salon_id) REFERENCES Salons(salon_id)
);

-- ---------- Chats (채팅방) ----------
CREATE TABLE Chats (
    chat_id INT AUTO_INCREMENT PRIMARY KEY,              -- 채팅방 고유 식별자
    user1_id INT NOT NULL,                               -- 참여자 1 ID
    user2_id INT NOT NULL,                               -- 참여자 2 ID
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user1_id) REFERENCES Users(user_id),
    FOREIGN KEY (user2_id) REFERENCES Users(user_id)
);

-- ---------- Messages (메시지) ----------
CREATE TABLE Messages (
    message_id INT AUTO_INCREMENT PRIMARY KEY,           -- 메시지 고유 식별자
    chat_id INT NOT NULL,                                -- 소속 채팅방 ID
    sender_id INT NOT NULL,                              -- 발신자 ID
    message_content TEXT NOT NULL,                       -- 메시지 내용
    sent_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (chat_id) REFERENCES Chats(chat_id),
    FOREIGN KEY (sender_id) REFERENCES Users(user_id)
);

-- ---------- Posts (커뮤니티 게시글) ----------
CREATE TABLE Posts (
    post_id INT AUTO_INCREMENT PRIMARY KEY,              -- 게시글 고유 식별자
    user_id INT NOT NULL,                                -- 작성자 ID
    title VARCHAR(255) NOT NULL,                         -- 게시글 제목
    content TEXT NOT NULL,                               -- 게시글 내용
    category VARCHAR(50),                                -- 게시글 카테고리
    image_url VARCHAR(255),                              -- 첨부 이미지 파일명
    salon_id INT,                                        -- 연관 미용실 ID (선택)
    view_count INT DEFAULT 0,                            -- 조회수
    like_count INT DEFAULT 0,                            -- 좋아요 수
    dislike_count INT DEFAULT 0,                         -- 별로예요 수
    report_count INT DEFAULT 0,                          -- 누적 신고 수
    status ENUM('visible', 'blinded', 'deleted') DEFAULT 'visible', -- 노출 상태 (자동 블라인드 여부)
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (salon_id) REFERENCES Salons(salon_id)
);

-- ---------- Comments (커뮤니티 댓글) ----------
CREATE TABLE Comments (
    comment_id INT AUTO_INCREMENT PRIMARY KEY,           -- 댓글 고유 식별자
    post_id INT NOT NULL,                                -- 소속 게시글 ID
    user_id INT NOT NULL,                                -- 작성자 ID
    content TEXT NOT NULL,                               -- 댓글 내용
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES Posts(post_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- ---------- post_likes (게시글 좋아요/별로예요) ----------
CREATE TABLE post_likes (
    like_id INT AUTO_INCREMENT PRIMARY KEY,              -- 반응 고유 식별자
    post_id INT NOT NULL,                                -- 대상 게시글 ID
    user_id INT NOT NULL,                                -- 반응한 사용자 ID
    reaction_type ENUM('like', 'dislike') NOT NULL,      -- 좋아요 / 별로예요
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_post_user (post_id, user_id),          -- 게시글당 1인 1반응
    FOREIGN KEY (post_id) REFERENCES Posts(post_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- ---------- post_reports (게시글 신고) ----------
CREATE TABLE post_reports (
    report_id INT AUTO_INCREMENT PRIMARY KEY,            -- 신고 고유 식별자
    post_id INT NOT NULL,                                -- 신고 대상 게시글 ID
    user_id INT NOT NULL,                                -- 신고한 사용자 ID
    reason ENUM('spam', 'illegal', 'abuse', 'privacy', 'other') NOT NULL DEFAULT 'other', -- 신고 사유 카테고리
    reason_detail VARCHAR(255),                          -- reason='other'일 때의 직접 입력 사유
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_post_user (post_id, user_id),          -- 게시글당 1인 1신고 (중복 신고 방지)
    FOREIGN KEY (post_id) REFERENCES Posts(post_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- ---------- comment_reports (댓글 신고) ----------
CREATE TABLE comment_reports (
    report_id INT AUTO_INCREMENT PRIMARY KEY,            -- 신고 고유 식별자
    comment_id INT NOT NULL,                             -- 신고 대상 댓글 ID
    user_id INT NOT NULL,                                -- 신고한 사용자 ID
    reason ENUM('spam', 'illegal', 'abuse', 'privacy', 'other') NOT NULL DEFAULT 'other', -- 신고 사유 카테고리
    reason_detail VARCHAR(255),                          -- reason='other'일 때의 직접 입력 사유
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_comment_user (comment_id, user_id),    -- 댓글당 1인 1신고 (중복 신고 방지)
    FOREIGN KEY (comment_id) REFERENCES Comments(comment_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- ---------- user_sanctions (회원 제재 이력) ----------
CREATE TABLE user_sanctions (
    sanction_id INT AUTO_INCREMENT PRIMARY KEY,           -- 제재 고유 식별자
    user_id INT NOT NULL,                                 -- 제재 대상 회원
    post_id INT,                                          -- 원인이 된 게시글 ID (참고용, FK 없음 - 삭제 후에도 기록 보존)
    post_title VARCHAR(255),                              -- 게시글 삭제 전 제목 스냅샷
    comment_id INT,                                       -- 원인이 된 댓글 ID (참고용, FK 없음 - 삭제 후에도 기록 보존)
    comment_content TEXT,                                 -- 댓글 삭제 전 내용 스냅샷
    admin_reason VARCHAR(255),                            -- 관리자가 입력한 제재 사유
    sanction_type ENUM('suspend_3d', 'suspend_7d', 'permanent') NOT NULL,
    suspended_until DATETIME,                             -- 이 제재로 인한 만료 시각 (permanent면 NULL)
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- ---------- Promotions (프로모션/광고) ----------
CREATE TABLE Promotions (
    promotion_id INT AUTO_INCREMENT PRIMARY KEY,         -- 프로모션 고유 식별자
    salon_id INT,                                        -- 관련 미용실 ID (선택)
    title VARCHAR(255) NOT NULL,                         -- 프로모션 제목
    description TEXT,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    discount_rate DECIMAL(5,2),                          -- 할인율 (예: 10.00 = 10%)
    coupon_code VARCHAR(50) UNIQUE,                      -- 쿠폰 코드
    image_url VARCHAR(255),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (salon_id) REFERENCES Salons(salon_id)
);

-- ---------- Advertisements (관리자 광고 슬라이드 배너) ----------
-- 특정 미용실에 묶이는 Promotions 와 달리, 관리자가 직접 운영하는 메인 배너다.
CREATE TABLE Advertisements (
    advertisement_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    description VARCHAR(500),
    image_url VARCHAR(500) NOT NULL,
    target_url VARCHAR(1000),                            -- 배너 클릭 시 이동할 주소
    display_order INT NOT NULL DEFAULT 0,                -- 노출 순서 (작을수록 먼저)
    active BOOLEAN NOT NULL DEFAULT TRUE,                -- 노출 여부
    start_at DATETIME NULL,                              -- 노출 시작 (NULL 이면 제한 없음)
    end_at DATETIME NULL,                                -- 노출 종료 (NULL 이면 제한 없음)
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_advertisements_exposure (active, start_at, end_at, display_order),
    CONSTRAINT chk_advertisements_period
        CHECK (end_at IS NULL OR start_at IS NULL OR end_at >= start_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------- Coupons (쿠폰 정책) ----------
CREATE TABLE Coupons (
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
    issue_type       VARCHAR(20) NOT NULL,                  -- signup / admin / code ...
    once_per_user    TINYINT(1) NOT NULL DEFAULT 0,         -- 1이면 한 회원에게 한 번만 발급
    is_active        TINYINT(1) NOT NULL DEFAULT 1,
    created_at       DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at       DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (promotion_id) REFERENCES Promotions(promotion_id),
    FOREIGN KEY (salon_id)     REFERENCES Salons(salon_id),
    FOREIGN KEY (service_id)   REFERENCES Services(service_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------- User_Coupons (사용자가 보유한 쿠폰) ----------
CREATE TABLE User_Coupons (
    user_coupon_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id        INT NOT NULL,
    coupon_id      INT NOT NULL,
    status         ENUM('available','reserved','used','expired') NOT NULL DEFAULT 'available',
    reservation_id INT NULL,                                -- reserved/used 일 때 어느 예약에 묶였는지
    issued_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    expires_at     DATETIME NOT NULL,                       -- 발급 시점에 Coupons.valid_until 을 복사
    used_at        DATETIME NULL,
    FOREIGN KEY (user_id)        REFERENCES Users(user_id),
    FOREIGN KEY (coupon_id)      REFERENCES Coupons(coupon_id),
    FOREIGN KEY (reservation_id) REFERENCES Reservations(reservation_id),
    INDEX idx_user_status (user_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Payments.user_coupon_id 는 User_Coupons 정의 이전에 만들어졌으므로 FK 는 여기서 붙인다.
ALTER TABLE Payments
    ADD CONSTRAINT fk_payments_user_coupon
    FOREIGN KEY (user_coupon_id) REFERENCES User_Coupons(user_coupon_id);

-- ---------- Point_Transactions (포인트 적립/사용 원장) ----------
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
    UNIQUE KEY uq_reservation_tx (reservation_id, tx_type) -- 같은 예약에 같은 종류의 원장이 두 번 쌓이지 않음
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
