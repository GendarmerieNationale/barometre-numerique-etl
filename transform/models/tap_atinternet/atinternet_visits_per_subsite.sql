select
    src_website,
    month,
    month_str,
    subsite,
    sum(m_visits) as visit_count
from {{ ref('atinternet_pages_visits_clean') }}
where src_website = 'gn'
group by
    src_website,
    month,
    month_str,
    subsite
order by month desc
