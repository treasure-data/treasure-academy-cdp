# Lesson 15. ヒストグラム

## ヒストグラムと他のチャートとの違い





## シンプルなHISTOGRAM


```sql
WITH sample AS (
  SELECT val
  FROM ( VALUES 1,2,2,3,3,3,4,4,4,4,5,5,5,5,5,6,6,6,6,7,7,7,8,8,9 ) AS t(val)
),
histo AS (
  SELECT HISTOGRAM(val) AS res_map
  FROM sample
)

SELECT val, freq
FROM histo
CROSS JOIN UNNEST (
  res_map
) t2 (val, freq)
```
|val|freq|
|---|----|
|1  |1   |
|2  |2   |
|3  |3   |
|4  |4   |
|5  |5   |
|6  |4   |
|7  |3   |
|8  |2   |
|9  |1   |



## 欠損値の補完

```sql
WITH sample AS (
  SELECT val
  FROM ( VALUES 2,2,3,3,3,5,5,5,5,5,6,6,6,6,9 ) AS t(val)
),
histo AS (
  SELECT HISTOGRAM(val) AS res_map
  FROM sample
)

SELECT val, freq
FROM histo
CROSS JOIN UNNEST (
  res_map
) t2 (val, freq)
```
|val|freq|
|---|----|
|2  |2   |
|3  |3   |
|5  |5   |
|6  |4   |
|9  |1   |



```sql
WITH sample AS (
  SELECT val
  FROM ( VALUES 2,2,3,3,3,5,5,5,5,5,6,6,6,6,9 ) AS t(val)
)

SELECT time AS val
FROM serial_numbers
WHERE time < (SELECT MAX(val) FROM sample)
AND time NOT IN (SELECT val FROM sample)
```
|val|
|---|
|1  |
|4  |
|7  |
|8  |




```sql
WITH sample AS (
  SELECT val
  FROM ( VALUES 2,2,3,3,3,5,5,5,5,5,6,6,6,6,9 ) AS t(val)
),
histo AS (
  SELECT HISTOGRAM(val) AS res_map
  FROM sample
)

SELECT val, freq
FROM histo
CROSS JOIN UNNEST (
  res_map
) t2 (val, freq)

UNION ALL
SELECT time AS val, 0 AS freq
FROM serial_numbers
WHERE time < (SELECT MAX(val) FROM sample)
AND time NOT IN (SELECT val FROM sample)

ORDER BY val
```
|val|freq|
|---|----|
|1  |0   |
|2  |2   |
|3  |3   |
|4  |0   |
|5  |5   |
|6  |4   |
|7  |0   |
|8  |0   |
|9  |1   |




### 年間購買分布

```sql
with sales_table AS
(
  SELECT member_id, SUM(price*amount) AS sales
  FROM sales_slip
  WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
  GROUP BY member_id
  HAVING SUM(price*amount) <= 1000000
),
histo AS
(
  SELECT HISTOGRAM(sales) AS res_map
  FROM sales_table
)

SELECT val, freq
FROM histo
CROSS JOIN UNNEST (
  res_map
) t2 (val, freq)
UNION ALL
SELECT time AS val, 0 AS freq
FROM serial_numbers
WHERE time < (SELECT MAX(sales) FROM sales_table)
AND time NOT IN (SELECT sales FROM sales_table)
ORDER BY val
```
|val|freq|
|---|----|
|1  |0   |
|2  |0   |
|3  |0   |



```sql
with sales_table AS
(
  SELECT member_id, SUM(price*amount) AS sales
  FROM sales_slip
  WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
  GROUP BY member_id
  HAVING SUM(price*amount) <= 1000000
),
histo AS
(
  SELECT HISTOGRAM(sales) AS res_map
  FROM sales_table
),
freq_table AS
(
  SELECT val, freq
  FROM histo
  CROSS JOIN UNNEST (
    res_map
  ) t2 (val, freq)

  UNION ALL
  SELECT time AS val, 0 AS freq
  FROM serial_numbers
  WHERE time < (SELECT MAX(sales) FROM sales_table)
  AND time NOT IN (SELECT sales FROM sales_table)
)

SELECT   (val/10000+1)*10000 AS val, SUM(freq) AS freq
FROM freq_table
GROUP BY (val/10000+1)*10000
ORDER BY val
```
|val|freq|
|---|----|
|10000|209 |
|20000|254 |
|30000|281 |
|...|    |
|980000|3   |
|990000|2   |
|1000000|3   |


