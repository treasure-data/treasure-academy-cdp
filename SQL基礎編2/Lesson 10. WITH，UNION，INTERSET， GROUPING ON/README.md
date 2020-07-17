# Lesson 10. WITH，UNION，INTERSET， GROUPING ON

## WITH節



```sql
WITH numbers AS
( SELECT number FROM ( VALUES 1,2,3,4,5,6 ) AS t(number) )

SELECT number FROM numbers
```
|number                                     |
|-------------------------------------------|
|1                                          |
|2                                          |
|3                                          |
|4                                          |
|5                                          |
|6                                          |



```sql
WITH numbers AS
( SELECT number FROM ( VALUES 1,2,3,4,5,6 ) AS t(number) ),
alphabets AS
( SELECT number,alphabet FROM ( VALUES (1,'a'),(2,'b'),(3,'c'),(4,'d'),(5,'e'),(6,'f') ) AS t(number,alphabet) )

SELECT numbers.number, alphabet 
FROM numbers, alphabets
WHERE numbers.number = alphabets.number
```
|number                                     |alphabet|
|-------------------------------------------|--------|
|1                                          |a       |
|4                                          |d       |
|2                                          |b       |
|3                                          |c       |
|5                                          |e       |
|6                                          |f       |



```sql
WITH numbers AS
( SELECT number FROM ( VALUES 1,2,3,4,5,6 ) AS t(number) ),
stats AS
( SELECT MAX(number) AS max_num FROM numbers )

SELECT number, 1.0*number/max_num AS ratio_from_max
FROM numbers, stats
```
|number                                     |ratio_from_max|
|-------------------------------------------|--------------|
|1                                          |0.16666666666666666|
|2                                          |0.3333333333333333|
|3                                          |0.5           |
|4                                          |0.6666666666666666|
|5                                          |0.8333333333333334|
|6                                          |1.0           |




```sql
WITH stats AS (
  SELECT MAX_BY(m,sales) AS max_m, MAX(sales) AS max_sales, 
    MIN_BY(m,sales) AS min_m, MIN(sales) AS min_sales
  FROM
  (
    SELECT 
      TD_TIME_FORMAT(time,'yyyy-MM-01','JST') AS m, SUM(price*amount) AS sales
    FROM  sales_slip
    WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
    GROUP BY TD_TIME_FORMAT(time,'yyyy-MM-01','JST')
  )
)

SELECT 
  TD_TIME_FORMAT(time,'yyyy-MM-01','JST') AS m, 
  SUM(price*amount) AS sales, 
  1.0*SUM(price*amount)/stats.max_sales AS ratio_from_max
FROM  sales_slip, stats
WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
GROUP BY TD_TIME_FORMAT(time,'yyyy-MM-01','JST'), stats.max_sales
ORDER BY m
```
|m                                          |sales|ratio_from_max    |
|-------------------------------------------|-----|------------------|
|2011-01-01                                 |139568438|0.6463141781486311|
|2011-02-01                                 |119880374|0.5551425989159564|
|2011-03-01                                 |109971888|0.5092583354137223|


## テーブル同士を結合する節


### UNION ALL

```sql
SELECT number1 FROM ( VALUES 1,2,3 ) AS t(number1)
UNION ALL
SELECT number2 FROM ( VALUES 1,3,5 ) AS t(number2)
```
|number1                                    |
|-------------------------------------------|
|1                                          |
|2                                          |
|3                                          |
|1                                          |
|3                                          |
|5                                          |



```sql
SELECT number FROM ( VALUES 1,2,3 ) AS t(number)
UNION ALL
SELECT alphabet FROM ( VALUES 'a','b','c' ) AS t(alphabet)
```
```sql
column 1 in UNION query has incompatible types: integer, varchar(1)
```

```sql
SELECT number FROM ( VALUES 1,2,3 ) AS t(number)
UNION ALL
SELECT number, alphabet FROM ( VALUES (1,'a'),(2,'b'),(3,'c') ) AS t(number, alphabet)
```

```sql
UNION query has different number of fields: 1, 2
```



```sql
SELECT number, alphabet FROM ( VALUES (1,'a'),(2,'b'),(3,'c') ) AS t(number, alphabet)
UNION ALL
SELECT alphabet, number FROM ( VALUES (1,'a'),(2,'b'),(3,'c') ) AS t(number, alphabet)
```

