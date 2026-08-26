-- ============================================================
--  salu 시연용 더미 데이터
--  실행:  mysql --default-character-set=utf8mb4 -u root -p salu < sql/seed_demo.sql
--         (Windows 클라이언트는 기본 charset 이 cp949 라 옵션을 빼면 한글이 깨진다.
--          아래 SET NAMES 로도 막아두었지만 옵션까지 주는 쪽이 확실하다)
--
--  몇 번을 실행해도 같은 상태가 된다 (전부 지우고 다시 넣는다).
--  리허설로 예약이 쌓이면 이 파일을 다시 실행해 초기 상태로 되돌린다.
--
--  날짜는 전부 CURDATE() 기준 상대값이라 며칠 뒤에 실행해도 유효하다.
--  절대 날짜를 넣으면 발표 당일에 예약 시간표가 통째로 비어버린다.
--
--  로컬 계정 비밀번호: 기존 DB 의 test 계정들과 같은 해시를 그대로 썼다.
--  (그 계정들에 쓰던 비밀번호로 로그인된다. user2 는 소셜 계정이라 비밀번호 없음)
-- ============================================================

SET NAMES utf8mb4;

USE salu;

SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE Notifications;
TRUNCATE TABLE Point_Transactions;
TRUNCATE TABLE Payments;
TRUNCATE TABLE User_Coupons;
TRUNCATE TABLE Coupons;
TRUNCATE TABLE Promotions;
TRUNCATE TABLE Reviews;
TRUNCATE TABLE Reservations;
TRUNCATE TABLE Stylist_Schedules;
TRUNCATE TABLE Stylists;
TRUNCATE TABLE Salon_Operating_Hours;
TRUNCATE TABLE Services;
TRUNCATE TABLE SalonNotices;
TRUNCATE TABLE Wishlists;
TRUNCATE TABLE Messages;
TRUNCATE TABLE Chats;
TRUNCATE TABLE user_sanctions;
TRUNCATE TABLE comment_reports;
TRUNCATE TABLE post_reports;
TRUNCATE TABLE post_likes;
TRUNCATE TABLE Comments;
TRUNCATE TABLE Posts;
TRUNCATE TABLE Advertisements;
TRUNCATE TABLE OwnerRequests;
TRUNCATE TABLE Salons;
TRUNCATE TABLE Users;

SET FOREIGN_KEY_CHECKS = 1;


-- ============================================================
--  Users — 로컬 계정은 기존 test 계정과 동일한 BCrypt 해시
-- ============================================================
--  1 관리자
--  2 점주 A : 운영중 매장 2개 (강남/홍대) — 시연 본선에서 쓰는 매장
--  3 손님(승격 신청중) : 관리자 1차 승인 대상
--  4 점주 C : 준비중 매장 2개 (필수정보 미입력 / 입력완료)
--  5 손님 1 : 쿠폰·적립금 보유. 예약·결제 시연의 주인공
--  6 손님 2 : 구글 소셜 계정
--  7 손님 3 : 커뮤니티 신고 대상 글 작성자
INSERT INTO Users
    (user_id, email, password, user_name, phone_number, user_type, provider, provider_id, point_balance) VALUES
(1, 'admin@salu.com',  '$2a$10$TzYP1yrIyYSK/6T.vFwfS.I1A9K807yKxkV0T590Gnr0XrydyUAWq', '관리자',   '010-0000-0001', 'admin',    'local',  NULL, 0),
(2, 'owner@salu.com',  '$2a$10$TzYP1yrIyYSK/6T.vFwfS.I1A9K807yKxkV0T590Gnr0XrydyUAWq', '김점주',   '010-0000-0002', 'owner',    'local',  NULL, 0),
(3, 'newowner@salu.com','$2a$10$TzYP1yrIyYSK/6T.vFwfS.I1A9K807yKxkV0T590Gnr0XrydyUAWq','박승격',   '010-0000-0003', 'customer', 'local',  NULL, 0),
(4, 'owner2@salu.com', '$2a$10$TzYP1yrIyYSK/6T.vFwfS.I1A9K807yKxkV0T590Gnr0XrydyUAWq', '이준비',   '010-0000-0004', 'owner',    'local',  NULL, 0),
(5, 'user1@salu.com',  '$2a$10$TzYP1yrIyYSK/6T.vFwfS.I1A9K807yKxkV0T590Gnr0XrydyUAWq', '최손님',   '010-0000-0005', 'customer', 'local',  NULL, 8000),
(6, 'user2@salu.com',  NULL,                                                            '정소셜',   '010-0000-0006', 'customer', 'google', 'google-1001', 1500),
(7, 'user3@salu.com',  '$2a$10$TzYP1yrIyYSK/6T.vFwfS.I1A9K807yKxkV0T590Gnr0XrydyUAWq', '한작성',   '010-0000-0007', 'customer', 'local',  NULL, 0);

--  8~17 : 매장 리뷰/예약 이력을 채우는 배경 손님들.
--  시연 주인공(손님1·2·3)의 예약내역·마이페이지가 더미로 뒤덮이면 안 되므로,
--  매장 20곳의 예약·리뷰는 전부 이 계정들 몫으로 돌린다.
--  point_balance 는 0 으로 두고 Point_Transactions 도 만들지 않는다
--  (원장 합계 = point_balance 불변식을 깨지 않기 위해서다).
INSERT INTO Users
    (user_id, email, password, user_name, phone_number, user_type, provider, provider_id, point_balance)
SELECT 7 + n,
       CONCAT('guest', n, '@salu.com'),
       '$2a$10$TzYP1yrIyYSK/6T.vFwfS.I1A9K807yKxkV0T590Gnr0XrydyUAWq',
       CONCAT(ELT(n, '김', '이', '박', '최', '정', '강', '조', '윤', '장', '임'),
              ELT(n, '서연', '지훈', '하은', '도현', '수아', '민준', '예린', '시우', '나윤', '건우')),
       CONCAT('010-3333-', LPAD(n, 4, '0')),
       'customer', 'local', NULL, 0
FROM (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
      UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10) g;


-- ============================================================
--  Salons — 1·2 는 손님에게 보이고, 3·4 는 2차 승인 대기중
-- ============================================================
--  3 : 필수정보 미입력 (영업시간·시술메뉴·디자이너 없음) → 사이드바 "준비중 1/4"
--  4 : 필수정보 4/4 완료 → 관리자가 바로 2차 승인 시연 가능 (백업 경로)
INSERT INTO Salons
    (salon_id, owner_id, salon_name, address, phone_number, description,
     average_rating, image_url, latitude, longitude, activation_status) VALUES
(1, 2, '살루 헤어 강남점', '서울특별시 강남구 테헤란로 152', '02-555-0101',
    '10년 경력 디자이너가 상주하는 프리미엄 헤어살롱입니다. 두피 케어와 손상모 클리닉 전문.',
    4.6, '/resources/images/salon1.svg', 37.5006, 127.0364, 'active'),
