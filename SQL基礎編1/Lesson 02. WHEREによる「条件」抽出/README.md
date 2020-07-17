# Lesson 02. WHEREによる「条件」抽出

## 比較演算子による条件抽出 [ WHERE ]

```sql
SELECT td_client_id, time
FROM sample_accesslog
WHERE td_client_id = 'f4d99634-4f1f-4e01-8d7f-9cd0a4a6613a'
LIMIT 10
```
|td_client_id|time       |
|------------|-----------|
|f4d99634-4f1f-4e01-8d7f-9cd0a4a6613a|1464572103 |
|f4d99634-4f1f-4e01-8d7f-9cd0a4a6613a|1464573326 |
|f4d99634-4f1f-4e01-8d7f-9cd0a4a6613a|1464570933 |

### 特定のtd_client_idを含まない

```sql
SELECT td_client_id, time
FROM sample_accesslog
WHERE td_client_id <> 'f4d99634-4f1f-4e01-8d7f-9cd0a4a6613a' --含まない
LIMIT 10
```
|td_client_id|time       |
|------------|-----------|
|32258bfe-444d-44fa-ad90-e71eea183008|1467187504 |
|c48672da-1b44-46a0-ab9d-c24cdbe9f146|1467190495 |
|3ee1cc12-5cc9-4b93-f1cb-31a4f3872d4e|1467187876 |

### 特定のtimeの値以上

```sql
SELECT td_client_id, time
FROM sample_accesslog
WHERE time >= 1463640700 --time の値が 1463640700 以上
LIMIT 10
```
|td_client_id|time       |
|------------|-----------|
|411b1c21-3e98-4a1a-a6cd-f41aaf69a5dc|1464239250 |
|2705c701-3b7c-4ef3-d88d-50529a3d1060|1466410889 |
|228e28e6-1753-4e69-b35f-5362fc725ec5|1464239515 |

### 特定のtimeより小さい

```sql
SELECT td_client_id, time
FROM sample_accesslog
WHERE time < 1463640700 -- time の値が 1463640700 より小さい
LIMIT 10
```
|td_client_id|time       |
|------------|-----------|
|c6c0c9cd-fd18-4c21-c795-5bca1ab63066|1462089548 |
|bdd71c57-06cf-4572-f504-eceadbec4e91|1462089432 |
|bdd71c57-06cf-4572-f504-eceadbec4e91|1462089362 |

## 複数の条件指定 [ WHERE A AND/OR/NOT B ]

### 特定のtd_client_idを含み，かつ特定のtimeの値以上

```sql
SELECT td_client_id, time
FROM sample_accesslog
WHERE td_client_id = 'f4d99634-4f1f-4e01-8d7f-9cd0a4a6613a'
AND time >= 1463640700
ORDER BY time
LIMIT 10
```
|td_client_id|time       |
|------------|-----------|
|f4d99634-4f1f-4e01-8d7f-9cd0a4a6613a|1463640700 |
|f4d99634-4f1f-4e01-8d7f-9cd0a4a6613a|1463640811 |
|f4d99634-4f1f-4e01-8d7f-9cd0a4a6613a|1463640889 |


### td_client_idの特定の3ユーザーのレコードのみ抽出

```sql
SELECT td_client_id, time
FROM sample_accesslog
WHERE td_client_id = 'f4d99634-4f1f-4e01-8d7f-9cd0a4a6613a'
OR td_client_id = '7f47d05f-bd12-4553-e69c-763064738631'
OR td_client_id = '780e865b-35f2-4e56-990a-5ed67cf733a3'
ORDER BY time
LIMIT 10
```
|td_client_id|time       |
|------------|-----------|
|780e865b-35f2-4e56-990a-5ed67cf733a3|1461348266 |
|780e865b-35f2-4e56-990a-5ed67cf733a3|1461348343 |
|780e865b-35f2-4e56-990a-5ed67cf733a3|1461348350 |


```sql
SELECT DISTINCT td_client_id
FROM
(
  SELECT td_client_id, time
  FROM sample_accesslog
  WHERE
     td_client_id = 'f4d99634-4f1f-4e01-8d7f-9cd0a4a6613a'
  OR td_client_id = '7f47d05f-bd12-4553-e69c-763064738631'
  OR td_client_id = '780e865b-35f2-4e56-990a-5ed67cf733a3'
)
```
|td_client_id|
|------------|
|f4d99634-4f1f-4e01-8d7f-9cd0a4a6613a|
|7f47d05f-bd12-4553-e69c-763064738631|
|780e865b-35f2-4e56-990a-5ed67cf733a3|


### td_client_idの特定の3ユーザーのみで，かつ特定のtimeより大きい

