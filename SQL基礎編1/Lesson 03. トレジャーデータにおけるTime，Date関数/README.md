# Lesson 03. トレジャーデータにおけるTime，Date関数

## TD_TIME_FORMAT
```sql
string TD_TIME_FORMAT(long unix_timestamp,
                      string format
                      [, string timezone = 'UTC'])
```


|Syntax    |Date or Time Component|Presentation|Examples                           |
|----------|----------------------|------------|-----------------------------------|
|G         |Era designator        |Text        |AD                                 |
|yyyy      |Year                  |Year        |1996                               |
|yy        |Year                  |Year（2 digits）|96                                 |
|MMMM      |Month in year         |Month long name|July                               |
|MMM       |Month in year         |Month short name|Jul                                |
|MM, M     |Month in year         |Month number|7                                  |
|ww，w      |Week in year          |Number      |6                                  |
|DDD, DD, D|Day in year           |Number      |189                                |
|dd, d     |Day in month          |Number      |10                                 |
|EEEE      |Day in week           |Text        |Tuesday                            |
|E，EEE     |Day in week           |Text（short form）|Tue                                |
|a         |Am/pm marker          |Text        |PM                                 |
|HH，H      |Hour in day（0-23）     |Number      |0                                  |
|kk，k      |Hour in day（1-24）     |Number      |24                                 |
|KK，K      |Hour in AM/PM（0-11）   |Number      |0                                  |
|hh，h      |Hour in AM/PM（1-12）   |Number      |12                                 |
|mm，m      |Minute in hour        |Number      |30                                 |
|ss，s      |Second in minute      |Number      |55                                 |
|SSS，SS，S  |Millisecond           |Number      |978                                |
|zzzz      |Time zone             |Zone long name|Pacific Standard Time, or GMT+01:00|
|z         |Time zone             |Zone short name|PST, or GMT+01:00                  |
|Z         |Time zone             |Zone offset |-800                               |
|u         |Day number of week（1-7）|Number      |1（for Monday）                      |

```sql
SELECT 
  TD_TIME_FORMAT(time,'yyyy-MM-dd','JST') AS day1,
  TD_TIME_FORMAT(time,'yyyy/MM/dd','JST') AS day2,
  TD_TIME_FORMAT(time,'yyyy/M/d'  ,'JST') AS day3,
  TD_TIME_FORMAT(time,'yyyy-MM-dd HH:mm:ss'      ,'JST') AS time1,
  TD_TIME_FORMAT(time,'yyyy-MM-dd hh:mm:ss a'    ,'JST') AS time2,
  TD_TIME_FORMAT(time,'yyyy-MM-dd HH:mm:ss:SSS'  ,'JST') AS time3,
  TD_TIME_FORMAT(time,'yyyy-MM-dd HH:mm:ss:SSS z','JST') AS time4
FROM ( VALUES 1466409507 ) AS t(time)
```
|day1      |day2         |day3|time1                              |time2                 |time3                  |time4                            |
|----------|-------------|----|-----------------------------------|----------------------|-----------------------|---------------------------------|
|2016-06-20|2016/06/20   |2016/6/20|2016-06-20 16:58:27                |2016-06-20 04:58:27 PM|2016-06-20 16:58:27:000|2016-06-20 16:58:27:000 GMT+09:00|


```sql
SELECT
  TD_TIME_FORMAT(time, 'yyyy-MM-dd', 'JST') AS d1,
  TD_TIME_FORMAT(time, 'yyyy-MM-dd HH:00:00', 'JST') AS d2,
  TD_TIME_FORMAT(time, 'yyyy-MM-dd HH:mm:00', 'JST') AS d3,
  TD_TIME_FORMAT(time, 'yyyy-MM-dd HH:mm:ss', 'JST') AS d4
FROM sample_accesslog
ORDER BY time DESC
LIMIT 10
```
|d1        |d2           |d3 |d4                                 |
|----------|-------------|---|-----------------------------------|
|2016-07-05|2016-07-05 15:00:00|2016-07-05 15:11:00|2016-07-05 15:11:40                |
|2016-07-05|2016-07-05 15:00:00|2016-07-05 15:11:00|2016-07-05 15:11:40                |
|2016-07-05|2016-07-05 15:00:00|2016-07-05 15:11:00|2016-07-05 15:11:21                |


