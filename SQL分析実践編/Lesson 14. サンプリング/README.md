# Lesson 14. サンプリング

## TABLESAMPLE
```sql
SELECT time, member_id, category, sub_category, goods_id
FROM sales_slip TABLESAMPLE BERNOULLI(0.01)
```
|time|member_id|category|sub_category|goods_id|
|----|---------|--------|------------|--------|
|1351601114|23717    |Home and Garden and Tools|Kitchen and Dining|597779  |
|1353414039|1839357  |Movies and Music and Games|Musical Instruments|603113  |
|1332844885|929459   |Automotive and Industrial|Motorcycle and Powersports|562491  |


## WHERE節とRAND関数によるランダムサンプリング

```sql
SELECT time, member_id, category, sub_category, goods_id
FROM sales_slip
WHERE RAND() <= 0.0001 -- 0.01%
ORDER BY time
```
|time|member_id|category|sub_category|goods_id|
|----|---------|--------|------------|--------|
|1108666186|99165    |Electronics and Computers|Video Games |105392  |
|1117873958|79502    |Sports and Outdoors|Boating and Water Sports|113720  |
|1118262459|574010   |Clothing and Shoes and Jewelry|Men         |114558  |



## ORDER BY節とRAND関数によるランダムサンプリング


```sql
SELECT time, member_id, category, sub_category, goods_id
FROM sales_slip
ORDER BY RAND()
LIMIT 5
```
|time|member_id|category|sub_category|goods_id|
|----|---------|--------|------------|--------|
|1354147836|391139   |Movies and Music and Games|Entertainment Collectibles|602270  |
|1319643101|NULL         |Automotive and Industrial|Lab and Scientific|109601  |
|1354963866|1638055  |Beauty and Health and Grocery|Specialty Diets|606541  |
|1265313812|282436   |Toys and Kids and Baby|For Baby    |382080  |
|1123604291|111187   |Electronics and Computers|Wearable Technology|122035  |



```sql
SELECT time, member_id, category, sub_category, goods_id, RAND() AS rnd
FROM sales_slip
ORDER BY rnd
LIMIT 5
```
|time|member_id|category|sub_category|goods_id|rnd                   |
|----|---------|--------|------------|--------|----------------------|
|1367296687|NULL         |Automotive and Industrial|Lab and Scientific|109601  |2.1735940403111442e-07|
|1202236057|717558   |Electronics and Computers|Cell Phones and Accessories|249775  |2.659721006770255e-07 |
|1293285082|949366   |Beauty and Health and Grocery|Menâ€™s Grooming|109090  |7.179268182166965e-07 |
|1387234627|517345   |Electronics and Computers|Trade In Your Electronics|665739  |8.370794056800079e-07 |
|1334767187|NULL         |Automotive and Industrial|Lab and Scientific|109601  |8.393554470353948e-07 |


## ROW_NUMBERとRAND関数によるランダムサンプリング


```sql
SELECT *
FROM
(
  SELECT time, member_id, category, sub_category, goods_id, ROW_NUMBER()OVER(ORDER BY RAND()) AS rnd_rnk
  FROM sales_slip
)
WHERE rnd_rnk <= 5
```
|time|member_id|category|sub_category|goods_id|rnd_rnk               |
|----|---------|--------|------------|--------|----------------------|
|1319312519|NULL         |Automotive and Industrial|Lab and Scientific|109601  |1                     |
|1310589185|1132047  |Sports and Outdoors|Sports Collectibles|512941  |2                     |
|1195516803|949366   |Beauty and Health and Grocery|Menâ€™s Grooming|109090  |3                     |
|1349567121|NULL         |Automotive and Industrial|Lab and Scientific|109601  |4                     |
|1382551570|2259091  |Automotive and Industrial|Lab and Scientific|NULL        |5                     |



