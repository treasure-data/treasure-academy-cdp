# Lesson 06. 文字列関数，正規表現

## 文字列の情報を得る関数

### LENGTH(string) → bigint：文字列の長さを取得する

```sql
SELECT s, LENGTH(s) AS num_of_digits
FROM (
  VALUES '1','10','100','1000'
) AS t(s)
```
|s   |num_of_digits|
|----|-------------|
|1   |1            |
|10  |2            |
|100 |3            |
|1000|4            |


### CHR(n) → varchar：改行コードやタブを文字列に加える

|文字  |文字コード表記|補足   |
|----|-------|-----|
|タブ  |CHR(9) |\t 相当|
|CR  |CHR(13)|\r 相当（CTRL+M）|
|LF  |CHR(10)|\n 相当（CTRL+J）|
|改行  |CHR(13) &#124;&#124; CHR(10)|Windowsプラットフォーム|
|    |CHR(10)|UNIX，LINUX系プラットフォーム|
|スペース|CHR(32)|     |
|引用符（'）|CHR(39)|     |

```sql
-- I  have a 'pen'.
-- I have an 'apple'.
SELECT 'I'||CHR(32)||CHR(32)||'have'||CHR(32)||'a'||CHR(32)||CHR(39)||'pen'||CHR(39)||'.'||CHR(10)||'I'||CHR(32)||'have'||CHR(32)||'an'||CHR(32)||CHR(39)||'apple'||CHR(39) ||'.' AS pico
```
|pico|
|----|
|I  have a 'pen'. I have an 'apple'.|


### POSITION(substring IN string)，STRPOS(string, substring) → bigint：部分文字列の登場位置を調べる


```sql
SELECT POSITION('pen' IN 'I have a pen') AS pos1, STRPOS('I have a pen', 'pen') AS pos2, STRPOS('pen', 'I have a pen') AS pos_wrong
```
|pos1|pos2|pos_wrong|
|----|----|---------|
|10  |10  |0        |


### LEVENSHTEIN_DISTANCE(string1, string2)，HAMMING_DISTANCE(string1, string2) → bigint：2つの文字列の類似度を数値化する


```sql
SELECT HAMMING_DISTANCE('1111111','1010101') AS dist_ham1, HAMMING_DISTANCE('lunch','punch') AS dist_ham2
```
|dist_ham1|dist_ham2|
|---------|---------|
|3        |1        |


```sql
SELECT LEVENSHTEIN_DISTANCE(    'apple', 'pineapple') AS dist_lev1,
       LEVENSHTEIN_DISTANCE('pineapple',  'applepen') AS dist_lev2
```
|dist_lev1|dist_lev2|
|---------|---------|
|4        |7        |


## 文字列を整形する関数

### TRIM(string)，RTRIM(string)，LTRIM(string) → varchar：文字列の前後の余計な空白（タブ，改行）を除去する


```sql
SELECT s, TRIM(s) AS trim_str, RTRIM(s) AS rtrim_str, LTRIM(s) AS ltrim_str
FROM ( VALUES CHR(9)||' Pine Apple '||CHR(10)) AS t(s)
```
|s   |trim_str|rtrim_str|ltrim_str   |
|----|--------|---------|------------|
|→Pine Apple ⏎|Pine Apple|→Pine Apple|Pine Apple ⏎|

### LOWER(string)，UPPER(string) → varchar：文字列の全部を小文字／大文字に変換する

```sql
SELECT LOWER(s) AS lower_str, UPPER(s) AS upper_str
FROM ( VALUES 'PineApple') AS t(s)
```
|lower_str|upper_str|
|---------|---------|
|pineapple|PINEAPPLE|


## 文字列を加工する関数

### ||，CONCAT(string1, ..., stringN) → varchar：文字列を結合する


```sql
SELECT s1, s2, s3, s1||'_'||s2||'_'||s3 AS concat_str1, CONCAT(s1,'_',s2,'_',s3) AS concat_str2
FROM (
  VALUES 
    ('A', 'a', '1'),
    ('B', 'b', '2'),
    ('C', 'c', '3'),
    ('D', 'd', '4')
) AS t(s1,s2,s3)
```
|s1  |s2 |s3 |concat_str1|concat_str2|
|----|---|---|-----------|-----------|
|A   |a  |1  |A_a_1      |A_a_1      |
|B   |b  |2  |B_b_2      |B_b_2      |
|C   |c  |3  |C_c_3      |C_c_3      |
|D   |d  |4  |D_d_4      |D_d_4      |


### SUBSTR(string, start, length) → varchar：部分文字列を抜き出す


```sql
SELECT s, SUBSTR(s,1,7) AS os, TRIM(SUBSTR(s,8)) AS version
FROM (
  VALUES
    'Windows',
    'Windows 7',
    'Windows 8',
    'Windows 8.1',
    'Windows Phone',
    'Windows RT 8.1',
    'Windows Vista',
    'Windows XP'
) AS t(s)
```
|s   |os |version|
|----|---|-------|
|Windows|Windows|       |
|Windows 7|Windows|7      |
|Windows 8|Windows|8      |
|Windows 8.1|Windows|8.1    |
|Windows Phone|Windows|Phone  |
|Windows RT 8.1|Windows|RT 8.1 |
|Windows Vista|Windows|Vista  |
|Windows XP|Windows|XP     |


### LPAD(string, size, padstring)，RPAD(string, size, padstring) → varchar：特定の長さになるまで文字列を埋める

```sql
SELECT s, LPAD(s,4,'0') AS pad_str
FROM (
  VALUES '1','10','100','1000'
) AS t(s)
```
|s   |pad_str|
|----|-------|
|1   |0001   |
|10  |0010   |
|100 |0100   |
|1000|1000   |


### （応用）異なる接頭辞と異なる桁数の数値からなる文字列を並び替え可能にする


```sql
WITH sample AS
(
  SELECT s
  FROM (
    VALUES 'am1','fm10','am100','fm1000'
  ) AS t(s)
)

SELECT REGEXP_EXTRACT(s,'^[^0-9]*') AS prefix, REGEXP_EXTRACT(s,'[0-9]*$') AS num_str
FROM sample
```
|prefix|num_str|
|------|-------|
|am    |1      |
|fm    |10     |
|am    |100    |
|fm    |1000   |


```sql
WITH sample AS
(
  SELECT s
  FROM (
    VALUES 'am1','fm10','am100','fm1000'
  ) AS t(s)
),
split_sample AS
(
  SELECT REGEXP_EXTRACT(s,'^[^0-9]*') AS prefix, REGEXP_EXTRACT(s,'[0-9]*$') AS num_str
  FROM sample
)

SELECT MAX(length(num_str)) AS max_len
FROM split_sample
```
|max_len|
|-------|
|4      |


