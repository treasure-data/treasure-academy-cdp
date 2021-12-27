with union_count as (
  select
    t1_id_type
    , t1_id
    , t2_id_type
    , t2_id
    , count(1) over (partition by t2_id_type, t1_id_type, t1_id) as have_t2_id
    , count(1) over (partition by t1_id_type, t2_id_type, t2_id) as have_t1_id
  from tmp_map_via_all
  group by
    t1_id_type, t1_id, t2_id_type, t2_id
)
select 
    t1_id_type
    , t1_id
    , t2_id_type
    , t2_id
  from union_count
  where have_t2_id = 1 and have_t1_id = 1