## WIDTH_BUCKETによるヒストグラム



```sql
WITH sample AS (
  SELECT val
  FROM ( VALUES 1,2,2,3,3,3,4,4,4,4,5,5,5,5,5,6,6,6,6,7,7,7,8,8,9 ) AS t(val)
)

SELECT val, bucket, 
  IF(bucket=6, INFINITY(), 2+1.0*(8-2)/5*bucket) AS upper_val,
  freq
FROM
(
  SELECT val, WIDTH_BUCKET(val,2,8,5) AS bucket, COUNT(1) AS freq
FROM sample
GROUP BY val, WIDTH_BUCKET(val,2,8,5)
)
ORDER BY val
```
|val|bucket|upper_val|freq|
|---|------|---------|----|
|1  |0     |2.0      |1   |
|2  |1     |3.2      |2   |
|3  |1     |3.2      |3   |
|4  |2     |4.4      |4   |
|5  |3     |5.6      |5   |
|6  |4     |6.8      |4   |
|7  |5     |8.0      |3   |
|8  |6     |Infinity |2   |
|9  |6     |Infinity |1   |



```sql
WITH sample AS (
  SELECT val
  FROM ( VALUES 1,2,2,3,3,3,7,7,7,8,8,9 ) AS t(val)
)

SELECT val, bucket, 
  IF(bucket=6, INFINITY(), 2+1.0*(8-2)/5*bucket) AS upper_val, 
  freq
FROM
(
  SELECT val, WIDTH_BUCKET(val,2,8,5) AS bucket, COUNT(1) AS freq
FROM sample
GROUP BY val, WIDTH_BUCKET(val,2,8,5)
)
ORDER BY val
```
|val|bucket|upper_val|freq|
|---|------|---------|----|
|1  |0     |2.0      |1   |
|2  |1     |3.2      |2   |
|3  |1     |3.2      |3   |
|7  |5     |8.0      |3   |
|8  |6     |Infinity |2   |
|9  |6     |Infinity |1   |




```sql
WITH sample AS (
  SELECT val
  FROM ( VALUES 1,2,2,3,3,3,7,7,7,8,8,9 ) AS t(val)
),
bucket_table AS
(
  SELECT val, WIDTH_BUCKET(val,2,8,5) AS bucket, COUNT(1) AS freq
  FROM sample
  GROUP BY val, WIDTH_BUCKET(val,2,8,5)
)

SELECT val, bucket, 
  IF(bucket=0,-INFINITY(), 2+1.0*(8-2)/5*(bucket-1)) AS lower_val,
  IF(bucket=6, INFINITY(), 2+1.0*(8-2)/5*bucket)     AS upper_val,
  freq
FROM
(
  SELECT val, bucket, freq
  FROM bucket_table

  UNION ALL
  SELECT NULL AS val, time AS bucket, 0 AS freq
  FROM serial_numbers
  WHERE time < (SELECT MAX(bucket) FROM bucket_table)
  AND time NOT IN (SELECT bucket FROM bucket_table)
)
ORDER BY bucket, val
```
|val|bucket|lower_val|upper_val|freq|
|---|------|---------|---------|----|
|1  |0     |-Infinity|2.0      |1   |
|2  |1     |2.0      |3.2      |2   |
|3  |1     |2.0      |3.2      |3   |
|NULL|2     |3.2      |4.4      |0   |
|NULL|3     |4.4      |5.6      |0   |
|NULL|4     |5.6      |6.8      |0   |
|7  |5     |6.8      |8.0      |3   |
|8  |6     |8.0      |Infinity |2   |
|9  |6     |8.0      |Infinity |1   |