```sql
SELECT DISTINCT
  TD_TIME_FORMAT(time, 'yyyy-MM-dd', 'JST') AS d,
  CASE TD_TIME_FORMAT(time, 'u', 'JST')
    WHEN '1' THEN 'Monday'
    WHEN '2' THEN 'Tuesday'
    WHEN '3' THEN 'Wednesday'
    WHEN '4' THEN 'Thursday'
    WHEN '5' THEN 'Friday'
    WHEN '6' THEN 'Saturday'
    WHEN '7' THEN 'Sunday'
    ELSE 'Error'
  END AS day_of_the_week
FROM sample_accesslog
ORDER BY d
```
|d         |day_of_the_week|
|----------|---------------|
|2016-04-23|Saturday       |
|2016-04-24|Sunday         |
|2016-04-25|Monday         |
|2016-04-26|Tuesday        |
|2016-04-27|Wednesday      |
|2016-04-28|Thursday       |
|2016-04-29|Friday         |


## TD_TIME_RANGE
```sql
boolean TD_TIME_RANGE(int/long unix_timestamp,                            
                      int/long/string start_time,
                      int/long/string end_time
                      [, string default_timezone = 'UTC'])
```


### A. 特定の時間軸での範囲指定

```sql
SELECT ... WHERE TD_TIME_RANGE(time, '2018-01-01', '2018-02-01','JST') --月
SELECT ... WHERE TD_TIME_RANGE(time, '2018-01-01', '2018-01-08','JST') --週
SELECT ... WHERE TD_TIME_RANGE(time, '2018-01-01', '2018-01-02','JST') --日
SELECT ... WHERE TD_TIME_RANGE(time, '2018-01-01 00:00:00', '2018-01-01 01:00:00','JST') --時間
SELECT ... WHERE TD_TIME_RANGE(time, '2018-01-01 00:00:00', '2018-01-01 00:01:00','JST') --分
```

```sql
WHERE start_time <= time AND time < end_time --NG
```

```sql
SELECT ... WHERE TD_TIME_RANGE(time, '2013-01-01','JST')        --NG
SELECT ... WHERE TD_TIME_RANGE(time, '2013-01-01', NULL, 'JST') --OK
```

```sql
SELECT ... WHERE TD_TIME_RANGE(time, '2013-01-01',
                               TD_TIME_ADD('2013-01-01', '1', 'JST'))      --OK
SELECT ... WHERE TD_TIME_RANGE(time, TD_SCHEDULED_TIME() / 86400 * 86400)) --NG
SELECT ... WHERE TD_TIME_RANGE(time, 1356998401 / 86400 * 86400))          --NG
```


```sql
SELECT
  TD_TIME_FORMAT(time, 'yyyy-MM-dd HH:mm:ss', 'JST') AS d
FROM sample_accesslog
WHERE TD_TIME_RANGE(time, '2016-05-01','2016-06-01','JST')
LIMIT 10
```
|d         |FIELD2       |FIELD3|
|----------|-------------|------|
|2016-05-18 14|28           |07    |
|2016-05-24 13|32           |18    |
|2016-05-18 14|09           |36    |


```sql
SELECT
  TD_TIME_FORMAT(MIN(time), 'yyyy-MM-dd HH:mm:ss', 'JST') AS min_d,
  TD_TIME_FORMAT(MAX(time), 'yyyy-MM-dd HH:mm:ss', 'JST') AS max_d
FROM sample_accesslog
WHERE TD_TIME_RANGE(time, '2016-05-01','2016-06-01','JST')
```
|min_d     |max_d        |
|----------|-------------|
|2016-05-01 00:02:12|2016-05-31 23:58:55|


### B. 「始点以降」/「終点未満」

```sql
SELECT ... WHERE TD_TIME_RANGE(time, '2018-01-01', NULL, 'JST') --始点以降
SELECT ... WHERE TD_TIME_RANGE(time, NULL, '2018-01-01', 'JST') --終点未満
SELECT ... WHERE TD_TIME_RANGE(time, NULL, '2018-01-01 JST')    --始点以降
```

#### 2016年5月未満
```sql
SELECT
  TD_TIME_FORMAT(MIN(time), 'yyyy-MM-dd HH:mm:ss', 'JST') AS min_d,
  TD_TIME_FORMAT(MAX(time), 'yyyy-MM-dd HH:mm:ss', 'JST') AS max_d
FROM sample_accesslog
WHERE TD_TIME_RANGE(time, NULL, '2016-05-01','JST')
```
|min_d     |max_d        |
|----------|-------------|
|2016-04-23 01:20:50|2016-04-30 23:35:14|


#### 2016年5月以降

```sql
SELECT
  TD_TIME_FORMAT(MIN(time), 'yyyy-MM-dd HH:mm:ss', 'JST') AS min_d,
  TD_TIME_FORMAT(MAX(time), 'yyyy-MM-dd HH:mm:ss', 'JST') AS max_d
FROM sample_accesslog
WHERE TD_TIME_RANGE(time, '2016-05-01',NULL,'JST')
```
|min_d     |max_d        |
|----------|-------------|
|2016-05-01 00:02:12|2016-07-05 15:11:40|


