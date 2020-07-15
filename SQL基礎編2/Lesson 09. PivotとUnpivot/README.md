# Lesson 09. PivotとUnpivot

## 縦持ちテーブルと横持ちテーブルの相互変換

### Pivot（縦持ち → 横持ち）



```sql
SELECT td_client_id, td_title AS key, COUNT(1) AS value
FROM sample_accesslog
GROUP BY td_client_id, td_title
ORDER BY td_client_id
```
|td_client_id                        |key                                               |value|
|------------------------------------|--------------------------------------------------|-----|
|000077fb-2c93-4cd7-d9d0-293866aaec31|Treasure Data - データ分析をクラウドで、シンプルに。 - Treasure Data|2    |
|000077fb-2c93-4cd7-d9d0-293866aaec31|採用情報 - Treasure Data                              |1    |
|000077fb-2c93-4cd7-d9d0-293866aaec31|企業情報 - Treasure Data                              |1    |




```sql
WITH vtable AS 
( SELECT id,key,value
  FROM ( VALUES
    (1,'col1',11),(1,'col2',12),(1,'col3',13),
    (2,'col1',21),(2,'col2',22),(2,'col3',23),
    (3,'col1',31),(3,'col2',32),(3,'col3',33)
  ) AS t(id,key,value) 
)
SELECT id, key, value
FROM vtable
```
|id                                  |key                                               |value|
|------------------------------------|--------------------------------------------------|-----|
|1                                   |col1                                              |11   |
|1                                   |col2                                              |12   |
|1                                   |col3                                              |13   |
|2                                   |col1                                              |21   |
|2                                   |col2                                              |22   |
|2                                   |col3                                              |23   |
|3                                   |col1                                              |31   |
|3                                   |col2                                              |32   |
|3                                   |col3                                              |33   |



```sql
WITH vtable AS 
( SELECT id,key,value
  FROM ( VALUES
    (1,'col1',11),(1,'col2',12),(1,'col3',13),
    (2,'col1',21),(2,'col2',22),(2,'col3',23),
    (3,'col1',31),(3,'col2',32),(3,'col3',33)
  ) AS t(id,key,value) 
)

SELECT
  id,
  kv['col1'] AS col1,
  kv['col2'] AS col2,
  kv['col3'] AS col3
FROM (
  SELECT id, MAP_AGG(key, value) AS kv
  FROM vtable
  GROUP BY id
)
ORDER BY id
```
|id                                  |col1                                              |col2|col3|
|------------------------------------|--------------------------------------------------|----|----|
|1                                   |11                                                |12  |13  |
|2                                   |21                                                |22  |23  |
|3                                   |31                                                |32  |33  |



```sql
WITH vtable AS 
( SELECT id,key,value
  FROM ( VALUES
    (1,'col1',11),(1,'col2',12),(1,'col3',13),
    (2,'col1',21),(2,'col2',22),(2,'col3',23),
    (3,'col1',31),(3,'col2',32)--,(3,'col3',33)
  ) AS t(id,key,value) 
)

SELECT
  id,
  kv['col1'] AS col1,
  kv['col2'] AS col2,
  kv['col3'] AS col3
FROM (
  SELECT id, MAP_AGG(key, value) AS kv
  FROM vtable
  GROUP BY id
)
ORDER BY id
```



```sql
failed: Key not present in map: col3
```



```sql
WITH vtable AS 
( SELECT id,key,value
  FROM ( VALUES
    (1,'col1',11),(1,'col2',12),(1,'col3',13),
    (2,'col1',21),(2,'col2',22),(2,'col3',23),
    (3,'col1',31),(3,'col2',32)--,(3,'col3',33)
  ) AS t(id,key,value) 
)

SELECT
  id,
  IF(ELEMENT_AT(kv,'col1') IS NOT NULL, kv['col1'], NULL) AS col1,
  IF(ELEMENT_AT(kv,'col2') IS NOT NULL, kv['col2'], NULL) AS col2,
  IF(ELEMENT_AT(kv,'col3') IS NOT NULL, kv['col3'], NULL) AS col3
FROM (
  SELECT id, MAP_AGG(key, value) AS kv
  FROM vtable
  GROUP BY id
)
ORDER BY id
```
|id                                  |col1                                              |col2|col3|
|------------------------------------|--------------------------------------------------|----|----|
|1                                   |11                                                |12  |13  |
|2                                   |21                                                |22  |23  |
|3                                   |31                                                |32  |NULL|


