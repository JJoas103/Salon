-- =====================================================================
-- 커뮤니티 기능 반영 마이그레이션
--
-- 이미 데이터가 들어있는 기존 salu DB에 적용하는 스크립트입니다.
-- DB를 새로 만드는 경우에는 schema.sql 하나만 실행하면 되므로
-- 이 파일은 실행할 필요가 없습니다.
--
-- 실행: mysql -u root -p salu < sql/migration_community.sql
-- =====================================================================

USE salu;

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