## TD_DATE_TRUNC
```sql
long TD_DATE_TRUNC(string unit,
                   long unix_timestamp
                   [, string default_timezone = 'UTC'])
```

```sql
'minute'
'hour'
'day'
'week'
'month'
'quarter'
'year'
```

```sql
SELECT TD_DATE_TRUNC('hour',  time, 'JST') FROM ... 
  --時間の始まり： 2018-11-23 11:00:00
SELECT TD_DATE_TRUNC('day',   time, 'JST') FROM ... 
  --日の始まり： 2018-11-23 00:00:00
SELECT TD_DATE_TRUNC('week',  time, 'JST') FROM ... 
  --週の始まり： 2018-11-19 00:00:00 （週始まりは月曜日！）
SELECT TD_DATE_TRUNC('month', time, 'JST') FROM ... 
  --月の始まり： 2018-11-01 00:00:00
SELECT TD_DATE_TRUNC('year',  time, 'JST') FROM ... 
  --年の始まり： 2018-01-01 00:00:00
```


## TD_TIME_STRING
```sql
string TD_TIME_STRING(unix_timestamp,
                      '(interval string)'
                      [, time zone])
```

```sql
SELECT 
  TD_TIME_STRING(time,'y','JST') AS time_y,
  TD_TIME_STRING(time,'M','JST') AS time_M,
  TD_TIME_STRING(time,'w','JST') AS time_w,
  TD_TIME_STRING(time,'d','JST') AS time_d,
  TD_TIME_STRING(time,'h','JST') AS time_h,
  TD_TIME_STRING(time,'m','JST') AS time_m,
  TD_TIME_STRING(time,'s','JST') AS time_s,

  TD_TIME_STRING(time,'y!','JST') AS time_y2,
  TD_TIME_STRING(time,'M!','JST') AS time_M2,
  TD_TIME_STRING(time,'w!','JST') AS time_w2,
  TD_TIME_STRING(time,'d!','JST') AS time_d2,
  TD_TIME_STRING(time,'h!','JST') AS time_h2,
  TD_TIME_STRING(time,'m!','JST') AS time_m2,
  TD_TIME_STRING(time,'s!','JST') AS time_s2
FROM ( VALUES 1576110613 ) AS t(time)
```
```sql
time_y,  2019-01-01 00:00:00+0900
time_M,  2019-12-01 00:00:00+0900
time_w,  2019-12-09 00:00:00+0900
time_d,  2019-12-12 00:00:00+0900
time_h,  2019-12-12 09:00:00+0900
time_m,  2019-12-12 09:30:00+0900
time_s,  2019-12-12 09:30:13+0900
time_y2, 2019
time_M2, 2019-12
time_w2, 2019-12-09
time_d2, 2019-12-12
time_h2, 2019-12-12 09
time_m2, 2019-12-12 09:30
time_s2, 2019-12-12 09:30:13
```

## TD_TIME_ADD
```sql
long TD_TIME_ADD(int/long/string time,
                 string duration
                 [, string default_timezone = 'UTC'])
```

```sql
 'Nw'：N週後   (e.g.  '1w',  '4w',  '48d')
'-Nw'：N週前   (e.g. '-1w', '-2w', '-48d')
 'Nd'：N日後   (e.g.  '1d',  '2d',  '30d')
'-Nd'：N日前   (e.g. '-1d', '-2d', '-30d')
 'Nh'：N時間後 (e.g.  '1h',  '2h',  '48h')
'-Nh'：N時間前 (e.g. '-1h', '-2h', '-48h')
 'Nm'：N分後   (e.g.  '1m',  '2m',  '90m')
'-Nm'：N分前   (e.g. '-1m', '-2m', '-90m')
 'Ns'：N秒後   (e.g.  '1s',  '2s',  '90s')
'-Ns'：N秒前   (e.g. '-1s', '-2s', '-90s')
'NdMhLs'：N日M時間L分後 (e.g. '1d6h30m', '-2d3h', '-1h30m')
```

