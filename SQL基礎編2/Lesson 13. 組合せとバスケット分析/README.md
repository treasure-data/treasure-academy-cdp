# Lesson 13. 組合せとバスケット分析


## Numbers：2つ数値の組合せ



### 1. 2つの数値の組合せをSQLですべて求める


```sql
FROM table1 n1
CROSS JOIN table2 n2
```



```sql
WITH numbers AS
( SELECT number FROM ( VALUES 1,2,3,4,5,6 ) AS t(number) )

SELECT n1.number, n2.number
FROM numbers n1, numbers n2
ORDER BY n1.number, n2.number
```
|number|number|
|------|------|
|1     |1     |
|1     |2     |
|...   |      |
|6     |5     |
|6     |6     |




### 2. 2つの数値の組合せで，同じ数値の組合せは避ける



```sql
WITH numbers AS 
( SELECT number FROM ( VALUES 1,2,3,4,5,6 ) AS t(number) )

SELECT n1.number, n2.number
FROM numbers n1, numbers n2
WHERE n1.number <> n2.number
ORDER BY n1.number, n2.number
```
|number|number|
|------|------|
|1     |2     |
|1     |3     |
|...   |      |
|6     |4     |
|6     |5     |




### ※重要：「CROSS JOIN+WHERE」と「JOIN+ON」の違い

```sql
WITH numbers AS 
( SELECT number FROM ( VALUES 1,2,3,4,5,6 ) AS t(number) )

SELECT n1.number, n2.number
FROM numbers n1
JOIN numbers n2
ON n1.number <> n2.number
ORDER BY n1.number, n2.number
```



```sql
-- Hive
WITH numbers AS 
( SELECT STACK(6,1,2,3,4,5,6) AS number  )

SELECT n1.number, n2.number
FROM numbers n1
JOIN numbers n2
ON n1.number <> n2.number
ORDER BY n1.number, n2.number
```


```sql
SemanticException : Both left and right aliases encountered in JOIN 'number'
```


### 3. 2つの数値の組合せで順序を気にしない


```sql
WITH numbers AS 
( SELECT number FROM ( VALUES 1,2,3,4,5,6 ) AS t(number) )

SELECT n1.number, n2.number
FROM numbers n1, numbers n2
WHERE n1.number < n2.number
ORDER BY n1.number, n2.number
```
```sql
WITH numbers AS 
( SELECT number FROM ( VALUES 1,2,3,4,5,6 ) AS t(number) )

SELECT n1.number, n2.number
FROM numbers n1 JOIN numbers n2
ON n1.number < n2.number
ORDER BY n1.number, n2.number
```

|number|number|
|------|------|
|1     |2     |
|1     |3     |
|...   |      |
|4     |5     |
|4     |6     |
|5     |6     |



## Matching：食器のマッチング


|id |type|
|---|----|
|d1 |dish|
|d2 |dish|
|c1 |cup |
|c2 |cup |
|c3 |cup |



```sql
WITH tableware AS 
( SELECT id, type FROM ( 
  VALUES 
('d1','dish'),('d2','dish'),('c1','cup'),('c2','cup'),('c3','cup')
) AS t(id,type) )

SELECT n1.id, n2.id, n1.id || ' & ' || n2.id
FROM tableware n1, tableware n2
WHERE n1.id < n2.id
ORDER BY n1.id, n2.id
```
|id |id |_col2  |
|---|---|-------|
|c1 |c2 |c1 & c2|
|c1 |c3 |c1 & c3|
|c1 |d1 |c1 & d1|
|c1 |d2 |c1 & d2|
|c2 |c3 |c2 & c3|
|c2 |d1 |c2 & d1|
|c2 |d2 |c2 & d2|
|c3 |d1 |c3 & d1|
|c3 |d2 |c3 & d2|
|d1 |d2 |d1 & d2|




## 4. 可能な皿とカップのマッチングを考える


