with renamed as (
    select
        id::bigint as id,
        "etat_de_lexpérience" as etat_experience,
        ressenti_usager as ressenti_usager,
        "intitulé_typologie_1" as typologie_structure_1,
        "intitulé_typologie_2" as typologie_structure_2,
        "intitulé_typologie_3" as typologie_structure_3,
        "tags_généraux_accessibilité" as tag_accessibilite,
        "tags_généraux_informationexplication" as tag_explication,
        "tags_généraux_relation" as tag_relation,
        "tags_généraux_réactivité" as tag_reactivite,
        "tags_généraux_simplicitécomplexité" as tag_simplicite,
        code_postal_usager as code_postal,
        to_date(ecrit_le, 'DD/MM/YYYY') as date_ecriture,
        to_date(date_de_publication, 'DD/MM/YYYY') as date_publi,
        to_date("date_de_premiere_réponse", 'DD/MM/YYYY') as date_reponse
    from {{ source('tap_csv_voxusagers', 'experiences') }}
)

-- Only select useful columns
select
    id,
    date_ecriture,
    date_publi,
    date_reponse,
    etat_experience,
    ressenti_usager,
    tag_accessibilite,
    tag_explication,
    tag_relation,
    tag_reactivite,
    tag_simplicite,
    code_postal,
    typologie_structure_1,
    typologie_structure_2,
    typologie_structure_3,
    code_postal_to_iso(code_postal::text) as iso_3166_2,
    date_reponse - date_publi as days_to_response
from renamed
