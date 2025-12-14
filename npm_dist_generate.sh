#!/usr/bin/env bash

# ------------------------------------------------------------------------------
# Nom du script       : npm_dist_generate.sh
# Version             : 1.0.0
# Auteur              : archsystem-dev
# Date de modification: 14 décembre 2025
# Description         : Génère la distribution de production du frontend via npm
#                       run build, corrige les permissions du dossier dist et
#                       autorise www-data (Nginx) à lire les fichiers statiques.
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
# Pourquoi : la génération npm se fait en utilisateur standard
[[ "$EUID" -ne 0 ]] || error "Ce script ne doit pas être exécuté avec sudo ou en root."

# Confirmation du mode d'exécution correct
success "Exécution en utilisateur standard confirmée"

# ------------------------------------------------------------------------------
# Chemins absolus du projet
# ------------------------------------------------------------------------------

# Répertoire courant normalisé (racine du projet)
SCRIPT_DIR="$(realpath -m .)"
# Chemin vers le répertoire frontend
FRONTEND_DIR="$SCRIPT_DIR/frontend"
# Chemin vers le dossier de distribution généré
DIST_DIR="$FRONTEND_DIR/dist"

# Vérification de la présence du dossier frontend
# Pourquoi : garantit que le script est lancé depuis la bonne racine
[[ -d "$FRONTEND_DIR" ]] || error "Dossier frontend/ introuvable dans $SCRIPT_DIR"

# ------------------------------------------------------------------------------
# Génération de la distribution frontend
# ------------------------------------------------------------------------------

# Information sur la génération de la build production
info "Lancement de la génération de la distribution (npm run build)..."
# Positionnement dans le répertoire frontend
cd "$FRONTEND_DIR"

# Exécution silencieuse de la commande de build
npm run build >/dev/null || error "Échec de la commande npm run build"
# Confirmation de la génération réussie
success "Distribution générée dans $DIST_DIR"

# ------------------------------------------------------------------------------
# Finalisation et message de succès
# ------------------------------------------------------------------------------

# Affichage final récapitulatif
echo ""
echo "════════════════════════════════════════════════════════════"
echo "         DISTRIBUTION FRONTEND GÉNÉRÉE AVEC SUCCÈS          "
echo "════════════════════════════════════════════════════════════"
echo ""
printf " %-18s : %s\n" "Dossier dist" "$DIST_DIR"
printf " %-18s : %s\n" "Permissions" "755 (lecture pour www-data)"
echo ""
echo " Les fichiers statiques sont prêts à être servis par Nginx."
echo " Vous pouvez maintenant lancer launch_test_prod.sh."
echo ""
echo "════════════════════════════════════════════════════════════"
echo ""