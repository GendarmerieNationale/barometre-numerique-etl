{% set tags = ["tag_accessibilite", "tag_explication", "tag_relation", "tag_reactivite", "tag_simplicite"] %}

with tmp as (select
    {% for tag in tags %}
    sum(
        case when {{ tag }} = 'Positif' then 1 else 0 end
    ) as "exp_{{tag}}_pos",
    sum(
        case when {{ tag }} = 'Neutre' then 1 else 0 end
    ) as "exp_{{tag}}_med",
    sum(
        case when {{ tag }} = 'Négatif' then 1 else 0 end
    ) as "exp_{{tag}}_neg",
    {% endfor %}
    count(*) as exp_count
    from {{ ref('voxusagers_clean') }})

-- unpivot the above table
select
    unnest(array [{% for tag in tags %} '{{tag}}' {{ ", " if not loop.last else "" }}{% endfor %}]) as tag,
    unnest(array [{% for tag in tags %} exp_{{tag}}_pos {{ ", " if not loop.last else "" }}{% endfor %}]) as pos_count,
    unnest(array [{% for tag in tags %} exp_{{tag}}_med {{ ", " if not loop.last else "" }}{% endfor %}]) as med_count,
    unnest(array [{% for tag in tags %} exp_{{tag}}_neg {{ ", " if not loop.last else "" }}{% endfor %}]) as neg_count,
    exp_count as total_count
from tmp