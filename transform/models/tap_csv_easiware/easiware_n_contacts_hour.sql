select
    hour,
    count(reference) as n_contact
from {{ ref ('easiware_requests_clean') }}
group by hour