```sql
WITH sample AS
(
  SELECT s
  FROM (
    VALUES 'am1','fm10','am100','fm1000'
  ) AS t(s)
),
split_sample AS
(
  SELECT REGEXP_EXTRACT(s,'^[^0-9]*') AS prefix, REGEXP_EXTRACT(s,'[0-9]*$') AS num_str
  FROM sample
),
stat AS
(
  SELECT MAX(length(num_str)) AS max_len
  FROM split_sample
)

SELECT prefix || LPAD(num_str, max_len, '0') AS s_can_sort
FROM split_sample,stat
ORDER BY s_can_sort
```
|s_can_sort|
|----------|
|am0001    |
|am0100    |
|fm0010    |
|fm1000    |


### SPLIT(string, delimiter) → array，SPLIT_PART(string, delimiter, index) → varchar：文字列を分割する


```sql
SELECT s, 
  SPLIT(s,' ') AS splitted_strs, 
  SPLIT_PART(s,' ',1) AS os, 
  SPLIT_PART(s,' ',2) AS version
FROM (
  VALUES
    'Windows',
    'Windows 7',
    'Windows 8',
    'Windows 8.1',
    'Windows Phone',
    'Windows RT 8.1',
    'Windows Vista',
    'Windows XP'
) AS t(s)
```
|s   |splitted_strs           |os     |version|
|----|------------------------|-------|-------|
|Windows|["Windows"]             |Windows|       |
|Windows 7|["Windows", "7"]        |Windows|7      |
|Windows 8|["Windows", "8"]        |Windows|8      |
|Windows 8.1|["Windows", "8.1"]      |Windows|8.1    |
|Windows Phone|["Windows", "Phone"]    |Windows|Phone  |
|Windows RT 8.1|["Windows", "RT", "8.1"]|Windows|RT     |
|Windows Vista|["Windows", "Vista"]    |Windows|Vista  |
|Windows XP|["Windows", "XP"]       |Windows|XP     |


## 正規表現の基礎を学ぶ

### 正規表現文字

|構文  |Matches|
|----|-------|
|\t  |タブ文字（'\u0009'）|
|\n  |改行文字（'\u000A'）|
|\r  |キャリッジリターン文字（'\u000D'）|
|\f  |用紙送り文字（'\u000C'）|
|\a  |警告（ベル）文字（'\u0007'）|
|\e  |エスケープ文字（'\u001B'）|

### 文字クラス（基本）

|構文  |Matches|
|----|-------|
|[abc]|a，b，またはc|
|[^abc]|a，b，c以外の文字（否定）|
|[a-zA-Z]|a〜zまたはA〜Z（範囲）|
|[a-d[m-p]]|a〜dまたはm〜p（[a-dm-p]と同じ）（結合）|
|[a-z&&[def]]|d，e，f（交差）|
|[a-z&&[^bc]]|bとcを除くa〜z（ [ad-z]と同じ）（減算）|
|[a-z&&[^m-p]]|m〜pを除くa〜z（ [a-lq-z]と同じ）（減算）|

### 定義済みの文字クラス

|構文  |Matches|
|----|-------|
|.   |任意の文字（行末記号とマッチする場合もある）|
|\d  |数字：[0-9]|
|\D  |数字以外：[^0-9]|
|\s  |空白文字：[\t\n\x0B\f\r]|
|\S  |非空白文字：[^\s]|
|\w  |単語構成文字：[a-zA-Z0-9_]（アルファベット，数字，_）|
|\W  |非単語文字：[^\w]|

#### 任意の文字が2文字目にくる4文字のパターン
```sql
'a.cd'
```
マッチする文字列
```sql
abcd
a1cd
a_cd
```
マッチしない文字列
```sql
abbcd # a と cd の間に2文字以上ある
abc   # d がない
acd   # a と cd の間に0文字
```
確認クエリ
```sql
SELECT str, REGEXP_LIKE(str,'a.cd') AS is_matched
FROM (
  VALUES 'abcd', 'a1cd', 'a_cd', 'abbcd', 'abc', 'acd'
) AS t(str)
```
|str |is_matched              |
|----|------------------------|
|abcd|true                    |
|a1cd|true                    |
|a_cd|true                    |
|abbcd|false                   |
|abc |false                   |
|acd |false                   |


#### 数字が2文字目にくる4文字のパターン
```sql
'a[\d]cd', 'a[0-9]cd' 
```
マッチする文字列
```sql
a1cd
```
マッチしない文字列
```sql
abcd  # a と cd の間が数字でない
a1c   # c の後に d がない
a12cd # a と cd の間に2文字以上
```
確認クエリ
```sql
SELECT str, 
  REGEXP_LIKE(str,'a[\d]cd')  AS is_matched, 
  REGEXP_LIKE(str,'a[0-9]cd') AS is_matched
FROM (
  VALUES 'a1cd', 'abcd', 'a1c', 'a12cd'
) AS t(str)
```
|str |is_matched              |is_matched|
|----|------------------------|----------|
|a1cd|true                    |true      |
|abcd|false                   |false     |
|a1c |false                   |false     |
|a12cd|false                   |false     |


#### 数字以外の文字が2文字目にくる4文字のパターン

```sql
'a[^\d]cd', 'a[\D]cd', 'a[^0-9]cd'
```

マッチする文字列
```sql
abcd
a_cd
```

マッチしない文字列
```sql
a1cd  # a と cd の間が数字
abbcd # a と cd の間に2文字以上ある
acd   # a と cd の間に0文字
```
確認クエリ
```sql
SELECT str, 
  REGEXP_LIKE(str,'a[^\d]cd')  AS is_matched, 
  REGEXP_LIKE(str,'a[\D]cd')   AS is_matched,
  REGEXP_LIKE(str,'a[^0-9]cd') AS is_matched
FROM (
  VALUES 'abcd', 'a_cd', 'a1cd', 'abbcd', 'acd'
) AS t(str)
```
|str |is_matched              |is_matched|is_matched|
|----|------------------------|----------|----------|
|abcd|true                    |true      |true      |
|a_cd|true                    |true      |true      |
|a1cd|false                   |false     |false     |
|abbcd|false                   |false     |false     |
|acd |false                   |false     |false     |


### 数量子（1. 最長一致）
|構文  |Matches|
|----|-------|
|X?  |Xが1または0回|
|X*  |Xが0回以上 |
|X+  |Xが1回以上 |
|X{n}|Xがn回   |
|X{n,}|Xがn回以上 |
|X{n,m}|Xがn回以上，m回以下|

まずは「?」を含むパターンについて例を用いて検証していきましょう。

#### bの0〜1回の繰り返しを挟むパターン

```sql
'ab?cd'
```

マッチする文字列（「[ ]」はマッチする部分を示す）

```sql
[acd]
[abcd]
[abcd][acd]
```

マッチしない文字列

