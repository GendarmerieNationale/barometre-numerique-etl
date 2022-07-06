-- Make sure that the totals match

with total_daily as (
    select
        sum(amount) as a1,
        sum(count) as c1
    from {{ ref('perceval_daily') }}
),

total_monthly as (
    select
        sum(amount) as a2,
        sum(count) as c2
    from {{ ref('perceval_monthly') }}
),

total_geo as (
    select sum(count) as c3
    from {{ ref('perceval_geo') }}
),

total_age_cat as (
    select sum(count) as c4
    from {{ ref('perceval_age_cat') }}
)

select * from total_daily, total_monthly, total_geo, total_age_cat
where (c1 != c2 or c2 != c3 or c3 != c4)
--    unlike total counts, amounts are floats, so there can be rounding errors
--    -> check that the difference is small
   or abs(a1 - a2) > 1
