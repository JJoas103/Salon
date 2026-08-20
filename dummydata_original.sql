-- ============================================================
--  salu (미용실 예약 플랫폼) 더미 데이터
--  참조 순서: Users(owner 추가) -> Salons -> Services/Stylists/Salon_Operating_Hours
--            -> Reservations -> Payments/Reviews
--  기존 Users(user_id 1~7)는 모두 customer 이므로 owner 계정을 8~11로 추가
-- ============================================================

USE salu;

-- ---------- 1. 점주(owner) 계정 추가 (Salons.owner_id 참조용) ----------
INSERT INTO Users (email, password, user_name, phone_number, user_type) values
('test1@salu.com', '$2a$10$uyZ84UlxDOh4sVVoKVoSTue0pi8txpiMtaC3Ae6jWJaYVII2DodLK', 'test1', '010-2000-0001', 'customer'), -- user_id 1
('test2@salu.com', '$2a$10$uyZ84UlxDOh4sVVoKVoSTue0pi8txpiMtaC3Ae6jWJaYVII2DodLK', 'test2', '010-2000-0002', 'customer'), -- user_id 2
('test3@salu.com', '$2a$10$uyZ84UlxDOh4sVVoKVoSTue0pi8txpiMtaC3Ae6jWJaYVII2DodLK', 'test3', '010-2000-0003', 'customer'), -- user_id 3
('test4@salu.com', '$2a$10$uyZ84UlxDOh4sVVoKVoSTue0pi8txpiMtaC3Ae6jWJaYVII2DodLK', 'test4', '010-2000-0004', 'customer'), -- user_id 4
('test5@salu.com', '$2a$10$uyZ84UlxDOh4sVVoKVoSTue0pi8txpiMtaC3Ae6jWJaYVII2DodLK', 'test5', '010-2000-0001', 'customer'), -- user_id 5
('test6@salu.com', '$2a$10$uyZ84UlxDOh4sVVoKVoSTue0pi8txpiMtaC3Ae6jWJaYVII2DodLK', 'test6', '010-2000-0002', 'customer'), -- user_id 6
('test7@salu.com', '$2a$10$uyZ84UlxDOh4sVVoKVoSTue0pi8txpiMtaC3Ae6jWJaYVII2DodLK', 'tsst7', '010-2000-0003', 'customer'), -- user_id 7
('owner1@salu.com', '$2a$10$uyZ84UlxDOh4sVVoKVoSTue0pi8txpiMtaC3Ae6jWJaYVII2DodLK', '이원장', '010-2000-0001', 'owner'), -- user_id 8
('owner2@salu.com', '$2a$10$uyZ84UlxDOh4sVVoKVoSTue0pi8txpiMtaC3Ae6jWJaYVII2DodLK', '박원장', '010-2000-0002', 'owner'), -- user_id 9
('owner3@salu.com', '$2a$10$uyZ84UlxDOh4sVVoKVoSTue0pi8txpiMtaC3Ae6jWJaYVII2DodLK', '최원장', '010-2000-0003', 'owner'), -- user_id 10
('owner4@salu.com', '$2a$10$uyZ84UlxDOh4sVVoKVoSTue0pi8txpiMtaC3Ae6jWJaYVII2DodLK', '정원장', '010-2000-0004', 'owner'); -- user_id 11
-- ---------- 2. Salons (owner_id: 8~11 참조) ----------
INSERT INTO Salons (owner_id, salon_name, address, phone_number, description, average_rating, image_url) VALUES
(8,  '라움헤어',       '서울 강남구 논현동 123-4',   '02-511-1001', '트렌디한 커트와 컬러 전문 살롱',        4.5, NULL), -- salon_id 1
(8,  '소울커트',       '서울 마포구 홍대동 45-6',    '02-511-1002', '홍대 감성의 캐주얼 헤어샵',            4.2, NULL), -- salon_id 2
(9,  '블랑쉬헤어',     '서울 서초구 반포동 78-9',    '02-511-1003', '웨딩/투톤 컬러 전문',                  4.7, NULL), -- salon_id 3
(9,  '그레이스살롱',   '인천 남동구 구월동 12-3',    '032-511-1004', '가족 단골 손님이 많은 동네 미용실',    4.3, NULL), -- salon_id 4
(10, '헤어스튜디오 온', '인천 연수구 송도동 34-5',   '032-511-1005', '남성 전문 클리닉 헤어샵',              4.4, NULL), -- salon_id 5
(10, '살롱드밀',       '서울 성동구 성수동 56-7',    '02-511-1006', '연예인 단골로 유명한 프리미엄 살롱',    4.8, NULL), -- salon_id 6
(11, '위드헤어',       '인천 부평구 부평동 89-1',    '032-511-1007', '합리적인 가격의 실속형 헤어샵',        4.0, NULL), -- salon_id 7
(11, '컬러플레이 헤어', '서울 마포구 연남동 23-4',   '02-511-1008', '탈염/컬러 특화 살롱',                  4.6, NULL), -- salon_id 8
(8,  '에디트헤어',     '서울 용산구 이태원동 67-8',  '02-511-1009', '남녀 커트 및 펌 전문',                 4.1, NULL), -- salon_id 9
(9,  '뮤즈헤어살롱',   '인천 미추홀구 주안동 90-1',  '032-511-1010', '20년 경력 원장님이 직접 시술',        4.9, NULL); -- salon_id 10
-- ---------- 3. Services (salon_id 1~10 참조) ----------
INSERT INTO Services (salon_id, service_name, category, price, duration_minutes, description, concern) VALUES
(1,  '여성컷',           '컷',   25000,  40,  '디자이너 커트 (샴푸 포함)',       '일상 손질 편한 커트, 얼굴형 커버'),        -- service_id 1
(1,  '남성컷',           '컷',   18000,  30,  '남성 스타일 커트',               '짧고 깔끔한 스타일, 이미지 변신'),        -- service_id 2
(2,  '볼륨매직',        '펌',   120000, 150, '자연스러운 볼륨 매직 스트레이트', '곱슬머리, 부스스한 모발, 매끈한 볼륨'),    -- service_id 3
(2,  '뿌리염색',         '염색', 60000,  90,  '새치 커버 뿌리염색',             '새치 커버, 뿌리 탈색'),                   -- service_id 4
(3,  '히피펌',           '펌',   90000, 120, '내추럴 웨이브 히피펌',            '밋밋한 머리, 볼륨 다운, 웨이브 연출'),     -- service_id 5
(4,  '여성컷',           '컷',   22000,  40,  '디자이너 커트',                  '일상 손질 편한 커트, 얼굴형 커버'),        -- service_id 6
(4,  '클리닉트리트먼트', '클리닉', 70000,  60,  '손상모 집중 케어',             '손상모, 갈라짐, 푸석함 완화'),             -- service_id 7
(5,  '남성컷',           '컷',   20000,  30,  '남성 클리닉 커트',               '짧고 깔끔한 스타일, 두피 케어'),          -- service_id 8
(6,  '발레아쥬',        '염색', 150000, 180, '자연스러운 그라데이션 염색',      '칙칙한 톤, 그라데이션 염색, 분위기 전환'), -- service_id 9
(7,  '여성컷',           '컷',   23000,  40,  '디자이너 커트',                  '일상 손질 편한 커트, 얼굴형 커버'),        -- service_id 10
(8,  '셋팅펌',          '펌',   110000, 150, '내추럴 셋팅펌',                   '볼륨 부족, 힘없는 모발, 자연스러운 웨이브'), -- service_id 11
(9,  '남성컷',           '컷',   19000,  30,  '남성 스타일 커트',               '짧고 깔끔한 스타일, 이미지 변신'),        -- service_id 12
(10, '여성컷',           '컷',   24000,  40,  '디자이너 커트',                  '일상 손질 편한 커트, 얼굴형 커버');        -- service_id 13

