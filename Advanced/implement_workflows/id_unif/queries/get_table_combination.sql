with prep as (
  select
    table_name
  from
    unnest(split('${company_table_list.join(",")}', ',')) as t(table_name)
)
select
  t1.table_name as table_name1
  , t2.table_name as table_name2
from
  prep as t1
  inner join prep as t2 on t1.table_name < t2.table_name
order by
  t1.table_name
  , t2.table_name