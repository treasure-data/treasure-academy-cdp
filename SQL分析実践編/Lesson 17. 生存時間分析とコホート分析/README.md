# Lesson 17. 生存時間分析とコホート分析

## コホート分析

```sql
WITH stat AS
(
  SELECT 
    uid, TD_TIME_FORMAT(MIN(time), 'yyyy-MM', 'JST') AS first_login
  FROM login
  GROUP BY uid
)

SELECT m, first_login, COUNT(1) AS cnt
FROM
(
  SELECT
    uid, TD_TIME_FORMAT(time, 'yyyy-MM', 'JST') AS m
  FROM login
  GROUP BY uid, TD_TIME_FORMAT(time, 'yyyy-MM', 'JST')
) login
JOIN
(
  SELECT uid, first_login FROM stat
) stat
ON login.uid = stat.uid
GROUP BY m, first_login
ORDER BY m, first_login
```
|m  |first_login      |cnt               |
|---|-----------------|------------------|
|2011-11|2011-11          |37463             |
|2011-12|2011-11          |36238             |
|2011-12|2011-12          |33133             |



```sql
WITH stat AS
(
  SELECT 
    uid, TD_TIME_FORMAT(MIN(time), 'yyyy-MM', 'JST') AS first_login
  FROM login
  GROUP BY uid
),
login_table AS
(
  SELECT
    uid, TD_TIME_FORMAT(time, 'yyyy-MM', 'JST') AS m
  FROM login
  GROUP BY uid, TD_TIME_FORMAT(time, 'yyyy-MM', 'JST')
),
cohort_table AS
(
  SELECT m, first_login, COUNT(1) AS cnt
  FROM login_table login JOIN stat
  ON login.uid = stat.uid
  GROUP BY m, first_login
)

SELECT m,
  IF(ELEMENT_AT(kv,'2011-11') IS NOT NULL, kv['2011-11'], 0) AS m2011_11,
  IF(ELEMENT_AT(kv,'2011-12') IS NOT NULL, kv['2011-12'], 0) AS m2011_12,
  IF(ELEMENT_AT(kv,'2012-01') IS NOT NULL, kv['2012-01'], 0) AS m2012_01,
  IF(ELEMENT_AT(kv,'2012-02') IS NOT NULL, kv['2012-02'], 0) AS m2012_02,
  IF(ELEMENT_AT(kv,'2012-03') IS NOT NULL, kv['2012-03'], 0) AS m2012_03,
  IF(ELEMENT_AT(kv,'2012-04') IS NOT NULL, kv['2012-04'], 0) AS m2012_04,
  IF(ELEMENT_AT(kv,'2012-05') IS NOT NULL, kv['2012-05'], 0) AS m2012_05,
  IF(ELEMENT_AT(kv,'2012-06') IS NOT NULL, kv['2012-06'], 0) AS m2012_06,
  IF(ELEMENT_AT(kv,'2012-07') IS NOT NULL, kv['2012-07'], 0) AS m2012_07,
  IF(ELEMENT_AT(kv,'2012-08') IS NOT NULL, kv['2012-08'], 0) AS m2012_08,
  IF(ELEMENT_AT(kv,'2012-09') IS NOT NULL, kv['2012-09'], 0) AS m2012_09,
  IF(ELEMENT_AT(kv,'2012-10') IS NOT NULL, kv['2012-10'], 0) AS m2012_10,
  IF(ELEMENT_AT(kv,'2012-11') IS NOT NULL, kv['2012-11'], 0) AS m2012_11,
  IF(ELEMENT_AT(kv,'2012-12') IS NOT NULL, kv['2012-12'], 0) AS m2012_12  
FROM
(
  SELECT m, MAP_AGG(first_login, cnt) AS kv
  FROM cohort_table
  GROUP BY m
)
ORDER BY m ASC
```
|m  |m2011_11         |m2011_12          |m2012_01|m2012_02|m2012_03|m2012_04|m2012_05|m2012_06|m2012_07|m2012_08|m2012_09|m2012_10|m2012_11|m2012_12|
|---|-----------------|------------------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|
|2011-11|37463            |0                 |0       |0       |0       |0       |0       |0       |0       |0       |0       |0       |0       |0       |
|2011-12|36238            |33133             |0       |0       |0       |0       |0       |0       |0       |0       |0       |0       |0       |0       |
|2012-01|31552            |10200             |13163   |0       |0       |0       |0       |0       |0       |0       |0       |0       |0       |0       |
|2012-02|27719            |7001              |3326    |7572    |0       |0       |0       |0       |0       |0       |0       |0       |0       |0       |
|2012-03|25378            |5767              |2337    |2590    |13883   |0       |0       |0       |0       |0       |0       |0       |0       |0       |
|2012-04|22532            |4184              |1547    |1130    |3280    |8252    |0       |0       |0       |0       |0       |0       |0       |0       |
|2012-05|20536            |3551              |1287    |905     |1559    |1608    |4813    |0       |0       |0       |0       |0       |0       |0       |
|2012-06|18997            |3232              |1140    |904     |1279    |1097    |1410    |4383    |0       |0       |0       |0       |0       |0       |
|2012-07|17866            |3087              |1079    |820     |1134    |897     |972     |1283    |8964    |0       |0       |0       |0       |0       |
|2012-08|16753            |3028              |1026    |665     |1050    |784     |807     |882     |2611    |16543   |0       |0       |0       |0       |
|2012-09|15372            |2435              |829     |480     |798     |590     |619     |609     |1345    |3435    |9731    |0       |0       |0       |
|2012-10|14486            |2272              |760     |456     |726     |548     |559     |527     |1099    |1855    |1987    |8010    |0       |0       |
|2012-11|13552            |2016              |690     |380     |628     |449     |505     |480     |872     |1301    |1001    |1967    |6994    |0       |
|2012-12|12598            |1728              |595     |334     |557     |393     |462     |382     |744     |991     |696     |972     |1358    |4223    |




