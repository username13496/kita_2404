SELECT * FROM book;
SELECT bookid, price FROM book;

SELECT * FROM Customer;
SELECT * FROM orders;
SELECT * FROM imported_book;

--�ߺ����� ���
SELECT DISTINCT publisher FROM book;
-- Q. ������ ���� �̻��� ������ �˻�
SELECT * FROM book
WHERE price > 10000;
-- Q. ����-2������ ������ ���� �˻�
SELECT * FROM book
WHERE price BETWEEN 10000 AND 20000;
SELECT * FROM book
WHERE 10000 <= price and price <= 20000;
-- <=/=>
-- Task1_0517. ���ǻ簡 '�½�����' Ȥ�� '���ѹ̵��'�� ������ �˻�(3����)
SELECT * FROM book
WHERE (publisher='�½�����') OR (publisher='���ѹ̵��');
SELECT * FROM book
WHERE publisher IN('�½�����','���ѹ̵��');
SELECT * FROM book;
SELECT * FROM book WHERE (publisher='�½�����')
UNION
SELECT * FROM book WHERE (publisher='���ѹ̵��');


-- Task2_0517. ���ǻ簡 '�½�����' Ȥ�� '���ѹ̵��'�� �ƴ� ������ �˻�
SELECT * FROM book
WHERE(publisher) NOT IN ('�½�����','���ѹ̵��');

-- LIKE�� ��Ȯ�� '�౸�� ����'�� ��ġ�ϴ� �ุ ����
SELECT bookname, publisher FROM book
WHERE bookname LIKE '�౸�� ����'; 
-- �Ϻθ��� �ȵ�

-- % : 0�� �̻��� ������ ����
-- _ : ��Ȯ�� 1���� ������ ����

-- '�౸'�� ���Ե� ���ǻ�
SELECT bookname, publisher FROM book
WHERE bookname LIKE'%�౸%';

-- �����̸��� ���� �ι�° ��ġ�� '��'��� ���ڿ��� ���� ����
SELECT bookname, publisher FROM book
WHERE bookname LIKE '_��%';

-- Task3_0517. �౸�� ���� ���� �� ������ 2�� �̻��� ������ �˻�
SELECT bookname, price FROM book
WHERE bookname LIKE'%�౸%' AND price >= 20000;

-- ORDER BY : �ø����� ����(default)
SELECT * FROM book
ORDER BY bookid;
SELECT * FROM book
ORDER BY bookname;
SELECT * FROM book
ORDER BY price;

-- �������� DESC
SELECT * FROM book
ORDER BY bookname DESC;
SELECT * FROM book
ORDER BY price DESC;

-- Q. ������ ���ݼ����� �˻��� �� ������ ������ �̸������� �˻�
-- AS�� ���� ����
SELECT * FROM book
ORDER BY price,bookname;
SELECT * FROM orders;
SELECT SUM(saleprice) AS "�� �Ǹž�"
FROM orders
WHERE custid = 2;

-- GROUP BY : �����͸� Ư�� ���ؿ� ���� �׷�ȭ�ϴµ� ���. �̸� ���� �����Լ�(SUM, AVG, MAX, MIM, COUNT)�� �̿�
SELECT SUM(saleprice) AS total,
AVG(saleprice) AS average,
MIN(saleprice) AS minimum,
MAX(saleprice) AS maximum
FROM orders;

-- ���Ǹž��� custid �������� �׷�ȭ
SELECT custid, COUNT(*) AS ��������, SUM(saleprice) AS "�� �Ǹž�"
FROM orders
GROUP BY custid;

-- bookid�� 5���� ū ����
SELECT custid, COUNT(*) AS ��������, SUM(saleprice) AS "�� �Ǹž�"
FROM orders
WHERE bookid > 5
GROUP BY custid;

-- ���������� 2���� ū ����
SELECT custid, COUNT(*) AS ��������, SUM(saleprice) AS "�� �Ǹž�"
FROM orders
WHERE bookid > 5
GROUP BY custid
HAVING COUNT(*) >2;