```sql
WITH sample AS (
  SELECT val
  FROM ( VALUES 1,2,2,3,3,3,7,7,7,8,8,9 ) AS t(val)
),
bucket_table AS
(
  SELECT val, WIDTH_BUCKET(val,2,8,5) AS bucket, COUNT(1) AS freq
  FROM sample
  GROUP BY val, WIDTH_BUCKET(val,2,8,5)
),
range_bucket_table AS
(
  SELECT val, bucket, 
    IF(bucket=0,-INFINITY(),2+1.0*(8-2)/5*(bucket-1)) AS lower_val,
    IF(bucket=6, INFINITY(),2+1.0*(8-2)/5*bucket) AS upper_val,
    freq
  FROM
  (
    SELECT val, bucket, freq
    FROM bucket_table

    UNION ALL
    SELECT NULL AS val, time AS bucket, 0 AS freq
    FROM serial_numbers
    WHERE time < (SELECT MAX(bucket) FROM bucket_table)
    AND time NOT IN (SELECT bucket FROM bucket_table)
  )
)

SELECT bucket,
  CONCAT('[',CAST(ROUND(lower_val,1) AS VARCHAR),',',CAST(ROUND(upper_val,1) AS VARCHAR),')') AS range, 
  SUM(freq) AS freq
FROM range_bucket_table
GROUP BY bucket, CONCAT('[',CAST(ROUND(lower_val,1) AS VARCHAR),',',CAST(ROUND(upper_val,1) AS VARCHAR),')')
ORDER BY bucket
```
|bucket|range|freq    |
|------|-----|--------|
|0     |[-Infinity,2.0)|1       |
|1     |[2.0,3.2)|5       |
|2     |[3.2,4.4)|0       |
|3     |[4.4,5.6)|0       |
|4     |[5.6,6.8)|0       |
|5     |[6.8,8.0)|3       |
|6     |[8.0,Infinity)|3       |


## 最大／最小を両端に指定したヒストグラムテンプレートクエリ（binの数nのみ指定）


```sql
WITH sample AS (
  SELECT val
  FROM ( VALUES 1,2,2,3,3,3,7,7,7,8,8,9 ) AS t(val)
),
stat AS
 (
  SELECT MIN(val) AS mn, MAX(val)+1 AS mx, 5 AS n --WIDTH_BUCKET(mn=1,mx=10,n=5)
  FROM sample
),
bucket_table AS
(
  SELECT val, WIDTH_BUCKET(val,mn,mx,n) AS bucket, COUNT(1) AS freq
  FROM sample,stat
  GROUP BY val, WIDTH_BUCKET(val,mn,mx,n)
),
range_bucket_table AS
(
  SELECT val, bucket, 
    IF(bucket=0,  -INFINITY(),mn+1.0*(mx-mn)/n*(bucket-1)) AS lower_val,
    IF(bucket=n+1, INFINITY(),mn+1.0*(mx-mn)/n*bucket)     AS upper_val,
    freq
  FROM
  (
    SELECT val, bucket, freq
    FROM bucket_table

    UNION ALL
    SELECT NULL AS val, time AS bucket, 0 AS freq
    FROM serial_numbers
    WHERE time < (SELECT MAX(bucket) FROM bucket_table)
    AND time NOT IN (SELECT bucket FROM bucket_table)
  ), stat
)

SELECT bucket,
  CONCAT('[',CAST(ROUND(lower_val,1) AS VARCHAR),',',CAST(ROUND(upper_val,1) AS VARCHAR),')') AS range, 
  SUM(freq) AS freq
FROM range_bucket_table
GROUP BY bucket, CONCAT('[',CAST(ROUND(lower_val,1) AS VARCHAR),',',CAST(ROUND(upper_val,1) AS VARCHAR),')')
ORDER BY bucket
```
|bucket|range|freq    |
|------|-----|--------|
|1     |[1.0,2.8)|3       |
|2     |[2.8,4.6)|3       |
|3     |[4.6,6.4)|0       |
|4     |[6.4,8.2)|5       |
|5     |[8.2,10.0)|1       |


binの数を変えてみます。先程より少ない数（n = 3）を設定してみます。

