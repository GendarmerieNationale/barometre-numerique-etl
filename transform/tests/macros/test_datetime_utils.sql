with test_dates as (
    select *
    from (
            values
            ('2020-01-01 14:38:14', 14, date '2020-01-01', date '2020-01-01', '2020-01', 2020),
            ('2020-01-01 00:38:14', 0, date '2020-01-01', date '2020-01-01', '2020-01', 2020),
            ('2019-12-31 23:38:14', 23, date '2019-12-31', date '2019-12-01', '2019-12', 2019),
            ('2020-01-22 10:00:00', 10, date '2020-01-22', date '2020-01-01', '2020-01', 2020),
            ('2022-05-31 12:05:06', 12, date '2022-05-31', date '2022-05-01', '2022-05', 2022)
        )
    as test_dates(input_datetime_str, expected_hour, expected_date, expected_month, expected_month_str, expected_year)
),

t1 as (
    select
        *,
        to_timestamp(
            input_datetime_str, 'YYYY-MM-DD HH24:MI:SS'
        )::timestamp as datetime
    from test_dates
),

t2 as (
    select
        *,
        datetime_to_hour_of_day(datetime) as hour,
        datetime_to_date(datetime) as date
    from t1
),

t3 as (
    select
        *,
        date_to_month(date) as month,
        date_to_month_str(date) as month_str,
        date_to_year(date) as year
   from t2
)

select *
from t3
where
      hour != expected_hour
   or date != expected_date
   or month != expected_month
   or month_str != expected_month_str
   or year != expected_year