(2, 2, '살루 헤어 홍대점', '서울특별시 마포구 양화로 156', '02-555-0102',
    '트렌디한 컬러와 펌 전문. 20대 고객 만족도 1위 지점입니다.',
    4.3, '/resources/images/salon2.svg', 37.5563, 126.9236, 'active'),
(3, 4, '준비중 살롱',      '서울특별시 성동구 왕십리로 100', '02-555-0103',
    NULL,
    0.0, '/resources/images/salon3.svg', 37.5610, 127.0370, 'preparing'),
(4, 4, '살루 헤어 성수점', '서울특별시 성동구 연무장길 45', '02-555-0104',
    '성수동 감성 인테리어의 신규 지점입니다.',
    0.0, '/resources/images/salon4.svg', 37.5445, 127.0557, 'preparing');


-- ============================================================
--  OwnerRequests — 창모 시연: 1차 승인 대상
-- ============================================================
INSERT INTO OwnerRequests
    (request_id, user_id, salon_name, salon_phone, message, request_type, status) VALUES
(1, 3, '살루 헤어 신촌점', '02-555-0105',
    '신촌에서 5년째 운영중인 미용실입니다. 입점 신청합니다.', 'promotion', 'pending');


-- ============================================================
--  Salon_Operating_Hours — 매장 1·2·4 는 7일 모두 영업
--  (요일이 하나라도 빠지면 그날 예약 시간표가 통째로 빈다)
-- ============================================================
INSERT INTO Salon_Operating_Hours (salon_id, day_of_week, open_time, close_time)
SELECT s.salon_id, d.day_of_week, d.open_time, d.close_time
FROM (SELECT 1 AS salon_id UNION ALL SELECT 2 UNION ALL SELECT 4) s
CROSS JOIN (
    SELECT '월' AS day_of_week, '10:00:00' AS open_time, '20:00:00' AS close_time
    UNION ALL SELECT '화', '10:00:00', '20:00:00'
    UNION ALL SELECT '수', '10:00:00', '20:00:00'
    UNION ALL SELECT '목', '10:00:00', '20:00:00'
    UNION ALL SELECT '금', '10:00:00', '21:00:00'
    UNION ALL SELECT '토', '10:00:00', '19:00:00'
    UNION ALL SELECT '일', '11:00:00', '18:00:00'
) d;


-- ============================================================
--  Services — category 는 컷/펌/염색/클리닉/세트, concern 은 AI 추천 가중치용
-- ============================================================
--  service_id 1 (앞머리 컷 10,000원) 은 쿠폰 하나로 0원이 되는 시연용 시술이다.
INSERT INTO Services
    (service_id, salon_id, service_name, category, price, duration_minutes, description, concern) VALUES
(1, 1, '앞머리 컷',        '컷',     10000,  20, '앞머리만 다듬는 간단 시술', '앞머리, 잔머리'),
(2, 1, '여성 디자인 컷',   '컷',     35000,  60, '얼굴형에 맞춘 디자인 커트', '얼굴형 보완, 볼륨'),
(3, 1, '볼륨 매직',        '펌',     150000, 180, '뿌리 볼륨과 매직을 동시에', '곱슬머리, 볼륨 다운, 뻗침'),
(4, 1, '전체 염색',        '염색',   90000,  120, '뿌리부터 모발 끝까지 균일한 컬러', '새치, 탈색모, 컬러 유지'),
(5, 1, '두피 스케일링',    '클리닉', 60000,  50, '두피 각질과 피지를 제거하는 케어', '두피 트러블, 비듬, 지성두피'),
(6, 1, '헤어 클리닉',      '클리닉', 80000,  70, '손상모 집중 영양 트리트먼트', '손상모, 푸석함, 갈라짐'),
(7, 2, '남성 컷',          '컷',     25000,  40, '두상에 맞춘 남성 커트',     '숱 많음, 뻗침'),
(8, 2, '히피펌',           '펌',     120000, 150, '자연스러운 웨이브 연출',   '볼륨, 생머리, 스타일링'),
(9, 2, '뿌리 염색',        '염색',   55000,  80, '자란 뿌리만 컬러 보정',     '새치, 뿌리 톤'),
(10, 4, '기본 컷',         '컷',     20000,  40, '성수점 오픈 기념 커트',     '기본 손질'),
(11, 4, '베이직 펌',       '펌',     100000, 140, '성수점 오픈 기념 펌',       '볼륨'),
--  1·2 번은 시연 본선 매장이라 아래 추가 매장 20곳(7종)보다 메뉴가 적으면 안 된다.
--  카테고리 필터에서 "세트"·"클리닉" 을 골랐을 때 강남/홍대점이 빠지는 것도 어색하다.
(12, 1, '드라이 세트',     '세트',   30000,  40, '행사·모임용 드라이 스타일링', '스타일링, 볼륨'),
(13, 2, '여성 디자인컷',   '컷',     33000,  60, '얼굴형에 맞춘 디자인 커트',   '얼굴형 보완, 볼륨'),
(14, 2, '헤어 클리닉',     '클리닉', 75000,  70, '손상모 집중 영양 트리트먼트', '손상모, 푸석함, 갈라짐'),
(15, 2, '드라이 세트',     '세트',   28000,  40, '행사·모임용 드라이 스타일링', '스타일링, 볼륨');


-- ============================================================
--  Stylists
-- ============================================================
INSERT INTO Stylists (stylist_id, salon_id, stylist_name, phone_number, description) VALUES
(1, 1, '박원장', '010-1111-0001', '경력 12년 · 커트와 클리닉 전문'),
(2, 1, '이실장', '010-1111-0002', '경력 8년 · 펌과 볼륨 매직 전문'),
(3, 1, '김디자이너', '010-1111-0003', '경력 5년 · 컬러 전문'),
(4, 2, '최원장', '010-1111-0004', '경력 10년 · 남성 커트 전문'),
(5, 2, '정실장', '010-1111-0005', '경력 6년 · 웨이브 펌 전문'),
(6, 4, '오디자이너', '010-1111-0006', '성수점 오픈 멤버'),
--  홍대점도 3명으로 맞춘다 (2명이면 디자이너 선택 단계가 사실상 둘 중 하나가 된다)
(7, 2, '한디자이너', '010-1111-0007', '경력 4년 · 컬러와 클리닉 담당');


-- ============================================================
--  추가 매장 20곳 (salon_id 5~24) — Elasticsearch 검색 시연용
--  전부 active 라 손님 검색에 노출된다. 소유주는 김점주(user 2).
--  이름·주소·소개에 지역/시술 키워드를 흩뿌려 두어, "펌"·"염색"·"강남"·
--  "남성" 같은 검색어가 서로 다른 매장 묶음을 돌려주도록 했다.
--  아래 Services/영업시간/디자이너/스케줄은 이 매장들까지 한꺼번에 채운다.
-- ============================================================
INSERT INTO Salons
    (salon_id, owner_id, salon_name, address, phone_number, description,
     average_rating, image_url, latitude, longitude, activation_status) VALUES
