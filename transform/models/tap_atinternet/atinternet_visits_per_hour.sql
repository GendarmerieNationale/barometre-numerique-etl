select
    src_website,
    datetime,
    date,
    visit_hour,
    month,
    month_str,
    subsite,
    sum(m_visits) as visit_count
from {{ ref('atinternet_hourly_visits_clean') }}
where src_website = 'gn'
group by
    src_website,
    datetime,
    visit_hour,
    date,
    month,
    month_str,
    subsite
order by subsite asc, datetime desc