```sql
WITH tableware AS 
( SELECT id, type FROM ( 
  VALUES 
('d1','dish'),('d2','dish'),('c1','cup'),('c2','cup'),('c3','cup')
) AS t(id,type) )

SELECT n1.id, n2.id, n1.id || ' & ' || n2.id
FROM tableware n1, tableware n2
WHERE n1.id < n2.id
AND n1.type <> n2.type
ORDER BY n1.id, n2.id
```
|id |id |_col2  |
|---|---|-------|
|c1 |d1 |c1 & d1|
|c1 |d2 |c1 & d2|
|c2 |d1 |c2 & d1|
|c2 |d2 |c2 & d2|
|c3 |d1 |c3 & d1|
|c3 |d2 |c3 & d2|


## トランプの組合せ


### 5. 同じ絵柄のカードであるが，異なる数字の組合せを考える

```sql
WITH trump AS 
( SELECT number, symbol FROM ( 
  VALUES 
('♦',1),('♦',2),('♦',3),('♦',4),('♦',5),('♦',6),('♦',7),('♦',8),('♦',9),('♦',10),('♦',11),('♦',12),('♦',13),
('♤',1),('♤',2),('♤',3),('♤',4),('♤',5),('♤',6),('♤',7),('♤',8),('♤',9),('♤',10),('♤',11),('♤',12),('♤',13),
('♣',1),('♣',2),('♣',3),('♣',4),('♣',5),('♣',6),('♣',7),('♣',8),('♣',9),('♣',10),('♣',11),('♣',12),('♣',13),
('♡',1),('♡',2),('♡',3),('♡',4),('♡',5),('♡',6),('♡',7),('♡',8),('♡',9),('♡',10),('♡',11),('♡',12),('♡',13)
) AS t(symbol,number) )

SELECT n1.symbol, n1.number, n2.number, COUNT(1) AS cnt
FROM trump n1, trump n2
WHERE n1.symbol = n2.symbol
AND n1.number < n2.number
GROUP BY n1.symbol, n1.number, n2.number
ORDER BY cnt DESC, n1.symbol, n1.number, n2.number
```
|symbol|number|number |cnt|
|------|------|-------|---|
|♡     |1     |2      |1  |
|♡     |1     |3      |1  |
|...   |      |       |   |
|♦     |11    |13     |1  |
|♦     |12    |13     |1  |




### 6. 絵柄を区別せず，数字の組合せの登場回数を考える


```sql
WITH trump AS 
( SELECT number, symbol FROM ( 
  VALUES 
('♦',1),('♦',2),('♦',3),('♦',4),('♦',5),('♦',6),('♦',7),('♦',8),('♦',9),('♦',10),('♦',11),('♦',12),('♦',13),
('♤',1),('♤',2),('♤',3),('♤',4),('♤',5),('♤',6),('♤',7),('♤',8),('♤',9),('♤',10),('♤',11),('♤',12),('♤',13),
('♣',1),('♣',2),('♣',3),('♣',4),('♣',5),('♣',6),('♣',7),('♣',8),('♣',9),('♣',10),('♣',11),('♣',12),('♣',13),
('♡',1),('♡',2),('♡',3),('♡',4),('♡',5),('♡',6),('♡',7),('♡',8),('♡',9),('♡',10),('♡',11),('♡',12),('♡',13)
) AS t(symbol,number) )

SELECT number1, number2, COUNT(1) AS cnt
FROM
(
  SELECT n1.symbol AS symbol, n1.number AS number1, n2.number AS number2
  FROM trump n1, trump n2
  WHERE n1.symbol = n2.symbol
  AND n1.number < n2.number
) tmp
GROUP BY number1, number2
ORDER BY cnt DESC, number1, number2
```
|number1|number2|cnt    |
|-------|-------|-------|
|1      |2      |4      |
|1      |3      |4      |
|...    |       |       |
|11     |13     |4      |
|12     |13     |4      |



## バスケット分析



### 共起回数 | A ∩ B | （一定期間内での共起）


```sql
WITH gm_stat AS
(
  SELECT member_id, goods_id
  FROM sales_slip
  WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
  GROUP BY member_id, goods_id
)

SELECT g1.goods_id AS goods_id1, g2.goods_id AS goods_id2, COUNT(1) AS cnt
FROM gm_stat g1, gm_stat g2
WHERE g1.member_id=g2.member_id
AND g1.goods_id<g2.goods_id
GROUP BY g1.goods_id, g2.goods_id
ORDER BY cnt DESC
LIMIT 10
```
|goods_id1|goods_id2|cnt    |
|---------|---------|-------|
|541456   |547453   |158    |
|546452   |547453   |153    |
|531458   |547453   |139    |