```sql
abbcd   # b が2回以上
abbbcd  # b が2回以上
ab1cd   # a と cd の間に b と b 以外の文字がある
```

確認クエリ

```sql
SELECT str, 
  REGEXP_EXTRACT_ALL(str,'ab?cd') AS matched
FROM (
  VALUES 'acd', 'abcd', 'abcdacd', 'abbcd', 'abbbcd', 'ab1cd'
) AS t(str)
```
|str |matched                 |
|----|------------------------|
|acd |["acd"]                 |
|abcd|["abcd"]                |
|abcdacd|["abcd", "acd"]         |
|abbcd|[]                      |
|abbbcd|[]                      |
|ab1cd|[]                      |


#### bcの0〜1回の繰り返しを挟むパターン

1文字の繰り返しでなく，文字列の繰り返しを記述するためには，繰り返したい文字列を「( )」で括って次のようにします。
```sql
'a(bc)?d'
```

マッチする文字列（「[ ]」はマッチする部分を示す）

```sql
[ad]     # (bc) は含まれなくてもよい
[abcd]
```

マッチしない文字列

```sql
abd    # (bc) がない
acd    # (bc) がない
abce   # a(bc) の後が d でなく e
abcexd # a(bc) と d の間の x が邪魔
abcbce # (bc) が2回挟まっている
```

確認クエリ
```sql
SELECT str, 
  REGEXP_EXTRACT_ALL(str,'a(bc)?d') AS matched
FROM (
  VALUES 'ad', 'abd', 'acd', 'abcd', 'abce', 'abcxd', 'abcbcd'
) AS t(str)
```
|str |matched                 |
|----|------------------------|
|ad  |["ad"]                  |
|abd |[]                      |
|acd |[]                      |
|abcd|["abcd"]                |
|abce|[]                      |
|abcxd|[]                      |
|abcbcd|[]                      |


#### bかcの0〜1回の繰り返しを挟むパターン

複数の文字のいずれかの繰り返しを記述するためには，「[ ]」による文字クラスを使います。

```sql
'a[bc]?d'
```

マッチする文字列（「[ ]」はマッチする部分を示す）
```sql
[ad]
[abd]
[acd]
[abd]e
```
マッチしない文字列
```sql
abcd    # b か c が2回挟まっている
abbd    # b か c が2回挟まっている
```

確認クエリ
```sql
SELECT str, 
  REGEXP_EXTRACT_ALL(str,'a[bc]?d') AS matched
FROM (
  VALUES 'ad', 'abd', 'acd', 'acde', 'abcd', 'abbd'
) AS t(str)
```
|str |matched                 |
|----|------------------------|
|ad  |["ad"]                  |
|abd |["abd"]                 |
|acd |["acd"]                 |
|acde|["acd"]                 |
|abcd|[]                      |
|abbd|[]                      |


#### 0〜1回の数字の繰り返しを挟むパターン

数字などの文字クラスも繰り返しの対象にできます。
```sql
'X[\d]?Y[\d]?'
```

マッチする文字列（「[ ]」はマッチする部分を示す）

```sql
[XY]
[X1Y]
[X1Y2]3
```

マッチしない文字列
```sql
X123Y # X と Y の間に数字が3回挟まっている
```

確認クエリ
```sql
SELECT str, 
  REGEXP_EXTRACT_ALL(str,'X[\d]?Y[\d]?') AS matched
FROM (
  VALUES 'XY','X1Y','X123Y','X1Y23'
) AS t(str)
```
|str |matched                 |
|----|------------------------|
|XY  |["XY"]                  |
|X1Y |["X1Y"]                 |
|X123Y|[]                      |
|X1Y23|["X1Y2"]                |


ここまでは「?」を含むパターンの例を見てきました。ここからは，「*」（0回以上の繰り返し）を含むパターンについて例を使って検証していきます。

#### bの0回以上の繰り返しを挟むパターン
```sql
'ab*cd'
```

マッチする文字列（「[ ]」はマッチする部分を示す）

```sql
[acd]
[abcd]
[abcd][acd]
[abbcd]
[abbbcd]
```

マッチしない文字列

```sql
ab1cd   # a と cd の間に b と b 以外の文字がある
```

確認クエリ
```sql
SELECT str, 
  REGEXP_EXTRACT_ALL(str,'ab*cd') AS matched
FROM (
  VALUES 'acd', 'abcd', 'abcdacd', 'abbcd', 'abbbcd', 'ab1cd'
) AS t(str)
```
|str |matched                 |
|----|------------------------|
|acd |["acd"]                 |
|abcd|["abcd"]                |
|abcdacd|["abcd", "acd"]         |
|abbcd|["abbcd"]               |
|abbbcd|["abbbcd"]              |
|ab1cd|[]                      |


#### bcの0回以上の繰り返しを挟むパターン

```sql
'a(bc)*d'
```

マッチする文字列（「[ ]」はマッチする部分を示す）
```sql
[ad]     # (bc) は含まれなくてもよい
[abcd]
[abcbcd]
```

マッチしない文字列

```sql
abd    # (bc) がない
acd    # (bc) がない
abcxd  # a(bc) と d の間の x が邪魔
abcbce # a(bc)(bc) の後が d でなく e
```

確認クエリ
```sql
SELECT str, 
  REGEXP_EXTRACT_ALL(str,'a(bc)*d') AS matched
FROM (
  VALUES 'ad', 'abd', 'acd', 'abcd', 'abcxd', 'abcbcd', 'abcbce'
) AS t(str)
```
|str |matched                 |
|----|------------------------|
|ad  |["ad"]                  |
|abd |[]                      |
|acd |[]                      |
|abcd|["abcd"]                |
|abcxd|[]                      |
|abcbcd|["abcbcd"]              |
|abcbce|[]                      |


#### bかcの0回以上の繰り返しを挟むパターン
```sql
'a[bc]*d'
```

マッチする文字列（「[ ]」はマッチする部分を示す）

```sql
[ad]
[abd]
[acd]
[abcd]
[abcbbcd]
```

マッチしない文字列
```sql
abce    # d で終わらず e で終わっている
```

確認クエリ
```sql
SELECT str, 
  REGEXP_EXTRACT_ALL(str,'a[bc]*d') AS matched
FROM (
  VALUES 'ad', 'abd', 'acd', 'abcd', 'abcbbcd', 'abce'
) AS t(str)
```
|str |matched                 |
|----|------------------------|
|ad  |["ad"]                  |
|abd |["abd"]                 |
|acd |["acd"]                 |
|abcd|["abcd"]                |
|abcbbcd|["abcbbcd"]             |
|abce|[]                      |


#### 数字の0回以上の繰り返しを挟むパターン

```sql
'X[\d]*Y[\d]*'
```

マッチする文字列（「[ ]」はマッチする部分を示す）

```sql
[XY]
[X1Y]
[X1Y23]
[X123Y]
```