-- ---------- 4. Stylists (salon_id 1~10 참조) ----------
INSERT INTO Stylists (salon_id, stylist_name, phone_number, description, image_url) VALUES
(1,  '김지은', '010-3000-0001', '커트 전문 디자이너 경력 8년', NULL), -- stylist_id 1
(1,  '박민수', '010-3000-0002', '남성 커트 전문',              NULL), -- stylist_id 2
(2,  '이하늘', '010-3000-0003', '매직/스트레이트 전문',        NULL), -- stylist_id 3
(3,  '최유정', '010-3000-0004', '펌 전문 디자이너',            NULL), -- stylist_id 4
(4,  '정다은', '010-3000-0005', '커트 전문',                    NULL), -- stylist_id 5
(4,  '오세훈', '010-3000-0006', '트리트먼트 전문',              NULL), -- stylist_id 6
(5,  '강태양', '010-3000-0007', '남성 클리닉 전문',            NULL), -- stylist_id 7
(6,  '윤소희', '010-3000-0008', '컬러 전문 원장',              NULL), -- stylist_id 8
(7,  '한지민', '010-3000-0009', '커트 전문',                    NULL), -- stylist_id 9
(8,  '서준혁', '010-3000-0010', '펌 전문 디자이너',            NULL), -- stylist_id 10
(9,  '임수아', '010-3000-0011', '남성/여성 커트 전문',          NULL), -- stylist_id 11
(10, '배도현', '010-3000-0012', '20년 경력 원장',              NULL); -- stylist_id 12

