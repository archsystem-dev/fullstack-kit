#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Nom du script       : github_reset_pull.sh
# Description         : Récupère l'état exact du dépôt distant et écrase
#                       proprement les fichiers versionnés locaux.
#                       Les fichiers non suivis (untracked) sont préservés.
# ------------------------------------------------------------------------------

set -euo pipefail
IFS=$'\n\t'

# ------------------------------------------------------------------------------
# Fonctions d'affichage
# ------------------------------------------------------------------------------
info()    { printf "[INFO]  %s\n" "$*" >&2; }
success() { printf "[OK]    %s\n" "$*" >&2; }
error()   { printf "[ERREUR] %s\n" "$*" >&2; exit 1; }

# ------------------------------------------------------------------------------
# Chemins et config
# ------------------------------------------------------------------------------
SCRIPT_DIR="$(pwd)"
CONFIG_FILE="$SCRIPT_DIR/github.ini"

[[ -f "$CONFIG_FILE" ]] || error "Fichier github.ini introuvable dans $SCRIPT_DIR"
[[ -d ".git" ]]         || error "Pas un dépôt Git dans $SCRIPT_DIR"

# Lecture des identifiants (simplifié)
GIT_USER=$(crudini --get "$CONFIG_FILE" Github user 2>/dev/null || error "Clé 'user' manquante")
GIT_TOKEN=$(crudini --get "$CONFIG_FILE" Github token 2>/dev/null || error "Clé 'token' manquante")

PROJECT_NAME="$(basename "$SCRIPT_DIR")"
REMOTE_URL="https://$GIT_USER:$GIT_TOKEN@github.com/$GIT_USER/$PROJECT_NAME.git"

# ------------------------------------------------------------------------------
# Confirmation utilisateur
# ------------------------------------------------------------------------------
echo "════════════════════════════════════════════════════════════"
echo "   RÉINITIALISATION + MISE À JOUR DEPUIS GITHUB (écrasement)"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "Cette opération va :"
echo "  • Récupérer la branche distante"
echo "  • Écraser TOUS les fichiers versionnés localement"
echo "  • Préserver les fichiers non suivis (untracked)"
echo ""
echo "Dossier : $SCRIPT_DIR"
echo "Dépôt   : $REMOTE_URL"
echo ""
read -rp "Confirmer ? (oui/non) : " confirm
confirm=$(echo "$confirm" | tr '[:upper:]' '[:lower:]')

[[ "$confirm" == "oui" ]] || { info "Opération annulée."; exit 0; }

# ------------------------------------------------------------------------------
# Configuration remote
# ------------------------------------------------------------------------------
info "Configuration remote origin..."
if git remote | grep -q "^origin$"; then
    git remote set-url origin "$REMOTE_URL"
else
    git remote add origin "$REMOTE_URL"
fi

# ------------------------------------------------------------------------------
# Détection branche principale distante
# ------------------------------------------------------------------------------
info "Récupération des références distantes..."
git fetch origin --quiet

# Détection branche par défaut (main ou master)
if git symbolic-ref refs/remotes/origin/HEAD >/dev/null 2>&1; then
    DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')
else
    # Fallback ls-remote
    DEFAULT_BRANCH=$(git ls-remote --symref origin HEAD | awk '/^ref: /{print $2}' | sed 's@refs/heads/@@')
    [[ -z "$DEFAULT_BRANCH" ]] && {
        git ls-remote origin main >/dev/null 2>&1 && DEFAULT_BRANCH=main || DEFAULT_BRANCH=master
    }
fi

success "Branche distante : $DEFAULT_BRANCH"

# ------------------------------------------------------------------------------
# Reset dur + pull
# ------------------------------------------------------------------------------
info "Reset dur vers origin/$DEFAULT_BRANCH..."
git reset --hard "origin/$DEFAULT_BRANCH"

info "Mise à jour complète (pull)..."
git pull --ff-only origin "$DEFAULT_BRANCH" || {
    # En cas d'échec rare (divergence inattendue), on force à nouveau
    git fetch origin "$DEFAULT_BRANCH"
    git reset --hard "origin/$DEFAULT_BRANCH"
}

# Optionnel : mise à jour submodules
git submodule update --init --recursive --quiet 2>/dev/null || true

success "Synchronisation terminée"
echo ""
echo "════════════════════════════════════════════════════════════"
echo "     MISE À JOUR TERMINÉE – Fichiers versionnés écrasés     "
echo "════════════════════════════════════════════════════════════"
echo "Branche : $DEFAULT_BRANCH"
echo "Commit  : $(git rev-parse --short HEAD)"
echo ""
echo "→ Les fichiers non suivis (untracked) ont été préservés."
echo "→ Toutes vos modifications locales versionnées ont été perdues."
echo ""