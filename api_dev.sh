#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Nom du script       : api_dev.sh
# Version             : 1.0.0
# Auteur              : archsystem-dev
# Date de modification: 14 décembre 2025
# Description         : Arrête un éventuel serveur Uvicorn existant et lance
#                       Uvicorn en mode développement (--reload) pour le backend
#                       FastAPI, en tant qu'utilisateur réel.
# ------------------------------------------------------------------------------

# Activation des options strictes pour une exécution robuste et sécurisée
# Pourquoi : arrête le script en cas d'erreur, variable non définie ou erreur
# dans un pipeline, rendant le comportement plus prévisible et sécurisé.
set -euo pipefail

# Définition des séparateurs internes de champs pour éviter les problèmes
# avec les espaces dans les noms de fichiers ou variables
# Pourquoi : limite les séparateurs à newline et tabulation, évitant les splits
# intempestifs sur les espaces dans les chemins ou noms.
IFS=$'\n\t'

# ------------------------------------------------------------------------------
# Fonctions utilitaires d'affichage standardisées
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Nom de la fonction   : info()
# Liste des Paramètres : "$@" (message à afficher)
# Description          : Affiche un message informatif précédé du préfixe [INFO]
#                       sur la sortie d'erreur standard pour ne pas polluer stdout.
# ------------------------------------------------------------------------------
info() {
    printf "[INFO]  %s\n" "$*" >&2
}

# ------------------------------------------------------------------------------
# Nom de la fonction   : success()
# Liste des Paramètres : "$@" (message à afficher)
# Description          : Affiche un message de succès précédé du préfixe [OK]
#                       sur la sortie d'erreur standard.
# ------------------------------------------------------------------------------
success() {
    printf "[OK]    %s\n" "$*" >&2
}

# ------------------------------------------------------------------------------
# Nom de la fonction   : error()
# Liste des Paramètres : "$@" (message d'erreur à afficher)
# Description          : Affiche un message d'erreur précédé de [ERREUR] et quitte
#                       le script avec un code d'erreur non nul pour signaler
#                       un problème critique.
# ------------------------------------------------------------------------------
error() {
    printf "[ERREUR] %s\n" "$*" >&2
    exit 1
}

# ------------------------------------------------------------------------------
# Chemins absolus et variables d'environnement
# ------------------------------------------------------------------------------

# Obtention du répertoire contenant le script (même si lancé depuis ailleurs)
# Pourquoi : permet d'avoir des chemins fiables indépendamment du cwd.
SCRIPT_DIR="$(realpath -m .)"

# Répertoire du backend FastAPI
# Pourquoi : centralise le chemin du projet backend pour réutilisation.
BACKEND_DIR="${SCRIPT_DIR}/backend"

# Chemin vers l'installation Miniconda de l'utilisateur réel
# Utilisation de SUDO_USER si le script est lancé avec sudo
# Pourquoi : garantit que l'environnement appartient bien à l'utilisateur réel
# même en cas d'exécution avec privilèges élevés.
REAL_USER="${SUDO_USER:-$USER}"
MINICONDA_PATH="/home/${REAL_USER}/Softwares/miniconda3"

# ------------------------------------------------------------------------------
# Affichage du titre principal
# ------------------------------------------------------------------------------

# Nettoyage de l'écran pour une présentation claire au démarrage
clear
echo ""
echo "════════════════════════════════════════════════════════════"
echo "                LANCEMENT DU SERVEUR FASTAPI                "
echo "════════════════════════════════════════════════════════════"
echo ""

# ------------------------------------------------------------------------------
# Activation de l'environnement Conda
# ------------------------------------------------------------------------------

# Information à l'utilisateur sur l'étape en cours
info "Activation de l'environnement Conda dédié au backend..."

# Chargement des fonctions Conda dans la session courante
# Nécessaire avant toute utilisation de la commande conda
# Pourquoi : sans cela, la commande "conda" n'est pas disponible dans le script.
source "${MINICONDA_PATH}/etc/profile.d/conda.sh" || \
    error "Impossible de charger les fonctions Conda (conda.sh introuvable)"

# Activation de l'environnement spécifique situé dans le répertoire backend
# Pourquoi : isole les dépendances du projet dans un env dédié.
conda activate "${BACKEND_DIR}/conda" || \
    error "Échec de l'activation de l'environnement Conda"

# Confirmation visuelle du succès de l'activation
success "Environnement Conda activé avec succès"

# ------------------------------------------------------------------------------
# Arrêt d'un serveur Uvicorn potentiellement en cours
# ------------------------------------------------------------------------------

# Information sur la recherche d'un processus existant
info "Recherche et arrêt d'un éventuel processus Uvicorn existant..."

# Tentative d'arrêt gracieux des processus correspondant à uvicorn
# Utilisation de -f pour matcher le motif dans la ligne de commande complète
# Redirection pour masquer la sortie standard de pkill
if pkill -f "uvicorn" > /dev/null 2>&1; then
    success "Ancien serveur Uvicorn arrêté correctement"
else
    info "Aucun processus Uvicorn détecté en cours d'exécution"
fi

# ------------------------------------------------------------------------------
# Lancement du serveur Uvicorn en mode développement
# ------------------------------------------------------------------------------

# Information sur le démarrage imminent
info "Lancement du serveur Uvicorn en mode développement (--reload)..."

# Positionnement dans le répertoire du backend pour un contexte correct
# Pourquoi : uvicorn a besoin d'être lancé depuis le répertoire contenant main.py
cd "${BACKEND_DIR}"

# Démarrage de Uvicorn avec rechargement automatique sur modification
# --host 0.0.0.0 rend le serveur accessible depuis l'extérieur de la machine
# --port 8000 définit le port d'écoute standard pour FastAPI
# --reload active le rechargement à chaud en développement
# --reload-dir limite la surveillance aux fichiers du backend uniquement
uvicorn main:app \
    --host 0.0.0.0 \
    --port 8000 \
    --reload \
    --reload-dir "${BACKEND_DIR}"

# ------------------------------------------------------------------------------
# Fin du script - affichage de succès
# ------------------------------------------------------------------------------

# Nettoyage de l'écran avant le message final pour une présentation propre
clear
echo ""
echo "════════════════════════════════════════════════════════════"
echo "                SERVEUR UVICORN LANCÉ AVEC SUCCÈS            "
echo "════════════════════════════════════════════════════════════"
echo ""

# Message de succès et indication de l'URL d'accès
success "Le serveur FastAPI est maintenant accessible sur http://localhost:8000"
echo ""