sql/archive

여기 있는 파일은 더 이상 실행하지 않는다
전부 '../schema.sql'과 '../migration_catchup.sql'에 통합되어 있고, 어떤 변경이 언제 들어왔는지 남겨두기 위한 이력용

- 새로 DB를 만든다 → '../schema.sql'
- 이미 DB가 있다 → '../migration_catchup.sql'

'migration_combined.sql'은 원래도 
'migration_salon_notices' + '_image' + 'migration_reviews_images' + 'migration_coupon'을 
한 파일로 묶어 재배포한 것이라, 개별 파일과 내용이 겹침

'restore_original_salons_utf8.sql'은 2026-07-27에 더미데이터 한글을 복구한 데이터 전용 스크립트
스키마 변경 없이 이미 반영되어 있음

앞으로 스키마를 바꿀 때:
    1. 팀원은 'sql/migration_<기능>.sql'을 새로 만들어 올림 (기존 DB 갱신용)
    2. 팀장이 'schema.sql' + 'migration_catchup.sql'에 통합하고, 이력 주석을 갱신한 뒤 원본을 이 폴더로 옮김
두 곳이 어긋나면 새로 DB를 만든 사람만 기능이 깨져서 원인을 찾기 어려움
