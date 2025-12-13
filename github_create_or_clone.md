# github_create_or_clone.sh

## Objectif du script
Crée un dépôt privé GitHub s'il n'existe pas ou clone le dépôt existant, initialise Git localement et effectue le premier push en utilisant les identifiants stockés dans `project.ini`.

## Ce que fait le script étape par étape
1. Détermine les répertoires des scripts et du projet (via arguments ou répertoire courant).
2. Demande confirmation des répertoires choisis à l'utilisateur.
3. Crée les répertoires si nécessaire et extrait le nom du projet.
4. Charge les paramètres GitHub (user, token, name, email) depuis `project.ini`.
5. Vérifie l'existence du dépôt distant sur GitHub.
6. Si le dépôt existe : le clone dans le répertoire projet.
7. Si le dépôt n'existe pas :
   - Copie les dossiers `backend` et `frontend` (sauf pour le kit de base).
   - Crée un dépôt privé sur GitHub.
   - Initialise Git localement, configure les identités, ajoute le remote et effectue le premier commit/push.
8. Affiche un récapitulatif final avec les informations du dépôt.

## Liste des fonctions internes

| Fonction          | Rôle                                                                 |
|-------------------|----------------------------------------------------------------------|
| info()            | Affiche un message informatif avec préfixe [INFO]                    |
| success()         | Affiche un message de succès avec préfixe [OK]                       |
| error()           | Affiche un message d'erreur avec préfixe [ERREUR] et arrête le script|
| get_config_value()| Lit une valeur depuis un fichier ini via crudini et gère les erreurs |

## Prérequis
- `crudini` installé sur le système.
- `git` installé et configuré.
- Fichier `project.ini` présent dans le répertoire projet avec la section `[Github]` contenant les clés `user`, `token`, `name`, `email`.
- Dossiers `backend` et `frontend` présents dans le répertoire des scripts (sauf pour le kit de base).

## Utilisation
```bash
chmod +x github_create_or_clone.sh
./github_create_or_clone.sh [chemin_scripts] [chemin_projet]