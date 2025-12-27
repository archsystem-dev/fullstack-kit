#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Nom du script       : api_start.sh
# Version             : 1.0.0
# Auteur              : archsystem-dev
# Date de modification: 14 décembre 2025
# Description         : Arrête un éventuel serveur Uvicorn existant, démarre un
#                       nouveau serveur Uvicorn pour le backend FastAPI et
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
# Chemins absolus et configuration
# ------------------------------------------------------------------------------

# Détermination du répertoire contenant le script
# Pourquoi : garantit des chemins fiables quel que soit le cwd
SCRIPT_DIR="$(pwd)"
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
# Arrêt d'un éventuel serveur Uvicorn existant
# ------------------------------------------------------------------------------

# Information sur la recherche et l'arrêt potentiel
info "Arrêt d'un éventuel processus Uvicorn existant..."
# Envoi d'un signal d'arrêt à tout processus contenant "uvicorn" dans sa commande
if pkill -f uvicorn >/dev/null 2>&1; then
    success "Ancien serveur Uvicorn arrêté"
else
    info "Aucun processus Uvicorn en cours"
fi

# ------------------------------------------------------------------------------
# Démarrage du serveur Uvicorn
# ------------------------------------------------------------------------------

# Information sur le démarrage
info "Démarrage du serveur Uvicorn (FastAPI)..."
# Positionnement dans le répertoire du backend pour un contexte correct
cd "$BACKEND_DIR"

# Lancement de Uvicorn en arrière-plan
# Pourquoi : & pour détacher le processus et permettre la suite du script
if uvicorn main:app --host 0.0.0.0 --port 8000 >/dev/null 2>&1 & then
    success "Serveur Uvicorn démarré en arrière-plan"
else
    error "Échec du démarrage de Uvicorn"
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

# Information sur les tests de santé
info "Vérifications finales..."
echo " Vérifications :"

# Test si Uvicorn répond sur son port direct
# Pourquoi : vérifie que le processus backend est bien accessible
curl http://0.0.0.0:8000 >/dev/null 2>&1 && echo " Uvicorn     : OK (répond)" || echo " Uvicorn     : ÉCHEC"

# Test si le service Nginx est actif
# Pourquoi : confirme que le reverse proxy est opérationnel
systemctl is-active nginx >/dev/null && echo " Nginx       : OK (actif)" || echo " Nginx       : ÉCHEC"

# ------------------------------------------------------------------------------
# Finalisation et message de succès
# ------------------------------------------------------------------------------

# Affichage du récapitulatif final
echo ""
echo "════════════════════════════════════════════════════════════"
echo "               SERVEUR DÉMARRÉ AVEC SUCCÈS                   "
echo "════════════════════════════════════════════════════════════"
echo ""
echo " Le serveur FastAPI (Uvicorn) est lancé et Nginx redémarré."
echo ""
echo " Test rapide :"
printf " %-24s : %s\n" "curl http://0.0.0.0:8000" "Devrait retourner une réponse valide"
echo " Réponse : $(curl http://0.0.0.0:8000 2>/dev/null || echo 'Erreur de connexion')"
echo ""
echo "════════════════════════════════════════════════════════════"
echo ""