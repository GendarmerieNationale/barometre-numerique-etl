with raw_users as (
    select
        id,
        name,
        username,
        created_at,
        verified,
        (public_metrics -> 'tweet_count')::integer as n_tweets,
        (public_metrics -> 'followers_count')::integer as n_followers,
        (public_metrics -> 'following_count')::integer as n_following,
        (public_metrics -> 'listed_count')::integer as n_listed
    from {{ source('tap_twitter', 'users') }}
),

-- Extract the department code from the username as an integer
-- Only works when the username is something like: 'Gendarmerie_04' or 'gendarmerie_973',
-- return NULL otherwise (e.g. for 'GendarmerieNationale')
users_tmp as (
    select
        *,
        convert_to_integer(
            replace(lower(username), 'gendarmerie_', '')
        ) as dpt
    from raw_users
),

-- Convert the department number to a ISO-3166-2 formatted code
-- Example: 4 -> 'FR-04', 973 -> 'FR-973'
users as (
    select
        *,
        dpt_code_to_iso(dpt) as iso_3166_2
    from users_tmp
),

geo_ref as (
    select
        subdiv_type,
        iso_3166_2,
        subdiv_name,
        parent_subdiv
    from {{ ref('fra_iso_3166_2') }}
),

final as (
    select
        username as page_username,
        name as page_name,
        n_followers,
        n_tweets,
        geo_ref.iso_3166_2 as geo_dpt_iso,
        geo_ref.subdiv_name as geo_dpt_name,
        geo_ref_parent.iso_3166_2 as geo_region_iso,
        geo_ref_parent.subdiv_name as geo_region_name,
        'https://twitter.com/' || username as page_url
    from users
    left join geo_ref on users.iso_3166_2 = geo_ref.iso_3166_2
    left join
        geo_ref as geo_ref_parent on
            geo_ref.parent_subdiv = geo_ref_parent.iso_3166_2
)

select * from final