### TD_PIVOT（Hive2019.1以降のみ）


```sql
WITH vtable AS 
( 
  SELECT STACK(
    9, --行数をはじめに定義！
    1,'col1',11,1,'col2',12,1,'col3',13,
    2,'col1',21,2,'col2',22,2,'col3',23,
    3,'col1',31,3,'col2',32,3,'col3',33
  ) AS (id,key,value)
)

SELECT id, MAX(t.col1) AS col1, MAX(t.col2) AS col2, MAX(t.col3) AS col3
FROM vtable
LATERAL VIEW TD_PIVOT(key,value,'col1,col2,col3') t
GROUP BY id
ORDER BY id
```
| id | col1 | col2 | col3 | 
|----|------|------|------| 
| 1  | 11   | 12   | 13   | 
| 2  | 21   | 22   | 23   | 
| 3  | 31   | 32   | 33   | 




```sql
WITH vtable AS 
( 
  SELECT STACK(
    8, --行数をはじめに定義！
    1,'col1',11,1,'col2',12,1,'col3',13,
    2,'col1',21,2,'col2',22,2,'col3',23,
    3,'col1',31,3,'col2',32--,3,'col3',33
  ) AS (id,key,value)
)

SELECT id, MAX(t.col1) AS col1, MAX(t.col2) AS col2, MAX(t.col3) AS col3
FROM vtable
LATERAL VIEW TD_PIVOT(key,value,'col1,col2,col3') t
GROUP BY id
ORDER BY id
```
| id | col1 | col2 | col3 | 
|----|------|------|------| 
| 1  | 11   | 12   | 13   | 
| 2  | 21   | 22   | 23   | 
| 3  | 31   | 32   | NULL | 




```sql
WITH vtable AS 
( 
  SELECT STACK(
    15, --行数をはじめに定義！
    1,'col1',11,1,'col2',12,1,'col3',13,
    2,'col1',21,2,'col2',22,2,'col3',23,
    3,'col1',31,3,'col2',32,3,'col3',33,
    1,'col1',111,1,'col2',121,1,'col3',131,
    2,'col1',212,2,'col2',222,2,'col3',232
  ) AS (id,key,value)
)

SELECT id, COLLECT_SET(t.col1) AS col1, COLLECT_SET(t.col2) AS col2, COLLECT_SET(t.col3) AS col3
FROM vtable
LATERAL VIEW TD_PIVOT(key,value,'col1,col2,col3') t
GROUP BY id
ORDER BY id
```
|id |col1                                   |col2  |col3  |
|---|---------------------------------------|------|------|
|1  |[11, 111]                              |[12, 121]|[13, 131]|
|2  |[21, 212]                              |[22, 222]|[23, 232]|
|3  |[31]                                   |[32]  |[33]  |

### Unpivot（横持ち → 縦持ち）


```sql
WITH htable AS 
( SELECT id,col1,col2,col3
  FROM ( VALUES
    (1,11,12,13),(2,21,22,23),(3,31,32,33)
  ) AS t(id,col1,col2,col3) 
)

SELECT id,col1,col2,col3 FROM htable
```
|id |col1                                   |col2  |col3  |
|---|---------------------------------------|------|------|
|1  |11                                     |12    |13    |
|2  |21                                     |22    |23    |
|3  |31                                     |32    |33    |



```sql
WITH htable AS 
( SELECT id,col1,col2,col3
  FROM ( VALUES
    (1,11,12,13),(2,21,22,23),(3,31,32,33)
  ) AS t(id,col1,col2,col3) 
)

SELECT t1.id, t2.key, t2.value
FROM htable t1
CROSS JOIN UNNEST (
  array['col1','col2','col3'],
  array[ col1,  col2,  col3 ]
) t2 (key, value)
```
|id |key                                    |value |
|---|---------------------------------------|------|
|1  |col1                                   |11    |
|1  |col2                                   |12    |
|1  |col3                                   |13    |
|2  |col1                                   |21    |
|2  |col2                                   |22    |
|2  |col3                                   |23    |
|3  |col1                                   |31    |
|3  |col2                                   |32    |
|3  |col3                                   |33    |



