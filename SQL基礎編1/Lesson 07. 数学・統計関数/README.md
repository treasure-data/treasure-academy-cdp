# Lesson 07. 数学・統計関数

## ABS(x) → [same as input]：絶対値

```sql
SELECT val, ABS(val) AS abs_val
FROM ( VALUES -2, -1.1, 0, 1.1, 2 ) AS t(val)
```
|val                                        |abs_val                                          |
|-------------------------------------------|-------------------------------------------------|
|-2.0                                       |2.0                                              |
|-1.1                                       |1.1                                              |
|0.0                                        |0.0                                              |
|1.1                                        |1.1                                              |
|2.0                                        |2.0                                              |


## FLOOR(x)，CEILING(x)，ROUND(x, d) → [same as input]，TRUNCATE(x) → double：整形関数


```sql
SELECT val, 
  FLOOR(val) AS floor_val, 
  CEILING(val) AS ceiling_val, 
  TRUNCATE(val) AS truncate_val, 
  ROUND(val) round_val, ROUND(val,1) round_val2
FROM ( VALUES -1.50, -1.22, -0.65, -0.33, 0.15, 0.50, 0.99, 1.49, 1.50 ) AS t(val)
```
|val                                        |floor_val                                        |ceiling_val|truncate_val|round_val|round_val2|
|-------------------------------------------|-------------------------------------------------|-----------|------------|---------|----------|
|-1.5                                       |-2.0                                             |-1.0       |-1.0        |-2.0     |-1.5      |
|-1.22                                      |-2.0                                             |-1.0       |-1.0        |-1.0     |-1.2      |
|-0.65                                      |-1.0                                             |-0.0       |-0.0        |-1.0     |-0.7      |
|-0.33                                      |-1.0                                             |-0.0       |-0.0        |-0.0     |-0.3      |
|0.15                                       |0.0                                              |1.0        |0.0         |0.0      |0.2       |
|0.5                                        |0.0                                              |1.0        |0.0         |1.0      |0.5       |
|0.99                                       |0.0                                              |1.0        |0.0         |1.0      |1.0       |
|1.49                                       |1.0                                              |2.0        |1.0         |1.0      |1.5       |
|1.5                                        |1.0                                              |2.0        |1.0         |2.0      |1.5       |


## POWER(x, p)，SQRT(x)，CBRT(x) → double：指数関数と平方根

```sql
SELECT val, 
  POWER(val,2) AS pow2, SQRT(val) AS sqrt_val, SQRT(POWER(val,2)) AS val,
  POWER(val,3) AS pow3, CBRT(val) AS cbrt_val, CBRT(POWER(val,3)) AS val
FROM ( VALUES 0, 1, 2, 3, 4, 8, 9 ) AS t(val)
```
|val                                        |pow2                                             |sqrt_val|val |pow3|cbrt_val|val|
|-------------------------------------------|-------------------------------------------------|--------|----|----|--------|---|
|0                                          |0.0                                              |0.0     |0.0 |0.0 |0.0     |0.0|
|1                                          |1.0                                              |1.0     |1.0 |1.0 |1.0     |1.0|
|2                                          |4.0                                              |1.4142135623730951|2.0 |8.0 |1.2599210498948732|2.0|
|3                                          |9.0                                              |1.7320508075688772|3.0 |27.0|1.4422495703074083|3.0|
|4                                          |16.0                                             |2.0     |4.0 |64.0|1.5874010519681996|4.0|
|8                                          |64.0                                             |2.8284271247461903|8.0 |512.0|2.0     |8.0|
|9                                          |81.0                                             |3.0     |9.0 |729.0|2.080083823051904|9.0|


## LOG2(x)，LOG10(x) → double：対数関数