```sql
SELECT td_client_id, time
FROM sample_accesslog
WHERE
( 
     td_client_id = 'f4d99634-4f1f-4e01-8d7f-9cd0a4a6613a'
  OR td_client_id = '7f47d05f-bd12-4553-e69c-763064738631'
  OR td_client_id = '780e865b-35f2-4e56-990a-5ed67cf733a3'
)
AND time >= 1463640700
ORDER BY time
LIMIT 10
```
|td_client_id|time      |
|------------|----------|
|f4d99634-4f1f-4e01-8d7f-9cd0a4a6613a|1463640700|
|f4d99634-4f1f-4e01-8d7f-9cd0a4a6613a|1463640811|
|f4d99634-4f1f-4e01-8d7f-9cd0a4a6613a|1463640889|

　　
### td_client_idの特定の3ユーザー「以外」のユーザーで，かつ特定のtimeより大きい

```sql
SELECT td_client_id, time
FROM sample_accesslog
WHERE
NOT ( 
     td_client_id = 'f4d99634-4f1f-4e01-8d7f-9cd0a4a6613a'
  OR td_client_id = '7f47d05f-bd12-4553-e69c-763064738631'
  OR td_client_id = '780e865b-35f2-4e56-990a-5ed67cf733a3'
)
AND time >= 1463640700
ORDER BY time
LIMIT 10
```
|td_client_id|time      |
|------------|----------|
|749cd3ba-e549-4fc7-9c83-0263999fa8bf|1463640703|
|749cd3ba-e549-4fc7-9c83-0263999fa8bf|1463640724|
|6c94bf0f-39de-4ee2-fc29-f0af74475b71|1463640735|


```sql
SELECT td_client_id, time
FROM sample_accesslog
WHERE
( 
      td_client_id != 'f4d99634-4f1f-4e01-8d7f-9cd0a4a6613a'
  AND td_client_id != '7f47d05f-bd12-4553-e69c-763064738631'
  AND td_client_id != '780e865b-35f2-4e56-990a-5ed67cf733a3'
)
AND time >= 1463640700
ORDER BY time
LIMIT 10
```
|td_client_id|time      |
|------------|----------|
|749cd3ba-e549-4fc7-9c83-0263999fa8bf|1463640703|
|749cd3ba-e549-4fc7-9c83-0263999fa8bf|1463640724|
|6c94bf0f-39de-4ee2-fc29-f0af74475b71|1463640735|


# 範囲演算子BETWEENによる条件抽出 [ WHERE BETWEEN A AND B ]


```sql
SELECT td_client_id, time
FROM sample_accesslog
WHERE
( 
     td_client_id = 'f4d99634-4f1f-4e01-8d7f-9cd0a4a6613a'
  OR td_client_id = '7f47d05f-bd12-4553-e69c-763064738631'
  OR td_client_id = '780e865b-35f2-4e56-990a-5ed67cf733a3'
)
AND time BETWEEN 1463640700 AND 1463727100
ORDER BY time
LIMIT 10
```
|td_client_id|time      |
|------------|----------|
|f4d99634-4f1f-4e01-8d7f-9cd0a4a6613a|1463640700|
|f4d99634-4f1f-4e01-8d7f-9cd0a4a6613a|1463640811|
|f4d99634-4f1f-4e01-8d7f-9cd0a4a6613a|1463640889|


# IN演算子による条件抽出 [ WHERE IN (A,B)  ]


```sql
SELECT td_client_id, time
FROM sample_accesslog
WHERE
td_client_id IN 
( 
  'f4d99634-4f1f-4e01-8d7f-9cd0a4a6613a',
  '7f47d05f-bd12-4553-e69c-763064738631',
  '780e865b-35f2-4e56-990a-5ed67cf733a3'
)
AND time BETWEEN 1463640700 AND 1463727100
ORDER BY time
LIMIT 10
```
|td_client_id|time      |
|------------|----------|
|f4d99634-4f1f-4e01-8d7f-9cd0a4a6613a|1463640700|
|f4d99634-4f1f-4e01-8d7f-9cd0a4a6613a|1463640811|
|f4d99634-4f1f-4e01-8d7f-9cd0a4a6613a|1463640889|


```sql
SELECT td_client_id, time
FROM sample_accesslog
WHERE
td_client_id NOT IN 
( 
  'f4d99634-4f1f-4e01-8d7f-9cd0a4a6613a',
  '7f47d05f-bd12-4553-e69c-763064738631',
  '780e865b-35f2-4e56-990a-5ed67cf733a3'
)
AND time BETWEEN 1463640700 AND 1463727100
ORDER BY time
LIMIT 10
```
|td_client_id|time      |
|------------|----------|
|749cd3ba-e549-4fc7-9c83-0263999fa8bf|1463640703|
|749cd3ba-e549-4fc7-9c83-0263999fa8bf|1463640724|
|6c94bf0f-39de-4ee2-fc29-f0af74475b71|1463640735|

## IS NULLの重要性 [ WHERE A IS (NOT) NULL ]

```sql
SELECT a
FROM ( VALUES FALSE, TRUE, NULL ) AS t(a)
```
|a         |
|----------|
|false     |
|true      |
|NULL      |


```sql
SELECT a
FROM ( VALUES FALSE, TRUE, NULL ) AS t(a)
WHERE a = NULL
```

```sql
SELECT a
FROM ( VALUES FALSE, TRUE, NULL ) AS t(a)
WHERE a IS NULL
```
|a         |
|----------|
|NULL      |


