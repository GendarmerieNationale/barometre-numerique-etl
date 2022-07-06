select
    count(*) as exp_count,
    sum(
        case when ressenti_usager = 'Positif' then 1 else 0 end
    ) as exp_pos_count,
    sum(
        case when ressenti_usager = 'Neutre' then 1 else 0 end
    ) as exp_moy_count,
    sum(
        case when ressenti_usager = 'Négatif' then 1 else 0 end
    ) as exp_neg_count,
    sum(
        case when etat_experience = 'Traitée' then 1 else 0 end
    ) as exp_answered_count,
    avg(days_to_response) as avg_days_to_response,
    percentile_cont(
        0.95
    ) within group ( order by days_to_response ) as p95_days_to_response,
    percentile_cont(
        0.90
    ) within group ( order by days_to_response ) as p90_days_to_response,
    percentile_cont(
        0.75
    ) within group ( order by days_to_response ) as p75_days_to_response
from {{ ref('voxusagers_clean') }}