```sql
SELECT
  TD_TIME_FORMAT( time, 'yyyy-MM-dd HH:mm:ss', 'JST') AS time0,
  TD_TIME_FORMAT( TD_TIME_ADD(time,  '1d','JST'), 'yyyy-MM-dd HH:mm:ss', 'JST') AS time1,  --1日後
  TD_TIME_FORMAT( TD_TIME_ADD(time, '-1d','JST'), 'yyyy-MM-dd HH:mm:ss', 'JST') AS time2,  --1日前
  TD_TIME_FORMAT( TD_TIME_ADD(time,  '1h','JST'), 'yyyy-MM-dd HH:mm:ss', 'JST') AS time3,  --1時間後
  TD_TIME_FORMAT( TD_TIME_ADD(time, '-1h','JST'), 'yyyy-MM-dd HH:mm:ss', 'JST') AS time4,  --1時間前
  TD_TIME_FORMAT( TD_TIME_ADD(time, '30m','JST'), 'yyyy-MM-dd HH:mm:ss', 'JST') AS time5, --30分後
  TD_TIME_FORMAT( TD_TIME_ADD(time,'-30m','JST'), 'yyyy-MM-dd HH:mm:ss', 'JST') AS time6, --30分前
  TD_TIME_FORMAT( TD_TIME_ADD(time, '10s','JST'), 'yyyy-MM-dd HH:mm:ss', 'JST') AS time7, --10秒後
  TD_TIME_FORMAT( TD_TIME_ADD(time,'-10s','JST'), 'yyyy-MM-dd HH:mm:ss', 'JST') AS time8, --10秒前
  TD_TIME_FORMAT( TD_TIME_ADD(time,'1d12h30m','JST'), 'yyyy-MM-dd HH:mm:ss', 'JST') AS time9 --1日12時間30分後
FROM ( VALUES 1576110613 ) AS t(time)
```
|time0     |time1        |time2              |time3              |time4              |time5              |time6              |time7              |time8              |time9              |
|----------|-------------|-------------------|-------------------|-------------------|-------------------|-------------------|-------------------|-------------------|-------------------|
|2019-12-12 09:30:13|2019-12-13 09:30:13|2019-12-11 09:30:13|2019-12-12 10:30:13|2019-12-12 08:30:13|2019-12-12 10:00:13|2019-12-12 09:00:13|2019-12-12 09:30:23|2019-12-12 09:30:03|2019-12-13 22:00:13|



## テンプレート集：「日次」「週次」「月次」（TD_TIME_RANGE編）


```sql
# 基準日 = '2016-05-22 01:00:00'
[2016-05-21 00:00:00, 2016-05-22 00:00:00）  --日次
[2016-05-09 00:00:00, 2016-05-16 00:00:00）  --週次
[2016-04-01 00:00:00, 2016-05-01 00:00:00)   --月次
```

### 日次テンプレート
```sql
--TD_SCHEDULED_TIME() = '2016-05-22 01:00 AM' の unixtime
TD_TIME_RANGE(
  time,  
  TD_TIME_ADD(TD_DATE_TRUNC('day', TD_SCHEDULED_TIME(), 'JST'),'-1d'),
  TD_DATE_TRUNC('day', TD_SCHEDULED_TIME(), 'JST')
 ) --日次 [2016-05-21 00:00:00, 2016-05-22 00:00:00）
```

取得した結果の日次の範囲が正しいかの確認クエリ
```sql
--TD_SCHEDULED_TIME() = '2016-05-22 01:00 AM' の unixtime
SELECT
  TD_TIME_FORMAT(MIN(time), 'yyyy-MM-dd HH:mm:ss', 'JST') AS min_d,
  TD_TIME_FORMAT(MAX(time), 'yyyy-MM-dd HH:mm:ss', 'JST') AS max_d
FROM sample_accesslog
WHERE TD_TIME_RANGE(
  time,  
  TD_TIME_ADD(TD_DATE_TRUNC('day', TD_SCHEDULED_TIME(), 'JST'),'-1d'),
  TD_DATE_TRUNC('day', TD_SCHEDULED_TIME(), 'JST')
 )  --日次 [2016-05-21 00:00:00, 2016-05-22 00:00:00）
```
|min_d     |max_d        |
|----------|-------------|
|2016-05-21 00:00:26|2016-05-21 23:43:49|


### 週次テンプレート
```sql
--TD_SCHEDULED_TIME() = '2016-05-22 01:00 AM' の unixtime
TD_TIME_RANGE(
  time,  
  TD_TIME_ADD(TD_DATE_TRUNC('week', TD_SCHEDULED_TIME(), 'JST'),'-1w'),
  TD_DATE_TRUNC('week', TD_SCHEDULED_TIME(), 'JST')
 ) --週次 [2016-05-09 00:00:00, 2016-05-16 00:00:00）
```