```sql
SELECT 2 AS base,
  LOG2(antilogarithm) AS logarithm, antilogarithm
FROM ( VALUES 0, 1, 2, 4, 8, 9 ) AS t(antilogarithm)
UNION ALL
SELECT 10 AS base,
  LOG10(antilogarithm) AS logarithm, antilogarithm
FROM ( VALUES 0, 1, 10, 100, 2) AS t(antilogarithm)
ORDER BY base ASC
```
|base                                       |logarithm                                        |antilogarithm|
|-------------------------------------------|-------------------------------------------------|-------------|
|2                                          |-Infinity                                        |0            |
|2                                          |0.0                                              |1            |
|2                                          |1.0                                              |2            |
|2                                          |2.0                                              |4            |
|2                                          |3.0                                              |8            |
|2                                          |3.1699250014423126                               |9            |
|10                                         |-Infinity                                        |0            |
|10                                         |0.0                                              |1            |
|10                                         |1.0                                              |10           |
|10                                         |2.0                                              |100          |
|10                                         |0.3010299956639812                               |2            |


## EXP(x)，LN(x) → double：指数関数eと自然対数

```sql
SELECT 'e' AS base,
  LN(antilogarithm) AS logarithm, antilogarithm
FROM ( VALUES EXP(0), EXP(1), EXP(2) ) AS t(antilogarithm)
```
|base                                       |logarithm                                        |antilogarithm|
|-------------------------------------------|-------------------------------------------------|-------------|
|e                                          |0.0                                              |1.0          |
|e                                          |1.0                                              |2.718281828459045|
|e                                          |2.0                                              |7.38905609893065|


## NORMAL_CDF(mean, sd, x) → double：正規分布

```sql
WITH sample AS (
  SELECT val
  FROM ( VALUES 1,2,2,3,3,3,4,4,4,4,5,5,5,5,5,6,6,6,6,7,7,7,8,8,9 ) AS t(val)
),
stat AS
 (
  SELECT AVG(val) AS av, STDDEV(val) AS sd
  FROM sample
)
SELECT DISTINCT val, NORMAL_CDF(av,sd,val) AS prob_cum, av, sd
FROM sample,stat
UNION ALL
SELECT 20 AS val, NORMAL_CDF(av,sd,20) AS prob_cum, av, sd
FROM stat
ORDER BY val
```
|val                                        |prob_cum                                         |av  |sd                |
|-------------------------------------------|-------------------------------------------------|----|------------------|
|1                                          |0.025021760624352463                             |5.0 |2.0412414523193148|
|2                                          |0.07082234514756836                              |5.0 |2.0412414523193148|
|3                                          |0.16359343889515277                              |5.0 |2.0412414523193148|
|4                                          |0.312103057383203                                |5.0 |2.0412414523193148|
|5                                          |0.5                                              |5.0 |2.0412414523193148|
|6                                          |0.687896942616797                                |5.0 |2.0412414523193148|
|7                                          |0.8364065611048472                               |5.0 |2.0412414523193148|
|8                                          |0.9291776548524316                               |5.0 |2.0412414523193148|
|9                                          |0.9749782393756475                               |5.0 |2.0412414523193148|
|20                                         |0.9999999999998997                               |5.0 |2.0412414523193148|



