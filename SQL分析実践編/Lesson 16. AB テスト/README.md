# Lesson 16. A/B テスト




## Welch の片側検定
テキストを参照ください。

## テストに必要なインプットテーブル形式
まず，A/Bテストにかけるためのテーブル形式を定義します。
- レコードはAとBの2行
- AとBの平均値（平均アクセス数，平均売上，平均コンバージョン）が統計的な意味で差異があるか否かを検定する
- A，Bそれぞれの「数」，「平均」，「分散」を求めたテーブルがテンプレート

## 購買履歴での事例

```sql
SELECT 
  IF(CAST(member_id AS INTEGER)%2=0,'A','B') AS ab, 
  COUNT(1) AS cnt,
  AVG(sales)    AS ag,
  STDDEV(sales) AS sd
FROM (
  SELECT member_id, SUM(price*amount) AS sales
  FROM sales_slip
  WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
  GROUP BY member_id
)
GROUP BY IF(CAST(member_id AS INTEGER)%2=0,'A','B')
```
|ab |cnt              |ag                |sd                |
|---|-----------------|------------------|------------------|
|B  |4408             |204696.70961887477|2445357.7436663453|
|A  |4421             |165884.85161728115|219180.89283232426|



```sql
WITH ab_table AS
(
  SELECT 
    IF(CAST(member_id AS INTEGER)%2=0,'A','B') AS ab, 
    COUNT(1) AS cnt,
    AVG(sales)    AS ag,
    STDDEV(sales) AS sd
  FROM (
    SELECT member_id, SUM(price*amount) AS sales
    FROM sales_slip
    WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
    GROUP BY member_id
  )
  GROUP BY IF(CAST(member_id AS INTEGER)%2=0,'A','B')
)

SELECT *, (cnt/(cnt-1))*sd*sd AS ueach
FROM ab_table
```
|ab |cnt              |ag                |sd                |ueach             |
|---|-----------------|------------------|------------------|------------------|
|B  |4408             |204696.70961887477|2445357.7436663453|5979774494508.959 |
|A  |4421             |165884.85161728115|219180.89283232423|48040263782.774796|


## A/Bレコードのマージ

```sql
WITH ab_table AS
(
  SELECT 
    IF(CAST(member_id AS INTEGER)%2=0,'A','B') AS ab, 
    COUNT(1) AS cnt,
    AVG(sales)    AS ag,
    STDDEV(sales) AS sd
  FROM (
    SELECT member_id, SUM(price*amount) AS sales
    FROM sales_slip
    WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
    GROUP BY member_id
  )
  GROUP BY IF(CAST(member_id AS INTEGER)%2=0,'A','B')
)

SELECT 
  ab    AS a,       LEAD(ab)OVER(ORDER BY ab)    AS b,
  cnt   AS cnt_a,   LEAD(cnt)OVER(ORDER BY ab)   AS cnt_b,
  ag    AS avg_a,   LEAD(ag)OVER(ORDER BY ab)    AS avg_b,
  sd    AS sd_a,    LEAD(sd)OVER(ORDER BY ab)    AS sd_b,
  ueach AS ueach_a, LEAD(ueach)OVER(ORDER BY ab) AS ueach_b
FROM
(
  SELECT *, (cnt/(cnt-1))*sd*sd AS ueach
  FROM ab_table
)
```
|a  |b                |cnt_a             |cnt_b             |avg_a             |avg_b             |sd_a             |sd_b      |ueach_a           |ueach_b          |
|---|-----------------|------------------|------------------|------------------|------------------|-----------------|----------|------------------|-----------------|
|A  |B                |4421              |4408              |165884.85161728115|204696.70961887477|219180.8928323243|2445357.7436663467|48040263782.774826|5979774494508.966|
|B  |NULL             |4408              |NULL              |204696.70961887477|NULL              |2445357.7436663467|NULL      |5979774494508.966 |NULL             |




## 統計値Tと自由度m

