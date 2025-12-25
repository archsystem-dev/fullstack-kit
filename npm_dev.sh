#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Nom du script       : npm_dev.sh
# Version             : 1.0.0
# Auteur              : archsystem-dev
# Date de modification: 14 décembre 2025
# Description         : Arrête les processus Node.js/npm existants liés au serveur
#                       de développement et lance npm run dev dans le dossier frontend.
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
# Chemins absolus du script et du dossier frontend
# ------------------------------------------------------------------------------

# Répertoire courant normalisé (racine du projet)
SCRIPT_DIR="$(pwd)"
# Chemin vers le répertoire frontend
FRONTEND_DIR="$SCRIPT_DIR/frontend"

# Vérification de la présence du dossier frontend
# Pourquoi : garantit que le script est lancé depuis la bonne racine
[[ -d "$FRONTEND_DIR" ]] || error "Dossier frontend/ introuvable dans $SCRIPT_DIR"

# ------------------------------------------------------------------------------
# Arrêt des processus Node.js/npm existants
# ------------------------------------------------------------------------------

# Information sur l'arrêt des processus
info "Arrêt des processus Node.js/npm de développement existants..."
# Tentative d'arrêt via plusieurs motifs courants pour les serveurs dev
if pkill -f "node.*npm.*run" >/dev/null 2>&1 || \
   pkill -f "node.*dev" >/dev/null 2>&1 || \
   pkill -f "vite\|react-scripts\|next" >/dev/null 2>&1; then
    success "Processus existants arrêtés"
else
    info "Aucun processus de développement en cours"
fi

# Pause pour assurer la terminaison propre des processus
# Pourquoi : évite les conflits de port lors du redémarrage
sleep 2

# ------------------------------------------------------------------------------
# Lancement du serveur de développement npm
# ------------------------------------------------------------------------------

# Information sur le démarrage
info "Lancement de npm run dev dans le dossier frontend..."
# Positionnement dans le répertoire frontend
cd "$FRONTEND_DIR"

# Exécution du script de développement (reste au premier plan)
# Pourquoi : permet le rechargement à chaud et l'interaction utilisateur
npm run dev || error "Échec du lancement de npm run dev"