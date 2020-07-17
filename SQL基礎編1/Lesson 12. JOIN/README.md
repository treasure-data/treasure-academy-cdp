# Lesson 12. JOIN

## INNER JOIN

### レコード数が変わらないケース
#### 主に使用するデータ：sales_slip_sp
|receit_id                                  |member_id|goods_id                 |
|-------------------------------------------|---------|-------------------------|
|1                                          |member01'|1                        |
|2                                          |member02'|2                        |
|3                                          |member03'|3                        |
|4                                          |member01'|4                        |
|5                                          |member04'|1                        |

#### 主に使用するデータ：master_memers
|member_id                                  |mail|gender                   |age|
|-------------------------------------------|----|-------------------------|---|
|member01'                                  |takayama_kazuhisa@example.com'|m'                       |27 |
|member02'                                  |akiyama_hiromasa@example.com'|m'                       |33 |
|member03'                                  |iwasawa_kogan@example.com'|m'                       |30 |
|member04'                                  |takao_ayaka@example.com'|f'                       |40 |

## 主に使用するデータ：master_smartphones
|goods_id                                   |os |goods_name               |price|
|-------------------------------------------|---|-------------------------|-----|
|1                                          |iOS'|Apple iPhone XS 256GB'   |117480|
|2                                          |android'|ASUS ROG Phone 2 512GB'  |91080|
|3                                          |iOS'|Apple iPhone 8 256GB'    |78540|
|4                                          |android'|HUAWEI Mate 20 Pro'      |79200|
|5                                          |iOS'|Apple iPhone 7 32GB'     |37180|
|6                                          |android'|SHARP AQUOS zero'        |48180|

```sql
WITH sales_slip_sp AS 
( SELECT receit_id,member_id,goods_id FROM ( 
  VALUES 
(1,'member01',1),
(2,'member02',2),
(3,'member03',3),
(4,'member01',4),
(5,'member04',1)
) AS t(receit_id,member_id,goods_id) ),

master_members AS
( SELECT member_id,mail,gender,age FROM ( 
  VALUES
('member01','takayama_kazuhisa@example.com','m',27),
('member02','akiyama_hiromasa@example.com', 'm',33),
('member03','iwasawa_kogan@example.com',   'm',30),
('member04','takao_ayaka@example.com',      'f',40)
) AS t(member_id,mail,gender,age) ),

master_smartphones AS 
( SELECT goods_id,os,goods_name,price FROM (
  VALUES
(1,'iOS',    'Apple iPhone XS 256GB',117480),
(2,'android','ASUS ROG Phone 2 512GB',91080),
(3,'iOS',    'Apple iPhone 8 256GB',   78540),
(4,'android','HUAWEI Mate 20 Pro',    79200),
(5,'iOS',    'Apple iPhone 7 32GB',   37180),
(6,'android','SHARP AQUOS zero',      48180)
) AS t(goods_id,os,goods_name,price) )

SELECT receit_id, slip.member_id, goods_id, mail, gender, age 
FROM sales_slip_sp slip
JOIN master_members members
ON slip.member_id = members.member_id
```
|receit_id                                  |member_id|goods_id                 |mail|gender|age|
|-------------------------------------------|---------|-------------------------|----|------|---|
|1                                          |member01 |1                        |takayama_kazuhisa@example.com|m     |27 |
|2                                          |member02 |2                        |akiyama_hiromasa@example.com|m     |33 |
|3                                          |member03 |3                        |iwasawa_kogan@example.com|m     |30 |
|4                                          |member01 |4                        |takayama_kazuhisa@example.com|m     |27 |
|5                                          |member04 |1                        |takao_ayaka@example.com|f     |40 |


```sql
WITH sales_slip_sp AS 
( SELECT receit_id,member_id,goods_id FROM ( 
  VALUES 
(1,'member01',1),
(2,'member02',2),
(3,'member03',3),
(4,'member01',4),
(5,'member04',1)
) AS t(receit_id,member_id,goods_id) ),

master_members AS
( SELECT member_id,mail,gender,age FROM ( 
  VALUES
('member01','takayama_kazuhisa@example.com','m',27),
('member02','akiyama_hiromasa@example.com', 'm',33),
('member03','iwasawa_kogan@example.com',   'm',30),
('member04','takao_ayaka@example.com',      'f',40)
) AS t(member_id,mail,gender,age) ),

master_smartphones AS 
( SELECT goods_id,os,goods_name,price FROM (
  VALUES
(1,'iOS',    'Apple iPhone XS 256GB',117480),
(2,'android','ASUS ROG Phone 2 512GB',91080),
(3,'iOS',    'Apple iPhone 8 256GB',   78540),
(4,'android','HUAWEI Mate 20 Pro',    79200),
(5,'iOS',    'Apple iPhone 7 32GB',   37180),
(6,'android','SHARP AQUOS zero',      48180)
) AS t(goods_id,os,goods_name,price) )

SELECT receit_id, slip.member_id, mail, gender, age, 
  slip.goods_id, os, goods_name, price
FROM sales_slip_sp slip
JOIN master_members members
ON slip.member_id = members.member_id
JOIN master_smartphones smartphones
ON slip.goods_id = smartphones.goods_id
```
|receit_id                                  |member_id|mail                     |gender|age|goods_id|os     |goods_name            |price |
|-------------------------------------------|---------|-------------------------|------|---|--------|-------|----------------------|------|
|1                                          |member01 |takayama_kazuhisa@example.com|m     |27 |1       |iOS    |Apple iPhone XS 256GB |117480|
|2                                          |member02 |akiyama_hiromasa@example.com|m     |33 |2       |android|ASUS ROG Phone 2 512GB|91080 |
|3                                          |member03 |iwasawa_kogan@example.com|m     |30 |3       |iOS    |Apple iPhone 8 256GB  |78540 |
|4                                          |member01 |takayama_kazuhisa@example.com|m     |27 |4       |android|HUAWEI Mate 20 Pro    |79200 |
|5                                          |member04 |takao_ayaka@example.com  |f     |40 |1       |iOS    |Apple iPhone XS 256GB |117480|


```sql
-- WITH 文は省略
SELECT receit_id, slip.member_id, mail, gender, age,
  slip.goods_id, os, goods_name, price
FROM sales_slip_sp slip
JOIN
( 
  SELECT * FROM master_members 
) members
ON slip.member_id = members.member_id
JOIN
( 
  SELECT * FROM master_smartphones
) smartphones
ON slip.goods_id = smartphones.goods_id
```

### レコード数が減るケース

#### 主に使用するデータ：sales_slip_sp
|receit_id                                  |member_id|goods_id                 |gender|os      |
|-------------------------------------------|---------|-------------------------|------|--------|
|1                                          |member01'|1                        |m'    |iOS'    |
|2                                          |member02'|2                        |m'    |android'|
|3                                          |member03'|3                        |m'    |iOS'    |
|4                                          |member01'|4                        |m'    |android'|
|5                                          |member04'|1                        |f'    |iOS'    |
|6                                          |member05'|4                        |f'    |android'|
|7                                          |member02'|7                        |m'    |android'|

#### 主に使用するデータ：master_memers
|member_id                                  |mail|gender                   |age|
|-------------------------------------------|----|-------------------------|---|
|member01'                                  |takayama_kazuhisa@example.com'|m'                       |27 |
|member02'                                  |akiyama_hiromasa@example.com'|m'                       |33 |
|member03'                                  |iwasawa_kogan@example.com'|m'                       |30 |
|member04'                                  |takao_ayaka@example.com'|f'                       |40 |
|member06'                                  |noriko_tanaka@example.com'|f'                       |22 |

