# Lesson 05. 条件制御

## IFの基本

```sql
IF(condition, true_value, false_value)
```

```sql
WITH numbers AS 
( SELECT number FROM ( VALUES 1,2,3,4,5,6,NULL ) AS t(number) )

SELECT number,
  IF(number%2=1,'odd','even') AS number_type
FROM numbers
```
|number|number_type|
|------|-----------|
|1     |odd        |
|2     |even       |
|3     |odd        |
|4     |even       |
|5     |odd        |
|6     |even       |
|NULL  |even       |


## IFの結果の集計横展開

### IF結果を集計して縦方向にテーブル出力

```sql
WITH numbers AS 
( SELECT number FROM ( VALUES 1,2,3,4,5,6 ) AS t(number) )

SELECT number_type, COUNT(1) AS cnt
FROM
(
  SELECT number, IF(number%2=1,'odd','even') AS number_type
  FROM numbers
)
GROUP BY number_type
```
|number_type|cnt  |
|-----------|-----|
|odd        |3    |
|even       |3    |


### IFの結果を集計して横方向にテーブル出力


```sql
WITH numbers AS 
( SELECT number FROM ( VALUES 1,2,3,4,5,6,NULL ) AS t(number) )

SELECT
  COUNT(IF(number%2=1,1,NULL)) AS num_odd,
  COUNT(IF(number%2=0,1,NULL)) AS num_even,
  COUNT(IF(number IS NULL,1,NULL)) AS num_null,
  COUNT(1) AS num_total,
  COUNT(IF(number%2=0,1,0)) AS num_even_wrong, --IFの結果にかかわらずカウントされてしまう悪い例
  COUNT(number) AS num_total_wrong --NULLをカウントしない全件カウント
FROM numbers
```
|num_odd|num_even|num_null|num_total|num_even_wrong|num_total_wrong|
|-------|--------|--------|---------|--------------|---------------|
|3      |3       |1       |7        |7             |6              |


## CASEの基本

```sql
CASE expression
    WHEN value THEN result
    [ WHEN ... ]
    [ ELSE result ]
END
```


```sql
WITH numbers AS 
( SELECT number FROM ( VALUES 1,2,3,4,5,6,NULL ) AS t(number) )

SELECT number,
  CASE number%2
    WHEN 1 THEN 'odd'
    WHEN 0 THEN 'even'
    WHEN NULL THEN 'null'
    ELSE 'other'
  END
  AS number_type
FROM numbers
```
|number|number_type|
|------|-----------|
|1     |odd        |
|2     |even       |
|3     |odd        |
|4     |even       |
|5     |odd        |
|6     |even       |
|NULL  |other      |

```sql
WITH numbers AS 
( SELECT number FROM ( VALUES 1,2,3,4,5,6,NULL ) AS t(number) )

SELECT number,
  CASE number%2
    WHEN 1 THEN 'odd'
    WHEN 0 THEN 'even'
    WHEN NULL THEN 'null'
  END
  AS number_type
FROM numbers
```
|number|number_type|
|------|-----------|
|1     |odd        |
|2     |even       |
|3     |odd        |
|4     |even       |
|5     |odd        |
|6     |even       |
|NULL  |NULL       |


```sql
CASE
    WHEN condition THEN result
    [ WHEN ... ]
    [ ELSE result ]
END
```


```sql
WITH numbers AS 
( SELECT number FROM ( VALUES 1,2,3,4,5,6,NULL ) AS t(number) )

SELECT number,
  CASE 
    WHEN number%2=1 THEN 'odd'
    WHEN number%2=0 THEN 'even'
    WHEN number%2 IS NULL THEN 'null'
    ELSE 'other'
  END
  AS number_type
FROM numbers
```
|number|number_type|
|------|-----------|
|1     |odd        |
|2     |even       |
|3     |odd        |
|4     |even       |
|5     |odd        |
|6     |even       |
|NULL  |null       |


## CASEとセグメント


