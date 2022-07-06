{% set gn_typologies = [
    'Brigade de gendarmerie',
    'Région de Gendarmerie',
    'Unité Numérique',
    'Service en ligne Perceval',
    'Pré-plainte en ligne (PPEL)',
    'Gendarmerie Nationale'
]
%}

--  Group typologies together to a single array
with t1 as (
    select
        id,
        array_agg(
            array [
                typologie_structure_1,
                typologie_structure_2,
                typologie_structure_3
            ]
        ) as typologies_structure
    from {{ ref('voxusagers_clean') }}
    group by id
),

--  Transform the array into 3 distinct rows (one per typologie_structure_x)
tmp as (
    select distinct
        unnest(typologies_structure) as typologie_structure,
        count(*) as exp_count
    from t1
    group by typologie_structure
)

--  restrict to structures related to GN
select *
from tmp
where typologie_structure = any(array {{gn_typologies}})
