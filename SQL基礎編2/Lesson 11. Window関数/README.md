# Lesson 11. Window関数

## 集計を「集約」ではなく「付与」する世界観


## 概要


## ランキング系

### ROW_NUMBER：行番号

```sql
SELECT val, ROW_NUMBER()OVER(ORDER BY val) AS rnk
FROM ( VALUES 1,1,2,3 ) AS t(val)
ORDER BY rnk ASC
```
|val                                        |rnk|
|-------------------------------------------|---|
|1                                          |1  |
|1                                          |2  |
|2                                          |3  |
|3                                          |4  |

#### 例：ユーザーごとに，最初のアクセスから順にレコードに番号を割り振る

```sql
SELECT rnk, td_client_id, time
FROM
(
  SELECT 
    ROW_NUMBER() OVER (PARTITION BY td_client_id ORDER BY time ASC) AS rnk, td_client_id, time
  FROM sample_accesslog
) tmp
WHERE td_client_id IN ('f4d99634-4f1f-4e01-8d7f-9cd0a4a6613a','7f47d05f-bd12-4553-e69c-763064738631')
ORDER BY td_client_id, rnk ASC
```
|rnk                                        |td_client_id|time      |
|-------------------------------------------|------------|----------|
|1                                          |7f47d05f-bd12-4553-e69c-763064738631|1465180893|
|2                                          |7f47d05f-bd12-4553-e69c-763064738631|1465181876|
|3                                          |7f47d05f-bd12-4553-e69c-763064738631|1465181995|


#### 例：ユーザーごとの直帰のアクティビティを知るために，各ユーザーの最新の5レコードを取得する

```sql
SELECT rnk, td_client_id, time
FROM
(
  SELECT 
    ROW_NUMBER() OVER (PARTITION BY td_client_id ORDER BY time DESC) AS rnk, td_client_id, time
  FROM sample_accesslog
) tmp
WHERE rnk<=5
AND td_client_id IN ('f4d99634-4f1f-4e01-8d7f-9cd0a4a6613a','7f47d05f-bd12-4553-e69c-763064738631')
ORDER BY td_client_id, rnk
```
|rnk                                        |td_client_id|time      |
|-------------------------------------------|------------|----------|
|1                                          |7f47d05f-bd12-4553-e69c-763064738631|1467694887|
|2                                          |7f47d05f-bd12-4553-e69c-763064738631|1467694610|
|3                                          |7f47d05f-bd12-4553-e69c-763064738631|1467694548|
|4                                          |7f47d05f-bd12-4553-e69c-763064738631|1467694418|
|5                                          |7f47d05f-bd12-4553-e69c-763064738631|1467694247|
|1                                          |f4d99634-4f1f-4e01-8d7f-9cd0a4a6613a|1465171459|
|2                                          |f4d99634-4f1f-4e01-8d7f-9cd0a4a6613a|1465171440|
|3                                          |f4d99634-4f1f-4e01-8d7f-9cd0a4a6613a|1464935509|
|4                                          |f4d99634-4f1f-4e01-8d7f-9cd0a4a6613a|1464935376|
|5                                          |f4d99634-4f1f-4e01-8d7f-9cd0a4a6613a|1464930080|


### RANK：ランキング（同率で番号を飛ばす）


```sql
SELECT val, RANK()OVER(ORDER BY val) AS rnk
FROM ( VALUES 1,1,2,3 ) AS t(val)
ORDER BY rnk ASC
```
|val                                        |rnk|
|-------------------------------------------|---|
|1                                          |1  |
|1                                          |1  |
|2                                          |3  |
|3                                          |4  |


#### 例：カテゴリごとの2011年度マンスリートップセールス5品目を取得する

