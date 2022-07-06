with requests as (
    select
        reference_hash as reference,
        date as original_datetime,
        -- Encoding errors: replace missing characters with '?' to make it explicit
        replace(motif, '�', '?') as motif,
        replace(motif_parent, '�', '?') as motif_parent,
        to_timestamp(date, 'DD/MM/YYYY HH24:MI')::timestamp as datetime
    from {{ source ('tap_csv_easiware', 'easiware_requests') }}
),

categories as (
    select
        motif_parent,
        motif,
        categorie
    from {{ ref('easiware_categories') }}
),

-- Match easiware motif/motif_parent with a high level
-- category (ex: demande_info, signalement, PNAV, etc)
-- and exclude PNAV data
all_data as (
    select
        requests.reference,
        requests.datetime,
        requests.original_datetime,
        categories.categorie as category
    from requests
    left join
        categories on
            -- Use 'is not distinct' rather than '=', so that NULL values are matched together
            requests.motif is not distinct from categories.motif and requests.motif_parent is not distinct from categories.motif_parent
    where categories.categorie is distinct from 'PNAV'
),

all_data_with_date as (
    select
        *,
        datetime_to_hour_of_day(datetime) as hour,
        datetime_to_date(datetime) as date
    from all_data
)

select
    *,
    date_to_month(date) as month,
    date_to_month_str(date) as month_str,
    date_to_year(date) as year
from all_data_with_date
