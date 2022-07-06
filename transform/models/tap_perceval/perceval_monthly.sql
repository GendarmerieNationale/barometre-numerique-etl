with tmp as (
    select
        month,
        month_str,
        sum(count) as count,
        sum(amount) as amount
    from {{ ref('perceval_daily') }}
    group by month, month_str
)

select
    month,
    month_str,
    count,
    amount,
    amount / count as avg_amount
from tmp
