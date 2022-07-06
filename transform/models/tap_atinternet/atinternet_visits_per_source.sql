select
    src_website,
    month,
    month_str,
    src,
    src_detail,
    sum(m_visits) as visit_count
from {{ ref('atinternet_sources_visits_clean') }}
where src_website = 'gn'
group by
    src_website,
    month,
    month_str,
    src,
    src_detail
order by month desc
