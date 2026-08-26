-- ============================================================
--  AI 상담 챗봇 시연용 시드 데이터
--
--  기존 더미(dummydata_original.sql)는 시술이 13건뿐이라 상담이 성립하지 않았음
--  클리닉이 1건이라 "손상모 케어 추천" 의 정답이 하나로 고정되고,
--  최저가 상위 3건이 전부 남성컷으로 나오는 식임
--
--  카테고리를 고르게 채워 검색·정렬·매장비교가 모두 답이 갈리도록 함
--  매장별 성격(Salons.description)에 맞춰 취급 시술과 가격대를 다르게 둠
--
--  실행:  mysql --default-character-set=utf8mb4 -u root -p salu < sql/seed_ai_demo.sql
--         (Windows 클라이언트는 기본 charset 이 cp949 라 옵션을 빼면 한글이 깨진다)
--  여러 번 실행해도 같은 결과가 되도록 매장명+시술명 기준으로 중복을 건너뜀
--  시술을 늘린 뒤에는 ai-service 재색인이 필요함:
--    curl -X POST http://localhost:8000/api/reindex
-- ============================================================

SET NAMES utf8mb4;

USE salu;

-- ---------- 1. 시술 ----------
-- salon_id 를 번호로 박지 않고 매장명으로 찾음 — 다른 DB 에서도 그대로 돌아가게
INSERT INTO Services (salon_id, service_name, category, price, duration_minutes, description, concern)
SELECT s.salon_id, v.service_name, v.category, v.price, v.duration_minutes, v.description, v.concern
FROM (
    -- 라움헤어 (강남 / 트렌디한 커트와 컬러)
    SELECT '라움헤어' AS salon_name, '레이어드컷' AS service_name, '컷' AS category, 32000 AS price, 50 AS duration_minutes,
           '얼굴형에 맞춘 층 커트' AS description, '무거운 머리, 볼륨 부족, 답답한 인상' AS concern
    UNION ALL SELECT '라움헤어', '애쉬브라운 염색', '염색', 85000, 120, '탈색 없이 넣는 애쉬 계열 염색', '노란기 제거, 차분한 톤, 자연스러운 갈색'
    UNION ALL SELECT '라움헤어', '헤어글로스', '클리닉', 45000, 40, '윤기 코팅 트리트먼트', '푸석함, 윤기 없음, 부스스한 모발'
    UNION ALL SELECT '라움헤어', '앞머리펌', '펌', 35000, 40, '자연스러운 앞머리 컬', '뜨는 앞머리, 밋밋한 인상'

    -- 소울커트 (홍대 / 캐주얼)
    UNION ALL SELECT '소울커트', '허쉬컷', '컷', 28000, 50, '가벼운 layered 허쉬컷', '무거운 머리, 답답한 인상, 볼륨 부족'
    UNION ALL SELECT '소울커트', '투블럭컷', '컷', 21000, 35, '남성 투블럭 스타일', '짧고 깔끔한 스타일, 옆머리 뜸'
    UNION ALL SELECT '소울커트', '흑채펌', '펌', 78000, 110, '자연스러운 남성 다운펌', '뜨는 머리, 곱슬머리, 정리 안 되는 옆머리'
    UNION ALL SELECT '소울커트', '베이직 트리트먼트', '클리닉', 35000, 40, '기본 영양 케어', '푸석함, 갈라짐, 손상모'

    -- 블랑쉬헤어 (웨딩 / 투톤 컬러)
    UNION ALL SELECT '블랑쉬헤어', '웨딩 업스타일', '세트', 130000, 90, '예식 당일 업스타일', '특별한 날 스타일링, 웨딩'
    UNION ALL SELECT '블랑쉬헤어', '투톤 컬러', '염색', 180000, 240, '탈색 후 두 가지 톤 배색', '개성 있는 컬러, 분위기 전환'
    UNION ALL SELECT '블랑쉬헤어', '디지털펌', '펌', 140000, 180, '열기구 웨이브 펌', '힘없는 모발, 볼륨 부족, 웨이브 연출'
    UNION ALL SELECT '블랑쉬헤어', '단백질 클리닉', '클리닉', 95000, 80, '탈색모 집중 복구', '탈색 손상, 끊어짐, 심한 손상모'

    -- 그레이스살롱 (동네 / 가족 단골)
    UNION ALL SELECT '그레이스살롱', '커트+드라이', '세트', 32000, 60, '커트와 드라이를 함께', '일상 손질 편한 커트, 스타일링'
    UNION ALL SELECT '그레이스살롱', '새치커버 염색', '염색', 55000, 80, '자연 갈색 새치 커버', '새치 커버, 흰머리, 자연스러운 톤'
    UNION ALL SELECT '그레이스살롱', '볼륨매직', '펌', 115000, 150, '뿌리 볼륨 매직', '곱슬머리, 부스스한 모발, 매끈한 볼륨'
    UNION ALL SELECT '그레이스살롱', '두피 스케일링', '클리닉', 40000, 40, '두피 각질 제거와 진정', '두피 가려움, 기름진 두피, 냄새'

    -- 헤어스튜디오 온 (남성 전문 클리닉)
    UNION ALL SELECT '헤어스튜디오 온', '남성 다운펌', '펌', 45000, 60, '뜨는 옆머리 정리', '뜨는 머리, 정리 안 되는 옆머리, 곱슬머리'
    UNION ALL SELECT '헤어스튜디오 온', '두피 클리닉', '클리닉', 60000, 60, '두피 집중 관리 프로그램', '두피 가려움, 비듬, 기름진 두피'
    UNION ALL SELECT '헤어스튜디오 온', '남성 커버 염색', '염색', 45000, 60, '남성용 새치 커버', '새치 커버, 흰머리'
    UNION ALL SELECT '헤어스튜디오 온', '스포츠컷', '컷', 16000, 25, '짧고 관리 쉬운 커트', '짧고 깔끔한 스타일, 관리 편한 머리'

    -- 살롱드밀 (프리미엄)
    UNION ALL SELECT '살롱드밀', '프리미엄 헤드스파', '클리닉', 160000, 90, '두피 마사지 포함 스파', '두피 피로, 스트레스, 기름진 두피'
    UNION ALL SELECT '살롱드밀', '디자이너 컷', '컷', 90000, 60, '원장 디자이너 커트', '얼굴형 커버, 이미지 변신'
    UNION ALL SELECT '살롱드밀', '럭셔리 클리닉', '클리닉', 220000, 120, '고농축 단백질 복구', '심한 손상모, 끊어짐, 갈라짐'

    -- 위드헤어 (실속형)
    UNION ALL SELECT '위드헤어', '남성컷', '컷', 15000, 25, '실속형 남성 커트', '짧고 깔끔한 스타일, 관리 편한 머리'
    UNION ALL SELECT '위드헤어', '기본펌', '펌', 55000, 90, '가격 부담 없는 기본 펌', '볼륨 부족, 힘없는 모발'
    UNION ALL SELECT '위드헤어', '뿌리염색', '염색', 38000, 60, '뿌리만 채우는 염색', '새치 커버, 뿌리 자란 머리'

    -- 컬러플레이 헤어 (탈염 / 컬러 특화)
    UNION ALL SELECT '컬러플레이 헤어', '블리치 2회', '염색', 160000, 210, '밝은 톤을 위한 2회 탈색', '밝은 컬러, 톤 업, 개성 있는 컬러'
    UNION ALL SELECT '컬러플레이 헤어', '핑크 컬러', '염색', 130000, 180, '탈색 후 핑크 컬러', '개성 있는 컬러, 분위기 전환'
    UNION ALL SELECT '컬러플레이 헤어', '탈색모 클리닉', '클리닉', 80000, 70, '탈색 직후 복구 케어', '탈색 손상, 심한 손상모, 끊어짐'
    UNION ALL SELECT '컬러플레이 헤어', '컬러 커트', '컷', 30000, 45, '컬러에 맞춘 커트', '이미지 변신, 얼굴형 커버'

    -- 에디트헤어 (남녀 커트 및 펌)
    UNION ALL SELECT '에디트헤어', '여성컷', '컷', 24000, 40, '디자이너 커트', '일상 손질 편한 커트, 얼굴형 커버'
    UNION ALL SELECT '에디트헤어', '히피펌', '펌', 88000, 120, '내추럴 웨이브 히피펌', '밋밋한 머리, 웨이브 연출, 볼륨 부족'
    UNION ALL SELECT '에디트헤어', '보브펌', '펌', 95000, 130, '단발 웨이브 펌', '단발 스타일, 웨이브 연출'
    UNION ALL SELECT '에디트헤어', '영양 클리닉', '클리닉', 50000, 50, '펌·염색 후 영양 보충', '손상모, 푸석함, 갈라짐'

    -- 뮤즈헤어살롱 (20년 경력 원장)
    UNION ALL SELECT '뮤즈헤어살롱', '원장 커트', '컷', 38000, 50, '원장 직접 시술 커트', '얼굴형 커버, 이미지 변신'
    UNION ALL SELECT '뮤즈헤어살롱', '셋팅펌', '펌', 105000, 150, '내추럴 셋팅펌', '볼륨 부족, 힘없는 모발, 자연스러운 웨이브'
    UNION ALL SELECT '뮤즈헤어살롱', '발레아쥬', '염색', 145000, 180, '자연스러운 그라데이션 염색', '칙칙한 톤, 그라데이션 염색, 분위기 전환'
    UNION ALL SELECT '뮤즈헤어살롱', '손상모 집중케어', '클리닉', 72000, 70, '손상 단계별 맞춤 케어', '손상모, 갈라짐, 푸석함 완화'
) AS v
JOIN Salons s ON s.salon_name = v.salon_name AND s.closed_at IS NULL
WHERE NOT EXISTS (
    SELECT 1 FROM Services e
    WHERE e.salon_id = s.salon_id AND e.service_name = v.service_name
);