-- Task4_0517. 2�� �迬�� ���� �ֹ��� ������ ������ �� �Ǹž��� ���Ͻÿ�
SELECT customer.name, orders.custid, SUM(orders.saleprice) AS "�� �Ǹž�"
FROM orders, customer
WHERE orders.custid = 2 AND orders.custid = customer.custid
GROUP BY customer.name, orders.custid;  

SELECT customer.name, orders.custid, COUNT(orders.orderid) AS "���� ����", SUM(orders.saleprice) AS "�� �Ǹž�"
FROM orders, customer
WHERE orders.custid = 2 AND orders.custid = customer.custid
GROUP BY customer.name, orders.custid;

SELECT customer.name, orders.custid, SUM(orders.saleprice)
FROM orders
INNER JOIN customer on orders.custid = customer.custid
WHERE orders.custid =2
GROUP BY customer.name, orders.custid;


-- Task5_0517. ������ 8,000�� �̻��� ������ ������ ���� ���Ͽ� ���� �ֹ� ������ �� ������ ���Ͻÿ�.
-- ��, �� �� �̻� ������ ���� ���Ͻÿ�.
SELECT custid, COUNT(*) AS ��������
FROM orders
WHERE saleprice >= 8000
GROUP BY custid
HAVING COUNT(*) >= 2;

SELECT custid, COUNT(*) AS ��������
FROM orders
WHERE saleprice >= 8000
HAVING COUNT(*) >= 2
GROUP BY custid;

-- Task6_0517. ���� �̸��� ���� �ֹ��� ������ �ǸŰ����� �˻��Ͻÿ�
SELECT name, saleprice
FROM customer, orders
WHERE customer.custid = orders.custid;

-- Task7_0517. ������ �ֹ��� ��� ������ �� �Ǹž��� ���ϰ�, ������ �����Ͻÿ�.
SELECT custid, SUM(saleprice) "�� �Ǹž�"
FROM orders
GROUP BY custid
ORDER BY custid;

SELECT custid, SUM(saleprice) "�� �Ǹž�"
FROM orders
GROUP BY custid
ORDER BY "�� �Ǹž�";

SELECT name, SUM(saleprice) AS "�� �Ǹž�"
FROM customer C, orders O
WHERE C.custid = O.custid
GROUP BY C.name
ORDER BY C.name;

-- Q. ���� �̸��� ���� �ֹ��� ������ �̸��� ��io; �Ͻÿ� �� ���̺� �̿��ϱ�
SELECT C.name, B.bookname
FROM book B, customer C, orders O
WHERE C.custid = O.custid AND O.bookid = B.bookid;

SELECT customer.name, book.bookname
FROM orders
INNER JOIN customer ON orders.custid = customer.custid
INNER JOIN book ON orders.bookid = book.bookid;

-- Q. ������ 20000���� ������ �ֹ��� ���� �̸��� ������ �̸��� ���Ͻÿ� �� ���̺� ��� ��
SELECT C.name B.bookname
FROM customer C, book B, orders O
WHERE C.custid = O.custid AND O.bookid = B.bookid AND B.price = 20000
ORDER BY custid;

SELECT * FROM customer;
SELECT * FROM orders;

-- JOIN�� �� �� �̻��� ���̺��� �����Ͽ� ���õ� �����͸� ������ �� ���
-- ���� ����(INNER JOIN)
SELECT customer.name, orders.saleprice
FROM customer
INNER JOIN orders ON customer.custid = orders.custid;

-- ���� �ܺ� ���� (Left Outer Join) : . �� ��° ���̺� ��ġ�ϴ� �����Ͱ� ���� ��� NULL ���� ���
SELECT customer.name, orders.saleprice
FROM customer
LEFT OUTER JOIN orders ON customer.custid = orders.custid;

-- ������ �ܺ� ���� (Right Outer Join) : ù ��° ���̺� ��ġ�ϴ� �����Ͱ� ���� ��� NULL ���� ���
SELECT customer.name, orders.saleprice
FROM customer
RIGHT OUTER JOIN orders ON customer.custid = orders.custid;

-- FULL OUTER JOIN : ��ġ�ϴ� �����Ͱ� ���� ��� �ش� ���̺����� NULL ���� ���
SELECT customer.name, orders.saleprice
FROM customer
FULL OUTER JOIN orders ON customer.custid = orders.custid;

