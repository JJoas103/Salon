
-- dummydata_original.sql import 시 클라이언트 인코딩(latin1)이 강제되지
-- 않아 한글이 깨져 저장된 문제를 원본 텍스트로 복구하는 스크립트.
--
-- 실행: mysql --default-character-set=utf8mb4 -u root -p salu < sql/restore_original_salons_utf8.sql

USE salu;

-- ---------- Users : owner 이름 (user_id 8~11) ----------
UPDATE Users SET user_name = '이원장' WHERE user_id = 8;
UPDATE Users SET user_name = '박원장' WHERE user_id = 9;
UPDATE Users SET user_name = '최원장' WHERE user_id = 10;
UPDATE Users SET user_name = '정원장' WHERE user_id = 11;

-- ---------- Salons (salon_id 1~10) ----------
UPDATE Salons SET salon_name = '라움헤어',       address = '서울 강남구 논현동 123-4',  description = '트렌디한 커트와 컬러 전문 살롱'     WHERE salon_id = 1;
UPDATE Salons SET salon_name = '소울커트',       address = '서울 마포구 홍대동 45-6',   description = '홍대 감성의 캐주얼 헤어샵'          WHERE salon_id = 2;
UPDATE Salons SET salon_name = '블랑쉬헤어',     address = '서울 서초구 반포동 78-9',   description = '웨딩/투톤 컬러 전문'                WHERE salon_id = 3;
UPDATE Salons SET salon_name = '그레이스살롱',   address = '인천 남동구 구월동 12-3',   description = '가족 단골 손님이 많은 동네 미용실'  WHERE salon_id = 4;
UPDATE Salons SET salon_name = '헤어스튜디오 온', address = '인천 연수구 송도동 34-5',  description = '남성 전문 클리닉 헤어샵'            WHERE salon_id = 5;
UPDATE Salons SET salon_name = '살롱드밀',       address = '서울 성동구 성수동 56-7',   description = '연예인 단골로 유명한 프리미엄 살롱' WHERE salon_id = 6;
UPDATE Salons SET salon_name = '위드헤어',       address = '인천 부평구 부평동 89-1',   description = '합리적인 가격의 실속형 헤어샵'      WHERE salon_id = 7;
UPDATE Salons SET salon_name = '컬러플레이 헤어', address = '서울 마포구 연남동 23-4',  description = '탈염/컬러 특화 살롱'                WHERE salon_id = 8;
UPDATE Salons SET salon_name = '에디트헤어',     address = '서울 용산구 이태원동 67-8', description = '남녀 커트 및 펌 전문'               WHERE salon_id = 9;
UPDATE Salons SET salon_name = '뮤즈헤어살롱',   address = '인천 미추홀구 주안동 90-1', description = '20년 경력 원장님이 직접 시술'       WHERE salon_id = 10;

-- ---------- Services (service_id 1~13) ----------
UPDATE Services SET service_name = '여성컷',           description = '디자이너 커트 (샴푸 포함)'   WHERE service_id = 1;
UPDATE Services SET service_name = '남성컷',           description = '남성 스타일 커트'            WHERE service_id = 2;
UPDATE Services SET service_name = '볼륨매직',         description = '자연스러운 볼륨 매직 스트레이트' WHERE service_id = 3;
UPDATE Services SET service_name = '뿌리염색',         description = '새치 커버 뿌리염색'          WHERE service_id = 4;
UPDATE Services SET service_name = '히피펌',           description = '내추럴 웨이브 히피펌'        WHERE service_id = 5;
UPDATE Services SET service_name = '여성컷',           description = '디자이너 커트'                WHERE service_id = 6;
UPDATE Services SET service_name = '클리닉트리트먼트', description = '손상모 집중 케어'            WHERE service_id = 7;
UPDATE Services SET service_name = '남성컷',           description = '남성 클리닉 커트'            WHERE service_id = 8;
UPDATE Services SET service_name = '발레아쥬',         description = '자연스러운 그라데이션 염색'  WHERE service_id = 9;
UPDATE Services SET service_name = '여성컷',           description = '디자이너 커트'                WHERE service_id = 10;
UPDATE Services SET service_name = '셋팅펌',           description = '내추럴 셋팅펌'                WHERE service_id = 11;
UPDATE Services SET service_name = '남성컷',           description = '남성 스타일 커트'            WHERE service_id = 12;
UPDATE Services SET service_name = '여성컷',           description = '디자이너 커트'                WHERE service_id = 13;

-- ---------- Stylists (stylist_id 1~12) ----------
UPDATE Stylists SET stylist_name = '김지은', description = '커트 전문 디자이너 경력 8년' WHERE stylist_id = 1;
UPDATE Stylists SET stylist_name = '박민수', description = '남성 커트 전문'             WHERE stylist_id = 2;
UPDATE Stylists SET stylist_name = '이하늘', description = '매직/스트레이트 전문'       WHERE stylist_id = 3;
UPDATE Stylists SET stylist_name = '최유정', description = '펌 전문 디자이너'           WHERE stylist_id = 4;
UPDATE Stylists SET stylist_name = '정다은', description = '커트 전문'                  WHERE stylist_id = 5;
UPDATE Stylists SET stylist_name = '오세훈', description = '트리트먼트 전문'            WHERE stylist_id = 6;
UPDATE Stylists SET stylist_name = '강태양', description = '남성 클리닉 전문'          WHERE stylist_id = 7;
UPDATE Stylists SET stylist_name = '윤소희', description = '컬러 전문 원장'            WHERE stylist_id = 8;
UPDATE Stylists SET stylist_name = '한지민', description = '커트 전문'                  WHERE stylist_id = 9;
UPDATE Stylists SET stylist_name = '서준혁', description = '펌 전문 디자이너'          WHERE stylist_id = 10;
UPDATE Stylists SET stylist_name = '임수아', description = '남성/여성 커트 전문'        WHERE stylist_id = 11;
UPDATE Stylists SET stylist_name = '배도현', description = '20년 경력 원장'            WHERE stylist_id = 12;

-- ---------- Salon_Operating_Hours ----------
-- day_of_week는 데이터가 아니라 ENUM 라벨 자체가 CREATE TABLE 시점에 깨져서
-- 저장된 것 (schema.sql은 정상). ENUM은 라벨 문자열로 매칭/변환되므로
-- 곧바로 새 라벨로 MODIFY하면 기존 값과 매칭이 안 돼 truncate 에러가 난다.
-- VARCHAR로 풀었다가 값을 바로잡고 다시 ENUM으로 되돌린다.
-- (현재 더미데이터는 전 살롱이 '월' 한 값만 갖고 있어 UPDATE가 단순하다.)
ALTER TABLE Salon_Operating_Hours MODIFY day_of_week VARCHAR(10) NOT NULL;
UPDATE Salon_Operating_Hours SET day_of_week = '월';
ALTER TABLE Salon_Operating_Hours
    MODIFY day_of_week ENUM('월', '화', '수', '목', '금', '토', '일') NOT NULL;