取得した結果の週次の範囲が正しいかの確認クエリ
```sql
--TD_SCHEDULED_TIME() = '2016-05-22 01:00 AM' の unixtime
SELECT
  TD_TIME_FORMAT(MIN(time), 'yyyy-MM-dd HH:mm:ss', 'JST') AS min_d,
  TD_TIME_FORMAT(MAX(time), 'yyyy-MM-dd HH:mm:ss', 'JST') AS max_d
FROM sample_accesslog
WHERE TD_TIME_RANGE(
  time,  
  TD_TIME_ADD(TD_DATE_TRUNC('week', TD_SCHEDULED_TIME(), 'JST'),'-1w'),
  TD_DATE_TRUNC('week', TD_SCHEDULED_TIME(), 'JST')
 ) --週次 [2016-05-09 00:00:00, 2016-05-16 00:00:00）
```
|min_d     |max_d        |
|----------|-------------|
|2016-05-09 00:04:50|2016-05-15 23:51:36|


### 月次テンプレート
```sql
--TD_SCHEDULED_TIME() = '2016-05-22 01:00 AM' の unixtime
TD_TIME_RANGE(
  time,
  TD_DATE_TRUNC(
    'month', TD_DATE_TRUNC('month', TD_SCHEDULED_TIME(),'JST')-1, 'JST'
  ),                                                
  TD_DATE_TRUNC('month', TD_SCHEDULED_TIME(), 'JST')
)  --月次 [2016-04-01 00:00:00, 2016-05-01 00:00:00)
```

取得した結果の月次の範囲が正しいかの確認クエリ
```sql
--TD_SCHEDULED_TIME() = '2016-05-22 01:00 AM' の unixtime
SELECT
  TD_TIME_FORMAT(MIN(time), 'yyyy-MM-dd HH:mm:ss', 'JST') AS min_d,
  TD_TIME_FORMAT(MAX(time), 'yyyy-MM-dd HH:mm:ss', 'JST') AS max_d
FROM sample_accesslog
WHERE TD_TIME_RANGE(
  time,
  TD_DATE_TRUNC(
    'month', TD_DATE_TRUNC('month', TD_SCHEDULED_TIME(),'JST')-1, 'JST'
  ),                                                
  TD_DATE_TRUNC('month', TD_SCHEDULED_TIME(), 'JST')
)  --月次 [2016-04-01 00:00:00, 2016-05-01 00:00:00)
```
|min_d     |max_d        |
|----------|-------------|
|2016-05-01 00:02:12|2016-05-31 23:58:55|


## Prestoの日付関数で同様のクエリを再現する

```sql
--TD_SCHEDULED_TIME() = '2016-05-22 01:00 AM' の unixtime
WHERE 
    date_add('day', -1, date_trunc('day', from_unixtime(TD_SCHEDULED_TIME(),'Asia/Tokyo')))
 <= from_unixtime(time,'Asia/Tokyo')
AND from_unixtime(time,'Asia/Tokyo') 
 <  date_trunc('day', from_unixtime(TD_SCHEDULED_TIME(),'Asia/Tokyo')) 
  --日次 [2016-05-21 00:00:00, 2016-05-21 00:00:00）

WHERE 
    date_add('week', -1, date_trunc('week', from_unixtime(TD_SCHEDULED_TIME(),'Asia/Tokyo')))
 <= from_unixtime(time,'Asia/Tokyo')
AND from_unixtime(time,'Asia/Tokyo')
 <  date_trunc('week', from_unixtime(TD_SCHEDULED_TIME(),'Asia/Tokyo')) 
  --週次 [2016-05-09 00:00:00, 2016-05-15 00:00:00）

WHERE
    date_add('month', -1, date_trunc('month', from_unixtime(TD_SCHEDULED_TIME(),'Asia/Tokyo')))
 <= from_unixtime(time,'Asia/Tokyo')
AND from_unixtime(time,'Asia/Tokyo')
 <  date_trunc('month', from_unixtime(TD_SCHEDULED_TIME(),'Asia/Tokyo')) 
  --月次 [2016-04-01 00:00:00, 2016-05-01 00:00:00)
```

## TD_INTERVAL

TD_INTERVALは近年彗星のごとく登場した大変便利な関数です。それまではTD_TIME_RANGEとTD_DATE_TRUNCを駆使して行っていた過去の月次処理が，この関数のみでできるようになったのです。
```sql
boolean TD_INTERVAL(int/long time,
                    string interval_string,
                    [, string default_timezone = 'UTC'])
```


