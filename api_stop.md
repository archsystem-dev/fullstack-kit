# api_stop.sh

## Objectif du script
Arrête proprement le serveur Uvicorn du backend FastAPI et redémarre Nginx pour appliquer les changements de configuration (par exemple, retour à une page de maintenance).

## Ce que fait le script étape par étape
1. Active les options strictes Bash et définit les séparateurs IFS sécurisés.
2. Définit les fonctions d'affichage standardisées `info`, `success` et `error`.
3. Vérifie que le script n'est pas exécuté en root (pour éviter des problèmes avec Conda).
4. Calcule les chemins absolus nécessaires (répertoire du script, backend, Miniconda).
5. Active l'environnement Conda dédié au projet backend.
6. Arrête gracieusement tout processus Uvicorn existant.
7. Redémarre le service système Nginx.
8. Effectue des vérifications : Uvicorn doit être injoignable, Nginx doit être actif.
9. Affiche un message récapitulatif de succès avec un test rapide montrant l'erreur de connexion.

## Liste des fonctions internes

| Fonction  | Rôle                                                                 |
|-----------|----------------------------------------------------------------------|
| `info`    | Affiche un message informatif précédé de [INFO]                      |
| `success` | Affiche un message de succès précédé de [OK]                         |
| `error`   | Affiche un message d'erreur précédé de [ERREUR] et quitte le script  |

## Prérequis clairs
- Miniconda installé dans `~/Softwares/miniconda3`.
- Un environnement Conda dédié situé dans `backend/conda`.
- FastAPI et Uvicorn installés dans cet environnement (nécessaire pour pkill précis).
- Nginx installé et configuré comme reverse proxy.
- Droits suffisants pour exécuter `systemctl restart nginx` (généralement via sudo, mais le script lui-même interdit l'exécution en root pour protéger Conda).
- Le script doit être exécuté depuis le répertoire racine du projet (où se trouve le dossier `backend`).

## Utilisation précise
```bash
chmod +x api_stop.sh    # une seule fois, pour rendre le script exécutable
./api_stop.sh           # exécuter en utilisateur standard
# Si nécessaire pour Nginx : sudo systemctl restart nginx séparément
# ou adapter le script pour gérer sudo uniquement sur cette commande