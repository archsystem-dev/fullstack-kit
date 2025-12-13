------------------------------------------------------------------------------
Nom du script       : api_stop.sh
Version             : 1.0.0
Auteur              : archsystem-dev
Date de modification: 13 décembre 2025
Description         : Arrête proprement le serveur Uvicorn du backend et
                      redémarre Nginx pour appliquer les changements.
------------------------------------------------------------------------------

## Objectif du script

Arrêter le serveur Uvicorn du backend FastAPI et redémarrer Nginx pour libérer le port et appliquer les configurations mises à jour.

## Ce que fait le script étape par étape

1. Vérifie que le script est exécuté avec sudo et récupère l'utilisateur réel.
2. Récupère les chemins absolus du script et du dossier backend.
3. Active l'environnement Conda dédié au backend.
4. Arrête tous les processus Uvicorn en cours d'exécution.
5. Attend 2 secondes pour laisser le temps au processus de se terminer.
6. Redémarre le service Nginx.
7. Effectue des vérifications finales (Uvicorn arrêté, Nginx actif).
8. Affiche un message récapitulatif de succès avec un test curl.

## Liste des fonctions internes

| Fonction            | Rôle                                                                 |
|---------------------|----------------------------------------------------------------------|
| info()              | Affiche un message informatif avec préfixe [INFO]                    |
| success()           | Affiche un message de succès avec préfixe [OK]                       |
| error()             | Affiche un message d'erreur avec préfixe [ERREUR] et quitte le script|

## Prérequis clairs

- Exécution avec `sudo`
- Nginx installé et configuré comme service systemd
- Miniconda installé dans `/home/$USER/Softwares/miniconda3`
- Environnement Conda créé dans `backend/conda`
- Uvicorn installé dans l'environnement Conda

## Utilisation précise

```bash
sudo chmod +x api_stop.sh
sudo ./api_stop.sh