-- ---------- 5. Salon_Operating_Hours (salon_id 1~10, 대표 요일 1건씩) ----------
INSERT INTO Salon_Operating_Hours (salon_id, day_of_week, open_time, close_time) VALUES
(1,  '월', '10:00:00', '20:00:00'),
(2,  '월', '11:00:00', '21:00:00'),
(3,  '월', '10:00:00', '19:00:00'),
(4,  '월', '09:30:00', '20:30:00'),
(5,  '월', '10:00:00', '20:00:00'),
(6,  '월', '11:00:00', '22:00:00'),
(7,  '월', '09:00:00', '19:00:00'),
(8,  '월', '10:00:00', '21:00:00'),
(9,  '월', '10:30:00', '20:30:00'),
(10, '월', '09:00:00', '18:00:00');

-- ---------- 6. Reservations (user_id 1~7 / salon,stylist,service 매칭) ----------
INSERT INTO Reservations (user_id, salon_id, stylist_id, service_id, reservation_time, status) VALUES
(1, 1,  1,  1,  '2026-07-25 14:00:00', 'completed'),  -- reservation_id 1
(2, 1,  2,  2,  '2026-07-20 11:00:00', 'completed'),  -- reservation_id 2
(3, 2,  3,  3,  '2026-07-23 15:00:00', 'pending'),    -- reservation_id 3
(4, 3,  4,  5,  '2026-07-18 10:00:00', 'completed'),  -- reservation_id 4
(5, 4,  5,  6,  '2026-07-26 13:00:00', 'confirmed'),  -- reservation_id 5
(6, 4,  6,  7,  '2026-07-15 16:00:00', 'cancelled'),  -- reservation_id 6
(7, 5,  7,  8,  '2026-07-24 12:00:00', 'pending'),    -- reservation_id 7
(1, 6,  8,  9,  '2026-07-19 17:00:00', 'completed'),  -- reservation_id 8
(2, 7,  9,  10, '2026-07-27 10:00:00', 'completed'),  -- reservation_id 9
(3, 8,  10, 11, '2026-07-16 14:30:00', 'completed'),  -- reservation_id 10
(4, 9,  11, 12, '2026-07-28 11:30:00', 'pending'),    -- reservation_id 11
(5, 10, 12, 13, '2026-07-21 09:00:00', 'cancelled');  -- reservation_id 12
-- ---------- 7. Payments (reservation_id UNIQUE, 금액은 해당 service 가격과 일치) ----------
INSERT INTO Payments (reservation_id, user_id, amount, payment_method, payment_status, transaction_id) VALUES
(1,  1, 25000,  '신용카드', 'completed', 'TXN-0001'),
(2,  2, 18000,  '간편결제', 'completed', 'TXN-0002'),
(3,  3, 120000, '신용카드', 'pending',   'TXN-0003'),
(4,  4, 90000,  '신용카드', 'completed', 'TXN-0004'),
(5,  5, 22000,  '간편결제', 'completed', 'TXN-0005'),
(6,  6, 70000,  '신용카드', 'refunded',  'TXN-0006'),
(8,  1, 150000, '간편결제', 'completed', 'TXN-0008'),
(9,  2, 23000,  '신용카드', 'completed', 'TXN-0009'),
(10, 3, 110000, '간편결제', 'completed', 'TXN-0010'),
(12, 5, 24000,  '신용카드', 'refunded',  'TXN-0012');

-- ---------- 8. Reviews (completed 예약만, reservation_id UNIQUE) ----------
INSERT INTO Reviews (user_id, salon_id, reservation_id, rating, comment) VALUES
(1, 1, 1,  5, '커트 실력이 정말 좋아요! 다음에도 재방문 의사 있습니다.'),
(2, 1, 2,  4, '깔끔하고 친절했어요.'),
(4, 3, 4,  5, '히피펌 결과물이 만족스러웠습니다.'),
(1, 6, 8,  5, '발레아쥬 컬러가 자연스럽게 잘 나왔어요.'),
(2, 7, 9,  4, '가격 대비 만족스러운 시술이었습니다.'),
(3, 8, 10, 5, '셋팅펌 유지력이 좋아요, 강추합니다.');