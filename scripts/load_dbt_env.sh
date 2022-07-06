#!/bin/sh
# ---
# This script loads some environment variables in order to be able to
# run the dbt project without using meltano CLI (e.g. 'dbt run').
#
# When using the meltano CLI (e.g. 'meltano invoke dbt:run' or 'meltano elt tap-x target-postgres --transform run'),
# meltano should already have loaded the .env file and set the DBT_PROJECT_DIR variable
# ---
# Get file parent directory (https://stackoverflow.com/a/246128/12662410)
PROJECT_DIR=$( cd -- "$( dirname -- "$0" )" 2>&1 > /dev/null && cd .. && pwd )
# Most variables should be in the project .env file
export $(grep -v '^#' $PROJECT_DIR/.env | xargs)
# Except this one, which requires the project path
# https://hub.meltano.com/transformers/dbt#profiles-directory
export DBT_PROFILES_DIR=$PROJECT_DIR/transform/profile
echo "Loaded env variables from " $PROJECT_DIR/.env