```sql
WITH ab_table AS
(
  SELECT 
    IF(CAST(member_id AS INTEGER)%2=0,'A','B') AS ab, 
    COUNT(1) AS cnt,
    AVG(sales)    AS ag,
    STDDEV(sales) AS sd
  FROM (
    SELECT member_id, SUM(price*amount) AS sales
    FROM sales_slip
    WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
    GROUP BY member_id
  )
  GROUP BY IF(CAST(member_id AS INTEGER)%2=0,'A','B')
),
ueach_table AS
(
  SELECT 
    ab    AS a,       LEAD(ab)OVER(ORDER BY ab)    AS b,
    cnt   AS cnt_a,   LEAD(cnt)OVER(ORDER BY ab)   AS cnt_b,
    ag    AS avg_a,   LEAD(ag)OVER(ORDER BY ab)    AS avg_b,
    sd    AS sd_a,    LEAD(sd)OVER(ORDER BY ab)    AS sd_b,
    ueach AS ueach_a, LEAD(ueach)OVER(ORDER BY ab) AS ueach_b
  FROM
  (
    SELECT *, (cnt/(cnt-1))*sd*sd AS ueach
    FROM ab_table
  )
)

SELECT *,
  ABS( (avg_a-avg_b)/SQRT(sd_a*sd_a/(cnt_a-1)+sd_b*sd_b/(cnt_b-1)) ) AS t_stat,
  ROUND( POW((sd_a*sd_a/(cnt_a-1)+sd_b*sd_b/(cnt_b-1)),2) / ( POW(sd_a,4)/POW(cnt_a-1,3) + POW(sd_b,4)/POW(cnt_b-1,3) ) ) AS m
FROM ueach_table
WHERE a = 'A'
```
|a  |b                |cnt_a             |cnt_b             |avg_a             |avg_b             |sd_a             |sd_b             |ueach_a           |ueach_b          |t_stat           |m     |
|---|-----------------|------------------|------------------|------------------|------------------|-----------------|-----------------|------------------|-----------------|-----------------|------|
|A  |B                |4421              |4408              |165884.85161728115|204696.70961887477|219180.8928323243|2445357.743666346|48040263782.774826|5979774494508.964|1.0494484257242693|4478.0|


## テストテンプレート

```sql
WITH ab_table AS
(
  SELECT 
    IF(CAST(member_id AS INTEGER)%2=0,'A','B') AS ab, 
    COUNT(1) AS cnt,
    AVG(sales)    AS ag,
    STDDEV(sales) AS sd
  FROM (
    SELECT member_id, SUM(price*amount) AS sales
    FROM sales_slip
    WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
    GROUP BY member_id
  )
  GROUP BY IF(CAST(member_id AS INTEGER)%2=0,'A','B')
),
ueach_table AS
(
  SELECT 
    ab    AS a,       LEAD(ab)OVER(ORDER BY ab)    AS b,
    cnt   AS cnt_a,   LEAD(cnt)OVER(ORDER BY ab)   AS cnt_b,
    ag    AS avg_a,   LEAD(ag)OVER(ORDER BY ab)    AS avg_b,
    sd    AS sd_a,    LEAD(sd)OVER(ORDER BY ab)    AS sd_b,
    ueach AS ueach_a, LEAD(ueach)OVER(ORDER BY ab) AS ueach_b
  FROM
  (
    SELECT *, (cnt/(cnt-1))*sd*sd AS ueach
    FROM ab_table
  )
),
welch AS
(
  SELECT *,
    ABS( (avg_a-avg_b)/SQRT(sd_a*sd_a/(cnt_a-1)+sd_b*sd_b/(cnt_b-1)) ) AS t_stat,
    ROUND( POW((sd_a*sd_a/(cnt_a-1)+sd_b*sd_b/(cnt_b-1)),2) / ( POW(sd_a,4)/POW(cnt_a-1,3) + POW(sd_b,4)/POW(cnt_b-1,3) ) ) AS m
  FROM ueach_table
  WHERE a = 'A'
),
t AS
(
  SELECT MIN_BY(t_dist.val,t_dist.m) AS t_val
  FROM welch, t_dist
  WHERE welch.m <= t_dist.m
)

SELECT cnt_a, cnt_b, ROUND(avg_a) AS avg_a, ROUND(avg_b) AS avg_b, 
  t_stat, t_val, IF(t_stat>t_val,'REJECT','NOT REJECT') AS test_res
FROM welch, t
```
|cnt_a|cnt_b            |avg_a             |avg_b             |t_stat            |t_val             |test_res         |
|-----|-----------------|------------------|------------------|------------------|------------------|-----------------|
|4421 |4408             |165885.0          |204697.0          |1.0494484257242693|1.96              |NOT REJECT       |

上記のテスト結果は「NOT REJECT：差異が認められない」となりました。

## サンプル数と標準偏差が変化するとテストの結果はどう変わるか？