```sql
--TD_SCHEDULED_TIME() = '2016-05-22 01:00 AM' の unixtime
-- ！SELECT 節かコメントに TD_SCHEDULED_TIME() を入れることを忘れない！
TD_INTERVAL(time,  '1d', 'JST') 
  --今日 [2016-05-22 00:00:00, 2016-05-23 00:00:00)
TD_INTERVAL(time, '-1d', 'JST') 
  --昨日 [2016-05-21 00:00:00, 2016-05-22 00:00:00)
TD_INTERVAL(time, '-7d', 'JST') 
  --今週 [2016-05-16 00:00:00, 2016-05-23 00:00:00)
TD_INTERVAL(time,  '1w', 'JST') 
  --今週 [2016-05-16 00:00:00, 2016-05-23 00:00:00)
TD_INTERVAL(time, '-1w', 'JST') 
  --前週 [2016-05-09 00:00:00, 2016-05-16 00:00:00)
TD_INTERVAL(time,  '1M', 'JST') 
  --今月 [2016-05-01 00:00:00, 2016-06-01 00:00:00)
TD_INTERVAL(time, '-1M', 'JST') 
  --前月 [2016-04-01 00:00:00, 2016-05-01 00:00:00)
TD_INTERVAL(time, '-2M', 'JST')
  --前月+前々月 [2016-04-01 00:00:00, 2016-06-01 00:00:00)
```

### 今日（TRUNCした日から+1d）
```sql
--TD_SCHEDULED_TIME() = '2016-05-22 01:00 AM' の unixtime
SELECT
  TD_TIME_FORMAT(MIN(time), 'yyyy-MM-dd HH:mm:ss', 'JST') AS min_d,
  TD_TIME_FORMAT(MAX(time), 'yyyy-MM-dd HH:mm:ss', 'JST') AS max_d
FROM sample_accesslog
WHERE
  TD_INTERVAL(time,  '1d', 'JST') 
  --今日 [2016-05-22 00:00:00, 2016-05-23 00:00:00)
```
|min_d     |max_d        |
|----------|-------------|
|2016-05-22 00:02:34|2016-05-22 23:59:55|


### 昨日（TRUNCした日から-1d）
```sql
--TD_SCHEDULED_TIME() = '2016-05-22 01:00 AM' の unixtime
SELECT
  TD_TIME_FORMAT(MIN(time), 'yyyy-MM-dd HH:mm:ss', 'JST') AS min_d,
  TD_TIME_FORMAT(MAX(time), 'yyyy-MM-dd HH:mm:ss', 'JST') AS max_d
FROM sample_accesslog
WHERE
  TD_INTERVAL(time, '-1d', 'JST') 
  --昨日 [2016-05-21 00:00:00, 2016-05-22 00:00:00)
```
|min_d     |max_d        |
|----------|-------------|
|2016-05-21 00:00:26|2016-05-21 23:43:49|


### 今週（TRUNCした週から+1w）
```sql
--TD_SCHEDULED_TIME() = '2016-05-22 01:00 AM' の unixtime
SELECT
  TD_TIME_FORMAT(MIN(time), 'yyyy-MM-dd HH:mm:ss', 'JST') AS min_d,
  TD_TIME_FORMAT(MAX(time), 'yyyy-MM-dd HH:mm:ss', 'JST') AS max_d
FROM sample_accesslog
WHERE
  TD_INTERVAL(time,  '1w', 'JST') 
  --今週 [2016-05-16 00:00:00, 2016-05-23 00:00:00)
```
|min_d     |max_d        |
|----------|-------------|
|2016-05-16 00:04:53|2016-05-22 23:59:55|


### 先週（TRUNCした週から-1w）
```sql
--TD_SCHEDULED_TIME() = '2016-05-22 01:00 AM' の unixtime
SELECT
  TD_TIME_FORMAT(MIN(time), 'yyyy-MM-dd HH:mm:ss', 'JST') AS min_d,
  TD_TIME_FORMAT(MAX(time), 'yyyy-MM-dd HH:mm:ss', 'JST') AS max_d
FROM sample_accesslog
WHERE
  TD_INTERVAL(time, '-1w', 'JST') 
  --前週 [2016-05-09 00:00:00, 2016-05-16 00:00:00)
```
|min_d     |max_d        |
|----------|-------------|
|2016-05-09 00:04:50|2016-05-15 23:51:36|


### 今月（TRUNCした月から+1M）
```sql
--TD_SCHEDULED_TIME() = '2016-05-22 01:00 AM' の unixtime
SELECT
  TD_TIME_FORMAT(MIN(time), 'yyyy-MM-dd HH:mm:ss', 'JST') AS min_d,
  TD_TIME_FORMAT(MAX(time), 'yyyy-MM-dd HH:mm:ss', 'JST') AS max_d
FROM sample_accesslog
WHERE
  TD_INTERVAL(time,  '1M', 'JST') 
  --今月 [2016-05-01 00:00:00, 2016-06-01 00:00:00)
```
|min_d     |max_d        |
|----------|-------------|
|2016-05-01 00:02:12|2016-05-31 23:58:55|