マッチしない文字列

```sql
X12Z34Y # 12 と 34 の間に文字が挟まっている
```

確認クエリ
```sql
SELECT str, 
  REGEXP_EXTRACT_ALL(str,'X[\d]*Y[\d]*') AS matched
FROM (
  VALUES 'XY','X1Y','X123Y','X1Y23','X12Z34Y'
) AS t(str)
```
|str |matched                 |
|----|------------------------|
|XY  |["XY"]                  |
|X1Y |["X1Y"]                 |
|X123Y|["X123Y"]               |
|X1Y23|["X1Y23"]               |
|X12Z34Y|[]                      |


ここからは，「+」（1回以上の繰り返し）を含むパターンを例を用いて検証します。

#### bの1回以上の繰り返しを挟むパターン
```sql
'ab+cd'
```

マッチする文字列（「[ ]」はマッチする部分を示す）

```sql
[abcd]
[abcd]acd
[abbcd]
[abbbcd]
```

マッチしない文字列

```sql
acd   # a と cd の間に b がない
ab1cd # a と cd の間に b と b 以外の文字がある
```

確認クエリ
```sql
SELECT str, 
  REGEXP_EXTRACT_ALL(str,'ab+cd') AS matched
FROM (
  VALUES 'acd', 'abcd', 'abcdacd', 'abbcd', 'abbbcd', 'ab1cd'
) AS t(str)
```
|str |matched                 |
|----|------------------------|
|acd |[]                      |
|abcd|["abcd"]                |
|abcdacd|["abcd"]                |
|abbcd|["abbcd"]               |
|abbbcd|["abbbcd"]              |
|ab1cd|[]                      |


#### abの1回以上の繰り返しを挟むパターン
```sql
'(ab)+cd'
```

マッチする文字列（「[ ]」はマッチする部分を示す）

```sql
[abcd]   # (ab)cd
[ababcd] # (ab)(ab)cd
```

マッチしない文字列
```sql
bcd     # (ab) ではなく b のみ
abbcd   # (ab) と cd の間に (ab) でなく b のみ
ababxcd # (ab)(ab) と cd の間の x が邪魔
```
確認クエリ
```sql
SELECT str, 
  REGEXP_EXTRACT_ALL(str,'(ab)+cd') AS matched
FROM (
  VALUES 'bcd', 'abcd', 'abbcd', 'ababcd', 'ababxcd'
) AS t(str)
```
|str |matched                 |
|----|------------------------|
|bcd |[]                      |
|abcd|["abcd"]                |
|abbcd|[]                      |
|ababcd|["ababcd"]              |
|ababxcd|[]                      |


#### bかcの1回以上の繰り返しを挟むパターン

```sql
'a[bc]+d'
```
マッチする文字列（「[ ]」はマッチする部分を示す）
```sql
[abd]
[acd]
[abcd]
[abcbd]
```
マッチしない文字列

```sql
ad    # b か c が 1 回も挟まらない
abce  # d で終わらず e で終わっている
```

確認クエリ

```sql
SELECT str, 
  REGEXP_EXTRACT_ALL(str,'a[bc]+d') AS matched
FROM (
  VALUES 'ad', 'abd', 'acd', 'abcd', 'abce', 'abcbd'
) AS t(str)
```
|str |matched                 |
|----|------------------------|
|ad  |[]                      |
|abd |["abd"]                 |
|acd |["acd"]                 |
|abcd|["abcd"]                |
|abce|[]                      |
|abcbd|["abcbd"]               |


#### 数字の1回以上の繰り返しを挟まむパターン
```sql
'X[\d]+Y[\d]*'
```
マッチする文字列（「[ ]」はマッチする部分を示す）
```sql
[X1Y]
[X1Y23]
[X123Y]
```
マッチしない文字列
```sql
XY      # 数字が1回も挟まっていない
X12Z34Y # 12 と 34 の間に文字が挟まっている
```
確認クエリ
```sql
SELECT str, 
  REGEXP_EXTRACT_ALL(str,'X[\d]+Y[\d]*') AS matched
FROM (
  VALUES 'XY','X1Y','X123Y','X1Y23','X12Z34Y'
) AS t(str)
```
|str |matched                 |
|----|------------------------|
|XY  |[]                      |
|X1Y |["X1Y"]                 |
|X123Y|["X123Y"]               |
|X1Y23|["X1Y23"]               |
|X12Z34Y|[]                      |


ここからは，{n,m}（n回以上m回以下の繰り返し）を含むパターンについて例を用いて検証します。

#### bに対する{n,m}の繰り返しを挟んだパターンの例

マッチする文字列（「[ ]」はマッチする部分を示す）

```sql
'ab{3}cd'   # b が3回（ちょうど）含まれる ⇒ [abbbcd]
'ab{1,}cd'  # b が1回以上含まれる ⇒ [abcd], [abcd]acd, [abbcd], [abbbcd]
'ab{1,2}cd' # b が1回から2回含まれる ⇒ [abcd], [abcd]acd, [abbcd]
'ab{0,2}cd' # b が0回から2回含まれる ⇒ [acd], [abcd], [abcd][acd], [abbcd]
```

確認クエリ
```sql
SELECT str, 
  REGEXP_EXTRACT_ALL(str,'ab{3}cd')   AS m1,
  REGEXP_EXTRACT_ALL(str,'ab{1,}cd')  AS m2,
  REGEXP_EXTRACT_ALL(str,'ab{1,2}cd') AS m3,
  REGEXP_EXTRACT_ALL(str,'ab{0,2}cd') AS m4
FROM (
  VALUES 'acd', 'abcd', 'abcdacd', 'abbcd', 'abbbcd', 'ab1cd'
) AS t(str)
```
|str |m1                      |m2        |m3       |m4             |
|----|------------------------|----------|---------|---------------|
|acd |[]                      |[]        |[]       |["acd"]        |
|abcd|[]                      |["abcd"]  |["abcd"] |["abcd"]       |
|abcdacd|[]                      |["abcd"]  |["abcd"] |["abcd", "acd"]|
|abbcd|[]                      |["abbcd"] |["abbcd"]|["abbcd"]      |
|abbbcd|["abbbcd"]              |["abbbcd"]|[]       |[]             |
|ab1cd|[]                      |[]        |[]       |[]             |


