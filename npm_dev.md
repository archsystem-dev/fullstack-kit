------------------------------------------------------------------------------
Nom du script       : npm_dev.sh
Version             : 1.0.0
Auteur              : archsystem-dev
Date de modification: 13 décembre 2025
Description         : Arrête les processus Node.js/npm existants liés au serveur
                      de développement et lance npm run dev dans le dossier frontend.
------------------------------------------------------------------------------

## Objectif du script

Lancer le serveur de développement frontend (Vue.js/Vite, React, Next.js, etc.) en mode interactif avec rechargement automatique, après avoir arrêté toute instance précédente.

## Ce que fait le script étape par étape

1. Récupère les chemins absolus du script et du dossier frontend.
2. Vérifie la présence du dossier frontend/.
3. Arrête les processus Node.js/npm existants correspondant à un serveur de développement.
4. Attend 2 secondes pour laisser les processus se terminer proprement.
5. Passe dans le dossier frontend et exécute npm run dev.
6. Le script reste au premier plan tant que le serveur de développement tourne (logs en temps réel).

## Liste des fonctions internes

| Fonction            | Rôle                                                                 |
|---------------------|----------------------------------------------------------------------|
| info()              | Affiche un message informatif avec préfixe [INFO]                    |
| success()           | Affiche un message de succès avec préfixe [OK]                       |
| error()             | Affiche un message d'erreur avec préfixe [ERREUR] et quitte le script|

## Prérequis clairs

- Dossier frontend/ présent avec un package.json valide
- Script "dev" défini dans package.json (ex: Vite, Vue CLI, Create React App, Next.js)
- npm et Node.js installés et accessibles
- Les dépendances npm déjà installées (via install_packages.sh)

## Utilisation précise

```bash
chmod +x npm_dev.sh
./npm_dev.sh