### 前月（TRUNCした月から-1M）（データが2016-04-23までであることに注意）
```sql
--TD_SCHEDULED_TIME() = '2016-05-22 01:00 AM' の unixtime
SELECT
  TD_TIME_FORMAT(MIN(time), 'yyyy-MM-dd HH:mm:ss', 'JST') AS min_d,
  TD_TIME_FORMAT(MAX(time), 'yyyy-MM-dd HH:mm:ss', 'JST') AS max_d
FROM sample_accesslog
WHERE
  TD_INTERVAL(time, '-1M', 'JST') 
  --前月 [2016-04-01 00:00:00, 2016-05-01 00:00:00)
```
|min_d     |max_d        |
|----------|-------------|
|2016-04-23 01:20:50|2016-04-30 23:35:14|


### 前月+前々月（TRUNCした月から-2M）（2016-07-22の日付に変更していることに注意）
```sql
--TD_SCHEDULED_TIME() = '2016-07-22 01:00 AM' の unixtime
SELECT
  TD_TIME_FORMAT(MIN(time), 'yyyy-MM-dd HH:mm:ss', 'JST') AS min_d,
  TD_TIME_FORMAT(MAX(time), 'yyyy-MM-dd HH:mm:ss', 'JST') AS max_d
FROM sample_accesslog
WHERE
  TD_INTERVAL(time, '-2M', 'JST')
  --前月+前々月 [2016-05-01 00:00:00, 2016-07-01 00:00:00)
```
|min_d     |max_d        |
|----------|-------------|
|2016-05-01 00:02:12|2016-06-30 23:57:07|


```sql
--TD_SCHEDULED_TIME() = '2016-05-22 01:00 AM' の unixtime
--！!SELECT 節かコメントに TD_SCHEDULED_TIME() を入れることを忘れない！
TD_INTERVAL(time,  '-1d/-1d', 'JST') 
  --TRUNC後1日前から-1日間 [2016-05-20 00:00:00, 2016-05-21 00:00:00)
TD_INTERVAL(time,  '-7d/-2d', 'JST') 
  --TRUNC後2日前から-7日間 [2016-05-13 00:00:00, 2016-05-20 00:00:00)
TD_INTERVAL(time,  '-7d/-2d', 'JST') 
  --TRUNC後7日前から-7日間 [2016-05-08 00:00:00, 2016-05-15 00:00:00)
TD_INTERVAL(time, '-1w/-1w', 'JST')  
  --TRUNC後1週間前から-1週間 [2016-05-02 00:00:00, 2016-05-09 00:00:00)
TD_INTERVAL(time,  '-1M/-1M', 'JST') 
  --TRUNC後1ヶ月前から-1ヶ月間 [2016-03-01 00:00:00, 2016-04-01 00:00:00)
TD_INTERVAL(time, '-2M/-1M', 'JST')  
  --TRUNC後1ヶ月前から-2ヶ月間 [2016-02-01 00:00:00, 2016-04-01 00:00:00)
```

### 'd'でTRUNC後1日前から-1日間
```sql
--TD_SCHEDULED_TIME() = '2016-05-22 01:00 AM' の unixtime
SELECT
  TD_TIME_FORMAT(MIN(time), 'yyyy-MM-dd HH:mm:ss', 'JST') AS min_d,
  TD_TIME_FORMAT(MAX(time), 'yyyy-MM-dd HH:mm:ss', 'JST') AS max_d
FROM sample_accesslog
WHERE
  TD_INTERVAL(time,  '-1d/-1d', 'JST') 
  --TRUNC後1日前から-1日間 [2016-05-20 00:00:00, 2016-05-21 00:00:00)
```
|min_d     |max_d        |
|----------|-------------|
|2016-05-20 00:14:44|2016-05-20 23:57:11|


### 'd'でTRUNC後2日前から-7日間
```sql
--TD_SCHEDULED_TIME() = '2016-05-22 01:00 AM' の unixtime
SELECT
  TD_TIME_FORMAT(MIN(time), 'yyyy-MM-dd HH:mm:ss', 'JST') AS min_d,
  TD_TIME_FORMAT(MAX(time), 'yyyy-MM-dd HH:mm:ss', 'JST') AS max_d
FROM sample_accesslog
WHERE
  TD_INTERVAL(time,  '-7d/-2d', 'JST') 
  --TRUNC後2日前から-7日間 [2016-05-13 00:00:00, 2016-05-20 00:00:00)
```
|min_d     |max_d        |
|----------|-------------|
|2016-05-13 00:04:52|2016-05-19 23:42:47|


