# github_create_or_clone.sh
___

## Objectif du script
Crée un dépôt privé GitHub si inexistant ou clone le dépôt existant, initialise Git localement et effectue le premier push avec les identifiants configurés dans project.ini.

## Ce que fait le script étape par étape
1. Vérifie qu'il n'est pas exécuté en root (opérations Git en utilisateur standard).
2. Détermine les répertoires des scripts et du projet (via arguments ou répertoire courant).
3. Affiche et demande confirmation des répertoires choisis.
4. Extrait le nom du projet et vérifie la présence de `project.ini`.
5. Charge les paramètres GitHub (user, token, name, email) depuis `project.ini`.
6. Vérifie l'existence du dépôt distant via l'API GitHub.
7. Si existant : clone uniquement le répertoire `.git` pour synchroniser.
8. Si inexistant : copie les templates backend/frontend (sauf pour le kit), crée le dépôt privé distant, initialise Git localement, configure les identités, ajoute le remote, effectue le commit initial et le premier push.
9. Affiche un récapitulatif final avec les informations du dépôt configuré.

## Liste des fonctions internes

| Fonction           | Rôle                                                                 |
|--------------------|----------------------------------------------------------------------|
| `info`             | Affiche un message informatif précédé de [INFO]                      |
| `success`          | Affiche un message de succès précédé de [OK]                         |
| `error`            | Affiche un message d'erreur précédé de [ERREUR] et quitte le script  |
| `get_config_value` | Lit une valeur dans un fichier .ini via crudini et substitue $USER   |

## Prérequis clairs
- Exécution en utilisateur standard (pas de sudo/root).
- `crudini` installé pour lire les fichiers .ini.
- Fichier `project.ini` présent dans le répertoire du projet avec une section `[Github]` contenant les clés `user`, `token`, `name` et `email`.
- Accès internet et token GitHub valide avec droits de création de dépôts.
- Pour la création : templates `backend/` et `frontend/` présents dans le répertoire des scripts (sauf si projet nommé "fullstack-kit").
- Git installé et configuré.

## Utilisation précise
```bash
chmod +x github_create_or_clone.sh   # une seule fois
./github_create_or_clone.sh [chemin_vers_kit] [chemin_vers_projet]
# ou sans arguments : utilise le répertoire courant