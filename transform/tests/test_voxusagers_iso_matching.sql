-- Check that we can match all codes postaux
select * from {{ ref('voxusagers_clean') }}
where
    (
        code_postal is null and iso_3166_2 is not null
    ) or (code_postal is not null and iso_3166_2 is null)