```sql
WITH sample AS (
  SELECT val
  FROM ( VALUES 1,2,2,3,3,3,7,7,7,8,8,9 ) AS t(val)
),
stat AS
 (
  SELECT MIN(val) AS mn, MAX(val)+1 AS mx, 3 AS n --WIDTH_BUCKET(mn=1,mx=10,n=3)
  FROM sample
),
bucket_table AS
(
  SELECT val, WIDTH_BUCKET(val,mn,mx,n) AS bucket, COUNT(1) AS freq
  FROM sample,stat
  GROUP BY val, WIDTH_BUCKET(val,mn,mx,n)
),
range_bucket_table AS
(
  SELECT val, bucket, 
    IF(bucket=0,  -INFINITY(),mn+1.0*(mx-mn)/n*(bucket-1)) AS lower_val,
    IF(bucket=n+1, INFINITY(),mn+1.0*(mx-mn)/n*bucket)     AS upper_val,
    freq
  FROM
  (
    SELECT val, bucket, freq
    FROM bucket_table

    UNION ALL
    SELECT NULL AS val, time AS bucket, 0 AS freq
    FROM serial_numbers
    WHERE time < (SELECT MAX(bucket) FROM bucket_table)
    AND time NOT IN (SELECT bucket FROM bucket_table)
  ), stat
)

SELECT bucket,
  CONCAT('[',CAST(ROUND(lower_val,1) AS VARCHAR),',',CAST(ROUND(upper_val,1) AS VARCHAR),')') AS range, 
  SUM(freq) AS freq
FROM range_bucket_table
GROUP BY bucket, CONCAT('[',CAST(ROUND(lower_val,1) AS VARCHAR),',',CAST(ROUND(upper_val,1) AS VARCHAR),')')
ORDER BY bucket
```
|bucket|range|freq    |
|------|-----|--------|
|1     |[1.0,4.0)|6       |
|2     |[4.0,7.0)|0       |
|3     |[7.0,10.0)|6       |


次は，binの数nを増やし，9（取りうる値の最大値）としてみます。レコードが取りうる整数値の1つひとつが区間になった状態です。それ以上のnを指定すると，区間が1以下となり，無駄が増えてしまいます。

```sql
WITH sample AS (
  SELECT val
  FROM ( VALUES 1,2,2,3,3,3,7,7,7,8,8,9 ) AS t(val)
),
stat AS
 (
  SELECT MIN(val) AS mn, MAX(val)+1 AS mx, 9 AS n --WIDTH_BUCKET(mn=1,mx=10,n=9)
  FROM sample
),
bucket_table AS
(
  SELECT val, WIDTH_BUCKET(val,mn,mx,n) AS bucket, COUNT(1) AS freq
  FROM sample,stat
  GROUP BY val, WIDTH_BUCKET(val,mn,mx,n)
),
range_bucket_table AS
(
  SELECT val, bucket, 
    IF(bucket=0,  -INFINITY(),mn+1.0*(mx-mn)/n*(bucket-1)) AS lower_val,
    IF(bucket=n+1, INFINITY(),mn+1.0*(mx-mn)/n*bucket)     AS upper_val,
    freq
  FROM
  (
    SELECT val, bucket, freq
    FROM bucket_table

    UNION ALL
    SELECT NULL AS val, time AS bucket, 0 AS freq
    FROM serial_numbers
    WHERE time < (SELECT MAX(bucket) FROM bucket_table)
    AND time NOT IN (SELECT bucket FROM bucket_table)
  ), stat
)

SELECT bucket,
  CONCAT('[',CAST(ROUND(lower_val,1) AS VARCHAR),',',CAST(ROUND(upper_val,1) AS VARCHAR),')') AS range, 
  SUM(freq) AS freq
FROM range_bucket_table
GROUP BY bucket, CONCAT('[',CAST(ROUND(lower_val,1) AS VARCHAR),',',CAST(ROUND(upper_val,1) AS VARCHAR),')')
ORDER BY bucket
```
|bucket|range|freq    |
|------|-----|--------|
|1     |[1.0,2.0)|1       |
|2     |[2.0,3.0)|2       |
|3     |[3.0,4.0)|3       |
|4     |[4.0,5.0)|0       |
|5     |[5.0,6.0)|0       |
|6     |[6.0,7.0)|0       |
|7     |[7.0,8.0)|3       |
|8     |[8.0,9.0)|2       |
|9     |[9.0,10.0)|1       |




### 年間購買分布