```sql
WITH gm_stat AS
(
  SELECT member_id, goods_id
  FROM sales_slip
  WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
  GROUP BY member_id, goods_id
)

SELECT g1.goods_id AS goods_id1, g2.goods_id AS goods_id2, COUNT(1) AS cnt
FROM gm_stat g1 JOIN gm_stat g2
ON g1.member_id=g2.member_id
AND g1.goods_id<g2.goods_id
GROUP BY g1.goods_id, g2.goods_id
ORDER BY cnt DESC
LIMIT 10
```


```sql
WITH gm_stat AS
(
  SELECT member_id, goods_id
  FROM sales_slip
  WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
  GROUP BY member_id, goods_id
),
goods_stat AS
(
  SELECT goods_id, COUNT(1) AS cnt
  FROM gm_stat
  GROUP BY goods_id
),
stat AS
(
  SELECT SUM(cnt) AS total_cnt
  FROM goods_stat
),
combi AS
(
  SELECT g1.goods_id AS goods_id1, g2.goods_id AS goods_id2, COUNT(1) AS combi_cnt
  FROM gm_stat g1, gm_stat g2
  WHERE g1.member_id = g2.member_id
  AND g1.goods_id<g2.goods_id
  GROUP BY g1.goods_id, g2.goods_id
)

SELECT goods_id1, goods_id2, g1.cnt AS cnt1, g2.cnt AS cnt2, combi_cnt, total_cnt
FROM combi, goods_stat g1, goods_stat g2, stat
WHERE combi.goods_id1=g1.goods_id AND combi.goods_id2=g2.goods_id
ORDER BY combi_cnt DESC
LIMIT 10
```
|goods_id1|goods_id2|cnt1   |cnt2|combi_cnt|total_cnt|
|---------|---------|-------|----|---------|---------|
|541456   |547453   |413    |1700|158      |445222   |
|546452   |547453   |259    |1700|153      |445222   |
|531458   |547453   |394    |1700|139      |445222   |



### 共起回数 | A ∩ B | （同日購入を共起とする）

```sql
WITH goods_stat AS
(
  SELECT goods_id, COUNT(1) AS cnt
  FROM sales_slip
  WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
  GROUP BY goods_id
),
orders AS
(
  SELECT DENSE_RANK()OVER(PARTITION BY member_id ORDER BY d) AS shopping_order, goods_id, member_id
  FROM
  (
    SELECT goods_id, member_id, TD_TIME_FORMAT(time, 'yyyy-MM-dd', 'JST') AS d
    FROM sales_slip
    WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
    GROUP BY goods_id, member_id, TD_TIME_FORMAT(time, 'yyyy-MM-dd', 'JST')
  )
),
stat AS
(
  SELECT SUM(cnt) AS total_cnt
  FROM
  (
    SELECT member_id, MAX(shopping_order) AS cnt
    FROM orders
    GROUP BY member_id
  )
),
combi AS
(
  SELECT 
    o1.goods_id AS goods_id1, o2.goods_id AS goods_id2, COUNT(1) AS combi_cnt
  FROM orders o1, orders o2
  WHERE  o1.member_id = o2.member_id 
  AND o1.shopping_order = o2.shopping_order 
  AND o1.goods_id < o2.goods_id
  GROUP BY o1.goods_id, o2.goods_id
)

SELECT goods_id1, goods_id2, g1.cnt AS cnt1, g2.cnt AS cnt2, combi_cnt, total_cnt
FROM combi, goods_stat g1, goods_stat g2, stat
WHERE combi.goods_id1=g1.goods_id AND combi.goods_id2=g2.goods_id
ORDER BY combi_cnt DESC
LIMIT 10
```
|goods_id1|goods_id2|cnt1   |cnt2|combi_cnt|total_cnt|
|---------|---------|-------|----|---------|---------|
|546452   |547453   |327    |2213|110      |202354   |
|538660   |540882   |371    |216 |87       |202354   |
|545690   |547453   |247    |2213|84       |202354   |


