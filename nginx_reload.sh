#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Nom du script       : nginx_reload.sh
# Version             : 1.0.0
# Auteur              : archsystem-dev
# Date de modification: 14 décembre 2025
# Description         : Copie la configuration nginx.conf du projet vers le site
#                       default, valide la syntaxe, active le lien symbolique si
#                       nécessaire et recharge proprement le service Nginx.
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
# Vérifications préliminaires : privilèges root
# ------------------------------------------------------------------------------

# Information sur la vérification des privilèges
info "Vérification des privilèges root..."
# Pourquoi : modifications système sur /etc/nginx nécessitent root
[[ "$EUID" -eq 0 ]] || error "Ce script doit être exécuté avec sudo."

# Confirmation des privilèges élevés
success "Privilèges root confirmés"

# ------------------------------------------------------------------------------
# Chemins absolus et configuration Nginx
# ------------------------------------------------------------------------------

# Répertoire courant normalisé (racine du projet)
SCRIPT_DIR="$(realpath -m .)"

# Chemin source de la configuration projet
SOURCE_CONF="$SCRIPT_DIR/nginx.conf"
# Répertoires système Nginx
SITES_AVAILABLE="/etc/nginx/sites-available"
SITES_ENABLED="/etc/nginx/sites-enabled"
# Cible pour le site par défaut
TARGET_CONF="$SITES_AVAILABLE/default"

# Vérification de la présence du fichier de configuration source
[[ -f "$SOURCE_CONF" ]] || error "Fichier nginx.conf introuvable dans $SCRIPT_DIR"

# ------------------------------------------------------------------------------
# Arrêt temporaire de Nginx pour éviter les conflits
# ------------------------------------------------------------------------------

# Information sur l'arrêt temporaire
info "Arrêt temporaire du service Nginx..."
# Arrêt gracieux ; message alternatif si déjà arrêté
systemctl stop nginx 2>/dev/null || info "Nginx n'était pas démarré"

# ------------------------------------------------------------------------------
# Copie de la configuration projet vers le site default
# ------------------------------------------------------------------------------

# Information sur la copie
info "Copie de la configuration projet vers $TARGET_CONF..."
# Remplacement de la configuration default par celle du projet
cp "$SOURCE_CONF" "$TARGET_CONF"
# Confirmation de la copie réussie
success "Configuration copiée"

# ------------------------------------------------------------------------------
# Activation du site default via lien symbolique si nécessaire
# ------------------------------------------------------------------------------

# Information sur la vérification d'activation
info "Vérification de l'activation du site default..."
# Vérification de l'existence du lien symbolique
if [[ -L "$SITES_ENABLED/default" ]]; then
    info "Site default déjà activé"
else
    # Création du lien si absent
    info "Activation du site default..."
    ln -sf "$TARGET_CONF" "$SITES_ENABLED/default"
    success "Site default activé"
fi

# ------------------------------------------------------------------------------
# Validation de la syntaxe de la configuration Nginx
# ------------------------------------------------------------------------------

# Information sur le test de syntaxe
info "Test de la syntaxe de la configuration Nginx..."
# Test silencieux ; succès ou erreur fatale
if nginx -t >/dev/null 2>&1; then
    success "Syntaxe de la configuration valide"
else
    error "Erreur de syntaxe dans la configuration Nginx → opération annulée"
fi

# ------------------------------------------------------------------------------
# Rechargement propre du service Nginx
# ------------------------------------------------------------------------------

# Information sur le rechargement
info "Rechargement du service Nginx..."
# Reload préféré ; fallback sur start si arrêté
systemctl reload nginx 2>/dev/null || systemctl start nginx
# Confirmation du rechargement réussi
success "Nginx rechargé avec la nouvelle configuration"

# ------------------------------------------------------------------------------
# Finalisation et message de succès
# ------------------------------------------------------------------------------

# Affichage final récapitulatif
echo ""
echo "════════════════════════════════════════════════════════════"
echo "             NGINX RECHARGÉ AVEC SUCCÈS                     "
echo "════════════════════════════════════════════════════════════"
echo ""
printf " %-18s : %s\n" "Configuration" "$TARGET_CONF"
printf " %-18s : %s\n" "Site activé" "$SITES_ENABLED/default"
echo ""
echo " La nouvelle configuration du projet est maintenant appliquée."
echo " Nginx sert les fichiers selon nginx.conf du projet."
echo ""
echo "════════════════════════════════════════════════════════════"
echo ""