```sql
WITH sales_table AS
(
  SELECT member_id, category, SUM(price*amount) AS sales
  FROM sales_slip
  WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
  GROUP BY member_id, category
)

SELECT member_id, category, sales,
  CASE
    WHEN 0      <= sales AND sales < 10000   THEN 'Low'
    WHEN 10000  <= sales AND sales < 100000  THEN 'Mid'
    WHEN 100000 <= sales AND sales < 1000000 THEN 'High'
    ELSE 'Extreme'
  END AS seg_sales
FROM sales_table
```
|member_id|category|sales|seg_sales|
|---------|--------|-----|---------|
|415086   |Books and Audible|2652 |Low      |
|1227055  |Home and Garden and Tools|73738|Mid      |
|1426403  |Home and Garden and Tools|47208|Mid      |


```sql
WITH sales_table AS
(
  SELECT member_id, category, SUM(price*amount) AS sales
  FROM sales_slip
  WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
  GROUP BY member_id, category
)

SELECT seg_sales, COUNT(1) AS cnt
FROM
(
  SELECT member_id, category, sales,
    CASE
      WHEN 0      <= sales AND sales < 10000   THEN '01_Low'
      WHEN 10000  <= sales AND sales < 100000  THEN '02_Mid'
      WHEN 100000 <= sales AND sales < 1000000 THEN '03_High'
      ELSE '04_Extreme'
    END AS seg_sales
  FROM sales_table
)
GROUP BY seg_sales
ORDER BY seg_sales
```
|seg_sales|cnt  |
|---------|-----|
|01_Low   |28620|
|02_Mid   |41052|
|03_High  |1167 |
|04_Extreme|7    |


## CASEとFM分析

```sql
WITH sales_table AS
(
  SELECT member_id, category, SUM(price*amount) AS sales, COUNT(1) AS cnt
  FROM sales_slip
  WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
  GROUP BY member_id, category
)

SELECT seg_monetary,
  COUNT(1) AS freq,
  COUNT(IF(seg_frequency='01_Low',1,NULL))     AS freq_low,
  COUNT(IF(seg_frequency='02_Mid',1,NULL))     AS freq_mid,
  COUNT(IF(seg_frequency='03_High',1,NULL))    AS freq_high,
  COUNT(IF(seg_frequency='04_Extreme',1,NULL)) AS freq_extreme
FROM
(
  SELECT member_id, category, sales,
    CASE
      WHEN 0      <= sales AND sales < 10000   THEN '01_Low'
      WHEN 10000  <= sales AND sales < 100000  THEN '02_Mid'
      WHEN 100000 <= sales AND sales < 1000000 THEN '03_High'
      ELSE '04_Extreme'
    END AS seg_monetary,
    CASE
      WHEN 1  <= cnt AND cnt < 3   THEN '01_Low'
      WHEN 3  <= cnt AND cnt < 10  THEN '02_Mid'
      WHEN 10 <= cnt AND cnt < 100 THEN '03_High'
      ELSE '04_Extreme'
    END AS seg_frequency
  FROM sales_table
)
GROUP BY seg_monetary
ORDER BY seg_monetary
```
|seg_monetary|freq |freq_low|freq_mid|freq_high|freq_extreme|
|------------|-----|--------|--------|---------|------------|
|01_Low      |28620|16679   |11909   |32       |0           |
|02_Mid      |41052|1446    |25014   |14588    |4           |
|03_High     |1167 |14      |110     |1025     |18          |
|04_Extreme  |7    |0       |2       |2        |3           |


## COALESCE


```sql
SELECT AVG(a) AS ag, COUNT(a) AS cnt, SUM(a) AS sm
FROM ( VALUES 1, 1, 1, 1, NULL, NULL ) AS t(a)
```
|ag  |cnt  |sm   |
|----|-----|-----|
|1.0 |4    |4    |


```sql
SELECT AVG(COALESCE(a, 0)) AS ag, COUNT(COALESCE(a, 0)) AS cnt, SUM(COALESCE(a, 0)) AS sm
FROM ( VALUES 1, 1, 1, 1, NULL, NULL ) AS t(a)
```
|ag  |cnt  |sm   |
|----|-----|-----|
|0.6666666666666666|6    |4    |

