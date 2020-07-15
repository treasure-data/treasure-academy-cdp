# Lesson 18. ゲームログ分析クエリ

## Login KPI

### PV，UU（デイリー）
```sql
SELECT
  TD_TIME_FORMAT(time, 'yyyy-MM-dd', 'JST') AS d,
  COUNT(1) AS pv,
  COUNT(DISTINCT uid) AS uu
FROM login
GROUP BY TD_TIME_FORMAT(time, 'yyyy-MM-dd', 'JST')
ORDER BY d ASC
```
|d         |pv    |uu   |
|----------|------|-----|
|2011-11-29|26853 |21344|
|2011-11-30|113145|36082|
|2011-12-01|117825|38549|


### PV，UU（月次）
```sql
SELECT
  TD_TIME_FORMAT(time, 'yyyy-MM-01', 'JST') AS m,
  COUNT(1) AS pv,
  COUNT(DISTINCT uid) AS uu
FROM login
GROUP BY TD_TIME_FORMAT(time, 'yyyy-MM-01', 'JST')
ORDER BY m ASC
```
|m         |pv    |uu   |
|----------|------|-----|
|2011-11-01|139998|37463|
|2011-12-01|3002783|69371|
|2012-01-01|2904218|54915|
|2012-02-01|2457402|45618|


### PV，UU（月次×デイリーのピボット）

#### 1. 行：日，列：月，値：UU
```sql
WITH 
res_activity AS
(
  SELECT
    TD_TIME_FORMAT(time, 'MM', 'JST') AS m,
    TD_TIME_FORMAT(time, 'dd', 'JST') AS d,
    COUNT(1) AS pv,
    COUNT(DISTINCT uid) AS uu
  FROM login
  WHERE TD_TIME_RANGE(time, '2012-01-01','2013-01-01', 'JST')
  GROUP BY TD_TIME_FORMAT(time, 'MM', 'JST'), TD_TIME_FORMAT(time, 'dd', 'JST')
),
stat AS
(
  SELECT
    TD_TIME_FORMAT(time, 'dd', 'JST') AS d,
    COUNT(1) AS pv_total,
    COUNT(DISTINCT uid) AS uu_total
  FROM login
  WHERE TD_TIME_RANGE(time, '2012-01-01','2013-01-01', 'JST')
  GROUP BY TD_TIME_FORMAT(time, 'dd', 'JST')
)

SELECT d, uu_total,
  IF(ELEMENT_AT(kv,'01') IS NOT NULL, kv['01'], 0) AS m01,
  IF(ELEMENT_AT(kv,'02') IS NOT NULL, kv['02'], 0) AS m02,
  IF(ELEMENT_AT(kv,'03') IS NOT NULL, kv['03'], 0) AS m03,
  IF(ELEMENT_AT(kv,'04') IS NOT NULL, kv['04'], 0) AS m04,
  IF(ELEMENT_AT(kv,'05') IS NOT NULL, kv['05'], 0) AS m05,
  IF(ELEMENT_AT(kv,'06') IS NOT NULL, kv['06'], 0) AS m06,
  IF(ELEMENT_AT(kv,'07') IS NOT NULL, kv['07'], 0) AS m07,
  IF(ELEMENT_AT(kv,'08') IS NOT NULL, kv['08'], 0) AS m08,
  IF(ELEMENT_AT(kv,'09') IS NOT NULL, kv['09'], 0) AS m09,
  IF(ELEMENT_AT(kv,'10') IS NOT NULL, kv['10'], 0) AS m10,
  IF(ELEMENT_AT(kv,'11') IS NOT NULL, kv['11'], 0) AS m11,
  IF(ELEMENT_AT(kv,'12') IS NOT NULL, kv['12'], 0) AS m12
FROM
(
  SELECT t1.d, MAP_AGG(t1.m,uu) AS kv, MAX(uu_total) AS uu_total
  FROM res_activity t1
  JOIN
  ( SELECT * FROM stat ) t2
  ON t1.d = t2.d
  GROUP BY t1.d
)
ORDER BY d
```
|d         |uu_total|m01  |m02  |m03  |m04  |m05  |m06  |m07  |m08  |m09  |m10  |m11  |m12  |
|----------|--------|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
|01        |55090   |31349|28047|28078|23958|20765|19490|18248|18538|18513|17366|16660|15571|
|02        |53690   |31297|27992|26278|23765|20951|19411|18715|18555|18613|17442|16538|15779|
|03        |54067   |31544|27659|25752|24528|20774|19523|18956|18373|18627|17501|16587|15586|
|...       |        |     |     |     |     |     |     |     |     |     |     |     |     |
|28        |47738   |27997|25784|23640|21267|20111|18759|18058|19054|17272|17257|15889|0    |
|29        |48276   |28278|26090|24202|20972|20160|18539|18207|18803|17390|17037|15955|0    |
|30        |46437   |28168|0    |24149|21127|20035|17585|18275|18958|17640|17030|15764|0    |
|31        |42471   |27972|0    |24241|0    |19703|0    |18519|18603|0    |16890|0    |0    |


