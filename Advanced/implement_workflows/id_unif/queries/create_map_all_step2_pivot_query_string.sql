with prep as (
select t1_id_type
     , t2_id_type 
from tmp_map_all_step1
group by 1, 2
)
, prep2 as(
select t1_id_type
     , 'if(element_at(kv,''' as str1
     , t2_id_type as t2_id_type_1
     , ''') is not null, kv[''' as str2
     , t2_id_type as t2_id_type_2
     ,'''], null) as '  as str3
     , t2_id_type as t2_id_type_3
from prep
)

select t1_id_type
     , array_join(array_sort(array_agg(str1||t2_id_type_1||str2||t2_id_type_2||str3||t2_id_type_3)), ', ') as pivot_line
from prep2
group by 1
