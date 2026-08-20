-- ---------- Posts : 커뮤니티 기능용 컬럼 추가 ----------
-- PostVO 에 추가된 imageUrl / salonId / likeCount / dislikeCount 에 대응
ALTER TABLE Posts
    ADD COLUMN image_url VARCHAR(255) AFTER category,        -- 첨부 이미지 파일명
    ADD COLUMN salon_id INT AFTER image_url,                 -- 연관 미용실 ID (선택)
    ADD COLUMN like_count INT DEFAULT 0 AFTER view_count,    -- 좋아요 수
    ADD COLUMN dislike_count INT DEFAULT 0 AFTER like_count, -- 별로예요 수
    ADD CONSTRAINT fk_posts_salon FOREIGN KEY (salon_id) REFERENCES Salons(salon_id);

-- ---------- post_likes : 게시글 좋아요/별로예요 ----------
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

-- ------------salons 테이블 위도, 경도 추가 --------------
ALTER TABLE Salons
    add column latitude decimal(10, 7),  -- 위도
    add column longitude decimal(10, 7); -- 경도

-- ------------ 회원 탈퇴 컬럼 추가 --------------
ALTER TABLE Users
    add column deleted_at
    DATETIME NULL DEFAULT NULL after updated_at;

-- ---------- Posts : 신고/자동블라인드 기능용 컬럼 추가 ----------
ALTER TABLE Posts
    ADD COLUMN report_count INT DEFAULT 0 AFTER dislike_count,
    ADD COLUMN status ENUM('visible', 'blinded') DEFAULT 'visible' AFTER report_count;

-- ---------- post_reports : 게시글 신고 ----------
CREATE TABLE post_reports (
    report_id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_post_user (post_id, user_id),
    FOREIGN KEY (post_id) REFERENCES Posts(post_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- ---------- post_reports : 신고 사유 카테고리 컬럼 추가 ----------
ALTER TABLE post_reports
    ADD COLUMN reason ENUM('spam', 'illegal', 'abuse', 'privacy', 'other') NOT NULL DEFAULT 'other',
    ADD COLUMN reason_detail VARCHAR(255);

-- ---------- Users : 커뮤니티 제재(정지) 기능용 컬럼 추가 ----------
ALTER TABLE Users
    ADD COLUMN status ENUM('active', 'suspended', 'banned') DEFAULT 'active',
    ADD COLUMN suspended_until DATETIME NULL;

-- ---------- user_sanctions : 회원 제재 이력 ----------
CREATE TABLE user_sanctions (
    sanction_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    post_id INT,
    post_title VARCHAR(255),
    sanction_type ENUM('suspend_3d', 'suspend_7d', 'permanent') NOT NULL,
    suspended_until DATETIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- ---------- comment_reports : 댓글 신고 ----------
CREATE TABLE comment_reports (
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

-- ---------- user_sanctions : 댓글 제재 스냅샷 컬럼 추가 ----------
ALTER TABLE user_sanctions
    ADD COLUMN comment_id INT AFTER post_title,
    ADD COLUMN comment_content TEXT AFTER comment_id;

-- ---------- user_sanctions : 관리자 제재 사유 컬럼 추가 ----------
ALTER TABLE user_sanctions
    ADD COLUMN admin_reason VARCHAR(255) AFTER comment_content;