-- CROSS JOIN : �� ���̺� ���� ��� ������ ������ ����
SELECT customer.name, orders.saleprice
FROM customer
CROSS JOIN orders;

-- Q. ������ �������� ���� ���� �����Ͽ� ���� �̸��� ���� �ֹ��� ������ �ǸŰ����� ���Ͻÿ�(2���� ���, WHERE, JOIN)
SELECT C.name, O.saleprice
FROM customer C, orders O
WHERE C.custid = O.custid(+);

SELECT customer.name, orders.saleprice
FROM customer LEFT OUTER JOIN orders ON customer.custid = orders.custid;

-- �μ� ���� ��������
SELECT * FROM book;
SELECT * FROM orders;
-- Q. ������ ������ ���� �ִ� ���� �̸��� �˻��Ͻÿ�
SELECT name
FROM customer
WHERE custid IN (SELECT custid FROM orders);

-- Q. �����ѹ̵����� ������ ������ ������ ���� �̸��� ���̽ÿ�.
SELECT name
FROM customer
WHERE custid IN (SELECT custid FROM orders
WHERE bookid IN (SELECT bookid FROM book
WHERE publisher = '���ѹ̵��'));


-- Q. ���ǻ纰�� ���ǻ��� ��� ���� ���ݺ��� ��� ������ ���Ͻÿ�.
SELECT b1.bookname
FROM book b1
WHERE b1.price > (SELECT avg(b2.price)
FROM book b2
WHERE b2.publisher = b1.publisher);

-- Q. ������ �ֹ����� ���� ���� �̸��� ���̽ÿ�.
SELECT name
FROM customer
WHERE custid NOT IN (SELECT custid FROM orders);

-- Q. �ֹ��� �ִ� ���� �̸��� �ּҸ� ���̽ÿ�
SELECT name "�� �̸�", address "�� �ּ�"
FROM customer
WHERE custid IN (SELECT custid FROM orders);

