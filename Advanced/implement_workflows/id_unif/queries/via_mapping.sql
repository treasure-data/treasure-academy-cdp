  select
    step0.t1_id_type
    , step0.t1_id
    , step${i}.t2_id_type
    , step${i}.t2_id
  from
    map_union_all as step0
    ${td.last_results.inner_join_line}