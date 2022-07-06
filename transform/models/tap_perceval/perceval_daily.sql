with daily_amount as (
    select
        day,
        amount
    from {{ source('tap_perceval', 'amount_of_money_day') }}
),

daily_count as (
    select
        day,
        count
    from {{ source('tap_perceval', 'nb_report_day') }}
)

select
    daily_amount.day::date as date,
    daily_amount.day as date_str,
    daily_amount.amount as amount,
    daily_count.count as count,
    date_trunc('month', daily_amount.day::date) as month,
    to_char(
        date_trunc('month', daily_amount.day::date), 'YYYY-MM'
    ) as month_str
from
    daily_amount
full outer join
    daily_count
    on daily_amount.day = daily_count.day
