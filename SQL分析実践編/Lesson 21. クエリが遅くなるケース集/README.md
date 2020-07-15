# Lesson 21. クエリが遅くなるケース集



## 10GB以上の結果が返ってくるクエリ

10GB以上の結果をダウンロードしたりS3へアップロードしたりする場合には，クエリ結果の出力待ちがボトルネックになり，リソースをうまく使いきれません。この問題の対処として，クエリ冒頭に以下のマジックコメントを記述することで性能が改善します（ORDER BY節がない場合に限り）。
```sql
-- set session result_output_redirect='true'
```



## データパーティショニングに問題がある

```sql
SELECT TD_TIME_FORMAT(time, 'yyyy-MM-dd HH:00:00', 'JST') AS hour, COUNT(1) AS cnt
FROM sample_accesslog
GROUP BY 1
ORDER BY cnt DESC
LIMIT 100
```
|hour      |cnt|
|----------|---|
|2016-06-03 14:00:00|385|
|2016-06-21 15:00:00|300|
|2016-06-21 17:00:00|214|
|2016-06-16 14:00:00|213|
|2016-06-23 16:00:00|202|


## AWSやトレジャーデータプラットフォームに障害が起きている


### 単一ノード処理をする記述がある
1. DISTINCT
2. COUNT(DISTINCT x)
3. ORDER BY
4. UNION（UNION ALLではない）



### DISTINCTの書き換え

```sql
SELECT DISTINCT category, sub_category, goods_id
FROM sales_slip
```


```sql
SELECT category, sub_category, goods_id
FROM sales_slip
GROUP BY category, sub_category, goods_id
```


### COUNT(DISTINCT x)の書き換え

```sql
SELECT COUNT(DISTINCT goods_id)
FROM sales_slip
```
|_col0     |
|----------|
|385768    |


```sql
SELECT COUNT(goods_id)
FROM
(
  SELECT goods_id
  FROM sales_slip
  GROUP BY goods_id
)
```
|_col0     |
|----------|
|385768    |


```sql
SELECT COUNT(1)
FROM
(
  SELECT goods_id
  FROM sales_slip
  WHERE goods_id IS NOT NULL
  GROUP BY goods_id
)
```
|_col0     |
|----------|
|385768    |


```sql
SELECT APPROX_DISTINCT(goods_id)
FROM sales_slip
```
|_col0     |
|----------|
|397118    |


### ORDER BYの対処



### UNIONをUNION ALLへ置き換え


## パフォーマンスの悪いUDFを使っている


## GROUP BYに問題がある

### GROUP BYのキーが多数ある


### Cardinalityの高いカラムからGROUP BYのキーが並んでいない

```sql
SELECT GROUP BY member_id, gender --good

SELECT GROUP BY gender, member_id --bad
```

## JOINに問題がある
### 「Simple Equi-Joins」を心がけていない

```sql
SELECT a.date, b.name FROM
left_table a
JOIN right_table b
ON a.date = CAST((b.year * 10000 + b.month * 100 + b.day) as VARCHAR)
```

```sql
SELECT a.date, b.name 
FROM left_table a
JOIN (
  SELECT
    CAST((b.year * 10000 + b.month * 100 + b.day) as VARCHAR) AS date, name
  FROM right_table
) b
ON a.date = b.date  --Simple Equi-Join
```

### JOINの数が多い


### JOINの右側のテーブルサイズが大きい（Broadcast Joinを理解していない）



```sql
SELECT * FROM small_table, large_table
WHERE small_table.id = large_table.id
```
上記のクエリより下記のクエリのほうが効率が良くなります。
```sql
SELECT * FROM large_table, small_table
WHERE large_table.id = small_table.id
```

### CROSS JOINを使っている


### JOINキーのサイズが大きい



```sql
SELECT goods_id, slip.member_id, age
FROM sales_slip slip
JOIN
( 
  SELECT member_id, gender, age FROM master_members
) members
ON SMART_DIGEST(slip.member_id) = SMART_DIGEST(members.member_id)
WHERE TD_TIME_RANGE(time, '2011-01-01','2012-01-01','JST')
```


### Distributed Hash Joinを試していない

```sql
-- set session join_distribution_type = 'PARTITIONED'
SELECT ... FROM large_table l, small_table s WHERE l.id = s.id
```

## TD_TIME_RANGEでTime Indexの効用が効いていない


### 終点（end_time）が省略されている

```sql
SELECT ... WHERE TD_TIME_RANGE(time, '2013-01-01','JST') --NG
SELECT ... WHERE TD_TIME_RANGE(time, '2013-01-01', NULL, 'JST') --OK
```

### 引数内での計算で割り算をしている，結果がFLOAT型となる

```sql
SELECT ... WHERE TD_TIME_RANGE(time, '2013-01-01',
                               TD_TIME_ADD('2013-01-01', '1', 'JST')) --OK
SELECT ... WHERE TD_TIME_RANGE(time, TD_SCHEDULED_TIME() / 86400 * 86400)) --NG
SELECT ... WHERE TD_TIME_RANGE(time, 1356998401 / 86400 * 86400)) --NG
```

### （知らず知らずのうちに）OR節の中で使われている

```sql
SELECT * FROM table1
WHERE
  col1 < 100
  OR col2 is TRUE
  AND TD_TIME_RANGE(time, '2015-11-01')
```
上記のクエリは，下記のクエリと同等であり，ORの片方で使われるTD_TIME_RANGEによる効率化は効きません。
```sql
( col1 < 100 ) OR ( col2 is TRUE AND TD_TIME_RANGE(time, '2015-11-01') ) --NG
```
クエリの意図が先にORを適用させる場合であれば，以下のように書くことで効率化をはかれます。
```sql
( col1 < 100 OR col2 is TRUE ) AND TD_TIME_RANGE(time, '2015-11-01') --OK
```

## SELECT * を使っている

```sql
FROM a JOIN b
```
つまり，上記は以下と同等です。
```sql
FROM a JOIN ( SELECT * FROM b )
```
右側のテーブルが大きい場合には，クエリとしては長くなりますが，以下のように書きましょう。
```sql
FROM a JOIN ( SELECT col1, col2,... FROM b )
```

## 複数のLIKE表現が並んでいる

```sql
SELECT ...
FROM access_log
WHERE
  method LIKE '%GET%' OR
  method LIKE '%POST%' OR
  method LIKE '%PUT%' OR
  method LIKE '%DELETE%'
 ```
上記のクエリよりも，同結果が得られる下記のほうがパフォーマンスに優れています。
```sql
SELECT ...
FROM access_log
WHERE regexp_like(method, 'GET|POST|PUT|DELETE')
```

## Result Outputを使わず，クエリ内でCREATEやINSETを使う


### 既存のテーブルを上書き（Overwrite）する場合

```sql
DROP TABLE IF EXISTS my_result;
CREATE TABLE my_result AS
SELECT * FROM my_table
```

### 既存のテーブルに追記（Append）する場合

```sql
CREATE TABLE IF NOT EXISTS my_result(time bigint);
INSERT INTO my_result 
SELECT * FROM my_table
```
