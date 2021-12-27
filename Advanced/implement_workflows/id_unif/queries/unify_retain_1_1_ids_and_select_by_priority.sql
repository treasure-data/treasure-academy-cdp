with prep as (
select map_type
    , ${td.each.table_name1}_id
    , count(1)over(partition by map_type, ${td.each.table_name1}_id) as ${td.each.table_name2}_id_cnt
    , ${td.each.table_name2}_id
    , count(1)over(partition by map_type, ${td.each.table_name2}_id) as ${td.each.table_name1}_id_cnt
from tmp_map_${td.each.table_name1}_${td.each.table_name2}
group by map_type, ${td.each.table_name1}_id, ${td.each.table_name2}_id
)
, prep2 as(
select *
from prep
where (${td.each.table_name2}_id_cnt = 1 and ${td.each.table_name1}_id_cnt = 1)
)
, prep3 as(
select ${td.each.table_name1}_id
      , min_by(${td.each.table_name2}_id, map_type) as ${td.each.table_name2}_id
      , min(map_type) as map_type
from prep2
group by 1
)
select min_by(${td.each.table_name1}_id, map_type) as ${td.each.table_name1}_id
      , ${td.each.table_name2}_id
from prep3
group by 2