#### 2. 行：月，列：日，値：PV
```sql
WITH 
res_activity AS
(
  SELECT
    TD_TIME_FORMAT(time, 'MM', 'JST') AS m,
    TD_TIME_FORMAT(time, 'dd', 'JST') AS d,
    COUNT(1) AS pv,
    COUNT(DISTINCT uid) AS uu
  FROM login
  WHERE TD_TIME_RANGE(time, '2012-01-01','2013-01-01', 'JST')
  GROUP BY TD_TIME_FORMAT(time, 'MM', 'JST'), TD_TIME_FORMAT(time, 'dd', 'JST')
),
stat AS
(
  SELECT
    TD_TIME_FORMAT(time, 'MM', 'JST') AS m,
    COUNT(1) AS pv_total,
    COUNT(DISTINCT uid) AS uu_total
  FROM login
  WHERE TD_TIME_RANGE(time, '2012-01-01','2013-01-01', 'JST')
  GROUP BY TD_TIME_FORMAT(time, 'MM', 'JST')
)

SELECT m, pv_total,
  IF(ELEMENT_AT(kv,'01') IS NOT NULL, kv['01'], 0) AS d01,
  IF(ELEMENT_AT(kv,'02') IS NOT NULL, kv['02'], 0) AS d02,
  IF(ELEMENT_AT(kv,'03') IS NOT NULL, kv['03'], 0) AS d03,
  IF(ELEMENT_AT(kv,'04') IS NOT NULL, kv['04'], 0) AS d04,
  IF(ELEMENT_AT(kv,'05') IS NOT NULL, kv['05'], 0) AS d05,
  IF(ELEMENT_AT(kv,'06') IS NOT NULL, kv['06'], 0) AS d06,
  IF(ELEMENT_AT(kv,'07') IS NOT NULL, kv['07'], 0) AS d07,
  IF(ELEMENT_AT(kv,'08') IS NOT NULL, kv['08'], 0) AS d08,
  IF(ELEMENT_AT(kv,'09') IS NOT NULL, kv['09'], 0) AS d09,
  IF(ELEMENT_AT(kv,'10') IS NOT NULL, kv['10'], 0) AS d10,
  IF(ELEMENT_AT(kv,'11') IS NOT NULL, kv['11'], 0) AS d11,
  IF(ELEMENT_AT(kv,'12') IS NOT NULL, kv['12'], 0) AS d12,
  IF(ELEMENT_AT(kv,'13') IS NOT NULL, kv['13'], 0) AS d13,
  IF(ELEMENT_AT(kv,'14') IS NOT NULL, kv['14'], 0) AS d14,
  IF(ELEMENT_AT(kv,'15') IS NOT NULL, kv['15'], 0) AS d15,
  IF(ELEMENT_AT(kv,'16') IS NOT NULL, kv['16'], 0) AS d16,
  IF(ELEMENT_AT(kv,'17') IS NOT NULL, kv['17'], 0) AS d17,
  IF(ELEMENT_AT(kv,'18') IS NOT NULL, kv['18'], 0) AS d18,
  IF(ELEMENT_AT(kv,'19') IS NOT NULL, kv['19'], 0) AS d19,
  IF(ELEMENT_AT(kv,'20') IS NOT NULL, kv['20'], 0) AS d20,
  IF(ELEMENT_AT(kv,'21') IS NOT NULL, kv['21'], 0) AS d21,
  IF(ELEMENT_AT(kv,'22') IS NOT NULL, kv['22'], 0) AS d22,
  IF(ELEMENT_AT(kv,'23') IS NOT NULL, kv['23'], 0) AS d23,
  IF(ELEMENT_AT(kv,'24') IS NOT NULL, kv['24'], 0) AS d24,
  IF(ELEMENT_AT(kv,'25') IS NOT NULL, kv['25'], 0) AS d25,
  IF(ELEMENT_AT(kv,'26') IS NOT NULL, kv['26'], 0) AS d26,
  IF(ELEMENT_AT(kv,'27') IS NOT NULL, kv['27'], 0) AS d27,
  IF(ELEMENT_AT(kv,'28') IS NOT NULL, kv['28'], 0) AS d28,
  IF(ELEMENT_AT(kv,'29') IS NOT NULL, kv['29'], 0) AS d29,
  IF(ELEMENT_AT(kv,'30') IS NOT NULL, kv['30'], 0) AS d30,
  IF(ELEMENT_AT(kv,'31') IS NOT NULL, kv['31'], 0) AS d31
FROM
(
  SELECT t1.m, MAP_AGG(t1.d,uu) AS kv, MAX(pv_total) AS pv_total
  FROM res_activity t1
  JOIN
  ( SELECT * FROM stat ) t2
  ON t1.m= t2.m
  GROUP BY t1.m
)
ORDER BY m
```
|m         |pv_total|d01  |d02  |d03  |d04  |d05  |d06  |d07  |d08  |d09  |d10  |d11  |d12  |d13  |d14  |d15  |d16  |d17  |d18  |d19  |d20  |d21  |d22  |d23  |d24  |d25  |d26  |d27  |d28  |d29  |d30  |d31  |
|----------|--------|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
|01        |2904218 |31349|31297|31544|33611|31767|31001|30812|30753|31169|31089|30420|30489|30424|30170|30279|30332|29951|29880|29775|29448|29466|29252|28777|28735|28476|28265|28034|27997|28278|28168|27972|
|02        |2457402 |28047|27992|27659|27335|27463|27523|27403|26907|26685|26466|26565|26485|26492|26792|26690|26400|24806|25760|26246|26131|25971|25858|25772|28252|26146|25647|25470|25784|26090|0    |0    |
|03        |2451224 |28078|26278|25752|25863|25987|25561|25128|25273|24871|24710|24765|24619|24575|24445|24532|24360|24402|24510|24427|24468|24668|24289|24024|23851|23746|23542|23725|23640|24202|24149|24241|
|04        |2281913 |23958|23765|24528|24157|23725|23384|22979|23106|22953|22813|23038|22493|22307|22365|22336|22412|22344|22161|22109|21871|21822|21802|21805|21749|16365|21607|21224|21267|20972|21127|0    |
|05        |2044811 |20765|20951|20774|20678|20432|20855|21026|21136|21082|21023|20875|20636|20725|20837|20944|20533|20530|20231|20025|20037|20028|19993|19879|19926|20002|19857|20046|20111|20160|20035|19703|
|06        |1849574 |19490|19411|19523|19509|19649|19478|19471|19209|19224|19249|19583|19715|19663|19457|19359|19657|19637|19503|19676|19190|19216|19015|18746|18894|18844|18847|18768|18759|18539|17585|0    |
|07        |1876591 |18248|18715|18956|19009|19124|18981|19369|19371|19399|19165|19090|19242|18878|18807|18647|18914|18909|18709|18633|18738|18404|18513|18787|19030|18945|18666|18346|18058|18207|18275|18519|
|08        |1832644 |18538|18555|18373|18141|18348|18624|18439|18661|18662|18496|18473|18397|18844|19319|19257|19166|19099|18969|19101|19298|19238|19032|19153|18990|18725|18820|19158|19054|18803|18958|18603|
|09        |1761718 |18513|18613|18627|18517|18570|18534|18406|18442|18698|18539|18633|18549|18476|18227|18342|18246|18485|18131|18097|17975|17648|17669|18064|17760|17632|17701|17556|17272|17390|17640|0    |
|10        |1748469 |17366|17442|17501|17392|17328|17303|17255|17527|17251|17311|17301|17301|17111|17400|17370|17347|17423|17330|17247|17207|17210|17413|17369|17147|17031|16911|16935|17257|17037|17030|16890|
|11        |1592621 |16660|16538|16587|16809|16707|16886|16673|16669|16530|16516|16691|16554|16581|16496|16412|16157|16344|16228|16260|16161|16030|15855|16045|15858|15915|15951|15973|15889|15955|15764|0    |
|12        |1323916 |15571|15779|15586|15643|15558|15406|15219|15210|15300|15177|15217|15110|15041|14862|14949|14922|14952|15054|14932|14781|14552|14705|14549|14641|14604|14545|12048|0    |0    |0    |0    |


