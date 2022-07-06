-- Check that we don't have any bad surprises during the datetime conversion

with original_tmp as (
    select
        stats_id,
--      Exemple format: '2014-08-10 06:23:00'
        original_datetime,
        substring(original_datetime from 1 for 4)::int as year,
        substring(original_datetime from 6 for 2)::int as month,
        substring(original_datetime from 9 for 2)::int as day,
        substring(original_datetime from 12 for 2)::int as hour,
        substring(original_datetime from 15 for 2)::int as min
    from {{ ref('ppel_clean_logs') }}
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
        stats_id,
        datetime,
        date::text as date_str,
        month_str,
        extract(day from datetime) as day,
        extract(month from datetime) as month,
        extract(year from datetime) as year,
        extract(hour from datetime) as hour,
        extract(minute from datetime) as min
    from {{ ref('ppel_clean_logs') }}
)

-- Select rows where we have a difference between the
-- processed and original datetime data
select *
from original
inner join processed
           on original.stats_id = processed.stats_id
where original.year != processed.year
      or original.month != processed.month
      or original.day != processed.day
      or original.hour != processed.hour
      or original.min != processed.min
    or original.date_str != processed.date_str
    or original.month_str != processed.month_str
