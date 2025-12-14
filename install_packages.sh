#!/usr/bin/env bash
___

# ------------------------------------------------------------------------------
# Nom du script       : install_packages.sh
# Version             : 1.0.0
# Auteur              : archsystem-dev
# Date de modification: 14 décembre 2025
# Description         : Installe les dépendances Python (via pip dans l'environnement
#                       Conda dédié) et Node.js (via npm) pour le backend et le frontend
#                       du projet, en respectant les fichiers requirements.txt et package.json.
# ------------------------------------------------------------------------------

# Activation des options strictes pour une exécution robuste
# Pourquoi : arrête le script sur erreur, variable non définie ou pipeline échoué
set -euo pipefail

# Séparateurs internes sécurisés
# Pourquoi : évite les problèmes avec les espaces dans les chemins ou noms
IFS=$'\n\t'

# ------------------------------------------------------------------------------
# Fonctions utilitaires d'affichage
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Nom de la fonction   : info()
# Liste des Paramètres : "$@" (message à afficher)
# Description          : Affiche un message informatif avec préfixe [INFO]
# ------------------------------------------------------------------------------
# Affiche un message informatif avec préfixe [INFO]
info() {
    printf "[INFO]  %s\n" "$*" >&2
}

# ------------------------------------------------------------------------------
# Nom de la fonction   : success()
# Liste des Paramètres : "$@" (message à afficher)
# Description          : Affiche un message de succès avec préfixe [OK]
# ------------------------------------------------------------------------------
# Affiche un message de succès avec préfixe [OK]
success() {
    printf "[OK]    %s\n" "$*" >&2
}

# ------------------------------------------------------------------------------
# Nom de la fonction   : error()
# Liste des Paramètres : "$@" (message d'erreur)
# Description          : Affiche un message d'erreur avec [ERREUR] et quitte le script
# ------------------------------------------------------------------------------
# Affiche un message d'erreur avec préfixe [ERREUR] puis quitte
error() {
    printf "[ERREUR] %s\n" "$*" >&2
    exit 1
}

# ------------------------------------------------------------------------------
# Vérifications préliminaires : pas d'exécution en root
# ------------------------------------------------------------------------------

# Information sur la vérification des privilèges
info "Vérification que le script n'est pas exécuté en root..."
# Pourquoi : les installations se font dans l'environnement utilisateur
[[ "$EUID" -ne 0 ]] || error "Ce script ne doit pas être exécuté avec sudo ou en root."

# Confirmation du mode d'exécution correct
success "Exécution en utilisateur standard confirmée"

# ------------------------------------------------------------------------------
# Chemins absolus et configuration du projet
# ------------------------------------------------------------------------------

# Répertoire courant (où le script est lancé, supposé racine du projet)
SCRIPT_DIR="$(pwd)"
# Nom du projet extrait du répertoire courant
PROJECT_NAME="$(basename "SCRIPT_DIR")"

# Chemins vers les dossiers et fichiers clés
BACKEND_DIR="$SCRIPT_DIR/backend"
FRONTEND_DIR="$SCRIPT_DIR/frontend"
CONDA_ENV_DIR="$BACKEND_DIR/conda"
REQUIREMENTS_FILE="$BACKEND_DIR/requirements.txt"
PACKAGE_JSON="$FRONTEND_DIR/package.json"
PACKAGE_LOCK="$FRONTEND_DIR/package-lock.json"

# ------------------------------------------------------------------------------
# Vérifications préalables des dossiers et fichiers essentiels
# ------------------------------------------------------------------------------

# Information sur la vérification de la structure
info "Vérification de la structure du projet..."
[[ -d "$BACKEND_DIR" ]]     || error "Dossier backend/ introuvable"
[[ -d "$FRONTEND_DIR" ]]    || error "Dossier frontend/ introuvable"
[[ -d "$CONDA_ENV_DIR" ]]   || error "Environnement Conda introuvable dans backend/conda"

# Confirmation de la structure valide
success "Structure du projet vérifiée"

# ------------------------------------------------------------------------------
# Installation des dépendances Python (backend)
# ------------------------------------------------------------------------------

# Information sur l'activation de l'environnement
info "Activation de l'environnement Conda dédié..."
# Chargement des fonctions Conda depuis l'installation de base
source "$(conda info --base)/etc/profile.d/conda.sh" || error "Impossible de sourcer conda.sh"
# Activation de l'environnement dédié au backend
conda activate "$CONDA_ENV_DIR" || error "Impossible d'activer l'environnement Conda"

# Information sur l'installation Python
info "Installation des dépendances Python via pip..."
# Vérification de la présence du fichier de dépendances
[[ -f "$REQUIREMENTS_FILE" ]] || error "Fichier requirements.txt introuvable dans backend/"

# Installation/mise à jour silencieuse des packages Python
pip install --upgrade -r "$REQUIREMENTS_FILE" >/dev/null
# Confirmation du succès de l'installation backend
success "Dépendances Python installées avec succès"

# ------------------------------------------------------------------------------
# Installation des dépendances Node.js (frontend)
# ------------------------------------------------------------------------------

# Information sur l'installation frontend
info "Installation des dépendances npm dans frontend..."
# Positionnement dans le répertoire frontend
cd "$FRONTEND_DIR"

# Vérification de la présence du fichier package.json
[[ -f "$PACKAGE_JSON" ]] || error "Fichier package.json introuvable dans frontend/"

# Choix de la commande npm selon la situation
if [[ -f "$PACKAGE_LOCK" ]]; then
    info "package-lock.json présent → utilisation de npm ci"
    npm ci --legacy-peer-deps >/dev/null
elif [[ -d "node_modules" ]]; then
    info "node_modules présent sans package-lock → npm install"
    npm install --legacy-peer-deps >/dev/null
else
    info "Première installation → npm install"
    npm install --legacy-peer-deps >/dev/null
fi

# Génération du package-lock.json si absent pour reproductibilité
if [[ ! -f "$PACKAGE_LOCK" ]]; then
    info "Génération de package-lock.json pour reproductibilité"
    npm install --package-lock-only --legacy-peer-deps >/dev/null || true
fi

# Confirmation du succès de l'installation frontend
success "Dépendances npm installées avec succès"

# ------------------------------------------------------------------------------
# Finalisation et message de succès
# ------------------------------------------------------------------------------

# Affichage final récapitulatif
echo ""
echo "════════════════════════════════════════════════════════════"
echo "         PACKAGES DU PROJET $PROJECT_NAME INSTALLÉS         "
echo "════════════════════════════════════════════════════════════"
echo ""
printf " %-18s : %s\n" "Projet" "$PROJECT_NAME"
printf " %-18s : %s\n" "Backend (Python)" "requirements.txt → OK"
printf " %-18s : %s\n" "Frontend (npm)" "package.json → OK"
echo ""
echo " Toutes les dépendances sont maintenant installées."
echo " Vous pouvez lancer le serveur avec api_dev.sh ou api_start.sh."
echo ""
echo "════════════════════════════════════════════════════════════"
echo ""