(5,  2, '클래식 바버샵 강남', '서울특별시 강남구 강남대로 390', '02-501-0105', '남성 전문 바버샵. 가르마펌과 스포츠컷이 강점입니다.',        4.7, '/resources/images/salon1.svg', 37.4979, 127.0276, 'active'),
(6,  2, '컬러랩 청담',        '서울특별시 강남구 도산대로 430', '02-501-0106', '탈색과 애쉬 컬러 염색 전문 살롱입니다.',                     4.5, '/resources/images/salon2.svg', 37.5250, 127.0530, 'active'),
(7,  2, '펌하우스 신사',      '서울특별시 강남구 압구정로 110', '02-501-0107', '디지털펌·볼륨매직 전문. 곱슬머리 교정 상담 가능.',           4.4, '/resources/images/salon4.svg', 37.5240, 127.0230, 'active'),
(8,  2, '데일리헤어 홍대',    '서울특별시 마포구 홍익로 20',    '02-501-0108', '합리적인 가격의 커트와 스타일링. 20대 단골 다수.',           4.2, '/resources/images/salon1.svg', 37.5561, 126.9230, 'active'),
(9,  2, '모드살롱 연남',      '서울특별시 마포구 연남로 30',    '02-501-0109', '연남동 감성 인테리어. 여성 디자인컷과 클리닉 전문.',         4.6, '/resources/images/salon2.svg', 37.5630, 126.9250, 'active'),
(10, 2, '스타일리쉬 합정',    '서울특별시 마포구 양화로 45',    '02-501-0110', '웨딩·행사 헤어 세트 전문. 예약제 운영.',                     4.3, '/resources/images/salon4.svg', 37.5495, 126.9135, 'active'),
(11, 2, '헤어살롱 종로',      '서울특별시 종로구 종로 100',     '02-501-0111', '30년 전통의 동네 미용실. 커트와 파마가 저렴합니다.',         4.1, '/resources/images/salon1.svg', 37.5700, 126.9910, 'active'),
(12, 2, '뷰티풀 명동',        '서울특별시 중구 명동길 25',      '02-501-0112', '외국인 관광객도 많이 찾는 컬러·펌 살롱.',                    4.0, '/resources/images/salon2.svg', 37.5636, 126.9850, 'active'),
(13, 2, '살롱드누보 이태원',  '서울특별시 용산구 이태원로 200', '02-501-0113', '트렌디한 컬러와 남성 스타일링 전문.',                        4.4, '/resources/images/salon4.svg', 37.5345, 126.9945, 'active'),
(14, 2, '프리미엄 한남',      '서울특별시 용산구 한남대로 40',  '02-501-0114', '두피 스케일링과 헤어 클리닉 집중 케어.',                     4.8, '/resources/images/salon1.svg', 37.5340, 127.0000, 'active'),
(15, 2, '내추럴헤어 성수',    '서울특별시 성동구 성수이로 80',  '02-501-0115', '자연스러운 펌과 손상모 클리닉 전문.',                        4.5, '/resources/images/salon2.svg', 37.5445, 127.0560, 'active'),
(16, 2, '컷앤펌 왕십리',      '서울특별시 성동구 왕십리로 300', '02-501-0116', '빠른 커트와 기본 펌 위주의 실속 매장.',                      3.9, '/resources/images/salon4.svg', 37.5610, 127.0370, 'active'),
(17, 2, '살롱미러 잠실',      '서울특별시 송파구 올림픽로 300', '02-501-0117', '잠실 대형 살롱. 디자이너 10인 상주.',                        4.3, '/resources/images/salon1.svg', 37.5133, 127.1000, 'active'),
(18, 2, '헤어랩 건대',        '서울특별시 광진구 아차산로 200', '02-501-0118', '대학가 인기 매장. 남성 커트와 컬러 강점.',                   4.2, '/resources/images/salon2.svg', 37.5405, 127.0700, 'active'),
(19, 2, '엘레강스 여의도',    '서울특별시 영등포구 여의대로 24','02-501-0119', '직장인 대상 점심시간 빠른 커트 예약제.',                     4.1, '/resources/images/salon4.svg', 37.5215, 126.9245, 'active'),
(20, 2, '뷰살롱 목동',        '서울특별시 양천구 목동로 100',   '02-501-0120', '가족 단위 손님 많은 동네 미용실. 염색 전문.',                4.0, '/resources/images/salon1.svg', 37.5260, 126.8750, 'active'),
(21, 2, '더헤어 노원',        '서울특별시 노원구 노해로 450',   '02-501-0121', '펌과 매직 전문. 학생 할인 운영.',                            3.8, '/resources/images/salon2.svg', 37.6540, 127.0600, 'active'),
(22, 2, '살롱블룸 신촌',      '서울특별시 서대문구 신촌로 90',  '02-501-0122', '신촌 대학가 트렌디 살롱. 컬러·클리닉.',                      4.2, '/resources/images/salon4.svg', 37.5550, 126.9370, 'active'),
(23, 2, '헤어스토리 구로',    '서울특별시 구로구 디지털로 300', '02-501-0123', 'IT단지 직장인 대상 남성 커트·펌.',                           4.0, '/resources/images/salon1.svg', 37.4850, 126.9010, 'active'),
(24, 2, '아뜰리에 방배',      '서울특별시 서초구 방배로 100',   '02-501-0124', '1:1 프라이빗 디자인컷과 두피 케어.',                         4.6, '/resources/images/salon2.svg', 37.4810, 126.9970, 'active');

-- 추가 매장별 시술 3종 (컷/펌/염색). 가격은 salon_id 로 살짝 달리해 최저가가 매장마다 다르게.
INSERT INTO Services (salon_id, service_name, category, price, duration_minutes, description, concern)
SELECT s.salon_id, t.service_name, t.category,
       t.base_price + (s.salon_id * 300), t.duration_minutes, t.description, t.concern
FROM (SELECT salon_id FROM Salons WHERE salon_id BETWEEN 5 AND 24) s
CROSS JOIN (
    SELECT '커트'   AS service_name, '컷'   AS category, 18000  AS base_price, 40  AS duration_minutes, '기본 커트'          AS description, '기본 손질'        AS concern
    UNION ALL SELECT '일반펌',       '펌',   90000,  120, '자연스러운 웨이브 펌', '볼륨, 곱슬머리'
    UNION ALL SELECT '뿌리염색',     '염색', 50000,  90,  '뿌리 컬러 보정',       '새치, 뿌리 톤'
) t;

-- 추가 매장별 시술 3종 더 (클리닉/세트/디자인컷) — 컷·펌·염색만 있으면
-- 카테고리 필터에서 "클리닉"·"세트" 를 고르는 순간 20곳이 통째로 사라진다.
INSERT INTO Services (salon_id, service_name, category, price, duration_minutes, description, concern)
SELECT s.salon_id, t.service_name, t.category,
       t.base_price + (s.salon_id * 300), t.duration_minutes, t.description, t.concern