### 遷移回数 | A → B |，| B → A |

```sql
WITH goods_stat AS
(
  SELECT goods_id, COUNT(1) AS cnt
  FROM sales_slip
  WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
  GROUP BY goods_id
),
orders AS
(
  SELECT DENSE_RANK()OVER(PARTITION BY member_id ORDER BY d) AS shopping_order, goods_id, member_id
  FROM
  (
    SELECT goods_id, member_id, TD_TIME_FORMAT(time, 'yyyy-MM-dd', 'JST') AS d
    FROM sales_slip
    WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
    GROUP BY goods_id, member_id, TD_TIME_FORMAT(time, 'yyyy-MM-dd', 'JST')
  )
),
stat AS
(
  SELECT SUM(cnt) AS total_cnt
  FROM
  (
    SELECT member_id, MAX(shopping_order) AS cnt
    FROM orders
    GROUP BY member_id
  )
),
trans AS
(
  SELECT 
    o1.goods_id AS goods_id1, o2.goods_id AS goods_id2, COUNT(1) AS trans_cnt
  FROM orders o1, orders o2
  WHERE o1.member_id = o2.member_id 

  AND o1.shopping_order+1 = o2.shopping_order
  GROUP BY o1.goods_id, o2.goods_id
)

SELECT goods_id1, goods_id2, g1.cnt AS cnt1, g2.cnt AS cnt2, trans_cnt, total_cnt
FROM trans, goods_stat g1, goods_stat g2, stat
WHERE trans.goods_id1=g1.goods_id AND trans.goods_id2=g2.goods_id
ORDER BY trans_cnt DESC
LIMIT 10
```
|goods_id1|goods_id2|cnt1   |cnt2|trans_cnt|total_cnt|
|---------|---------|-------|----|---------|---------|
|547453   |547453   |2213   |2213|238      |202354   |
|109601   |109601   |540470 |540470|199      |202354   |
|543766   |547453   |356    |2213|51       |202354   |



```sql
WITH goods_stat AS
(
  SELECT goods_id, COUNT(1) AS cnt
  FROM sales_slip
  WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
  GROUP BY goods_id
),
orders AS
(
  SELECT goods_id, member_id, MIN(time) AS min_time, MAX(time) AS max_time
  FROM sales_slip
  WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST') 
  GROUP BY goods_id, member_id
),
trans AS 
(
  SELECT 
    o1.goods_id AS goods_id1, o2.goods_id AS goods_id2, COUNT(1) AS trans_cnt
  FROM orders o1, orders o2
  WHERE o1.member_id = o2.member_id 
  AND ( o1.min_time < o2.min_time OR o2.min_time < o1.max_time )
  AND o1.goods_id <> o2.goods_id
  GROUP BY o1.goods_id, o2.goods_id
)

SELECT goods_id1, goods_id2, g1.cnt AS cnt1, g2.cnt AS cnt2, trans_cnt
FROM trans, goods_stat g1, goods_stat g2
WHERE trans.goods_id1=g1.goods_id AND trans.goods_id2=g2.goods_id
ORDER BY trans_cnt DESC
LIMIT 10
```
|goods_id1|goods_id2|cnt1   |cnt2|trans_cnt|
|---------|---------|-------|----|---------|
|547453   |541456   |2213   |843 |142      |
|541456   |547453   |843    |2213|140      |
|531458   |547453   |658    |2213|139      |



### 共起係数