#### 主に使用するデータ：master_smartphones
|goods_id                                   |os |goods_name               |price|
|-------------------------------------------|---|-------------------------|-----|
|1                                          |iOS'|Apple iPhone XS 256GB'   |117480|
|2                                          |android'|ASUS ROG Phone 2 512GB'  |91080|
|3                                          |iOS'|Apple iPhone 8 256GB'    |78540|
|4                                          |android'|HUAWEI Mate 20 Pro'      |79200|
|5                                          |iOS'|Apple iPhone 7 32GB'     |37180|
|6                                          |android'|SHARP AQUOS zero'        |48180|
|8                                          |android'|SHARP AQUOS sense3'      |21800|


#### receit_id = 6 が消滅する例

```sql
WITH sales_slip_sp AS 
( SELECT receit_id,member_id,goods_id,gender,os FROM ( 
  VALUES 
(1,'member01',1,'m',    'iOS'),
(2,'member02',2,'m','android'),
(3,'member03',3,'m',    'iOS'),
(4,'member01',4,'m','android'),
(5,'member04',1,'f',    'iOS'),
(6,'member05',4,'f','android'),
(7,'member02',7,'m','android')
) AS t(receit_id,member_id,goods_id,gender,os) ),

master_members AS
( SELECT member_id,mail,gender,age FROM ( 
  VALUES
('member01','takayama_kazuhisa@example.com','m',27),
('member02','akiyama_hiromasa@example.com', 'm',33),
('member03','iwasawa_kogan@example.com',    'm',30),
('member04','takao_ayaka@example.com',      'f',40),
('member06','noriko_tanaka@example.com',    'f',22)
) AS t(member_id,mail,gender,age) ),

master_smartphones AS 
( SELECT goods_id,os,goods_name,price FROM (
  VALUES
(1,'iOS',    'Apple iPhone XS 256GB',117480),
(2,'android','ASUS ROG Phone 2 512GB',91080),
(3,'iOS',    'Apple iPhone 8 256GB',   78540),
(4,'android','HUAWEI Mate 20 Pro',    79200),
(5,'iOS',    'Apple iPhone 7 32GB',   37180),
(6,'android','SHARP AQUOS zero',      48180),
(8,'android','SHARP AQUOS sense3',    21800)
) AS t(goods_id,os,goods_name,price) )

SELECT receit_id, slip.member_id, mail, members.gender, age, goods_id
FROM sales_slip_sp slip
JOIN master_members members
ON slip.member_id = members.member_id
```
|receit_id                                  |member_id|mail                     |gender|age|goods_id|
|-------------------------------------------|---------|-------------------------|------|---|--------|
|2                                          |member02 |akiyama_hiromasa@example.com|m     |33 |2       |
|1                                          |member01 |takayama_kazuhisa@example.com|m     |27 |1       |
|4                                          |member01 |takayama_kazuhisa@example.com|m     |27 |4       |
|3                                          |member03 |iwasawa_kogan@example.com|m     |30 |3       |
|5                                          |member04 |takao_ayaka@example.com  |f     |40 |1       |
|7                                          |member02 |akiyama_hiromasa@example.com|m     |33 |7       |


### receit_id = 7 が消滅する例

```sql
WITH sales_slip_sp AS 
( SELECT receit_id,member_id,goods_id,gender,os FROM ( 
  VALUES 
(1,'member01',1,'m',    'iOS'),
(2,'member02',2,'m','android'),
(3,'member03',3,'m',    'iOS'),
(4,'member01',4,'m','android'),
(5,'member04',1,'f',    'iOS'),
(6,'member05',4,'f','android'),
(7,'member02',7,'m','android')
) AS t(receit_id,member_id,goods_id,gender,os) ),

master_members AS
( SELECT member_id,mail,gender,age FROM ( 
  VALUES
('member01','takayama_kazuhisa@example.com','m',27),
('member02','akiyama_hiromasa@example.com', 'm',33),
('member03','iwasawa_kogan@example.com',    'm',30),
('member04','takao_ayaka@example.com',      'f',40),
('member06','noriko_tanaka@example.com',    'f',22)
) AS t(member_id,mail,gender,age) ),

master_smartphones AS 
( SELECT goods_id,os,goods_name,price FROM (
  VALUES
(1,'iOS',    'Apple iPhone XS 256GB',117480),
(2,'android','ASUS ROG Phone 2 512GB',91080),
(3,'iOS',    'Apple iPhone 8 256GB',   78540),
(4,'android','HUAWEI Mate 20 Pro',    79200),
(5,'iOS',    'Apple iPhone 7 32GB',   37180),
(6,'android','SHARP AQUOS zero',      48180),
(8,'android','SHARP AQUOS sense3',    21800)
) AS t(goods_id,os,goods_name,price) )

SELECT receit_id, member_id, slip.goods_id, smartphones.os, goods_name, price
FROM sales_slip_sp slip
JOIN master_smartphones smartphones
ON slip.goods_id = smartphones.goods_id
```
|receit_id                                  |member_id|goods_id                 |os |goods_name|price|
|-------------------------------------------|---------|-------------------------|---|----------|-----|
|1                                          |member01 |1                        |iOS|Apple iPhone XS 256GB|117480|
|4                                          |member01 |4                        |android|HUAWEI Mate 20 Pro|79200|
|5                                          |member04 |1                        |iOS|Apple iPhone XS 256GB|117480|
|6                                          |member05 |4                        |android|HUAWEI Mate 20 Pro|79200|
|2                                          |member02 |2                        |android|ASUS ROG Phone 2 512GB|91080|
|3                                          |member03 |3                        |iOS|Apple iPhone 8 256GB|78540|

### receit_id = 6および7が消滅する例

```sql
WITH sales_slip_sp AS 
( SELECT receit_id,member_id,goods_id,gender,os FROM ( 
  VALUES 
(1,'member01',1,'m',    'iOS'),
(2,'member02',2,'m','android'),
(3,'member03',3,'m',    'iOS'),
(4,'member01',4,'m','android'),
(5,'member04',1,'f',    'iOS'),
(6,'member05',4,'f','android'),
(7,'member02',7,'m','android')
) AS t(receit_id,member_id,goods_id,gender,os) ),

master_members AS
( SELECT member_id,mail,gender,age FROM ( 
  VALUES
('member01','takayama_kazuhisa@example.com','m',27),
('member02','akiyama_hiromasa@example.com', 'm',33),
('member03','iwasawa_kogan@example.com',    'm',30),
('member04','takao_ayaka@example.com',      'f',40),
('member06','noriko_tanaka@example.com',    'f',22)
) AS t(member_id,mail,gender,age) ),

master_smartphones AS 
( SELECT goods_id,os,goods_name,price FROM (
  VALUES
(1,'iOS',    'Apple iPhone XS 256GB',117480),
(2,'android','ASUS ROG Phone 2 512GB',91080),
(3,'iOS',    'Apple iPhone 8 256GB',   78540),
(4,'android','HUAWEI Mate 20 Pro',    79200),
(5,'iOS',    'Apple iPhone 7 32GB',   37180),
(6,'android','SHARP AQUOS zero',      48180),
(8,'android','SHARP AQUOS sense3',    21800)
) AS t(goods_id,os,goods_name,price) )

SELECT receit_id, slip.member_id, mail, members.gender, age, 
  smartphones.goods_id, smartphones.os, goods_name, price
FROM sales_slip_sp slip
JOIN master_members  members
ON slip.member_id = members.member_id
JOIN master_smartphones smartphones
ON slip.goods_id = smartphones.goods_id
```
|receit_id                                  |member_id|mail                     |gender|age|goods_id|os     |goods_name            |price |
|-------------------------------------------|---------|-------------------------|------|---|--------|-------|----------------------|------|
|4                                          |member01 |takayama_kazuhisa@example.com|m     |27 |4       |android|HUAWEI Mate 20 Pro    |79200 |
|5                                          |member04 |takao_ayaka@example.com  |f     |40 |1       |iOS    |Apple iPhone XS 256GB |117480|
|1                                          |member01 |takayama_kazuhisa@example.com|m     |27 |1       |iOS    |Apple iPhone XS 256GB |117480|
|2                                          |member02 |akiyama_hiromasa@example.com|m     |33 |2       |android|ASUS ROG Phone 2 512GB|91080 |
|3                                          |member03 |iwasawa_kogan@example.com|m     |30 |3       |iOS    |Apple iPhone 8 256GB  |78540 |