```sql
column 1 in UNION query has incompatible types: integer, varchar(1)
```


```sql
SELECT number, alphabet FROM ( VALUES (1,'a'),(2,'b'),(3,'c') ) AS t(number, alphabet)
UNION ALL
SELECT number, alphabet FROM ( VALUES (1,'a'),(3,'c'),(5,'d') ) AS t(number, alphabet)
```
|number                                     |alphabet|
|-------------------------------------------|--------|
|1                                          |a       |
|2                                          |b       |
|3                                          |c       |
|1                                          |a       |
|3                                          |c       |
|5                                          |d       |


### UNION



```sql
SELECT number1 FROM ( VALUES 1,2,3 ) AS t(number1)
UNION
SELECT number2 FROM ( VALUES 1,3,5 ) AS t(number2)
```
|number1                                    |
|-------------------------------------------|
|5                                          |
|1                                          |
|3                                          |
|2                                          |




```sql
SELECT number, alphabet FROM ( VALUES (1,'a'),(2,'b'),(3,'c') ) AS t(number, alphabet)
UNION
SELECT number, alphabet FROM ( VALUES (1,'a'),(3,'d'),(5,'e') ) AS t(number, alphabet)
```
|number                                     |alphabet|
|-------------------------------------------|--------|
|2                                          |b       |
|3                                          |c       |
|3                                          |d       |
|5                                          |e       |
|1                                          |a       |


### INTERSECT



```sql
SELECT number1 FROM ( VALUES 1,2,3 ) AS t(number1)
INTERSECT
SELECT number2 FROM ( VALUES 1,3,5 ) AS t(number2)
```
|number1                                    |
|-------------------------------------------|
|1                                          |
|3                                          |


```sql
SELECT number, alphabet FROM ( VALUES (1,'a'),(2,'b'),(3,'c') ) AS t(number, alphabet)
INTERSECT
SELECT number, alphabet FROM ( VALUES (1,'a'),(3,'d'),(5,'e') ) AS t(number, alphabet)
```
|number                                     |alphabet|
|-------------------------------------------|--------|
|1                                          |a       |


### EXCEPT


```sql
SELECT number1 FROM ( VALUES 1,2,3 ) AS t(number1)
EXCEPT
SELECT number2 FROM ( VALUES 1,3,5 ) AS t(number2)
```
|number1                                    |
|-------------------------------------------|
|2                                          |


```sql
SELECT number2 FROM ( VALUES 1,3,5 ) AS t(number2)
EXCEPT
SELECT number1 FROM ( VALUES 1,2,3 ) AS t(number1)
```
|number2                                    |
|-------------------------------------------|
|5                                          |


```sql
SELECT number, alphabet FROM ( VALUES (1,'a'),(2,'b'),(3,'c') ) AS t(number, alphabet)
EXCEPT
SELECT number, alphabet FROM ( VALUES (1,'a'),(3,'d'),(5,'e') ) AS t(number, alphabet)
```
|number                                     |alphabet|
|-------------------------------------------|--------|
|2                                          |b       |
|3                                          |c       |


```sql
SELECT number, alphabet FROM ( VALUES (1,'a'),(3,'d'),(5,'e') ) AS t(number, alphabet)
EXCEPT
SELECT number, alphabet FROM ( VALUES (1,'a'),(2,'b'),(3,'c') ) AS t(number, alphabet)
```
|number                                     |alphabet|
|-------------------------------------------|--------|
|5                                          |e       |
|3                                          |d       |


## GROUPING SETS，CUBE，ROLLUP



### GROUPING SETS



```sql
SELECT category, sub_category, goods_id, SUM(price*amount) AS sales
FROM sales_slip
WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
GROUP BY GROUPING SETS(
  (category),
  (category,sub_category),
  (category,sub_category,goods_id)
)
```
|category                                   |sub_category|goods_id|sales   |
|-------------------------------------------|------------|--------|--------|
|Automotive and Industrial                  |Safety      |542003  |32062   |
|Electronics and Computers                  |Wearable Technology|NULL        |16601999|
|Electronics and Computers                  |Home Audio and Theater|540139  |72390   |