### 1-a. A,B 双方のサンプル数がもっと多い場合
まず，サンプル数がもっと多い場合を先に考えます。
1. （サンプル数）A：440000人，B：440000人 ←100倍にしてみる
2. （平均購入額）A：16.6万円，B：20.5万円
3. （標準偏差）A：220000，B：2450000
テストテンプレートの一部を人工的に変更して結果を確認してみます。
```sql
WITH ab_table AS
(
  SELECT 
    IF(CAST(member_id AS INTEGER)%2=0,'A','B') AS ab, 
    COUNT(1) * 100 AS cnt,
    AVG(sales)    AS ag,
    STDDEV(sales) AS sd
  FROM (
    SELECT member_id, SUM(price*amount) AS sales
    FROM sales_slip
    WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
    GROUP BY member_id
  )
  GROUP BY IF(CAST(member_id AS INTEGER)%2=0,'A','B')
),
ueach_table AS
(
  SELECT 
    ab    AS a,       LEAD(ab)OVER(ORDER BY ab)    AS b,
    cnt   AS cnt_a,   LEAD(cnt)OVER(ORDER BY ab)   AS cnt_b,
    ag    AS avg_a,   LEAD(ag)OVER(ORDER BY ab)    AS avg_b,
    sd    AS sd_a,    LEAD(sd)OVER(ORDER BY ab)    AS sd_b,
    ueach AS ueach_a, LEAD(ueach)OVER(ORDER BY ab) AS ueach_b
  FROM
  (
    SELECT *, (cnt/(cnt-1))*sd*sd AS ueach
    FROM ab_table
  )
),
welch AS
(
  SELECT *,
    ABS( (avg_a-avg_b)/SQRT(sd_a*sd_a/(cnt_a-1)+sd_b*sd_b/(cnt_b-1)) ) AS t_stat,
    ROUND( POW((sd_a*sd_a/(cnt_a-1)+sd_b*sd_b/(cnt_b-1)),2) / ( POW(sd_a,4)/POW(cnt_a-1,3) + POW(sd_b,4)/POW(cnt_b-1,3) ) ) AS m
  FROM ueach_table
  WHERE a = 'A'
),
t AS
(
  SELECT MIN_BY(t_dist.val,t_dist.m) AS t_val
  FROM welch, t_dist
  WHERE welch.m <= t_dist.m
)

SELECT cnt_a, cnt_b, ROUND(avg_a) AS avg_a, ROUND(avg_b) AS avg_b, 
  t_stat, t_val, IF(t_stat>t_val,'REJECT','NOT REJECT') AS test_res
FROM welch, t
```
|cnt_a|cnt_b            |avg_a             |avg_b             |t_stat            |t_val             |test_res         |
|-----|-----------------|------------------|------------------|------------------|------------------|-----------------|
|442100|440800           |165885.0          |204697.0          |10.495662917691837|1.96              |REJECT           |



### 1-b. A,B 双方のサンプル数がもっと少ない場合
次に，サンプル数がずっと少ない場合を先に考えます。
1. （サンプル数）A：44人，B：44人 ←1/100にしてみる
2. （平均購入額）A：16.6万円，B：20.5万円
3. （標準偏差）A：220000，B：2450000
```sql
WITH ab_table AS
(
  SELECT 
    IF(CAST(member_id AS INTEGER)%2=0,'A','B') AS ab, 
    COUNT(1) / 100 AS cnt,
    AVG(sales)    AS ag,
    STDDEV(sales) AS sd
  FROM (
    SELECT member_id, SUM(price*amount) AS sales
    FROM sales_slip
    WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
    GROUP BY member_id
  )
  GROUP BY IF(CAST(member_id AS INTEGER)%2=0,'A','B')
),
ueach_table AS
(
  SELECT 
    ab    AS a,       LEAD(ab)OVER(ORDER BY ab)    AS b,
    cnt   AS cnt_a,   LEAD(cnt)OVER(ORDER BY ab)   AS cnt_b,
    ag    AS avg_a,   LEAD(ag)OVER(ORDER BY ab)    AS avg_b,
    sd    AS sd_a,    LEAD(sd)OVER(ORDER BY ab)    AS sd_b,
    ueach AS ueach_a, LEAD(ueach)OVER(ORDER BY ab) AS ueach_b
  FROM
  (
    SELECT *, (cnt/(cnt-1))*sd*sd AS ueach
    FROM ab_table
  )
),
welch AS
(
  SELECT *,
    ABS( (avg_a-avg_b)/SQRT(sd_a*sd_a/(cnt_a-1)+sd_b*sd_b/(cnt_b-1)) ) AS t_stat,
    ROUND( POW((sd_a*sd_a/(cnt_a-1)+sd_b*sd_b/(cnt_b-1)),2) / ( POW(sd_a,4)/POW(cnt_a-1,3) + POW(sd_b,4)/POW(cnt_b-1,3) ) ) AS m
  FROM ueach_table
  WHERE a = 'A'
),
t AS
(
  SELECT MIN_BY(t_dist.val,t_dist.m) AS t_val
  FROM welch, t_dist
  WHERE welch.m <= t_dist.m
)

SELECT cnt_a, cnt_b, ROUND(avg_a) AS avg_a, ROUND(avg_b) AS avg_b, 
  t_stat, t_val, IF(t_stat>t_val,'REJECT','NOT REJECT') AS test_res
FROM welch, t
```
|cnt_a|cnt_b            |avg_a             |avg_b             |t_stat            |t_val             |test_res         |
|-----|-----------------|------------------|------------------|------------------|------------------|-----------------|
|44   |44               |165885.0          |204697.0          |0.10366179214964653|2.015368          |NOT REJECT       |



