select
    src_website,
    month,
    month_str,
    device_type,
    os_group,
    browser_group,
    sum(m_visits) as visit_count
from {{ ref('atinternet_devices_visits_clean') }}
where src_website = 'gn'
group by
    src_website,
    month,
    month_str,
    device_type,
    os_group,
    browser_group
order by month desc
