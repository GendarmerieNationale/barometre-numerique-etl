with tmp as (
    select
        code_postal,
        expected_dpt_code,
        code_postal_to_iso(code_postal::text) as dpt_code
    from {{ ref('test_code_postaux') }}
)

select * from tmp
where dpt_code != expected_dpt_code