### レコード数が増えるケース（間違い）

```sql
WITH sales_slip_sp AS 
( SELECT receit_id,member_id,goods_id,gender,os FROM ( 
  VALUES 
(1,'member01',1,'m',    'iOS'),
(2,'member02',2,'m','android'),
(3,'member03',3,'m',    'iOS'),
(4,'member01',4,'m','android'),
(5,'member04',1,'f',    'iOS'),
(6,'member05',4,'f','android'),
(7,'member02',7,'m','android')
) AS t(receit_id,member_id,goods_id,gender,os) ),

master_members AS
( SELECT member_id,mail,gender,age FROM ( 
  VALUES
('member01','takayama_kazuhisa@example.com','m',27),
('member02','akiyama_hiromasa@example.com', 'm',33),
('member03','iwasawa_kogan@example.com',    'm',30),
('member04','takao_ayaka@example.com',      'f',40),
('member06','noriko_tanaka@example.com',    'f',22)
) AS t(member_id,mail,gender,age) ),

master_smartphones AS 
( SELECT goods_id,os,goods_name,price FROM (
  VALUES
(1,'iOS',    'Apple iPhone XS 256GB',117480),
(2,'android','ASUS ROG Phone 2 512GB',91080),
(3,'iOS',    'Apple iPhone 8 256GB',   78540),
(4,'android','HUAWEI Mate 20 Pro',    79200),
(5,'iOS',    'Apple iPhone 7 32GB',   37180),
(6,'android','SHARP AQUOS zero',      48180),
(8,'android','SHARP AQUOS sense3',    21800)
) AS t(goods_id,os,goods_name,price) )

SELECT receit_id, slip.member_id, slip.gender, mail, age
FROM sales_slip_sp slip
JOIN master_members members
ON slip.gender = members.gender
```
|receit_id                                  |member_id|gender                   |mail|age|
|-------------------------------------------|---------|-------------------------|----|---|
|1                                          |member01 |m                        |iwasawa_kogan@example.com|30 |
|1                                          |member01 |m                        |akiyama_hiromasa@example.com|33 |
|1                                          |member01 |m                        |takayama_kazuhisa@example.com|27 |
|...                                        |         |                         |    |   |
|7                                          |member02 |m                        |iwasawa_kogan@example.com|30 |
|7                                          |member02 |m                        |akiyama_hiromasa@example.com|33 |
|7                                          |member02 |m                        |takayama_kazuhisa@example.com|27 |


```sql
WITH sales_slip_sp AS 
( SELECT receit_id,member_id,goods_id,gender,os FROM ( 
  VALUES 
(1,'member01',1,'m',    'iOS'),
(2,'member02',2,'m','android'),
(3,'member03',3,'m',    'iOS'),
(4,'member01',4,'m','android'),
(5,'member04',1,'f',    'iOS'),
(6,'member05',4,'f','android'),
(7,'member02',7,'m','android')
) AS t(receit_id,member_id,goods_id,gender,os) ),

master_members AS
( SELECT member_id,mail,gender,age FROM ( 
  VALUES
('member01','takayama_kazuhisa@example.com','m',27),
('member02','akiyama_hiromasa@example.com', 'm',33),
('member03','iwasawa_kogan@example.com',    'm',30),
('member04','takao_ayaka@example.com',      'f',40),
('member06','noriko_tanaka@example.com',    'f',22)
) AS t(member_id,mail,gender,age) ),

master_smartphones AS 
( SELECT goods_id,os,goods_name,price FROM (
  VALUES
(1,'iOS',    'Apple iPhone XS 256GB',117480),
(2,'android','ASUS ROG Phone 2 512GB',91080),
(3,'iOS',    'Apple iPhone 8 256GB',   78540),
(4,'android','HUAWEI Mate 20 Pro',    79200),
(5,'iOS',    'Apple iPhone 7 32GB',   37180),
(6,'android','SHARP AQUOS zero',      48180),
(8,'android','SHARP AQUOS sense3',    21800)
) AS t(goods_id,os,goods_name,price) )

SELECT receit_id, slip.member_id, slip.gender, slip.goods_id, slip.os, goods_name, price
FROM sales_slip_sp slip
JOIN master_members members
ON slip.gender = members.gender
JOIN master_smartphones smartphones
ON slip.os = smartphones.os
```
|receit_id                                  |member_id|gender                   |goods_id|os |goods_name            |price |
|-------------------------------------------|---------|-------------------------|--------|---|----------------------|------|
|1                                          |member01 |m                        |1       |iOS|Apple iPhone XS 256GB |117480|
|1                                          |member01 |m                        |1       |iOS|Apple iPhone 7 32GB   |37180 |
|1                                          |member01 |m                        |1       |iOS|Apple iPhone 8 256GB  |78540 |
|...                                        |         |                         |        |   |                      |      |
|3                                          |member03 |m                        |3       |iOS|Apple iPhone XS 256GB |117480|
|3                                          |member03 |m                        |3       |iOS|Apple iPhone 7 32GB   |37180 |
|3                                          |member03 |m                        |3       |iOS|Apple iPhone 8 256GB  |78540 |

## LEFT OUTER JOIN

### レコードが変わらないケース

```sql
WITH sales_slip_sp AS 
( SELECT receit_id,member_id,goods_id,gender,os FROM ( 
  VALUES 
(1,'member01',1,'m',    'iOS'),
(2,'member02',2,'m','android'),
(3,'member03',3,'m',    'iOS'),
(4,'member01',4,'m','android'),
(5,'member04',1,'f',    'iOS'),
(6,'member05',4,'f','android'),
(7,'member02',7,'m','android')
) AS t(receit_id,member_id,goods_id,gender,os) ),

master_members AS
( SELECT member_id,mail,gender,age FROM ( 
  VALUES
('member01','takayama_kazuhisa@example.com','m',27),
('member02','akiyama_hiromasa@example.com', 'm',33),
('member03','iwasawa_kogan@example.com',    'm',30),
('member04','takao_ayaka@example.com',      'f',40),
('member06','noriko_tanaka@example.com',    'f',22)
) AS t(member_id,mail,gender,age) ),

master_smartphones AS 
( SELECT goods_id,os,goods_name,price FROM (
  VALUES
(1,'iOS',    'Apple iPhone XS 256GB',117480),
(2,'android','ASUS ROG Phone 2 512GB',91080),
(3,'iOS',    'Apple iPhone 8 256GB',   78540),
(4,'android','HUAWEI Mate 20 Pro',    79200),
(5,'iOS',    'Apple iPhone 7 32GB',   37180),
(6,'android','SHARP AQUOS zero',      48180),
(8,'android','SHARP AQUOS sense3',    21800)
) AS t(goods_id,os,goods_name,price) )

SELECT receit_id, slip.member_id, members.member_id, mail, members.gender, age, goods_id
FROM sales_slip_sp slip
LEFT OUTER JOIN master_members members
ON slip.member_id = members.member_id
```
|receit_id                                  |member_id|member_id                |mail|gender|age                   |goods_id|
|-------------------------------------------|---------|-------------------------|----|------|----------------------|--------|
|2                                          |member02 |member02                 |akiyama_hiromasa@example.com|m     |33                    |2       |
|3                                          |member03 |member03                 |iwasawa_kogan@example.com|m     |30                    |3       |
|1                                          |member01 |member01                 |takayama_kazuhisa@example.com|m     |27                    |1       |
|4                                          |member01 |member01                 |takayama_kazuhisa@example.com|m     |27                    |4       |
|5                                          |member04 |member04                 |takao_ayaka@example.com|f     |40                    |1       |
|6                                          |member05 |NULL                         |NULL    |NULL      |NULL                      |4       |
|7                                          |member02 |member02                 |akiyama_hiromasa@example.com|m     |33                    |7       |