FROM (SELECT salon_id FROM Salons WHERE salon_id BETWEEN 5 AND 24) s
CROSS JOIN (
    SELECT '여성 디자인컷' AS service_name, '컷'   AS category, 32000 AS base_price, 60 AS duration_minutes, '얼굴형에 맞춘 디자인 커트' AS description, '얼굴형 보완, 볼륨' AS concern
    UNION ALL SELECT '헤어 클리닉',  '클리닉', 70000, 70, '손상모 집중 영양 트리트먼트', '손상모, 푸석함, 갈라짐'
    UNION ALL SELECT '드라이 세트',  '세트',   25000, 40, '행사·모임용 드라이 스타일링', '스타일링, 볼륨'
) t;

-- 매장 성격(Salons.description)에 맞춘 대표 시술 1종.
-- 20곳이 전부 같은 메뉴만 갖고 있으면 매장 비교·AI 추천에서 답이 하나로 고정된다.
INSERT INTO Services (salon_id, service_name, category, price, duration_minutes, description, concern) VALUES
(5,  '가르마펌',          '펌',     70000,  90,  '남성 가르마 라인 고정 펌',        '뻗침, 앞머리, 스타일링'),
(6,  '애쉬 탈색',         '염색',   180000, 240, '2회 탈색 후 애쉬 톤 마무리',      '탈색모, 컬러 유지'),
(7,  '디지털펌',          '펌',     160000, 200, '열펌으로 컬을 오래 유지',          '곱슬머리, 볼륨, 컬 유지'),
(8,  '남성 컷',           '컷',     22000,  40,  '두상에 맞춘 남성 커트',            '숱 많음, 뻗침'),
(9,  '두피 스케일링',     '클리닉', 58000,  50,  '두피 각질과 피지를 제거하는 케어', '두피 트러블, 비듬, 지성두피'),
(10, '웨딩 헤어 세트',    '세트',   120000, 90,  '예식·행사용 업스타일',             '스타일링, 행사'),
(11, '어르신 파마',       '펌',     45000,  100, '짧은 모발용 클래식 파마',          '볼륨, 새치'),
(12, '전체 염색',         '염색',   85000,  120, '뿌리부터 끝까지 균일한 컬러',      '새치, 컬러 유지'),
(13, '남성 다운펌',       '펌',     55000,  70,  '뜨는 옆머리를 눌러주는 펌',        '뻗침, 숱 많음'),
(14, '두피 집중 케어',    '클리닉', 130000, 90,  '두피 스케일링 + 앰플 관리 패키지', '탈모, 두피 트러블, 손상모'),
(15, '내추럴 볼륨펌',     '펌',     110000, 150, '뿌리 볼륨 위주의 자연스러운 펌',   '볼륨, 생머리'),
(16, '스피드 컷',         '컷',     15000,  25,  '예약 없이 빠르게 받는 커트',       '기본 손질'),
(17, '레이어드 컷',       '컷',     38000,  70,  '층을 낸 여성 커트',                '얼굴형 보완, 볼륨'),
(18, '학생 컷',           '컷',     14000,  30,  '학생증 제시 시 할인 커트',         '기본 손질'),
(19, '점심시간 컷',       '컷',     28000,  30,  '30분 안에 끝내는 직장인 커트',     '기본 손질, 스타일링'),
(20, '새치 염색',         '염색',   48000,  70,  '새치만 자연스럽게 커버',           '새치, 뿌리 톤'),
(21, '볼륨 매직',         '펌',     140000, 180, '뿌리 볼륨과 매직을 동시에',        '곱슬머리, 볼륨 다운, 뻗침'),
(22, '옴브레 염색',       '염색',   150000, 180, '뿌리에서 끝으로 흐르는 그라데이션','탈색모, 컬러 유지'),
(23, '남성 스포츠컷',     '컷',     20000,  30,  '짧고 단정한 남성 커트',            '숱 많음, 기본 손질'),
(24, '프라이빗 디자인컷', '컷',     55000,  80,  '1:1 상담 후 진행하는 디자인 커트', '얼굴형 보완, 손상모');

-- 추가 매장 영업시간 (7일)
INSERT INTO Salon_Operating_Hours (salon_id, day_of_week, open_time, close_time)
SELECT s.salon_id, d.day_of_week, d.open_time, d.close_time
FROM (SELECT salon_id FROM Salons WHERE salon_id BETWEEN 5 AND 24) s
CROSS JOIN (
    SELECT '월' AS day_of_week, '10:00:00' AS open_time, '20:00:00' AS close_time
    UNION ALL SELECT '화', '10:00:00', '20:00:00'
    UNION ALL SELECT '수', '10:00:00', '20:00:00'
    UNION ALL SELECT '목', '10:00:00', '20:00:00'
    UNION ALL SELECT '금', '10:00:00', '21:00:00'
    UNION ALL SELECT '토', '10:00:00', '19:00:00'
    UNION ALL SELECT '일', '11:00:00', '18:00:00'
) d;

-- 추가 매장별 디자이너 3명 (원장/실장/디자이너).
-- 1명뿐이면 예약 화면의 디자이너 선택 단계가 사실상 건너뛰어지고, 그 1명이 휴무인 날은
-- 매장 전체가 예약 불가로 보인다. 성(姓)은 salon_id 로 돌려 매장마다 다른 조합이 나온다.
-- 스케줄은 아래 공통 INSERT 가 Stylists 전체를 대상으로 한꺼번에 채운다.
INSERT INTO Stylists (salon_id, stylist_name, phone_number, description)
SELECT s.salon_id,
       CONCAT(ELT(MOD(s.salon_id * 3 + t.n, 12) + 1,
                  '김','이','박','최','정','강','조','윤','장','임','한','오'),
              t.title),
       CONCAT('010-2222-', LPAD(s.salon_id * 3 + t.n, 4, '0')),
       t.description
FROM (SELECT salon_id FROM Salons WHERE salon_id BETWEEN 5 AND 24) s
CROSS JOIN (
    SELECT 1 AS n, '원장'     AS title, '경력 12년 · 매장 총괄 · 커트 전문'  AS description
    UNION ALL SELECT 2, '실장',     '경력 7년 · 펌과 볼륨 매직 전문'
    UNION ALL SELECT 3, '디자이너', '경력 4년 · 컬러와 트렌드 스타일링'
) t
-- 디자이너 목록은 stylist_id 순으로 나온다. ORDER BY 가 없으면 원장이 맨 뒤로 밀린다.
ORDER BY s.salon_id, t.n;


-- ============================================================
--  Stylist_Schedules — 오늘부터 21일치
--  절대 날짜를 쓰면 안 된다. 발표일에 시간표가 비어버린다.
--  위에서 추가한 매장 디자이너까지 전부 한꺼번에 채운다 (Stylists 전체 대상).
-- ============================================================
INSERT INTO Stylist_Schedules (stylist_id, date, start_time, end_time, is_available)
WITH RECURSIVE days(n) AS (
    SELECT 0 UNION ALL SELECT n + 1 FROM days WHERE n < 20
)
SELECT s.stylist_id, CURDATE() + INTERVAL days.n DAY, '10:00:00', '20:00:00', 1
FROM Stylists s CROSS JOIN days;

