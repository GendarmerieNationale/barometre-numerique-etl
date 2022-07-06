-- Make sure that the totals match

with total as (
    select n_contact as n1
    from {{ ref('easiware_n_contacts_total') }}
),

total_cat as (
    select sum(n_contact) as n2
    from {{ ref('easiware_n_contacts_category') }}
),

total_hour as (
    select sum(n_contact) as n3
    from {{ ref('easiware_n_contacts_hour') }}
),

total_date as (
    select sum(n_contact) as n4
    from {{ ref('easiware_n_contacts_date') }}
)

select * from total, total_cat, total_hour, total_date
where (n1 <> n2 or n2 <> n3 or n3 <> n4)