```sql
WITH sales_slip_sp AS 
( SELECT receit_id,member_id,goods_id,gender,os FROM ( 
  VALUES 
(1,'member01',1,'m',    'iOS'),
(2,'member02',2,'m','android'),
(3,'member03',3,'m',    'iOS'),
(4,'member01',4,'m','android'),
(5,'member04',1,'f',    'iOS'),
(6,'member05',4,'f','android'),
(7,'member02',7,'m','android')
) AS t(receit_id,member_id,goods_id,gender,os) ),

master_members AS
( SELECT member_id,mail,gender,age FROM ( 
  VALUES
('member01','takayama_kazuhisa@example.com','m',27),
('member02','akiyama_hiromasa@example.com', 'm',33),
('member03','iwasawa_kogan@example.com',    'm',30),
('member04','takao_ayaka@example.com',      'f',40),
('member06','noriko_tanaka@example.com',    'f',22)
) AS t(member_id,mail,gender,age) ),

master_smartphones AS 
( SELECT goods_id,os,goods_name,price FROM (
  VALUES
(1,'iOS',    'Apple iPhone XS 256GB',117480),
(2,'android','ASUS ROG Phone 2 512GB',91080),
(3,'iOS',    'Apple iPhone 8 256GB',   78540),
(4,'android','HUAWEI Mate 20 Pro',    79200),
(5,'iOS',    'Apple iPhone 7 32GB',   37180),
(6,'android','SHARP AQUOS zero',      48180),
(8,'android','SHARP AQUOS sense3',    21800)
) AS t(goods_id,os,goods_name,price) )

SELECT receit_id, slip.member_id, mail, members.gender, age, 
  smartphones.goods_id, smartphones.os, goods_name, price
FROM sales_slip_sp slip
LEFT OUTER JOIN master_members members
ON slip.member_id = members.member_id
LEFT OUTER JOIN master_smartphones smartphones
ON slip.goods_id = smartphones.goods_id
```
|receit_id                                  |member_id|mail                     |gender|age|goods_id              |os    |goods_name            |price |
|-------------------------------------------|---------|-------------------------|------|---|----------------------|------|----------------------|------|
|2                                          |member02 |akiyama_hiromasa@example.com|m     |33 |2                     |android|ASUS ROG Phone 2 512GB|91080 |
|1                                          |member01 |takayama_kazuhisa@example.com|m     |27 |1                     |iOS   |Apple iPhone XS 256GB |117480|
|3                                          |member03 |iwasawa_kogan@example.com|m     |30 |3                     |iOS   |Apple iPhone 8 256GB  |78540 |
|4                                          |member01 |takayama_kazuhisa@example.com|m     |27 |4                     |android|HUAWEI Mate 20 Pro    |79200 |
|5                                          |member04 |takao_ayaka@example.com  |f     |40 |1                     |iOS   |Apple iPhone XS 256GB |117480|
|6                                          |member05 |NULL                         |NULL      |NULL   |4                     |android|HUAWEI Mate 20 Pro    |79200 |
|7                                          |member02 |akiyama_hiromasa@example.com|m     |33 |NULL                      |NULL      |NULL                      |NULL      |

### 結合できなかったレコードのほうを抽出する

```sql
WITH sales_slip_sp AS 
( SELECT receit_id,member_id,goods_id,gender,os FROM ( 
  VALUES 
(1,'member01',1,'m',    'iOS'),
(2,'member02',2,'m','android'),
(3,'member03',3,'m',    'iOS'),
(4,'member01',4,'m','android'),
(5,'member04',1,'f',    'iOS'),
(6,'member05',4,'f','android'),
(7,'member02',7,'m','android')
) AS t(receit_id,member_id,goods_id,gender,os) ),

master_members AS
( SELECT member_id,mail,gender,age FROM ( 
  VALUES
('member01','takayama_kazuhisa@example.com','m',27),
('member02','akiyama_hiromasa@example.com', 'm',33),
('member03','iwasawa_kogan@example.com',    'm',30),
('member04','takao_ayaka@example.com',      'f',40),
('member06','noriko_tanaka@example.com',    'f',22)
) AS t(member_id,mail,gender,age) ),

master_smartphones AS 
( SELECT goods_id,os,goods_name,price FROM (
  VALUES
(1,'iOS',    'Apple iPhone XS 256GB',117480),
(2,'android','ASUS ROG Phone 2 512GB',91080),
(3,'iOS',    'Apple iPhone 8 256GB',   78540),
(4,'android','HUAWEI Mate 20 Pro',    79200),
(5,'iOS',    'Apple iPhone 7 32GB',   37180),
(6,'android','SHARP AQUOS zero',      48180),
(8,'android','SHARP AQUOS sense3',    21800)
) AS t(goods_id,os,goods_name,price) )

SELECT receit_id, slip.member_id, members.member_id, mail, members.gender, age, goods_id
FROM sales_slip_sp slip
LEFT OUTER JOIN master_members members
ON slip.member_id = members.member_id
WHERE members.member_id IS NULL
```
|receit_id                                  |member_id|member_id                |mail|gender|age                   |goods_id|
|-------------------------------------------|---------|-------------------------|----|------|----------------------|--------|
|6                                          |member05 |NULL                         |NULL    |NULL      |NULL                      |4       |


```sql
WITH sales_slip_sp AS 
( SELECT receit_id,member_id,goods_id,gender,os FROM ( 
  VALUES 
(1,'member01',1,'m',    'iOS'),
(2,'member02',2,'m','android'),
(3,'member03',3,'m',    'iOS'),
(4,'member01',4,'m','android'),
(5,'member04',1,'f',    'iOS'),
(6,'member05',4,'f','android'),
(7,'member02',7,'m','android')
) AS t(receit_id,member_id,goods_id,gender,os) ),

master_members AS
( SELECT member_id,mail,gender,age FROM ( 
  VALUES
('member01','takayama_kazuhisa@example.com','m',27),
('member02','akiyama_hiromasa@example.com', 'm',33),
('member03','iwasawa_kogan@example.com',    'm',30),
('member04','takao_ayaka@example.com',      'f',40),
('member06','noriko_tanaka@example.com',    'f',22)
) AS t(member_id,mail,gender,age) ),

master_smartphones AS 
( SELECT goods_id,os,goods_name,price FROM (
  VALUES
(1,'iOS',    'Apple iPhone XS 256GB',117480),
(2,'android','ASUS ROG Phone 2 512GB',91080),
(3,'iOS',    'Apple iPhone 8 256GB',   78540),
(4,'android','HUAWEI Mate 20 Pro',    79200),
(5,'iOS',    'Apple iPhone 7 32GB',   37180),
(6,'android','SHARP AQUOS zero',      48180),
(8,'android','SHARP AQUOS sense3',    21800)
) AS t(goods_id,os,goods_name,price) )

SELECT receit_id, slip.member_id, mail, members.gender, age, 
  smartphones.goods_id, smartphones.os, goods_name, price
FROM sales_slip_sp slip
LEFT OUTER JOIN master_members members
ON slip.member_id = members.member_id
LEFT OUTER JOIN master_smartphones smartphones
ON slip.goods_id = smartphones.goods_id
WHERE members.member_id IS NULL OR smartphones.goods_id IS NULL
```
|receit_id                                  |member_id|mail                     |gender|age|goods_id              |os    |goods_name        |price|
|-------------------------------------------|---------|-------------------------|------|---|----------------------|------|------------------|-----|
|6                                          |member05 |NULL                         |NULL      |NULL   |4                     |android|HUAWEI Mate 20 Pro|79200|
|7                                          |member02 |akiyama_hiromasa@example.com|m     |33 |NULL                      |NULL      |NULL                  |NULL     |

### マスタデータがLEFT TABLEとなるケース

