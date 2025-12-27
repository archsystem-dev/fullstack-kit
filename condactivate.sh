#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Nom du script       : condactivate.sh
# Version             : 1.0.0
# Auteur              : archsystem-dev
# Date de modification: 27 décembre 2025
# Description         : Active l'environnement Conda
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

# Chemins vers les dossiers et fichiers clés
BACKEND_DIR="$SCRIPT_DIR/backend"
CONDA_ENV_DIR="$BACKEND_DIR/conda"

# ------------------------------------------------------------------------------
# Vérifications préalables des dossiers et fichiers essentiels
# ------------------------------------------------------------------------------

# Information sur la vérification de la structure
info "Vérification de la structure du projet..."
[[ -d "$BACKEND_DIR" ]]     || error "Dossier backend/ introuvable"
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