-- 디자이너 휴무 시연용 — 이실장은 3일 뒤 휴무 (그날 시간표가 비는 것을 보여준다)
UPDATE Stylist_Schedules
   SET is_available = 0
 WHERE stylist_id = 2
   AND date = CURDATE() + INTERVAL 3 DAY;


-- ============================================================
--  SalonNotices
-- ============================================================
--  매장 3(준비중·필수정보 미입력)만 일부러 비워 둔다. 여기에 공지를 넣어도
--  필수정보 체크리스트(주소/영업시간/시술메뉴/디자이너)에는 안 잡히지만,
--  "아무것도 없는 매장" 이라는 시연 전제가 흐려진다.
INSERT INTO SalonNotices (notice_id, salon_id, title, content) VALUES
(1, 1, '8월 휴무 안내', '매주 셋째 주 화요일은 정기 휴무입니다. 예약에 참고해 주세요.'),
(2, 1, '신규 클리닉 오픈', '두피 스케일링 메뉴가 새로 추가되었습니다. 8월 한정 20% 할인.'),
(3, 2, '주차 안내', '건물 지하 2층 주차장 이용 시 2시간 무료입니다.'),
(4, 2, '컬러 시술 예약 안내', '탈색이 포함된 컬러는 시술 시간이 길어 마감 3시간 전까지만 예약을 받습니다.'),
(5, 4, '오픈 예정 안내', '성수점은 준비를 마치는 대로 오픈합니다. 오픈 첫 주 전 시술 10% 할인 예정입니다.');

-- 추가 매장 20곳 공지 2건씩. 매장 상세의 공지 탭이 전부 비어 있으면
-- 매장을 아무거나 눌러 보여 주는 시연에서 빈 화면이 나온다.
INSERT INTO SalonNotices (salon_id, title, content)
SELECT s.salon_id, t.title, CONCAT(s.salon_name, t.content)
FROM (SELECT salon_id, salon_name FROM Salons WHERE salon_id BETWEEN 5 AND 24) s
JOIN (
    SELECT 0 AS grp, '정기 휴무 안내'    AS title, ' 은 매월 첫째 주 월요일 정기 휴무입니다.'                      AS content
    UNION ALL SELECT 0, '신규 고객 이벤트', ' 첫 방문 고객께 트리트먼트 1회를 무료로 드립니다.'
    UNION ALL SELECT 1, '주차 안내',        ' 방문 고객께 인근 주차장 2시간 무료 주차권을 드립니다.'
    UNION ALL SELECT 1, '예약제 운영 안내', ' 은 100% 예약제로 운영됩니다. 방문 전 예약 부탁드립니다.'
) t ON t.grp = MOD(s.salon_id, 2);


-- ============================================================
--  Reservations
-- ============================================================
--  pending 은 일부러 넣지 않는다 — 생성 10분이 지난 pending 은
--  expireStalePending() 이 자동으로 접기 때문에 시연 시작 전에 사라진다.
--
--  1 완료(리뷰 있음)          2일 전
--  2 완료(리뷰 없음)          5일 전   → 유빈 리뷰 작성 시연 + 적립 1,000원
--  3 확정                     2일 뒤   → 도율 "거절" 시연 대상 (결제가 ZERO 라 환불 API 안 탐)
--  4 확정                     1일 전   → 도율 "노쇼" 시연 대상 (노쇼는 환불 없음)
--  5 확정                     5일 뒤   → 용찬 예약내역·캘린더용 (건드리지 않음)
--  6 확정                     8일 뒤   → 용찬 캘린더 다건 표시용 (KAKAOPAY 라 거절 대상으로 쓰면 안 됨)
--  7 취소(거절 + 사유)        7일 전   → 상태 이력 표시용
--  8 취소(노쇼)               9일 전   → 상태 이력 표시용
--  9 완료(리뷰 있음)          12일 전
INSERT INTO Reservations
    (reservation_id, user_id, salon_id, stylist_id, service_id, reservation_time, status, reject_reason, cancel_type) VALUES
(1, 5, 1, 1, 2,  CURDATE() - INTERVAL 2 DAY  + INTERVAL 14 HOUR, 'completed', NULL, NULL),
(2, 5, 1, 2, 3,  CURDATE() - INTERVAL 5 DAY  + INTERVAL 11 HOUR, 'completed', NULL, NULL),
(3, 5, 1, 1, 4,  CURDATE() + INTERVAL 2 DAY  + INTERVAL 15 HOUR, 'confirmed', NULL, NULL),
(4, 6, 1, 3, 2,  CURDATE() - INTERVAL 1 DAY  + INTERVAL 16 HOUR, 'confirmed', NULL, NULL),
(5, 5, 2, 4, 7,  CURDATE() + INTERVAL 5 DAY  + INTERVAL 13 HOUR, 'confirmed', NULL, NULL),
(6, 5, 1, 2, 6,  CURDATE() + INTERVAL 8 DAY  + INTERVAL 17 HOUR, 'confirmed', NULL, NULL),
(7, 6, 1, 1, 5,  CURDATE() - INTERVAL 7 DAY  + INTERVAL 12 HOUR, 'cancelled', '디자이너 개인 사정으로 부득이하게 취소되었습니다.', 'rejected'),
(8, 7, 1, 3, 2,  CURDATE() - INTERVAL 9 DAY  + INTERVAL 18 HOUR, 'cancelled', '예약 시간에 방문하지 않으셨습니다.', 'no_show'),
(9, 6, 2, 5, 8,  CURDATE() - INTERVAL 12 DAY + INTERVAL 14 HOUR, 'completed', NULL, NULL);


-- ============================================================
--  Coupons
-- ============================================================
--  3번(웰컴 1만원)은 앞머리 컷(10,000원)에만 쓰이는 쿠폰이라 최종 금액이 0원이 된다.
--  0원이면 CheckoutService 가 pg_provider 를 ZERO 로 잡아 카카오페이를 거치지 않는다.
--  결제창이 안 뜰 때의 백업 시연 경로.
INSERT INTO Coupons
    (coupon_id, salon_id, service_id, coupon_name, coupon_code, discount_type, discount_value,
     max_discount, min_order_amount, valid_from, valid_until, issue_type, once_per_user, is_active) VALUES
(1, NULL, NULL, '여름맞이 20% 할인',   NULL,      'percent', 20.00, 30000, 0,
    CURDATE() - INTERVAL 10 DAY, CURDATE() + INTERVAL 60 DAY, 'admin',  0, 1),
(2, NULL, NULL, '신규 가입 5,000원',   NULL,      'amount',  5000.00, NULL, 20000,
    CURDATE() - INTERVAL 10 DAY, CURDATE() + INTERVAL 60 DAY, 'signup', 1, 1),
(3, 1,    1,    '앞머리 컷 무료 쿠폰', NULL,      'amount',  10000.00, NULL, 0,
    CURDATE() - INTERVAL 10 DAY, CURDATE() + INTERVAL 60 DAY, 'admin',  0, 1),
