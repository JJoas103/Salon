-- ============================================================
--  salu (미용실 예약 플랫폼) 스키마
--  MySQL 8.0 / utf8mb4
--  실행:  mysql -u root -p < sql/schema.sql
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
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
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
    amount DECIMAL(10,2) NOT NULL,                       -- 결제 금액
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