#### (ab)に対する{n,m}の繰り返しを挟んだパターンの例
マッチする文字列（「[ ]」はマッチする部分を示す）
```sql
'(ab){2}cd'   # (ab) が2回（ちょうど）含まれる ⇒ [(ab)(ab)cd]
'(ab){1,}cd'  # (ab) が1回以上含まれる ⇒ [(ab)cd], [(ab)(ab)cd]
'(ab){1,2}cd' # (ab) が1回から2回含まれる ⇒ [(ab)cd], [(ab)(ab)cd]
'(ab){0,2}cd' # (ab) が0回から2回含まれる ⇒ a[cd], b[cd], [abcd], (ab)b[cd], ab1[cd]
```
確認クエリ
```sql
SELECT str, 
  REGEXP_EXTRACT_ALL(str,'(ab){2}cd')   AS m1,
  REGEXP_EXTRACT_ALL(str,'(ab){1,}cd')  AS m2,
  REGEXP_EXTRACT_ALL(str,'(ab){1,2}cd') AS m3,
  REGEXP_EXTRACT_ALL(str,'(ab){0,2}cd') AS m4
FROM (
  VALUES 'acd', 'bcd','abcd', 'abbcd', 'ababcd', 'ab1cd'
) AS t(str)
```
|str |m1                      |m2        |m3       |m4             |
|----|------------------------|----------|---------|---------------|
|acd |[]                      |[]        |[]       |["cd"]         |
|bcd |[]                      |[]        |[]       |["cd"]         |
|abcd|[]                      |["abcd"]  |["abcd"] |["abcd"]       |
|abbcd|[]                      |[]        |[]       |["cd"]         |
|ababcd|["ababcd"]              |["ababcd"]|["ababcd"]|["ababcd"]     |
|ab1cd|[]                      |[]        |[]       |["cd"]         |


#### 数字に対する{n,m}の繰り返しを挟んだパターンの例

マッチする文字列（「[ ]」はマッチする部分を示す）
```sql
# 03-123-4567
'[\d]{3}'   # ⇒ 03-[123]-[456]
'[\d]{5}'   # ⇒ []
'[\d]{1,}'  # ⇒ [03]-[123]-[4567]
'[\d]{1,2}' # ⇒ [03]-[12][3]-[45][67]
'[\d]{0,2}' # ⇒ [03]-[12][3]-[45][67]
```

確認クエリ

```sql
SELECT str, 
  REGEXP_EXTRACT_ALL(str,'[\d]{3}')   AS m1,
  REGEXP_EXTRACT_ALL(str,'[\d]{5}')   AS m2,
  REGEXP_EXTRACT_ALL(str,'[\d]{1,}')  AS m3,
  REGEXP_EXTRACT_ALL(str,'[\d]{1,2}') AS m4,
  REGEXP_EXTRACT_ALL(str,'[\d]{0,2}') AS m5
FROM (
  VALUES '03-123-4567'
) AS t(str)
```
|str |m1                      |m2        |m3       |m4             |m5                                       |
|----|------------------------|----------|---------|---------------|-----------------------------------------|
|03-123-4567|["123", "456"]          |[]        |["03", "123", "4567"]|["03", "12", "3", "45", "67"]|["03", "", "12", "3", "", "45", "67", ""]|


### 数量子（2. 控えめなものと強欲なもの）
控えめな数量子を以下に示します。
|構文  |Matches|
|----|-------|
|X?? |Xの1または0回の最短の繰り返し|
|X*? |Xの0回以上の最短の繰り返し|
|X+? |Xの1回以上の最短の繰り返し|
|X{n}?|Xのn回の最短の繰り返し|
|X{n,}?|Xのn回以上の最短の繰り返し|
|X{n,m}?|Xのn回以上，m回以下の最短の繰り返し|

強欲な数量子を以下に示します。
|構文  |Matches|
|----|-------|
|X?+ |Xの1または0回の最大の繰り返し|
|X*+ |Xの0回以上の最大の繰り返し|
|X++ |Xの1回以上の最大の繰り返し|
|X{n}+|Xのn回の最大の繰り返し|
|X{n,}+|Xのn回以上の最大の繰り返し|
|X{n,m}+|Xのn回以上，m回以下の最大の繰り返し|

```sql
# acd
'ab+'  # ⇒ []
'ab+?' # ⇒ []
'ab++' # ⇒ []

'ab*'  # ⇒ [a]
'ab*?' # ⇒ [a]
'ab*+' # ⇒ [a]

'ab?'  # ⇒ [a]
'ab??' # ⇒ [a]
'ab?+' # ⇒ [a]

# abcd
'ab+'  # ⇒ [ab]
'ab+?' # ⇒ [ab]
'ab++' # ⇒ [ab]

'ab*'  # ⇒ [ab] 1回
'ab*?' # ⇒ [a]  0回
'ab*+' # ⇒ [ab] 1回

'ab?'  # ⇒ [ab] 1回
'ab??' # ⇒ [a]  0回
'ab?+' # ⇒ [ab] 1回

# abbbcd
'ab+'  # ⇒ [abbb] 3回
'ab+?' # ⇒ [ab]   1回
'ab++' # ⇒ [abbb] 3回

'ab*'  # ⇒ [abbb] 3回
'ab*?' # ⇒ [a]    0回
'ab*+' # ⇒ [abbb] 3回

'ab?'  # ⇒ [ab] 1回
'ab??' # ⇒ [a]  0回
'ab?+' # ⇒ [ab] 1回
```

確認クエリ
```sql
SELECT str, 
  REGEXP_EXTRACT_ALL(str,'ab+')  AS m1,       --普通
  REGEXP_EXTRACT_ALL(str,'ab+?') AS m1_short, --最短
  REGEXP_EXTRACT_ALL(str,'ab++') AS m1_long,  --強欲
  
  REGEXP_EXTRACT_ALL(str,'ab*')  AS m2,       --普通
  REGEXP_EXTRACT_ALL(str,'ab*?') AS m2_short, --最短
  REGEXP_EXTRACT_ALL(str,'ab*+') AS m2_long,  --強欲
  
  REGEXP_EXTRACT_ALL(str,'ab?')  AS m3,       --普通
  REGEXP_EXTRACT_ALL(str,'ab??') AS m3_short, --最短
  REGEXP_EXTRACT_ALL(str,'ab?+') AS m3_long   --強欲
FROM (
  VALUES 'acd', 'abcd', 'abbcd', 'abbbcd'
) AS t(str)
```
|str |m1                      |m1_short  |m1_long  |m2             |m2_short                                 |m2_long |m3    |m3_short|m3_long|
|----|------------------------|----------|---------|---------------|-----------------------------------------|--------|------|--------|-------|
|acd |[]                      |[]        |[]       |["a"]          |["a"]                                    |["a"]   |["a"] |["a"]   |["a"]  |
|abcd|["ab"]                  |["ab"]    |["ab"]   |["ab"]         |["a"]                                    |["ab"]  |["ab"]|["a"]   |["ab"] |
|abbcd|["abb"]                 |["ab"]    |["abb"]  |["abb"]        |["a"]                                    |["abb"] |["ab"]|["a"]   |["ab"] |
|abbbcd|["abbb"]                |["ab"]    |["abbb"] |["abbb"]       |["a"]                                    |["abbb"]|["ab"]|["a"]   |["ab"] |


