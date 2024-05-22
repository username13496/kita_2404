DROP TABLE Book;
CREATE TABLE Book(
bookid NUMBER(2) PRIMARY KEY,
bookname VARCHAR(40),
publisher VARCHAR(40),
price NUMBER(8)
);
INSERT INTO Book VALUES(1,'���ε���','�ʿ���',12600);
INSERT INTO Book VALUES(2,'�ʳ�F?!','����',5000);
INSERT INTO Book VALUES(3,'���̼� ����','Ƽ������Ŭ��',16200);
INSERT INTO Book VALUES(4,'����ذ�! ��������','�����»����',22500);
SElECT*FROM BOOK;
DELETE FROM BOOK;
commit;

--Task1_0520. 10���� �Ӽ����� �����Ǵ� ���̺� 2���� �ۼ��ϼ���. �� FOREIGN KEY�� �����Ͽ� ���� ���̺��� �����͸� ���� �� 
--�ٸ� ���̺��� ���õǴ� �����͵� ��� �����ǵ��� �ϼ���. (��� ���������� ���)
--��, �� ���̺� 5���� �����͸� �Է��ϰ� �ι�° ���̺� ù��° �����͸� �����ϰ� �ִ� �Ӽ��� �����Ͽ� ������ ���� 
DROP table mart;
DROP table department;
create table mart(
    custid number primary key
    , name varchar2(20)
    , age number
    , sx varchar2(20)
    , phone number not null
    , address varchar2(100)
    , frequency number -- �湮 ��
    , amount_num number
    , amount_price number
    , parking varchar2(20) -- ��������
    , family number -- ���� ������ ��
);

alter table mart drop column amount_num;
alter table mart modify (name varchar2(30));
alter table mart modify (phone varchar2(20));

DESC mart;
insert into mart values(1, '��浿', 32, '��', '010-1234-1234', '���� ����', 5, 1500000, 'N', 3);
insert into mart values(2, '�����', 31, '��', '010-7777-1234', '���� ��õ', 5, 200000000, 'Y', 4);
insert into mart values(3, '�̼���', 57, '��', '010-1592-1234', '�泲 �뿵', 5, 270000, 'N', 1);
insert into mart values(4, '������', 30, '��', '010-0516-1234', '���� ����', 5, 750000000, 'Y', 4);
insert into mart values(5, '�ӿ���', 30, '��', '010-0517-1235', '���� ����', 5, 75000000, 'Y', 2);

select * from mart;

create table department(
    custid number primary key
    , name varchar(20)
    , age number
    , sx varchar2(20)
    , phone number not null
    , address varchar2(100)
    , use_store varchar2(100) -- ���� ã�� ����
    , amount_num number
    , amount_price number
    , valet varchar2(20) -- �߷���ŷ ���� ��뿩��
    , rounge varchar2(20) -- vip ����� ��뿩��
    , foreign key (custid) references mart(custid) on delete cascade
);

alter table department modify (amount_price check (amount_price > 100000000));
alter table department modify (rounge default 'Y');
alter table department modify (valet default 'Y');
alter table department modify (phone varchar2(100));
alter table department drop column amount_num;
--alter table department add (custid number);
select * from department;

insert into department values(1, '�����', 31, '��', '010-7777-1234', '���� ��õ', 'LV', 900000000,'','');
insert into department values(2, '������', 30, '��', '010-0516-1234', '���� ����', 'GUCCI', 1500000000,'','');
insert into department values(3, '������', 31, '��', '010-7775-1235', '���� ��õ', 'LV', 900000000,'','');
insert into department values(4, '�ڼ���', 30, '��', '010-0516-1234', '���� ����', 'GUCCI', 1500000000,'','');
insert into department values(5, '�ӿ���', 30, '��', '010-0517-1235', '���� ����', 'ROLEX', 150000000,'','');

DELETE mart
WHERE custid = 1;