### 新規ユーザー数（月次）


```sql
SELECT TD_TIME_FORMAT(first_login_time, 'yyyy-MM-01', 'JST') AS m, COUNT(1) AS new_user
FROM
(
  SELECT uid, MIN(time) AS first_login_time
  FROM login
  GROUP BY uid
) t1
GROUP BY TD_TIME_FORMAT(first_login_time, 'yyyy-MM-01', 'JST')
ORDER BY m ASC
```
|m         |new_user|
|----------|--------|
|2011-11-01|37463   |
|2011-12-01|33133   |
|2012-01-01|13163   |


### ログイン回数（デイリー）

```sql
SELECT
  TD_TIME_FORMAT(time, 'yyyy-MM-dd', 'JST') AS d,
  COUNT(1) * 1.0 / COUNT(DISTINCT(uid)) AS play_times
FROM login
GROUP BY TD_TIME_FORMAT(time, 'yyyy-MM-dd', 'JST')
ORDER BY d ASC
```
|d         |play_times|
|----------|----------|
|2011-11-29|1.2581053223388305|
|2011-11-30|3.1357740701734937|
|2011-12-01|3.0564995200913123|


### セッション回数（デイリー）

```sql
SELECT d, AVG(session_cnt) AS avg_session_cnt
FROM
(
  SELECT uid, d, COUNT(DISTINCT session_id) AS session_cnt
  FROM
  (
    SELECT
      uid, time,
      TD_TIME_FORMAT(time, 'yyyy-MM-dd', 'JST') AS d,
      TD_SESSIONIZE_WINDOW(time,60*30)OVER(PARTITION BY uid, TD_TIME_FORMAT(time,'yyyy-MM-dd','JST') ORDER BY time) AS session_id
    FROM login
  )
  GROUP BY uid, d
)
GROUP BY d
ORDER BY d ASC
```
|d         |avg_session_cnt|
|----------|---------------|
|2011-11-29|1.2580116191904047|
|2011-11-30|3.135413779723962|
|2011-12-01|3.054994941503022|


