#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Nom du script       : api_stop.sh
# Version             : 1.0.0
# Auteur              : archsystem-dev
# Date de modification: 14 décembre 2025
# Description         : Arrête proprement le serveur Uvicorn du backend et
#                       redémarre Nginx pour appliquer les changements.
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
# Liste des Paramètres : "$@" (message à afficher)
# Description          : Affiche un message d'erreur avec [ERREUR] puis quitte
#                       avec un code d'erreur
# ------------------------------------------------------------------------------
# Affiche un message d'erreur avec préfixe [ERREUR] puis quitte
error() {
    printf "[ERREUR] %s\n" "$*" >&2
    exit 1
}

# ------------------------------------------------------------------------------
# Vérifications préliminaires : pas d'exécution en root
# ------------------------------------------------------------------------------

# Information sur la vérification de l'identité utilisateur
info "Vérification que le script n'est pas exécuté en root..."
# Pourquoi : certains services (comme Nginx) nécessitent sudo, mais le script
# gère Conda en utilisateur standard ; exécution en root peut causer des problèmes
[[ "$EUID" -ne 0 ]] || error "Ce script ne doit pas être exécuté avec sudo ou en root."

# Confirmation que l'exécution se fait en utilisateur non privilégié
success "Exécution en utilisateur standard confirmée"

# ------------------------------------------------------------------------------
# Chemins absolus et configuration
# ------------------------------------------------------------------------------

# Détermination du répertoire contenant le script
# Pourquoi : garantit des chemins fiables quel que soit le cwd
SCRIPT_DIR="$(realpath -m .)"
# Répertoire du projet backend FastAPI
BACKEND_DIR="$SCRIPT_DIR/backend"

# Chemin vers Miniconda (adapté à l'utilisateur réel)
# Pourquoi : utilise l'installation personnelle de l'utilisateur courant
MINICONDA_PATH="/home/$USER/Softwares/miniconda3"

# ------------------------------------------------------------------------------
# Activation de l'environnement Conda
# ------------------------------------------------------------------------------

# Information sur l'étape d'activation
info "Activation de l'environnement Conda du backend..."
# Chargement des fonctions Conda nécessaires à la commande conda
# shellcheck disable=SC1091
source "$MINICONDA_PATH/etc/profile.d/conda.sh" || error "Impossible de sourcer conda.sh"
# Activation de l'environnement dédié au backend
conda activate "$BACKEND_DIR/conda" || error "Impossible d'activer l'environnement Conda"

# Confirmation du succès de l'activation
success "Environnement Conda activé"

# ------------------------------------------------------------------------------
# Arrêt du serveur Uvicorn
# ------------------------------------------------------------------------------

# Information sur l'arrêt du processus
info "Arrêt de tout processus Uvicorn existant..."
# Envoi d'un signal d'arrêt à tout processus contenant "uvicorn" dans sa commande
if pkill -f uvicorn >/dev/null 2>&1; then
    success "Serveur Uvicorn arrêté"
else
    error "Aucun processus Uvicorn trouvé ou arrêt impossible"
fi

# ------------------------------------------------------------------------------
# Redémarrage de Nginx
# ------------------------------------------------------------------------------

# Information sur le redémarrage du reverse proxy
info "Redémarrage du service Nginx..."
# Redémarrage complet du service système Nginx
if systemctl restart nginx >/dev/null 2>&1; then
    success "Nginx redémarré"
else
    error "Impossible de redémarrer Nginx"
fi

# ------------------------------------------------------------------------------
# Vérifications finales
# ------------------------------------------------------------------------------

# Information sur les tests de santé post-arrêt
info "Vérifications finales..."
echo " Vérifications :"

# Test si Uvicorn est bien arrêté : une requête curl doit échouer
# Pourquoi : confirme que le backend n'est plus accessible directement
curl http://0.0.0.0:8000 >/dev/null 2>&1 && echo " Uvicorn     : ÉCHEC (encore actif)" || echo " Uvicorn     : OK (arrêté)"

# Test si le service Nginx reste actif après redémarrage
systemctl is-active nginx >/dev/null && echo " Nginx       : OK (actif)" || echo " Nginx       : ÉCHEC"

# ------------------------------------------------------------------------------
# Finalisation et message de succès
# ------------------------------------------------------------------------------

# Affichage du récapitulatif final
echo ""
echo "════════════════════════════════════════════════════════════"
echo "               SERVEUR ARRÊTÉ AVEC SUCCÈS                   "
echo "════════════════════════════════════════════════════════════"
echo ""
echo " Uvicorn a été arrêté et Nginx redémarré."
echo ""
echo " Test rapide :"
printf " %-18s : %s\n" "curl http://0.0.0.0:8000" "Devrait retourner 'Error'"
echo " Réponse : $(curl http://0.0.0.0:8000 2>/dev/null || echo 'Error')"
echo ""
echo "════════════════════════════════════════════════════════════"
echo ""