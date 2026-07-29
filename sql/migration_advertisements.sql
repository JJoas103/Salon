-- 관리자 광고 슬라이드 배너
-- 기존 테이블과 데이터는 변경하지 않고 Advertisements 테이블만 추가한다.
-- 실행 전 사용할 DB를 확인한 뒤 실행:
--   mysql -u root -p salu < sql/migration_advertisements.sql

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