```sql
WITH sales_table AS (
  SELECT category, sub_category, goods_id, SUM(price*amount) AS sales, TD_TIME_FORMAT(time, 'yyyy-MM-01', 'JST') AS d
  FROM sales_slip
  WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
  GROUP BY category, sub_category, goods_id, TD_TIME_FORMAT(time, 'yyyy-MM-01', 'JST')
)

SELECT d, rnk, category, sales, sub_category, goods_id
FROM
(
  SELECT 
    d, RANK() OVER (PARTITION BY d, category ORDER BY sales DESC) AS rnk, sales, category, sub_category, goods_id
  FROM sales_table
)
WHERE rnk<=5
ORDER BY category, d, rnk
```
|d                                          |rnk|category                 |sales |sub_category                    |goods_id|
|-------------------------------------------|---|-------------------------|------|--------------------------------|--------|
|2011-01-01                                 |1  |Automotive and Industrial|647020|Automotive Tools and Equipment  |470556  |
|2011-01-01                                 |2  |Automotive and Industrial|640679|Tires and Wheels                |468960  |
|2011-01-01                                 |3  |Automotive and Industrial|539167|Janitorial                      |475544  |
|2011-01-01                                 |4  |Automotive and Industrial|285524|Tires and Wheels                |477514  |
|2011-01-01                                 |5  |Automotive and Industrial|228348|Industrial Supplies             |469338  |
|2011-02-01                                 |1  |Automotive and Industrial|758096|Automotive Parts and Accessories|480895  |
|2011-02-01                                 |2  |Automotive and Industrial|321751|Automotive Parts and Accessories|481083  |
|2011-02-01                                 |3  |Automotive and Industrial|245344|Lab and Scientific              |480337  |
|2011-02-01                                 |4  |Automotive and Industrial|184801|Automotive Tools and Equipment  |481366  |
|2011-02-01                                 |5  |Automotive and Industrial|175812|Motorcycle and Powersports      |481275  |


#### DENSE_RANK：ランキング（同率で番号を飛ばさない）


```sql
SELECT val, DENSE_RANK()OVER(ORDER BY val) AS rnk
FROM ( VALUES 1,1,2,3 ) AS t(val)
ORDER BY rnk ASC
```
|val                                        |rnk|
|-------------------------------------------|---|
|1                                          |1  |
|1                                          |1  |
|2                                          |2  |
|3                                          |3  |


#### 例：カテゴリごとのマンスリートップセールス5品目を取得する


```sql
WITH sales_table AS
(
  SELECT category, sub_category, goods_id, SUM(price*amount) AS sales, TD_TIME_FORMAT(time, 'yyyy-MM-01', 'JST') AS d
  FROM sales_slip
  WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
  GROUP BY category, sub_category, goods_id, TD_TIME_FORMAT(time, 'yyyy-MM-01', 'JST')
)

SELECT d, rnk, category, sales, sub_category, goods_id
FROM
(
  SELECT 
    d, DENSE_RANK() OVER (PARTITION BY d, category ORDER BY sales DESC) AS rnk, sales, category, sub_category, goods_id
  FROM sales_table
)
WHERE rnk<=5
ORDER BY category, d, rnk
```
|d                                          |rnk|category                 |sales |sub_category                    |goods_id|
|-------------------------------------------|---|-------------------------|------|--------------------------------|--------|
|2011-01-01                                 |1  |Automotive and Industrial|647020|Automotive Tools and Equipment  |470556  |
|2011-01-01                                 |2  |Automotive and Industrial|640679|Tires and Wheels                |468960  |
|2011-01-01                                 |3  |Automotive and Industrial|539167|Janitorial                      |475544  |
|2011-01-01                                 |4  |Automotive and Industrial|285524|Tires and Wheels                |477514  |
|2011-01-01                                 |5  |Automotive and Industrial|228348|Industrial Supplies             |469338  |
|2011-02-01                                 |1  |Automotive and Industrial|758096|Automotive Parts and Accessories|480895  |
|2011-02-01                                 |2  |Automotive and Industrial|321751|Automotive Parts and Accessories|481083  |
|2011-02-01                                 |3  |Automotive and Industrial|245344|Lab and Scientific              |480337  |
|2011-02-01                                 |4  |Automotive and Industrial|184801|Automotive Tools and Equipment  |481366  |
|2011-02-01                                 |5  |Automotive and Industrial|175812|Motorcycle and Powersports      |481275  |

### PERCENT_RANK：ランキング（割合「(rank - 1) / (全行数 - 1)」で表示）


```sql
SELECT val, PERCENT_RANK()OVER(ORDER BY val) AS per_rnk
FROM ( VALUES 1,1,2,3 ) AS t(val)
ORDER BY per_rnk ASC
```
|val                                        |per_rnk|
|-------------------------------------------|-------|
|1                                          |0.0    |
|1                                          |0.0    |
|2                                          |0.6666666666666666|
|3                                          |1.0    |


#### 例：カテゴリごとにトップセールス10%に属する品目を取得する

