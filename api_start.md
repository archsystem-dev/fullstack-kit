# api_start.sh

## Objectif du script
Arrête un éventuel serveur Uvicorn existant, démarre un nouveau serveur Uvicorn pour le backend FastAPI en arrière-plan et redémarre Nginx pour appliquer les changements de configuration.

## Ce que fait le script étape par étape
1. Active les options strictes Bash et définit les séparateurs IFS sécurisés.
2. Définit les fonctions d'affichage standardisées `info`, `success` et `error`.
3. Calcule les chemins absolus nécessaires (répertoire du script, backend, Miniconda).
4. Active l'environnement Conda dédié au projet backend.
5. Arrête gracieusement tout processus Uvicorn existant.
6. Démarre Uvicorn en arrière-plan sur le port 8000.
7. Redémarre le service système Nginx.
8. Effectue des vérifications de santé sur Uvicorn et Nginx.
9. Affiche un message récapitulatif de succès avec un test rapide de la réponse HTTP.

## Liste des fonctions internes

| Fonction  | Rôle                                                                 |
|-----------|----------------------------------------------------------------------|
| `info`    | Affiche un message informatif précédé de [INFO]                      |
| `success` | Affiche un message de succès précédé de [OK]                         |
| `error`   | Affiche un message d'erreur précédé de [ERREUR] et quitte le script  |

## Prérequis clairs
- Miniconda installé dans `~/Softwares/miniconda3`.
- Un environnement Conda dédié situé dans `backend/conda`.
- FastAPI et Uvicorn installés dans cet environnement.
- Fichier `main.py` contenant l'application FastAPI (objet `app`) dans le répertoire `backend`.
- Nginx installé et configuré comme reverse proxy vers `localhost:8000`.
- Droits suffisants pour exécuter `systemctl restart nginx` (généralement via sudo ou appartenance au groupe adéquat).
- Le script doit être exécuté depuis le répertoire racine du projet (où se trouve le dossier `backend`).

## Utilisation précise
```bash
chmod +x api_start.sh   # une seule fois, pour rendre le script exécutable
./api_start.sh          # ou sudo ./api_start.sh si nécessaire pour Nginx