```sql
SELECT *
FROM
(
  SELECT time, member_id, category, sub_category, goods_id, ROW_NUMBER()OVER(ORDER BY RAND()) AS rnd_rnk
  FROM sales_slip
)
WHERE rnd_rnk <= 5
UNION ALL
SELECT *
FROM
(
  SELECT time, member_id, category, sub_category, goods_id, ROW_NUMBER()OVER(ORDER BY RAND()) AS rnd_rnk
  FROM sales_slip
)
WHERE rnd_rnk <= 5
```
|time|member_id|category|sub_category|goods_id|rnd_rnk               |
|----|---------|--------|------------|--------|----------------------|
|1208484603|695856   |Beauty and Health and Grocery|All Beauty  |260052  |1                     |
|1318863299|1952695  |Electronics and Computers|Software    |533854  |2                     |
|1258663183|574971   |Home and Garden and Tools|Appliances  |364286  |3                     |
|1354367776|NULL         |Automotive and Industrial|Lab and Scientific|109601  |4                     |
|1190403880|1104914  |Movies and Music and Games|Digital Games|233695  |5                     |
|1149882259|558829   |Toys and Kids and Baby|For Girls   |164186  |1                     |
|1352590636|NULL         |Automotive and Industrial|Lab and Scientific|109601  |2                     |
|1325342386|NULL         |Automotive and Industrial|Lab and Scientific|109601  |3                     |
|1250183164|554562   |Beauty and Health and Grocery|Health and Household and Baby Care|344561  |4                     |
|1300399724|90886    |Home and Garden and Tools|Arts and Crafts and Sewing|488745  |5                     |


## 層別サンプリング


### グループごとにサンプリング


```sql
SELECT *
FROM
(
  SELECT time, member_id, category, sub_category, goods_id, ROW_NUMBER()OVER(PARTITION BY category ORDER BY RAND()) AS rnd_rnk
  FROM sales_slip
)
WHERE rnd_rnk <= 5
ORDER BY category
```
|time|member_id|category|sub_category|goods_id|rnd_rnk               |
|----|---------|--------|------------|--------|----------------------|
|1169892840|940685   |Automotive and Industrial|Industrial Supplies|201438  |1                     |
|1361026836|NULL         |Automotive and Industrial|Lab and Scientific|109601  |2                     |
|1330942517|NULL         |Automotive and Industrial|Lab and Scientific|109601  |3                     |




### グループごとの母集団の数を意識したサンプリング



```sql
WITH stat AS
(
  SELECT category, COUNT(1) AS cnt_category
  FROM sales_slip
  GROUP BY category
)
SELECT s.*
FROM
(
  SELECT time, member_id, category, sub_category, goods_id, ROW_NUMBER()OVER(PARTITION BY category ORDER BY RAND()) AS rnd_rnk
  FROM sales_slip
) s, stat
WHERE s.category = stat.category
AND rnd_rnk <= cnt_category/10000
```
|time|member_id|category|sub_category|goods_id|rnd_rnk               |
|----|---------|--------|------------|--------|----------------------|
|1349527085|589567   |Books and Audible|Books       |595208  |1                     |
|1375748929|1675318  |Books and Audible|Textbooks   |647005  |2                     |
|1242335031|1251374  |Books and Audible|Textbooks   |325431  |3                     |




```sql
WITH stat AS
(
  SELECT category, COUNT(1) AS cnt
  FROM sales_slip
  GROUP BY category
)
SELECT s.category, MIN(stat.cnt) AS cnt_category, COUNT(1) AS cnt, 1.0*COUNT(1)/MIN(stat.cnt) AS ratio
FROM
(
  SELECT time, member_id, category, sub_category, goods_id, ROW_NUMBER()OVER(PARTITION BY category ORDER BY RAND()) AS rnd_rnk
  FROM sales_slip
) s, stat
WHERE s.category = stat.category
AND rnd_rnk <= stat.cnt/10000
GROUP BY s.category
ORDER BY cnt DESC
```
|category|cnt_category|cnt    |ratio|
|--------|------------|-------|-----|
|Automotive and Industrial|2207193     |220    |9.967411096356322e-05|
|Beauty and Health and Grocery|894252      |89     |9.952451881572532e-05|
|Electronics and Computers|662959      |66     |9.95536677230417e-05|
|Home and Garden and Tools|589352      |58     |9.841317243345233e-05|
|Sports and Outdoors|512399      |51     |9.953181017137036e-05|
|Movies and Music and Games|323719      |32     |9.885116412691253e-05|
|Toys and Kids and Baby|293097      |29     |9.894335322435918e-05|
|Clothing and Shoes and Jewelry|222291      |22     |9.89693689803006e-05|
|Books and Audible|187086      |18     |9.621243706103075e-05|


