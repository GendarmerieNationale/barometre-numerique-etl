select
    count,
    age_cat,
    month as month_str,
    to_date(month, 'YYYY-MM-DD') as month
from {{ source('tap_perceval', 'age_categories_month') }}
