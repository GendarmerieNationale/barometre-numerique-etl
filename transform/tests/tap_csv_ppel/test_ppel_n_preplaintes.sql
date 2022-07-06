-- Make sure that the totals match

with total as (
    select count(stats_id) as n1
    from {{ source('tap_csv_ppel', 'ppel_logs') }}
),

total_clean as (
    select count(stats_id) as n2
    from {{ ref('ppel_clean_logs') }}
),

total_daily as (
    select sum(n_preplaintes) as n3
    from {{ ref('ppel_daily') }}
),

total_person_type as (
    select sum(n_preplaintes) as n4
    from {{ ref('ppel_person_type') }}
),

total_geo as (
    select sum(n_preplaintes) as n5
    from {{ ref('ppel_geo') }}
)

select * from total, total_clean, total_daily, total_person_type, total_geo
where (n1 != n2 or n2 != n3 or n3 != n4 or n4 != n5)
