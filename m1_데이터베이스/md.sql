DROP TABLE Book;
CREATE TABLE Book(
bookid NUMBER(2) PRIMARY KEY,
bookname VARCHAR(40),
publisher VARCHAR(40),
price NUMBER(8)
);
INSERT INTO Book VALUES(1,'초인동맹','초여명',12600);
INSERT INTO Book VALUES(2,'너냐F?!','퍼플',5000);
INSERT INTO Book VALUES(3,'둘이서 수사','티알피지클럽',16200);
INSERT INTO Book VALUES(4,'고민해결! 마법서점','구르는사람들',22500);
SElECT*FROM BOOK;
DELETE FROM BOOK;
commit;

--Task1_0520. 10개의 속성으로 구성되는 테이블 2개를 작성하세요. 단 FOREIGN KEY를 적용하여 한쪽 테이블의 데이터를 삭제 시 
--다른 테이블의 관련되는 데이터도 모두 삭제되도록 하세요. (모든 제약조건을 사용)
--단, 각 테이블에 5개의 데이터를 입력하고 두번째 테이블에 첫번째 데이터를 참조하고 있는 속성을 선택하여 데이터 삭제 
DROP table mart;
DROP table department;
create table mart(
    custid number primary key
    , name varchar2(20)
    , age number
    , sx varchar2(20)
    , phone number not null
    , address varchar2(100)
    , frequency number -- 방문 빈도
    , amount_num number
    , amount_price number
    , parking varchar2(20) -- 주차여부
    , family number -- 가족 구성원 수
);

alter table mart drop column amount_num;
alter table mart modify (name varchar2(30));
alter table mart modify (phone varchar2(20));

DESC mart;
insert into mart values(1, '고길동', 32, '남', '010-1234-1234', '서울 강남', 5, 1500000, 'N', 3);
insert into mart values(2, '손흥민', 31, '남', '010-7777-1234', '강원 춘천', 5, 200000000, 'Y', 4);
insert into mart values(3, '이순신', 57, '남', '010-1592-1234', '경남 통영', 5, 270000, 'N', 1);
insert into mart values(4, '아이유', 30, '여', '010-0516-1234', '서울 서초', 5, 750000000, 'Y', 4);
insert into mart values(5, '임영웅', 30, '남', '010-0517-1235', '서울 역삼', 5, 75000000, 'Y', 2);

select * from mart;

create table department(
    custid number primary key
    , name varchar(20)
    , age number
    , sx varchar2(20)
    , phone number not null
    , address varchar2(100)
    , use_store varchar2(100) -- 자주 찾는 매장
    , amount_num number
    , amount_price number
    , valet varchar2(20) -- 발렛파킹 서비스 사용여부
    , rounge varchar2(20) -- vip 라운지 사용여부
    , foreign key (custid) references mart(custid) on delete cascade
);

alter table department modify (amount_price check (amount_price > 100000000));
alter table department modify (rounge default 'Y');
alter table department modify (valet default 'Y');
alter table department modify (phone varchar2(100));
alter table department drop column amount_num;
--alter table department add (custid number);
select * from department;

insert into department values(1, '손흥민', 31, '남', '010-7777-1234', '강원 춘천', 'LV', 900000000,'','');
insert into department values(2, '아이유', 30, '여', '010-0516-1234', '서울 서초', 'GUCCI', 1500000000,'','');
insert into department values(3, '박지성', 31, '남', '010-7775-1235', '강원 춘천', 'LV', 900000000,'','');
insert into department values(4, '박세리', 30, '여', '010-0516-1234', '서울 서초', 'GUCCI', 1500000000,'','');
insert into department values(5, '임영웅', 30, '남', '010-0517-1235', '서울 역삼', 'ROLEX', 150000000,'','');

DELETE mart
WHERE custid = 1;
