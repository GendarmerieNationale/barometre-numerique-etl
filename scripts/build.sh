#!/bin/bash
set -x
# --- Charge les variables d'environnement définies dans .env
set -o allexport
source .env
set +o allexport

# --- Crée la base de données Postgres `cyberimpact_dwh`, avec l'utilisateur `meltano` en tant que propriétaire
createdb -O meltano -e cyberimpact_dwh
# **Lien avec l'API**
# Pour se connecter à la base de données, l'API du baromètre numérique utilise l'utilisateur `express-api`,
# qui n'a accès qu'au schéma `analytics`, en lecture seule
psql "postgresql://meltano:$TARGET_POSTGRES_PASSWORD@localhost:5432/cyberimpact_dwh" -c "CREATE SCHEMA analytics;"
psql "postgresql://meltano:$TARGET_POSTGRES_PASSWORD@localhost:5432/cyberimpact_dwh" -c "GRANT CONNECT ON DATABASE cyberimpact_dwh TO \"express-api\";"
psql "postgresql://meltano:$TARGET_POSTGRES_PASSWORD@localhost:5432/cyberimpact_dwh" -c "GRANT USAGE ON SCHEMA analytics TO \"express-api\";"
psql "postgresql://meltano:$TARGET_POSTGRES_PASSWORD@localhost:5432/cyberimpact_dwh" -c "GRANT SELECT ON ALL TABLES IN SCHEMA analytics TO \"express-api\";"
# pour également donner accès aux futures tables créées par `meltano` (d'après https://stackoverflow.com/a/762649/12662410)
psql "postgresql://meltano:$TARGET_POSTGRES_PASSWORD@localhost:5432/cyberimpact_dwh" -c "ALTER DEFAULT PRIVILEGES IN SCHEMA analytics GRANT SELECT ON TABLES TO \"express-api\";"

# --- Installe les plugins du projet meltano (extractors, loaders, etc)
function meltano_exec {
  $CRONTAB_MELTANO_EXECUTABLE "$@"
}
# installe tout ce qui est spécifié dans meltano.yml
meltano_exec install
# sauf ce plugin, à installer manuellement (cf bug https://github.com/meltano/meltano/issues/3442)
meltano_exec add mapper meltano-map-transformer

# --- Remplissage initial de la bdd, en lançant tous les jobs/schedules spécifiés dans meltano.yml
meltano_exec invoke dbt:deps
meltano_exec invoke dbt:seed
meltano_exec schedule list --format=json | python3 scripts/make_initial_run_script.py >scripts/initial_meltano_run.sh
chmod +x scripts/initial_meltano_run.sh
scripts/initial_meltano_run.sh
meltano_exec invoke dbt:run
meltano_exec invoke dbt:test

# --- Crée mets en route le fichier crontab avec les jobs récurrents
meltano_exec schedule list --format=json | python3 scripts/make_crontab.py >crontab.file
crontab crontab.file