# Lesson 04. 集約関数

## 集約関数一覧
|FIELD1    |FIELD2       |FIELD3     |
|----------|-------------|-----------|
|関数名       |概要           |Return Type|
|COUNT(*), COUNT(col), COUNT(expr),  COUNT(DISTINCT col)|(*)：NULLを含む行の合計数を返します  (1)：NULLを含む行の合計数を返します  (col)：colの値がNULLでない行の合計数を返します  (expr)：指定されている式の結果がNULLではない行の数を返します  (DISTINCT col)：NULLでないユニークな行の合計数を数えます|BIGINT     |
|SUM(col), SUM(expr), SUM(DISTINCT col)|(col)：グループ内の列の値の合計を返します  (expr)：指定されている式の結果がNULLか0ならば0が加算され，それ以外の数値ならばその値が加算されます  (DISTINCT col)：グループ内の列のユニークな値の合計を返します|DOUBLE     |
|AVG(col),  AVG(expr), AVG(DISTINCT col)|(col)：グループ内の列の値の平均を返します。値がNULLの場合はスキップされ，行数（分母）にも加えられません。  (expr)：指定されている式の結果がNULLの場合はスキップされ，行数（分母）にも加えられません。それ以外の数値ならその値が加算され，行数（分母）も1でカウントされます  (DISTINCT col)：グループ内の列のユニークな値の平均を返します|DOUBLE     |
|MIN(col)  |グループ内の列の最小値を返します|DOUBLE     |
|MAX(col)  |グループ内の列の最大値を返します|DOUBLE     |
|VARIANCE(col), VAR_POP(col)|グループ内の数値列の分散を返します|DOUBLE     |
|VAR_SAMP(col)|グループ内の数値列のサンプル分散（不偏分散）を返します|DOUBLE     |
|STDDEV_POP(col)|グループ内の数値列の標準偏差を返します|DOUBLE     |
|STDDEV_SAMP(col)|グループ内の数値列のサンプル標準偏差を返します|DOUBLE     |
|COVAR_POP(col1, col2)|グループ内の数値列のペアの母集団の共分散を返します|DOUBLE     |
|COVAR_SAMP(col1, col2)|グループ内の数値列のペアのサンプル共分散を返します|DOUBLE     |
|CORR(col1, col2|グループ内の数値列のペアの相関係数（Pearson係数）を返します|DOUBLE     |

## COUNTの挙動を理解する

```sql
SELECT a
FROM ( VALUES 0, 0, 1, 2, NULL, NULL ) AS t(a)
```
|a         |
|----------|
|0         |
|0         |
|1         |
|2         |
|NULL      |
|NULL      |


```sql
SELECT 
  COUNT(*)     AS cnt_aster, 
  COUNT(0)     AS cnt_0, 
  COUNT(1)     AS cnt_1, 
  COUNT(FALSE) AS cnt_false,
  COUNT(NULL)  AS cnt_null, 
  COUNT(a)     AS cnt_col,
  COUNT(IF(a=0,1,0))     AS cnt_if_0,
  COUNT(IF(a=0,1,NULL))  AS cnt_if_null,
  COUNT(IF(NULL,1,0))    AS cnt_if_null_0,
  COUNT(IF(NULL,1,NULL)) AS cnt_if_null_null
FROM ( VALUES 0, 0, 1, 2, NULL, NULL ) AS t(a)
```
|cnt_aster |cnt_0        |cnt_1      |cnt_false|cnt_null|cnt_col|cnt_if_0|cnt_if_null|cnt_if_null_0|cnt_if_null_null|
|----------|-------------|-----------|---------|--------|-------|--------|-----------|-------------|----------------|
|6         |6            |6          |6        |0       |4      |6       |2          |6            |0               |


## 単純なユーザー数のカウント [ COUNT * ]
以降ではサンプルデータをもとにしてCOUNTの例を見ていきます。

```sql
SELECT COUNT(1) AS cnt
FROM sales_slip
```
|cnt       |
|----------|
|5892348   |


## 「抽出」から「集計」へ

```sql
SELECT COUNT(member_id) AS cnt
FROM sales_slip
```
|cnt       |
|----------|
|4372170   |


```sql
SELECT COUNT(1) AS cnt
FROM sales_slip
WHERE member_id IS NOT NULL
```
|cnt       |
|----------|
|4372170   |


## カラムの値によるグループごとのCOUNT [ GROUP BY ]


```sql
SELECT member_id
FROM sales_slip
GROUP BY member_id
ORDER BY member_id
LIMIT 3
```
|member_id |
|----------|
|10000     |
|100006    |
|1000382   |


```sql
SELECT DISTINCT member_id
FROM sales_slip
ORDER BY member_id
LIMIT 3
```
|member_id |
|----------|
|10000     |
|100006    |
|1000382   |


```sql
SELECT member_id, COUNT(1) AS cnt
FROM sales_slip
GROUP BY member_id
ORDER BY cnt DESC
LIMIT 3
```
|member_id |cnt    |
|----------|-------|
|NULL      |1520178|
|949366    |547570 |
|2259091   |330460 |


```sql
SELECT member_id, category, COUNT(1) AS cnt
FROM sales_slip
GROUP BY member_id
ORDER BY cnt DESC
LIMIT 10
```


```sql
'category' must be an aggregate expression or appear in GROUP BY clause
```

```sql
SELECT member_id, category, COUNT(1) AS cnt
FROM sales_slip
GROUP BY member_id, category
ORDER BY cnt DESC
LIMIT 10
```
|member_id |category|cnt    |
|----------|--------|-------|
|NULL      |Automotive and Industrial|1520178|
|949366    |Beauty and Health and Grocery|547557 |
|2259091   |Automotive and Industrial|330459 |


## WHERE節で集計対象を予め絞り込む [ WHERE GROUP BY ]

```sql
SELECT member_id, category, COUNT(1) AS cnt
FROM sales_slip
WHERE member_id = '10000'
GROUP BY member_id, category
ORDER BY cnt DESC
```
|member_id |category|cnt    |
|----------|--------|-------|
|10000     |Home and Garden and Tools|85     |
|10000     |Sports and Outdoors|77     |
|10000     |Electronics and Computers|67     |


```sql
SELECT member_id, category, COUNT(1) AS cnt
FROM sales_slip
WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
GROUP BY member_id, category
ORDER BY cnt DESC
```
|member_id |category|cnt    |
|----------|--------|-------|
|NULL      |Automotive and Industrial|539750 |
|1833816   |Electronics and Computers|245    |
|1833816   |Home and Garden and Tools|199    |


```sql
SELECT member_id, category, COUNT(1) AS cnt
FROM sales_slip
WHERE 150 <= COUNT(1)  --エラー箇所！
AND TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
GROUP BY member_id, category
ORDER BY cnt DESC
LIMIT 10
```


```sql
SELECT member_id, category, cnt
FROM
(
  SELECT member_id, category, COUNT(1) AS cnt
  FROM sales_slip
  WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
  GROUP BY member_id, category
)
WHERE 150 <= cnt
ORDER BY cnt DESC
LIMIT 10
```
|member_id |category|cnt    |
|----------|--------|-------|
|NULL      |Automotive and Industrial|539750 |
|1833816   |Electronics and Computers|245    |
|1833816   |Home and Garden and Tools|199    |


```sql
SELECT member_id, category, cnt
FROM
(
  SELECT member_id, category, COUNT(1) AS cnt
  FROM sales_slip
  WHERE member_id IS NOT NULL
  AND TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
  GROUP BY member_id, category
)
WHERE 150 <= cnt
ORDER BY cnt DESC
LIMIT 10
```
|member_id |category|cnt    |
|----------|--------|-------|
|1833816   |Electronics and Computers|245    |
|1833816   |Home and Garden and Tools|199    |
|949366    |Beauty and Health and Grocery|178    |


## HAVING節による集計値の条件でさらに絞り込む [ GROUP BY HAVING ]


```sql
SELECT member_id, category, COUNT(1) AS cnt
FROM sales_slip
WHERE member_id IS NOT NULL
AND TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
GROUP BY member_id, category
HAVING 150 <= COUNT(1)
ORDER BY cnt DESC
LIMIT 10
```
|member_id |category|cnt    |
|----------|--------|-------|
|1833816   |Electronics and Computers|245    |
|1833816   |Home and Garden and Tools|199    |
|949366    |Beauty and Health and Grocery|178    |


## SUMによる値の合計

```sql
SELECT 
  COUNT(1) AS cnt, 
  COUNT(member_id) AS cnt_omit_null, 
  SUM(amount) AS total_amount
FROM sales_slip
WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
```
|cnt       |cnt_omit_null|total_amount|
|----------|-------------|------------|
|1031573   |491823       |1093191     |


```sql
SELECT 
  COUNT(1) AS cnt,
  COUNT(member_id) AS cnt_omit_null, 
  SUM(amount) AS total_amount
FROM sales_slip
WHERE member_id IS NOT NULL
AND TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
```
|cnt       |cnt_omit_null|total_amount|
|----------|-------------|------------|
|491823    |491823       |553439      |


```sql
SELECT COUNT(1) AS cnt, SUM(amount * price) AS total_sales
FROM sales_slip
WHERE member_id IS NOT NULL
AND TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
```
|cnt       |total_sales|
|----------|-----------|
|491823    |1473754425 |


```sql
SELECT member_id, COUNT(1) AS cnt, 
  SUM(amount) AS total_amount,
  SUM(amount * price) AS total_sales
FROM sales_slip
WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
GROUP BY member_id
ORDER BY total_sales DESC
LIMIT 10
```
|member_id |cnt    |total_amount|total_sales|
|----------|-------|------------|-----------|
|NULL      |539750 |539752      |161925600  |
|1385684   |803    |1009        |9265322    |
|1111523   |38     |38          |5916546    |


```sql
SELECT member_id, 
  COUNT(1)                          AS cnt, 
  SUM(amount)                       AS total_amount,
  SUM(amount * price)               AS total_sales,
  SUM(amount * price) / COUNT(1)    AS avg_sales_per_cnt,
  SUM(amount * price) / SUM(amount) AS avg_sales_per_amount
FROM sales_slip
WHERE member_id IS NOT NULL
AND TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
GROUP BY member_id
HAVING 0 < SUM(amount)
ORDER BY total_sales DESC
LIMIT 10
```
|member_id |cnt    |total_amount|total_sales|avg_sales_per_cnt|avg_sales_per_amount|
|----------|-------|------------|-----------|-----------------|--------------------|
|1385684   |803    |1009        |9265322    |11538            |9182                |
|1111523   |38     |38          |5916546    |155698           |155698              |
|1916325   |681    |1235        |4840029    |7107             |3919                |


```sql
  SUM(amount * price) / COUNT(1)    AS avg_sales_per_cnt,
  SUM(amount * price) / SUM(amount) AS avg_sales_per_amount
```

```sql
  total_sales / cnt          AS avg_sales_per_cnt,
  total_sales / total_amount AS avg_sales_per_amount
```


```sql
SELECT member_id, cnt, total_amount, total_sales, 
  total_sales / cnt          AS avg_sales_per_cnt,
  total_sales / total_amount AS avg_sales_per_amount
FROM
(
  SELECT member_id,
    COUNT(1)            AS cnt, 
    SUM(amount)         AS total_amount,
    SUM(amount * price) AS total_sales
  FROM sales_slip
  WHERE member_id IS NOT NULL
  AND TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
  GROUP BY member_id
  HAVING 0 < SUM(amount)
)
ORDER BY total_sales DESC
LIMIT 10
```
|member_id |cnt    |total_amount|total_sales|avg_sales_per_cnt|avg_sales_per_amount|
|----------|-------|------------|-----------|-----------------|--------------------|
|1385684   |803    |1009        |9265322    |11538            |9182                |
|1111523   |38     |38          |5916546    |155698           |155698              |
|1916325   |681    |1235        |4840029    |7107             |3919                |


## AVGによる値の平均は注意深く


```sql
SELECT AVG(a) AS avg1
FROM ( VALUES 1, 1, 1, 1, 0, 0 ) AS t(a)
```
|avg1      |
|----------|
|0.6666666666666666|


```sql
SELECT AVG(a) AS avg2
FROM ( VALUES 1, 1, 1, 1, NULL, NULL ) AS t(a)
```
|avg2      |
|----------|
|1.0       |


```sql
SELECT AVG( COALESCE(a, 0) ) AS avg3
FROM ( VALUES 1, 1, 1, 1, NULL, NULL ) AS t(a)
```
|avg3      |
|----------|
|0.6666666666666666|


```sql
SELECT
  COUNT(1)                             AS cnt, 
  1.0* SUM(amount) / COUNT(1)          AS avg_amount1,
  AVG(amount)                          AS avg_amount2,
  1.0 * SUM(amount * price) / COUNT(1) AS avg_sales_per_cnt1,
  AVG(amount * price)                  AS avg_sales_per_cnt2
FROM sales_slip
WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
```
|cnt       |avg_amount1       |avg_amount2       |avg_sales_per_cnt1|avg_sales_per_cnt2|
|----------|------------------|------------------|------------------|------------------|
|1031573   |1.0597320790675988|1.0597320790675988|1585.6173290692952|1585.6173290692952|


```sql
SELECT
  COUNT(1)            AS cnt, 
  AVG(amount)         AS avg_amount3,
  AVG(amount * price) AS avg_sales_per_cnt3
FROM sales_slip
WHERE member_id IS NOT NULL
AND TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
```
|cnt       |avg_amount3       |avg_sales_per_cnt3|
|----------|------------------|------------------|
|491823    |1.1252808429048662|2996.5138372951246|


```sql
SELECT member_id, 
  COUNT(1)                             AS cnt, 
  1.0 * SUM(amount) / COUNT(1)         AS avg_amount1,
  AVG(amount)                          AS avg_amount2,
  1.0 * SUM(amount * price) / COUNT(1) AS avg_sales_per_cnt1,
  AVG(amount * price)                  AS avg_sales_per_cnt2
FROM sales_slip
WHERE member_id IS NOT NULL
AND TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
GROUP BY member_id
LIMIT 10
```
|member_id |cnt               |avg_amount1       |avg_amount2       |avg_sales_per_cnt1|avg_sales_per_cnt2|
|----------|------------------|------------------|------------------|------------------|------------------|
|487511    |53                |1.0943396226415094|1.0943396226415094|1900.1509433962265|1900.1509433962265|
|680660    |41                |1.048780487804878 |1.048780487804878 |1913.7317073170732|1913.7317073170732|
|860536    |144               |1.0486111111111112|1.0486111111111112|4146.208333333333 |4146.208333333333 |


## 時間をGROUP BYで扱う


```sql
SELECT 
  TD_TIME_FORMAT(time, 'yyyy-MM-dd', 'JST') AS d,
  SUM(amount * price) AS total_sales
FROM sales_slip
WHERE member_id IS NOT NULL
AND TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
GROUP BY TD_TIME_FORMAT(time, 'yyyy-MM-dd', 'JST')
ORDER BY d DESC
LIMIT 10
```
|d         |total_sales       |
|----------|------------------|
|2011-12-31|2443847           |
|2011-12-30|2053735           |
|2011-12-29|1378928           |


```sql
SELECT 
  TD_TIME_FORMAT(time, 'yyyy-MM-01', 'JST') AS d,
  category,
  SUM(amount * price) AS total_sales
FROM sales_slip
WHERE member_id IS NOT NULL
AND TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
GROUP BY TD_TIME_FORMAT(time, 'yyyy-MM-01', 'JST'), category
ORDER BY d DESC, category
LIMIT 10
```
|d         |category          |total_sales|
|----------|------------------|-----------|
|2011-12-01|Automotive and Industrial|13063147   |
|2011-12-01|Beauty and Health and Grocery|14239962   |
|2011-12-01|Books and Audible |7475593    |


## MAX，MINを扱う集計


```sql
SELECT 
  MAX(price) AS max_price, 
  MIN(price) AS min_price, 
  MAX_BY(goods_id, price) AS goods_id_max_price, 
  MIN_BY(goods_id, price) AS goods_id_min_price
FROM sales_slip
WHERE member_id IS NOT NULL
AND TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
```
|max_price |min_price         |goods_id_max_price|goods_id_min_price|
|----------|------------------|------------------|------------------|
|379048    |1                 |469815            |508703            |


```sql
SELECT DISTINCT category, sub_category, goods_id, price
FROM sales_slip
WHERE goods_id IN ('514206','508703')
AND TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
```
|category  |sub_category      |goods_id|price |
|----------|------------------|--------|------|
|Clothing and Shoes and Jewelry|Baby              |508703  |1     |
|Electronics and Computers|Computer Accessories and Peripherals|514206  |379048|


```sql
SELECT DISTINCT category, sub_category, goods_id, price
FROM sales_slip
WHERE goods_id IN (514206,508703)
AND TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
```


```sql
SELECT member_id,
  MAX(price) AS max_price, 
  MIN(price) AS min_price, 
  MAX_BY(goods_id, price) AS goods_id_max_price,
  MIN_BY(goods_id, price) AS goods_id_min_price
FROM sales_slip
WHERE member_id IS NOT NULL
AND TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
GROUP BY member_id
ORDER BY max_price DESC
LIMIT 10
```
|member_id |max_price         |min_price|goods_id_max_price|goods_id_min_price|
|----------|------------------|---------|------------------|------------------|
|337826    |379048            |665      |532489            |525950            |
|1385684   |379048            |96       |522981            |488745            |
|1111523   |379048            |934      |500087            |512968            |


```sql
SELECT member_id,
  TD_TIME_FORMAT(MAX(time), 'yyyy-MM-dd', 'JST') AS last_access, 
  TD_TIME_FORMAT(MIN(time), 'yyyy-MM-dd', 'JST') AS first_access, 
  MAX_BY(goods_id, time) AS goods_id_last_access, 
  MIN_BY(goods_id, time) AS goods_id_first_access,
  MAX_BY(price, time) AS price_last_access, 
  MIN_BY(price, time) AS price_first_access
FROM sales_slip
WHERE member_id IS NOT NULL
AND TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
GROUP BY member_id
ORDER BY last_access DESC
LIMIT 10
```
|member_id |last_access       |first_access|goods_id_last_access|goods_id_first_access|price_last_access|price_first_access|
|----------|------------------|------------|--------------------|---------------------|-----------------|------------------|
|1125245   |2011-12-31        |2011-04-06  |550495              |491404               |2839             |2553              |
|1199431   |2011-12-31        |2011-01-18  |549802              |471821               |1990             |934               |
|1458016   |2011-12-31        |2011-01-12  |550166              |471045               |952              |2860              |


## 最頻値


```sql
SELECT MAX_BY(price, cnt) AS mode, MAX(cnt) AS mode_frequency
FROM
(
  SELECT price, COUNT(1) AS cnt
  FROM sales_slip
  WHERE member_id IS NOT NULL
  AND TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
  GROUP BY price
)
```
|mode|mode_frequency|
|----|--------------|
|2839|48232         |



```sql
SELECT MAX_BY(price, amount) AS mode, MAX(amount) AS mode_frequency
FROM
(
  SELECT price, SUM(amount) AS amount
  FROM sales_slip
  WHERE member_id IS NOT NULL
  AND TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
  GROUP BY price
)
```
|mode|mode_frequency|
|----|--------------|
|2839|51319         |



```sql
SELECT MAX_BY(goods_id, amount) AS mode_goods_id, MAX(amount) AS mode_frequency
FROM
(
  SELECT goods_id, SUM(amount) AS amount
  FROM sales_slip
  WHERE member_id IS NOT NULL
  AND TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
  GROUP BY goods_id
)
```
|mode_goods_id|mode_frequency|
|-------------|--------------|
|488745       |7059          |



```sql
SELECT member_id, MAX_BY(goods_id, amount) AS mode_goods_id, MAX(amount) AS mode_frequency
FROM
(
  SELECT member_id, goods_id, SUM(amount) AS amount
  FROM sales_slip
  WHERE member_id IS NOT NULL
  AND TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
  GROUP BY member_id, goods_id
)
GROUP BY member_id
ORDER BY mode_frequency DESC
LIMIT 10
```
|member_id|mode_goods_id|mode_frequency|
|---------|-------------|--------------|
|7113     |488745       |338           |
|1500132  |109601       |224           |
|1348     |488745       |199           |


## BOOL_AND，BOOL_MIN


```sql
SELECT member_id, is_canceled_any, is_canceled_every
FROM
(
  SELECT member_id, 
    BOOL_OR( IF(is_canceled=1,TRUE,FALSE)) AS is_canceled_any,
    BOOL_AND(IF(is_canceled=1,TRUE,FALSE)) AS is_canceled_every
  FROM sales_slip
  WHERE member_id IS NOT NULL
  GROUP BY member_id
  HAVING BOOL_OR(IF(is_canceled=1,TRUE,FALSE)) --=TRUE
)
ORDER BY is_canceled_every DESC, is_canceled_any
```
|member_id|is_canceled_any|is_canceled_every|
|---------|---------------|-----------------|
|949366   |true           |true             |
|2259091  |true           |true             |
|323685   |true           |false            |



```sql
SELECT member_id,
  1.0 * COUNT(IF(is_canceled=1,1,NULL)) / COUNT(1) AS cancel_ratio
FROM sales_slip
WHERE member_id IN ('2259091','949366','323685')
GROUP BY member_id
ORDER BY cancel_ratio DESC
```
|member_id|cancel_ratio|
|---------|------------|
|949366   |1.0         |
|2259091  |1.0         |
|323685   |0.007722007722007722|



## 中央値，パーセンタイル（近似）


```sql
SELECT
  MAX(price) AS max_price,
  approx_percentile(price, 1)    AS max_price2,
  approx_percentile(price, 0.75) AS per75_price,
  approx_percentile(price, 0.50) AS median,
  approx_percentile(price, 0.25) AS per25_price,
  approx_percentile(price, 0)    AS min_price2,
  MIN(price) AS min_price
FROM sales_slip
WHERE member_id IS NOT NULL
AND TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
```
|max_price|max_price2|per75_price |median|per25_price|min_price2|min_price|
|---------|----------|------------|------|-----------|----------|---------|
|379048   |379048    |2980        |2000  |1124       |15        |1        |