```sql
SELECT category, NULL AS sub_category, NULL AS goods_id, SUM(price*amount) AS sales
FROM sales_slip
WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
GROUP BY category

UNION ALL
SELECT category, sub_category, NULL AS goods_id, SUM(price*amount) AS sales
FROM sales_slip
WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
GROUP BY category, sub_category
  
UNION ALL
SELECT category, sub_category, goods_id, SUM(price*amount) AS sales
FROM sales_slip
WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
GROUP BY category, sub_category, goods_id
```
|category                                   |sub_category|goods_id|sales   |
|-------------------------------------------|------------|--------|--------|
|Electronics and Computers                  |Car Electronics and GPS|494460  |25551   |
|Books and Audible                          |Textbooks   |494913  |38136   |
|Sports and Outdoors                        |Golf        |496492  |57600   |




```sql
SELECT category, sub_category, goods_id, SUM(price*amount) AS sales
FROM sales_slip
WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
GROUP BY GROUPING SETS(
  (),
  (category),
  (category,sub_category),
  (category,sub_category,goods_id)
)
```
|category                                   |sub_category|goods_id|sales   |
|-------------------------------------------|------------|--------|--------|
|Electronics and Computers                  |Musical Instruments|530651  |18000   |
|Sports and Outdoors                        |Leisure Sports and Game Room|NULL        |12641876|
|Home and Garden and Tools                  |Home Automation|NULL        |14593758|




```sql
SELECT TD_TIME_FORMAT(time,'yyyy-MM-01','JST'),category, sub_category, goods_id, SUM(price*amount) AS sales
FROM sales_slip
WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
GROUP BY GROUPING SETS(
  (TD_TIME_FORMAT(time,'yyyy-MM-01','JST'),category),
  (TD_TIME_FORMAT(time,'yyyy-MM-01','JST'),category,sub_category),
  (TD_TIME_FORMAT(time,'yyyy-MM-01','JST'),category,sub_category,goods_id)
)
```
```sql
mismatched input '('. Expecting: ')', ',', '.'
```



```sql
SELECT m, category, sub_category, goods_id, SUM(sales) AS sales
FROM 
(
  SELECT TD_TIME_FORMAT(time,'yyyy-MM-01','JST') AS m,category, sub_category, goods_id, price*amount AS sales
  FROM sales_slip
  WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
)
GROUP BY GROUPING SETS(
  (m,category),
  (m,category,sub_category),
  (m,category,sub_category,goods_id)
)
```
|m                                          |category|sub_category|goods_id|sales  |
|-------------------------------------------|--------|------------|--------|-------|
|2011-10-01                                 |Movies and Music and Games|Musical Instruments|532989  |25755  |
|2011-10-01                                 |Automotive and Industrial|Automotive Tools and Equipment|531186  |25840  |
|2011-10-01                                 |Home and Garden and Tools|Hardware    |NULL        |1870255|



```sql
SELECT category, sub_category, goods_id, SUM(price*amount) AS sales
FROM sales_slip
WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
GROUP BY GROUPING SETS(
  (category),
  (category,sub_category),
  (goods_id)
)
```
|category                                   |sub_category|goods_id|sales   |
|-------------------------------------------|------------|--------|--------|
|NULL                                       |NULL        |526973  |495282  |
|NULL                                       |NULL        |526422  |53074   |
|NULL                                       |NULL        |524133  |151480  |




```sql
SELECT category, sub_category, goods_id, SUM(price*amount) AS sales,
  GROUPING(category,sub_category,goods_id) AS group_id
FROM sales_slip
WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
GROUP BY GROUPING SETS(
  (category),
  (category,sub_category),
  (category,sub_category,goods_id)
)
```
|category                                   |sub_category|goods_id|sales   |group_id|
|-------------------------------------------|------------|--------|--------|--------|
|Clothing and Shoes and Jewelry             |Boys        |540286  |13328   |0       |
|Clothing and Shoes and Jewelry             |Women       |539249  |13328   |0       |
|Clothing and Shoes and Jewelry             |Boys        |NULL    |15730594|1       |




### ROLLUP

```sql
SELECT category, sub_category, SUM(price*amount) AS sales,
  GROUPING(category,sub_category) AS group_id
FROM sales_slip
WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
GROUP BY ROLLUP(category,sub_category)
ORDER BY group_id, category, sub_category
```
|category                                   |sub_category|goods_id|sales   |group_id|
|-------------------------------------------|------------|--------|--------|--------|
|Automotive and Industrial                  |Lab and Scientific|538429  |14940   |0       |
|Movies and Music and Games                 |Digital Games|538349  |155690  |0       |
|Electronics and Computers                  |NULL            |NULL        |290630163|3       |




