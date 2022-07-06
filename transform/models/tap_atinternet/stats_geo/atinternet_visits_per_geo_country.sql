select
    src_website,
    month,
    month_str,
    geo_country,
    sum(visit_count) as visit_count
from {{ ref('atinternet_visits_per_geo') }}
group by
    src_website,
    month,
    month_str,
    geo_country
order by month desc