```sql
WITH sample AS (
  SELECT val
  FROM ( VALUES 1,2,2,3,3,3,4,4,4,4,5,5,5,5,5,6,6,6,6,7,7,7,8,8,9 ) AS t(val)
),
stat AS
 (
  SELECT AVG(val) AS av, STDDEV(val) AS sd
  FROM sample
),
cum_norm AS
(
  SELECT DISTINCT val AS distinct_val, NORMAL_CDF(av,sd,val) AS prob_cum, av, sd
  FROM sample,stat
  UNION ALL
  SELECT 20 AS val, NORMAL_CDF(av,sd,20) AS prob_cum, av, sd
  FROM stat
)

SELECT pre_val, val, prob, SUM(prob)OVER(ORDER BY val RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS prob_cum
FROM
(
  SELECT LAG(distinct_val,1,-1*infinity())OVER(ORDER BY distinct_val) AS pre_val, distinct_val AS val, 
    prob_cum-LAG(prob_cum,1,0)OVER(ORDER BY distinct_val) AS prob
  FROM cum_norm
)
ORDER BY val
```
|pre_val                                    |val                                              |prob|prob_cum          |
|-------------------------------------------|-------------------------------------------------|----|------------------|
|-Infinity                                  |1                                                |0.025021760624352463|0.025021760624352463|
|1.0                                        |2                                                |0.04580058452321589|0.07082234514756836|
|2.0                                        |3                                                |0.09277109374758441|0.16359343889515277|
|3.0                                        |4                                                |0.14850961848805022|0.312103057383203 |
|4.0                                        |5                                                |0.187896942616797|0.5               |
|5.0                                        |6                                                |0.187896942616797|0.687896942616797 |
|6.0                                        |7                                                |0.14850961848805022|0.8364065611048472|
|7.0                                        |8                                                |0.09277109374758441|0.9291776548524316|
|8.0                                        |9                                                |0.04580058452321589|0.9749782393756475|
|9.0                                        |20                                               |0.02502176062425221|0.9999999999998997|


## INVERSE_NORMAL_CDF(mean, sd, p) → double

```sql
WITH sample AS (
  SELECT val
  FROM ( VALUES 1,2,2,3,3,3,4,4,4,4,5,5,5,5,5,6,6,6,6,7,7,7,8,8,9 ) AS t(val)
),
stat AS
 (
  SELECT AVG(val) AS av, STDDEV(val) AS sd
  FROM sample
)

SELECT INVERSE_NORMAL_CDF(av,sd,prob_cum) AS val_from_invnorm, val
FROM
(
  SELECT DISTINCT val, NORMAL_CDF(av,sd,val) AS prob_cum, av, sd
  FROM sample,stat
)
ORDER BY val
```
|val_from_invnorm                           |val                                              |
|-------------------------------------------|-------------------------------------------------|
|0.9999999999999973                         |1                                                |
|2.0000000000000004                         |2                                                |
|3.0                                        |3                                                |
|4.0                                        |4                                                |
|5.0                                        |5                                                |
|6.0                                        |6                                                |
|7.0                                        |7                                                |
|8.0                                        |8                                                |
|9.000000000000004                          |9                                                |


## RAND() → double：乱数


```sql
SELECT RAND() AS rnd1, RAND(10) AS rnd2
FROM ( VALUES 1,2,3,4,5 ) AS t(times)
```
|rnd1                                       |rnd2                                             |
|-------------------------------------------|-------------------------------------------------|
|0.18578995295149603                        |8                                                |
|0.9592199594246772                         |0                                                |
|0.47358461964349585                        |4                                                |
|0.20698194503703926                        |9                                                |
|0.27217366101669027                        |2                                                |



## STDDEV(x)，VARIANCE(x) → double：標準偏差，分散 （ただし，数学関数ではなく集約関数）

以下のクエリで```Unexpected parameters (varchar) for function avg.```とエラーが出る場合は，usedcarテーブルのpriceのスキーマがSTRINGになっていますのでLONGに変更しておいてください。

```sql
SELECT name, model, grade, AVG(price) AS avg_price, VARIANCE(price) AS var_price, STDDEV(price) AS stdev_price, COUNT(1) AS cnt
FROM usedcar
GROUP BY name, model, grade
HAVING 100 < COUNT(1)
ORDER BY var_price ASC
```
|name                                       |model                                            |grade            |avg_price         |var_price         |stdev_price       |cnt|
|-------------------------------------------|-------------------------------------------------|-----------------|------------------|------------------|------------------|---|
|ダイハツ                                       |ミライース                                            |660 L メモリアルエディション|745888.5017421603 |2776637874.3207994|52693.81248610504 |287|
|スズキ                                        |アルトラパン                                           |660 ショコラ G       |1150504.5045045046|3126924979.52498  |55918.914327130675|111|
|ダイハツ                                       |タント                                              |660 G スペシャル      |1180456.0         |3432056516.129035 |58583.75641872954 |125|