```sql
SELECT category, sub_category, SUM(price*amount) AS sales,
  GROUPING(category,sub_category) AS group_id
FROM sales_slip
WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
GROUP BY GROUPING SETS(
  (category,sub_category),
  (category),
  ()
)
ORDER BY group_id, category, sub_category
```
|category                                   |sub_category|sales |group_id|
|-------------------------------------------|------------|------|--------|
|Automotive and Industrial                  |Automotive Parts and Accessories|15404860|0       |
|Automotive and Industrial                  |Automotive Tools and Equipment|15047016|0       |
|Automotive and Industrial                  |Car/Vehicle Electronics and GPS|14112998|0       |



```sql
SELECT category, sub_category, goods_id, SUM(price*amount) AS sales,
  GROUPING(category,sub_category) AS group_id
FROM sales_slip
WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
GROUP BY ROLLUP(category,sub_category,goods_id)
ORDER BY group_id, category, sub_category, goods_id
```
|category                                   |sub_category|goods_id|sales   |group_id|
|-------------------------------------------|------------|--------|--------|--------|
|Automotive and Industrial                  |Automotive Parts and Accessories|466889  |24572   |0       |
|Automotive and Industrial                  |Automotive Parts and Accessories|466983  |3800    |0       |
|Automotive and Industrial                  |Automotive Parts and Accessories|467077  |3410    |0       |




```sql
WITH groups1
AS
( SELECT name,id
  FROM (
  VALUES 
    ('1_category',    POWER(2,2)),
    ('2_sub_category',POWER(2,1)),
    ('3_goods_id',    POWER(2,0)),
    ('1_NULL',                 0),
    ('2_NULL',                 0),
    ('3_NULL',                 0)
  ) AS t(name,id)
)

SELECT groups1.name AS name1, groups2.name AS name2, groups3.name AS name3, 
  CAST( (4+2+1-groups1.id-groups2.id-groups3.id) AS INTEGER ) AS group_id
FROM groups1
JOIN
( SELECT name, id FROM groups1 ) AS groups2
ON groups1.name <> groups2.name 
AND SUBSTR(groups1.name,1,1) ='1' AND SUBSTR(groups2.name,1,1) ='2'
JOIN
( SELECT name, id FROM groups1 ) AS groups3
ON groups2.name <> groups3.name AND groups1.name <> groups3.name
AND SUBSTR(groups3.name,1,1) ='3'
WHERE (4+2+1-groups1.id-groups2.id-groups3.id) IN (0,1,3,7)
ORDER BY group_id
```
|name1                                      |name2|name3 |group_id|
|-------------------------------------------|-----|------|--------|
|1_category                                 |2_sub_category|3_goods_id|0       |
|1_category                                 |2_sub_category|3_NULL|1       |
|1_category                                 |2_NULL|3_NULL|3       |
|1_NULL                                     |2_NULL|3_NULL|7       |



```sql
SELECT category, sub_category, goods_id, SUM(price*amount) AS sales,
  GROUPING(category,sub_category) AS group_id
FROM sales_slip
WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
GROUP BY GROUPING SETS(
  (category,sub_category,goods_id),
  (category,sub_category),
  (category),
  ()
)
ORDER BY group_id, category, sub_category, goods_id
```
|category                                   |sub_category|goods_id|sales   |group_id|
|-------------------------------------------|------------|--------|--------|--------|
|Automotive and Industrial                  |Automotive Parts and Accessories|466889  |24572   |0       |
|Automotive and Industrial                  |Automotive Parts and Accessories|466983  |3800    |0       |
|Automotive and Industrial                  |Automotive Parts and Accessories|467077  |3410    |0       |



```sql
SELECT m, category, sub_category, goods_id, SUM(sales) AS sales,
  GROUPING(category,sub_category) AS group_id
FROM 
(
  SELECT TD_TIME_FORMAT(time,'yyyy-MM-01','JST') AS m,category, sub_category, goods_id, price*amount AS sales
  FROM sales_slip
  WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
)
GROUP BY ROLLUP (m,category,sub_category,goods_id)
ORDER BY m,category, sub_category, goods_id
```
|m                                          |category|sub_category|goods_id|sales|group_id|
|-------------------------------------------|--------|------------|--------|-----|--------|
|2011-01-01                                 |Automotive and Industrial|Automotive Parts and Accessories|466889  |24572|0       |
|2011-01-01                                 |Automotive and Industrial|Automotive Parts and Accessories|466983  |3800 |0       |
|2011-01-01                                 |Automotive and Industrial|Automotive Parts and Accessories|467077  |3410 |0       |



