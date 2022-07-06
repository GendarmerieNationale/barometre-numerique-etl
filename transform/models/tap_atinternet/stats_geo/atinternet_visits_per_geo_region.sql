select
    src_website,
    month,
    month_str,
    geo_region_iso,
    geo_region_name,
    sum(visit_count) as visit_count
from {{ ref('atinternet_visits_per_geo') }}
group by
    src_website,
    month,
    month_str,
    geo_region_iso,
    geo_region_name
order by month desc
