-- ============================================================
--  salu (미용실 예약 플랫폼) 스키마
--  MySQL 8.0 / utf8mb4
--  실행:  mysql -u root -p < sql/schema.sql
--
--  이 파일은 "지금 시점의 완성된 스키마" 하나만 담는다.
--  새 DB 를 만들 때는 이 파일만 실행하면 되고, 마이그레이션을
--  따로 실행할 필요는 없다 (이미 전부 반영되어 있다).
--
--  이미 DB 를 갖고 있어서 새로 만들 수 없다면 이 파일 대신
--  sql/migration_catchup.sql 을 실행한다. 두 파일은 같은 결과를 만든다.
-- ============================================================
--  반영된 마이그레이션 이력 (적용 순서대로)
--
--    1. 2026-07-27  restore_original_salons_utf8.sql
--                   → 더미데이터 한글 복구. 스키마 변경 없음(데이터 전용)
--    2. 2026-07-28  migration_community.sql
--                   → Posts 에 image_url / salon_id / like_count / dislike_count
--                                / report_count / status
--                   → post_likes / post_reports / comment_reports / user_sanctions 신설
--                   → Salons 에 latitude / longitude
--                   → Users 에 deleted_at (회원 탈퇴 soft delete) / status / suspended_until
--    3. 2026-07-28  salon_coordinates.sql
--                   → 더미 미용실 좌표 채우기. 스키마 변경 없음(데이터 전용)
--    4. 2026-07-29  migration_advertisements.sql
--                   → Advertisements 신설 (관리자 광고 슬라이드 배너)
--    5. 2026-07-30  migration_owner_request.sql
--                   → OwnerRequests 신설 (점주 전환 신청/승인)
--    6. 2026-07-30  migration_salon_status.sql
--                   → Salons 에 closed_at (폐업 soft delete)
--    7. 2026-07-31  migration_chats.sql
--                   → Chats 에 salon_id + 고객·매장당 방 하나 UNIQUE
--                   → Messages 에 is_read (안읽음 배지)
--    8. 2026-08-04  migration_payment.sql
--                   → Payments 에 original_amount / coupon_discount / point_used
--                                 / pg_provider / user_coupon_id
--    9. 2026-08-05  migration_salon_notices.sql (+ _image)
--                   → SalonNotices 신설 + image_url
--   10. 2026-08-05  migration_reviews_images.sql
--                   → Reviews 에 image_url / image_url2
--   11. 2026-08-05  migration_Point.sql
--                   → Users 에 point_balance, Point_Transactions 신설
--   12. 2026-08-06  migration_reservation_reject.sql
--                   → Reservations 에 reject_reason / cancel_type
--   13. 2026-08-10  migration_coupon.sql
--                   → Coupons / User_Coupons 신설 + Payments.user_coupon_id FK
--   14. 2026-08-11  migration_combined.sql
--                   → 9·10·13 을 한 파일로 묶어 재배포한 것. 새 스키마 변경은 없다
--   15. 2026-08-12  migration_service_category.sql
--                   → Services 에 category (AI 시술 추천 필터용)
--   16. 2026-08-12  migration_service_concern.sql
--                   → Services 에 concern (AI 시술 추천 검색어 가중치용)
--   17. 2026-08-14  migration_oauth_login.sql
--                   → Users.password NULL 허용 + provider / provider_id + UNIQUE
--   18. 2026-08-16  migration_salon_activation.sql
--                   → Salons 에 activation_status (매장 2차 승인 = 손님 노출 여부)
--   19. 2026-08-18  migration_owner_request_type.sql
--                   → OwnerRequests 에 request_type (승격 요청 / 매장 추가 요청 구분)
--   20. 2026-08-19  migration_profile_image.sql
--                   → Users 에 profile_image_url
--   21. 2026-08-20  migration_my_community.sql / migration_comment_log.sql
--                   → Users 에 last_reply_check_at, Posts.status 에 'deleted' 추가
--   22. 2026-08-21  migration_notifications.sql (+ _enabled)
--                   → Notifications 신설, Users 에 notifications_enabled
--
--  개별 migration_*.sql 은 sql/archive/ 로 옮겨 이력으로만 보존한다.
--  앞으로 스키마를 바꿀 때도 같은 방식으로:
--    (1) 팀원은 migration_*.sql 을 새로 만들어 올린다 (기존 DB 를 갱신하는 용도)
--    (2) 이 파일과 migration_catchup.sql 로의 통합, 위 이력 갱신은 팀장이 한다
--  두 곳이 어긋나면 새로 DB 를 만든 사람만 기능이 깨져서 원인을 찾기 어렵다.
--
--  테이블 정의 순서는 FK 의존 순서다 (참조되는 쪽이 먼저).
--  Coupons/User_Coupons 가 Payments 앞에 있는 이유도 이것 —
--  Payments.user_coupon_id 가 User_Coupons 를 참조한다.
-- ============================================================