ratioの値は「9.9...e-05=9.9...*10^-5=0.000099...」を意味します。

### グループごとの母集団の数を意識したサンプリング（PERCENT_RANK）



```sql
SELECT *
FROM
(
  SELECT time, member_id, category, sub_category, goods_id, PERCENT_RANK()OVER(PARTITION BY category ORDER BY RAND()) AS per_rnk
  FROM sales_slip
)
WHERE per_rnk <= 0.0001 -- 0.01%
ORDER BY category
```
|time|member_id|category|sub_category|goods_id|per_rnk              |
|----|---------|--------|------------|--------|---------------------|
|1317696525|NULL         |Automotive and Industrial|Lab and Scientific|109601  |9.967415612234912e-05|
|1376996118|193551   |Automotive and Industrial|Industrial Supplies|583266  |9.922109177633845e-05|
|1384775934|2259091  |Automotive and Industrial|Lab and Scientific|NULL        |9.876802743032777e-05|



```sql
WITH stat AS
(
  SELECT category, COUNT(1) AS cnt
  FROM sales_slip
  GROUP BY category
)

SELECT s.category, stat.cnt AS cnt_category, s.cnt, 1.0*s.cnt/stat.cnt AS ratio
FROM
(
  SELECT category, COUNT(1) AS cnt
  FROM
  (
    SELECT time, member_id, category, sub_category, goods_id, PERCENT_RANK()OVER(PARTITION BY category ORDER BY RAND()) AS per_rnk
    FROM sales_slip
  )
  WHERE per_rnk <= 0.0001 -- 0.01%
  GROUP BY category
) s, stat
WHERE s.category = stat.category
ORDER BY category
```
|category|cnt_category|cnt    |ratio|
|--------|------------|-------|-----|
|Automotive and Industrial|2207193     |221    |0.00010012717510430669|
|Beauty and Health and Grocery|894252      |90     |0.00010064277183612673|
|Books and Audible|187086      |19     |0.00010155757245331024|
|Clothing and Shoes and Jewelry|222291      |23     |0.00010346797666122335|
|Electronics and Computers|662959      |67     |0.00010106205662793627|
|Home and Garden and Tools|589352      |59     |0.00010010995126851185|
|Movies and Music and Games|323719      |33     |0.00010194026300587855|
|Sports and Outdoors|512399      |52     |0.00010148341429237762|
|Toys and Kids and Baby|293097      |30     |0.00010235519299071639|




### グループごとの母集団の数を意識したサンプリング（NTILE）


```sql
SELECT *
FROM
(
  SELECT time, member_id, category, sub_category, goods_id, NTILE(10000)OVER(PARTITION BY category ORDER BY RAND()) AS tile
  FROM sales_slip
)
WHERE tile <= 1 -- 0.01%
ORDER BY category
```
|time|member_id|category|sub_category|goods_id|tile|
|----|---------|--------|------------|--------|----|
|1383494533|2259091  |Automotive and Industrial|Lab and Scientific|        |1   |
|1317995754|NULL         |Automotive and Industrial|Lab and Scientific|109601  |1   |
|1254148710|1492081  |Automotive and Industrial|Tires and Wheels|353152  |1   |




