with test_dates as (
    select *
    from (
            values
            ('2020-01-22', date '2020-01-01', '2020-01'),
            ('2020-01-01', date '2020-01-01', '2020-01'),
            ('2022-05-31', date '2022-05-01', '2022-05')
        )
    as test_dates(input_date_str, expected_month, expected_month_str)
),

t1 as (
    select
        *,
        input_date_str::date as date
    from test_dates
),

t2 as (
    select
        *,
        date_to_month(date) as month,
        date_to_month_str(date) as month_str
    from t1
)

select *
from t2
where month != expected_month or month_str != expected_month_str
