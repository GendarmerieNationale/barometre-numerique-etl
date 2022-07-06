with raw_gn as (
    select
        date,
        src,
        src_detail,
        src_referrer_url,
        m_bounces,
        m_time_spent_per_visits,
        m_unique_visitors,
        m_visits
    from {{ source('tap_atinternet_gn', 'sources_visits') }}
),

raw_sp as (
    select
        date,
        src,
        src_detail,
        src_referrer_url,
        m_bounces,
        m_time_spent_per_visits,
        m_unique_visitors,
        m_visits
    from {{ source('tap_atinternet_sp', 'sources_visits') }}
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

selected_data as (
    select
        src_website,
        date::date,
        src,
        src_detail,
        src_referrer_url,
        m_bounces,
        m_time_spent_per_visits,
        m_unique_visitors,
        m_visits
    from raw_all
),

atinternet_hourly_visits_clean as (
    select
        *,
        date_to_month(date) as month,
        date_to_month_str(date) as month_str,
        date_to_year(date) as year
    from selected_data
)

select * from atinternet_hourly_visits_clean
