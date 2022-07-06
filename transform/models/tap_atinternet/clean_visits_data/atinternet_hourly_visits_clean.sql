with raw_gn as (
    select
        date,
        visit_hour,
        site_level2,
        m_bounces,
        m_time_spent_per_visits,
        m_unique_visitors,
        m_visits
    from {{ source('tap_atinternet_gn', 'hourly_visits') }}
),

raw_sp as (
    select
        date,
        visit_hour,
        site_level2,
        m_bounces,
        m_time_spent_per_visits,
        m_unique_visitors,
        m_visits
    from {{ source('tap_atinternet_sp', 'hourly_visits') }}
),

raw_all as (
    select
        *,
        'gn' as src_website
    from raw_gn
    union all
    select
        *,
        'sp' as src_website
    from raw_sp
),

all_with_datetime as (
    select date::date + make_interval(hours := visit_hour::int) as datetime,
           *
    from raw_all
    where visit_hour >= 0 and m_visits > 0
),

selected_data as (
    select src_website,
        datetime,
        date::date,
        visit_hour,
        site_level2 as subsite,
        m_bounces,
        m_time_spent_per_visits,
        m_unique_visitors,
        m_visits
    from all_with_datetime
),

atinternet_hourly_visits_clean as (
    select *,
        date_to_month(date)     as month,
        date_to_month_str(date) as month_str,
        date_to_year(date)      as year
    from selected_data
)

select * from atinternet_hourly_visits_clean
