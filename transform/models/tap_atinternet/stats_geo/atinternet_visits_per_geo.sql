select
    src_website,
    month,
    month_str,
    geo_region_iso,
    geo_region_name,
    geo_country,
    geo_city,
    sum(m_visits) as visit_count
from {{ ref('atinternet_geo_visits_clean') }}
where src_website = 'gn'
group by
    src_website,
    month,
    month_str,
    geo_region_iso,
    geo_region_name,
    geo_country,
    geo_city
order by month desc