```sql
WITH sales_table AS
(
  SELECT category, sub_category, goods_id, SUM(price*amount) AS sales, TD_TIME_FORMAT(time, 'yyyy-MM-01', 'JST') AS d
  FROM sales_slip
  WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
  GROUP BY category, sub_category, goods_id, TD_TIME_FORMAT(time, 'yyyy-MM-01', 'JST')
)

SELECT d, rnk, category, sales, sub_category, goods_id
FROM
(
  SELECT 
    d, PERCENT_RANK() OVER (PARTITION BY d, category ORDER BY sales DESC) AS rnk, sales, category, sub_category, goods_id
  FROM sales_table
)
WHERE rnk<=0.1
ORDER BY category, d, rnk
```
|d                                          |rnk|category                 |sales |sub_category                  |goods_id|
|-------------------------------------------|---|-------------------------|------|------------------------------|--------|
|2011-01-01                                 |0.0|Automotive and Industrial|647020|Automotive Tools and Equipment|470556  |
|2011-01-01                                 |0.001763668430335097|Automotive and Industrial|640679|Tires and Wheels              |468960  |
|2011-01-01                                 |0.003527336860670194|Automotive and Industrial|539167|Janitorial                    |475544  |


### CUME_DIST：ランキング（相対位置「(現在の行の位置) / (全行数)」で表示）


```sql
SELECT val, CUME_DIST()OVER(ORDER BY val) AS cume
FROM ( VALUES 1,1,2,3 ) AS t(val)
ORDER BY cume ASC
```
|val                                        |cume|
|-------------------------------------------|----|
|1                                          |0.5 |
|1                                          |0.5 |
|2                                          |0.75|
|3                                          |1.0 |


#### 例：カテゴリごとにトップセールス10%に属する品目を取得する

```sql
WITH sales_table AS
(
  SELECT category, sub_category, goods_id, SUM(price*amount) AS sales, TD_TIME_FORMAT(time, 'yyyy-MM-01', 'JST') AS d
  FROM sales_slip
  WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
  GROUP BY category, sub_category, goods_id, TD_TIME_FORMAT(time, 'yyyy-MM-01', 'JST')
)

SELECT d, rnk, category, sales, sub_category, goods_id
FROM
(
  SELECT 
    d, CUME_DIST() OVER (PARTITION BY d, category ORDER BY sales DESC) AS rnk, sales, category, sub_category, goods_id
  FROM sales_table
)
WHERE rnk<=0.1
ORDER BY category, d, rnk
```
|d                                          |rnk|category                 |sales |sub_category                  |goods_id|
|-------------------------------------------|---|-------------------------|------|------------------------------|--------|
|2011-01-01                                 |0.0017605633802816902|Automotive and Industrial|647020|Automotive Tools and Equipment|470556  |
|2011-01-01                                 |0.0035211267605633804|Automotive and Industrial|640679|Tires and Wheels              |468960  |
|2011-01-01                                 |0.00528169014084507|Automotive and Industrial|539167|Janitorial                    |475544  |


### NTILE(N)：ランキング（1..Nに分割）



```sql
SELECT val, NTILE(10)OVER(ORDER BY val) AS tile
FROM ( VALUES 1,1,2,3 ) AS t(val)
ORDER BY tile ASC
```
|val                                        |tile|
|-------------------------------------------|----|
|1                                          |1   |
|1                                          |2   |
|2                                          |3   |
|3                                          |4   |

```sql
SELECT val, NTILE(3)OVER(ORDER BY val) AS tile
FROM ( VALUES 1,2,3,4,5 ) AS t(val)
ORDER BY tile ASC
```
|val                                        |tile|
|-------------------------------------------|----|
|1                                          |1   |
|2                                          |1   |
|3                                          |2   |
|4                                          |2   |
|5                                          |3   |


#### 例：カテゴリごとのマンスリートップセールス100品目を取得し「1〜10位，11位〜20位，...，91位〜100位」という10品目ごとのバケットに分割する

```sql
WITH sales_table AS
(
  SELECT category, sub_category, goods_id, SUM(price*amount) AS sales, TD_TIME_FORMAT(time, 'yyyy-MM-01', 'JST') AS d
  FROM sales_slip
  WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
  GROUP BY category, sub_category, goods_id, TD_TIME_FORMAT(time, 'yyyy-MM-01', 'JST')
)

SELECT d, rnk, NTILE(10) OVER (PARTITION BY d, category ORDER BY rnk) AS bucket, category, sales, sub_category, goods_id
FROM
(
  SELECT 
    d, RANK() OVER (PARTITION BY d, category ORDER BY sales DESC) AS rnk, sales, category, sub_category, goods_id
  FROM sales_table
)
WHERE rnk <= 100
ORDER BY category, d, rnk, bucket
```
|d                                          |rnk|bucket|category                 |sales |sub_category                  |goods_id|
|-------------------------------------------|---|------|-------------------------|------|------------------------------|--------|
|2011-01-01                                 |1  |1     |Automotive and Industrial|647020|Automotive Tools and Equipment|470556  |
|2011-01-01                                 |2  |1     |Automotive and Industrial|640679|Tires and Wheels              |468960  |
|2011-01-01                                 |3  |1     |Automotive and Industrial|539167|Janitorial                    |475544  |