#### 数字の3種類の繰り返しに対応したパターンの例


```sql
# 03-123-4567
'[\d]+'   # ⇒ [03]-[123]-[4567]
'[\d]+?'  # ⇒ [0][3]-[1][2][3]-[4][5][6][7]
'[\d]++'  # ⇒ [03]-[123]-[4567]

'[\d]*'   # ⇒ [03]-[123]-[4567]
'[\d]*?'  # ⇒ []
'[\d]*+'  # ⇒ [03]-[123]-[4567]

'[\d]?'   # ⇒ [0][3]-[1][2][3]-[4][5][6][7]
'[\d]??'  # ⇒ []
'[\d]?+'  # ⇒ [0][3]-[1][2][3]-[4][5][6][7]
```

確認クエリ

```sql
SELECT str, 
  REGEXP_EXTRACT_ALL(str,'[\d]+')  AS m1,
  REGEXP_EXTRACT_ALL(str,'[\d]+?') AS m1_short,
  REGEXP_EXTRACT_ALL(str,'[\d]++') AS m1_long,

  REGEXP_EXTRACT_ALL(str,'[\d]*')  AS m2,
  REGEXP_EXTRACT_ALL(str,'[\d]*?') AS m2_short,
  REGEXP_EXTRACT_ALL(str,'[\d]*+') AS m2_long,
  
  REGEXP_EXTRACT_ALL(str,'[\d]?')  AS m3,
  REGEXP_EXTRACT_ALL(str,'[\d]??') AS m3_short,
  REGEXP_EXTRACT_ALL(str,'[\d]?+') AS m3_long
FROM (
  VALUES '03-123-4567'
) AS t(str)
```
|str |m1                      |m1_short  |m1_long  |m2             |m2_short                                 |m2_long |m3    |m3_short|m3_long|
|----|------------------------|----------|---------|---------------|-----------------------------------------|--------|------|--------|-------|
|03-123-4567|["03", "123", "4567"]   |["0", "3", "1", "2", "3", "4", "5", "6", "7"]|["03", "123", "4567"]|["03", "", "123", "", "4567", ""]|["", "", "", "", "", "", "", "", "", "", "", ""]|["03", "", "123", "", "4567", ""]|["0", "3", "", "1", "2", "3", "", "4", "5", "6", "7", ""]|["", "", "", "", "", "", "", "", "", "", "", ""]|["0", "3", "", "1", "2", "3", "", "4", "5", "6", "7", ""]|


#### 数字とハイフンの3種類の繰り返しに対応したパターンの例


```sql
# 03-123-4567
'[\d-]+'   # ⇒ [03-123-456]
'[\d-]+?'  # ⇒ [0][3]-[1][2][3]-[4][5][6][7]
'[\d-]++'  # ⇒ [03-123-4567]

'[\d-]*'   # ⇒ [03]-[123]-[4567]
'[\d-]*?'  # ⇒ []
'[\d-]*+'  # ⇒ [03]-[123]-[4567]

'[\d-]?'   # ⇒ [0][3]-[1][2][3]-[4][5][6][7]
'[\d-]??'  # ⇒ []
'[\d-]?+'  # ⇒ [0][3]-[1][2][3]-[4][5][6][7]
```

確認クエリ
```sql
SELECT str, 
  REGEXP_EXTRACT_ALL(str,'[\d-]+')  AS m1,
  REGEXP_EXTRACT_ALL(str,'[\d-]+?') AS m1_short,
  REGEXP_EXTRACT_ALL(str,'[\d-]++') AS m1_long,
  
  REGEXP_EXTRACT_ALL(str,'[\d-]*')  AS m2,
  REGEXP_EXTRACT_ALL(str,'[\d-]*?') AS m2_short,
  REGEXP_EXTRACT_ALL(str,'[\d-]*+') AS m2_long,
  
  REGEXP_EXTRACT_ALL(str,'[\d-]?')  AS m3,
  REGEXP_EXTRACT_ALL(str,'[\d-]??') AS m3_short,
  REGEXP_EXTRACT_ALL(str,'[\d-]?+') AS m3_long
FROM (
  VALUES '03-123-4567'
) AS t(str)
```
|str |m1                      |m1_short  |m1_long  |m2             |m2_short                                 |m2_long |m3    |m3_short|m3_long|
|----|------------------------|----------|---------|---------------|-----------------------------------------|--------|------|--------|-------|
|03-123-4567|["03-123-4567"]         |["0", "3", "-", "1", "2", "3", "-", "4", "5", "6", "7"]|["03-123-4567"]|["03-123-4567", ""]|["", "", "", "", "", "", "", "", "", "", "", ""]|["03-123-4567", ""]|["0", "3", "-", "1", "2", "3", "-", "4", "5", "6", "7", ""]|["", "", "", "", "", "", "", "", "", "", "", ""]|["0", "3", "-", "1", "2", "3", "-", "4", "5", "6", "7", ""]|


### 境界正規表現エンジン

|構文  |Matches|
|----|-------|
|^   |行の先頭   |
|$   |行の末尾   |
|\b  |単語境界   |
|\B  |非単語境界  |
|\A  |入力の先頭  |
|\G  |前回のマッチの末尾|
|\Z  |最後の行末記号がある場合は，それを除く入力の末尾|
|\z  |入力の末尾（行末文字があれば，それが末尾）|

#### 境界正規表現エンジンを含むパターン例

```sql
# abc, abcxyz, xyzabc, xabcx, abc\n
'abc'     # ⇒ [abc], [abc]xyz, xyz[abc], x[abc]x, [abc]\n
'^abc'    # ⇒ [abc], [abc]xyz,                    [abc]\n
'abc$'    # ⇒ [abc],           xyz[abc],          [abc]\n
'^abc$'   # ⇒ [abc],                              [abc]\n
'^abc\n$' # ⇒                                     [abc]\n
```


確認クエリ
```sql
SELECT str, 
  REGEXP_LIKE(str,'abc')     AS is_m1,
  REGEXP_LIKE(str,'^abc')    AS is_m2,
  REGEXP_LIKE(str,'abc$')    AS is_m3,
  REGEXP_LIKE(str,'^abc$')   AS is_m4,
  REGEXP_LIKE(str,'^abc\n$') AS is_m5
FROM (
  VALUES 'abc', 'abcxyz', 'xyzabc', 'xabcx',
         'abc' || CHR(10) --ラインフィード (LF)
) AS t(str)
```
|str |is_m1                   |is_m2     |is_m3    |is_m4          |is_m5                                    |
|----|------------------------|----------|---------|---------------|-----------------------------------------|
|abc |true                    |true      |true     |true           |false                                    |
|abcxyz|true                    |true      |false    |false          |false                                    |
|xyzabc|true                    |false     |true     |false          |false                                    |
|xabcx|true                    |false     |false    |false          |false                                    |
|abc |true                    |true      |true     |true           |true                                     |


