-- Check that we don't have any bad surprises during the datetime conversion

with original_tmp as (
    select
        reference,
--      Exemple: '10/02/2021 09:03'
        original_datetime,
        substring(original_datetime from 1 for 2)::int as day,
        substring(original_datetime from 4 for 2)::int as month,
        substring(original_datetime from 7 for 4)::int as year,
        substring(original_datetime from 12 for 2)::int as hour,
        substring(original_datetime from 15 for 2)::int as min
    from {{ ref('easiware_requests_clean') }}
),

original as (
    select
        *,
        year || '-' || to_char(
            month, 'fm00'
        ) || '-' || to_char(day, 'fm00') as date_str,
        year || '-' || to_char(month, 'fm00') as month_str
    from original_tmp
),

processed as (
    select
        reference,
        datetime,
        date::text as date_str,
        month_str,
        extract(day from datetime) as day,
        extract(month from datetime) as month,
        extract(year from datetime) as year,
        extract(hour from datetime) as hour,
        extract(minute from datetime) as min
    from {{ ref('easiware_requests_clean') }}
)

-- Select rows where we have a difference between the
-- processed and original datetime data
select *
from original
inner join processed
           on original.reference = processed.reference
where original.year != processed.year
      or original.month != processed.month
      or original.day != processed.day
      or original.hour != processed.hour
      or original.min != processed.min
    or original.date_str != processed.date_str
    or original.month_str != processed.month_str