## Monetary KPI

### ARPU，ARPPU，DAU（デイリー）
```sql
WITH stat_login AS
(
  SELECT
    TD_TIME_FORMAT(time, 'yyyy-MM-dd', 'JST') AS d,
    COUNT(distinct uid) AS uu,
    COUNT(1) AS pv
  FROM login
  GROUP BY TD_TIME_FORMAT(time, 'yyyy-MM-dd', 'JST')
),
stat_pay AS
(
  SELECT
    TD_TIME_FORMAT(time, 'yyyy-MM-dd', 'JST') AS d,
    COUNT(distinct uid) AS uu,
    SUM(price*amount) AS sales
  FROM pay
GROUP BY TD_TIME_FORMAT(time, 'yyyy-MM-dd', 'JST')
)

SELECT
  t1.d AS d, t1.uu AS uu_login, t2.uu AS uu_pay,
  1.0*t2.sales/t1.uu AS arpu, 1.0*t2.sales/t2.uu AS arppu
FROM stat_login t1
LEFT OUTER JOIN ( SELECT * FROM stat_pay ) t2
ON (t1.d=t2.d)
ORDER BY d asc, arpu, arppu
```
|d         |uu_login|uu_pay|arpu              |arppu             |
|----------|--------|------|------------------|------------------|
|2011-11-29|21344   |392   |10.217391304347826|556.3265306122449 |
|2011-11-30|36082   |2052  |55.11085859985588 |969.0594541910332 |
|2011-12-01|38549   |2581  |89.38467923940958 |1335.0213095699341|


