------------------------------------------------------------------------------
Nom du script       : api_start.sh
Version             : 1.0.0
Auteur              : archsystem-dev
Date de modification: 13 décembre 2025
Description         : Arrête un éventuel serveur Uvicorn existant, démarre un
                      nouveau serveur Uvicorn pour le backend FastAPI et
                      redémarre Nginx pour appliquer les changements.
------------------------------------------------------------------------------

## Objectif du script

Démarrer proprement le serveur backend FastAPI avec Uvicorn (en arrêtant d'abord toute instance existante) et redémarrer Nginx pour que la configuration prenne effet.

## Ce que fait le script étape par étape

1. Vérifie que le script est exécuté avec sudo et récupère l'utilisateur réel.
2. Récupère les chemins absolus du script et du dossier backend.
3. Active l'environnement Conda dédié au backend.
4. Arrête tout processus Uvicorn existant (si présent).
5. Démarre une nouvelle instance de Uvicorn en arrière-plan sur le port 8000.
6. Attend 2 secondes pour laisser le serveur s'initialiser.
7. Redémarre le service Nginx.
8. Effectue des vérifications finales (Uvicorn répond, Nginx actif).
9. Affiche un message récapitulatif de succès avec un test curl.

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
- Fichier `main.py` contenant l'application FastAPI (variable `app`)
- Uvicorn installé dans l'environnement Conda

## Utilisation précise

```bash
sudo chmod +x api_start.sh
sudo ./api_start.sh