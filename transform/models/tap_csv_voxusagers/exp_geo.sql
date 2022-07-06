with tmp as (
    select
        iso_3166_2,
        count(*) as exp_count
    from {{ ref('voxusagers_clean') }}
    group by iso_3166_2
),

geo_ref as (
    select
        subdiv_type,
        iso_3166_2,
        subdiv_name,
        parent_subdiv
    from {{ ref('fra_iso_3166_2') }}
)

select
    exp_count,
    geo_ref.iso_3166_2 as geo_dpt_iso,
    geo_ref.subdiv_name as geo_dpt_name,
    geo_ref_parent.iso_3166_2 as geo_region_iso,
    geo_ref_parent.subdiv_name as geo_region_name
from tmp
left join geo_ref on tmp.iso_3166_2 = geo_ref.iso_3166_2
left join
    geo_ref as geo_ref_parent on
        geo_ref.parent_subdiv = geo_ref_parent.iso_3166_2
order by geo_dpt_iso desc