### 2. Aのサンプル数がBに対して圧倒的に少ない場合
1. （サンプル数）A：44人，B：4400人 ←Aを1/100にしてみる
2. （平均購入額）A：16.6万円，B：20.5万円
3. （標準偏差）A：220000，B：2450000

```sql
WITH ab_table AS
(
  SELECT ab, IF(ab='A',cnt/100, cnt) AS cnt, ag, sd
  FROM
  (
    SELECT 
      IF(CAST(member_id AS INTEGER)%2=0,'A','B') AS ab, 
      COUNT(1) AS cnt,
      AVG(sales)    AS ag,
      STDDEV(sales) AS sd
    FROM (
      SELECT member_id, SUM(price*amount) AS sales
      FROM sales_slip
      WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
      GROUP BY member_id
    )
    GROUP BY IF(CAST(member_id AS INTEGER)%2=0,'A','B')
  )
),
ueach_table AS
(
  SELECT 
    ab    AS a,       LEAD(ab)OVER(ORDER BY ab)    AS b,
    cnt   AS cnt_a,   LEAD(cnt)OVER(ORDER BY ab)   AS cnt_b,
    ag    AS avg_a,   LEAD(ag)OVER(ORDER BY ab)    AS avg_b,
    sd    AS sd_a,    LEAD(sd)OVER(ORDER BY ab)    AS sd_b,
    ueach AS ueach_a, LEAD(ueach)OVER(ORDER BY ab) AS ueach_b
  FROM
  (
    SELECT *, (cnt/(cnt-1))*sd*sd AS ueach
    FROM ab_table
  )
),
welch AS
(
  SELECT *,
    ABS( (avg_a-avg_b)/SQRT(sd_a*sd_a/(cnt_a-1)+sd_b*sd_b/(cnt_b-1)) ) AS t_stat,
    ROUND( POW((sd_a*sd_a/(cnt_a-1)+sd_b*sd_b/(cnt_b-1)),2) / ( POW(sd_a,4)/POW(cnt_a-1,3) + POW(sd_b,4)/POW(cnt_b-1,3) ) ) AS m
  FROM ueach_table
  WHERE a = 'A'
),
t AS
(
  SELECT MIN_BY(t_dist.val,t_dist.m) AS t_val
  FROM welch, t_dist
  WHERE welch.m <= t_dist.m
)

SELECT cnt_a, cnt_b, ROUND(avg_a) AS avg_a, ROUND(avg_b) AS avg_b, 
  t_stat, t_val, IF(t_stat>t_val,'REJECT','NOT REJECT') AS test_res
FROM welch, t
```
|cnt_a|cnt_b            |avg_a             |avg_b             |t_stat            |t_val             |test_res         |
|-----|-----------------|------------------|------------------|------------------|------------------|-----------------|
|44   |4408             |165885.0          |204697.0          |0.7802901476542795|1.971435          |NOT REJECT       |



1. （サンプル数）A：4人，B：440000人 ←Aを1/1000，Bを100倍
2. （平均購入額）A：16.6万円，B：20.5万円
3. （標準偏差）A：220000，B：2450000