### ARPU，ARPPU，MAU（月次）
```sql
WITH stat_login AS
(
  SELECT
    TD_TIME_FORMAT(time, 'yyyy-MM-01', 'JST') AS m,
    COUNT(distinct uid) AS uu,
    COUNT(1) AS pv
  FROM login
  GROUP BY TD_TIME_FORMAT(time, 'yyyy-MM-01', 'JST')
),
stat_pay AS
(
  SELECT
    TD_TIME_FORMAT(time, 'yyyy-MM-01', 'JST') AS m,
    COUNT(distinct uid) AS uu,
    SUM(price*amount) AS sales
  FROM pay
GROUP BY TD_TIME_FORMAT(time, 'yyyy-MM-01', 'JST')
)

SELECT
  t1.m AS m, t1.uu AS uu_login, t2.uu AS uu_pay,
  1.0*t2.sales/t1.uu AS arpu, 1.0*t2.sales/t2.uu AS arppu
FROM stat_login t1
LEFT OUTER JOIN ( SELECT * FROM stat_pay ) t2
ON (t1.m=t2.m)
ORDER BY m asc, arpu, arppu
```
|m         |uu_login|uu_pay|arpu              |arppu             |
|----------|--------|------|------------------|------------------|
|2011-11-01|37463   |2168  |58.90051517497264 |1017.799815498155 |
|2011-12-01|69371   |7325  |491.7350189560479 |4656.948805460751 |
|2012-01-01|54915   |6772  |763.247382318128  |6189.269049025399 |


### 新規課金ユーザー（月次）
```sql
SELECT TD_TIME_FORMAT(first_pay_time, 'yyyy-MM-01', 'JST') AS m, COUNT(1) AS new_pay_user
FROM
(
  SELECT uid, MIN(time) AS first_pay_time
  FROM pay
  GROUP BY uid
) t1
GROUP BY TD_TIME_FORMAT(first_pay_time, 'yyyy-MM-01', 'JST')
ORDER BY m ASC
```
|m         |new_pay_user|
|----------|------------|
|2011-11-01|2168        |
|2011-12-01|5274        |
|2012-01-01|1678        |


### クロステーブル：インストール × 最初の課金