## 参照系



### LAG：n行前の値を返す



```sql
SELECT val, LAG(val,1)OVER(ORDER BY val) AS val_lag1
FROM ( VALUES 1,2,3,4,5 ) AS t(val)
ORDER BY val ASC
```
|val                                        |val_lag1|
|-------------------------------------------|--------|
|1                                          |NULL        |
|2                                          |1       |
|3                                          |2       |
|4                                          |3       |
|5                                          |4       |

#### 例：あるユーザーのアクセス日一覧に対して，前回のアクセス日を付与する

```sql
WITH access_table AS
(
  SELECT td_client_id, TD_TIME_FORMAT(time,'yyyy-MM-dd', 'JST') AS d
  FROM sample_accesslog
  WHERE td_client_id IN ('10e725fc-c17f-43e1-da24-a452ef19d2f5')
  GROUP BY td_client_id, TD_TIME_FORMAT(time,'yyyy-MM-dd', 'JST')
)

SELECT rnk, td_client_id, d, d_lag
FROM
(
  SELECT 
  td_client_id, d,
  LAG(d, 1) OVER (PARTITION BY td_client_id ORDER BY d) AS d_lag,
  ROW_NUMBER()OVER (PARTITION BY td_client_id ORDER BY d) AS rnk
  FROM access_table
)
ORDER BY td_client_id, rnk, d DESC, d_lag DESC
```
|rnk                                        |td_client_id|d         |d_lag     |
|-------------------------------------------|------------|----------|----------|
|1                                          |10e725fc-c17f-43e1-da24-a452ef19d2f5|2016-04-25| NULL         |
|2                                          |10e725fc-c17f-43e1-da24-a452ef19d2f5|2016-04-26|2016-04-25|
|3                                          |10e725fc-c17f-43e1-da24-a452ef19d2f5|2016-04-29|2016-04-26|




```sql
SELECT d, d_lag, COUNT(1) AS cnt
FROM
(
  SELECT 
  td_client_id, d,
  LAG(d, 1) OVER (PARTITION BY td_client_id ORDER BY d) AS d_lag
  FROM 
  (
    SELECT td_client_id, TD_TIME_FORMAT(time,'yyyy-MM-dd', 'JST') AS d
    FROM sample_accesslog
    GROUP BY td_client_id, TD_TIME_FORMAT(time,'yyyy-MM-dd', 'JST')
  ) t1
)
WHERE d = '2016-06-16' AND d_lag IS NOT NULL
GROUP BY d, d_lag
ORDER BY d DESC, d_lag DESC
```
|d                                          |d_lag|cnt       |
|-------------------------------------------|-----|----------|
|2016-06-16                                 |2016-06-15|52        |
|2016-06-16                                 |2016-06-14|12        |
|2016-06-16                                 |2016-06-13|15        |



### LEAD： n行後の値を返す


```sql
SELECT val, LEAD(val,1)OVER(ORDER BY val) AS val_lead1
FROM ( VALUES 1,2,3,4,5 ) AS t(val)
ORDER BY val ASC
```
|val                                        |val_lead1|
|-------------------------------------------|---------|
|1                                          |2        |
|2                                          |3        |
|3                                          |4        |
|4                                          |5        |
|5                                          |NULL     |


#### 例：ページの平均閲覧時間を求める

```sql
SELECT td_client_id,
  REGEXP_REPLACE(REGEXP_REPLACE(td_url, '\?(.)*',''), 'http(.)*://|/$','') AS td_url, time,
  LEAD(time) OVER (PARTITION BY td_client_id ORDER BY time) - time AS diff
FROM sample_accesslog
ORDER BY td_client_id, time
```
|td_client_id                               |td_url|time      |diff|
|-------------------------------------------|------|----------|----|
|000077fb-2c93-4cd7-d9d0-293866aaec31       |www.treasuredata.com/jp|1461454040|17  |
|000077fb-2c93-4cd7-d9d0-293866aaec31       |www.treasuredata.com/jp/about|1461454057|85  |
|000077fb-2c93-4cd7-d9d0-293866aaec31       |www.treasuredata.com/jp/careers|1461454142|24  |