-- ⚠ 이 파일은 salu 데이터베이스를 통째로 지우고 다시 만든다.
--   기존 데이터를 남기고 스키마만 맞추려면 sql/migration_catchup.sql 을 실행할 것.
DROP DATABASE IF EXISTS salu;

CREATE DATABASE salu
    DEFAULT CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE salu;

-- ---------- Users (사용자) ----------
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,               -- 사용자 고유 식별자
    email VARCHAR(255) UNIQUE NOT NULL,                   -- 이메일 (로그인 ID)
    password VARCHAR(255) NULL,                           -- 비밀번호 (소셜 전용 계정은 NULL)
    user_name VARCHAR(100),
    phone_number VARCHAR(20),
    profile_image_url VARCHAR(255) NULL DEFAULT NULL,
    user_type ENUM('customer', 'owner', 'admin') NOT NULL, -- 사용자 유형 (고객, 점주, 관리자)
    provider ENUM('local', 'google', 'naver') NOT NULL DEFAULT 'local', -- 로그인 수단
    provider_id VARCHAR(255) NULL,                        -- 소셜 로그인 제공자가 발급한 사용자 식별자
    status ENUM('active', 'suspended', 'banned') DEFAULT 'active', -- 커뮤니티 이용 제한 상태
    notifications_enabled TINYINT(1) NOT NULL DEFAULT 1,
    suspended_until DATETIME NULL,                          -- 정지 만료 시각 (영구정지면 NULL)
    point_balance INT NOT NULL DEFAULT 0,                 -- 보유 포인트 (원장은 Point_Transactions)
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL DEFAULT NULL,                -- 탈퇴 일시 (NULL 이면 활성 회원. 행을 지우지 않는 soft delete)
    last_reply_check_at DATETIME NULL,                    -- 마이페이지 "내 글에 달린 댓글" 탭 마지막 확인 시각 (안읽음 배지용)
    UNIQUE KEY uq_users_provider_id (provider, provider_id) -- NULL끼리는 유니크 충돌로 안 보므로 로컬 계정끼리는 무관
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
    -- NULL 이면 운영중, 값이 있으면 폐업. Users.deleted_at 과 동일한 soft delete 패턴 —
    -- salon_id 를 ON DELETE CASCADE 없이 참조하는 테이블이 8개라 하드 delete 는 FK 에러가 난다.
    closed_at DATETIME NULL DEFAULT NULL,
    activation_status ENUM('preparing','active') NOT NULL DEFAULT 'active',
    FOREIGN KEY (owner_id) REFERENCES Users(user_id)
);