```sql
WITH list_table AS
(
  SELECT ARRAY[1,2,3,4] AS list
)

SELECT x
FROM list_table
CROSS JOIN UNNEST(list) AS t(x)
```
|x  |
|---|
|1  |
|2  |
|3  |
|4  |



```sql
WITH list_table AS
(
  SELECT ARRAY['a','b','c','d'] AS list
)

SELECT id, x
FROM list_table
CROSS JOIN UNNEST(list) WITH ORDINALITY AS t(id,x)
```
|id |x  |
|---|---|
|a  |1  |
|b  |2  |
|c  |3  |
|d  |4  |



```sql
WITH map_table AS
(
  SELECT MAP( ARRAY['a','b','c'], ARRAY[1,2,3] ) AS mp
)

SELECT k,v
FROM map_table
CROSS JOIN UNNEST(mp) AS t(k,v)
```
|k  |v  |
|---|---|
|a  |1  |
|b  |2  |
|c  |3  |



```sql
WITH htable AS 
( SELECT id,col1,col2,col3
  FROM ( VALUES
    (1,11,12,13),(2,21,22,23),(3,31,32,33)
  ) AS t(id,col1,col2,col3) 
)

SELECT id,value
FROM htable
CROSS JOIN UNNEST( ARRAY[col1,col2,col3] ) AS t(value)
```
|id |value|
|---|-----|
|1  |11   |
|1  |12   |
|1  |13   |
|2  |21   |
|2  |22   |
|2  |23   |
|3  |31   |
|3  |32   |
|3  |33   |



```sql
WITH htable AS 
( SELECT id,col1,col2,col3
  FROM ( VALUES
    (1,11,12,13),(2,21,22,23),(3,31,32,33)
  ) AS t(id,col1,col2,col3) 
)

SELECT id,key,value
FROM htable
CROSS JOIN UNNEST( MAP(ARRAY['col1','col2','col3'], ARRAY[col1,col2,col3]) ) AS t(key,value)
```
|id |key|value|
|---|---|-----|
|1  |col1|11   |
|1  |col2|12   |
|1  |col3|13   |
|2  |col1|21   |
|2  |col2|22   |
|2  |col3|23   |
|3  |col1|31   |
|3  |col2|32   |
|3  |col3|33   |



```sql
WITH htable AS 
( SELECT id,col1,col2,col3
  FROM ( VALUES
    (1,11,12,13),(2,21,22,23),(3,31,32,33)
  ) AS t(id,col1,col2,col3) 
)

SELECT id,key,value
FROM htable
CROSS JOIN UNNEST( 
  ARRAY['col1','col2','col3'], 
  ARRAY[col1,col2,col3] 
) AS t(key,value)
```
|id |key|value|
|---|---|-----|
|1  |col1|11   |
|1  |col2|12   |
|1  |col3|13   |
|2  |col1|21   |
|2  |col2|22   |
|2  |col3|23   |
|3  |col1|31   |
|3  |col2|32   |
|3  |col3|33   |



```sql
WITH htable AS 
( SELECT id,col1,col2,col3
  FROM ( VALUES
    (1,11,12,13),(2,21,22,23),(3,31,32,33)
  ) AS t(id,col1,col2,col3) 
)

SELECT id,x,key,value
FROM htable
CROSS JOIN UNNEST( ARRAY['1','2','3'], ARRAY['col1','col2','col3'], ARRAY[col1,col2,col3] ) AS t(x,key,value)
```
|id |x  |key|value|
|---|---|---|-----|
|1  |1  |col1|11   |
|1  |2  |col2|12   |
|1  |3  |col3|13   |
|2  |1  |col1|21   |
|2  |2  |col2|22   |
|2  |3  |col3|23   |
|3  |1  |col1|31   |
|3  |2  |col2|32   |
|3  |3  |col3|33   |


### TD_UNPIVOT （Hive2019.1以降のみ）


```sql
WITH htable AS 
( 
  SELECT STACK(
    3, --行数をはじめに定義！
    1,11,12,13,
    2,21,22,23,
    3,31,32,33
  ) AS (id,col1,col2,col3) 
)

SELECT id, t.key, t.value
FROM htable
LATERAL VIEW TD_UNPIVOT(
 'col1, col2, col3', --一括して''で包む！
  col1, col2, col3
) t
```
|id |key|value|
|---|---|-----|
|1  |col1|11   |
|1  |col2|12   |
|1  |col3|13   |
|2  |col1|21   |
|2  |col2|22   |
|2  |col3|23   |
|3  |col1|31   |
|3  |col2|32   |
|3  |col3|33   |


