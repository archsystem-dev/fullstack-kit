------------------------------------------------------------------------------
Nom du script       : github_push.sh
Version             : 1.0.0
Auteur              : archsystem-dev
Date de modification: 13 décembre 2025
Description         : Commit et push les modifications locales vers le dépôt
                      GitHub distant avec synchronisation préalable (pull rebase),
                      gestion automatique des stash et message de commit personnalisable.
------------------------------------------------------------------------------

## Objectif du script

Pousser proprement les modifications locales vers le dépôt GitHub distant en synchronisant d'abord (pull --rebase), en gérant les conflits potentiels et en committant avec un message clair.

## Ce que fait le script étape par étape

1. Vérifie l'environnement et récupère les chemins absolus.
2. Demande confirmation à l'utilisateur avant toute opération.
3. Lit les paramètres GitHub depuis `project.ini` (user, token obligatoires ; name/email optionnels).
4. Configure l'identité Git locale.
5. Vérifie la présence d'un dépôt Git et configure le remote origin.
6. Détecte automatiquement la branche par défaut distante.
7. Stash automatiquement les modifications locales si présentes.
8. Effectue un pull --rebase pour synchroniser avec le distant.
9. Restaure les modifications locales (stash pop) et gère les conflits.
10. Ajoute tous les fichiers, commit si changements (avec message personnalisable).
11. Push vers la branche distante.
12. Affiche un récapitulatif final de succès.

## Liste des fonctions internes

| Fonction            | Rôle                                                                 |
|---------------------|----------------------------------------------------------------------|
| info()              | Affiche un message informatif avec préfixe [INFO]                    |
| success()           | Affiche un message de succès avec préfixe [OK]                       |
| error()             | Affiche un message d'erreur avec préfixe [ERREUR] et quitte le script|
| to_lowercase()      | Convertit une chaîne en minuscules                                   |
| get_config_value()  | Lit une valeur dans la section [Github] de project.ini               |
| confirm_push()      | Demande confirmation interactive à l'utilisateur                    |

## Prérequis clairs

- Fichier `project.ini` présent dans le dossier projet avec section `[Github]` contenant au minimum `user` et `token`
- Dépôt Git local déjà initialisé et synchronisé
- Token GitHub avec permissions d'écriture sur le dépôt
- Commandes `git` et `crudini` disponibles

## Utilisation précise

```bash
chmod +x github_push.sh
./github_push.sh [message_de_commit_optionnel]