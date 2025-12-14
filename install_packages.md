# install_packages.sh
___

## Objectif du script
Installe les dépendances Python (via pip dans l'environnement Conda dédié) et Node.js (via npm) pour le backend et le frontend du projet, en respectant les fichiers requirements.txt et package.json.

## Ce que fait le script étape par étape
1. Vérifie qu'il n'est pas exécuté en root (opérations en utilisateur standard).
2. Définit les chemins absolus vers les dossiers backend, frontend et l'environnement Conda.
3. Vérifie la présence des dossiers et de l'environnement Conda.
4. Active l'environnement Conda dédié au backend.
5. Installe ou met à jour les dépendances Python à partir de requirements.txt.
6. Se positionne dans le frontend et installe les dépendances npm de manière adaptée (npm ci si package-lock.json présent, sinon npm install).
7. Génère un package-lock.json si absent pour assurer la reproductibilité future.
8. Affiche un récapitulatif final de succès avec les statuts des installations.

## Liste des fonctions internes

| Fonction  | Rôle                                                                 |
|-----------|----------------------------------------------------------------------|
| `info`    | Affiche un message informatif précédé de [INFO]                      |
| `success` | Affiche un message de succès précédé de [OK]                         |
| `error`   | Affiche un message d'erreur précédé de [ERREUR] et quitte le script  |

## Prérequis clairs
- Exécution en utilisateur standard (pas de sudo/root).
- Miniconda installé et accessible (commande `conda` disponible).
- Structure du projet présente : dossiers `backend/` et `frontend/`, environnement Conda dans `backend/conda`.
- Fichiers `backend/requirements.txt` et `frontend/package.json` présents.
- Node.js et npm installés sur la machine.

## Utilisation précise
```bash
chmod +x install_packages.sh   # une seule fois
cd /chemin/vers/votre/projet
./install_packages.sh