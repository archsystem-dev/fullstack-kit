# Fullstack Kit – FastAPI + Vue.js (ou React/Vite) + PostgreSQL + Redis + Nginx

Kit de développement et de déploiement complet pour applications web full-stack modernes, conçu pour être simple, reproductible et sécurisé.

Ce projet fournit une structure prête à l'emploi avec :
- **Backend** : FastAPI (Python) dans un environnement Conda dédié
- **Frontend** : Vue.js, React ou Vite (via npm)
- **Base de données** : PostgreSQL
- **Cache / sessions** : Redis
- **Reverse proxy** : Nginx
- **Gestion GitHub** : Création/clonage automatique de dépôt, push/pull

Tous les outils sont installés et configurés automatiquement via des scripts Bash.

## Structure du projet

Après création d’un nouveau projet avec `create_project.sh` :

```
mon_projet/
│
├── backend/
│   ├── conda/              # Environnement Conda dédié
│   ├── main.py             # Application FastAPI
│   └── requirements.txt
│
├── frontend/
│   ├── src/
│   ├── dist/               # Généré par npm run build
│   ├── package.json
│   └── App.vue
│
├── project.ini             # Généré lors du create_project.sh
├── nginx.conf              # Configuration NGNIX chargé par defaut
├── .gitignore
│
├── api_dev.sh
├── api_start.sh
├── api_stop.sh
│
├── github_create_or_clone.sh
├── github_push.sh
├── github_pull.sh
│
├── launch_dev.sh
├── launch_test_prod.sh
│
├── install_packages.sh
├── nginx_reload.sh

├── npm_dev.sh
└── npm_dist_generate.sh
```

## Prérequis système

- Ubuntu / Debian (testé sur Ubuntu 24.04+)
- Accès root (sudo)
- Connexion internet

## Installation initiale du kit (une seule fois)

```bash
# Cloner le kit
git clone https://github.com/votre-user/fullstack-kit.git
cd fullstack-kit

# Rendre les scripts exécutables
chmod +x *.sh

# Installer tous les logiciels nécessaires (Miniconda, PostgreSQL, Redis, Nginx, Node.js…)
sudo ./install_softwares.sh
```

Le script demande confirmation à chaque étape critique et nettoie les installations précédentes.

## Création d’un nouveau projet

Remplir le fichier project.ini avec vos paramètres GITHUB.

```bash
# Depuis le répertoire du kit
sudo ./create_project.sh
```

Le script interactif vous demande :
- Nom du projet (en minuscules)
- Version Python souhaitée
- Mot de passe PostgreSQL

Il crée automatiquement :
- Le répertoire projet dans le dossier configuré dans `install_softwares.ini`
- Les environnements Conda et npm
- L’utilisateur et la base PostgreSQL
- Le dépôt GitHub privé (ou clone si existant)
- Les liens symboliques vers tous les scripts du kit

## Utilisation quotidienne

### Développement (hot-reload)

```bash
cd /chemin/vers/votre/projet
./launch_dev.sh
```

→ Ouvre deux terminaux :
- Backend FastAPI avec `--reload` (port 8000)
- Frontend avec `npm run dev`

### Déploiement test / production

```bash
cd /chemin/vers/votre/projet
./launch_test_prod.sh
```

Étapes effectuées :
1. Génère la distribution frontend (`npm run build`)
2. Démarre Uvicorn en arrière-plan
3. Recharge Nginx avec la configuration du projet

L’application est alors accessible via le port configuré dans `nginx.conf` (généralement 80 ou 443).

### Gestion GitHub

```bash
# Mettre à jour le code local depuis GitHub
./github_pull.sh

# Committer et pousser les modifications
./github_push.sh "Message de commit descriptif"
```

### Arrêt propre

```bash
sudo ./api_stop.sh
```

Arrête Uvicorn et recharge Nginx (utile pour page de maintenance).

## Scripts principaux

| Script                     | Rôle principal |
|----------------------------|--------------------------------------------------------------|
| `create_project.sh`        | Crée un nouveau projet complet |
| `install_softwares.sh`     | Installe tous les logiciels système (une fois) |
| `launch_dev.sh`            | Mode développement (2 terminaux) |
| `launch_test_prod.sh`      | Déploiement production |
| `api_dev.sh`               | Backend dev avec reload |
| `api_start.sh`             | Backend production |
| `api_stop.sh`              | Arrêt propre du backend |
| `npm_dev.sh`               | Frontend dev server |
| `npm_dist_generate.sh`     | Génère la build production |
| `github_pull.sh`           | Pull + rebase + stash intelligent |
| `github_push.sh`           | Commit + push avec synchronisation |
| `nginx_reload.sh`          | Applique nginx.conf du projet |

## Configuration

- `install_softwares.ini` : paramètres globaux (chemins, ports, mots de passe…)
- `project.ini` (créé automatiquement) : token GitHub, credentials PostgreSQL…

## Contribution & Personnalisation

Le kit est conçu pour être étendu :
- Ajouter des paquets dans `requirements.txt`
- Modifier `nginx.conf` pour HTTPS, domaines, etc.
- Adapter les scripts pour d’autres stacks (Next.js, Nuxt…)

## Licence

MIT – Libre d’utilisation, modification et redistribution.