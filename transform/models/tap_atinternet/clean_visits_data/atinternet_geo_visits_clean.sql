with raw_gn as (
    select
        date,
        geo_country,
        geo_region,
        geo_city,
        m_bounces,
        m_time_spent_per_visits,
        m_unique_visitors,
        m_visits
    from {{ source('tap_atinternet_gn', 'geo_visits') }}
),

raw_sp as (
    select
        date,
        geo_country,
        geo_region,
        geo_city,
        m_bounces,
        m_time_spent_per_visits,
        m_unique_visitors,
        m_visits
    from {{ source('tap_atinternet_sp', 'geo_visits') }}
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

geo_ref as (
    select
        iso_3166_2,
        subdiv_name,
        atinternet_geo_region
    from {{ ref('fra_iso_3166_2') }}
),

raw_all_with_geo as (
    select
        raw_all.src_website,
        raw_all.date::date,
        raw_all.geo_city,
        raw_all.geo_country,
        geo_ref.iso_3166_2 as geo_region_iso,
        geo_ref.subdiv_name as geo_region_name,
        raw_all.m_bounces,
        raw_all.m_time_spent_per_visits,
        raw_all.m_unique_visitors,
        raw_all.m_visits
    from raw_all
    left join geo_ref on raw_all.geo_region = geo_ref.atinternet_geo_region
    where m_visits > 0
),

raw_all_with_date as (
    select
        *,
        date_to_month(date) as month,
        date_to_month_str(date) as month_str,
        date_to_year(date) as year
    from raw_all_with_geo
)

select * from raw_all_with_date