```sql
WITH stat AS
(
  SELECT category, COUNT(1) AS cnt
  FROM sales_slip
  GROUP BY category
)

SELECT s.category, stat.cnt AS cnt_category, s.cnt, 1.0*s.cnt/stat.cnt AS ratio
FROM
(
  SELECT category, COUNT(1) AS cnt
  FROM
  (
    SELECT time, member_id, category, sub_category, goods_id, NTILE(10000)OVER(PARTITION BY category ORDER BY RAND()) AS tile
    FROM sales_slip
  )
  WHERE tile <= 1 -- 0.01%
  GROUP BY category
) s, stat
WHERE s.category = stat.category
ORDER BY category
```
|category|cnt_category|cnt    |ratio|
|--------|------------|-------|-----|
|Automotive and Industrial|2207193     |221    |0.00010012717510430669|
|Beauty and Health and Grocery|894252      |90     |0.00010064277183612673|
|Books and Audible|187086      |19     |0.00010155757245331024|
|Clothing and Shoes and Jewelry|222291      |23     |0.00010346797666122335|
|Electronics and Computers|662959      |67     |0.00010106205662793627|
|Home and Garden and Tools|589352      |59     |0.00010010995126851185|
|Movies and Music and Games|323719      |33     |0.00010194026300587855|
|Sports and Outdoors|512399      |52     |0.00010148341429237762|
|Toys and Kids and Baby|293097      |30     |0.00010235519299071639|




```sql
SELECT *
FROM
(
  SELECT time, member_id, category, sub_category, goods_id, NTILE(10000)OVER(PARTITION BY category,sub_category,goods_id ORDER BY RAND()) AS tile
  FROM sales_slip
)
WHERE tile <= 1 -- 0.01%
```
```sql
386011 records
```



```sql
WITH stat AS
(
  SELECT category, sub_category, goods_id, COUNT(1) AS cnt
  FROM sales_slip
  GROUP BY category, sub_category, goods_id
)

SELECT s.category, s.sub_category, s.goods_id, stat.cnt AS cnt_all, s.cnt, 1.0*s.cnt/stat.cnt AS ratio
FROM
(
  SELECT category, sub_category, goods_id, COUNT(1) AS cnt
  FROM
  (
    SELECT time, member_id, category, sub_category, goods_id, NTILE(10000)OVER(PARTITION BY category ORDER BY RAND()) AS tile
    FROM sales_slip
  )
  WHERE tile <= 1 -- 0.01%
  GROUP BY category, sub_category, goods_id
) s, stat
WHERE s.category = stat.category AND s.sub_category = stat.sub_category AND s.goods_id = stat.goods_id
ORDER BY cnt_all ASC
```
|category|sub_category|goods_id|cnt_all|cnt|ratio|
|--------|------------|--------|-------|---|-----|
|Automotive and Industrial|Motorcycle and Powersports|282371  |1      |1  |1.0  |
|Sports and Outdoors|Hunting and Fishing|265622  |1      |1  |1.0  |
|Electronics and Computers|Car Electronics and GPS|652662  |1      |1  |1.0  |
|...||  |      |  |  |
|Automotive and Industrial|Industrial Supplies|583266  |23307  |3  |0.00012871669455528383|
|Beauty and Health and Grocery|Menâ€™s Grooming|109090  |547616 |48 |8.765266171916088e-05|
|Automotive and Industrial|Lab and Scientific|109601  |1525984|155|0.0001015738041814331|




```sql
SELECT val, NTILE(10)OVER(ORDER BY RAND()) AS tile
FROM ( VALUES 1,2,3,4 ) AS t(val)
```
|val|tile|
|---|----|
|4  |1   |
|3  |2   |
|1  |3   |
|2  |4   |



```sql
SELECT val, PERCENT_RANK()OVER(ORDER BY RAND()) AS per_rnk
FROM ( VALUES 1,2,3,4 ) AS t(val)
```
|val|per_rnk|
|---|-------|
|1  |0.0    |
|2  |0.3333333333333333|
|4  |0.6666666666666666|
|3  |1.0    |




```sql
SELECT val, CUME_DIST()OVER(ORDER BY RAND()) AS cume
FROM ( VALUES 1,2,3,4 ) AS t(val)
```
|val|cume|
|---|----|
|2  |0.25|
|4  |0.5 |
|3  |0.75|
|1  |1.0 |




### 時系列データを意識した層別サンプリング