(4, NULL, NULL, '코드 등록 3,000원',   'SALU2026','amount',  3000.00, NULL, 10000,
    CURDATE() - INTERVAL 10 DAY, CURDATE() + INTERVAL 60 DAY, 'code',   1, 1);

--  4번(코드형)은 일부러 발급하지 않는다 — 마이페이지에서 SALU2026 을 직접 등록하는 시연용.
INSERT INTO User_Coupons (user_coupon_id, user_id, coupon_id, status, expires_at) VALUES
(1, 5, 1, 'available', CURDATE() + INTERVAL 60 DAY),
(2, 5, 2, 'available', CURDATE() + INTERVAL 60 DAY),
(3, 5, 3, 'available', CURDATE() + INTERVAL 60 DAY),
(4, 6, 1, 'available', CURDATE() + INTERVAL 60 DAY);


-- ============================================================
--  Payments
-- ============================================================
--  3번 예약(도율 거절 시연 대상)만 pg_provider 를 ZERO 로 둔다.
--  KAKAOPAY 로 두면 거절 시 가짜 tid 로 카카오 취소 API 를 호출해 실패한다.
INSERT INTO Payments
    (payment_id, reservation_id, user_id, amount, original_amount, coupon_discount, point_used,
     user_coupon_id, pg_provider, payment_method, payment_status, transaction_id, paid_at) VALUES
(1, 1, 5, 35000,  35000,  0,     0, NULL, 'KAKAOPAY', '카카오페이', 'completed', 'DEMO-TID-0001', CURDATE() - INTERVAL 2 DAY),
(2, 2, 5, 150000, 150000, 0,     0, NULL, 'KAKAOPAY', '카카오페이', 'completed', 'DEMO-TID-0002', CURDATE() - INTERVAL 5 DAY),
(3, 3, 5, 0,      90000,  0, 90000, NULL, 'ZERO',     '전액 할인',   'completed', 'ZERO-3',        CURDATE() - INTERVAL 1 DAY),
(4, 4, 6, 35000,  35000,  0,     0, NULL, 'KAKAOPAY', '카카오페이', 'completed', 'DEMO-TID-0004', CURDATE() - INTERVAL 3 DAY),
(5, 5, 5, 25000,  25000,  0,     0, NULL, 'KAKAOPAY', '카카오페이', 'completed', 'DEMO-TID-0005', CURDATE() - INTERVAL 1 DAY),
(6, 6, 5, 80000,  80000,  0,     0, NULL, 'KAKAOPAY', '카카오페이', 'completed', 'DEMO-TID-0006', CURDATE()),
(7, 7, 6, 60000,  60000,  0,     0, NULL, 'KAKAOPAY', '카카오페이', 'refunded',  'DEMO-TID-0007', CURDATE() - INTERVAL 8 DAY),
(8, 8, 7, 35000,  35000,  0,     0, NULL, 'KAKAOPAY', '카카오페이', 'completed', 'DEMO-TID-0008', CURDATE() - INTERVAL 10 DAY),
(9, 9, 6, 120000, 120000, 0,     0, NULL, 'KAKAOPAY', '카카오페이', 'completed', 'DEMO-TID-0009', CURDATE() - INTERVAL 12 DAY);


-- ============================================================
--  Point_Transactions — Users.point_balance 와 balance_after 가 맞아야 한다
-- ============================================================
--  손님1 : 5,000(리뷰) → 8,000(리뷰) = 잔액 8,000
--  손님2 : 1,500(관리자 지급)        = 잔액 1,500
--  적립금은 1,000원 미만이면 결제 화면에서 입력칸 자체가 열리지 않는다.
INSERT INTO Point_Transactions
    (user_id, reservation_id, tx_type, amount, balance_after, description, created_at) VALUES
(5, 1,    'earn', 5000, 5000, '리뷰 작성 적립',   CURDATE() - INTERVAL 2 DAY),
(5, NULL, 'admin', 3000, 8000, '이벤트 적립금 지급', CURDATE() - INTERVAL 1 DAY),
(6, 9,    'earn', 1500, 1500, '리뷰 작성 적립',   CURDATE() - INTERVAL 12 DAY);


-- ============================================================
--  Reviews — 2번 예약은 일부러 리뷰를 남기지 않는다 (유빈 리뷰 작성 시연)
-- ============================================================
INSERT INTO Reviews (review_id, user_id, salon_id, reservation_id, rating, comment, created_at) VALUES
(1, 5, 1, 1, 5, '커트 상담을 꼼꼼히 해주셔서 만족스러웠습니다. 얼굴형에 딱 맞게 잘라주셨어요.', CURDATE() - INTERVAL 2 DAY),
(2, 6, 2, 9, 4, '히피펌 결이 자연스럽게 잘 나왔어요. 다만 대기 시간이 좀 길었습니다.',           CURDATE() - INTERVAL 11 DAY),
(3, 7, 1, 8, 3, '시술 자체는 괜찮았는데 예약 시간이 밀렸어요.',                                   CURDATE() - INTERVAL 9 DAY);


-- ============================================================
--  매장별 예약 이력 — 손님에게 노출되는 매장(active) 전부
-- ============================================================
--  위의 예약 1~9 는 시나리오가 정해진 시연용이라 손대지 않는다.
--  여기서는 매장 목록·상세·점주 대시보드가 비어 보이지 않도록 배경 예약을 깐다.
--
--  전부 배경 손님(user_id 8~17) 명의다. 아래 결제·리뷰 INSERT 도
--  "user_id BETWEEN 8 AND 17" 하나로 이 예약들만 골라낸다
--  (reservation_id > 9 같은 AUTO_INCREMENT 가정에 기대지 않기 위해서다).
--
--  매장당 10~16건 (salon_id 로 갈린다) — n 별 성격:
--    4,5,9,14 → 확정(미래)   7 → 취소(손님 자가취소)   12 → 취소(노쇼)   나머지 → 완료(과거)
--
--  건수를 이보다 줄이면 매장당 리뷰가 2~3건까지 떨어지고, 그러면 평균 별점이
--  표본이 작아 크게 튄다 (아래에서 평균을 다시 계산하므로 목록의 별점이 통째로 흔들린다).
INSERT INTO Reservations
    (user_id, salon_id, stylist_id, service_id, reservation_time, status, reject_reason, cancel_type)