```sql
WITH stat AS
(
  SELECT 
    uid, TD_TIME_FORMAT(MIN(time), 'yyyy-MM', 'JST') AS first_pay
  FROM pay
  GROUP BY uid
),
cohort_table AS
(
  SELECT first_login, first_pay, COUNT(1) AS cnt
  FROM
  (
    SELECT
      uid, TD_TIME_FORMAT(MIN(time), 'yyyy-MM', 'JST') AS first_login
    FROM login
    GROUP BY uid
  ) login
  LEFT OUTER JOIN
  (
    SELECT uid, first_pay FROM stat
  ) stat
  ON login.uid = stat.uid
  GROUP BY first_login, first_pay
)

SELECT first_pay,
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
  SELECT first_pay, MAP_AGG(first_login, cnt) AS kv
  FROM cohort_table
  WHERE first_pay IS NOT NULL
  GROUP BY first_pay
)
ORDER BY first_pay ASC
```
|first_pay |m2011_11|m2011_12|m2012_01|m2012_02|m2012_03|m2012_04|m2012_05|m2012_06|m2012_07|m2012_08|m2012_09|m2012_10|m2012_11|m2012_12|
|----------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|
|2011-11   |2168    |0       |0       |0       |0       |0       |0       |0       |0       |0       |0       |0       |0       |0       |
|2011-12   |4654    |620     |0       |0       |0       |0       |0       |0       |0       |0       |0       |0       |0       |0       |
|2012-01   |1144    |277     |257     |0       |0       |0       |0       |0       |0       |0       |0       |0       |0       |0       |
|2012-02   |969     |132     |111     |123     |0       |0       |0       |0       |0       |0       |0       |0       |0       |0       |
|2012-03   |729     |127     |58      |78      |229     |0       |0       |0       |0       |0       |0       |0       |0       |0       |
|2012-04   |265     |50      |31      |25      |86      |150     |0       |0       |0       |0       |0       |0       |0       |0       |
|2012-05   |313     |56      |33      |20      |26      |56      |137     |0       |0       |0       |0       |0       |0       |0       |
|2012-06   |151     |23      |20      |17      |18      |21      |79      |110     |0       |0       |0       |0       |0       |0       |
|2012-07   |143     |41      |16      |15      |19      |15      |42      |67      |266     |0       |0       |0       |0       |0       |
|2012-08   |114     |42      |7       |14      |15      |16      |23      |22      |78      |333     |0       |0       |0       |0       |
|2012-09   |112     |22      |10      |9       |4       |5       |7       |6       |20      |88      |208     |0       |0       |0       |
|2012-10   |102     |34      |10      |7       |5       |7       |3       |11      |17      |17      |42      |217     |0       |0       |
|2012-11   |64      |23      |3       |7       |4       |5       |7       |4       |7       |9       |10      |58      |128     |0       |
|2012-12   |32      |10      |2       |3       |2       |3       |8       |4       |4       |7       |2       |18      |29      |83      |




### 課金ユーザーのコホート分析

```sql
WITH stat AS
(
  SELECT 
    uid, TD_TIME_FORMAT(MIN(time), 'yyyy-MM', 'JST') AS first_pay
  FROM pay
  GROUP BY uid
),
cohort_table AS
(
  SELECT m, first_pay, COUNT(1) AS cnt
  FROM
  (
    SELECT
      uid, TD_TIME_FORMAT(time, 'yyyy-MM', 'JST') AS m
    FROM pay
    GROUP BY uid, TD_TIME_FORMAT(time, 'yyyy-MM', 'JST')
  ) pay
  JOIN
  (
    SELECT uid, first_pay FROM stat
  ) stat
  ON pay.uid = stat.uid
  GROUP BY m, first_pay
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
  SELECT m, MAP_AGG(first_pay, cnt) AS kv
  FROM cohort_table
  GROUP BY m
)
ORDER BY m ASC
```
|m         |m2011_11|m2011_12|m2012_01|m2012_02|m2012_03|m2012_04|m2012_05|m2012_06|m2012_07|m2012_08|m2012_09|m2012_10|m2012_11|m2012_12|
|----------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|
|2011-11   |2168    |0       |0       |0       |0       |0       |0       |0       |0       |0       |0       |0       |0       |0       |
|2011-12   |2051    |5274    |0       |0       |0       |0       |0       |0       |0       |0       |0       |0       |0       |0       |
|2012-01   |1829    |3265    |1678    |0       |0       |0       |0       |0       |0       |0       |0       |0       |0       |0       |
|2012-02   |1684    |2843    |867     |1335    |0       |0       |0       |0       |0       |0       |0       |0       |0       |0       |
|2012-03   |1545    |2479    |686     |643     |1221    |0       |0       |0       |0       |0       |0       |0       |0       |0       |
|2012-04   |1316    |2040    |558     |439     |355     |607     |0       |0       |0       |0       |0       |0       |0       |0       |
|2012-05   |1263    |2045    |557     |449     |313     |218     |641     |0       |0       |0       |0       |0       |0       |0       |
|2012-06   |1088    |1709    |443     |345     |228     |140     |261     |439     |0       |0       |0       |0       |0       |0       |
|2012-07   |1028    |1559    |410     |309     |201     |118     |204     |217     |624     |0       |0       |0       |0       |0       |
|2012-08   |964     |1448    |385     |295     |187     |106     |186     |164     |266     |664     |0       |0       |0       |0       |
|2012-09   |870     |1267    |332     |230     |188     |104     |161     |139     |201     |218     |491     |0       |0       |0       |
|2012-10   |823     |1154    |284     |225     |162     |81      |152     |120     |163     |143     |158     |472     |0       |0       |
|2012-11   |752     |1051    |267     |206     |139     |70      |129     |103     |150     |107     |101     |146     |329     |0       |
|2012-12   |621     |842     |218     |146     |113     |62      |116     |89      |125     |73      |71      |82      |110     |207     |