```sql
SELECT td_client_id, td_url, time, diff
FROM
(
  SELECT td_client_id,
    REGEXP_REPLACE(REGEXP_REPLACE(td_url, '\?(.)*',''), 'http(.)*://|/$','') AS td_url, time,
    LEAD(time) OVER (PARTITION BY td_client_id ORDER BY time) - time AS diff
  FROM sample_accesslog
)
WHERE diff <= 60*30 AND diff IS NOT NULL
ORDER BY td_client_id, time
```
|td_client_id                               |td_url|time      |diff|
|-------------------------------------------|------|----------|----|
|000077fb-2c93-4cd7-d9d0-293866aaec31       |www.treasuredata.com/jp|1461454040|17  |
|000077fb-2c93-4cd7-d9d0-293866aaec31       |www.treasuredata.com/jp/about|1461454057|85  |
|000077fb-2c93-4cd7-d9d0-293866aaec31       |www.treasuredata.com/jp/careers|1461454142|24  |




```sql
SELECT td_url, AVG(diff) AS avg_diff, COUNT(1) AS cnt
FROM
(
  SELECT td_client_id,
    REGEXP_REPLACE(REGEXP_REPLACE(td_url, '\?(.)*',''), 'http(.)*://|/$','') AS td_url, time,
    LEAD(time) OVER (PARTITION BY td_client_id ORDER BY time) - time AS diff
  FROM sample_accesslog
)
WHERE diff <= 60*30 AND diff IS NOT NULL
GROUP BY td_url
HAVING 10 <= COUNT(1)
ORDER BY avg_diff DESC
```
|td_url                                     |avg_diff|cnt       |
|-------------------------------------------|--------|----------|
|www.treasuredata.com/jp/press_release/20151014_private_dmp_rightsegment_cyberagent|521.9090909090909|11        |
|www.treasuredata.com/jp/thank_you          |369.6969696969697|33        |
|192.168.33.10:3000/jp/inboundmarketing     |367.6666666666667|48        |


### FIRST_VALUE：最初の行の値を返す


```sql
SELECT val, FIRST_VALUE(val)OVER(ORDER BY val) AS val_first
FROM ( VALUES 1,2,3,4,5 ) AS t(val)
ORDER BY val ASC
```
|val                                        |val_first|
|-------------------------------------------|---------|
|1                                          |1        |
|2                                          |1        |
|3                                          |1        |
|4                                          |1        |
|5                                          |1        |


#### 例：マンスリーの各グッズの売上について，そのカテゴリでトップの売上額に対する割合を求める（各カテゴリ上位5件まで）

```sql
WITH sales_table AS
(
  SELECT 
    TD_TIME_FORMAT(time,'yyyy-MM-01','JST') AS m, category, sub_category, goods_id, SUM(price*amount) AS sales
  FROM  sales_slip
  WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
  GROUP BY TD_TIME_FORMAT(time,'yyyy-MM-01','JST') , category, sub_category, goods_id
)

SELECT m, category, rnk, goods_id, sales, best_goods_id, best_sales, 1.0*sales/best_sales AS ratio
FROM
(
  SELECT m, category, goods_id, sales, FIRST_VALUE(sales) OVER (PARTITION BY m,category ORDER BY sales DESC) as best_sales,
    FIRST_VALUE(goods_id) OVER (PARTITION BY m,category ORDER BY sales DESC) as best_goods_id,
    RANK() OVER (PARTITION BY m,category ORDER BY sales DESC) as rnk
  FROM sales_table
)
WHERE rnk <= 5
ORDER BY m, category, ratio DESC
```
|m                                          |category|rnk|goods_id|sales |best_goods_id|best_sales|ratio             |
|-------------------------------------------|--------|---|--------|------|-------------|----------|------------------|
|2011-01-01                                 |Automotive and Industrial|1  |470556  |647020|470556       |647020    |1.0               |
|2011-01-01                                 |Automotive and Industrial|2  |468960  |640679|470556       |647020    |0.9901996847083552|
|2011-01-01                                 |Automotive and Industrial|3  |475544  |539167|470556       |647020    |0.8333080893944546|

### LAST_VALUE：最後の行の値を返す

```sql
SELECT val, LAST_VALUE(val)OVER(ORDER BY val) AS val_last
FROM ( VALUES 1,2,3,4,5 ) AS t(val)
ORDER BY val ASC
```
|val                                        |val_last|
|-------------------------------------------|--------|
|1                                          |1       |
|2                                          |2       |
|3                                          |3       |
|4                                          |4       |
|5                                          |5       |