#### よく遭遇するパターン例

|頻出するマッチさせたい文字列|例    |正規表現                              |
|--------------|-----|----------------------------------|
|半角数値のみで構成されている， もしくは空白|123456789|^[0-9]*$                          |
|英字小文字のみで構成されている，もしくは空白|abcdefg|^[a-z]*$                          |
|英字大文字のみで構成されている，もしくは空白|ABCDEFG|^[A-Z]*$                          |
|英字小文字大文字のみで構成されている，もしくは空白|ABCdefg|^[a-zA-Z]*$                       |
|英数字のみで構成されている， もしくは空白|12aaAA|^[0-9a-zA-Z]*$                    |
|郵便番号          |123-1234|^[0-9]{3}-[0-9]{4}$               |
|日付（yyyy/M/d形式）|2009/7/29|^[0-9]{4}/[01]?[0-9]/[0123]?[0-9]$|

```sql
SELECT
 REGEXP_EXTRACT_ALL('123456789', '^[0-9]*$') AS m1,
 REGEXP_EXTRACT_ALL('abcdefg', '^[a-z]*$') AS m2,
 REGEXP_EXTRACT_ALL('ABCDEFG', '^[A-Z]*$') AS m3,
 REGEXP_EXTRACT_ALL('ABCdefg', '^[a-zA-Z]*$') AS m4,
 REGEXP_EXTRACT_ALL('12aaAA', '^[0-9a-zA-Z]*$') AS m5,
 REGEXP_EXTRACT_ALL('123-1234', '^[0-9]{3}-[0-9]{4}$') AS m6,
 REGEXP_EXTRACT_ALL('2009/7/29', '^[0-9]{4}/[01]?[0-9]/[0123]?[0-9]$') AS m7
```
|m1  |m2                      |m3        |m4       |m5             |m6                                       |m7           |
|----|------------------------|----------|---------|---------------|-----------------------------------------|-------------|
|["123456789"]|["abcdefg"]             |["ABCDEFG"]|["ABCdefg"]|["12aaAA"]     |["123-1234"]                             |["2009/7/29"]|


## 正規表現で文字列を抽出する


### 特定の文字列を含み，最初にマッチした文字列を返す
REGEXP_EXTRACT(string, pattern)を使って，「td_urlが'fluentd.org'を含むかどうか」を調べるクエリを書いてみましょう。
```sql
SELECT td_url, REGEXP_EXTRACT(td_url,'fluentd.org') AS match_str
FROM sample_accesslog_fluentd
LIMIT 10
```
|td_url|match_str               |
|------|------------------------|
|http://docs.fluentd.org/ja/categories/installation|fluentd.org             |
|http://docs.fluentd.org/articles/config-file|fluentd.org             |
|http://docs.fluentd.org/articles/windows|fluentd.org             |


### いずれかの文字列を含む文字列で最初にマッチしたものを返す

```sql
(out_splunk$|out_file$|out_forward$|out_secure_forward$|out_exec$|out_exec_filter$|out_copy$)
```

```sql
SELECT td_url, match_str1, match_str2
FROM
(
  SELECT td_url,
    REGEXP_EXTRACT(td_url,'out_splunk$|out_file$|out_forward$|out_secure_forward$|out_exec$|out_exec_filter$|out_copy$') AS match_str1,
    REGEXP_EXTRACT(td_url,'out_.*$') AS match_str2
  FROM sample_accesslog_fluentd
)
WHERE match_str1 IS NOT NULL OR match_str2 IS NOT NULL
LIMIT 10
```
|td_url                                     |match_str1|match_str2|
|-------------------------------------------|----------|----------|
|http://docs.fluentd.org/articles/out_others|NULL      |out_others|
|http://docs.fluentd.org/articles/out_mongo |NULL      |out_mongo |
|http://docs.fluentd.org/articles/out_others|NULL      |out_others|


### 特定の文字列を含む任意のグループを取り出す

```sql
SELECT td_url, REGEXP_EXTRACT(td_url,'(docs.fluentd.org)',1) AS match_str
FROM sample_accesslog_fluentd
LIMIT 10
```
|td_url                                     |match_str       |
|-------------------------------------------|----------------|
|http://docs.fluentd.org/ja/articles/buf_file|docs.fluentd.org|
|http://docs.fluentd.org/ja/articles/quickstart|docs.fluentd.org|
|http://www.fluentd.org/testimonials        |NULL            |



### 複数のグループを記述する

```sql
WITH sample AS
( 
  SELECT s FROM
  ( 
    VALUES 
    'https://docs.fluentd.org/v0.12/articles/out_file',
    'https://docs.fluentd.org/v0.12/articles/out_forward',
    'https://www.fluentd.org/v0.12/articles/out_file',
    'out_file/article/docs.fluentd.org/'
  ) AS t(s)
)
SELECT
  s, REGEXP_EXTRACT(s,'(docs.fluentd.org).*(out_file)',1) AS match_str1,
     REGEXP_EXTRACT(s,'(docs.fluentd.org).*(out_file)',2) AS match_str2
FROM sample
```
|s                                          |match_str1      |match_str2|
|-------------------------------------------|----------------|----------|
|https://docs.fluentd.org/v0.12/articles/out_file|docs.fluentd.org|out_file  |
|https://docs.fluentd.org/v0.12/articles/out_forward|NULL            |NULL      |
|https://www.fluentd.org/v0.12/articles/out_file|NULL            |NULL      |
|out_file/article/docs.fluentd.org/         |NULL            |NULL      |



```sql
OK：https://docs.fluentd.org/v0.12/articles/out_file
NG：https://docs.fluentd.org/v0.12/articles/out_forward （2番目のグループを含まない）
NG：https://www.fluentd.org/v0.12/articles/out_file （1番目のグループを含まない）
NG：out_file/article/docs.fluentd.org/ （グループの出現順序が異なる）
```


### いずれかのグループにマッチさせる


```sql
WITH sample AS
( 
  SELECT s FROM
  ( 
    VALUES 
    'https://docs.fluentd.org/v0.12/articles/out_file',
    'https://docs.fluentd.org/v0.12/articles/out_forward',
    'https://www.fluentd.org/v0.12/articles/out_file',
    'out_file/article/docs.fluentd.org/'
  ) AS t(s)
)
SELECT
  s, REGEXP_EXTRACT(s,'(docs.fluentd.org|out_file)',1) AS match_str
FROM sample
```
|s                                          |match_str       |
|-------------------------------------------|----------------|
|https://docs.fluentd.org/v0.12/articles/out_file|docs.fluentd.org|
|https://docs.fluentd.org/v0.12/articles/out_forward|docs.fluentd.org|
|https://www.fluentd.org/v0.12/articles/out_file|out_file        |
|out_file/article/docs.fluentd.org/         |out_file        |