## Retention KPI
### 直帰率（デイリー）

```sql
WITH stat_bounce AS
(
  SELECT d, COUNT(IF(cnt=1,1,NULL)) AS cnt_bounce
  FROM
  (
    SELECT uid, TD_TIME_FORMAT(time, 'yyyy-MM-dd', 'JST') AS d, COUNT(1) AS cnt
    FROM login
    GROUP BY uid, TD_TIME_FORMAT(time, 'yyyy-MM-dd', 'JST')
  )
  GROUP BY d
),
stat_login AS
(
  SELECT TD_TIME_FORMAT(time, 'yyyy-MM-dd', 'JST') AS d, COUNT(DISTINCT uid) AS uu
  FROM login
  GROUP BY TD_TIME_FORMAT(time, 'yyyy-MM-dd', 'JST')
)

SELECT stat_bounce.d AS d, 1.0*cnt_bounce/uu AS bounce_ratio
FROM stat_bounce,stat_login
WHERE stat_bounce.d = stat_login.d
ORDER BY stat_bounce.d
```
|d         |bounce_ratio|
|----------|------------|
|2011-11-29|0.7599325337331334|
|2011-11-30|0.3021451139072113|
|2011-12-01|0.3351059690264339|
|2011-12-02|0.3002570119566432|

### 3ヶ月後の復帰ユーザー

```sql
--TD_SCHEDULED_TIME()=2012-12-27
WITH recent_users AS
(
  SELECT uid
  FROM login
  WHERE TD_TIME_RANGE( time, TD_TIME_ADD(TD_SCHEDULED_TIME(), '-7d'), TD_SCHEDULED_TIME(), 'JST')
  GROUP BY uid
), 
first_access_users AS
(
  SELECT uid, MIN(time)
  FROM login
  GROUP BY uid
  HAVING MIN(time) < TD_TIME_ADD(TD_SCHEDULED_TIME(),'-97d','JST')
),
no_dormant_users AS
(
  SELECT uid
  FROM login
  WHERE TD_TIME_RANGE( time, TD_TIME_ADD(TD_SCHEDULED_TIME(), '-7d'), TD_TIME_ADD(TD_SCHEDULED_TIME(), '-97d'), 'JST')
  GROUP BY uid
),
dormant_users AS
(
  SELECT first_access_users.uid AS uid
  FROM first_access_users
  LEFT OUTER JOIN no_dormant_users
  ON first_access_users.uid = no_dormant_users.uid
  WHERE no_dormant_users.uid IS NULL
)

SELECT TD_TIME_FORMAT(TD_SCHEDULED_TIME(),'yyyy-MM-dd','JST') AS d, COUNT(1) AS cnt
FROM recent_users,dormant_users
WHERE recent_users.uid=dormant_users.uid
```
|d         |cnt   |
|----------|------|
|2012-12-27|15958 |



### 7日連続ログイン

