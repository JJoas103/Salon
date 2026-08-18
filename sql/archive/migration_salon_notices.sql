-- 점주 이벤트/공지사항 (owner/events 페이지에서 작성 -> 고객 지도검색(salonmap) 상세 카드의 "공지사항" 탭에 노출)
-- 실행: mysql -u root -p salu < sql/migration_salon_notices.sql

CREATE TABLE SalonNotices (
    notice_id INT AUTO_INCREMENT PRIMARY KEY,
    salon_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (salon_id) REFERENCES Salons(salon_id)
);
