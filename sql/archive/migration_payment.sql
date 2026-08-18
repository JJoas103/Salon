-- payments 테이블에 할인 내역 관련 컬럼 4개 추가 
-- amount = original_amount - coupon_discount - point_used로 확정
-- user_coupon_id FK는 이후 step5 coupons 마이그레이션에서 붙일 예정

alter table payments 
	add column original_amount DECIMAL(10, 2) not null default 0,
	add column coupon_discount DECIMAL(10, 2) not null default 0,
	add column point_used int not null default 0,
	add column pg_provider varchar(20) not null default 'KAKAOPAY',
	add column user_coupon_id int null;

update payments set original_amount = amount where original_amount = 0;