```sql
WITH sales_slip_sp AS 
( SELECT receit_id,member_id,goods_id,gender,os FROM ( 
  VALUES 
(1,'member01',1,'m',    'iOS'),
(2,'member02',2,'m','android'),
(3,'member03',3,'m',    'iOS'),
(4,'member01',4,'m','android'),
(5,'member04',1,'f',    'iOS'),
(6,'member05',4,'f','android'),
(7,'member02',7,'m','android')
) AS t(receit_id,member_id,goods_id,gender,os) ),

master_members AS
( SELECT member_id,mail,gender,age FROM ( 
  VALUES
('member01','takayama_kazuhisa@example.com','m',27),
('member02','akiyama_hiromasa@example.com', 'm',33),
('member03','iwasawa_kogan@example.com',    'm',30),
('member04','takao_ayaka@example.com',      'f',40),
('member06','noriko_tanaka@example.com',    'f',22)
) AS t(member_id,mail,gender,age) ),

master_smartphones AS 
( SELECT goods_id,os,goods_name,price FROM (
  VALUES
(1,'iOS',    'Apple iPhone XS 256GB',117480),
(2,'android','ASUS ROG Phone 2 512GB',91080),
(3,'iOS',    'Apple iPhone 8 256GB',   78540),
(4,'android','HUAWEI Mate 20 Pro',    79200),
(5,'iOS',    'Apple iPhone 7 32GB',   37180),
(6,'android','SHARP AQUOS zero',      48180),
(8,'android','SHARP AQUOS sense3',    21800)
) AS t(goods_id,os,goods_name,price) )

SELECT members.member_id, COALESCE(sales,0) AS sales, goods_names,
  mail, gender, age
FROM master_members members
LEFT OUTER JOIN
( 
  SELECT member_id, SUM(price) AS sales, ARRAY_AGG(goods_name) AS goods_names
  FROM sales_slip_sp slip
  JOIN
  ( SELECT goods_id, price, goods_name FROM master_smartphones ) smartphones
  ON slip.goods_id = smartphones.goods_id
  GROUP BY member_id
) slip
ON members.member_id = slip.member_id
ORDER BY member_id
```
|member_id                                  |sales|goods_names              |mail|gender|age                   |
|-------------------------------------------|-----|-------------------------|----|------|----------------------|
|member01                                   |196680|["Apple iPhone XS 256GB", "HUAWEI Mate 20 Pro"]|takayama_kazuhisa@example.com|m     |27                    |
|member02                                   |91080|["ASUS ROG Phone 2 512GB"]|akiyama_hiromasa@example.com|m     |33                    |
|member03                                   |78540|["Apple iPhone 8 256GB"] |iwasawa_kogan@example.com|m     |30                    |
|member04                                   |117480|["Apple iPhone XS 256GB"]|takao_ayaka@example.com|f     |40                    |
|member06                                   |0    |NULL                         |noriko_tanaka@example.com|f     |22                    |


## RIGHT OUTER JOIN

```sql
WITH sales_slip_sp AS 
( SELECT receit_id,member_id,goods_id,gender,os FROM ( 
  VALUES 
(1,'member01',1,'m',    'iOS'),
(2,'member02',2,'m','android'),
(3,'member03',3,'m',    'iOS'),
(4,'member01',4,'m','android'),
(5,'member04',1,'f',    'iOS'),
(6,'member05',4,'f','android'),
(7,'member02',7,'m','android')
) AS t(receit_id,member_id,goods_id,gender,os) ),

master_members AS
( SELECT member_id,mail,gender,age FROM ( 
  VALUES
('member01','takayama_kazuhisa@example.com','m',27),
('member02','akiyama_hiromasa@example.com', 'm',33),
('member03','iwasawa_kogan@example.com',    'm',30),
('member04','takao_ayaka@example.com',      'f',40),
('member06','noriko_tanaka@example.com',    'f',22)
) AS t(member_id,mail,gender,age) ),

master_smartphones AS 
( SELECT goods_id,os,goods_name,price FROM (
  VALUES
(1,'iOS',    'Apple iPhone XS 256GB',117480),
(2,'android','ASUS ROG Phone 2 512GB',91080),
(3,'iOS',    'Apple iPhone 8 256GB',   78540),
(4,'android','HUAWEI Mate 20 Pro',    79200),
(5,'iOS',    'Apple iPhone 7 32GB',   37180),
(6,'android','SHARP AQUOS zero',      48180),
(8,'android','SHARP AQUOS sense3',    21800)
) AS t(goods_id,os,goods_name,price) )

SELECT members.member_id, receit_id, mail, members.gender, age, goods_id
FROM sales_slip_sp slip
RIGHT OUTER JOIN master_members members
ON members.member_id = slip.member_id
ORDER BY members.member_id, receit_id
```
|member_id                                  |receit_id|mail                     |gender|age|goods_id              |
|-------------------------------------------|---------|-------------------------|------|---|----------------------|
|member01                                   |1        |takayama_kazuhisa@example.com|m     |27 |1                     |
|member01                                   |4        |takayama_kazuhisa@example.com|m     |27 |4                     |
|member02                                   |2        |akiyama_hiromasa@example.com|m     |33 |2                     |
|member02                                   |7        |akiyama_hiromasa@example.com|m     |33 |7                     |
|member03                                   |3        |iwasawa_kogan@example.com|m     |30 |3                     |
|member04                                   |5        |takao_ayaka@example.com  |f     |40 |1                     |
|member06                                   |NULL         |noriko_tanaka@example.com|f     |22 |NULL                      |

```sql
WITH sales_slip_sp AS 
( SELECT receit_id,member_id,goods_id,gender,os FROM ( 
  VALUES 
(1,'member01',1,'m',    'iOS'),
(2,'member02',2,'m','android'),
(3,'member03',3,'m',    'iOS'),
(4,'member01',4,'m','android'),
(5,'member04',1,'f',    'iOS'),
(6,'member05',4,'f','android'),
(7,'member02',7,'m','android')
) AS t(receit_id,member_id,goods_id,gender,os) ),

master_members AS
( SELECT member_id,mail,gender,age FROM ( 
  VALUES
('member01','takayama_kazuhisa@example.com','m',27),
('member02','akiyama_hiromasa@example.com', 'm',33),
('member03','iwasawa_kogan@example.com',    'm',30),
('member04','takao_ayaka@example.com',      'f',40),
('member06','noriko_tanaka@example.com',    'f',22)
) AS t(member_id,mail,gender,age) ),

master_smartphones AS 
( SELECT goods_id,os,goods_name,price FROM (
  VALUES
(1,'iOS',    'Apple iPhone XS 256GB',117480),
(2,'android','ASUS ROG Phone 2 512GB',91080),
(3,'iOS',    'Apple iPhone 8 256GB',   78540),
(4,'android','HUAWEI Mate 20 Pro',    79200),
(5,'iOS',    'Apple iPhone 7 32GB',   37180),
(6,'android','SHARP AQUOS zero',      48180),
(8,'android','SHARP AQUOS sense3',    21800)
) AS t(goods_id,os,goods_name,price) )

SELECT smartphones.goods_id, receit_id, member_id, os, goods_name, price
FROM master_smartphones smartphones
RIGHT OUTER JOIN
( 
  SELECT receit_id, member_id, goods_id  FROM sales_slip_sp
) slip
ON smartphones.goods_id = slip.goods_id
ORDER BY goods_id, receit_id
```
|goods_id                                   |receit_id|member_id                |os |goods_name|price                 |
|-------------------------------------------|---------|-------------------------|---|----------|----------------------|
|1                                          |1        |member01                 |iOS|Apple iPhone XS 256GB|117480                |
|1                                          |5        |member04                 |iOS|Apple iPhone XS 256GB|117480                |
|2                                          |2        |member02                 |android|ASUS ROG Phone 2 512GB|91080                 |
|3                                          |3        |member03                 |iOS|Apple iPhone 8 256GB|78540                 |
|4                                          |4        |member01                 |android|HUAWEI Mate 20 Pro|79200                 |
|4                                          |6        |member05                 |android|HUAWEI Mate 20 Pro|79200                 |
|NULL                                       |7        |member02                 |NULL|NULL      |NULL                  |


