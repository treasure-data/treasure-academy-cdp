with prep as (
select t1_id_type
from tmp_map_all_step1
group by 1
)

select array_join(array_sort(array_agg(t1_id_type)), ', ') as select_groupby_line
from prep