## 月別カテゴリ別売上のPivot

### 集計結果の縦持ちテーブル展開


```sql
SELECT category, TD_TIME_FORMAT(time,'yyyy-MM-01','JST') AS m, SUM(price*amount) AS sales
FROM sales_slip
WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
GROUP BY category, TD_TIME_FORMAT(time,'yyyy-MM-01','JST')
ORDER BY category, m
```
|category|m  |sales|
|--------|---|-----|
|Automotive and Industrial|2011-01-01|12534483|
|Automotive and Industrial|2011-02-01|13416809|
|Automotive and Industrial|2011-03-01|8758366|


### 集計結果の横持ちテーブル展開


```sql
SELECT category,
  SUM(price*amount) AS sales,
  SUM(IF(TD_TIME_FORMAT(time,'MM','JST')='01',price*amount,0)) AS sales_01,
  SUM(IF(TD_TIME_FORMAT(time,'MM','JST')='02',price*amount,0)) AS sales_02,
  SUM(IF(TD_TIME_FORMAT(time,'MM','JST')='03',price*amount,0)) AS sales_03,
  SUM(IF(TD_TIME_FORMAT(time,'MM','JST')='04',price*amount,0)) AS sales_04,
  SUM(IF(TD_TIME_FORMAT(time,'MM','JST')='05',price*amount,0)) AS sales_05,
  SUM(IF(TD_TIME_FORMAT(time,'MM','JST')='06',price*amount,0)) AS sales_06,
  SUM(IF(TD_TIME_FORMAT(time,'MM','JST')='07',price*amount,0)) AS sales_07,
  SUM(IF(TD_TIME_FORMAT(time,'MM','JST')='08',price*amount,0)) AS sales_08,
  SUM(IF(TD_TIME_FORMAT(time,'MM','JST')='09',price*amount,0)) AS sales_09,
  SUM(IF(TD_TIME_FORMAT(time,'MM','JST')='10',price*amount,0)) AS sales_10,
  SUM(IF(TD_TIME_FORMAT(time,'MM','JST')='11',price*amount,0)) AS sales_11,
  SUM(IF(TD_TIME_FORMAT(time,'MM','JST')='12',price*amount,0)) AS sales_12
FROM sales_slip
WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
GROUP BY category
ORDER BY category
```
|category|sales|sales_01|sales_02|sales_03|sales_04|sales_05|sales_06|sales_07|sales_08|sales_09|sales_10|sales_11|sales_12|
|--------|-----|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|
|Automotive and Industrial|297392235|12534483|13416809|8758366 |9090745 |10018925|11619741|12079420|10917973|22954570|99919930|56737426|29343847|
|Beauty and Health and Grocery|143134731|14230393|11712632|9706985 |10697462|10428175|12302220|11462844|11190105|11326316|13649877|12187760|14239962|
|Books and Audible|77114484|7229510 |5549857 |6446509 |5411451 |4906877 |6625708 |6588833 |4388909 |7049822 |8363116 |7078299 |7475593 |


### Pivot（縦持ち → 横持ち）


