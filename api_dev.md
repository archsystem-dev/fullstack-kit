# api_dev.sh
___

## Objectif du script
Arrête un éventuel serveur Uvicorn existant et lance Uvicorn en mode développement (--reload) pour le backend FastAPI, en utilisant l'environnement Conda dédié et en tant qu'utilisateur réel.

## Ce que fait le script étape par étape
1. Active les options strictes Bash (`set -euo pipefail`) et définit les séparateurs IFS pour une gestion sécurisée des espaces.
2. Définit les fonctions utilitaires `info`, `success` et `error` pour un affichage standardisé.
3. Détermine les chemins absolus nécessaires (répertoire du script, backend, installation Miniconda de l'utilisateur réel).
4. Affiche un titre clair de lancement.
5. Charge les fonctions Conda et active l'environnement dédié situé dans `backend/conda`.
6. Recherche et arrête gracieusement tout processus Uvicorn existant.
7. Se positionne dans le répertoire backend et lance Uvicorn avec les options de développement (--reload, écoute sur 0.0.0.0:8000).
8. À la fin (ou en cas d'interruption manuelle), affiche un message de succès avec l'URL d'accès.

## Liste des fonctions internes

| Fonction  | Rôle                                                                 |
|-----------|----------------------------------------------------------------------|
| `info`    | Affiche un message informatif avec le préfixe [INFO]                 |
| `success` | Affiche un message de succès avec le préfixe [OK]                    |
| `error`   | Affiche un message d'erreur avec [ERREUR] et termine le script       |

## Prérequis clairs
- Miniconda installé dans `~/Softwares/miniconda3` pour l'utilisateur réel.
- Un environnement Conda nommé ou situé dans `backend/conda`.
- Le module FastAPI avec Uvicorn installé dans cet environnement.
- Un fichier `main.py` contenant l'application FastAPI (objet `app`) dans le répertoire `backend`.
- Le script doit être exécuté depuis le répertoire racine du projet (où se trouve le dossier `backend`).

## Utilisation précise
```bash
chmod +x api_dev.sh   # une seule fois, pour rendre le script exécutable
./api_dev.sh