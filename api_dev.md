------------------------------------------------------------------------------
Nom du script       : api_dev.sh
Version             : 1.0.0
Auteur              : archsystem-dev
Date de modification: 13 décembre 2025
Description         : Arrête un éventuel serveur Uvicorn existant et lance
                      Uvicorn en mode développement (--reload) pour le backend
                      FastAPI, en tant qu'utilisateur réel.
------------------------------------------------------------------------------

## Objectif du script

Lancer le serveur backend FastAPI en mode développement avec rechargement automatique (--reload) pour faciliter le développement et le débogage.

## Ce que fait le script étape par étape

1. Vérifie que le script est exécuté avec sudo et récupère l'utilisateur réel.
2. Récupère les chemins absolus du script et du dossier backend.
3. Arrête tout processus Uvicorn existant (si présent).
4. Lance Uvicorn en mode développement :
   - En tant qu'utilisateur réel (via sudo -u)
   - Avec activation de l'environnement Conda dédié
   - Sur le port 8000, accessible depuis l'extérieur (--host 0.0.0.0)
   - Avec rechargement automatique sur modification des fichiers backend
5. Le script reste au premier plan tant que Uvicorn tourne (mode interactif).

## Liste des fonctions internes

| Fonction            | Rôle                                                                 |
|---------------------|----------------------------------------------------------------------|
| info()              | Affiche un message informatif avec préfixe [INFO]                    |
| success()           | Affiche un message de succès avec préfixe [OK]                       |
| error()             | Affiche un message d'erreur avec préfixe [ERREUR] et quitte le script|

## Prérequis clairs

- Exécution avec `sudo`
- Miniconda installé dans `/home/$USER/Softwares/miniconda3`
- Environnement Conda créé dans `backend/conda`
- Fichier `main.py` contenant l'application FastAPI (variable `app`)
- Uvicorn installé dans l'environnement Conda
- Le script doit rester au premier plan pendant le développement

## Utilisation précise

```bash
sudo chmod +x api_dev.sh
sudo ./api_dev.sh