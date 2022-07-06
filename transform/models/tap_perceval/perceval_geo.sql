with tmp as (
    select
        month as month_str,
        dpt_code,
        count,
        to_date(month, 'YYYY-MM-DD') as month,
        dpt_code_to_iso(dpt_code) as geo_dpt_iso
    from {{ source('tap_perceval', 'dpt_report_month') }}
),

geo_ref as (
    select
        iso_3166_2,
        subdiv_name
    from {{ ref('fra_iso_3166_2') }}
)

select
    month,
    month_str,
    dpt_code,
    geo_ref.iso_3166_2 as geo_dpt_iso,
    geo_ref.subdiv_name as geo_dpt_name,
    count
from
    tmp
left join
    geo_ref
    on tmp.geo_dpt_iso = geo_ref.iso_3166_2
