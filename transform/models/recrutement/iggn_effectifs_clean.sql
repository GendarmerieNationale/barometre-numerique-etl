with effectif_table as (select
    annee,
    categorie,
    effectifs_homme,
    effectifs_femme,
    case
        when categorie = 'Personnel civil' then 'civil' else 'militaire'
    end as type_personnel
    from {{ ref('iggn_effectifs_raw') }}
)

-- Unpivot the table
select e.annee,
       e.categorie,
       e.type_personnel,
       t.*
from effectif_table e
cross join lateral (
    values
    (e.effectifs_homme, 'homme'),
    (e.effectifs_femme, 'femme')
) as t(effectifs, genre)