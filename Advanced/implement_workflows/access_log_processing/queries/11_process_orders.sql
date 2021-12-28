SELECT
 *
 ,NORMALIZE(LOWER(email), NFKD) AS email_modified -- メールアドレスをノーマライズ、小文字にする
 ,SPLIT_PART(COALESCE(name, 'UNKNOWN UNKNOWN'), ' ', 1) AS fname -- name列を分割して名前を取り出す。NULLの場合はダミー文字列を埋める
 ,SPLIT_PART(COALESCE(name, 'UNKNOWN UNKNOWN'), ' ', 2) AS lname   -- name列を分割して名字を取り出す。NULLの場合はダミー文字列を埋める 
FROM l0_access_log.orders