```sql
SELECT category, TD_TIME_FORMAT(time, 'yyyy-MM-dd', 'JST') AS d, COUNT(1) AS cnt
FROM sales_slip
GROUP BY category, TD_TIME_FORMAT(time, 'yyyy-MM-dd', 'JST')
ORDER BY cnt ASC
```
|category|d  |cnt|
|--------|---|---|
|Beauty and Health and Grocery|2005-01-05|1  |
|Automotive and Industrial|2005-01-02|1  |
|Toys and Kids and Baby|2005-01-05|1  |




```sql
SELECT category, TD_TIME_FORMAT(time, 'yyyy-MM-01', 'JST') AS m, COUNT(1) AS cnt
FROM sales_slip
GROUP BY category, TD_TIME_FORMAT(time, 'yyyy-MM-01', 'JST')
ORDER BY cnt ASC
```
|category|m  |cnt|
|--------|---|---|
|Clothing and Shoes and Jewelry|2004-12-01|22 |
|Automotive and Industrial|2004-12-01|28 |
|Books and Audible|2004-12-01|51 |




```sql
SELECT *
FROM
(
  SELECT time, member_id, category, sub_category, goods_id, 
    NTILE(379)OVER(PARTITION BY category,TD_TIME_FORMAT(time, 'yyyy-MM-01', 'JST') ORDER BY RAND()) AS tile
  FROM sales_slip
  WHERE TD_TIME_RANGE(time, '2005-01-01', NULL, 'JST')
)
WHERE tile <= 1 -- 1/379 ≒ 0.25%
```
|time|member_id|category|sub_category    |goods_id|tile|
|----|---------|--------|----------------|--------|----|
|1166384297|949366   |Beauty and Health and Grocery|Menâ€™s Grooming|109090  |1   |
|1166003653|949366   |Beauty and Health and Grocery|Menâ€™s Grooming|109090  |1   |
|1167134792|949366   |Beauty and Health and Grocery|Menâ€™s Grooming|109090  |1   |



```sql
WITH stat AS
(
  SELECT category,TD_TIME_FORMAT(time, 'yyyy-MM-01', 'JST') AS m, COUNT(1) AS cnt
  FROM sales_slip
  GROUP BY category,TD_TIME_FORMAT(time, 'yyyy-MM-01', 'JST')
)
SELECT s.category, stat.m, stat.cnt AS cnt_all, s.cnt AS cnt_sample, 1.0*s.cnt/stat.cnt AS ratio
FROM
(
  SELECT category,TD_TIME_FORMAT(time, 'yyyy-MM-01', 'JST') AS m, COUNT(1) AS cnt
  FROM
  (      SELECT time, member_id, category, sub_category, goods_id, 
      NTILE(379)OVER(PARTITION BY category,TD_TIME_FORMAT(time, 'yyyy-MM-01', 'JST') ORDER BY RAND()) AS tile
    FROM sales_slip
    WHERE TD_TIME_RANGE(time, '2005-01-01', NULL, 'JST')
  )
  WHERE tile <= 1 -- 1/379 ≒ 0.25%
  GROUP BY category,TD_TIME_FORMAT(time, 'yyyy-MM-01', 'JST')
) s, stat
WHERE s.category = stat.category AND s.m = stat.m
ORDER BY cnt_all ASC
```
|category|m  |cnt_all|cnt_sample      |ratio |
|--------|---|-------|----------------|------|
|Books and Audible|2005-01-01|379    |1               |0.002638522427440633|
|Books and Audible|2005-02-01|467    |2               |0.004282655246252677|
|Clothing and Shoes and Jewelry|2005-01-01|478    |2               |0.0041841004184100415|
|Movies and Music and Games|2005-01-01|482    |2               |0.004149377593360996|
|Automotive and Industrial|2005-01-01|504    |2               |0.003968253968253968|
|...     |   |       |                |      |
|Automotive and Industrial|2013-07-01|68485  |181             |0.0026429145068263124|
|Automotive and Industrial|2011-11-01|153386 |405             |0.0026403974287092695|
|Automotive and Industrial|2011-10-01|296840 |784             |0.002641153483358038|



