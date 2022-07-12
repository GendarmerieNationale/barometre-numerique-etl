# Le Baromètre Numérique (ELT avec Meltano)
Projet Meltano pour la partie _Extract, Load, Transform (ELT)_ du « Baromètre Numérique », 
plateforme de transparence des services numériques de la Gendarmerie Nationale.

Accessible à l'adresse: https://www.gendarmerie.interieur.gouv.fr/barometre-numerique/

⚠️ Version Bêta : Le site, le code source et sa documentation sont encore en phase de développement.

## Installation
TODO: put everything in scripts or make file, and use pinned meltano versions
### Mettre en place l'environnement Meltano
Commencer par cloner le dépôt
```
git clone https://github.com/GendarmerieNationale/barometre-numerique-etl.git
cd barometre-numerique-etl
```

Il faut ensuite s'assurer que les données .csv non suivies par git soient présentes 
sur le serveur :
- Données brutes dans `../data/` (**en dehors du repo**)
- Données manquantes de référence : `transform/data/easiware_categories.csv` (_dbt seed data_). 
  Le projet dbt [ne peut pas compiler](https://docs.getdbt.com/docs/building-a-dbt-project/seeds) 
  s'il manque ces fichiers.

Puis créer et remplir le fichier `.env` contenant les variables d'environnement. 
(TODO: décrire quelles variables d'environnement)

> Note: pour générer des mots de passe sécurisés, il peut être utile d'installer et 
> d'utiliser [`pwgen`](https://linux.die.net/man/1/pwgen) par exemple:
> ```
> pwgen -1s 32
> ```
> Cela peut être fait en local sur votre machine de dev, si pwgen n'est pas installé sur les serveurs.

### Installer Meltano
[Documentation officielle](https://docs.meltano.com/guide/installation#local-installation)

> Note : la documentation officielle propose plusieurs manières d'installer un projet meltano 
> (avec ou sans docker notamment). Les étapes ci-dessous concernent l'installation sans docker,
> qui peut-être plus pratique pour des installations simples, mais ce n'est pas la seule option qui existe.

**Prérequis :**
- python 3.7, 3.8 ou 3.9 : version 3.9 installée par défaut sur debian (`python3`)
- `apt install python3-pip python3-venv` : nécessaire pour installer `pipx` (et d'autres packages)
- `apt install libpq-dev` : si vous utilisez python 3.9, nécessaire pour `target-postgres` 
(cf [issue github](https://github.com/transferwise/pipelinewise-target-postgres/issues/82))
- Également s'assurer que `gcc` et `python3-dev` sont disponibles (à cause de 
[ce package](https://github.com/closeio/ciso8601/issues/25) qui ne mets pas à disposition les wheels compilés...)

Il devrait maintenant être possible d'installer [`pipx`](https://pypa.github.io/pipx/installation/) 
(similaire à `npx`, mais pour python), puis d'installer `meltano` :
```
# install pipx in ~/.local/bin
python3 -m pip install --user pipx  
# add `export PATH="$PATH:/root/.local/bin"` at the end of ~/.bashrc
python3 -m pipx ensurepath
source ~/.bashrc

# TODO: pin meltano version
pipx install meltano
```

> Note : il est également possible d'installer meltano en utilisant un python venv
> plutôt que pipx :
> Créer le venv dans le dossier actuel avec `python3 -m venv venv`, 
> et ne pas oublier de l'activer avec `source venv/bin/activate` avant 
> de lancer `pip install meltano` ou d'autres commandes meltano.


### Créer la base de données Postgres (DWH)
Créer l'utilisateur `meltano`, qui va effectuer les jobs ETL/ELT
```
# (l'option -e affiche simplement la commande SQL exécutée)
createuser -P -e meltano
# -> entrer un mdp (généré avec pwgen par exemple)
```

Et l'utilisateur `express-api`, que l'API va utiliser pour se connecter à la bdd :
```
createuser -P -e express-api
# -> choisir et entrer un autre mdp
```

Voir la doc postgres pour [plus de détails sur les rôles](https://www.postgresql.org/docs/current/ddl-priv.html).
Si l'API est hébergée sur une machine différente de la bdd, il faut également s'assurer que la bdd 
`cyberimpact_dwh` accepte les connections de l'utilisateur `express-api` depuis une IP extérieure.
Typiquement en rajoutant une ligne comme `host  all  express-api  XXX.XXX.XXX.XXX/32 md5` dans
le fichier `/etc/postgresql/14/main/pg_hba.conf` (où `XXX.XXX.XXX.XXX/32` est remplacé par l'IP 
de la machine hébergeant l'API).

### Installer le projet meltano et remplir la bdd initiale
Lancer :
```
chmod +x scripts/build.sh
scripts/build.sh
```

## Utiliser Meltano et dbt
TODO: explication basique des commandes utiles
```
# --- meltano
meltano run ...

# --- dbt
meltano invoke dbt:deps
meltano invoke dbt:seed
meltano invoke dbt:run --select '*'
meltano invoke dbt:test
# note: if you are using dbt directly, you also need to `source load_dbt_env.sh`

# in case you need a clean refresh for a specific source
drop schema tap_x cascade;  # in a psql console
meltano run tap-x target-postgres --full-refresh
```

Qu'est-ce qui se passe lorsqu'on lance un job/run alors une bdd target déjà partiellement remplie,
mais avec un nouveau state_id, ou bien après avoir accidentellement supprimé la bdd meltano?
Si les clés primaires sont bien définies, meltano fait bien les choses et ne charge pas de
doublons dans la bdd, uniquement les (potentielles) nouvelles données.
Testé avec:
- tap-csv-voxusagers

TODO: explain crontab

TODO: how to launch dbt UI
```
source scripts/load_dbt_env.sh
# check that the dbt env variables are well defined: this should be `/path/to/project/transform/profile`
echo $DBT_PROFILES_DIR
cd transform
dbt docs generate
dbt docs serve
```

## Développement
TODO: nouveaux extracteurs ? meltano SDK?

## Mises à jour
```
# pour meltano (https://docs.meltano.com/reference/command-line-interface#upgrade)
meltano upgrade

```