## FULL OUTER JOIN

```sql
WITH sales_slip_sp AS 
( SELECT receit_id,member_id,goods_id,gender,os FROM ( 
  VALUES 
(1,'member01',1,'m',    'iOS'),
(2,'member02',2,'m','android'),
(3,'member03',3,'m',    'iOS'),
(4,'member01',4,'m','android'),
(5,'member04',1,'f',    'iOS'),
(6,'member05',4,'f','android'),
(7,'member02',7,'m','android')
) AS t(receit_id,member_id,goods_id,gender,os) ),

master_members AS
( SELECT member_id,mail,gender,age FROM ( 
  VALUES
('member01','takayama_kazuhisa@example.com','m',27),
('member02','akiyama_hiromasa@example.com', 'm',33),
('member03','iwasawa_kogan@example.com',    'm',30),
('member04','takao_ayaka@example.com',      'f',40),
('member06','noriko_tanaka@example.com',    'f',22)
) AS t(member_id,mail,gender,age) ),

master_smartphones AS 
( SELECT goods_id,os,goods_name,price FROM (
  VALUES
(1,'iOS',    'Apple iPhone XS 256GB',117480),
(2,'android','ASUS ROG Phone 2 512GB',91080),
(3,'iOS',    'Apple iPhone 8 256GB',   78540),
(4,'android','HUAWEI Mate 20 Pro',    79200),
(5,'iOS',    'Apple iPhone 7 32GB',   37180),
(6,'android','SHARP AQUOS zero',      48180),
(8,'android','SHARP AQUOS sense3',    21800)
) AS t(goods_id,os,goods_name,price) )

SELECT receit_id, slip.member_id, members.member_id, mail, members.gender, age, goods_id
FROM sales_slip_sp slip
FULL OUTER JOIN master_members members
ON slip.member_id = members.member_id
```
|receit_id                                  |member_id|member_id                |mail|gender|age                   |goods_id|
|-------------------------------------------|---------|-------------------------|----|------|----------------------|--------|
|6                                          |member05 |NULL                     |NULL|NULL  |NULL                  |4       |
|5                                          |member04 |member04                 |takao_ayaka@example.com|f     |40                    |1       |
|3                                          |member03 |member03                 |iwasawa_kogan@example.com|m     |30                    |3       |
|1                                          |member01 |member01                 |takayama_kazuhisa@example.com|m     |27                    |1       |
|2                                          |member02 |member02                 |akiyama_hiromasa@example.com|m     |33                    |2       |
|4                                          |member01 |member01                 |takayama_kazuhisa@example.com|m     |27                    |4       |
|7                                          |member02 |member02                 |akiyama_hiromasa@example.com|m     |33                    |7       |
|NULL                                       |NULL     |member06                 |noriko_tanaka@example.com|f     |22                    |NULL    |


```sql
WITH sales_slip_sp AS 
( SELECT receit_id,member_id,goods_id,gender,os FROM ( 
  VALUES 
(1,'member01',1,'m',    'iOS'),
(2,'member02',2,'m','android'),
(3,'member03',3,'m',    'iOS'),
(4,'member01',4,'m','android'),
(5,'member04',1,'f',    'iOS'),
(6,'member05',4,'f','android'),
(7,'member02',7,'m','android')
) AS t(receit_id,member_id,goods_id,gender,os) ),

master_members AS
( SELECT member_id,mail,gender,age FROM ( 
  VALUES
('member01','takayama_kazuhisa@example.com','m',27),
('member02','akiyama_hiromasa@example.com', 'm',33),
('member03','iwasawa_kogan@example.com',    'm',30),
('member04','takao_ayaka@example.com',      'f',40),
('member06','noriko_tanaka@example.com',    'f',22)
) AS t(member_id,mail,gender,age) ),

master_smartphones AS 
( SELECT goods_id,os,goods_name,price FROM (
  VALUES
(1,'iOS',    'Apple iPhone XS 256GB',117480),
(2,'android','ASUS ROG Phone 2 512GB',91080),
(3,'iOS',    'Apple iPhone 8 256GB',   78540),
(4,'android','HUAWEI Mate 20 Pro',    79200),
(5,'iOS',    'Apple iPhone 7 32GB',   37180),
(6,'android','SHARP AQUOS zero',      48180),
(8,'android','SHARP AQUOS sense3',    21800)
) AS t(goods_id,os,goods_name,price) )

SELECT receit_id, slip.member_id, mail, members.gender, age, 
  smartphones.goods_id, smartphones.os, goods_name, price
FROM sales_slip_sp slip
FULL OUTER JOIN master_members members
ON slip.member_id = members.member_id
FULL OUTER JOIN master_smartphones smartphones
ON slip.goods_id = smartphones.goods_id
```
|receit_id                                  |member_id|mail                     |gender|age|goods_id              |os  |goods_name            |price |
|-------------------------------------------|---------|-------------------------|------|---|----------------------|----|----------------------|------|
|NULL                                       |NULL     |noriko_tanaka@example.com|f     |22 |NULL                  |NULL|NULL                  |NULL  |
|6                                          |member05 |NULL                     |NULL  |NULL|4                     |android|HUAWEI Mate 20 Pro    |79200 |
|5                                          |member04 |takao_ayaka@example.com  |f     |40 |1                     |iOS |Apple iPhone XS 256GB |117480|
|3                                          |member03 |iwasawa_kogan@example.com|m     |30 |3                     |iOS |Apple iPhone 8 256GB  |78540 |
|4                                          |member01 |takayama_kazuhisa@example.com|m     |27 |4                     |android|HUAWEI Mate 20 Pro    |79200 |
|1                                          |member01 |takayama_kazuhisa@example.com|m     |27 |1                     |iOS |Apple iPhone XS 256GB |117480|
|7                                          |member02 |akiyama_hiromasa@example.com|m     |33 |NULL                      |NULL    |NULL                      |NULL      |
|2                                          |member02 |akiyama_hiromasa@example.com|m     |33 |2                     |android|ASUS ROG Phone 2 512GB|91080 |
|NULL                                       |NULL     |NULL                     |NULL  |NULL|5                     |iOS |Apple iPhone 7 32GB   |37180 |
|NULL                                       |NULL     |NULL                     |NULL  |NULL|6                     |android|SHARP AQUOS zero      |48180 |
|NULL                                       |NULL     |NULL                     |NULL  |NULL|8                     |android|SHARP AQUOS sense3    |21800 |


## WHEREとONの違い

### ON → JOIN（推奨）

```sql
WITH sales_slip_sp AS 
( SELECT receit_id,member_id,goods_id,gender,os FROM ( 
  VALUES 
(1,'member01',1,'m',    'iOS'),
(2,'member02',2,'m','android'),
(3,'member03',3,'m',    'iOS'),
(4,'member01',4,'m','android'),
(5,'member04',1,'f',    'iOS'),
(6,'member05',4,'f','android'),
(7,'member02',7,'m','android')
) AS t(receit_id,member_id,goods_id,gender,os) ),

master_members AS
( SELECT member_id,mail,gender,age FROM ( 
  VALUES
('member01','takayama_kazuhisa@example.com','m',27),
('member02','akiyama_hiromasa@example.com', 'm',33),
('member03','iwasawa_kogan@example.com',    'm',30),
('member04','takao_ayaka@example.com',      'f',40),
('member06','noriko_tanaka@example.com',    'f',22)
) AS t(member_id,mail,gender,age) ),

master_smartphones AS 
( SELECT goods_id,os,goods_name,price FROM (
  VALUES
(1,'iOS',    'Apple iPhone XS 256GB',117480),
(2,'android','ASUS ROG Phone 2 512GB',91080),
(3,'iOS',    'Apple iPhone 8 256GB',   78540),
(4,'android','HUAWEI Mate 20 Pro',    79200),
(5,'iOS',    'Apple iPhone 7 32GB',   37180),
(6,'android','SHARP AQUOS zero',      48180),
(8,'android','SHARP AQUOS sense3',    21800)
) AS t(goods_id,os,goods_name,price) )

SELECT receit_id, slip.member_id, age
FROM sales_slip_sp slip
JOIN master_members members
ON slip.member_id = members.member_id
AND 30 <= members.age
```
|receit_id                                  |member_id|age                      |
|-------------------------------------------|---------|-------------------------|
|2                                          |member02 |33                       |
|5                                          |member04 |40                       |
|7                                          |member02 |33                       |
|3                                          |member03 |30                       |


