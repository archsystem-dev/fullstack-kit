# create_project.sh

## Objectif du script
Crée un nouveau projet web FastAPI/Vue avec environnements npm (frontend), Conda (backend) et base PostgreSQL, à partir d'une configuration interactive et d'un fichier .ini.

## Ce que fait le script étape par étape
1. Vérifie l'exécution en root via sudo et récupère l'utilisateur réel.
2. Lance un configurateur interactif pour saisir nom du projet, version Python et mot de passe PostgreSQL.
3. Lit les chemins globaux depuis `install_softwares.ini`.
4. Définit tous les chemins du projet et vérifie qu'aucun élément n'existe déjà.
5. Crée la structure de répertoires avec bons propriétaires.
6. Initialise un projet npm dans le frontend (avec express).
7. Crée un environnement Conda dédié dans le backend.
8. Crée le rôle et la base PostgreSQL, configure l'authentification et redémarre le service.
9. Crée des liens symboliques vers les scripts du kit et copie les fichiers de configuration.
10. Gère la création ou le clonage du dépôt GitHub via un script dédié.
11. Effectue des vérifications finales sur npm, Conda et PostgreSQL.
12. Affiche un récapitulatif complet de succès.

## Liste des fonctions internes

| Fonction          | Rôle                                                                 |
|-------------------|----------------------------------------------------------------------|
| `info`            | Affiche un message informatif avec préfixe [INFO]                    |
| `success`         | Affiche un message de succès avec préfixe [OK]                       |
| `error`           | Affiche un message d'erreur avec [ERREUR] et quitte le script        |
| `to_lowercase`    | Convertit une chaîne en minuscules (POSIX)                           |
| `get_config_value`| Lit une valeur dans un fichier .ini et substitue $USER               |
| `create_symlink`  | Crée un lien symbolique en nettoyant proprement les conflits         |
| `project_config`  | Boucle interactive de configuration et validation du projet         |

## Prérequis clairs
- Exécution avec `sudo` (obligatoire pour PostgreSQL et permissions).
- Miniconda installé et configuré pour root et l'utilisateur réel.
- PostgreSQL installé et fonctionnel (utilisateur `postgres` existant).
- `crudini` installé pour lire les fichiers .ini.
- Fichier `install_softwares.ini` présent dans le même répertoire que le script.
- Scripts du kit (listés dans la boucle) présents dans le répertoire du script.
- Fichiers `nginx.conf`, `github.ini`, `gitignore.conf` présents.
- Accès GitHub configuré pour l'utilisateur réel (pour le script github_create_or_clone.sh).

## Utilisation précise
```bash
chmod +x create_project.sh   # une seule fois
sudo ./create_project.sh    # obligatoire : exécuter avec sudo