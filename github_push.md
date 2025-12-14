# github_push.sh

## Objectif du script
Commit et push les modifications locales vers le dépôt GitHub distant avec synchronisation préalable (pull rebase), gestion automatique des stash et message de commit personnalisable.

## Ce que fait le script étape par étape
1. Vérifie qu'il n'est pas exécuté en root (opérations Git en utilisateur standard).
2. Convertit les réponses utilisateur en minuscules de façon portable.
3. Lit les paramètres GitHub depuis `project.ini` avec valeurs par défaut pour name/email.
4. Demande une confirmation interactive avant toute opération.
5. Charge les credentials GitHub et configure l'identité Git.
6. Vérifie la présence d'un dépôt local et configure le remote origin avec token.
7. Détecte automatiquement la branche par défaut distante.
8. Stash automatiquement les modifications locales si présentes.
9. Effectue un pull --rebase pour synchroniser avec le distant.
10. Restaure les modifications locales via stash pop (arrête en cas de conflit).
11. Ajoute tous les changements, commit avec message personnalisé (ou défaut).
12. Effectue le push vers la branche distante.
13. Affiche un récapitulatif final détaillé (ou message si rien à pousser).

## Liste des fonctions internes

| Fonction         | Rôle                                                                 |
|------------------|----------------------------------------------------------------------|
| `info`           | Affiche un message informatif précédé de [INFO]                      |
| `success`        | Affiche un message de succès précédé de [OK]                         |
| `error`          | Affiche un message d'erreur précédé de [ERREUR] et quitte le script  |
| `to_lowercase`   | Convertit une chaîne en minuscules de façon portable                 |
| `get_config_value`| Lit une valeur dans project.ini avec fallback sur default si fourni |
| `confirm_push`   | Demande confirmation interactive oui/non avant le push              |

## Prérequis clairs
- Exécution en utilisateur standard (pas de sudo/root).
- `crudini` installé pour lire les fichiers .ini.
- Fichier `project.ini` présent dans le répertoire du projet avec section `[Github]` contenant au minimum `user` et `token`.
- Dépôt Git local initialisé et lié à un dépôt distant GitHub.
- Accès internet et token GitHub valide avec droits d'écriture.

## Utilisation précise
```bash
chmod +x github_push.sh   # une seule fois
cd /chemin/vers/votre/projet
./github_push.sh [message_de_commit_optionnel]