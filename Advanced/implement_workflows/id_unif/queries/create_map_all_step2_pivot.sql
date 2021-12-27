select
    t1_id_type
    , t1_id as ${td.each.t1_id_type}
    , ${td.each.pivot_line}
  from (
    select
      t1_id_type
      , t1_id
      , map_agg(t2_id_type, t2_id) as kv
    from
      tmp_map_all_step1
    where t1_id_type = '${td.each.t1_id_type}'
    group by
      t1_id_type
      , t1_id
    )