```sql
WITH ab_table AS
(
  SELECT ab, IF(ab='A',cnt/1000, cnt*100) AS cnt, ag, sd
  FROM
  (
    SELECT 
      IF(CAST(member_id AS INTEGER)%2=0,'A','B') AS ab, 
      COUNT(1) AS cnt,
      AVG(sales)    AS ag,
      STDDEV(sales) AS sd
    FROM (
      SELECT member_id, SUM(price*amount) AS sales
      FROM sales_slip
      WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
      GROUP BY member_id
    )
    GROUP BY IF(CAST(member_id AS INTEGER)%2=0,'A','B')
  )
),
ueach_table AS
(
  SELECT 
    ab    AS a,       LEAD(ab)OVER(ORDER BY ab)    AS b,
    cnt   AS cnt_a,   LEAD(cnt)OVER(ORDER BY ab)   AS cnt_b,
    ag    AS avg_a,   LEAD(ag)OVER(ORDER BY ab)    AS avg_b,
    sd    AS sd_a,    LEAD(sd)OVER(ORDER BY ab)    AS sd_b,
    ueach AS ueach_a, LEAD(ueach)OVER(ORDER BY ab) AS ueach_b
  FROM
  (
    SELECT *, (cnt/(cnt-1))*sd*sd AS ueach
    FROM ab_table
  )
),
welch AS
(
  SELECT *,
    ABS( (avg_a-avg_b)/SQRT(sd_a*sd_a/(cnt_a-1)+sd_b*sd_b/(cnt_b-1)) ) AS t_stat,
    ROUND( POW((sd_a*sd_a/(cnt_a-1)+sd_b*sd_b/(cnt_b-1)),2) / ( POW(sd_a,4)/POW(cnt_a-1,3) + POW(sd_b,4)/POW(cnt_b-1,3) ) ) AS m
  FROM ueach_table
  WHERE a = 'A'
),
t AS
(
  SELECT MIN_BY(t_dist.val,t_dist.m) AS t_val
  FROM welch, t_dist
  WHERE welch.m <= t_dist.m
)

SELECT cnt_a, cnt_b, ROUND(avg_a) AS avg_a, ROUND(avg_b) AS avg_b, 
  t_stat, t_val, IF(t_stat>t_val,'REJECT','NOT REJECT') AS test_res
FROM welch, t
```
|cnt_a|cnt_b            |avg_a             |avg_b             |t_stat            |t_val             |test_res         |
|-----|-----------------|------------------|------------------|------------------|------------------|-----------------|
|4    |440800           |165885.0          |204697.0          |0.3065762383235844|3.182446          |NOT REJECT       |



### 3-a. A,B 双方の標準偏差がもっと大きい場合

1. （サンプル数）A：4400人，B：4400人
2. （平均購入額）A：16.6万円，B：20.5万円
3. （標準偏差）A：22000000，B：245000000 ←100倍にしてみる
```sql
WITH ab_table AS
(
  SELECT 
    IF(CAST(member_id AS INTEGER)%2=0,'A','B') AS ab, 
    COUNT(1)      AS cnt,
    AVG(sales)    AS ag,
    STDDEV(sales) * 100 AS sd
  FROM (
    SELECT member_id, SUM(price*amount) AS sales
    FROM sales_slip
    WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
    GROUP BY member_id
  )
  GROUP BY IF(CAST(member_id AS INTEGER)%2=0,'A','B')
),
ueach_table AS
(
  SELECT 
    ab    AS a,       LEAD(ab)OVER(ORDER BY ab)    AS b,
    cnt   AS cnt_a,   LEAD(cnt)OVER(ORDER BY ab)   AS cnt_b,
    ag    AS avg_a,   LEAD(ag)OVER(ORDER BY ab)    AS avg_b,
    sd    AS sd_a,    LEAD(sd)OVER(ORDER BY ab)    AS sd_b,
    ueach AS ueach_a, LEAD(ueach)OVER(ORDER BY ab) AS ueach_b
  FROM
  (
    SELECT *, (cnt/(cnt-1))*sd*sd AS ueach
    FROM ab_table
  )
),
welch AS
(
  SELECT *,
    ABS( (avg_a-avg_b)/SQRT(sd_a*sd_a/(cnt_a-1)+sd_b*sd_b/(cnt_b-1)) ) AS t_stat,
    ROUND( POW((sd_a*sd_a/(cnt_a-1)+sd_b*sd_b/(cnt_b-1)),2) / ( POW(sd_a,4)/POW(cnt_a-1,3) + POW(sd_b,4)/POW(cnt_b-1,3) ) ) AS m
  FROM ueach_table
  WHERE a = 'A'
),
t AS
(
  SELECT MIN_BY(t_dist.val,t_dist.m) AS t_val
  FROM welch, t_dist
  WHERE welch.m <= t_dist.m
)

SELECT cnt_a, cnt_b, ROUND(avg_a) AS avg_a, ROUND(avg_b) AS avg_b, 
  t_stat, t_val, IF(t_stat>t_val,'REJECT','NOT REJECT') AS test_res
FROM welch, t
```
|cnt_a|cnt_b            |avg_a             |avg_b             |t_stat            |t_val             |test_res         |
|-----|-----------------|------------------|------------------|------------------|------------------|-----------------|
|4421 |4408             |165885.0          |204697.0          |0.010494484257242694|1.96              |NOT REJECT       |




