#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Nom du script       : launch_dev.sh
# Version             : 1.0.0
# Auteur              : archsystem-dev
# Date de modification: 14 décembre 2025
# Description         : Ouvre deux terminaux graphiques séparés pour lancer en mode
#                       développement le serveur backend FastAPI (api_dev.sh) et le
#                       serveur frontend npm (npm_dev.sh).
# ------------------------------------------------------------------------------

# Activation des options strictes pour une exécution robuste et sécurisée
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
info() {
    printf "[INFO]  %s\n" "$*" >&2
}

# ------------------------------------------------------------------------------
# Nom de la fonction   : success()
# Liste des Paramètres : "$@" (message à afficher)
# Description          : Affiche un message de succès avec préfixe [OK]
# ------------------------------------------------------------------------------
success() {
    printf "[OK]    %s\n" "$*" >&2
}

# ------------------------------------------------------------------------------
# Nom de la fonction   : error()
# Liste des Paramètres : "$@" (message d'erreur)
# Description          : Affiche un message d'erreur avec [ERREUR] et quitte le script
# ------------------------------------------------------------------------------
error() {
    printf "[ERREUR] %s\n" "$*" >&2
    exit 1
}

# ------------------------------------------------------------------------------
# Vérifications préliminaires : pas d'exécution en root
# ------------------------------------------------------------------------------

# Information sur la vérification des privilèges
info "Vérification que le script n'est pas exécuté en root..."
# Pourquoi : les terminaux graphiques et scripts dev s'exécutent en utilisateur standard
[[ "$EUID" -ne 0 ]] || error "Ce script ne doit pas être exécuté avec sudo ou en root."

# Confirmation du mode d'exécution correct
success "Exécution en utilisateur standard confirmée"

# ------------------------------------------------------------------------------
# Nom de la fonction   : open_terminal_and_run()
# Liste des Paramètres : $1 → chemin absolu du script à exécuter
# Description          : Ouvre un nouveau terminal graphique et exécute le script
#                       donné, adapté au desktop/terminal disponible
# ------------------------------------------------------------------------------
open_terminal_and_run() {
    local script_path="$1"

    # Information sur le lancement en cours
    info "Lancement de $script_path dans un nouveau terminal"

    # Détection prioritaire de Konsole (KDE/Plasma)
    if [ "${XDG_CURRENT_DESKTOP:-}" = "KDE" ] || [ "${XDG_CURRENT_DESKTOP:-}" = "plasma" ] || command -v konsole >/dev/null 2>&1; then
        konsole -e bash "$script_path"

    # GNOME Terminal
    elif command -v gnome-terminal >/dev/null 2>&1; then
        gnome-terminal -- bash -c "bash \"$script_path\"; echo; echo 'Appuyez sur Entrée pour fermer...'; read -r"

    # XFCE Terminal
    elif command -v xfce4-terminal >/dev/null 2>&1; then
        xfce4-terminal -x bash "$script_path"

    # Fallback sur xterm
    elif command -v xterm >/dev/null 2>&1; then
        xterm -e bash "$script_path"

    # Aucun terminal supporté trouvé
    else
        error "Aucun terminal graphique supporté détecté (konsole, gnome-terminal, xfce4-terminal, xterm)"
    fi
}

# ------------------------------------------------------------------------------
# Chemins absolus et vérification des scripts
# ------------------------------------------------------------------------------

SCRIPT_DIR="$(pwd)"

# Chemins vers les scripts de développement
API_DEV_SCRIPT="$SCRIPT_DIR/api_dev.sh"
NPM_DEV_SCRIPT="$SCRIPT_DIR/npm_dev.sh"

# Vérification de l'existence des scripts requis
[[ -f "$API_DEV_SCRIPT" ]] || error "Script api_dev.sh introuvable dans $SCRIPT_DIR"
[[ -f "$NPM_DEV_SCRIPT" ]] || error "Script npm_dev.sh introuvable dans $SCRIPT_DIR"

# ------------------------------------------------------------------------------
# Lancement des deux terminaux en parallèle
# ------------------------------------------------------------------------------

# Information globale de démarrage
info "Démarrage de l'environnement de développement..."

# Lancement asynchrone des deux terminaux
open_terminal_and_run "$API_DEV_SCRIPT" &
open_terminal_and_run "$NPM_DEV_SCRIPT" &

# Confirmation du lancement réussi
success "Deux terminaux ouverts : backend (api_dev.sh) et frontend (npm_dev.sh)"

# Affichage final récapitulatif
echo ""
echo "════════════════════════════════════════════════════════════"
echo "          ENVIRONNEMENT DE DÉVELOPPEMENT LANCÉ              "
echo "════════════════════════════════════════════════════════════"
echo ""
echo " Deux terminaux graphiques ont été ouverts :"
echo ""
printf " %-24s : %s\n" "Backend (FastAPI)" "api_dev.sh (port 8000, --reload)"
printf " %-24s : %s\n" "Frontend (npm)" "npm_dev.sh (serveur dev)"
echo ""
echo " Vous pouvez maintenant développer en temps réel."
echo " Les modifications sont rechargées automatiquement."
echo ""
echo " Pour arrêter : Ctrl+C dans chaque terminal."
echo ""
echo "════════════════════════════════════════════════════════════"
echo ""