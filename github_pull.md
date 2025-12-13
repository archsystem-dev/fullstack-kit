------------------------------------------------------------------------------
Nom du script       : github_pull.sh
Version             : 1.0.0
Auteur              : archsystem-dev
Date de modification: 13 décembre 2025
Description         : Met à jour les fichiers locaux depuis le dépôt GitHub distant
                      en préservant les fichiers non versionnés et en gérant
                      automatiquement les modifications locales via stash.
------------------------------------------------------------------------------

## Objectif du script

Synchroniser le projet local avec la branche par défaut du dépôt GitHub distant de manière sécurisée, sans supprimer les fichiers non versionnés et en préservant/restaurant les modifications locales.

## Ce que fait le script étape par étape

1. Vérifie l'environnement (sudo ou non) et récupère les chemins absolus.
2. Demande confirmation à l'utilisateur avant toute opération.
3. Lit les paramètres GitHub depuis `project.ini` (user, token obligatoires ; name/email optionnels).
4. Configure l'identité Git locale.
5. Vérifie la présence d'un dépôt Git et configure le remote origin avec authentification.
6. Détecte automatiquement la branche par défaut distante.
7. Stash automatiquement les modifications locales si présentes.
8. Passe sur la branche distante, fetch et reset --hard pour synchroniser.
9. Met à jour les submodules éventuels.
10. Restaure les modifications locales (stash pop) et signale les conflits éventuels.
11. Affiche un récapitulatif final de succès.

## Liste des fonctions internes

| Fonction            | Rôle                                                                 |
|---------------------|----------------------------------------------------------------------|
| info()              | Affiche un message informatif avec préfixe [INFO]                    |
| success()           | Affiche un message de succès avec préfixe [OK]                       |
| error()             | Affiche un message d'erreur avec préfixe [ERREUR] et quitte le script|
| to_lowercase()      | Convertit une chaîne en minuscules                                   |
| get_config_value()  | Lit une valeur dans la section [Github] de project.ini               |
| confirm_pull()      | Demande confirmation interactive à l'utilisateur                    |

## Prérequis clairs

- Fichier `project.ini` présent dans le dossier projet avec section `[Github]` contenant au minimum `user` et `token`
- Dépôt Git local déjà initialisé (`.git` présent)
- Token GitHub avec permissions de lecture sur le dépôt
- Commandes `git` et `crudini` disponibles

## Utilisation précise

```bash
chmod +x github_pull.sh
./github_pull.sh