```sql
WITH groups1
AS
( SELECT name,id
  FROM (
  VALUES 
    ('1_month',       POWER(2,3)),
    ('2_category',    POWER(2,2)),
    ('3_sub_category',POWER(2,1)),
    ('4_goods_id',    POWER(2,0)),
    ('1_NULL',                 0),
    ('2_NULL',                 0),
    ('3_NULL',                 0),
    ('4_NULL',                 0)
  ) AS t(name,id)
)

SELECT groups1.name AS name1, groups2.name AS name2, groups3.name AS name3, groups4.name AS name4, 
  CAST( (8+4+2+1-groups1.id-groups2.id-groups3.id-groups4.id) AS INTEGER ) AS group_id
FROM groups1
JOIN
( SELECT name, id FROM groups1 ) AS groups2
ON groups1.name <> groups2.name 
AND SUBSTR(groups1.name,1,1) ='1' AND SUBSTR(groups2.name,1,1) ='2'
JOIN
( SELECT name, id FROM groups1 ) AS groups3
ON groups2.name <> groups3.name AND groups1.name <> groups3.name
AND SUBSTR(groups3.name,1,1) ='3'
JOIN
( SELECT name, id FROM groups1 ) AS groups4
ON groups3.name <> groups4.name AND groups2.name <> groups4.name AND groups1.name <> groups4.name
AND SUBSTR(groups4.name,1,1) ='4'
WHERE (8+4+2+1-groups1.id-groups2.id-groups3.id-groups4.id) IN (0,1,3,7,15)
ORDER BY group_id
```           
|name1                                      |name2|name3 |name4   |group_id|
|-------------------------------------------|-----|------|--------|--------|
|1_month                                    |2_category|3_sub_category|4_goods_id|0       |
|1_month                                    |2_category|3_sub_category|4_NULL  |1       |
|1_month                                    |2_category|3_NULL|4_NULL  |3       |
|1_month                                    |2_NULL|3_NULL|4_NULL  |7       |
|1_NULL                                     |2_NULL|3_NULL|4_NULL  |15      |

### CUBE



```sql
SELECT category, sub_category, SUM(price*amount) AS sales,
  GROUPING(category,sub_category) AS group_id
FROM sales_slip
WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
GROUP BY CUBE(category,sub_category)
ORDER BY group_id, category, sub_category
```
|category                                   |sub_category|sales |group_id|
|-------------------------------------------|------------|------|--------|
|Automotive and Industrial                  |Automotive Parts and Accessories|15404860|0       |
|Automotive and Industrial                  |Automotive Tools and Equipment|15047016|0       |
|Automotive and Industrial                  |Car/Vehicle Electronics and GPS|14112998|0       |



```sql
SELECT category, sub_category, SUM(price*amount) AS sales,
  GROUPING(category,sub_category) AS group_id
FROM sales_slip
WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
GROUP BY GROUPING SETS(
  (),
  (category),
  (sub_category),
  (category,sub_category)
)
ORDER BY group_id, category, sub_category
```
|category                                   |sub_category|sales |group_id|
|-------------------------------------------|------------|------|--------|
|Automotive and Industrial                  |Automotive Parts and Accessories|15404860|0       |
|Automotive and Industrial                  |Automotive Tools and Equipment|15047016|0       |
|Automotive and Industrial                  |Car/Vehicle Electronics and GPS|14112998|0       |



```sql
SELECT category, sub_category, goods_id, SUM(price*amount) AS sales,
  GROUPING(category,sub_category,goods_id) AS group_id
FROM sales_slip
WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
GROUP BY CUBE(category,sub_category,goods_id)
ORDER BY group_id, category, sub_category, goods_id
```
|category                                   |sub_category|goods_id|sales   |group_id|
|-------------------------------------------|------------|--------|--------|--------|
|Automotive and Industrial                  |Automotive Parts and Accessories|466889  |24572   |0       |
|Automotive and Industrial                  |Automotive Parts and Accessories|466983  |3800    |0       |
|Automotive and Industrial                  |Automotive Parts and Accessories|467077  |3410    |0       |



