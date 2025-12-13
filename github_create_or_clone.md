------------------------------------------------------------------------------
Nom du script       : github_create_or_clone.sh
Version             : 1.0.0
Auteur              : archsystem-dev
Date de modification: 13 décembre 2025
Description         : Crée un dépôt privé GitHub si inexistant ou clone le dépôt
                      existant, initialise Git localement et effectue le premier
                      push avec les identifiants configurés dans project.ini.
------------------------------------------------------------------------------

# Objectif du script

Ce script automatise la création ou le clonage d'un dépôt GitHub privé pour un projet, en utilisant les identifiants stockés dans `project.ini`. Il initialise le dépôt local et effectue le premier push si nécessaire.

# Étapes réalisées par le script

1. Vérification des arguments et résolution des chemins absolus.
2. Création des répertoires nécessaires si absents.
3. Lecture des paramètres GitHub depuis `project.ini`.
4. Vérification de l'existence du dépôt distant via l'API GitHub.
5. Si le dépôt existe : clonage sécurisé dans le répertoire du projet.
6. Si le dépôt n'existe pas :
   - Copie des templates `backend` et `frontend`.
   - Création du dépôt privé sur GitHub.
   - Initialisation Git locale, configuration de l'identité, commit initial et push.
7. Affichage d'un récapitulatif final clair.

# Fonctions internes

| Fonction            | Rôle                                                                 |
|---------------------|----------------------------------------------------------------------|
| info()              | Affiche un message informatif avec préfixe [INFO]                    |
| success()           | Affiche un message de succès avec préfixe [OK]                       |
| error()             | Affiche un message d'erreur avec préfixe [ERREUR] et quitte le script|
| get_config_value()  | Lit une valeur dans project.ini et remplace $USER par l'utilisateur réel |

# Prérequis

- `crudini` installé pour lire les fichiers INI.
- `git` installé et configuré.
- `curl` disponible pour interagir avec l'API GitHub.
- Un fichier `project.ini` valide dans le répertoire du projet contenant les sections et clés Github (user, token, name, email).
- Les dossiers `backend` et `frontend` présents dans le répertoire des scripts (pour les nouveaux projets).

# Utilisation

```bash
chmod +x github_create_or_clone.sh
./github_create_or_clone.sh <SCRIPT_DIR> <PROJECT_DIR>