-- ������ Ÿ��
-- ������ (Numeric Types
-- NUMBER: ���� �������� ���� ������ Ÿ��. ����, �Ǽ�, ���� �Ҽ���, �ε� �Ҽ��� ���� ����
-- NUMBER(38,0)�� ���� �ǹ̷� �ؼ�, 38�� �ڸ��� 0�� �Ҽ���(�Ҽ����� �ڸ����� ����) SCALE 0�� �Ҽ��� ���� �ڸ���
-- NUMBER(10), NUMBER(8,2)
-- ������ (Character Types)
-- VARCHAR2(size): ���� ���� ���ڿ��� ����. size�� �ִ� ���� ���̸� ����Ʈ, Ȥ�� ���ڼ��� ����(Ȯ�� �� �� ����) ������� �������� ����
-- ����2�� ����Ŭ
-- VARCHAR2�� �ΰ��� ������� ���̸� ���� : ����Ʈ�� ����
-- ����Ȯ�ι��
SELECT *
FROM v$nls_parameters
WHERE parameter = 'NLS_LENGTH_SEMANTICS';
-- NVARCHAR2(size)�� ����� ������ ���� ����Ʈ ���� ��� �׻� ���� ������ ũ�Ⱑ ����
-- CHAR(size): ���� ���� ���ڿ��� ����. ������ ���̺��� ª�� ���ڿ��� �ԷµǸ� �������� �������� ä����
-- ��¥ �� �ð��� (Date and Time Types)
-- DATE: ��¥�� �ð��� ����. ������ Ÿ���� ��, ��, ��, ��, ��, �ʸ� ���� �ֱ� ��ٷο�
-- DATE Ÿ���� ��¥�� �ð��� YYYY-MM-DD HH24:MI:SS �������� �����մϴ�.
-- ���� ���, 2024�� 5�� 20�� ���� 3�� 45�� 30�ʴ� 2024-05-20 15:45:30���� ��
-- TIMESTAMP: ��¥�� �ð��� �� ���� ������ �������� ����
-- ���� �������� (Binary Data Types)
-- BLOB: �뷮�� ���� �����͸� ����. �̹���, ����� ���� ���� �����ϴ� �� ����
-- ��Ը� ��ü�� (Large Object Types)
-- CLOB: �뷮�� ���� �����͸� ����
-- NCLOB: �뷮�� ������ ���� ���� �����͸� ���� ������ ����
-- ���� ���ڵ��� �ǹ�
-- ��ǻ�ʹ� ���ڷ� �̷���� �����͸� ó��. ���ڵ��� ���� ����(��: 'A', '��', '?')�� 
-- ����(�ڵ� ����Ʈ)�� ��ȯ�Ͽ� ��ǻ�Ͱ� �����ϰ� ������ �� �ְ� �Ѵ�.
-- ���� ���, ASCII ���ڵ������� �빮�� 'A'�� 65��, �ҹ��� 'a'�� 97�� ���ڵ�. 
-- �����ڵ� ���ڵ������� 'A'�� U+0041, �ѱ� '��'�� U+AC00, �̸�Ƽ�� '?'�� U+1F60A�� ���ڵ�
-- �ƽ�Ű�� 7��Ʈ�� ����Ͽ� �� 128���� ���ڸ� ǥ���ϴ� �ݸ� �����ڵ�� �ִ� 1,114,112���� ���ڸ� ǥ��

-- ASCII ���ڵ�: ���
-- ���� 'A' -> 65 (10����) -> 01000001 (2����)
-- ���� 'B' -> 66 (10����) -> 01000010 (2����)

-- �����ڵ�(UTF-8) ���ڵ�: ������
-- ���� 'A' -> U+0041 -> 41 (16����) -> 01000001 (2����, ASCII�� ����)
-- ���� '��' -> U+AC00 -> EC 95 80 (16����) -> 11101100 10010101 10000000 (2����)

-- CLOB: CLOB�� �Ϲ������� �����ͺ��̽��� �⺻ ���� ����(��: ASCII, LATIN1 ��)�� ����Ͽ� �ؽ�Ʈ �����͸� ����. 
-- �� ������ �ַ� ����� ���� ���� ����Ʈ ���ڷ� �̷���� �ؽ�Ʈ�� �����ϴ� �� ���.
-- NCLOB: NCLOB�� �����ڵ�(UTF-16)�� ����Ͽ� �ؽ�Ʈ �����͸� ����. ���� �ٱ��� ������ �ʿ��� ��, \
-- �� �پ��� ���� ������ �ؽ�Ʈ �����͸� ������ �� ����. �ٱ��� ���ڰ� ���Ե� �����͸� ȿ�������� ó���� �� �ִ�.

-- �������� : ���Ἲ ��ġ�� �����ϱ� ���� �˾ƾ� �ϰ� ��ٷο�
-- PRIMARY KEY : �� ���� �����ϰ� �ĺ��ϴ� ��(�Ǵ� ������ ����). �ߺ��ǰų� NULL ���� ������� �ʴ´�.
-- FOREIGN KEY : �ٸ� ���̺��� �⺻ Ű�� �����ϴ� ��. ���� ���Ἲ�� ����
-- UNIQUE : ���� �ߺ��� ���� ����� ���� ����. NULL���� ���
-- NOT NULL : ���� NULL ���� ������� �ʴ´�.
-- CHECK : �� ���� Ư�� ������ �����ؾ� ���� ���� (��: age > 18)
-- DEFAULT : ���� ������� ���� �������� ���� ��� ���� �⺻���� ����

-- AUTHOR ���̺� ����
CREATE TABLE authors (
id NUMBER PRIMARY KEY,
first_name VARCHAR2(50) NOT NULL,
last_name VARCHAR2(50) NOT NULL,
nationality VARCHAR(50)
);
DROP TABLE authors;

DROP TABLE newbook;
-- Q. newbook��� ���̺��� �����ϼ���
CREATE TABLE newbook (
bookid NUMBER,
isbn NUMBER(13),
bookname VARCHAR2(50) NOT NULL,
author VARCHAR2(50) NOT NULL,
publisher VARCHAR2(50) NOT NULL,
price NUMBER DEFAULT 10000 CHECK(price>1000),
published_date DATE,
PRIMARY KEY(bookid)
);
DESC newbook;
-- ���̺� �������� ����, �߰�, �Ӽ� �߰�, ����, ����
DELETE FROM newbook;
ALTER TABLE newbook MODIFY (isbn VACHAR2(10));
ALTER TABLE newbook ADD author_id NUMBER;
ALTER TABLE newbook DROP COLUMN author_id;
ALTER TABLE newbook MODIFY (isbn VARCHAR2(50));
INSERT INTO newbook VALUES (1, 9781234567890, 'SQL Guide', 'John Doe', 'TechBooks', 15000, TO_DATE('2024-05-20', 'YYYY-MM-DD'));
INSERT INTO newbook VALUES (2, 9781234567890, 'SQL Guide', 'John Doe', 'TechBooks', 15000, TO_DATE('2024-05-20', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO newbook VALUES (3, 978123456780000023, 'SQL Guide', 'John Doe', 'TechBooks', 15000, TO_DATE('2024-05-20', 'YYYY-MM-DD HH24:MI:SS'));
SELECT * FROM newbook;
-- ON DELETE CASCADE �ɼ��� �����Ǿ� �־�, newcustomer ���̺��� � ���� ���ڵ尡 �����Ǹ� �ش� ���� ��� �ֹ���
-- neworders ���̺����� �ڵ����� ����
CREATE TABLE newcustomer(
custid NUMBER PRIMARY KEY,
name VARCHAR2(40),
address VARCHAR2(40),
phone VARCHAR2(30));

CREATE TABLE neworders(
orderid NUMBER,
custid NUMBER NOT NULL,
bookid NUMBER NOT NULL,
saleprice NUMBER,
orderdate DATE,
PRIMARY KEY (orderid),
FOREIGN KEY(custid) REFERENCES newcustomer(custid) ON DELETE CASCADE);
DESC neworders;

INSERT INTO newcustomer VALUES(1,'Kevin','���ﵿ','010-1234-1234');
INSERT INTO neworders VALUES(10,1,100,1000,SYSDATE);

SELECT * FROM newcustomer;
SELECT * FROM neworders;
DELETE FROM newcustomer;
DELETE FROM neworders;

DROP TABLE newcustomer cascade constraints purge;
DROP TABLE neworders cascade constraints purge;

-- +�� ��� ��
SELECT ABS(+78), ABS(-78)
FROM dual;

SELECT ROUND(4.875, 1)
FROM dual;

-- Task1_0520. 10���� �Ӽ����� �����Ǵ� ���̺� 2���� �ۼ��ϼ���. �� FOREIGN KEY �� �����Ͽ� ���� ���̺��� �����͸� ���� ��
-- �ٸ� ���̺��� ���õǴ� �����͵� ��� �����ǵ��� �ϼ���. (��� ���������� ���)
-- ��, �� ���̺� 5���� �����͸� �Է��ϰ� �ι�° ���̺� ù��° �����͸� �����ϰ� �ִ� �Ӽ��� �����Ͽ� ������ ����

DROP TABLE mart;
CREATE TABLE mart (
custid NUMBER PRIMARY KEY,
name VARCHAR(20),
age NUMBER,
sx VARCHAR2(20), -- char
phone NUMBER NOT NULL,
address VARCHAR2(100),
frequenct NUMBER, -- �湮 ��
amount_num NUMBER,
amount_price NUMBER,
parking VARCHAR2(20), -- ���� ���� n y�� char�� �ϴ°� ����
family NUMBER -- ���� ������ ��
);

ALTER TABLE mart DROP COLUMN amount_num;
ALTER TABLE mart MODIFY (name VARCHAR2(30));
ALTER TABLE mart MODIFY (phone VARCHAR2(20));

DESC mart;
INSERT INTO mart VALUES(1, '��浿', 32, '��', '010-1234-1234', '���� ����', 5, 1500000, 'N', 3);
INSERT INTO mart VALUES(2, '�����', 31, '��', '010-7777-1234', '���� ��õ', 5, 200000000, 'Y', 4);
INSERT INTO mart VALUES(3, '�̼���', 57, '��', '010-1592-1234', '�泲 �뿵', 5, 270000, 'N', 1);
INSERT INTO mart VALUES(4, '������', 30, '��', '010-0516-1234', '���� ����', 5, 750000000, 'Y', 4);
INSERT INTO mart VALUES(5, '�ӿ���', 30, '��', '010-0517-1235', '���� ����', 5, 75000000, 'Y', 2);

SELECT * FROM mart;

DROP TABLE department;

CREATE TABLE department(
    custid number PRIMARY KEY
    , name VARCHAR(20)
    , age NUMBER
    , sx VARCHAR2(20)
    , phone NUMBERr NOT NULL
    , address VARCHAR2(100)
    , use_store VARCHAR2(100) -- ���� ã�� ����
    , amount_num NUMBER
    , amount_price NUMBERr
    , valet VARCHAR2(20) -- �߷���ŷ ���� ��뿩��
    , rounge VARCHAR2(20) -- vip ����� ��뿩��
    , FOREGIN KEY (custid) references mart(custid) ON DELETE CASCADE
);

ALTER TABLE department MODIFY (amount_price check (amount_price > 100000000));
ALTER TABLE department MODIFY (rounge default 'Y');
ALTER TABLE department MODIFY (valet default 'Y');
ALTER TABLE department MODIFY (phone varchar2(100));
ALTER TABLE department DROP COLUMN amount_num;
-- ALTER TABLE department ADD (custid number);

SELECT * FROM department;

INSERT INTO department VALUES(1, '�����', 31, '��', '010-7777-1234', '���� ��õ', 'LV', 900000000,'','');
INSERT INTO department VALUES(2, '������', 30, '��', '010-0516-1234', '���� ����', 'GUCCI', 1500000000,'','');
INSERT INTO department VALUES(3, '������', 31, '��', '010-7775-1235', '���� ��õ', 'LV', 900000000,'','');
INSERT INTO department VALUES(4, '�ڼ���', 30, '��', '010-0516-1234', '���� ����', 'GUCCI', 1500000000,'','');
INSERT INTO department VALUES(5, '�ӿ���', 30, '��', '010-0517-1235', '���� ����', 'ROLEX', 150000000,'','');

DELETE mart
WHERE custid = 1;

ALTER TABLE department MODIFY 


SELECT * FROM orders;
SELECT custid AS ����ȣ, ROUND(AVG(saleprice), -2) AS ����ֹ��ݾ�
FROM orders
GROUP BY custid;

SELECT bookname ����, LENGTH(bookname) ���ڼ�, LENGTHB(bookname) ����Ʈ��
FROM book
WHERE publisher = '�½�����';

-- Task2_0520. Customer ���̺��� �ڼ��� ���� �ּҸ� �迬�� ���� �ּҷ� �����Ͻÿ�.
UPDATE customer
SET address = (
SELECT address
FROM customer
WHERE name = '�迬��')
WHERE name = '�ڼ���';

SELECT address, name FROM customer;

UPDATE customer
SET address = '���ѹα� ����'
WHERE name = '�ڼ���';

-- Task3_0520.���� ���� ���߱����� ���Ե� ������ ���󱸡��� ������ �� ���� ���, ������ ���̽ÿ�.
SELECT bookid, REPLACE(bookname, '�߱�','��') bookname, publisher, price
FROM book;
SELECT * FROM book;

-- Task4_0520. ���缭���� �� �߿��� ���� ��(��)�� ���� ����� �� ���̳� �Ǵ��� ���� �ο����� ���Ͻÿ�.
SELECT * FROM customer;
-- ù��° ����(1)���� ���� ���ð���, ���� ���ذ� �������(ǥ����) �ͼ������� ������ �빮�ڷ� ����
-- substr(name, 1, 1) �Լ��� ���ڿ� �̸��� ù��° ���ں��� �����Ͽ� �� ���ڸ� ��ȯ
-- GROUP BY ������ substr(name, 1, 1) ǥ������ ����ؾ� ��/��Ī ��� �Ұ�
SELECT substr(name, 1, 1) ��, COUNT(*) �ο�
FROM customer
GROUP BY substr(name, 1, 1);

-- Task5_0520. ���缭���� �ֹ��Ϸκ��� 10�� �� ������ Ȯ���Ѵ�. �� �ֹ��� Ȯ�����ڸ� ���Ͻÿ�.
SELECT * FROM orders;
SELECT orderid, orderdate AS �ֹ���, orderdate + 10 AS Ȯ������
FROM orders;

-- Q. ���缭���� �ֹ��Ϸκ��� 2���� �� ������ Ȯ���Ѵ�. �� �ֹ��� Ȯ�����ڸ� ���Ͻÿ�.
SELECT orderid, orderdate AS �ֹ���, ADD_MONTHS(orderdate, 2) AS Ȯ������
FROM orders;

-- Task6_0520.���缭���� 2020�� 7�� 7�Ͽ� �ֹ����� ������ �ֹ���ȣ, �ֹ���, ����ȣ, ������ȣ�� ��� ���̽ÿ�. 
-- �� �ֹ����� ��yyyy-mm-dd ���ϡ� ���·� ǥ���Ѵ�.
SELECT orderid �ֹ���ȣ, orderdate, TO_CHAR(orderdate, 'YYYY-mm-dd day') �ֹ���, custid ����ȣ, bookid ������ȣ
FROM orders
WHERE orderdate = '2020-07-07';
DESC orders;
-- TO_DATE ���ڿ� �ν��ϰ� ����
-- WHERE orderdate = TO_DATE('2020-07-07', 'YYYY-MM-DD');
-- WHERE orderdate = TO_DATE('20/07/07', 'YY/MM/DD');

-- Task7_0520. ��� �ֹ��ݾ� ������ �ֹ��� ���ؼ� �ֹ���ȣ�� �ݾ��� ���̽ÿ�.
SELECT saleprice, orderid
FROM orders
WHERE saleprice < (SELECT AVG(saleprice) FROM orders);

-- ���̺� �ΰ��� ������
SELECT O1.orderid, O1.saleprice
FROM orders O1
WHERE O1.saleprice < (SELCET AVG(O2.saleprice)
FROM orders O2);

-- ���� ���� ��ü�� o2��� ��Ī���� ����, saleprice�� ��� ���� avg_saleprice�� ���
SELECT O1.orderid, O1.saleprice
FROM orders O1
JOIN (SELECT AVG(saleprice) AS avg_saleprice FROM orders) O2
ON O1.saleprice < O2.avg_saleprice;


-- Task8_0520. ���ѹα����� �����ϴ� ������ �Ǹ��� ������ �� �Ǹž��� ���Ͻÿ�.
SELECT address, custid
FROM customer
WHERE address LIKE '���ѹα�%';

SELECT SUM(saleprice) AS ���Ǹž� FROM orders
WHERE custid IN (SELECT custid FROM customer WHERE address LIKE '%���ѹα�%');

-- �б� ������ ���� ���̺� 2�� �̻����� db�� �����ϰ� 3�� �̻� Ȱ���� �� �ִ� case�� ���弼��

-- Q. DBMS ������ ������ ���� ��¥�� �ð�, ������ Ȯ���Ͻÿ�
SELECT SYSDATE, TO_CHAR(SYSDATE, 'YYYY-mm-dd HH:MI:SS day') SYSDATE1
FROM DUAL;

-- Q. �̸�, ��ȭ��ȣ�� ���Ե� ������� ���̽ÿ�. ��, ��ȭ��ȣ�� ���� ���� '����ó����'���� ǥ���Ͻÿ�.
-- NVL �Լ��� ���� NULL�� ��� �������� ����ϰ�, NULL�� �ƴϸ� �������� �״�� ����Ѵ�. �Լ� : NVL("��", "������")
SELECT name �̸�, NVL(phone, '����ó����') ��ȭ��ȣ
FROM customer;

-- Q. ����Ͽ��� ����ȣ, �̸�, ��ȭ��ȣ�� ���� �θ� ���̽ÿ�
-- ROWNUM : ����Ŭ���� �ڵ����� �����ϴ� ���� ���� ������ ����Ǵ� ���� �� �࿡ �Ϸù�ȣ�� �ڵ����� �Ҵ�
SELECT ROWNUM ����, custid ����ȣ, name �̸�, phone ��ȭ��ȣ
FROM customer
WHERE ROWNUM < 3;

DROP TABLE newcustomer CASCADE CONSTRAINTS;
commit;