```sql
WITH vtable AS
(
  SELECT category, TD_TIME_FORMAT(time,'yyyy-MM-01','JST') AS m, SUM(price*amount) AS sales
  FROM sales_slip
  WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
  GROUP BY category, TD_TIME_FORMAT(time,'yyyy-MM-01','JST')
  ORDER BY category, m
)

SELECT
  category, 
  sales,
  IF(ELEMENT_AT(kv,'2011-01-01') IS NOT NULL,kv['2011-01-01'],0) AS sales_01,
  IF(ELEMENT_AT(kv,'2011-02-01') IS NOT NULL,kv['2011-02-01'],0) AS sales_02,
  IF(ELEMENT_AT(kv,'2011-03-01') IS NOT NULL,kv['2011-03-01'],0) AS sales_03,
  IF(ELEMENT_AT(kv,'2011-04-01') IS NOT NULL,kv['2011-04-01'],0) AS sales_04,
  IF(ELEMENT_AT(kv,'2011-05-01') IS NOT NULL,kv['2011-05-01'],0) AS sales_05,
  IF(ELEMENT_AT(kv,'2011-06-01') IS NOT NULL,kv['2011-06-01'],0) AS sales_06,
  IF(ELEMENT_AT(kv,'2011-07-01') IS NOT NULL,kv['2011-07-01'],0) AS sales_07,
  IF(ELEMENT_AT(kv,'2011-08-01') IS NOT NULL,kv['2011-08-01'],0) AS sales_08,
  IF(ELEMENT_AT(kv,'2011-09-01') IS NOT NULL,kv['2011-09-01'],0) AS sales_09,
  IF(ELEMENT_AT(kv,'2011-10-01') IS NOT NULL,kv['2011-10-01'],0) AS sales_10,
  IF(ELEMENT_AT(kv,'2011-11-01') IS NOT NULL,kv['2011-11-01'],0) AS sales_11,
  IF(ELEMENT_AT(kv,'2011-12-01') IS NOT NULL,kv['2011-12-01'],0) AS sales_12
FROM (
  SELECT category, map_agg(m, sales) AS kv, SUM(sales) AS sales
  FROM vtable
  GROUP BY category
)
ORDER BY category
```
|category|sales|sales_01|sales_02|sales_03|sales_04|sales_05|sales_06|sales_07|sales_08|sales_09|sales_10|sales_11|sales_12|
|--------|-----|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|
|Automotive and Industrial|297392235|12534483|13416809|8758366 |9090745 |10018925|11619741|12079420|10917973|22954570|99919930|56737426|29343847|
|Beauty and Health and Grocery|143134731|14230393|11712632|9706985 |10697462|10428175|12302220|11462844|11190105|11326316|13649877|12187760|14239962|
|Books and Audible|77114484|7229510 |5549857 |6446509 |5411451 |4906877 |6625708 |6588833 |4388909 |7049822 |8363116 |7078299 |7475593 |


### Unpivot（横持ち → 縦持ち）



```sql
WITH htable AS
(
  SELECT category,
    SUM(price*amount) AS sales,
    SUM(IF(TD_TIME_FORMAT(time,'MM','JST')='01',price*amount,0)) AS sales_01,
    SUM(IF(TD_TIME_FORMAT(time,'MM','JST')='02',price*amount,0)) AS sales_02,
    SUM(IF(TD_TIME_FORMAT(time,'MM','JST')='03',price*amount,0)) AS sales_03,
    SUM(IF(TD_TIME_FORMAT(time,'MM','JST')='04',price*amount,0)) AS sales_04,
    SUM(IF(TD_TIME_FORMAT(time,'MM','JST')='05',price*amount,0)) AS sales_05,
    SUM(IF(TD_TIME_FORMAT(time,'MM','JST')='06',price*amount,0)) AS sales_06,
    SUM(IF(TD_TIME_FORMAT(time,'MM','JST')='07',price*amount,0)) AS sales_07,
    SUM(IF(TD_TIME_FORMAT(time,'MM','JST')='08',price*amount,0)) AS sales_08,
    SUM(IF(TD_TIME_FORMAT(time,'MM','JST')='09',price*amount,0)) AS sales_09,
    SUM(IF(TD_TIME_FORMAT(time,'MM','JST')='10',price*amount,0)) AS sales_10,
    SUM(IF(TD_TIME_FORMAT(time,'MM','JST')='11',price*amount,0)) AS sales_11,
    SUM(IF(TD_TIME_FORMAT(time,'MM','JST')='12',price*amount,0)) AS sales_12
  FROM sales_slip
  WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
  GROUP BY category
  ORDER BY category
)

SELECT t1.category, t2.key AS m, t2.value AS sales
FROM htable t1
CROSS JOIN UNNEST (
  array['2011-01-01','2011-02-01','2011-03-01','2011-04-01','2011-05-01','2011-06-01','2011-07-01','2011-08-01','2011-09-01','2011-10-01','2011-11-01','2011-12-01'],
  array[sales_01,sales_02,sales_03,sales_04,sales_05,sales_06,sales_07,sales_08,sales_09,sales_10,sales_11,sales_12]
) t2 (key, value)
ORDER BY category, m
```
|category|m  |sales|
|--------|---|-----|
|Automotive and Industrial|2011-01-01|12534483|
|Automotive and Industrial|2011-02-01|13416809|
|Automotive and Industrial|2011-03-01|8758366|


