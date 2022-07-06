select
    src_website,
    month,
    month_str,
    geo_city,
    sum(visit_count) as visit_count
from {{ ref('atinternet_visits_per_geo') }}
group by
    src_website,
    month,
    month_str,
    geo_city
order by month desc