### マッチした文字列をすべて取り出す

```sql
WITH sample AS
( 
  SELECT s FROM
  ( 
    VALUES 
    'https://docs.fluentd.org/v0.12/articles/out_file',
    'https://docs.fluentd.org/v0.12/articles/out_forward',
    'https://www.fluentd.org/v0.12/articles/out_file',
    'out_file/article/docs.fluentd.org/'
  ) AS t(s)
)
SELECT
  s, REGEXP_EXTRACT_ALL(s,'docs.fluentd.org.*out_file') AS match_strs1,
     REGEXP_EXTRACT_ALL(s,'docs.fluentd.org|out_file') AS match_strs2
FROM sample
```
|s                                          |match_strs1     |match_strs2                     |
|-------------------------------------------|----------------|--------------------------------|
|https://docs.fluentd.org/v0.12/articles/out_file|["docs.fluentd.org/v0.12/articles/out_file"]|["docs.fluentd.org", "out_file"]|
|https://docs.fluentd.org/v0.12/articles/out_forward|[]              |["docs.fluentd.org"]            |
|https://www.fluentd.org/v0.12/articles/out_file|[]              |["out_file"]                    |
|out_file/article/docs.fluentd.org/         |[]              |["out_file", "docs.fluentd.org"]|


### メタ文字をエスケープしてマッチさせる

1. 文字列全体```「^\\(.+*?)[|]$」```をマッチさせる

```sql
SELECT 
  REGEXP_EXTRACT(
    '^\\(.+*?)[|]$',
    '\^\\\\\(\.\+\*\?\)\[\|\]\$'
)
```
|_col0                                      |
|-------------------------------------------|
|^\\(.+*?)[&#124;]$                              |


2. ```「(.+*?)」```で取り出す

```sql
SELECT 
  REGEXP_EXTRACT(
    '^\\(.+*?)[|]$',
    '\(.*\)'
)
```
|_col0                                      |
|-------------------------------------------|
|(.+*?)                                     |


3. ```「(.+*?)」```と```「[|]」```を，それぞれGROUP1，GROUP2としてマッチさせる

```sql
SELECT 
  REGEXP_EXTRACT(
    '^\\(.+*?)[|]$',
    '(\(.*\))|(\[.*\])',
    1
  ) AS group1,
  REGEXP_EXTRACT(
    '^\\(.+*?)[|]$',
    '(\(.*\))(\[.*\])',
    2
  ) AS group2
```
|group1                                     |group2|
|-------------------------------------------|------|
|(.+*?)                                     |[\|]   |


## 正規表現で文字列を条件判定する


### 特定の文字列を含むか否か
```sql
SELECT td_url
FROM sample_accesslog_fluentd
WHERE REGEXP_LIKE(td_url,'docs.fluentd.org')
LIMIT 10
```
|td_url                                     |
|-------------------------------------------|
|http://docs.fluentd.org/articles/in_unix   |
|http://docs.fluentd.org/articles/http-to-hdfs|
|http://docs.fluentd.org/articles/config-file|


## 正規表現で文字列を置換する


### 文字列の除去



```sql
SELECT td_url,
  REGEXP_REPLACE(td_url,'http(.)*://','') AS replaced_url
FROM sample_accesslog_fluentd
LIMIT 10
```
|td_url                                     |replaced_url                                     |
|-------------------------------------------|-------------------------------------------------|
|http://www.fluentd.org/guides              |www.fluentd.org/guides                           |
|http://www.fluentd.org/blog/fluentd-v0.10.56-is-released|www.fluentd.org/blog/fluentd-v0.10.56-is-released|
|http://www.fluentd.org/                    |www.fluentd.org/                                 |


```sql
SELECT td_url,
  -- 'http(s)://' を除外 | '?'以降のパラメータを除外 | レコードの末尾の '/' を除外
  REGEXP_REPLACE(td_url,'http(.)*://|\?(.)*|/$','') AS replaced_url
FROM sample_accesslog_fluentd
WHERE REGEXP_LIKE(td_url,'\?')
LIMIT 10
```
|td_url                                     |replaced_url                                     |
|-------------------------------------------|-------------------------------------------------|
|http://www.fluentd.org/blog/fluentd-goes-gopher?utm_content=buffer4bfc1&utm_medium=social&utm_source=twitter.com&utm_campaign=buffer|www.fluentd.org/blog/fluentd-goes-gopher         |
|http://docs.fluentd.org/articles/support?aliId=1395429|docs.fluentd.org/articles/support                |
|http://docs.fluentd.org/articles/quickstart?aliId=1527960|docs.fluentd.org/articles/quickstart             |


```sql
SELECT td_url,
  REGEXP_REPLACE(td_url,'/','@') AS replaced_url
FROM sample_accesslog_fluentd
LIMIT 10
```
|td_url                                     |replaced_url                                     |
|-------------------------------------------|-------------------------------------------------|
|http://www.fluentd.org/blog/               |http:@@www.fluentd.org@blog@                     |
|http://docs.fluentd.org/articles/in_tail   |http:@@docs.fluentd.org@articles@in_tail         |
|http://docs.fluentd.org/ja/articles/formatter-plugin-overview|http:@@docs.fluentd.org@ja@articles@formatter-plugin-overview|



```sql
SELECT td_url,
  --'http' と 'docs.fluentd.org' を入れ替え | で区切る
  -- $1=http, $2=://, $3=docs.fluentd.org --
  REGEXP_REPLACE(td_url,'(http)(.*)(docs.fluentd.org)','$3 | $2 | $1') AS replaced_url
FROM sample_accesslog_fluentd
WHERE REGEXP_LIKE(td_url,'docs.fluentd.org')
LIMIT 10
```
|td_url                                     |replaced_url                                     |
|-------------------------------------------|-------------------------------------------------|
|http://docs.fluentd.org/articles/out_file  |docs.fluentd.org | :// | http/articles/out_file  |
|http://docs.fluentd.org/articles/quickstart|docs.fluentd.org | :// | http/articles/quickstart|
|http://docs.fluentd.org/articles/plugin-development|docs.fluentd.org | :// | http/articles/plugin-development|


## 正規表現で文字列を分割する


```sql
SELECT td_url,
  REGEXP_SPLIT(td_url,'/') AS splitted_strs
FROM sample_accesslog_fluentd
LIMIT 10
```
|td_url                                     |splitted_strs                                    |
|-------------------------------------------|-------------------------------------------------|
|http://docs.fluentd.org/articles/install-by-rpm|["http:", "", "docs.fluentd.org", "articles", "install-by-rpm"]|
|http://docs.fluentd.org/articles/install-by-deb|["http:", "", "docs.fluentd.org", "articles", "install-by-deb"]|
|http://docs.fluentd.org/articles/buf_file  |["http:", "", "docs.fluentd.org", "articles", "buf_file"]|