-- ---------- 2. test10 의 완료 예약 ----------
-- 개인화 상담(이력 기반 추천)을 시연하려면 완료 예약이 있어야 함
-- 서로 다른 매장 두 곳, 서로 다른 카테고리로 넣어 "이력 매장 비교" 가 성립하게 함
INSERT INTO Reservations (user_id, salon_id, stylist_id, service_id, reservation_time, status)
-- 매장에 스타일리스트가 여럿이면 LEFT JOIN 이 행을 늘리므로 한 명만 고른다.
-- MIN 으로 집계해야 ONLY_FULL_GROUP_BY(MySQL 8 기본 sql_mode)에 걸리지 않는다.
SELECT u.user_id, s.salon_id, MIN(st.stylist_id), sv.service_id, v.reservation_time, 'completed'
FROM (
    SELECT '라움헤어' AS salon_name, '레이어드컷' AS service_name,
           TIMESTAMP(CURRENT_DATE - INTERVAL 40 DAY, '14:00:00') AS reservation_time
    UNION ALL SELECT '컬러플레이 헤어', '핑크 컬러',
           TIMESTAMP(CURRENT_DATE - INTERVAL 18 DAY, '11:00:00')
) AS v
JOIN Users u  ON u.email = 'test10@salu.com' AND u.deleted_at IS NULL
JOIN Salons s ON s.salon_name = v.salon_name AND s.closed_at IS NULL
JOIN Services sv ON sv.salon_id = s.salon_id AND sv.service_name = v.service_name
LEFT JOIN Stylists st ON st.salon_id = s.salon_id
WHERE NOT EXISTS (
    SELECT 1 FROM Reservations r
    WHERE r.user_id = u.user_id AND r.service_id = sv.service_id AND r.status = 'completed'
)
GROUP BY u.user_id, s.salon_id, sv.service_id, v.reservation_time;

-- ---------- 확인 ----------
SELECT category AS 카테고리, COUNT(*) AS 건수 FROM Services GROUP BY category ORDER BY 건수 DESC;
SELECT COUNT(*) AS 전체시술 FROM Services;
SELECT u.email, COUNT(*) AS 완료예약
FROM Reservations r JOIN Users u ON u.user_id = r.user_id
WHERE r.status = 'completed' GROUP BY u.email ORDER BY u.email;
