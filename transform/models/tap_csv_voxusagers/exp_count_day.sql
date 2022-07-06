with tmp as (
    select
        --        Cast date_publi to timestamp before date_trunc (instead of the default timestamp with timezone)
        date_publi as date,
        date_trunc('month', date_publi::timestamp)::date as month,
        count(*) as exp_count
    from {{ ref('voxusagers_clean') }}
    group by month, date
)

select
    *,
    to_char(month, 'YYYY-MM') as month_str
from tmp