```sql
with sample AS
(
  SELECT member_id, SUM(price*amount) AS val
  FROM sales_slip
  WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
  GROUP BY member_id
  HAVING SUM(price*amount) <= 1000000
),
stat AS
 (
  SELECT MIN(val) AS mn, MAX(val)+1 AS mx, 20 AS n
  FROM sample
),
bucket_table AS
(
  SELECT val, WIDTH_BUCKET(val,mn,mx,n) AS bucket, COUNT(1) AS freq
  FROM sample,stat
  GROUP BY val, WIDTH_BUCKET(val,mn,mx,n)
),
range_bucket_table AS
(
  SELECT val, bucket, 
    IF(bucket=0,  -INFINITY(),mn+1.0*(mx-mn)/n*(bucket-1)) AS lower_val,
    IF(bucket=n+1, INFINITY(),mn+1.0*(mx-mn)/n*bucket)     AS upper_val,
    freq
  FROM
  (
    SELECT val, bucket, freq
    FROM bucket_table

    UNION ALL
    SELECT NULL AS val, time AS bucket, 0 AS freq
    FROM serial_numbers
    WHERE time < (SELECT MAX(bucket) FROM bucket_table)
    AND time NOT IN (SELECT bucket FROM bucket_table)
  ), stat
)

SELECT bucket,
  CONCAT('[',CAST(ROUND(lower_val,1) AS VARCHAR),',',CAST(ROUND(upper_val,1) AS VARCHAR),')') AS range, 
  SUM(freq) AS freq
FROM range_bucket_table
GROUP BY bucket, CONCAT('[',CAST(ROUND(lower_val,1) AS VARCHAR),',',CAST(ROUND(upper_val,1) AS VARCHAR),')')
ORDER BY bucket
```
|bucket|range|freq    |
|------|-----|--------|
|1     |[96.0,50063.8)|1488    |
|2     |[50063.8,100031.6)|2059    |
|3     |[100031.6,149999.4)|1779    |
|...   |     |        |
|18    |[849548.6,899516.4)|16      |
|19    |[899516.4,949484.2)|8       |
|20    |[949484.2,999452.0)|10      |




```sql
with sample AS
(
  SELECT member_id, SUM(price*amount) AS val
  FROM sales_slip
  WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
  GROUP BY member_id
  --HAVING SUM(price*amount) <= 1000000
),
stat AS
 (
  SELECT MIN(val) AS mn, MAX(val)+1 AS mx, 20 AS n
  FROM sample
),
bucket_table AS
(
  SELECT val, WIDTH_BUCKET(val,mn,mx,n) AS bucket, COUNT(1) AS freq
  FROM sample,stat
  GROUP BY val, WIDTH_BUCKET(val,mn,mx,n)
),
range_bucket_table AS
(
  SELECT val, bucket, 
    IF(bucket=0,  -INFINITY(),mn+1.0*(mx-mn)/n*(bucket-1)) AS lower_val,
    IF(bucket=n+1, INFINITY(),mn+1.0*(mx-mn)/n*bucket)     AS upper_val,
    freq
  FROM
  (
    SELECT val, bucket, freq
    FROM bucket_table

    UNION ALL
    SELECT NULL AS val, time AS bucket, 0 AS freq
    FROM serial_numbers
    WHERE time < (SELECT MAX(bucket) FROM bucket_table)
    AND time NOT IN (SELECT bucket FROM bucket_table)
  ), stat
)

SELECT bucket,
  CONCAT('[',CAST(ROUND(lower_val,1) AS VARCHAR),',',CAST(ROUND(upper_val,1) AS VARCHAR),')') AS range, 
  SUM(freq) AS freq
FROM range_bucket_table
GROUP BY bucket, CONCAT('[',CAST(ROUND(lower_val,1) AS VARCHAR),',',CAST(ROUND(upper_val,1) AS VARCHAR),')')
ORDER BY bucket
```
|bucket|range|freq    |
|------|-----|--------|
|1     |[96.0,8096371.3)|8827    |
|2     |[8096371.3,1.61926465E7)|1       |
|3     |[1.61926465E7,2.42889218E7)|0       |
|...   |     |        |
|18    |[1.376367753E8,1.457330505E8)|0       |
|19    |[1.457330505E8,1.538293258E8)|0       |
|20    |[1.538293258E8,1.61925601E8)|1       |



