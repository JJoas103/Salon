-- ---------- Salons : 지도 마커용 좌표 채우기 ----------
-- 더미데이터의 번지(123-4 등)는 지어낸 값이라 카카오 Geocoder 로 변환되지 않는다.
-- 그래서 각 미용실이 위치한 '동'의 중심 좌표를 넣어둔다. 더미 데이터이므로 동 단위면 충분하다.
-- 실제 미용실 등록 기능을 만들 때는 등록 시점에 주소 → 좌표를 한 번 변환해서 저장할 것.
--
-- salon_id 는 재생성 시 달라질 수 있어 phone_number 로 매칭한다
-- (restore_original_salons_utf8.sql 과 동일한 방식).

UPDATE Salons SET latitude = 37.5111000, longitude = 127.0224000 WHERE phone_number = '02-511-1001';  -- 라움헤어 / 서울 강남구 논현동
UPDATE Salons SET latitude = 37.5563000, longitude = 126.9236000 WHERE phone_number = '02-511-1002';  -- 소울커트 / 서울 마포구 (홍대 일대)
UPDATE Salons SET latitude = 37.5045000, longitude = 126.9959000 WHERE phone_number = '02-511-1003';  -- 블랑쉬헤어 / 서울 서초구 반포동
UPDATE Salons SET latitude = 37.4478000, longitude = 126.7017000 WHERE phone_number = '032-511-1004'; -- 그레이스살롱 / 인천 남동구 구월동
UPDATE Salons SET latitude = 37.3894000, longitude = 126.6390000 WHERE phone_number = '032-511-1005'; -- 헤어스튜디오 온 / 인천 연수구 송도동
UPDATE Salons SET latitude = 37.5446000, longitude = 127.0559000 WHERE phone_number = '02-511-1006';  -- 살롱드밀 / 서울 성동구 성수동
UPDATE Salons SET latitude = 37.4934000, longitude = 126.7220000 WHERE phone_number = '032-511-1007'; -- 위드헤어 / 인천 부평구 부평동
UPDATE Salons SET latitude = 37.5626000, longitude = 126.9255000 WHERE phone_number = '02-511-1008';  -- 컬러플레이 헤어 / 서울 마포구 연남동
UPDATE Salons SET latitude = 37.5345000, longitude = 126.9946000 WHERE phone_number = '02-511-1009';  -- 에디트헤어 / 서울 용산구 이태원동
UPDATE Salons SET latitude = 37.4638000, longitude = 126.6810000 WHERE phone_number = '032-511-1010'; -- 뮤즈헤어살롱 / 인천 미추홀구 주안동

-- 확인용
-- SELECT salon_id, salon_name, address, latitude, longitude FROM Salons ORDER BY salon_id;