## 継続期間

```sql
WITH histo AS
(
  SELECT HISTOGRAM(term) AS res_map
  FROM
  (
    SELECT uid, 
     FLOOR( 1.0*(MAX(time)-MIN(time))/(60*60*24) )+1 AS term
    FROM login
    GROUP BY uid
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
|1.0|72918            |
|2.0|4078             |
|3.0|2780             |
|...|                 |
|392.0|633              |
|393.0|2118             |
|394.0|7849             |




## 生存時間集計（単純集計）


```sql
WITH term_table AS
(
  SELECT term, COUNT(1) AS cnt
  FROM
  (
    SELECT uid, FLOOR( 1.0*(MAX(time)-MIN(time))/(60*60*24) )+1 AS term
    FROM login  
    GROUP BY uid
  )
  GROUP BY term
  UNION ALL
  SELECT term, cnt
  FROM ( VALUES (0,0) ) AS t(term, cnt)
),
stats AS
(
  SELECT SUM(cnt) AS cnt_total
  FROM term_table
)

SELECT 
  term,
    cnt_total-SUM(cnt)OVER(ORDER BY term RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS survival_cnt,
  1.0*(cnt_total-SUM(cnt)OVER(ORDER BY term RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW))/cnt_total  AS survival_ratio
FROM term_table, stats
ORDER BY term
```
|term|survival_cnt     |survival_ratio      |
|----|-----------------|--------------------|
|0.0 |177127           |1.0                 |
|1.0 |104209           |0.5883292778627764  |
|2.0 |100131           |0.5653062491884354  |
|... |                 |                    |
|392.0|9967             |0.05627035968542345 |
|393.0|7849             |0.044312837681437615|
|394.0|0                |0.0                 |




```sql
WITH term_table AS
(
  SELECT term, COUNT(1) AS cnt
  FROM
  (
    SELECT uid, FLOOR( 1.0*(MAX(time)-MIN(time))/(60*60*24*7) )+1 AS term
    FROM login  
    GROUP BY uid
  )
  GROUP BY term
  UNION ALL
  SELECT term, cnt
  FROM ( VALUES (0,0) ) AS t(term, cnt)
),
stats AS
(
  SELECT SUM(cnt) AS cnt_total
  FROM term_table
)

SELECT 
  term,
    cnt_total-SUM(cnt)OVER(ORDER BY term RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS survival_cnt,
  1.0*(cnt_total-SUM(cnt)OVER(ORDER BY term RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW))/cnt_total  AS survival_ratio
FROM term_table, stats
ORDER BY term
```
|term|survival_cnt     |survival_ratio      |
|----|-----------------|--------------------|
|0.0 |177127           |1.0                 |
|1.0 |89541            |0.5055186391685063  |
|2.0 |81196            |0.45840555081946854 |
|... |                 |                    |
|55.0|12005            |0.06777622835592541 |
|56.0|9967             |0.05627035968542345 |
|57.0|0                |0.0                 |


## 生存時間分析

```sql
--TD_SCHEDULED_TIME()=2012-12-27
WITH term_table AS
(
  SELECT uid, FLOOR( 1.0*(MAX(time)-MIN(time))/(60*60*24*7) )+1 AS term,
    IF( MAX(time)<TD_TIME_ADD(TD_SCHEDULED_TIME(),'-2w','JST'),1,0 ) AS is_cancelled
  FROM login  
  GROUP BY uid
),
term_cnt_table AS
(
  SELECT term,
    COUNT(1) AS cnt,
    COUNT(IF(is_cancelled=1,1,NULL)) AS cancel_cnt,
    COUNT(IF(is_cancelled=0,1,NULL)) AS censored_cnt
  FROM term_table
  GROUP BY term
  UNION ALL
  SELECT term, cnt, cancel_cnt, censored_cnt
  FROM ( VALUES (0,0,0,0) ) AS t(term,cnt,cancel_cnt,censored_cnt)
),
stats AS
(
  SELECT SUM(cnt) AS total_cnt
  FROM term_cnt_table
)

SELECT term, cancel_cnt, censored_cnt, 
  LAG(survival_cnt,1,survival_cnt)OVER(ORDER BY term) AS including_risk_cnt,
  1.0*survival_cnt/total_cnt  AS survival_ratio
FROM
(
  SELECT *, total_cnt-SUM(cnt)OVER(ORDER BY term RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS survival_cnt
  FROM term_cnt_table, stats
)
```
|term|cancel_cnt       |censored_cnt        |including_risk_cnt|survival_ratio     |
|----|-----------------|--------------------|------------------|-------------------|
|0.0 |0                |0                   |177127            |1.0                |
|1.0 |85140            |2446                |177127            |0.5055186391685063 |
|2.0 |8053             |292                 |89541             |0.45840555081946854|
|... |                 |                    |                  |                   |
|55.0|104              |766                 |12875             |0.06777622835592541|
|56.0|0                |2038                |12005             |0.05627035968542345|
|57.0|0                |9967                |9967              |0.0                |



```sql
--TD_SCHEDULED_TIME()=2012-12-27
WITH term_table AS
(
  SELECT uid, FLOOR( 1.0*(MAX(time)-MIN(time))/(60*60*24*7) )+1 AS term,
    IF( MAX(time)<TD_TIME_ADD(TD_SCHEDULED_TIME(),'-2w','JST'),1,0 ) AS is_cancelled 
  FROM login  
  GROUP BY uid
),
term_cnt_table AS
(
  SELECT term,
    COUNT(1) AS cnt,
    COUNT(IF(is_cancelled=1,1,NULL)) AS cancel_cnt,
    COUNT(IF(is_cancelled=0,1,NULL)) AS censored_cnt
  FROM term_table
  GROUP BY term
  UNION ALL
  SELECT term, cnt, cancel_cnt, censored_cnt
  FROM ( VALUES (0,0,0,0) ) AS t(term,cnt,cancel_cnt,censored_cnt)
),
stats AS
(
  SELECT SUM(cnt) AS total_cnt
  FROM term_cnt_table
),
input_table AS
(
  SELECT term, cancel_cnt, censored_cnt, 
    LAG(survival_cnt,1,survival_cnt)OVER(ORDER BY term) AS including_risk_cnt,
    1.0*survival_cnt/total_cnt  AS survival_ratio
  FROM
  (
    SELECT *, total_cnt-SUM(cnt)OVER(ORDER BY term RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS survival_cnt
    FROM term_cnt_table, stats
  )
),
survival_stat AS
(
  SELECT *, 1-(1.0*cancel_cnt/including_risk_cnt) AS km_stat_seed, 1.0*cancel_cnt/including_risk_cnt AS nelson_aalen_stat_seed
  FROM input_table
)

SELECT *,
  EXP(SUM(LN(km_stat_seed))OVER(ORDER BY term ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)) AS km_stat,
  EXP(-SUM(nelson_aalen_stat_seed)OVER(ORDER BY term ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)) AS nelson_aalen_stat
FROM survival_stat
```
|term|cancel_cnt       |censored_cnt        |including_risk_cnt|survival_ratio     |km_stat_seed     |nelson_aalen_stat_seed|km_stat            |nelson_aalen_stat |
|----|-----------------|--------------------|------------------|-------------------|-----------------|----------------------|-------------------|------------------|
|0.0 |0                |0                   |177127            |1.0                |1.0              |0.0                   |1.0                |1.0               |
|1.0 |85140            |2446                |177127            |0.5055186391685063 |0.519327939839776|0.480672060160224     |0.519327939839776  |0.6183676718507567|
|2.0 |8053             |292                 |89541             |0.45840555081946854|0.910063546308395|0.08993645369160497   |0.47262142662761936|0.5651814133192471|
|... |                 |                    |                  |                   |                 |                      |                   |                  |
|56.0|0                |2038                |12005             |0.05627035968542345|1.0              |0.0                   |0.09324008835823522|0.1145329256773586|
|57.0|0                |9967                |9967              |0.0                |1.0              |0.0                   |0.09324008835823522|0.1145329256773586|



### sample_access_log

sample_access_logの生存時間分析は以下のクエリで実行できます。
- term_tableのFROM節：「sample_access_log」
- ユーザー識別子：「td_client_id」
- いつまでアクセスなければ退会とみなすか：「1w」
- そして観測日をいつとみなすか：「TD_SCHEDULED_TIME() = 2016-07-05」
- termの単位の部分：「日単位」

```sql
--TD_SCHEDULED_TIME()=2016-07-05
WITH term_table AS
(
    SELECT td_client_id, FLOOR( 1.0*(MAX(time)-MIN(time))/(60*60*24) )+1 AS term,
      IF( MAX(time)<TD_TIME_ADD(TD_SCHEDULED_TIME(),'-1w','JST'),1,0 ) AS is_cancelled
    FROM sample_accesslog
    GROUP BY td_client_id
),
term_cnt_table AS
(
  SELECT term,
    COUNT(1) AS cnt,
    COUNT(IF(is_cancelled=1,1,NULL)) AS cancel_cnt,
    COUNT(IF(is_cancelled=0,1,NULL)) AS censored_cnt
  FROM term_table
  GROUP BY term
  UNION ALL
  SELECT term, cnt, cancel_cnt, censored_cnt
  FROM ( VALUES (0,0,0,0) ) AS t(term,cnt,cancel_cnt,censored_cnt)
),
stats AS
(
  SELECT SUM(cnt) AS total_cnt
  FROM term_cnt_table
),
input_table AS
(
  SELECT term, cancel_cnt, censored_cnt, LAG(survival_cnt,1,survival_cnt)OVER(ORDER BY term) AS including_risk_cnt,
    1.0*survival_cnt/total_cnt  AS survival_ratio
  FROM
  (
    SELECT *, total_cnt-SUM(cnt)OVER(ORDER BY term RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS survival_cnt
    FROM term_cnt_table, stats
  )
),
survival_stat AS
(
  SELECT *, 1-(1.0*cancel_cnt/including_risk_cnt) AS km_stat_seed, 1.0*cancel_cnt/including_risk_cnt AS nelson_aalen_stat_seed
  FROM input_table
)

SELECT *,
  EXP(SUM(LN(km_stat_seed))OVER(ORDER BY term ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)) AS km_stat,
  EXP(-SUM(nelson_aalen_stat_seed)OVER(ORDER BY term ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)) AS nelson_aalen_stat
FROM survival_stat
```
|term|cancel_cnt       |censored_cnt        |including_risk_cnt|survival_ratio     |km_stat_seed     |nelson_aalen_stat_seed|km_stat            |nelson_aalen_stat |
|----|-----------------|--------------------|------------------|-------------------|-----------------|----------------------|-------------------|------------------|
|0.0 |0                |0                   |26938             |1.0                |1.0              |0.0                   |1.0                |1.0               |
|1.0 |21156            |3310                |26938             |0.0917662781201277 |0.21464102754473235|0.7853589724552676    |0.21464102754473235|0.45595599676094856|
|2.0 |235              |47                  |2472              |0.0812977949365209 |0.9049352750809061|0.09506472491909385   |0.19423623730484071|0.4146072064765174|
|... |                 |                    |                  |                   |                 |                      |                   |                  |
|71.0|0                |7                   |9                 |7.424456158586383e-05|1.0              |0.0                   |0.012644094819647312|0.029070146277051904|
|72.0|0                |1                   |2                 |3.712228079293192e-05|1.0              |0.0                   |0.012644094819647312|0.029070146277051904|
|73.0|0                |1                   |1                 |0.0                |1.0              |0.0                   |0.012644094819647312|0.029070146277051904|



### sales_slip
sales_slipの生存時間分析は以下のクエリで実行できます。
- termsテーブルのFROM節：「sales_slip」
- ユーザー識別子：「member_id」
- いつまでアクセスなければ退会とみなすか：「1m」
- そして観測日をいつとみなすか：「TD_SCHEDULED_TIME() = 2013-12-19」
- play_term_from_installの単位の部分：「月単位」

```sql
--TD_SCHEDULED_TIME()=2013-12-19
WITH term_table AS
(
    SELECT member_id, FLOOR( 1.0*(MAX(time)-MIN(time))/(60*60*24*7*30) )+1 AS term,
      IF( MAX(time)<TD_TIME_ADD(TD_SCHEDULED_TIME(),'-1m','JST'),1,0 ) AS is_cancelled 
    FROM sales_slip
    GROUP BY member_id
),
term_cnt_table AS
(
  SELECT term,
    COUNT(1) AS cnt,
    COUNT(IF(is_cancelled=1,1,NULL)) AS cancel_cnt,
    COUNT(IF(is_cancelled=0,1,NULL)) AS censored_cnt
  FROM term_table
  GROUP BY term
  UNION ALL
  SELECT term, cnt, cancel_cnt, censored_cnt
  FROM ( VALUES (0,0,0,0) ) AS t(term,cnt,cancel_cnt,censored_cnt)
),
stats AS
(
  SELECT SUM(cnt) AS total_cnt
  FROM term_cnt_table
),
input_table AS
(
  SELECT term, cancel_cnt, censored_cnt, LAG(survival_cnt,1,survival_cnt)OVER(ORDER BY term) AS including_risk_cnt,
    1.0*survival_cnt/total_cnt  AS survival_ratio
  FROM
  (
    SELECT *, total_cnt-SUM(cnt)OVER(ORDER BY term RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS survival_cnt
    FROM term_cnt_table, stats
  )
),
survival_stat AS
(
  SELECT *, 1-(1.0*cancel_cnt/including_risk_cnt) AS km_stat_seed, 1.0*cancel_cnt/including_risk_cnt AS nelson_aalen_stat_seed
  FROM input_table
)

SELECT *,
  EXP(SUM(LN(km_stat_seed))OVER(ORDER BY term ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)) AS km_stat,
  EXP(-SUM(nelson_aalen_stat_seed)OVER(ORDER BY term ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)) AS nelson_aalen_stat
FROM survival_stat
```
|term|cancel_cnt       |censored_cnt        |including_risk_cnt|survival_ratio     |km_stat_seed     |nelson_aalen_stat_seed|km_stat            |nelson_aalen_stat |
|----|-----------------|--------------------|------------------|-------------------|-----------------|----------------------|-------------------|------------------|
|0.0 |0                |0                   |9593              |1.0                |1.0              |0.0                   |1.0                |1.0               |
|1.0 |13               |1                   |9593              |0.9985406025226727 |0.9986448451996247|0.0013551548003752736 |0.9986448451996247 |0.9986457630072539|
|2.0 |45               |0                   |9579              |0.9938496820598353 |0.995302223614156|0.004697776385844034  |0.993953435028001  |0.9939653508964252|
|... |                 |                    |                  |                   |                 |                      |                   |                  |
|14.0|927              |7                   |4213              |0.3418117377254248 |0.7799667695229053|0.2200332304770947    |0.34558658440416273|0.3719888370297805|
|15.0|1350             |6                   |3279              |0.20045866777858856|0.5882891125343093|0.41171088746569073   |0.20330482504288805|0.2464484782305023|
|16.0|1896             |27                  |1923              |0.0                |0.01404056162246492|0.9859594383775351    |0.0028545139241591203|0.09194527103609064|