```sql
with sample AS
(
  SELECT member_id, SUM(price*amount) AS val
  FROM sales_slip
  WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
  GROUP BY member_id
  --HAVING SUM(price*amount) <= 1000000
),
stat AS
 (
  SELECT MIN(val) AS mn, MAX(val)+1 AS mx, 16192 AS n
  FROM sample
),
bucket_table AS
(
  SELECT val, WIDTH_BUCKET(val,mn,mx,n) AS bucket, COUNT(1) AS freq
  FROM sample,stat
  GROUP BY val, WIDTH_BUCKET(val,mn,mx,n)
),
range_bucket_table AS
(
  SELECT val, bucket, 
    IF(bucket=0,  -INFINITY(),mn+1.0*(mx-mn)/n*(bucket-1)) AS lower_val,
    IF(bucket=n+1, INFINITY(),mn+1.0*(mx-mn)/n*bucket)     AS upper_val,
    freq
  FROM
  (
    SELECT val, bucket, freq
    FROM bucket_table

    UNION ALL
    SELECT NULL AS val, time AS bucket, 0 AS freq
    FROM serial_numbers
    WHERE time < (SELECT MAX(bucket) FROM bucket_table)
    AND time NOT IN (SELECT bucket FROM bucket_table)
  ), stat
)

SELECT bucket,
  CONCAT('[',CAST(ROUND(lower_val,1) AS VARCHAR),',',CAST(ROUND(upper_val,1) AS VARCHAR),')') AS range, 
  SUM(freq) AS freq
FROM range_bucket_table
GROUP BY bucket, CONCAT('[',CAST(ROUND(lower_val,1) AS VARCHAR),',',CAST(ROUND(upper_val,1) AS VARCHAR),')')
ORDER BY bucket
```
|bucket|range            |freq|
|------|-----------------|----|
|1     |[96.0,10096.3)   |209 |
|2     |[10096.3,20096.7)|255 |
|3     |[20096.7,30097.0)|284 |




## 両端の数%を外れ値とみなして除外したヒストグラム

```sql
with sample AS
(
  SELECT member_id, SUM(price*amount) AS val
  FROM sales_slip
  WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
  GROUP BY member_id
  --HAVING SUM(price*amount) <= 1000000
),
stat AS
 (
  SELECT 
    APPROX_PERCENTILE(val,0.05) AS mn, 
    APPROX_PERCENTILE(val,0.95) AS mx,
    20 AS n
  FROM sample
),
bucket_table AS
(
  SELECT val, WIDTH_BUCKET(val,mn,mx,n) AS bucket, COUNT(1) AS freq
  FROM sample,stat
  GROUP BY val, WIDTH_BUCKET(val,mn,mx,n)
),
range_bucket_table AS
(
  SELECT val, bucket, 
    IF(bucket=0,  -INFINITY(),mn+1.0*(mx-mn)/n*(bucket-1)) AS lower_val,
    IF(bucket=n+1, INFINITY(),mn+1.0*(mx-mn)/n*bucket)     AS upper_val,
    freq
  FROM
  (
    SELECT val, bucket, freq
    FROM bucket_table

    UNION ALL
    SELECT NULL AS val, time AS bucket, 0 AS freq
    FROM serial_numbers
    WHERE time < (SELECT MAX(bucket) FROM bucket_table)
    AND time NOT IN (SELECT bucket FROM bucket_table)
  ), stat
)

SELECT bucket,
  CONCAT('[',CAST(ROUND(lower_val,1) AS VARCHAR),',',CAST(ROUND(upper_val,1) AS VARCHAR),')') AS range, 
  SUM(freq) AS freq
FROM range_bucket_table
GROUP BY bucket, CONCAT('[',CAST(ROUND(lower_val,1) AS VARCHAR),',',CAST(ROUND(upper_val,1) AS VARCHAR),')')
ORDER BY bucket
```
|bucket|range            |freq|
|------|-----------------|----|
|0     |[-Infinity,19231.0)|444 |
|1     |[19231.0,40874.2)|696 |
|2     |[40874.2,62517.4)|884 |
|3     |[62517.4,84160.6)|912 |
|...   |                 |    |
|19    |[408808.6,430451.8)|48  |
|20    |[430451.8,452095.0)|46  |
|21    |[452095.0,Infinity)|434 |




