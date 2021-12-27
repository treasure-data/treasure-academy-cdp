with ${td.each.table_name1} as (
select column_name, ordinal_position
from information_schema.columns
where table_schema = '${td.database}' 
  and table_name = 'tmp_company_${td.each.table_name1}'
  and column_name in ('representative', 'address_all', 'zip_code', 'tel', 'web_domain', 'mail_domain', 'ceo')
)
,  ${td.each.table_name2} as (
select column_name
from information_schema.columns
where table_schema = '${td.database}' 
  and table_name = 'tmp_company_${td.each.table_name2}'
  and column_name in ('representative', 'address_all', 'zip_code', 'tel', 'web_domain', 'mail_domain', 'ceo')
)

select t1.column_name as col_name1
     , t2.column_name as col_name2
     , ordinal_position as map_type
from ${td.each.table_name1}  as t1
inner join ${td.each.table_name2}  as t2
on t1.column_name = t2.column_name
order by ordinal_position
