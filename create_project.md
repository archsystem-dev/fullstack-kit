------------------------------------------------------------------------------
Nom du script       : create_project.sh
Version             : 1.0.0
Auteur              : archsystem-dev
Date de modification: 13 décembre 2025
Description         : Crée un nouveau projet web FastAPI/Vue avec environnements npm (frontend), Conda (backend) et base PostgreSQL, à partir d'une configuration interactive et d'un fichier .ini.
------------------------------------------------------------------------------

# Objectif du script

Créer un projet complet FastAPI (backend) / Vue.js (frontend) avec tous les environnements nécessaires (npm, Conda, PostgreSQL) et les scripts utilitaires du kit en liens symboliques.

# Étapes réalisées par le script

1. Vérification que le script est exécuté avec `sudo` et récupération de l'utilisateur réel.
2. Saisie interactive et validation du nom du projet, version Python et mot de passe PostgreSQL.
3. Lecture des chemins généraux depuis `install_softwares.ini`.
4. Vérifications anti-écrasement (répertoire projet et utilisateur PostgreSQL).
5. Création des répertoires `frontend` et `backend`.
6. Initialisation d'un projet npm avec Express dans `frontend`.
7. Création d'un environnement Conda avec la version Python demandée dans `backend`.
8. Création de l'utilisateur et de la base de données PostgreSQL.
9. Création de liens symboliques vers tous les scripts du kit de développement.
10. Copie et personnalisation des fichiers `nginx.conf`, `project.ini` et `.gitignore`.
11. Ajout des informations de connexion PostgreSQL dans `project.ini`.
12. Exécution du script `github_create_or_clone.sh` pour initialiser le dépôt GitHub.
13. Vérifications finales des environnements npm, Conda et PostgreSQL.
14. Affichage d'un récapitulatif final et attribution complète des droits à l'utilisateur réel.

# Liste des fonctions internes

| Fonction           | Rôle                                                                 |
|--------------------|----------------------------------------------------------------------|
| info()             | Affiche un message informatif avec préfixe [INFO]                    |
| success()          | Affiche un message de succès avec préfixe [OK]                       |
| error()            | Affiche un message d'erreur avec préfixe [ERREUR] et termine le script|
| to_lowercase()     | Convertit une chaîne en minuscules                                   |
| get_config_value() | Lit une valeur depuis le fichier .ini et substitue $USER             |
| create_symlink()   | Crée un lien symbolique en gérant les cas existants                  |
| project_config()   | Boucle interactive de configuration et validation                    |

# Prérequis

- Exécuter le script avec `sudo`.
- `crudini` installé pour lire les fichiers .ini.
- Miniconda installé au chemin indiqué dans `install_softwares.ini`.
- PostgreSQL installé et service actif.
- Accès GitHub configuré pour l'utilisateur réel (clé SSH ou token).

# Utilisation

```bash
sudo chmod +x create_project.sh
sudo ./create_project.sh