### 3-b. A,B 双方の標準偏差がもっと小さい場合
1. （サンプル数）A：4400人，B：4400人
2. （平均購入額）A：16.6万円，B：20.5万円
3. （標準偏差）A：2200，B：24500 ←1/100にしてみる
```sql
WITH ab_table AS
(
  SELECT 
    IF(CAST(member_id AS INTEGER)%2=0,'A','B') AS ab, 
    COUNT(1)      AS cnt,
    AVG(sales)    AS ag,
    STDDEV(sales) / 100 AS sd
  FROM (
    SELECT member_id, SUM(price*amount) AS sales
    FROM sales_slip
    WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
    GROUP BY member_id
  )
  GROUP BY IF(CAST(member_id AS INTEGER)%2=0,'A','B')
),
ueach_table AS
(
  SELECT 
    ab    AS a,       LEAD(ab)OVER(ORDER BY ab)    AS b,
    cnt   AS cnt_a,   LEAD(cnt)OVER(ORDER BY ab)   AS cnt_b,
    ag    AS avg_a,   LEAD(ag)OVER(ORDER BY ab)    AS avg_b,
    sd    AS sd_a,    LEAD(sd)OVER(ORDER BY ab)    AS sd_b,
    ueach AS ueach_a, LEAD(ueach)OVER(ORDER BY ab) AS ueach_b
  FROM
  (
    SELECT *, (cnt/(cnt-1))*sd*sd AS ueach
    FROM ab_table
  )
),
welch AS
(
  SELECT *,
    ABS( (avg_a-avg_b)/SQRT(sd_a*sd_a/(cnt_a-1)+sd_b*sd_b/(cnt_b-1)) ) AS t_stat,
    ROUND( POW((sd_a*sd_a/(cnt_a-1)+sd_b*sd_b/(cnt_b-1)),2) / ( POW(sd_a,4)/POW(cnt_a-1,3) + POW(sd_b,4)/POW(cnt_b-1,3) ) ) AS m
  FROM ueach_table
  WHERE a = 'A'
),
t AS
(
  SELECT MIN_BY(t_dist.val,t_dist.m) AS t_val
  FROM welch, t_dist
  WHERE welch.m <= t_dist.m
)

SELECT cnt_a, cnt_b, ROUND(avg_a) AS avg_a, ROUND(avg_b) AS avg_b, 
  t_stat, t_val, IF(t_stat>t_val,'REJECT','NOT REJECT') AS test_res
FROM welch, t
```
|cnt_a|cnt_b            |avg_a             |avg_b             |t_stat            |t_val             |test_res         |
|-----|-----------------|------------------|------------------|------------------|------------------|-----------------|
|4421 |4408             |165885.0          |204697.0          |104.9448425724269 |1.96              |REJECT           |