WITH RECURSIVE seq(n) AS (
    SELECT 1 UNION ALL SELECT n + 1 FROM seq WHERE n < 16
),
sal AS (
    SELECT salon_id FROM Salons WHERE activation_status = 'active' AND closed_at IS NULL
),
st AS (
    SELECT salon_id, stylist_id,
           ROW_NUMBER() OVER (PARTITION BY salon_id ORDER BY stylist_id) AS rn,
           COUNT(*)     OVER (PARTITION BY salon_id)                     AS cnt
    FROM Stylists
),
sv AS (
    SELECT salon_id, service_id,
           ROW_NUMBER() OVER (PARTITION BY salon_id ORDER BY service_id) AS rn,
           COUNT(*)     OVER (PARTITION BY salon_id)                     AS cnt
    FROM Services
)
SELECT 8 + MOD(sal.salon_id * 3 + seq.n, 10),
       sal.salon_id,
       st.stylist_id,
       sv.service_id,
       CASE WHEN seq.n IN (4, 5, 9, 14)
            THEN CURDATE() + INTERVAL (seq.n - 3 + MOD(sal.salon_id, 5)) DAY
                           + INTERVAL (11 + MOD(sal.salon_id + seq.n, 7)) HOUR
            ELSE CURDATE() - INTERVAL (seq.n * 6 + MOD(sal.salon_id, 7)) DAY
                           + INTERVAL (11 + MOD(sal.salon_id + seq.n, 7)) HOUR
       END,
       CASE WHEN seq.n IN (4, 5, 9, 14) THEN 'confirmed'
            WHEN seq.n IN (7, 12)        THEN 'cancelled'
            ELSE                              'completed' END,
       CASE WHEN seq.n = 7  THEN '고객 요청으로 취소되었습니다.'
            WHEN seq.n = 12 THEN '예약 시간에 방문하지 않으셨습니다.'
            ELSE NULL END,
       CASE WHEN seq.n = 7  THEN 'user_cancelled'
            WHEN seq.n = 12 THEN 'no_show'
            ELSE NULL END
FROM sal
CROSS JOIN seq
JOIN st ON st.salon_id = sal.salon_id AND st.rn = MOD(seq.n, st.cnt) + 1
JOIN sv ON sv.salon_id = sal.salon_id AND sv.rn = MOD(seq.n * 2, sv.cnt) + 1
WHERE seq.n <= 10 + MOD(sal.salon_id, 7);


-- 배경 예약의 결제 — Payments 는 예약과 1:1 이라, 없으면 예약 상세에서 결제 정보가 빈다.
-- 쿠폰·적립금은 쓰지 않은 정가 결제로 둔다 (User_Coupons 재고를 건드리지 않기 위해서다).
-- paid_at 이 미래가 되지 않도록 NOW() 로 잘라 둔다 (확정 예약은 시술일이 아직 안 왔다).
INSERT INTO Payments
    (reservation_id, user_id, amount, original_amount, coupon_discount, point_used,
     user_coupon_id, pg_provider, payment_method, payment_status, transaction_id, paid_at)
SELECT r.reservation_id, r.user_id, sv.price, sv.price, 0, 0,
       NULL, 'KAKAOPAY', '카카오페이',
       -- 노쇼는 환불하지 않는다 (선불 금액을 매장이 정산한다) — 예약 1~9 의 8번과 같은 규칙
       CASE WHEN r.cancel_type = 'user_cancelled' THEN 'refunded' ELSE 'completed' END,
       CONCAT('DEMO-TID-', LPAD(r.reservation_id, 6, '0')),
       LEAST(r.reservation_time - INTERVAL 1 DAY, NOW())
FROM Reservations r
JOIN Services sv ON sv.service_id = r.service_id
WHERE r.user_id BETWEEN 8 AND 17;


-- 배경 예약의 리뷰 — 완료 예약 중 6건에 1건은 일부러 리뷰를 비운다.
-- (전부 리뷰가 달려 있으면 "리뷰 작성 가능" 목록이 비어 리뷰 작성 시연을 못 한다)
-- 별점은 Salons.average_rating(위에서 손으로 정해 둔 목표값) 을 중심으로 흔들고,
-- 실제 평균은 이 블록 아래에서 다시 계산해 덮어쓴다.
INSERT INTO Reviews (user_id, salon_id, reservation_id, rating, comment, created_at)
SELECT t.user_id, t.salon_id, t.reservation_id, t.rating,
       CASE WHEN t.rating >= 4
            THEN ELT(MOD(t.reservation_id, 6) + 1,
                     '상담부터 마무리까지 꼼꼼하셨어요. 다음에도 여기로 올 것 같습니다.',
                     '원하는 스타일을 사진으로 보여드렸는데 거의 그대로 나왔어요.',
                     '매장이 깔끔하고 대기 없이 바로 시술 들어가서 좋았습니다.',
                     '가격 대비 만족도가 높아요. 주변에도 추천했습니다.',
                     '두피가 예민한 편인데 자극 없이 편하게 받았어요.',
                     '시술 후 홈케어 방법까지 알려주셔서 도움이 많이 됐습니다.')
            ELSE ELT(MOD(t.reservation_id, 3) + 1,
                     '결과는 무난했는데 예약 시간보다 조금 밀려서 기다렸습니다.',
                     '시술은 괜찮았지만 매장이 붐벼서 조금 정신없었어요.',
                     '나쁘지 않았어요. 다만 상담이 조금 더 자세했으면 좋았을 것 같습니다.')
       END,
       t.created_at
FROM (
    SELECT r.user_id, r.salon_id, r.reservation_id,
           -- 오프셋을 reservation_id 나머지로 잡으면 매장마다 +1/-1 개수가 안 맞아
           -- 평균이 목표값에서 0.5 넘게 밀린다. 매장 안에서의 순번으로 돌려 균형을 맞춘다.
           LEAST(5, GREATEST(1,
               CAST(ROUND(s.average_rating) AS SIGNED)
               + CASE MOD(ROW_NUMBER() OVER (PARTITION BY r.salon_id ORDER BY r.reservation_id), 4)
                      WHEN 1 THEN 1 WHEN 3 THEN -1 ELSE 0 END
           )) AS rating,
           r.reservation_time + INTERVAL 1 DAY AS created_at
    FROM Reservations r
    JOIN Salons s ON s.salon_id = r.salon_id
    WHERE r.user_id BETWEEN 8 AND 17
      AND r.status = 'completed'
      AND MOD(r.reservation_id, 6) <> 0
) t;


-- Salons.average_rating 는 Reviews 를 캐시한 값이다 (ReviewMapper.refreshSalonAverageRating
-- 과 같은 식으로 다시 계산한다). 위에서 손으로 적어 둔 목표값이 실제 리뷰와 어긋난 채
-- 남으면, 매장 목록의 별점과 상세의 리뷰 목록이 서로 다른 숫자를 말하게 된다.
UPDATE Salons s
   SET s.average_rating = COALESCE(
         (SELECT ROUND(AVG(rv.rating), 1) FROM Reviews rv WHERE rv.salon_id = s.salon_id), 0);


-- ============================================================
--  Wishlists
-- ============================================================
INSERT INTO Wishlists (user_id, salon_id) VALUES
(5, 1),
(5, 2),
(6, 1);


-- ============================================================
--  Chats / Messages — 수겸 1:1 상담 시연 (빈 방보다 대화가 있는 편이 자연스럽다)
-- ============================================================
INSERT INTO Chats (chat_id, user1_id, user2_id, salon_id) VALUES
(1, 5, 2, 1),
(2, 6, 2, 2);