```sql
WITH gm_stat AS
(
  SELECT member_id, goods_id
  FROM sales_slip
  WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
  GROUP BY member_id, goods_id
),
goods_stat AS
(
  SELECT goods_id, COUNT(1) AS cnt
  FROM gm_stat
  GROUP BY goods_id
),
stat AS
(
  SELECT SUM(cnt) AS total_cnt
  FROM goods_stat
),
combi AS
(
  SELECT g1.goods_id AS goods_id1, g2.goods_id AS goods_id2, COUNT(1) AS combi_cnt
  FROM gm_stat g1, gm_stat g2
  WHERE g1.member_id = g2.member_id
  GROUP BY g1.goods_id, g2.goods_id
  HAVING g1.goods_id<g2.goods_id
)

SELECT goods_id1, goods_id2, g1.cnt AS cnt1, g2.cnt AS cnt2, combi_cnt, total_cnt,
  1.0*combi_cnt/(g1.cnt+g2.cnt-combi_cnt)       AS jaccard_coeff,
  1.0*combi_cnt/IF(g1.cnt<g2.cnt,g1.cnt,g2.cnt) AS simpson_coeff,
  1.0*combi_cnt/SQRT(g1.cnt*g2.cnt)             AS cos_coeff,
  1.0*combi_cnt/(g1.cnt+g2.cnt)                 AS dice_coeff
FROM combi, goods_stat g1, goods_stat g2, stat
WHERE combi.goods_id1=g1.goods_id AND combi.goods_id2=g2.goods_id
ORDER BY combi_cnt DESC
LIMIT 10
```
|goods_id1|goods_id2|cnt1   |cnt2|combi_cnt|total_cnt|jaccard_coeff      |simpson_coeff      |cos_coeff          |dice_coeff         |
|---------|---------|-------|----|---------|---------|-------------------|-------------------|-------------------|-------------------|
|541456   |547453   |413    |1700|158      |445222   |0.08081841432225063|0.38256658595641646|0.1885634868608601 |0.07477520113582584|
|546452   |547453   |259    |1700|153      |445222   |0.08471760797342193|0.5907335907335908 |0.23057758600094497|0.0781010719754977 |
|531458   |547453   |394    |1700|139      |445222   |0.0710997442455243 |0.35279187817258884|0.16984087893220706|0.06638013371537727|



#### Jaccard係数：| A ∩ B | / | A ∪ B |

#### Simpson係数：| A ∩ B | / MIN ( | A |, | B | )

#### Cosine係数：| A ∩ B | / SQRT ( | A | * | B | )

#### Dice係数：2 * | A ∩ B | / ( | A | + | B | )


### レコメンデーション係数

```sql
WITH gm_stat AS
(
  SELECT member_id, goods_id
  FROM sales_slip
  WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
  GROUP BY member_id, goods_id
),
goods_stat AS
(
  SELECT goods_id, COUNT(1) AS cnt
  FROM gm_stat
  GROUP BY goods_id
),
stat AS
(
  SELECT SUM(cnt) AS total_cnt
  FROM goods_stat
),
combi AS
(
  SELECT g1.goods_id AS goods_id1, g2.goods_id AS goods_id2, COUNT(1) AS combi_cnt
  FROM gm_stat g1, gm_stat g2
  WHERE g1.member_id = g2.member_id
  GROUP BY g1.goods_id, g2.goods_id
  HAVING g1.goods_id<>g2.goods_id
)

SELECT goods_id1, goods_id2, g1.cnt AS cnt1, g2.cnt AS cnt2, combi_cnt, total_cnt,
  1.0*combi_cnt/g1.cnt AS confidence,
  1.0*combi_cnt/total_cnt AS support,
  (1.0*combi_cnt/g1.cnt) / (1.0*g2.cnt/total_cnt) AS lift
FROM combi, goods_stat g1, goods_stat g2, stat
WHERE combi.goods_id1=g1.goods_id AND combi.goods_id2=g2.goods_id
ORDER BY combi_cnt DESC
LIMIT 10
```
|goods_id1|goods_id2|cnt1   |cnt2|combi_cnt|total_cnt|confidence         |support            |lift               |
|---------|---------|-------|----|---------|---------|-------------------|-------------------|-------------------|
|547453   |541456   |1700   |413 |158      |445222   |0.09294117647058824|0.00035487913894641324|100.1923885486398  |
|541456   |547453   |413    |1700|158      |445222   |0.38256658595641646|0.00035487913894641324|100.1923885486398  |
|546452   |547453   |259    |1700|153      |445222   |0.5907335907335908 |0.00034364878644810906|154.71034749034752 |


#### Confidence係数：| A ∩ B | / | A |


#### Support係数：| A ∩ B | / | Ω |



#### Lift係数：( | A ∩ B | / | A | ) / ( | B | / | Ω | )

