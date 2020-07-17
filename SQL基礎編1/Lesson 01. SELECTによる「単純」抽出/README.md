# Lesson 01. SELECTによる「単純」抽出

## 全行，全カラムの抽出 [ SELECT * ]

```sql
SELECT * 
FROM sample_accesslog
```

|td_client_id|td_global_id             |td_title        |td_browser|td_host|td_path            |td_url    |td_referrer|td_ip|td_os     |td_language|time      |
|------------|-------------------------|----------------|----------|-------|-------------------|----------|-----------|-----|----------|-----------|----------|
|59523c90-2724-4d52-9157-1b93cd89f2a2|                         |リソース - Treasure Data|Chrome    |www.treasuredata.com|/jp/resources      |https://www.treasuredata.com/jp/resources|https://www.treasuredata.com/jp/|133.250.236.113|Windows 7 |ja         |1465977533|
|37c30508-18fa-422b-cdca-48ef68cbd29d|                         |Treasure Data - データ分析をクラウドで、シンプルに。 - Treasure Data|Mobile Safari|www.treasuredata.com|/jp/               |https://www.treasuredata.com/jp/|https://www.google.co.jp/|103.5.140.189|iOS       |ja-jp      |1465977276|
|e6d199fe-3367-4fb7-ab41-5422e30ca5c9|                         |Treasure Data - データ分析をクラウドで、シンプルに。 - Treasure Data|Mobile Safari|www.treasuredata.com|/jp/               |https://www.treasuredata.com/jp/?gclid=CMX_uou8qc0CFdgmvQodBrMD5w|           |106.133.82.194|iOS       |ja-jp      |1465974373|

## 全行，全カラムの抽出 [ SELECT col ]

```sql
SELECT time, td_client_id, td_title
FROM sample_accesslog
```
|time   |td_client_id             |td_title        |
|-------|-------------------------|----------------|
|1466410889|2705c701-3b7c-4ef3-d88d-50529a3d1060|Treasure Data - データ分析をクラウドで、シンプルに。 - Treasure Data|
|1466411086|a1265a65-70a0-4ee2-98fe-6671146666ee|Treasure Data - データ分析をクラウドで、シンプルに。 - Treasure Data|
|1466412618|83b53ce3-7c66-46aa-8c4d-cbec9e52bb86|Treasure Data - データ分析をクラウドで、シンプルに。 - Treasure Data|


```sql
SELECT time, td_client_id td_title --カンマが抜けてる！
FROM sample_accesslog
```

|time   |td_title                 |
|-------|-------------------------|
|1465892286|daa933f7-6c39-4ce5-b610-d2368950c176|
|1465892317|7f47d05f-bd12-4553-e69c-763064738631|
|1465892324|93b18d92-095e-46f3-ece9-a00369945e97|


## カラムに別名を付ける [ SELECT col AS name ]


```sql
SELECT td_client_id AS uid1, td_client_id AS uid2, td_title AS title
FROM sample_accesslog
```
|uid1   |uid2                     |title                     |
|-------|-------------------------|--------------------------|
|6dc74bd9-313d-42be-c4ba-9072f4c15312|6dc74bd9-313d-42be-c4ba-9072f4c15312|サービス概要 - Treasure Data    |
|e3dc64f2-93a8-4c0f-c9b3-2a8170065578|e3dc64f2-93a8-4c0f-c9b3-2a8170065578|サービス概要 - Treasure Data    |
|7f47d05f-bd12-4553-e69c-763064738631|7f47d05f-bd12-4553-e69c-763064738631|連携するシステム一覧 - Treasure Data|


## 抽出件数を絞る [ LIMIT n ]

```sql
SELECT time, td_client_id, td_title
FROM sample_accesslog
LIMIT 5 --結果を5件のみ取得
```

|time   |td_client_id             |td_title                  |
|-------|-------------------------|--------------------------|
|1467099783|33c61ec6-aa33-40bb-8f7d-326a2cba9ed7|Treasure Data - データ分析をクラウドで、シンプルに。 - Treasure Data|
|1467100686|b40f644b-f816-4dc6-9131-aa7f0e2044d1|Treasure Data - データ分析をクラウドで、シンプルに。 - Treasure Data|
|1467100698|b40f644b-f816-4dc6-9131-aa7f0e2044d1|お客様事例一覧 - Treasure Data   |
|1467097949|7d34de55-b53d-472f-d8a7-8eaaa43d5c03|トレジャーデータサービスが、 株式会社MonotaRO（モノタロウ）のデータ分析基盤として導入 - プレスリリース - Treasure Data|
|1467097832|3513d40c-97c3-49cb-b087-f90cb80a4c26|企業情報 - Treasure Data      |


