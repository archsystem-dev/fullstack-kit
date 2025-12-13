------------------------------------------------------------------------------
Nom du script       : launch_test_prod.sh
Version             : 1.0.0
Auteur              : archsystem-dev
Date de modification: 13 décembre 2025
Description         : Génère la distribution frontend, démarre le serveur backend
                      FastAPI en mode production et recharge Nginx pour déployer
                      l'application en environnement de test/production.
------------------------------------------------------------------------------

## Objectif du script

Préparer et lancer l'application en mode production : générer les fichiers statiques du frontend, démarrer le serveur backend Uvicorn et recharger Nginx pour servir l'application.

## Ce que fait le script étape par étape

1. Récupère les chemins absolus du script et du dossier projet.
2. Vérifie la présence des scripts nécessaires (`npm_dist_generate.sh`, `api_start.sh`, `nginx_reload.sh`).
3. Exécute `npm_dist_generate.sh` pour générer la distribution frontend (npm run build).
4. Exécute `api_start.sh` avec sudo pour démarrer le serveur backend en mode production.
5. Exécute `nginx_reload.sh` avec sudo pour recharger la configuration Nginx.
6. Affiche un récapitulatif final de succès.

## Liste des fonctions internes

| Fonction            | Rôle                                                                 |
|---------------------|----------------------------------------------------------------------|
| info()              | Affiche un message informatif avec préfixe [INFO]                    |
| success()           | Affiche un message de succès avec préfixe [OK]                       |
| error()             | Affiche un message d'erreur avec préfixe [ERREUR] et quitte le script|

## Prérequis clairs

- Les scripts `npm_dist_generate.sh`, `api_start.sh` et `nginx_reload.sh` présents dans le dossier projet
- Privilèges sudo pour `api_start.sh` et `nginx_reload.sh`
- Configuration npm avec un script "build" défini dans package.json
- Nginx configuré pour servir les fichiers statiques du frontend

## Utilisation précise

```bash
chmod +x launch_test_prod.sh
./launch_test_prod.sh