------------------------------------------------------------------------------
Nom du script       : install_packages.sh
Version             : 1.0.0
Auteur              : archsystem-dev
Date de modification: 13 décembre 2025
Description         : Installe les dépendances Python (via pip dans l'environnement
                      Conda dédié) et Node.js (via npm) pour le backend et le frontend
                      du projet, en respectant les fichiers requirements.txt et package.json.
------------------------------------------------------------------------------

## Objectif du script

Installer de manière fiable et reproductible toutes les dépendances nécessaires au projet (Python pour le backend FastAPI et Node.js pour le frontend Vue.js/Express).

## Ce que fait le script étape par étape

1. Récupère les chemins absolus et le nom du projet.
2. Vérifie la présence des dossiers backend/, frontend/ et de l'environnement Conda.
3. Active l'environnement Conda dédié au backend.
4. Installe ou met à jour les dépendances Python listées dans `backend/requirements.txt`.
5. Passe dans le dossier frontend et installe les dépendances npm :
   - Utilise `npm ci` si `package-lock.json` existe (installation reproductible).
   - Sinon utilise `npm install`.
   - Génère `package-lock.json` si absent pour les futures installations.
6. Affiche un récapitulatif final de succès.

## Liste des fonctions internes

| Fonction            | Rôle                                                                 |
|---------------------|----------------------------------------------------------------------|
| info()              | Affiche un message informatif avec préfixe [INFO]                    |
| success()           | Affiche un message de succès avec préfixe [OK]                       |
| error()             | Affiche un message d'erreur avec préfixe [ERREUR] et quitte le script|

## Prérequis clairs

- Environnement Conda créé dans `backend/conda` (via create_project.sh)
- Fichier `backend/requirements.txt` présent
- Fichier `frontend/package.json` présent
- Commandes `conda`, `pip` et `npm` disponibles dans le PATH
- Accès internet pour télécharger les packages

## Utilisation précise

```bash
chmod +x install_packages.sh
./install_packages.sh