```sql
-- Hive
WITH sales_slip_sp AS 
( SELECT STACK(
    7,
    1,'member01',1,'m',    'iOS',
    2,'member02',2,'m','android',
    3,'member03',3,'m',    'iOS',
    4,'member01',4,'m','android',
    5,'member04',1,'f',    'iOS',
    6,'member05',4,'f','android',
    7,'member02',7,'m','android'
  ) AS (receit_id,member_id,goods_id,gender,os)
),

master_members AS
( SELECT STACK(
    5,
    'member01','takayama_kazuhisa@example.com','m',27,
    'member02','akiyama_hiromasa@example.com', 'm',33,
    'member03','iwasawa_kogan@example.com',    'm',30,
    'member04','takao_ayaka@example.com',      'f',40,
    'member06','noriko_tanaka@example.com',    'f',22
  ) AS (member_id,mail,gender,age)
)

SELECT receit_id, slip.member_id, age
FROM sales_slip_sp slip
JOIN master_members members
ON slip.member_id = members.member_id
AND slip.goods_id <= members.age
```

Hive0.13で上記を実行すると
```sql
SemanticException: Line 33:4 Both left and right aliases encountered in JOIN 'age'
```
というエラーになります。

### JOIN → WHERE（非推奨）

```sql
WITH sales_slip_sp AS 
( SELECT receit_id,member_id,goods_id,gender,os FROM ( 
  VALUES 
(1,'member01',1,'m',    'iOS'),
(2,'member02',2,'m','android'),
(3,'member03',3,'m',    'iOS'),
(4,'member01',4,'m','android'),
(5,'member04',1,'f',    'iOS'),
(6,'member05',4,'f','android'),
(7,'member02',7,'m','android')
) AS t(receit_id,member_id,goods_id,gender,os) ),

master_members AS
( SELECT member_id,mail,gender,age FROM ( 
  VALUES
('member01','takayama_kazuhisa@example.com','m',27),
('member02','akiyama_hiromasa@example.com', 'm',33),
('member03','iwasawa_kogan@example.com',    'm',30),
('member04','takao_ayaka@example.com',      'f',40),
('member06','noriko_tanaka@example.com',    'f',22)
) AS t(member_id,mail,gender,age) ),

master_smartphones AS 
( SELECT goods_id,os,goods_name,price FROM (
  VALUES
(1,'iOS',    'Apple iPhone XS 256GB',117480),
(2,'android','ASUS ROG Phone 2 512GB',91080),
(3,'iOS',    'Apple iPhone 8 256GB',   78540),
(4,'android','HUAWEI Mate 20 Pro',    79200),
(5,'iOS',    'Apple iPhone 7 32GB',   37180),
(6,'android','SHARP AQUOS zero',      48180),
(8,'android','SHARP AQUOS sense3',    21800)
) AS t(goods_id,os,goods_name,price) )

SELECT receit_id, slip.member_id, age
FROM sales_slip_sp slip
JOIN master_members members
ON slip.member_id = members.member_id
WHERE 30 <= members.age
```
|receit_id                                  |member_id|age                      |
|-------------------------------------------|---------|-------------------------|
|5                                          |member04 |40                       |
|2                                          |member02 |33                       |
|7                                          |member02 |33                       |
|3                                          |member03 |30                       |


```sql
-- Hive
WITH sales_slip_sp AS 
( SELECT STACK(
    7,
    1,'member01',1,'m',    'iOS',
    2,'member02',2,'m','android',
    3,'member03',3,'m',    'iOS',
    4,'member01',4,'m','android',
    5,'member04',1,'f',    'iOS',
    6,'member05',4,'f','android',
    7,'member02',7,'m','android'
  ) AS (receit_id,member_id,goods_id,gender,os)
),

master_members AS
( SELECT STACK(
    5,
    'member01','takayama_kazuhisa@example.com','m',27,
    'member02','akiyama_hiromasa@example.com', 'm',33,
    'member03','iwasawa_kogan@example.com',    'm',30,
    'member04','takao_ayaka@example.com',      'f',40,
    'member06','noriko_tanaka@example.com',    'f',22
  ) AS (member_id,mail,gender,age)
)

SELECT receit_id, slip.member_id, age
FROM sales_slip_sp slip
JOIN master_members members
ON slip.member_id = members.member_id
WHERE slip.goods_id <= members.age
```
|receit_id                                  |member_id|age                      |
|-------------------------------------------|---------|-------------------------|
|4                                          |member01 |27                       |
|1                                          |member01 |27                       |
|7                                          |member02 |33                       |
|2                                          |member02 |33                       |
|3                                          |member03 |30                       |
|5                                          |member04 |40                       |


### WHERE TD_TIME_RANGE → JOIN（推奨）

```sql
SELECT goods_id, members.member_id, age
FROM sales_slip slip
LEFT OUTER JOIN
( 
  SELECT member_id, gender, age FROM master_members
) members
ON slip.member_id = members.member_id AND slip.member_id IS NOT NULL
WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
-- AND TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST') --NG
```
|goods_id                                   |member_id|age                      |
|-------------------------------------------|---------|-------------------------|
|548453                                     |920431   |47                       |
|537833                                     |1225349  |35                       |
|544411                                     |233096   |63                       |

```sql
** Time indexes:
  - tdce.sales_slip : [2010-12-31 15:00:00 UTC, 2011-12-31 14:59:59 UTC]
**
```

### WHERE TD_TIME_RANGE → ON → JOIN（推奨）

```sql
SELECT goods_id, members.member_id, age
FROM sales_slip slip
LEFT OUTER JOIN
( 
  SELECT member_id, gender, age FROM master_members
) members
ON slip.member_id = members.member_id 
AND 30 <= members.age
WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
```
|goods_id                                   |member_id|age                      |
|-------------------------------------------|---------|-------------------------|
|478234                                     |452218   |71                       |
|533750                                     |1328980  |36                       |
|471748                                     |96391    |57                       |


## JOINと集計を同時に

### グッズ名ごとの売上点数
```sql
WITH sales_slip_sp AS 
( SELECT receit_id,member_id,goods_id,gender,os FROM ( 
  VALUES 
(1,'member01',1,'m',    'iOS'),
(2,'member02',2,'m','android'),
(3,'member03',3,'m',    'iOS'),
(4,'member01',4,'m','android'),
(5,'member04',1,'f',    'iOS'),
(6,'member05',4,'f','android'),
(7,'member02',7,'m','android')
) AS t(receit_id,member_id,goods_id,gender,os) ),

master_members AS
( SELECT member_id,mail,gender,age FROM ( 
  VALUES
('member01','takayama_kazuhisa@example.com','m',27),
('member02','akiyama_hiromasa@example.com', 'm',33),
('member03','iwasawa_kogan@example.com',    'm',30),
('member04','takao_ayaka@example.com',      'f',40),
('member06','noriko_tanaka@example.com',    'f',22)
) AS t(member_id,mail,gender,age) ),

master_smartphones AS 
( SELECT goods_id,os,goods_name,price FROM (
  VALUES
(1,'iOS',    'Apple iPhone XS 256GB',117480),
(2,'android','ASUS ROG Phone 2 512GB',91080),
(3,'iOS',    'Apple iPhone 8 256GB',   78540),
(4,'android','HUAWEI Mate 20 Pro',    79200),
(5,'iOS',    'Apple iPhone 7 32GB',   37180),
(6,'android','SHARP AQUOS zero',      48180),
(8,'android','SHARP AQUOS sense3',    21800)
) AS t(goods_id,os,goods_name,price) )

SELECT goods_name, COUNT(1) AS cnt
FROM sales_slip_sp slip
LEFT OUTER JOIN
( 
  SELECT * FROM master_smartphones
) smartphones
ON slip.goods_id = smartphones.goods_id
GROUP BY goods_name
```　　　　　　　　　　　
|goods_name                                 |cnt|
|-------------------------------------------|---|
|HUAWEI Mate 20 Pro                         |2  |
|Apple iPhone XS 256GB                      |2  |
|ASUS ROG Phone 2 512GB                     |1  |
|NULL                                       |1  |
|Apple iPhone 8 256GB                       |1  |