## スタージェスの公式

```sql
N=log2(レコード数)-1
```sql
これに基づくと，binの幅は「MAX(値) - MIN(値) / N」とすることができます。この公式に基づいてある程度見やすい幅に修正したヒストグラムを作成するためのクエリを以下に示します。
```sql
WITH sample AS (
  SELECT val
  FROM ( VALUES 1,2,2,3,3,3,7,7,7,8,8,9 ) AS t(val)
),
stat AS
 (
  SELECT MIN(val) AS mn, MAX(val)+1 AS mx,
  CAST(LOG2(COUNT(1))-1 AS INTEGER) AS n -- スタージェスの公式によるbinの数
  FROM sample
),
bucket_table AS
(
  SELECT val, WIDTH_BUCKET(val,mn,mx,n) AS bucket, COUNT(1) AS freq
  FROM sample,stat
  GROUP BY val, WIDTH_BUCKET(val,mn,mx,n)
),
range_bucket_table AS
(
  SELECT val, bucket, 
    IF(bucket=0,  -INFINITY(),mn+1.0*(mx-mn)/n*(bucket-1)) AS lower_val,
    IF(bucket=n+1, INFINITY(),mn+1.0*(mx-mn)/n*bucket)     AS upper_val,
    freq
  FROM
  (
    SELECT val, bucket, freq
    FROM bucket_table

    UNION ALL
    SELECT NULL AS val, time AS bucket, 0 AS freq
    FROM serial_numbers
    WHERE time < (SELECT MAX(bucket) FROM bucket_table)
    AND time NOT IN (SELECT bucket FROM bucket_table)
  ), stat
)

SELECT bucket,
  CONCAT('[',CAST(ROUND(lower_val,1) AS VARCHAR),',',CAST(ROUND(upper_val,1) AS VARCHAR),')') AS range, 
  SUM(freq) AS freq
FROM range_bucket_table
GROUP BY bucket, CONCAT('[',CAST(ROUND(lower_val,1) AS VARCHAR),',',CAST(ROUND(upper_val,1) AS VARCHAR),')')
ORDER BY bucket
```
|bucket|range            |freq|
|------|-----------------|----|
|1     |[1.0,4.0)        |6   |
|2     |[4.0,7.0)        |0   |
|3     |[7.0,10.0)       |6   |




### 年間購買分布

```sql
with sample AS
(
  SELECT member_id, SUM(price*amount) AS val
  FROM sales_slip
  WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
  GROUP BY member_id
  --HAVING SUM(price*amount) <= 1000000
),
stat AS
 (
  SELECT MIN(val) AS mn, MAX(val)+1 AS mx,
  CAST(LOG2(COUNT(1))-1 AS INTEGER) AS n -- スタージェスの公式によるbinの数
  FROM sample
),
bucket_table AS
(
  SELECT val, WIDTH_BUCKET(val,mn,mx,n) AS bucket, COUNT(1) AS freq
  FROM sample,stat
  GROUP BY val, WIDTH_BUCKET(val,mn,mx,n)
),
range_bucket_table AS
(
  SELECT val, bucket, 
    IF(bucket=0,  -INFINITY(),mn+1.0*(mx-mn)/n*(bucket-1)) AS lower_val,
    IF(bucket=n+1, INFINITY(),mn+1.0*(mx-mn)/n*bucket)     AS upper_val,
    freq
  FROM
  (
    SELECT val, bucket, freq
    FROM bucket_table

    UNION ALL
    SELECT NULL AS val, time AS bucket, 0 AS freq
    FROM serial_numbers
    WHERE time < (SELECT MAX(bucket) FROM bucket_table)
    AND time NOT IN (SELECT bucket FROM bucket_table)
  ), stat
)

SELECT bucket,
  CONCAT('[',CAST(ROUND(lower_val,1) AS VARCHAR),',',CAST(ROUND(upper_val,1) AS VARCHAR),')') AS range, 
  SUM(freq) AS freq
FROM range_bucket_table
GROUP BY bucket, CONCAT('[',CAST(ROUND(lower_val,1) AS VARCHAR),',',CAST(ROUND(upper_val,1) AS VARCHAR),')')
ORDER BY bucket
```
|bucket|range            |freq|
|------|-----------------|----|
|1     |[96.0,1.34938881E7)|8828|
|2     |[1.34938881E7,2.69876802E7)|0   |
|3     |[2.69876802E7,4.04814723E7)|0   |


