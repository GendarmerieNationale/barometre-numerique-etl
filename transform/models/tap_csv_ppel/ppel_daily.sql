select
    date,
    month,
    month_str,
    count(stats_id) as n_preplaintes,
    avg(duree) as duree_moy,
    percentile_disc(0.5) within group ( order by duree ) as duree_med
from {{ ref('ppel_clean_logs') }}
group by date, month, month_str