### グッズ名ごとの購入者の平均年齢
```sql
WITH sales_slip_sp AS 
( SELECT receit_id,member_id,goods_id,gender,os FROM ( 
  VALUES 
(1,'member01',1,'m',    'iOS'),
(2,'member02',2,'m','android'),
(3,'member03',3,'m',    'iOS'),
(4,'member01',4,'m','android'),
(5,'member04',1,'f',    'iOS'),
(6,'member05',4,'f','android'),
(7,'member02',7,'m','android')
) AS t(receit_id,member_id,goods_id,gender,os) ),

master_members AS
( SELECT member_id,mail,gender,age FROM ( 
  VALUES
('member01','takayama_kazuhisa@example.com','m',27),
('member02','akiyama_hiromasa@example.com', 'm',33),
('member03','iwasawa_kogan@example.com',    'm',30),
('member04','takao_ayaka@example.com',      'f',40),
('member06','noriko_tanaka@example.com',    'f',22)
) AS t(member_id,mail,gender,age) ),

master_smartphones AS 
( SELECT goods_id,os,goods_name,price FROM (
  VALUES
(1,'iOS',    'Apple iPhone XS 256GB',117480),
(2,'android','ASUS ROG Phone 2 512GB',91080),
(3,'iOS',    'Apple iPhone 8 256GB',   78540),
(4,'android','HUAWEI Mate 20 Pro',    79200),
(5,'iOS',    'Apple iPhone 7 32GB',   37180),
(6,'android','SHARP AQUOS zero',      48180),
(8,'android','SHARP AQUOS sense3',    21800)
) AS t(goods_id,os,goods_name,price) )

SELECT goods_name, COUNT(1) AS cnt, AVG(age) AS avg_age
FROM sales_slip_sp slip
LEFT OUTER JOIN
( 
  SELECT member_id, gender, age FROM master_members 
) members
ON slip.member_id = members.member_id
LEFT OUTER JOIN
( 
  SELECT goods_id, goods_name, price FROM master_smartphones
) smartphones
ON slip.goods_id = smartphones.goods_id
GROUP BY goods_name
```
|goods_name                                 |cnt|avg_age|
|-------------------------------------------|---|-------|
|ASUS ROG Phone 2 512GB                     |1  |33.0   |
|Apple iPhone 8 256GB                       |1  |30.0   |
|HUAWEI Mate 20 Pro                         |2  |27.0   |
|Apple iPhone XS 256GB                      |2  |33.5   |
|NULL                                       |1  |33.0   |


### グッズ名ごとの購入者の男女別平均年齢
```sql
WITH sales_slip_sp AS 
( SELECT receit_id,member_id,goods_id,gender,os FROM ( 
  VALUES 
(1,'member01',1,'m',    'iOS'),
(2,'member02',2,'m','android'),
(3,'member03',3,'m',    'iOS'),
(4,'member01',4,'m','android'),
(5,'member04',1,'f',    'iOS'),
(6,'member05',4,'f','android'),
(7,'member02',7,'m','android')
) AS t(receit_id,member_id,goods_id,gender,os) ),

master_members AS
( SELECT member_id,mail,gender,age FROM ( 
  VALUES
('member01','takayama_kazuhisa@example.com','m',27),
('member02','akiyama_hiromasa@example.com', 'm',33),
('member03','iwasawa_kogan@example.com',    'm',30),
('member04','takao_ayaka@example.com',      'f',40),
('member06','noriko_tanaka@example.com',    'f',22)
) AS t(member_id,mail,gender,age) ),

master_smartphones AS 
( SELECT goods_id,os,goods_name,price FROM (
  VALUES
(1,'iOS',    'Apple iPhone XS 256GB',117480),
(2,'android','ASUS ROG Phone 2 512GB',91080),
(3,'iOS',    'Apple iPhone 8 256GB',   78540),
(4,'android','HUAWEI Mate 20 Pro',    79200),
(5,'iOS',    'Apple iPhone 7 32GB',   37180),
(6,'android','SHARP AQUOS zero',      48180),
(8,'android','SHARP AQUOS sense3',    21800)
) AS t(goods_id,os,goods_name,price) )

SELECT goods_name, 
  COUNT(IF(members.gender='m',1,NULL)) AS cnt_m,
  COUNT(IF(members.gender='f',1,NULL)) AS cnt_f,
  AVG(IF(members.gender='m',age,NULL)) AS avg_age_m,
  AVG(IF(members.gender='f',age,NULL)) AS avg_age_f
FROM sales_slip_sp slip
LEFT OUTER JOIN
( 
  SELECT member_id, gender, age FROM master_members 
) members
ON slip.member_id = members.member_id
LEFT OUTER JOIN
( 
  SELECT goods_id, goods_name, price FROM master_smartphones
) smartphones
ON slip.goods_id = smartphones.goods_id
GROUP BY goods_name
```
|goods_name                                 |cnt_m|cnt_f|avg_age_m|avg_age_f|
|-------------------------------------------|-----|-----|---------|---------|
|ASUS ROG Phone 2 512GB                     |1    |0    |33.0     |NULL     |
|Apple iPhone 8 256GB                       |1    |0    |30.0     |NULL     |
|Apple iPhone XS 256GB                      |1    |1    |27.0     |40.0     |
|NULL                                       |1    |0    |33.0     |NULL     |
|HUAWEI Mate 20 Pro                         |1    |0    |27.0     |NULL     |

### より多くのデータでの実行例

```sql
SELECT goods_id, 
  COUNT(IF(members.gender='男',1,NULL)) AS cnt_m,
  COUNT(IF(members.gender='女',1,NULL)) AS cnt_f,
  AVG(IF(members.gender='男',price*amount,NULL)) AS avg_sales_per_receit_m,
  AVG(IF(members.gender='女',price*amount,NULL)) AS avg_sales_per_receit_f,
  AVG(IF(members.gender='男',age,NULL)) AS avg_age_m,
  AVG(IF(members.gender='女',age,NULL)) AS avg_age_f
FROM sales_slip slip
LEFT OUTER JOIN
( 
  SELECT member_id, gender, age FROM master_members
) members
ON slip.member_id = members.member_id
WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
GROUP BY goods_id
ORDER BY cnt_m+cnt_f DESC
```
|goods_id                                   |cnt_m|cnt_f|avg_sales_per_receit_m|avg_sales_per_receit_f|avg_age_m         |avg_age_f         |
|-------------------------------------------|-----|-----|----------------------|----------------------|------------------|------------------|
|547453                                     |1123 |1090 |154.22083704363314    |153.19266055045873    |50.454140694568125|50.10825688073395 |
|541456                                     |449  |394  |932.0445434298441     |910.4568527918782     |52.55902004454343 |50.621827411167516|
|109601                                     |259  |461  |301.1583011583012     |371.5835140997831     |45.84169884169884 |49.22776572668113 |