```sql
SELECT val, LAST_VALUE(val)OVER(ORDER BY val ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS val_last
FROM ( VALUES 1,2,3,4,5 ) AS t(val)
ORDER BY val ASC
```
|val                                        |val_last|
|-------------------------------------------|--------|
|1                                          |5       |
|2                                          |5       |
|3                                          |5       |
|4                                          |5       |
|5                                          |5       |


```sql
WITH sales_table AS
(
  SELECT 
    TD_TIME_FORMAT(time,'yyyy-MM-01','JST') AS m, category, sub_category, goods_id, SUM(price*amount) AS sales
  FROM  sales_slip
  WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
  GROUP BY TD_TIME_FORMAT(time,'yyyy-MM-01','JST') , category, sub_category, goods_id
)

SELECT m, category, rnk, goods_id, sales, best_goods_id, best_sales, 1.0*sales/best_sales AS ratio
FROM
(
  SELECT m, category, goods_id, sales, LAST_VALUE(sales) OVER (PARTITION BY m,category ORDER BY sales) as best_sales,
    LAST_VALUE(goods_id) OVER (PARTITION BY m,category ORDER BY sales) as best_goods_id,
    RANK() OVER (PARTITION BY m,category ORDER BY sales DESC) as rnk
  FROM sales_table
)
WHERE rnk <= 5
ORDER BY m, category, ratio DESC
```
|m                                          |category|rnk|goods_id|sales |best_goods_id|best_sales|ratio|
|-------------------------------------------|--------|---|--------|------|-------------|----------|-----|
|2011-01-01                                 |Automotive and Industrial|2  |468960  |640679|468960       |640679    |1.0  |
|2011-01-01                                 |Automotive and Industrial|1  |470556  |647020|470556       |647020    |1.0  |
|2011-01-01                                 |Automotive and Industrial|3  |475544  |539167|475544       |539167    |1.0  |



```sql
WITH sales_table AS
(
  SELECT 
    TD_TIME_FORMAT(time,'yyyy-MM-01','JST') AS m, category, sub_category, goods_id, SUM(price*amount) AS sales
  FROM  sales_slip
  WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
  GROUP BY TD_TIME_FORMAT(time,'yyyy-MM-01','JST') , category, sub_category, goods_id
)

SELECT m, category, rnk, goods_id, sales, best_goods_id, best_sales, 1.0*sales/best_sales AS ratio
FROM
(
  SELECT m, category, goods_id, sales, 
    LAST_VALUE(sales) OVER (PARTITION BY m,category ORDER BY sales ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as best_sales,
    LAST_VALUE(goods_id) OVER (PARTITION BY m,category ORDER BY sales ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as best_goods_id,
    RANK() OVER (PARTITION BY m,category ORDER BY sales DESC) as rnk
  FROM sales_table
)
WHERE rnk <= 5
ORDER BY m, category, ratio DESC
```
|m                                          |category|rnk|goods_id|sales |best_goods_id|best_sales|ratio|
|-------------------------------------------|--------|---|--------|------|-------------|----------|-----|
|2011-01-01                                 |Automotive and Industrial|1  |470556  |647020|470556       |647020    |1.0  |
|2011-01-01                                 |Automotive and Industrial|2  |468960  |640679|470556       |647020    |0.9901996847083552|
|2011-01-01                                 |Automotive and Industrial|3  |475544  |539167|470556       |647020    |0.8333080893944546|



### NTH_VALUE：n番目の行の値を返す


```sql
SELECT val, NTH_VALUE(val,3)OVER(ORDER BY val ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS val_nth
FROM ( VALUES 1,2,3,4,5 ) AS t(val)
ORDER BY val ASC
```
|val                                        |val_nth|
|-------------------------------------------|-------|
|1                                          |3      |
|2                                          |3      |
|3                                          |3      |
|4                                          |3      |
|5                                          |3      |


#### 例：マンスリーの各グッズの売上に関して，そのカテゴリでトップの売上額に対する割合を求める（各カテゴリ上位5件まで）