- 標本分散（サンプルの分散）：VAR_SAMP，VARIANCE
- 不偏分散（母集団の分散）：VAR_POP

## CORR(y, x) → double：相関係数（ただし，数学関数ではなく集約関数）

以下のクエリで```Unexpected parameters (varchar, bigint) for function corr.```とエラーが出る場合は，usedcarテーブルのodd_kmのスキーマがSTRINGになっていますのでLONGに変更しておいてください。

```sql
SELECT name, model, grade, CORR(odd_km,price) AS cor, COUNT(1) AS cnt
FROM usedcar
GROUP BY name, model, grade
HAVING 100 < COUNT(1)
ORDER BY cor ASC
```
|name                                       |model                                            |grade            |cor               |cnt               |
|-------------------------------------------|-------------------------------------------------|-----------------|------------------|------------------|
|スズキ                                        |ワゴンR                                             |660 FX リミテッド 4WD |-0.9055533        |181               |
|スズキ                                        |ワゴンR                                             |660 スティングレー X 4WD|-0.9052105        |169               |
|ホンダ                                        |ライフ                                              |660 G 4WD        |-0.8803281        |142               |


## KURTOSIS(x)，SKEWNESS(x) → double：尖度，歪度（ただし，数学関数ではなく集約関数）


```sql
SELECT name, model, grade, KURTOSIS(odd_km) AS kurt, COUNT(1) AS cnt
FROM usedcar
GROUP BY name, model, grade
HAVING 100 < COUNT(1) AND KURTOSIS(odd_km) < 10
ORDER BY kurt DESC
```
|name                                       |model                                            |grade            |kurt              |cnt               |
|-------------------------------------------|-------------------------------------------------|-----------------|------------------|------------------|
|ダイハツ                                       |ミラココア                                            |660 プラス X        |9.794265678055226 |392               |
|ホンダ                                        |フィット                                             |1.3 G スマートセレクション |9.487795145737548 |290               |
|ホンダ                                        |N-ONE                                            |660 G            |9.247379202802893 |179               |

```sql
SELECT name, model, grade, SKEWNESS(odd_km) AS skew, COUNT(1) AS cnt
FROM usedcar
GROUP BY name, model, grade
HAVING 100 < COUNT(1)
ORDER BY skew DESC
```
|name                                       |model                                            |grade            |skew              |cnt               |
|-------------------------------------------|-------------------------------------------------|-----------------|------------------|------------------|
|日産                                         |ノート                                              |1.5 15S Vパッケージ   |11.511944337974466|254               |
|ダイハツ                                       |ミライース                                            |660 L メモリアルエディション|11.377413612122172|287               |
|ダイハツ                                       |ミラジーノ                                            |660 ミニライトスペシャル   |10.288540573552194|313               |


## REGR_SLOPE(y, x)，REGR_INTERCEPT(y, x) → double：単純回帰（ただし，数学関数ではなく集約関数）


```sql
SELECT name, model, grade, CORR(price,odd_km) AS cor,
  REGR_SLOPE(price,odd_km) AS slope, REGR_INTERCEPT(price,odd_km) AS itcpt, COUNT(1) AS cnt
FROM usedcar
GROUP BY name, model, grade
HAVING 100 < COUNT(1)
ORDER BY cor ASC
```
|name                                       |model                                            |grade            |cor               |slope             |itcpt    |cnt|
|-------------------------------------------|-------------------------------------------------|-----------------|------------------|------------------|---------|---|
|スズキ                                        |ワゴンR                                             |660 FX リミテッド 4WD |-0.9055533        |-7.736353         |1182057.1|181|
|スズキ                                        |ワゴンR                                             |660 スティングレー X 4WD|-0.9052105        |-7.3997245        |1291553.8|169|
|ホンダ                                        |ライフ                                              |660 G 4WD        |-0.8803281        |-8.574498         |1104132.5|142|

