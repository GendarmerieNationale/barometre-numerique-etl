with logs as (
    select
        stats_id,
        stats_dpt_unite as dpt_code,
        stats_debut_declaration as original_datetime,
        stats_pers_physique::int::bool as is_pers_physique,
        stats_pers_morale::int::bool as is_pers_morale,
        dpt_code_to_iso(stats_dpt_unite) as geo_dpt_iso,
        to_timestamp(
            stats_debut_declaration, 'YYYY-MM-DD HH24:MI:SS'
        )::timestamp as datetime_debut,
        to_timestamp(
            stats_fin_declaration, 'YYYY-MM-DD HH24:MI:SS'
        )::timestamp as datetime_fin
    from {{ source('tap_csv_ppel', 'ppel_logs') }}
),

geo_ref as (
    select
        iso_3166_2,
        subdiv_name
    from {{ ref('fra_iso_3166_2') }}
),

--      Join the logs with geo data
all_logs as (
    select
        stats_id,
        original_datetime,
        datetime_debut as datetime,
        dpt_code,
        geo_ref.iso_3166_2 as geo_dpt_iso,
        geo_ref.subdiv_name as geo_dpt_name,
        datetime_fin - datetime_debut as duree,
        case
            when (is_pers_physique and not is_pers_morale) then 'physique'
            when (not is_pers_physique and is_pers_morale) then 'morale'
            else 'unknown'
        end as type_personne
    from
        logs
    left join geo_ref
        on logs.geo_dpt_iso = geo_ref.iso_3166_2
),

--      Extract date columns from datetime
all_logs_with_date as (
    select
        *,
        datetime_to_hour_of_day(datetime) as hour,
        datetime_to_date(datetime) as date
    from all_logs
)

select
    *,
    date_to_month(date) as month,
    date_to_month_str(date) as month_str,
    date_to_year(date) as year
from all_logs_with_date