「1.34938881E7」などの末尾の「E7」は10の7乗の意味です。

```sql
with sample AS
(
  SELECT member_id, SUM(price*amount) AS val
  FROM sales_slip
  WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
  GROUP BY member_id
  --HAVING SUM(price*amount) <= 1000000
),
stat AS
 (
  SELECT 
    APPROX_PERCENTILE(val,0.05) AS mn, 
    APPROX_PERCENTILE(val,0.95) AS mx,
    CAST(LOG2(COUNT(1))-1 AS INTEGER) AS n -- スタージェスの公式によるbinの数
  FROM sample
),
bucket_table AS
(
  SELECT val, WIDTH_BUCKET(val,mn,mx,n) AS bucket, COUNT(1) AS freq
  FROM sample,stat
  GROUP BY val, WIDTH_BUCKET(val,mn,mx,n)
),
range_bucket_table AS
(
  SELECT val, bucket, 
    IF(bucket=0,  -INFINITY(),mn+1.0*(mx-mn)/n*(bucket-1)) AS lower_val,
    IF(bucket=n+1, INFINITY(),mn+1.0*(mx-mn)/n*bucket)     AS upper_val,
    freq
  FROM
  (
    SELECT val, bucket, freq
    FROM bucket_table

    UNION ALL
    SELECT NULL AS val, time AS bucket, 0 AS freq
    FROM serial_numbers
    WHERE time < (SELECT MAX(bucket) FROM bucket_table)
    AND time NOT IN (SELECT bucket FROM bucket_table)
  ), stat
)

SELECT bucket,
  CONCAT('[',CAST(ROUND(lower_val,1) AS VARCHAR),',',CAST(ROUND(upper_val,1) AS VARCHAR),')') AS range, 
  SUM(freq) AS freq
FROM range_bucket_table
GROUP BY bucket, CONCAT('[',CAST(ROUND(lower_val,1) AS VARCHAR),',',CAST(ROUND(upper_val,1) AS VARCHAR),')')
ORDER BY bucket
```
|bucket|range            |freq|
|------|-----------------|----|
|0     |[-Infinity,19231.0)|448 |
|1     |[19231.0,55275.0)|1252|
|2     |[55275.0,91319.0)|1531|
|3     |[91319.0,127363.0)|1344|
|...   |                 |    |
|11    |[379671.0,415715.0)|137 |
|12    |[415715.0,451759.0)|69  |
|13    |[451759.0,Infinity)|434 |


## NUMERIC_HISTOGRAM


```sql
WITH sample AS (
  SELECT val
  FROM ( VALUES 1,2,2,3,3,3,4,4,4,4,5,5,5,5,5,6,6,6,6,7,7,7,8,8,9 ) AS t(val)
),
histo AS (
  SELECT NUMERIC_HISTOGRAM(5,val) AS res_map
  FROM sample
)

SELECT key, value
FROM histo
CROSS JOIN UNNEST (
  res_map
) t2 (key, value)
```
|key|value            |
|---|-----------------|
|1.6666666|3.0              |
|3.5714285|7.0              |
|5.0|5.0              |
|6.428571|7.0              |
|8.333333|3.0              |




### 年間購買分布


```sql
with histo AS
(
  SELECT NUMERIC_HISTOGRAM(20,sales) AS res_map
  FROM
  (
    SELECT member_id, SUM(price*amount) AS sales
    FROM sales_slip
    WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
    GROUP BY member_id
  )
)

SELECT key, value
FROM histo
CROSS JOIN UNNEST (
  res_map
) t2 (key, value)
ORDER BY key
```
|key|value            |
|---|-----------------|
|34501.49|1881.0           |
|73071.64|1218.0           |
|103662.25|1181.0           |
|...|                 |
|5916546.0|1.0              |
|9265322.0|1.0              |
|161925600.0|1.0              |