```sql
WITH sales_table AS
(
  SELECT 
    TD_TIME_FORMAT(time,'yyyy-MM-01','JST') AS m, category, sub_category, goods_id, SUM(price*amount) AS sales
  FROM  sales_slip
  WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
  GROUP BY TD_TIME_FORMAT(time,'yyyy-MM-01','JST') , category, sub_category, goods_id
)

SELECT m, category, rnk, goods_id, sales, best_goods_id, best_sales, 1.0*sales/best_sales AS ratio
FROM
(
  SELECT m, category, goods_id, sales, 
    NTH_VALUE(sales,1) OVER (PARTITION BY m,category ORDER BY sales DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as best_sales,
    NTH_VALUE(goods_id,1) OVER (PARTITION BY m,category ORDER BY sales DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as best_goods_id,
    RANK() OVER (PARTITION BY m,category ORDER BY sales DESC) as rnk
  FROM sales_table
)
WHERE rnk <= 5
ORDER BY m, category, ratio DESC
```
|m                                          |category|rnk|goods_id|sales |best_goods_id|best_sales|ratio             |
|-------------------------------------------|--------|---|--------|------|-------------|----------|------------------|
|2011-01-01                                 |Automotive and Industrial|1  |470556  |647020|470556       |647020    |1.0               |
|2011-01-01                                 |Automotive and Industrial|2  |468960  |640679|470556       |647020    |0.9901996847083552|
|2011-01-01                                 |Automotive and Industrial|3  |475544  |539167|470556       |647020    |0.8333080893944546|



## 集約関数系



### RUNNING SUM：はじめから現在までの累計和を求める ※この名前の関数はありません


```sql
SELECT val, SUM(val)OVER(ORDER BY val ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS run_sum --ROWSは省略可能
FROM ( VALUES 1,2,3,4,5 ) AS t(val)
ORDER BY val ASC
```
|val                                        |run_sum|
|-------------------------------------------|-------|
|1                                          |1      |
|2                                          |3      |
|3                                          |6      |
|4                                          |10     |
|5                                          |15     |



```sql
SELECT val, SUM(val)OVER(ORDER BY val ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS run_sum --ROWSは省略可能
FROM ( VALUES 1,2,2,2,5 ) AS t(val)
ORDER BY val ASC
```
|val                                        |run_sum|
|-------------------------------------------|-------|
|1                                          |1      |
|2                                          |3      |
|2                                          |5      |
|2                                          |7      |
|5                                          |12     |


```sql
SELECT val, SUM(val)OVER(ORDER BY val ASC ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) AS moving_avg
FROM ( VALUES 1,2,2,2,5 ) AS t(val)
ORDER BY val ASC
```
|val                                        |moving_avg|
|-------------------------------------------|----------|
|1                                          |1         |
|2                                          |3         |
|2                                          |5         |
|2                                          |7         |
|5                                          |11        |




#### 例：categoryごとに，各日の売上額と併せて月初から当日までの累計和を表示する

```sql
WITH sales_table AS
(
  SELECT 
    TD_TIME_FORMAT(time,'yyyy-MM-dd','JST') AS d, TD_TIME_FORMAT(time,'yyyy-MM-01','JST') AS m_from, category, SUM(price*amount) AS sales
  FROM  sales_slip
  WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
  GROUP BY TD_TIME_FORMAT(time,'yyyy-MM-dd','JST'), TD_TIME_FORMAT(time,'yyyy-MM-01','JST'), category
)

SELECT d, m_from, category, sales, 
  SUM(sales) OVER (PARTITION BY category,m_from ORDER BY d ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as sales_running_sum
FROM sales_table
ORDER BY category, d, m_from
```
|d                                          |m_from|category                 |sales |sales_running_sum|
|-------------------------------------------|------|-------------------------|------|-----------------|
|2011-01-01                                 |2011-01-01|Automotive and Industrial|136540|136540           |
|2011-01-02                                 |2011-01-01|Automotive and Industrial|264154|400694           |
|...                                        |      |                         |      |                 |
|2011-01-30                                 |2011-01-01|Automotive and Industrial|406599|12285233         |
|2011-01-31                                 |2011-01-01|Automotive and Industrial|249250|12534483         |
|2011-02-01                                 |2011-02-01|Automotive and Industrial|580275|580275           |
|2011-02-02                                 |2011-02-01|Automotive and Industrial|409995|990270           |




### MOVING AVERAGE：移動平均，nレコードの平均値を求める


```sql
SELECT val, AVG(val)OVER(ORDER BY val ASC ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) as moving_avg
FROM ( VALUES 1,2,3,4,5 ) AS t(val)
ORDER BY val ASC
```
|val                                        |moving_avg|
|-------------------------------------------|----------|
|1                                          |1.0       |
|2                                          |1.5       |
|3                                          |2.0       |
|4                                          |2.5       |
|5                                          |3.5       |


```SQL
SELECT val, AVG(val)OVER(ORDER BY val ASC ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) as moving_avg
FROM ( VALUES 1,2,2,2,5 ) AS t(val)
ORDER BY val ASC
```
|val                                        |moving_avg|
|-------------------------------------------|----------|
|1                                          |1.0       |
|2                                          |1.5       |
|2                                          |1.6666666666666667|
|2                                          |1.75      |
|5                                          |2.75      |


