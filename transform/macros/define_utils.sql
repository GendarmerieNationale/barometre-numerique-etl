-- cf https://discourse.getdbt.com/t/using-dbt-to-manage-user-defined-functions/18
{% macro define_utils() %}

CREATE OR REPLACE FUNCTION dpt_code_to_iso(dpt_code text)
    RETURNS TEXT AS
$$
DECLARE
    iso_code TEXT DEFAULT NULL;
BEGIN
    CASE
        WHEN dpt_code = '75'
            THEN iso_code := '75C';
        WHEN dpt_code = '20'
            THEN iso_code := '20R';
        WHEN dpt_code = '975'
            THEN iso_code := 'PM';
        WHEN dpt_code = '986'
            THEN iso_code := 'WF';
        WHEN dpt_code = '987'
            THEN iso_code := 'PF';
        WHEN dpt_code = '988'
            THEN iso_code := 'NC';
        --  Dans nos bdd, le code département 69 représente en fait
--  le Rhône (code iso: FR-69) + la métropole de Lyon (code iso: FR-69M)
--  -> on les regroupe dans un "faux" code ISO
        WHEN dpt_code = '69'
            THEN iso_code := 'HACK-RHONE';
        WHEN dpt_code = '97'
            THEN iso_code := 'HACK-97';
        WHEN dpt_code = '98'
            THEN iso_code := 'HACK-98';
        ELSE iso_code := dpt_code;
        END CASE;
    RETURN 'FR-' || iso_code;
END;
$$ LANGUAGE plpgsql;

-- Convert a "department" integer code (e.g. 75, 3, or 971) to a valid ISO 3166 code (e.g. 'FR-75', 'FR-03', 'FR-971')
-- Note: the "department" code does not actually need to be a valid department code
-- (see https://fr.wikipedia.org/wiki/Code_postal_en_France#Cas_particuliers)
CREATE OR REPLACE FUNCTION dpt_code_to_iso(dpt_code int)
    RETURNS TEXT AS
$$
BEGIN
    RETURN dpt_code_to_iso(to_char(dpt_code, 'fm900'));
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION code_postal_to_iso(code_postal text)
    RETURNS TEXT AS
$$
DECLARE
    dpt_code     TEXT DEFAULT NULL;
    dpt_code_int INT DEFAULT NULL;
BEGIN
    CASE
        WHEN starts_with(code_postal, '97') or starts_with(code_postal, '98')
--             Outre-mer: extract the first 3 digits (e.g. Guadeloupe: 97130 -> '971')
            THEN dpt_code := left(code_postal, 3);
        WHEN starts_with(code_postal, '20')
            --             Corse: map 201XX codes to '2A' (Corse-du-Sud) and 202XX codes to '2B' (Haute-Corse)
--             cf https://fr.wikipedia.org/wiki/Code_postal_en_France#Corse_(20)
            THEN IF starts_with(code_postal, '201') THEN
                dpt_code := '2A';
            ELSIF starts_with(code_postal, '202') THEN
                dpt_code := '2B';
            ELSE
                RAISE NOTICE '(Corse) Could not map code postal to a dpt code: "%".  Returning NULL.', code_postal;
            END IF;
        --             ⚠️ We may encounter other edge cases not taken into account here:
--             https://fr.wikipedia.org/wiki/Liste_des_communes_de_France_dont_le_code_postal_ne_correspond_pas_au_d%C3%A9partement
--             In these cases, the result should be a close department, but not the administrative match
        ELSE --             For most departments:
--              - remove the last 3 digits (e.g. 75001 -> 75, 1500 -> 1)
--              - then add a heading digit if necessary (75 -> '75', 1 -> '01')
--             RAISE NOTICE '(Corse) Could not map code postal to a dpt code: "%".  Returning NULL.', code_postal;
            dpt_code_int := left(code_postal, -3)::int;
            dpt_code := to_char(dpt_code_int, 'fm900');
        END CASE;
    RETURN dpt_code_to_iso(dpt_code);
END;
$$ LANGUAGE plpgsql;

-- https://stackoverflow.com/a/2095676/12662410
CREATE OR REPLACE FUNCTION convert_to_integer(v_input text)
    RETURNS INTEGER AS
$$
DECLARE
    v_int_value INTEGER DEFAULT NULL;
BEGIN
    BEGIN
        v_int_value := v_input::INTEGER;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'Invalid integer value: "%".  Returning NULL.', v_input;
            RETURN NULL;
    END;
    RETURN v_int_value;
END;
$$ LANGUAGE plpgsql;

-- ----- Date time utils (make sure we use the same time processing functions
-- across the project)
CREATE OR REPLACE FUNCTION datetime_to_hour_of_day(datetime timestamp)
    RETURNS INT AS
$$
BEGIN
    RETURN extract(hour from datetime);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION datetime_to_date(datetime timestamp)
    RETURNS DATE AS
$$
BEGIN
    RETURN datetime::date;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION date_to_month(date date)
    RETURNS DATE AS
$$
BEGIN
    RETURN date_trunc('month', date)::date;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION date_to_month_str(date date)
    RETURNS TEXT AS
$$
BEGIN
    RETURN to_char(date, 'YYYY-MM');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION date_to_year(date date)
    RETURNS INT AS
$$
BEGIN
    RETURN extract(year from date);
END;
$$ LANGUAGE plpgsql;


-- ----- Random functions, useful to generate fake data
-- From: https://stackoverflow.com/questions/53687946/beta-and-lognorm-distributions-in-postgresql
CREATE OR REPLACE FUNCTION random_normal(mu FLOAT = 0, sigma FLOAT = 1)
    RETURNS FLOAT AS
$$
BEGIN
    RETURN sigma * sqrt(-2. * ln(random())) * cos(2 * pi() * random()) + mu;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION random_lognormal(mu FLOAT = 0, sigma FLOAT = 1)
    RETURNS FLOAT AS
$$
BEGIN
    RETURN exp(random_normal(mu, sigma));
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION random_truncnormal(min FLOAT = 0, max FLOAT = 1, sigma FLOAT = 0.15)
    RETURNS FLOAT AS
$$
BEGIN
    --     Generate a normal dist roughly in the [min,max] interval, then clamp it
    RETURN greatest(min, least(max, min + (max - min) * random_normal(0.5, sigma)));
END;
$$ LANGUAGE plpgsql;

{% endmacro %}