### 4. Aの標準偏差がBに対して圧倒的に大きい場合，テストの結果はどう変わるか？
1. （サンプル数）A：4400人，B：4400人
2. （平均購入額）A：16.6万円，B：20.5万円
3. （標準偏差）A：22000000，B：24500 ←Aを100倍，Bを1/100にしてみる
```sql
WITH ab_table AS
(
  SELECT ab, cnt, ag, IF(ab='A',sd*100, sd/100) AS sd
  FROM
  (
    SELECT 
      IF(CAST(member_id AS INTEGER)%2=0,'A','B') AS ab, 
      COUNT(1) AS cnt,
      AVG(sales)    AS ag,
      STDDEV(sales) AS sd
    FROM (
      SELECT member_id, SUM(price*amount) AS sales
      FROM sales_slip
      WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
      GROUP BY member_id
    )
    GROUP BY IF(CAST(member_id AS INTEGER)%2=0,'A','B')
  )
),
ueach_table AS
(
  SELECT 
    ab    AS a,       LEAD(ab)OVER(ORDER BY ab)    AS b,
    cnt   AS cnt_a,   LEAD(cnt)OVER(ORDER BY ab)   AS cnt_b,
    ag    AS avg_a,   LEAD(ag)OVER(ORDER BY ab)    AS avg_b,
    sd    AS sd_a,    LEAD(sd)OVER(ORDER BY ab)    AS sd_b,
    ueach AS ueach_a, LEAD(ueach)OVER(ORDER BY ab) AS ueach_b
  FROM
  (
    SELECT *, (cnt/(cnt-1))*sd*sd AS ueach
    FROM ab_table
  )
),
welch AS
(
  SELECT *,
    ABS( (avg_a-avg_b)/SQRT(sd_a*sd_a/(cnt_a-1)+sd_b*sd_b/(cnt_b-1)) ) AS t_stat,
    ROUND( POW((sd_a*sd_a/(cnt_a-1)+sd_b*sd_b/(cnt_b-1)),2) / ( POW(sd_a,4)/POW(cnt_a-1,3) + POW(sd_b,4)/POW(cnt_b-1,3) ) ) AS m
  FROM ueach_table
  WHERE a = 'A'
),
t AS
(
  SELECT MIN_BY(t_dist.val,t_dist.m) AS t_val
  FROM welch, t_dist
  WHERE welch.m <= t_dist.m
)

SELECT cnt_a, cnt_b, ROUND(avg_a) AS avg_a, ROUND(avg_b) AS avg_b, 
  t_stat, t_val, IF(t_stat>t_val,'REJECT','NOT REJECT') AS test_res
FROM welch, t
```
|cnt_a|cnt_b            |avg_a             |avg_b             |t_stat            |t_val             |test_res         |
|-----|-----------------|------------------|------------------|------------------|------------------|-----------------|
|4421 |4408             |165885.0          |204697.0          |0.11772605896350993|1.96              |NOT REJECT       |




## GROUP BYに対応したテンプレートクエリ

```sql
WITH ab_table AS
(
  SELECT 
    IF(CAST(member_id AS INTEGER)%2=0,'A','B') AS ab, 
    sub_category,
    COUNT(1) AS cnt,
    AVG(sales)    AS ag,
    STDDEV(sales) AS sd
  FROM (
    SELECT member_id, sub_category, SUM(price*amount) AS sales
    FROM sales_slip
    WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
    GROUP BY member_id, sub_category
  )
  GROUP BY IF(CAST(member_id AS INTEGER)%2=0,'A','B'), sub_category
),
ueach_table AS
(
  SELECT 
    ab    AS a,       LEAD(ab)OVER(PARTITION BY sub_category ORDER BY ab)    AS b,
    sub_category,
    cnt   AS cnt_a,   LEAD(cnt)OVER(PARTITION BY sub_category ORDER BY ab)   AS cnt_b,
    ag    AS avg_a,   LEAD(ag)OVER(PARTITION BY sub_category ORDER BY ab)    AS avg_b,
    sd    AS sd_a,    LEAD(sd)OVER(PARTITION BY sub_category ORDER BY ab)    AS sd_b,
    ueach AS ueach_a, LEAD(ueach)OVER(PARTITION BY sub_category ORDER BY ab) AS ueach_b
  FROM
  (
    SELECT *, (cnt/(cnt-1))*sd*sd AS ueach
    FROM ab_table
  )
),
welch AS
(
  SELECT *,
    ABS( (avg_a-avg_b)/SQRT(sd_a*sd_a/(cnt_a-1)+sd_b*sd_b/(cnt_b-1)) ) AS t_stat,
    ROUND( POW((sd_a*sd_a/(cnt_a-1)+sd_b*sd_b/(cnt_b-1)),2) / ( POW(sd_a,4)/POW(cnt_a-1,3) + POW(sd_b,4)/POW(cnt_b-1,3) ) ) AS m
  FROM ueach_table
  WHERE a = 'A'
),
t AS
(
  SELECT sub_category, MIN_BY(t_dist.val,t_dist.m) AS t_val
  FROM welch, t_dist
  WHERE welch.m <= t_dist.m
  GROUP BY sub_category
)

SELECT welch.sub_category, cnt_a, cnt_b, ROUND(avg_a) AS avg_a, ROUND(avg_b) AS avg_b, 
  t_stat, t_val, IF(t_stat>t_val,'REJECT','NOT REJECT') AS test_res
FROM welch JOIN t
ON welch.sub_category = t.sub_category
ORDER BY t_stat DESC
```
|sub_category|cnt_a            |cnt_b             |avg_a             |avg_b             |t_stat            |t_val            |test_res  |
|------------|-----------------|------------------|------------------|------------------|------------------|-----------------|----------|
|Pet Supplies|1803             |1823              |5110.0            |4572.0            |2.6435229759742676|1.96             |REJECT    |
|Cell Phones and Accessories|1629             |1650              |4941.0            |5522.0            |2.4760638964276223|1.96             |REJECT    |
|Menâ€™s Grooming|1507             |1488              |4764.0            |5381.0            |2.318784943315247 |1.96             |REJECT    |
|Hunting and Fishing|1433             |1495              |4874.0            |5352.0            |1.8464156355524592|1.96             |NOT REJECT|
|Entertainment Collectibles|1490             |1469              |4931.0            |4508.0            |1.7420797648705493|1.96             |NOT REJECT|
|Automotive Tools and Equipment|1582             |1580              |4519.0            |4998.0            |1.715586065782713 |1.96             |NOT REJECT|