#### 例：cateogryごとに，各日の売上額と併せて直近5日間の移動平均を表示する
```sql
SELECT d, category, sales, AVG(sales) OVER (PARTITION BY category ORDER BY d ASC ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) as sales_moving_avg
FROM
(
  SELECT 
    TD_TIME_FORMAT(time,'yyyy-MM-dd','JST') AS d, category, SUM(price*amount) AS sales
  FROM  sales_slip
  WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
  GROUP BY TD_TIME_FORMAT(time,'yyyy-MM-dd','JST'), category
) t
ORDER BY category, d
```
|d                                          |category|sales |sales_moving_avg  |
|-------------------------------------------|--------|------|------------------|
|2011-01-01                                 |Automotive and Industrial|136540|136540.0          |
|2011-01-02                                 |Automotive and Industrial|264154|200347.0          |
|2011-01-03                                 |Automotive and Industrial|120338|173677.33333333334|
|2011-01-04                                 |Automotive and Industrial|283688|201180.0          |
|2011-01-05                                 |Automotive and Industrial|468996|254743.2          |




### LOCAL MAX，MIN：特定の区間での最大，最小を求める

```sql
SELECT val, MAX(val)OVER(ORDER BY val ASC) AS local_max
FROM ( VALUES 1,2,3,4,5 ) AS t(val)
ORDER BY val ASC
```
|val                                        |local_max|
|-------------------------------------------|---------|
|1                                          |1        |
|2                                          |2        |
|3                                          |3        |
|4                                          |4        |
|5                                          |5        |



```sql
SELECT val, MAX(val)OVER(ORDER BY val ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS val_max
FROM ( VALUES 1,2,3,4,5 ) AS t(val)
ORDER BY val ASC
```
|val                                        |val_max|
|-------------------------------------------|-------|
|1                                          |5      |
|2                                          |5      |
|3                                          |5      |
|4                                          |5      |
|5                                          |5      |


```sql
SELECT val, MAX(val)OVER() AS val_max
FROM ( VALUES 1,2,3,4,5 ) AS t(val)
ORDER BY val ASC
```
|val                                        |val_max|
|-------------------------------------------|-------|
|1                                          |5      |
|2                                          |5      |
|3                                          |5      |
|4                                          |5      |
|5                                          |5      |


#### 例： category ごとに，月間の最大売上額/最小売上額を各々のレコードに付与する
```sql
WITH sales_table AS
(
  SELECT 
    TD_TIME_FORMAT(time,'yyyy-MM-dd','JST') AS d, TD_TIME_FORMAT(time,'yyyy-MM-01','JST') AS m, category, SUM(price*amount) AS sales
  FROM  sales_slip
  WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
  GROUP BY TD_TIME_FORMAT(time,'yyyy-MM-dd','JST'), TD_TIME_FORMAT(time,'yyyy-MM-01','JST'), category
)

SELECT m, d, category, sales, 
  MAX(sales) OVER (PARTITION BY category, m) as max_sales,
  FIRST_VALUE(sales)OVER (PARTITION BY category, m ORDER BY sales DESC) as max_sales2,
  LAST_VALUE(sales)OVER (PARTITION BY category, m ORDER BY sales ASC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as max_sales3,
  MIN(sales) OVER (PARTITION BY category, m) as min_sales,
  FIRST_VALUE(sales)OVER (PARTITION BY category, m ORDER BY sales ASC) as min_sales2,
  LAST_VALUE(sales)OVER (PARTITION BY category, m ORDER BY sales DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as min_sales3
FROM sales_table
ORDER BY category, m, d, sales DESC
```
|m                                          |d  |category                 |sales |max_sales|max_sales2|max_sales3|min_sales|min_sales2|min_sales3|
|-------------------------------------------|---|-------------------------|------|---------|----------|----------|---------|----------|----------|
|2011-01-01                                 |2011-01-01|Automotive and Industrial|136540|813518   |813518    |813518    |120338   |120338    |120338    |
|2011-01-01                                 |2011-01-02|Automotive and Industrial|264154|813518   |813518    |813518    |120338   |120338    |120338    |
|2011-01-01                                 |2011-01-03|Automotive and Industrial|120338|813518   |813518    |813518    |120338   |120338    |120338    |
|...                                        |   |                         |      |         |          |          |         |          |          |
|2011-01-01                                 |2011-01-28|Automotive and Industrial|343872|813518   |813518    |813518    |120338   |120338    |120338    |
|2011-01-01                                 |2011-01-29|Automotive and Industrial|813518|813518   |813518    |813518    |120338   |120338    |120338    |


