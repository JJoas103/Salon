USE salu;

UPDATE Users SET user_name = '이원장' WHERE email = 'owner1@salu.com';
UPDATE Users SET user_name = '박원장' WHERE email = 'owner2@salu.com';
UPDATE Users SET user_name = '최원장' WHERE email = 'owner3@salu.com';
UPDATE Users SET user_name = '정원장' WHERE email = 'owner4@salu.com';

UPDATE Salons SET salon_name = '라움헤어', address = '서울 강남구 논현동 123-4', description = '트렌디한 커트와 컬러 전문 살롱' WHERE phone_number = '02-511-1001';
UPDATE Salons SET salon_name = '소울커트', address = '서울 마포구 홍대동 45-6', description = '홍대 감성의 캐주얼 헤어샵' WHERE phone_number = '02-511-1002';
UPDATE Salons SET salon_name = '블랑쉬헤어', address = '서울 서초구 반포동 78-9', description = '웨딩/투톤 컬러 전문' WHERE phone_number = '02-511-1003';
UPDATE Salons SET salon_name = '그레이스살롱', address = '인천 남동구 구월동 12-3', description = '가족 단골 손님이 많은 동네 미용실' WHERE phone_number = '032-511-1004';
UPDATE Salons SET salon_name = '헤어스튜디오 온', address = '인천 연수구 송도동 34-5', description = '남성 전문 클리닉 헤어샵' WHERE phone_number = '032-511-1005';
UPDATE Salons SET salon_name = '살롱드밀', address = '서울 성동구 성수동 56-7', description = '연예인 단골로 유명한 프리미엄 살롱' WHERE phone_number = '02-511-1006';
UPDATE Salons SET salon_name = '위드헤어', address = '인천 부평구 부평동 89-1', description = '합리적인 가격의 실속형 헤어샵' WHERE phone_number = '032-511-1007';
UPDATE Salons SET salon_name = '컬러플레이 헤어', address = '서울 마포구 연남동 23-4', description = '탈염/컬러 특화 살롱' WHERE phone_number = '02-511-1008';
UPDATE Salons SET salon_name = '에디트헤어', address = '서울 용산구 이태원동 67-8', description = '남녀 커트 및 펌 전문' WHERE phone_number = '02-511-1009';
UPDATE Salons SET salon_name = '뮤즈헤어살롱', address = '인천 미추홀구 주안동 90-1', description = '20년 경력 원장님이 직접 시술' WHERE phone_number = '032-511-1010';

UPDATE Services se JOIN Salons s ON s.salon_id = se.salon_id SET se.service_name = '여성컷', se.description = '디자이너 커트 (샴푸 포함)' WHERE s.phone_number = '02-511-1001' AND se.price = 25000;
UPDATE Services se JOIN Salons s ON s.salon_id = se.salon_id SET se.service_name = '남성컷', se.description = '남성 스타일 커트' WHERE s.phone_number = '02-511-1001' AND se.price = 18000;
UPDATE Services se JOIN Salons s ON s.salon_id = se.salon_id SET se.service_name = '볼륨매직', se.description = '자연스러운 볼륨 매직 스트레이트' WHERE s.phone_number = '02-511-1002' AND se.price = 120000;
UPDATE Services se JOIN Salons s ON s.salon_id = se.salon_id SET se.service_name = '뿌리염색', se.description = '새치 커버 뿌리염색' WHERE s.phone_number = '02-511-1002' AND se.price = 60000;
UPDATE Services se JOIN Salons s ON s.salon_id = se.salon_id SET se.service_name = '히피펌', se.description = '내추럴 웨이브 히피펌' WHERE s.phone_number = '02-511-1003';
UPDATE Services se JOIN Salons s ON s.salon_id = se.salon_id SET se.service_name = '여성컷', se.description = '디자이너 커트' WHERE s.phone_number = '032-511-1004' AND se.price = 22000;
UPDATE Services se JOIN Salons s ON s.salon_id = se.salon_id SET se.service_name = '클리닉트리트먼트', se.description = '손상모 집중 케어' WHERE s.phone_number = '032-511-1004' AND se.price = 70000;
UPDATE Services se JOIN Salons s ON s.salon_id = se.salon_id SET se.service_name = '남성컷', se.description = '남성 클리닉 커트' WHERE s.phone_number = '032-511-1005';
UPDATE Services se JOIN Salons s ON s.salon_id = se.salon_id SET se.service_name = '발레아쥬', se.description = '자연스러운 그라데이션 염색' WHERE s.phone_number = '02-511-1006';
UPDATE Services se JOIN Salons s ON s.salon_id = se.salon_id SET se.service_name = '여성컷', se.description = '디자이너 커트' WHERE s.phone_number = '032-511-1007';
UPDATE Services se JOIN Salons s ON s.salon_id = se.salon_id SET se.service_name = '셋팅펌', se.description = '내추럴 셋팅펌' WHERE s.phone_number = '02-511-1008';
UPDATE Services se JOIN Salons s ON s.salon_id = se.salon_id SET se.service_name = '남성컷', se.description = '남성 스타일 커트' WHERE s.phone_number = '02-511-1009';
UPDATE Services se JOIN Salons s ON s.salon_id = se.salon_id SET se.service_name = '여성컷', se.description = '디자이너 커트' WHERE s.phone_number = '032-511-1010';
