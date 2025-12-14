#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Nom du script       : launch_test_prod.sh
# Version             : 1.0.0
# Auteur              : archsystem-dev
# Date de modification: 14 décembre 2025
# Description         : Génère la distribution frontend, démarre le serveur backend
#                       FastAPI en mode production et recharge Nginx pour déployer
#                       l'application en environnement de test/production.
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
# Pourquoi : certaines étapes internes nécessitent sudo, mais le script principal
# s'exécute en utilisateur standard pour éviter des problèmes de permissions
[[ "$EUID" -ne 0 ]] || error "Ce script ne doit pas être exécuté avec sudo ou en root."

# Confirmation du mode d'exécution correct
success "Exécution en utilisateur standard confirmée"

# ------------------------------------------------------------------------------
# Chemins absolus et scripts à exécuter
# ------------------------------------------------------------------------------

# Répertoire courant normalisé (racine du projet)
SCRIPT_DIR="$(realpath -m .)"

# Chemins vers les scripts dépendants
NPM_DIST_SCRIPT="$SCRIPT_DIR/npm_dist_generate.sh"
API_START_SCRIPT="$SCRIPT_DIR/api_start.sh"
NGINX_RELOAD_SCRIPT="$SCRIPT_DIR/nginx_reload.sh"

# Vérification de l'existence des scripts nécessaires
# Pourquoi : garantit que toutes les étapes peuvent être exécutées
[[ -f "$NPM_DIST_SCRIPT" ]]     || error "Script npm_dist_generate.sh introuvable"
[[ -f "$API_START_SCRIPT" ]]    || error "Script api_start.sh introuvable"
[[ -f "$NGINX_RELOAD_SCRIPT" ]] || error "Script nginx_reload.sh introuvable"

# ------------------------------------------------------------------------------
# Étape 1 : Génération de la distribution frontend
# ------------------------------------------------------------------------------

# Information sur la génération de la build production
info "Génération de la distribution frontend (npm run build)..."
# Exécution du script dédié à la build frontend
bash "$NPM_DIST_SCRIPT" || error "Échec de la génération de la distribution frontend"
# Confirmation du succès de la build
success "Distribution frontend générée"

# ------------------------------------------------------------------------------
# Étape 2 : Démarrage du serveur backend (nécessite sudo)
# ------------------------------------------------------------------------------

# Information sur le démarrage du backend
info "Démarrage du serveur backend FastAPI en mode production..."
# Exécution du script de démarrage production (gère sudo internement si besoin)
bash "$API_START_SCRIPT" || error "Échec du démarrage du serveur backend"
# Confirmation du démarrage réussi
success "Serveur backend démarré"

# ------------------------------------------------------------------------------
# Étape 3 : Rechargement de Nginx (nécessite sudo)
# ------------------------------------------------------------------------------

# Information sur le rechargement du reverse proxy
info "Rechargement de la configuration Nginx..."
# Exécution avec sudo du script de rechargement Nginx
sudo bash "$NGINX_RELOAD_SCRIPT" || error "Échec du rechargement de Nginx"
# Confirmation du rechargement réussi
success "Nginx rechargé"

# ------------------------------------------------------------------------------
# Finalisation et message de succès
# ------------------------------------------------------------------------------

# Affichage final récapitulatif
echo ""
echo "════════════════════════════════════════════════════════════"
echo "          APPLICATION DÉPLOYÉE EN PRODUCTION                "
echo "════════════════════════════════════════════════════════════"
echo ""
echo " L'environnement de test/production est maintenant actif :"
echo ""
printf " %-18s : %s\n" "Frontend" "Distribution statique générée"
printf " %-18s : %s\n" "Backend" "Uvicorn (FastAPI) lancé"
printf " %-18s : %s\n" "Proxy" "Nginx rechargé"
echo ""
echo " Votre application est accessible via le port configuré dans Nginx."
echo ""
echo " Pour arrêter : sudo ./api_stop.sh"
echo ""
echo "════════════════════════════════════════════════════════════"
echo ""