### 'd'でTRUNC後7日前から-7日間
```sql
--TD_SCHEDULED_TIME() = '2016-05-22 01:00 AM' の unixtime
SELECT
  TD_TIME_FORMAT(MIN(time), 'yyyy-MM-dd HH:mm:ss', 'JST') AS min_d,
  TD_TIME_FORMAT(MAX(time), 'yyyy-MM-dd HH:mm:ss', 'JST') AS max_d
FROM sample_accesslog
WHERE
  TD_INTERVAL(time,  '-7d/-7d', 'JST') 
  --TRUNC後2日前から-7日間 [2016-05-08 00:00:00, 2016-05-15 00:00:00)
```
|min_d     |max_d        |
|----------|-------------|
|2016-05-08 00:03:33|2016-05-14 23:54:38|


### 'w'でTRUNC後1週間前から-1週間
```sql
--TD_SCHEDULED_TIME() = '2016-05-22 01:00 AM' の unixtime
SELECT
  TD_TIME_FORMAT(MIN(time), 'yyyy-MM-dd HH:mm:ss', 'JST') AS min_d,
  TD_TIME_FORMAT(MAX(time), 'yyyy-MM-dd HH:mm:ss', 'JST') AS max_d
FROM sample_accesslog
WHERE
  TD_INTERVAL(time, '-1w/-1w', 'JST')  
  --TRUNC後1週間前から-1週間 [2016-05-02 00:00:00, 2016-05-09 00:00:00)
```
|min_d     |max_d        |
|----------|-------------|
|2016-05-02 00:04:04|2016-05-08 23:40:06|


### 'M'でTRUNC後1ヶ月前から-1ヶ月間（2016-07-22の日付に変更していることに注意）
```sql
--TD_SCHEDULED_TIME() = '2016-07-22 01:00 AM' の unixtime
SELECT
  TD_TIME_FORMAT(MIN(time), 'yyyy-MM-dd HH:mm:ss', 'JST') AS min_d,
  TD_TIME_FORMAT(MAX(time), 'yyyy-MM-dd HH:mm:ss', 'JST') AS max_d
FROM sample_accesslog
WHERE
  TD_INTERVAL(time,  '-1M/-1M', 'JST') 
  --TRUNC後1ヶ月前から-1ヶ月間 [2016-05-01 00:00:00, 2016-06-01 00:00:00)
```
|min_d     |max_d        |
|----------|-------------|
|2016-05-01 00:02:12|2016-05-31 23:58:55|


### 'M'でTRUNC後1ヶ月前から-2ヶ月間（2016-07-22の日付に変更していることに注意，データが2016-04-23までであることに注意）
```sql
--TD_SCHEDULED_TIME() = '2016-07-22 01:00 AM' の unixtime
SELECT
  TD_TIME_FORMAT(MIN(time), 'yyyy-MM-dd HH:mm:ss', 'JST') AS min_d,
  TD_TIME_FORMAT(MAX(time), 'yyyy-MM-dd HH:mm:ss', 'JST') AS max_d
FROM sample_accesslog
WHERE
  TD_INTERVAL(time, '-2M/-1M', 'JST')  
  --TRUNC後1ヶ月前から-2ヶ月間 [2016-04-01 00:00:00, 2016-06-01 00:00:00)
```
|min_d     |max_d        |
|----------|-------------|
|2016-04-23 01:20:50|2016-05-31 23:58:55|


### テンプレート集：「日次」「週次」「月次」（TD_INTERVAL編）


```sql
# 基準日 = '2018-11-23 11:11:00'
[2018-11-22 00:00:00, 2018-11-23 00:00:00) --日次
[2018-11-12 00:00:00, 2018-11-19 00:00:00) --週次
[2018-10-01 00:00:00, 2018-11-01 00:00:00) --月次
```

```sql
--TD_SCHEDULED_TIME() = '2018-11-23 11:11:00'
--！SELECT 句に TD_SCHEDULED_TIME() を入れることを忘れない！
TD_INTERVAL(time, '-1d', 'JST')  
  --日次 [2018-11-22 00:00:00, 2018-11-23 00:00:00)
TD_INTERVAL(time, '-1w', 'JST')  
  --週次 [2018-11-12 00:00:00, 2018-11-19 00:00:00)
TD_INTERVAL(time, '-1M', 'JST')  
  --月次 [2018-10-01 00:00:00, 2018-11-01 00:00:00)
```
