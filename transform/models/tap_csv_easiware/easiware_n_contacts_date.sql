select
    date,
    month,
    month_str,
    count(reference) as n_contact
from {{ ref ('easiware_requests_clean') }}
group by date, month, month_str