```sql
SELECT a
FROM ( VALUES FALSE, TRUE, NULL ) AS t(a)
WHERE a IS NOT NULL
```
|a         |
|----------|
|false     |
|true      |

```sql
SELECT a
FROM ( VALUES 0, 1, NULL ) AS t(a)
```
|a         |
|----------|
|0     |
|1      |
|NULL      |


```sql
SELECT a, a = NULL AS eq_null, a IS NULL AS is_null
FROM ( VALUES 0, 1, NULL ) AS t(a)
```
|a         |eq_null|is_null|
|----------|-------|-------|
|0         |NULL   |false  |
|1         |NULL   |false  |
|NULL      |NULL   |true   |


```sql
SELECT a
FROM ( VALUES 0, 1, NULL ) AS t(a)
WHERE a = NULL
```


```sql
SELECT a
FROM ( VALUES 0, 1, NULL ) AS t(a)
WHERE a IS NULL
```
|a         |
|----------|
|NULL      |


```sql
SELECT a
FROM ( VALUES 0, 1, NULL ) AS t(a)
WHERE a IS NOT NULL
```
|a         |
|----------|
|0     |
|1      |



```sql
SELECT a, a = NULL AS eq_null, a IS NULL AS is_null
FROM ( VALUES '', ' ', NULL ) AS t(a)
```
|a         |eq_null|is_null|
|----------|-------|-------|
|          |NULL   |false  |
|          |NULL   |false  |
|          |NULL   |true   |


## IS DISTINCT FROMの重要性 [ WHERE A IS (NOT) DISTINCT FROM B ]

```sql
SELECT a, b
FROM 
( 
  VALUES
    (1, 1), (1, 2), (1, NULL), (NULL, NULL)
) AS t(a,b)
```
|a         |b   |
|----------|----|
|1         |1   |
|1         |2   |
|1         |NULL|
|NULL      |NULL|


### NULLとNULLを同じとみなしてくれない（無条件にNULL）

```sql
SELECT a, b
FROM 
( 
  VALUES (1, 1), (1, 2), (1, NULL), (NULL, NULL)
) AS t(a,b)
WHERE a = b
```
|a         |b   |
|----------|----|
|1         |1   |


### NULLとその他の値を異なるとみなしてくれない（無条件にNULL）

```sql
SELECT a, b
FROM 
( 
  VALUES (1, 1), (1, 2), (1, NULL), (NULL, NULL)
) AS t(a,b)
WHERE a <> b
```
|a         |b   |
|----------|----|
|1         |2   |



### A IS [NOT] B は使えない

```sql
SELECT a, b
FROM
( 
  VALUES (1, 1), (1, 2), (1, NULL), (NULL, NULL)
) AS t(a,b)
WHERE a IS b -- エラー（a IS NOT NULLも同様）
```


### NULLとNULLを同じとみなしてくれる比較クエリ

```sql
SELECT a, b
FROM
( 
  VALUES (1, 1), (1, 2), (1, NULL), (NULL, NULL)
) AS t(a,b)
WHERE a IS NOT DISTINCT FROM b
```
|a         |b   |
|----------|----|
|1         |1   |
|NULL      |NULL|


### NULLと他の値を異なるとみなしてくれる比較クエリ

```sql
SELECT a, b
FROM
( 
  VALUES (1, 1), (1, 2), (1, NULL), (NULL, NULL)
) AS t(a,b)
WHERE a IS DISTINCT FROM b
```
|a         |b   |
|----------|----|
|1         |2   |
|1         |NULL|


## LIKEによる文字列の部分一致 [ WHERE A LIKE pattern ]

```sql
SELECT DISTINCT td_os
FROM sample_accesslog
WHERE td_os LIKE '_indows%'
```
|td_os     |
|----------|
|Windows 7 |
|Windows 8 |
|Windows Phone|
|Windows XP|
|Windows Vista|
|Windows RT 8.1|
|Windows   |
|Windows 8.1|


```sql
SELECT DISTINCT td_os
FROM sample_accesslog
WHERE td_os LIKE 'windows'
```


```sql
SELECT DISTINCT td_os
FROM sample_accesslog
WHERE td_os LIKE 'Windows'
```
|td_os     |
|----------|
|Windows   |



```sql
SELECT DISTINCT td_os
FROM sample_accesslog
WHERE td_os LIKE 'Windows%' --または '%windows%'
```
|td_os     |
|----------|
|Windows 8.1|
|Windows RT 8.1|
|Windows 7 |
|Windows 8 |
|Windows Vista|
|Windows   |
|Windows Phone|
|Windows XP|


```sql
SELECT DISTINCT td_os
FROM sample_accesslog
WHERE td_os 
LIKE 'Windows%8%'
```
|td_os     |
|----------|
|Windows 8.1|
|Windows RT 8.1|
|Windows 8 |


```sql
SELECT DISTINCT td_os
FROM sample_accesslog
WHERE td_os 
LIKE 'Windows_8%'
```
|td_os     |
|----------|
|Windows 8.1|
|Windows 8 |