-- ---------- Services (시술/서비스) ----------
CREATE TABLE Services (
    service_id INT AUTO_INCREMENT PRIMARY KEY,
    salon_id INT NOT NULL,
    service_name VARCHAR(255) NOT NULL,
    -- 컷/펌/염색/클리닉/세트 5종 고정값이지만, 추후 값이 늘어날 수 있어 ENUM 대신 VARCHAR.
    -- 값이 없는 기존 시술은 필터 대상에서만 제외되면 되므로 NULL 허용.
    category VARCHAR(20) NULL,
    price DECIMAL(10,2) NOT NULL,
    duration_minutes INT,
    description TEXT,
    -- AI 시술 추천 챗봇이 하이브리드 검색에서 가중치를 두는 필드(고민 키워드,
    -- 쉼표로 나열. 예: "곱슬머리, 손상모, 볼륨 다운"). 값이 없어도 검색은 되므로 NULL 허용.
    concern VARCHAR(255) NULL,
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
    -- 점주가 확정된 예약을 정리하면 status 는 cancelled 가 되고 아래 두 컬럼이 남는다.
    --   cancelled + cancel_type='rejected'  → 점주가 부득이 취소하고 환불해 준 건
    --   cancelled + cancel_type='no_show'   → 손님이 오지 않아 노쇼로 마감(선불 금액은 매장 정산)
    --   cancelled + cancel_type='user_cancelled' → 손님이 직접 취소(결제 완료건이면 환불)
    --   cancelled + cancel_type IS NULL     → 결제 실패/이탈로 자리만 비운 건 (reject_reason 도 NULL)
    -- 손님 자가 취소가 생기면 'customer' 같은 값을 여기에 추가하면 된다.
    reject_reason VARCHAR(255) NULL DEFAULT NULL,
    cancel_type VARCHAR(20) NULL DEFAULT NULL,
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
    image_url VARCHAR(255) NULL,                          -- 첨부 사진 1
    image_url2 VARCHAR(255) NULL,                         -- 첨부 사진 2
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

-- ---------- Promotions (프로모션/광고) ----------
-- 아직 화면/mapper 가 붙지 않은 스캐폴딩이지만, Coupons.promotion_id 가 참조한다.
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

-- ---------- User_Coupons (사용자가 보유한 쿠폰) ----------
CREATE TABLE User_Coupons (
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

-- ---------- Payments (결제) ----------
CREATE TABLE Payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,           -- 결제 고유 식별자
    reservation_id INT UNIQUE NOT NULL,                  -- 관련 예약 ID
    user_id INT NOT NULL,                                -- 결제한 고객 ID
    -- amount = original_amount - coupon_discount - point_used 로 확정된 최종 결제 금액
    amount DECIMAL(10,2) NOT NULL,
    original_amount DECIMAL(10,2) NOT NULL DEFAULT 0,    -- 할인 전 금액 (시술 정가)
    coupon_discount DECIMAL(10,2) NOT NULL DEFAULT 0,    -- 쿠폰 할인액
    point_used INT NOT NULL DEFAULT 0,                   -- 사용 포인트
    user_coupon_id INT NULL,                             -- 사용한 보유 쿠폰
    pg_provider VARCHAR(20) NOT NULL DEFAULT 'KAKAOPAY', -- 결제 게이트웨이
    payment_method VARCHAR(50),                          -- 결제 수단 (예: 신용카드, 간편결제)
    payment_status ENUM('pending', 'completed', 'failed', 'refunded') NOT NULL, -- 결제 상태
    transaction_id VARCHAR(255) UNIQUE,                  -- 결제 시스템 트랜잭션 ID
    paid_at DATETIME DEFAULT CURRENT_TIMESTAMP,          -- 결제 일시
    FOREIGN KEY (reservation_id) REFERENCES Reservations(reservation_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    CONSTRAINT fk_payments_user_coupon
        FOREIGN KEY (user_coupon_id) REFERENCES User_Coupons(user_coupon_id)
);

-- ---------- Point_Transactions (포인트 원장) ----------
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

-- ---------- Chats (1:1 상담 채팅방) ----------
-- 규칙: user1_id = 고객, user2_id = 점주  ← 순서 고정.
--       이 순서를 지켜야 UNIQUE 제약과 단일 조건 조회가 성립한다.
CREATE TABLE Chats (
    chat_id INT AUTO_INCREMENT PRIMARY KEY,              -- 채팅방 고유 식별자
    user1_id INT NOT NULL,                               -- 참여자 1 ID (고객)
    user2_id INT NOT NULL,                               -- 참여자 2 ID (점주)
    salon_id INT NOT NULL,                               -- 어느 매장 문의인지
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user1_id) REFERENCES Users(user_id),
    FOREIGN KEY (user2_id) REFERENCES Users(user_id),
    CONSTRAINT fk_chats_salon FOREIGN KEY (salon_id) REFERENCES Salons(salon_id),
    CONSTRAINT uq_chats_customer_salon UNIQUE (user1_id, salon_id)  -- 고객+매장당 방 하나
);

-- ---------- Messages (메시지) ----------
CREATE TABLE Messages (
    message_id INT AUTO_INCREMENT PRIMARY KEY,           -- 메시지 고유 식별자
    chat_id INT NOT NULL,                                -- 소속 채팅방 ID
    sender_id INT NOT NULL,                              -- 발신자 ID
    message_content TEXT NOT NULL,                       -- 메시지 내용
    is_read TINYINT(1) NOT NULL DEFAULT 0,               -- 안읽음 배지용
    sent_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (chat_id) REFERENCES Chats(chat_id),
    FOREIGN KEY (sender_id) REFERENCES Users(user_id)
);

-- ---------- SalonNotices (점주 이벤트/공지사항) ----------
-- owner/events 에서 작성 → 고객 지도검색(salonmap) 상세 카드의 "공지사항" 탭에 노출
CREATE TABLE SalonNotices (
    notice_id INT AUTO_INCREMENT PRIMARY KEY,
    salon_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    image_url VARCHAR(255) NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (salon_id) REFERENCES Salons(salon_id)
);

-- ---------- OwnerRequests (점주 전환 신청) ----------
CREATE TABLE OwnerRequests (
    request_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    salon_name VARCHAR(255) NOT NULL,
    salon_phone VARCHAR(20),
    message TEXT,
    request_type ENUM('promotion','additional_salon') NOT NULL DEFAULT 'promotion',
    status ENUM('pending','approved','rejected') NOT NULL DEFAULT 'pending',
    requested_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    processed_at DATETIME NULL,
    processed_by INT NULL,                               -- 처리한 관리자
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (processed_by) REFERENCES Users(user_id)
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
    CONSTRAINT fk_posts_salon FOREIGN KEY (salon_id) REFERENCES Salons(salon_id)
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

-- ---------- Notifications (고객 알림함) ----------
-- ref_id 는 type 에 따라 가리키는 테이블이 달라 FK 를 걸지 않는다 (다형성 참조:
--   RESERVATION -> Reservations, COUPON -> User_Coupons, CHAT -> Chats, NOTICE -> SalonNotices)
CREATE TABLE Notifications (
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