## 抽出結果を並び替える [ ORDER BY col ]

```sql
SELECT time, td_client_id, td_title
FROM sample_accesslog
ORDER BY td_client_id ASC --ASCは昇順（小さい順）
LIMIT 10                  --LIMIT節は ORDER BY節より後

```
|time      |td_client_id|td_title                                          |
|----------|------------|--------------------------------------------------|
|1461454166|000077fb-2c93-4cd7-d9d0-293866aaec31|Treasure Data - データ分析をクラウドで、シンプルに。 - Treasure Data|
|1461454040|000077fb-2c93-4cd7-d9d0-293866aaec31|Treasure Data - データ分析をクラウドで、シンプルに。 - Treasure Data|
|1461454057|000077fb-2c93-4cd7-d9d0-293866aaec31|企業情報 - Treasure Data                              |

```sql
SELECT time, td_client_id, td_title
FROM sample_accesslog
ORDER BY td_client_id DESC --DESCは降順（大きい順）
LIMIT 10                   --ORDER BY節との併用では負荷削減効果は薄い
```

|time      |td_client_id                        |td_title                                          |
|----------|------------------------------------|--------------------------------------------------|
|1466494001|fffe877a-759d-4f67-a5c4-ac5ea1ee78b5|Treasure Data - データ分析をクラウドで、シンプルに。 - Treasure Data|
|1466494000|fffe877a-759d-4f67-a5c4-ac5ea1ee78b5|Treasure Data - データ分析をクラウドで、シンプルに。 - Treasure Data|
|1463156253|fffe6e62-edf6-45d8-b052-c119c3752c8f|Treasure Data - データ分析をクラウドで、シンプルに。 - Treasure Data|

```sql
SELECT time, td_client_id, td_title
FROM sample_accesslog
ORDER BY td_client_id ASC, time DESC
LIMIT 10
```

|time      |td_client_id                        |td_title                                          |
|----------|------------------------------------|--------------------------------------------------|
|1461454166|000077fb-2c93-4cd7-d9d0-293866aaec31|Treasure Data - データ分析をクラウドで、シンプルに。 - Treasure Data|
|1461454142|000077fb-2c93-4cd7-d9d0-293866aaec31|採用情報 - Treasure Data                              |
|1461454057|000077fb-2c93-4cd7-d9d0-293866aaec31|企業情報 - Treasure Data                              |

## 特定のカラムのユニークな値/組合せのみ抽出 [ SELECT DISTINCT col ]

```sql
SELECT DISTINCT td_title
FROM sample_accesslog
ORDER BY td_title
LIMIT 10
```

|td_title  |
|----------|
|企業情報 - Treasure Data|
|2014年の事業戦略を発表 - プレスリリース - Treasure Data|
|2015年事業戦略発表 デジタルおよびIoT事業を中心としたグローバル市場拡大を強化 - プレスリリース - Treasure Data|

```sql
SELECT DISTINCT td_title, td_os, td_browser
FROM sample_accesslog
ORDER BY td_title, td_os, td_browser
LIMIT 10
```

|td_title  |td_os      |td_browser|
|----------|-----------|----------|
|企業情報 - Treasure Data|Windows 8.1|Firefox   |
|2014年の事業戦略を発表 - プレスリリース - Treasure Data|Other      |Googlebot |
|2014年の事業戦略を発表 - プレスリリース - Treasure Data|Windows 7  |Chrome    |

## 抽出した結果を続けて参照する [ SELECT FROM (SELECT) ]

```sql
SELECT time, td_client_id
FROM
(
  SELECT time, td_client_id, td_title
  FROM sample_accesslog
)
ORDER BY td_client_id ASC
LIMIT 10
```
|time      |td_client_id|
|----------|------------|
|1461454166|000077fb-2c93-4cd7-d9d0-293866aaec31|
|1461454040|000077fb-2c93-4cd7-d9d0-293866aaec31|
|1461454057|000077fb-2c93-4cd7-d9d0-293866aaec31|

