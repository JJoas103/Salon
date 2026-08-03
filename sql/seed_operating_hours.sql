-- ============================================================================
-- Salon_Operating_Hours 보충 시드
--
-- dummydata_original.sql 에는 '월' 요일 10행만 들어 있어서, 예약 화면에서
-- 월요일 말고는 시간대가 하나도 뜨지 않는다 (그 요일 행이 없으면 휴무로 보기 때문).
-- 월요일 영업시간을 그대로 화~토에 복사해 채운다. 일요일은 휴무로 남겨 둔다.
--
-- 실행:  mysql -u root -p salu < sql/seed_operating_hours.sql
--
-- 두 번 실행하면 같은 요일 행이 하나 더 생기지만 동작에는 지장이 없다.
-- (SalonMapper.findOperatingHour 가 LIMIT 1 로 한 행만 읽는다)
-- 깨끗하게 다시 넣고 싶으면 아래 DELETE 주석을 풀고 실행하면 된다.
-- ============================================================================

-- DELETE FROM Salon_Operating_Hours WHERE day_of_week IN ('화', '수', '목', '금', '토');

INSERT INTO Salon_Operating_Hours (salon_id, day_of_week, open_time, close_time)
SELECT src.salon_id, d.dow, src.open_time, src.close_time
FROM (
    SELECT salon_id, open_time, close_time
    FROM Salon_Operating_Hours
    WHERE day_of_week = '월'
) AS src
CROSS JOIN (
    SELECT '화' AS dow
    UNION ALL SELECT '수'
    UNION ALL SELECT '목'
    UNION ALL SELECT '금'
    UNION ALL SELECT '토'
) AS d;

-- 확인용: 매장별로 요일이 몇 개씩 들어갔는지
-- SELECT salon_id, COUNT(*) AS days, GROUP_CONCAT(day_of_week ORDER BY hour_id) AS list
--   FROM Salon_Operating_Hours GROUP BY salon_id;
