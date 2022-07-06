--        Combine all in a single table (fill with null when columns are missing in a table)
--        https://github.com/dbt-labs/dbt-utils#union_relations-source
with combine_all as (
   {{ dbt_utils.union_relations(relations=[
        ref ('twitter_followers')
    ]) }}
)

--        Keep the original table name as 'reseau' in the final table.
--        Remove the table prefix and '_followers' suffix, e.g.
--              "cyberimpact_dwh"."analytics"."twitter_followers"
--        becomes
--              twitter
select *,
       replace(split_part(_dbt_source_relation, '"."', -1),
           '_followers"', '') as reseau
from combine_all


-- Also possible to do it with UNION ALL (but this requires the tables to have the exact same columns)
-- and a for loop over the tables