```sql
--TD_SCHEDULED_TIME()=2012-12-27
WITH login_cnt_7d_table AS
(
  SELECT uid, COUNT( DISTINCT TD_TIME_FORMAT(time, 'yyyy-MM-dd', 'JST')) AS login_cnt
  FROM login
  WHERE TD_INTERVAL(time, '-7d', 'JST') 
  GROUP BY uid
)

SELECT TD_TIME_FORMAT(TD_SCHEDULED_TIME(),'yyyy-MM-dd','JST') AS d, login_cnt, COUNT(1) AS cnt
FROM login_cnt_7d_table
GROUP BY login_cnt
ORDER BY login_cnt
```
|d         |login_cnt|cnt  |
|----------|---------|-----|
|2012-12-27|1        |2877 |
|2012-12-27|2        |1043 |
|2012-12-27|3        |811  |
|2012-12-27|4        |869  |
|2012-12-27|5        |1131 |
|2012-12-27|6        |1909 |
|2012-12-27|7        |10628|




```sql
--TD_SCHEDULED_TIME()=2012-12-27
WITH login_cnt_7d_table AS
(
  SELECT uid, COUNT( DISTINCT TD_TIME_FORMAT(time, 'yyyy-MM-dd', 'JST')) AS login_cnt
  FROM login
  WHERE TD_INTERVAL(time, '-7d', 'JST') 
  GROUP BY uid
)

SELECT TD_TIME_FORMAT(TD_SCHEDULED_TIME(),'yyyy-MM-dd','JST') AS d, login_cnt, COUNT(1) AS cnt
FROM login_cnt_7d_table
GROUP BY login_cnt
HAVING login_cnt=7
```
|d         |login_cnt|cnt  |
|----------|---------|-----|
|2012-12-27|7        |10628|



```sql
--TD_SCHEDULED_TIME()=2012-12-27
WITH login_cnt_7d_table AS
(
  SELECT uid, COUNT( DISTINCT TD_TIME_FORMAT(time, 'yyyy-MM-dd', 'JST')) AS login_cnt
  FROM login
  WHERE TD_INTERVAL(time, '-7d', 'JST') 
  GROUP BY uid
), login_cnt_6d_table AS
(
  SELECT uid, COUNT( DISTINCT TD_TIME_FORMAT(time, 'yyyy-MM-dd', 'JST')) AS login_cnt
  FROM login
  WHERE TD_INTERVAL(time, '-6d', 'JST') 
  GROUP BY uid
)

SELECT TD_TIME_FORMAT(TD_SCHEDULED_TIME(),'yyyy-MM-dd','JST') AS d, login_cnt, COUNT(1) AS cnt
FROM login_cnt_7d_table
GROUP BY login_cnt
HAVING login_cnt=7
UNION ALL
SELECT TD_TIME_FORMAT(TD_SCHEDULED_TIME(),'yyyy-MM-dd','JST') AS d, login_cnt, COUNT(1) AS cnt
FROM login_cnt_6d_table
GROUP BY login_cnt
HAVING login_cnt=6
```
|d         |login_cnt|cnt  |
|----------|---------|-----|
|2012-12-27|6        |10929|
|2012-12-27|7        |10628|


### 頻繁なログインユーザー

```sql
--TD_SCHEDULED_TIME()=2012-12-27
WITH login_cnt_7d_table AS
(
  SELECT uid, COUNT( DISTINCT TD_TIME_FORMAT(time, 'yyyy-MM-dd', 'JST')) AS login_cnt
  FROM login
  WHERE TD_INTERVAL(time, '-7d', 'JST') 
  GROUP BY uid
)

SELECT TD_TIME_FORMAT(TD_SCHEDULED_TIME(),'yyyy-MM-dd','JST') AS d, login_cnt, COUNT(1) AS cnt
FROM login_cnt_7d_table
GROUP BY login_cnt
HAVING 5 <= login_cnt
ORDER BY login_cnt DESC
```
|d         |login_cnt|cnt  |
|----------|---------|-----|
|2012-12-27|7        |10628|
|2012-12-27|6        |1909 |
|2012-12-27|5        |1131 |