INSERT INTO Messages (chat_id, sender_id, message_content, is_read, sent_at) VALUES
(1, 5, '안녕하세요, 볼륨 매직 시술 시간이 얼마나 걸릴까요?',              1, NOW() - INTERVAL 3 HOUR),
(1, 2, '안녕하세요! 모발 길이에 따라 다르지만 보통 3시간 정도 소요됩니다.', 1, NOW() - INTERVAL 2 HOUR),
(1, 5, '감사합니다. 주차도 가능한가요?',                                   0, NOW() - INTERVAL 1 HOUR),
(2, 6, '히피펌 예약하려는데 이번 주 토요일 가능할까요?',                   0, NOW() - INTERVAL 30 MINUTE);


-- ============================================================
--  Advertisements — 관리자가 등록하는 메인 배너
-- ============================================================
INSERT INTO Advertisements
    (advertisement_id, title, description, image_url, target_url, display_order, active) VALUES
(1, '여름맞이 펌 20% 할인', '살루 헤어 전 매장 · 8월 한정', '/resources/images/ad1.svg', '/common/home', 1, 1),
(2, '첫 예약 5,000원 쿠폰', '지금 가입하면 즉시 지급',       '/resources/images/ad2.svg', '/common/coupons', 2, 1),
(3, '리뷰 쓰면 1,000원 적립', '시술 후 사진 리뷰 이벤트',    '/resources/images/ad3.svg', '/common/my-reviews', 3, 1);


-- ============================================================
--  커뮤니티 — 병휴 시연
-- ============================================================
INSERT INTO Posts (post_id, user_id, title, content, category, salon_id, view_count, like_count, dislike_count, report_count, status, created_at) VALUES
(1, 5, '강남에서 볼륨 매직 잘하는 곳 추천해주세요',
    '곱슬이 심한 편인데 자연스럽게 펴주는 곳 찾고 있습니다. 추천 부탁드려요!',
    '질문', NULL, 128, 5, 0, 0, 'visible', NOW() - INTERVAL 5 DAY),
(2, 6, '살루 헤어 강남점 후기 남깁니다',
    '박원장님께 커트 받았는데 상담부터 꼼꼼하셨어요. 재방문 의사 100%입니다.',
    '후기', 1, 342, 12, 1, 0, 'visible', NOW() - INTERVAL 3 DAY),
(3, 7, '광고성 글입니다 클릭하세요 !!!!',
    '지금 바로 연락주세요 특가 진행중 010-0000-0000 링크 클릭 클릭 클릭',
    '자유', NULL, 57, 0, 8, 3, 'visible', NOW() - INTERVAL 1 DAY),
(4, 5, '염색 후 색 빠짐 관리 어떻게 하시나요',
    '애쉬 계열로 염색했는데 2주 만에 다 빠졌어요. 홈케어 팁 공유해주세요.',
    '질문', NULL, 89, 3, 0, 0, 'visible', NOW() - INTERVAL 12 HOUR),
(5, 6, '오늘 홍대점 다녀왔습니다',
    '히피펌 했는데 웨이브가 딱 원하던 느낌이에요. 사진은 나중에 올릴게요.',
    '후기', 2, 45, 2, 0, 0, 'visible', NOW() - INTERVAL 4 HOUR);

INSERT INTO Comments (comment_id, post_id, user_id, content, created_at) VALUES
(1, 1, 6, '살루 헤어 강남점 이실장님 추천드려요. 볼륨 매직 전문이세요.', NOW() - INTERVAL 4 DAY),
(2, 1, 7, '저도 거기 다녀왔는데 만족했습니다.',                          NOW() - INTERVAL 4 DAY),
(3, 2, 5, '후기 감사합니다! 저도 예약해봐야겠어요.',                      NOW() - INTERVAL 2 DAY),
(4, 3, 5, '신고했습니다.',                                                NOW() - INTERVAL 20 HOUR),
(5, 4, 6, '컬러 전용 샴푸 쓰시면 확실히 덜 빠져요.',                      NOW() - INTERVAL 6 HOUR);

INSERT INTO post_likes (post_id, user_id, reaction_type) VALUES
(1, 6, 'like'),
(1, 7, 'like'),
(2, 5, 'like'),
(2, 7, 'like'),
(3, 5, 'dislike'),
(3, 6, 'dislike'),
(4, 6, 'like');

--  미처리 신고 3건 — 신고 큐가 비어 있으면 관리자 신고 처리 시연을 할 수 없다
INSERT INTO post_reports (post_id, user_id, reason, reason_detail) VALUES
(3, 5, 'spam',  NULL),
(3, 6, 'spam',  NULL),
(3, 2, 'other', '연락처를 반복해서 올리고 있습니다.');

INSERT INTO comment_reports (comment_id, user_id, reason, reason_detail) VALUES
(4, 7, 'abuse', NULL);


-- ============================================================
--  Notifications — 손님1 알림함
-- ============================================================
INSERT INTO Notifications (user_id, type, title, message, link_url, ref_id, is_read, created_at) VALUES
(5, 'RESERVATION', '예약이 확정되었습니다', '살루 헤어 강남점 · 전체 염색', '/common/reservation?category=1', 3, 0, NOW() - INTERVAL 1 DAY),
(5, 'COUPON',      '쿠폰이 발급되었습니다', '여름맞이 20% 할인 쿠폰이 도착했습니다', '/common/coupons', 1, 0, NOW() - INTERVAL 2 DAY),
(5, 'CHAT',        '새 메시지가 도착했습니다', '살루 헤어 강남점: 3시간 정도 소요됩니다', '/common/chat?chatId=1', 1, 1, NOW() - INTERVAL 2 HOUR),
(5, 'NOTICE',      '매장 새 공지사항', '살루 헤어 강남점 · 신규 클리닉 오픈', '/common/salonmap', 2, 0, NOW() - INTERVAL 6 HOUR);


-- ============================================================
--  적재 결과 요약 — 실행하면 그대로 화면에 찍힌다.
--  매장 3(준비중·필수정보 미입력)만 시술/디자이너/영업시간이 0 이어야 정상이다.
-- ============================================================
SELECT s.salon_id                                  AS id,
       s.salon_name                                AS 매장,
       s.activation_status                         AS 상태,
       (SELECT COUNT(*) FROM Services            x WHERE x.salon_id = s.salon_id) AS 시술,
       (SELECT COUNT(*) FROM Stylists            x WHERE x.salon_id = s.salon_id) AS 디자이너,
       (SELECT COUNT(*) FROM Salon_Operating_Hours x WHERE x.salon_id = s.salon_id) AS 영업요일,
       (SELECT COUNT(*) FROM SalonNotices        x WHERE x.salon_id = s.salon_id) AS 공지,
       (SELECT COUNT(*) FROM Reservations        x WHERE x.salon_id = s.salon_id) AS 예약,
       (SELECT COUNT(*) FROM Reviews             x WHERE x.salon_id = s.salon_id) AS 리뷰,
       s.average_rating                            AS 평점
FROM Salons s
ORDER BY s.salon_id;