```sql
WITH groups1
AS
( SELECT name,id
  FROM (
  VALUES 
    ('1_category',    POWER(2,2)),
    ('2_sub_category',POWER(2,1)),
    ('3_goods_id',    POWER(2,0)),
    ('1_NULL',                 0),
    ('2_NULL',                 0),
    ('3_NULL',                 0)
  ) AS t(name,id)
)

SELECT groups1.name AS name1, groups2.name AS name2, groups3.name AS name3, 
  CAST( (4+2+1-groups1.id-groups2.id-groups3.id) AS INTEGER ) AS group_id
FROM groups1
JOIN
( SELECT name, id FROM groups1 ) AS groups2
ON groups1.name <> groups2.name 
AND SUBSTR(groups1.name,1,1) ='1' AND SUBSTR(groups2.name,1,1) ='2'
JOIN
( SELECT name, id FROM groups1 ) AS groups3
ON groups2.name <> groups3.name AND groups1.name <> groups3.name
AND SUBSTR(groups3.name,1,1) ='3'
ORDER BY group_id
```
|name1                                      |name2|name3 |group_id|
|-------------------------------------------|-----|------|--------|
|1_category                                 |2_sub_category|3_goods_id|0       |
|1_category                                 |2_sub_category|3_NULL|1       |
|1_category                                 |2_NULL|3_goods_id|2       |
|1_category                                 |2_NULL|3_NULL|3       |
|1_NULL                                     |2_sub_category|3_goods_id|4       |
|1_NULL                                     |2_sub_category|3_NULL|5       |
|1_NULL                                     |2_NULL|3_goods_id|6       |
|1_NULL                                     |2_NULL|3_NULL|7       |



```sql
SELECT category, sub_category, goods_id, SUM(price*amount) AS sales,
  GROUPING(category,sub_category,goods_id) AS group_id
FROM sales_slip
WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
GROUP BY GROUPING SETS(
  (),
  (category),
  (sub_category),
  (goods_id),
  (category,sub_category),
  (category,goods_id),
  (sub_category,goods_id),
  (category,sub_category,goods_id)
)
ORDER BY group_id, category, sub_category, goods_id
```
|category                                   |sub_category|goods_id|sales   |group_id|
|-------------------------------------------|------------|--------|--------|--------|
|Automotive and Industrial                  |Automotive Parts and Accessories|466889  |24572   |0       |
|Automotive and Industrial                  |Automotive Parts and Accessories|466983  |3800    |0       |
|Automotive and Industrial                  |Automotive Parts and Accessories|467077  |3410    |0       |



```sql
SELECT m, category, sub_category, goods_id, SUM(sales) AS sales,
  GROUPING(category,sub_category,goods_id) AS group_id
FROM 
(
  SELECT TD_TIME_FORMAT(time,'yyyy-MM-01','JST') AS m,category, sub_category, goods_id, price*amount AS sales
  FROM sales_slip
  WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
)
GROUP BY CUBE (m,category,sub_category,goods_id)
HAVING m IS NOT NULL
ORDER BY group_id, m, category, sub_category, goods_id
```
|m                                          |category|sub_category|goods_id|sales|group_id|
|-------------------------------------------|--------|------------|--------|-----|--------|
|2011-01-01                                 |Automotive and Industrial|Automotive Parts and Accessories|466889  |24572|0       |
|2011-01-01                                 |Automotive and Industrial|Automotive Parts and Accessories|466983  |3800 |0       |
|2011-01-01                                 |Automotive and Industrial|Automotive Parts and Accessories|467077  |3410 |0       |



