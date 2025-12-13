# Kit de Développement Full-Stack

Ce kit fournit un ensemble complet de scripts Bash pour créer, configurer, développer et déployer des projets web full-stack :
- **Backend** : FastAPI (Python) dans un environnement Conda dédié
- **Frontend** : Application moderne (Vue.js/Vite, React, etc.) gérée via npm
- **Base de données** : PostgreSQL dédiée par projet
- **Cache** : Redis
- **Serveur web** : Nginx (proxy reverse + service des fichiers statiques)
- **Contrôle de version** : Git + GitHub (création ou clonage automatique)

Tout est conçu pour être homogène, sécurisé et accessible aux néophytes tout en restant professionnel.

## Prérequis système

- Ubuntu/Debian (testé sur Ubuntu 22.04/24.04)
- Accès root/sudo
- Connexion internet (installation des paquets)
- Un compte GitHub avec un **Personal Access Token** (scopes : `repo`)

## Installation initiale

1. Placez tous les scripts dans un dossier dédié (ex: `~/archsystem-kit/`).
2. Préparez le fichier `install_softwares.ini` (modèle fourni, adaptez les chemins et mots de passe).
3. Exécutez l’installation globale une seule fois :

```bash
sudo chmod +x install_softwares.sh
sudo ./install_softwares.sh
```

Ce script installe et configure :
- Miniconda
- PostgreSQL
- Redis
- Nginx
- Node.js/npm (version spécifiée)
- Création du dossier projets

## Création d’un nouveau projet

```bash
sudo chmod +x create_project.sh
sudo ./create_project.sh
```

Le script vous guide interactivement :
- Nom du projet (minuscules)
- Version Python souhaitée
- Mot de passe PostgreSQL
→ Crée les dossiers, environnements, base de données, dépôt GitHub, liens symboliques vers tous les scripts utilitaires.

## Scripts utilitaires disponibles dans chaque projet

Tous les scripts suivants sont liés symboliquement dans le dossier du projet.

| Script                     | Description                                                                 | Utilisation typique                          |
|----------------------------|-----------------------------------------------------------------------------|----------------------------------------------|
| `api_dev.sh`               | Lance le backend FastAPI en mode développement (--reload)                   | `./api_dev.sh` (ou via `launch_dev.sh`)      |
| `npm_dev.sh`               | Arrête les processus frontend existants et lance `npm run dev`              | `./npm_dev.sh` (ou via `launch_dev.sh`)      |
| `launch_dev.sh`            | Ouvre deux terminaux : un pour le backend, un pour le frontend (dev)        | `./launch_dev.sh`                            |
| `npm_dist_generate.sh`     | Génère la distribution de production du frontend (`npm run build`)          | `./npm_dist_generate.sh`                     |
| `api_start.sh`             | Démarre le serveur Uvicorn en mode production                               | `sudo ./api_start.sh`                        |
| `api_stop.sh`              | Arrête Uvicorn et redémarre Nginx                                           | `sudo ./api_stop.sh`                         |
| `nginx_reload.sh`          | Applique la configuration Nginx du projet                                   | `sudo ./nginx_reload.sh`                     |
| `launch_test_prod.sh`      | Séquence complète pour déployer en production (build + start + reload)      | `./launch_test_prod.sh`                      |
| `install_packages.sh`      | Installe/maj les dépendances Python (requirements.txt) et npm               | `./install_packages.sh`                      |
| `github_create_or_clone.sh`| Crée ou clone le dépôt GitHub (appelé automatiquement par create_project)  | Rarement manuel                              |
| `github_pull.sh`           | Synchronise le projet local avec le dépôt distant (préserve modifications) | `./github_pull.sh`                           |
| `github_push.sh`           | Commit et push les modifications locales vers GitHub                        | `./github_push.sh [message]`                 |

## Flux de travail recommandé

### Développement quotidien
```bash
./launch_dev.sh
```
→ Deux terminaux s’ouvrent avec rechargement automatique.

### Déploiement en test/production
```bash
./npm_dist_generate.sh      # Génère dist/
./launch_test_prod.sh       # Build + start backend + reload Nginx
```

### Mise à jour du code depuis GitHub
```bash
./github_pull.sh
```

### Envoi de vos modifications
```bash
./github_push.sh "Description des changements"
```

## Structure d’un projet créé

```
monprojet/
├── backend/
│   └── conda/              → Environnement Conda dédié
├── frontend/
│   ├── dist/               → Fichiers statiques de production
│   └── node_modules/
├── project.ini             → Configuration projet (PostgreSQL, GitHub, etc.)
├── nginx.conf              → Configuration Nginx spécifique
└── *.sh                    → Tous les scripts utilitaires (liens symboliques)
```

## Personnalisation

- Modifiez `project.ini` pour les credentials GitHub et PostgreSQL.
- Adaptez `nginx.conf` pour vos routes, SSL, etc.
- Ajoutez vos dépendances dans `backend/requirements.txt` et `frontend/package.json`.
