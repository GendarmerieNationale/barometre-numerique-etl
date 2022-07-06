Ce dossier contient quelques scripts réalisés pour le projet.

*`load_dbt_env.sh`*
Ce script peut être utile pour exécuter des commandes `dbt` sans passer par meltano.
Le script charge simplement les variables définies dans le fichier `.env` à la racine du projet.

*`make_crontab.py`*
Permet de créer un fichier crontab à partir de schedules définis dans `meltano.yml`.
Pour l'utiliser: 
  - Spécifier le chemin de l'exécutable meltano dans le `.env` (`CRONTAB_MELTANO_EXECUTABLE`)
  - `export $(grep -v '^#' .env | xargs)` pour charger les variables d'environnement
  - `meltano schedule list --format=json | python3 scripts/make_crontab.py`.

Si le fichier crontab convient, il est possible de le charger (en écrasant le crontab existant !) avec:
```
meltano schedule list --format=json | python3 scripts/make_crontab.py >crontab.file
crontab crontab.file
```