## アクセスログでの事例

```sql
WITH ab_table AS
(
  SELECT 
    td_title,
    IF(LENGTH(td_ip)%2=0,'A','B') AS ab, 
    COUNT(1) AS cnt,
    AVG(pv)    AS ag,
    STDDEV(pv) AS sd
  FROM (
    SELECT td_ip, td_title, COUNT(1) AS pv
    FROM sample_accesslog
    GROUP BY td_ip, td_title
  )
  GROUP BY IF(LENGTH(td_ip)%2=0,'A','B'), td_title
),
ueach_table AS
(
  SELECT 
    ab    AS a,       LEAD(ab)OVER(PARTITION BY td_title ORDER BY ab)    AS b,
    td_title,
    cnt   AS cnt_a,   LEAD(cnt)OVER(PARTITION BY td_title ORDER BY ab)   AS cnt_b,
    ag    AS avg_a,   LEAD(ag)OVER(PARTITION BY td_title ORDER BY ab)    AS avg_b,
    sd    AS sd_a,    LEAD(sd)OVER(PARTITION BY td_title ORDER BY ab)    AS sd_b,
    ueach AS ueach_a, LEAD(ueach)OVER(PARTITION BY td_title ORDER BY ab) AS ueach_b
  FROM
  (
    SELECT *, (cnt/(cnt-1))*sd*sd AS ueach
    FROM ab_table
  )
),
welch AS
(
  SELECT *,
    ABS( (avg_a-avg_b)/SQRT(sd_a*sd_a/(cnt_a-1)+sd_b*sd_b/(cnt_b-1)) ) AS t_stat,
    ROUND( POW((sd_a*sd_a/(cnt_a-1)+sd_b*sd_b/(cnt_b-1)),2) / ( POW(sd_a,4)/POW(cnt_a-1,3) + POW(sd_b,4)/POW(cnt_b-1,3) ) ) AS m
  FROM ueach_table
  WHERE a = 'A'
),
t AS
(
  SELECT td_title, MIN_BY(t_dist.val,t_dist.m) AS t_val
  FROM welch, t_dist
  WHERE welch.m <= t_dist.m
  GROUP BY td_title
)

SELECT welch.td_title, cnt_a, cnt_b, ROUND(avg_a,1) AS avg_a, ROUND(avg_b,1) AS avg_b, 
  t_stat, t_val, IF(t_stat>t_val,'REJECT','NOT REJECT') AS test_res
FROM welch JOIN t
ON welch.td_title = t.td_title
WHERE 50 <= cnt_a AND 50 <= cnt_b
ORDER BY t_stat DESC
```
|td_title|cnt_a            |cnt_b             |avg_a             |avg_b             |t_stat            |t_val            |test_res  |
|--------|-----------------|------------------|------------------|------------------|------------------|-----------------|----------|
|プライベートDMPソリューション”TREASURE(トレジャー) DMP(ディーエムピー)”を 4月より提供開始 - プレスリリース - Treasure Data|298              |370               |1.8               |2.0               |1.1905781581541686|1.963609         |NOT REJECT|
|Eコマース - Treasure Data|155              |177               |1.7               |1.5               |1.1597967524793498|1.968093         |NOT REJECT|
|会社情報 - Treasure Data|328              |342               |1.4               |1.9               |1.1535810869244305|1.966726         |NOT REJECT|


この例では，すべて差異が認められない結果となりました。
