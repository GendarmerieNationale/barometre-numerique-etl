with tmp as (select
    month,
    month_str,
    page_full_name,
    visit_count
    from {{ ref('atinternet_visits_per_page') }}
    where subsite = 'recrutement'
        and starts_with(
            page_full_name, 'decouvrir-nos-metiers::'
        )
),

--      Transforme la colonne page_full_name en un nom de métier
--      (en minuscules, sans accent ni caractère spécial)
tmp2 as (select
    *,
    replace(
        replace(
            page_full_name,
            'decouvrir-nos-metiers::', ''),
        '-', ' '
    ) as metier_name_tmp2
    from tmp
),

--      Enlève les métiers avec très peu de visites (~1-2, les erreurs et les tests)
tmp3 as (
    select *
    from tmp2
    where metier_name_tmp2 not in (
            'Z2VuZGFybW',
            'null',
            'technicien en réseaux informatiques et télécoms',
            'gendarmeen brigade'
        )
),

-- Corrige certains mots communs (en rajoutant les accents, majuscules, etc)
tmp4 as (
    select
        *,
        replace(
            replace(
                replace(
                    replace(
                        replace(
                            replace(
                                replace(
                                    replace(
                                        replace(
                                            replace(
                                                replace(
                                                    replace(
                                                        replace(
                                                            replace(
                                                                replace(
                                                                    replace(
                                                                    metier_name_tmp2,
                                                                    'psig',
                                                                    'PSIG'
                                                                ),
                                                                'gign', 'GIGN'),
                                                            ' rh ', ' RH '),
                                                        'd h', 'd''h'),
                                                    'd i', 'd''i'),
                                                'unite', 'unité'),
                                            'republicain', 'républicain'),
                                        'systemes', 'systèmes'),
                                    'enqueteur', 'enquêteur'),
                                'securite', 'sécurité'),
                            'numerique', 'numérique'),
                        'telecom', 'télécom'),
                    'developpeur', 'développeur'),
                'helicoptere', 'hélicoptère'),
            'aerien', 'aérien'),
        'mecanicien','mécanicien')
        as metier_name_tmp4
    from tmp3
),

--      Remplace la première lettre par une majuscule
tmp5 as (
    select
        *,
        upper(
            left(metier_name_tmp4, 1)
        ) || right(metier_name_tmp4, -1) as metier_name
    from tmp4
),

--      Dernières corrections pour les erreurs restantes:
--      remplace les noms métiers par ceux spécifiés dans transform/data/recrutement_noms_metiers.csv
name_mapping as (
    select
        name,
        name_clean
    from {{ ref('recrutement_noms_metiers') }}
),

tmp6 as (
    select
        month,
        month_str,
        page_full_name,
        visit_count,
        case
            when
                (name_mapping.name_clean is null) then tmp5.metier_name
            else name_mapping.name_clean
        end as metier_name
    from tmp5 left join name_mapping on tmp5.metier_name = name_mapping.name
)

select *
from tmp6
