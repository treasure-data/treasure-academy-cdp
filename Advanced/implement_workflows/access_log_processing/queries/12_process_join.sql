SELECT
  o.td_client_id
  , o.email
  , o.fname
  , o.lname
  , COUNT(1) AS access_cnt
FROM
  l1_access_log.pageviews p
LEFT OUTER JOIN l1_access_log.orders o
ON o.td_client_id = p.td_client_id
WHERE o.td_client_id IS NOT NULL
GROUP BY o.td_client_id, o.email, o.fname, o.lname
ORDER BY access_cnt DESC