```sql
WITH groups1
AS
( SELECT name,id
  FROM (
  VALUES 
    ('1_month',       POWER(2,3)),
    ('2_category',    POWER(2,2)),
    ('3_sub_category',POWER(2,1)),
    ('4_goods_id',    POWER(2,0)),
    ('1_NULL',                 0),
    ('2_NULL',                 0),
    ('3_NULL',                 0),
    ('4_NULL',                 0)
  ) AS t(name,id)
)

SELECT groups1.name AS name1, groups2.name AS name2, groups3.name AS name3, groups4.name AS name4, 
  CAST( (8+4+2+1-groups1.id-groups2.id-groups3.id-groups4.id) AS INTEGER ) AS group_id
FROM groups1
JOIN
( SELECT name, id FROM groups1 ) AS groups2
ON groups1.name <> groups2.name 
AND SUBSTR(groups1.name,1,1) ='1' AND SUBSTR(groups2.name,1,1) ='2'
JOIN
( SELECT name, id FROM groups1 ) AS groups3
ON groups2.name <> groups3.name AND groups1.name <> groups3.name
AND SUBSTR(groups3.name,1,1) ='3'
JOIN
( SELECT name, id FROM groups1 ) AS groups4
ON groups3.name <> groups4.name AND groups2.name <> groups4.name AND groups1.name <> groups4.name
AND SUBSTR(groups4.name,1,1) ='4'
ORDER BY group_id
```
|name1                                      |name2|name3 |name4   |group_id|
|-------------------------------------------|-----|------|--------|--------|
|1_month                                    |2_category|3_sub_category|4_goods_id|0       |
|1_month                                    |2_category|3_sub_category|4_NULL  |1       |
|1_month                                    |2_category|3_NULL|4_goods_id|2       |
|1_month                                    |2_category|3_NULL|4_NULL  |3       |
|1_month                                    |2_NULL|3_sub_category|4_goods_id|4       |
|1_month                                    |2_NULL|3_sub_category|4_NULL  |5       |
|1_month                                    |2_NULL|3_NULL|4_goods_id|6       |
|1_month                                    |2_NULL|3_NULL|4_NULL  |7       |
|1_NULL                                     |2_category|3_sub_category|4_goods_id|8       |
|1_NULL                                     |2_category|3_sub_category|4_NULL  |9       |
|1_NULL                                     |2_category|3_NULL|4_goods_id|10      |
|1_NULL                                     |2_category|3_NULL|4_NULL  |11      |
|1_NULL                                     |2_NULL|3_sub_category|4_goods_id|12      |
|1_NULL                                     |2_NULL|3_sub_category|4_NULL  |13      |
|1_NULL                                     |2_NULL|3_NULL|4_goods_id|14      |
|1_NULL                                     |2_NULL|3_NULL|4_NULL  |15      |



## EXISTS，IN，=：WHERE節のサブクエリと比較

### EXISTS

```sql
WITH t1 AS
( SELECT number, alphabet FROM ( VALUES (1,'a'),(2,'b'),(3,'c') ) AS t(number, alphabet) ),
t2 AS
( SELECT number FROM ( VALUES 1, 3, 5 ) AS t(number) )

SELECT number, alphabet
FROM t1
WHERE EXISTS (SELECT * FROM t2 WHERE t1.number = t2.number)
```
|number                                     |alphabet|
|-------------------------------------------|--------|
|1                                          |a       |
|3                                          |c       |


### IN


```sql
WITH t1 AS
( SELECT number, alphabet FROM ( VALUES (1,'a'),(2,'b'),(3,'c') ) AS t(number, alphabet) ),
t2 AS
( SELECT number FROM ( VALUES 1, 3, 5 ) AS t(number) )

SELECT number, alphabet
FROM t1
WHERE number IN (SELECT number FROM t2)
```
|number                                     |alphabet|
|-------------------------------------------|--------|
|1                                          |a       |
|3                                          |c       |


### Scalarサブクエリ

```sql
WITH t1 AS
( SELECT number, alphabet FROM ( VALUES (1,'a'),(2,'b'),(3,'c') ) AS t(number, alphabet) ),
t2 AS
( SELECT number FROM ( VALUES 1, 3, 5 ) AS t(number) )

SELECT number, alphabet
FROM t1
WHERE number = (SELECT MIN(number) FROM t2)
```
|number                                     |alphabet|
|-------------------------------------------|--------|
|1                                          |a       |


```sql
--結果なし（t2のMAX=5に対してt1には5の値のnumberカラムが存在しない）
WITH t1 AS
( SELECT number, alphabet FROM ( VALUES (1,'a'),(2,'b'),(3,'c') ) AS t(number, alphabet) ),
t2 AS
( SELECT number FROM ( VALUES 1, 3, 5 ) AS t(number) )

SELECT number, alphabet
FROM t1
WHERE number = (SELECT MAX(number) FROM t2)
```
