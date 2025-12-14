# github_pull.sh
___

## Objectif du script
Met à jour les fichiers locaux depuis le dépôt GitHub distant en préservant les fichiers non versionnés et en gérant automatiquement les modifications locales via stash.

## Ce que fait le script étape par étape
1. Vérifie qu'il n'est pas exécuté en root (opérations Git en utilisateur standard).
2. Convertit les réponses utilisateur en minuscules de façon portable.
3. Lit les paramètres GitHub depuis `project.ini` avec valeurs par défaut pour name/email.
4. Demande une confirmation interactive avant toute modification.
5. Charge les credentials GitHub et configure l'identité Git.
6. Vérifie la présence d'un dépôt local et configure le remote origin avec token.
7. Détecte automatiquement la branche par défaut distante.
8. Stash automatiquement les modifications locales si présentes.
9. Synchronise forcée avec la branche distante (reset --hard) et met à jour les submodules.
10. Restaure les modifications locales via stash pop (gère les conflits).
11. Affiche un récapitulatif final détaillé de la mise à jour.

## Liste des fonctions internes

| Fonction         | Rôle                                                                 |
|------------------|----------------------------------------------------------------------|
| `info`           | Affiche un message informatif précédé de [INFO]                      |
| `success`        | Affiche un message de succès précédé de [OK]                         |
| `error`          | Affiche un message d'erreur précédé de [ERREUR] et quitte le script  |
| `to_lowercase`   | Convertit une chaîne en minuscules de façon portable                 |
| `get_config_value`| Lit une valeur dans project.ini avec fallback sur default si fourni |
| `confirm_pull`   | Demande confirmation interactive oui/non avant la mise à jour       |

## Prérequis clairs
- Exécution en utilisateur standard (pas de sudo/root).
- `crudini` installé pour lire les fichiers .ini.
- Fichier `project.ini` présent dans le répertoire du projet avec section `[Github]` contenant au minimum `user` et `token`.
- Dépôt Git local initialisé et lié à un dépôt distant GitHub.
- Accès internet et token GitHub valide avec droits de lecture.

## Utilisation précise
```bash
chmod +x github_pull.sh   # une seule fois
cd /chemin/vers/votre/projet
./github_pull.sh