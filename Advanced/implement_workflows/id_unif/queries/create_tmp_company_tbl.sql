-- カラム名の変更
SELECT
  id AS ${target}_id
, corp_name AS company_name
, address_all
, zip_code
, tel
, web_domain
, mail_domain
, ceo
, time
FROM
	${target}
