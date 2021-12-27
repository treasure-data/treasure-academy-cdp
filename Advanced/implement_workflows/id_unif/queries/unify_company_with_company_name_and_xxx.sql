select ${td.each.table_name1}_id
     , ${td.each.table_name2}_id
     , ${td.each.map_type} as map_type
from
( 
  select ${td.each.table_name1}_id
       , company_name
       , ${td.each.col_name1}
    from tmp_company_${td.each.table_name1}
) as t1
inner join 
(
  select ${td.each.table_name2}_id
       , company_name
       , ${td.each.col_name2}
    from tmp_company_${td.each.table_name2}
) as t2
on t1.company_name = t2.company_name
and t1.${td.each.col_name1} = t2.${td.each.col_name2}
