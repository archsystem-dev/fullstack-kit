#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Nom du script       : github_pull.sh
# Version             : 1.0.0
# Auteur              : archsystem-dev
# Date de modification: 14 décembre 2025
# Description         : Met à jour les fichiers locaux depuis le dépôt GitHub distant
#                       en préservant les fichiers non versionnés et en gérant
#                       automatiquement les modifications locales via stash.
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
# Pourquoi : les opérations Git doivent se faire en utilisateur standard
[[ "$EUID" -ne 0 ]] || error "Ce script ne doit pas être exécuté avec sudo ou en root."

# Confirmation du mode d'exécution correct
success "Exécution en utilisateur standard confirmée"

# ------------------------------------------------------------------------------
# Fonction : to_lowercase()
# Liste des Paramètres : $1 → chaîne à convertir
# Description          : Convertit une chaîne en minuscules de façon portable
# ------------------------------------------------------------------------------
to_lowercase() {
    echo "${1,,}"
}

# ------------------------------------------------------------------------------
# Fonction : get_config_value()
# Liste des Paramètres : $1 → clé dans la section [Github]
# Description          : Lit une valeur dans project.ini via crudini (valeurs
#                       optionnelles pour name/email avec valeurs par défaut)
# ------------------------------------------------------------------------------
get_config_value() {
    local key=$1 default=${2:-}
    local val
    # Lecture avec crudini, fallback sur default si vide
    val=$(crudini --get "$CONFIG_PROJECT" Github "$key" 2>/dev/null || echo "")
    if [[ -z "$val" && -n "$default" ]]; then
        echo "$default"
    elif [[ -z "$val" ]]; then
        error "Clé '$key' manquante dans la section [Github] de project.ini"
    else
        echo "$val"
    fi
}

# ------------------------------------------------------------------------------
# Fonction : confirm_pull()
# Liste des Paramètres : aucun
# Description          : Demande confirmation à l'utilisateur avant la mise à jour
# ------------------------------------------------------------------------------
confirm_pull() {

    # Affichage du titre de confirmation
    echo "════════════════════════════════════════════════════════════"
    echo "         MISE À JOUR DU PROJET DEPUIS GITHUB                "
    echo "════════════════════════════════════════════════════════════"
    echo ""
    printf " %-18s : %s\n" "Utilisateur" "${REAL_USER:-$USER}"
    printf " %-18s : %s\n" "Dossier projet" "$SCRIPT_DIR"
    echo ""
    echo " Cette opération va synchroniser les fichiers avec le dépôt distant."
    echo " Les fichiers non versionnés restent intacts."
    echo ""

    # Boucle de confirmation oui/non
    while true; do
        read -rp " Confirmer la mise à jour (oui/non) : " INPUT_CONFIRM
        CONFIRM=$(to_lowercase "$INPUT_CONFIRM")
        echo ""

        case "$CONFIRM" in
            oui)
                success "Mise à jour confirmée"
                return 0
                ;;
            non)
                info "Mise à jour annulée par l'utilisateur"
                exit 0
                ;;
            *)
                echo "Choix invalide. Veuillez répondre par 'oui' ou 'non'."
                echo ""
                ;;
        esac
    done
}

# ------------------------------------------------------------------------------
# Chemins absolus et configuration du projet
# ------------------------------------------------------------------------------

# Chemin absolu du script et de son répertoire
SCRIPT_DIR="$(pwd)"
# Fichier de configuration du projet
CONFIG_PROJECT="$SCRIPT_DIR/project.ini"

# Vérification de la présence du fichier ini
[[ -f "$CONFIG_PROJECT" ]] || error "Fichier project.ini manquant dans $SCRIPT_DIR"

# Détermination de l'utilisateur réel (gestion sudo)
if [[ "$EUID" -eq 0 && -n "${SUDO_USER:-}" ]]; then
    REAL_USER="$SUDO_USER"
else
    REAL_USER="$USER"
fi

# ------------------------------------------------------------------------------
# Confirmation utilisateur
# ------------------------------------------------------------------------------

# Demande explicite avant toute modification
confirm_pull

# ------------------------------------------------------------------------------
# Lecture des paramètres GitHub depuis project.ini
# ------------------------------------------------------------------------------

# Information sur le chargement des credentials
info "Lecture des paramètres GitHub..."
GIT_USER=$(get_config_value user)
GIT_TOKEN=$(get_config_value token)
GIT_NAME=$(get_config_value name "ArchKitty")
GIT_EMAIL=$(get_config_value email "chaton.garou@gmail.com")

# Nom du projet et URL du remote avec token
PROJECT_NAME="$(basename "$SCRIPT_DIR")"
REMOTE_URL="https://$GIT_USER:$GIT_TOKEN@github.com/$GIT_USER/$PROJECT_NAME.git"

# Confirmation du chargement
success "Paramètres GitHub chargés pour $GIT_USER"

# ------------------------------------------------------------------------------
# Configuration de l'identité Git
# ------------------------------------------------------------------------------

# Définition des identités pour author et committer
export GIT_AUTHOR_NAME="$GIT_NAME"
export GIT_AUTHOR_EMAIL="$GIT_EMAIL"
export GIT_COMMITTER_NAME="$GIT_NAME"
export GIT_COMMITTER_EMAIL="$GIT_EMAIL"

# ------------------------------------------------------------------------------
# Vérifications préalables Git
# ------------------------------------------------------------------------------

# Vérification de l'existence d'un dépôt local
info "Vérification de la présence d'un dépôt Git local..."
[[ -d ".git" ]] || error "Aucun dépôt Git détecté dans $SCRIPT_DIR"

# Configuration ou mise à jour du remote origin
info "Configuration du remote origin..."
if ! git remote | grep -q "^origin$"; then
    git remote add origin "$REMOTE_URL"
else
    git remote set-url origin "$REMOTE_URL"
fi

# ------------------------------------------------------------------------------
# Détection de la branche par défaut distante
# ------------------------------------------------------------------------------

# Récupération des références distantes
info "Détection de la branche par défaut distante..."
git fetch origin --quiet

# Détermination robuste de la branche par défaut
if git symbolic-ref refs/remotes/origin/HEAD >/dev/null 2>&1; then
    DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')
else
    DEFAULT_BRANCH=$(git ls-remote --symref origin HEAD | awk '/^ref: /{gsub(/refs\/heads\//,"",$2); print $2; exit}')
    [[ -z "$DEFAULT_BRANCH" ]] && { git ls-remote origin main >/dev/null 2>&1 && DEFAULT_BRANCH=main || DEFAULT_BRANCH=master; }
fi

# Confirmation de la branche détectée
success "Branche distante détectée : $DEFAULT_BRANCH"

# ------------------------------------------------------------------------------
# Gestion des modifications locales (stash automatique)
# ------------------------------------------------------------------------------

# Indicateur de stash effectué
STASHED=false
# Détection des modifications locales non commitées
if ! git diff --quiet || ! git diff --cached --quiet; then
    info "Modifications locales détectées → stash automatique"
    git stash push -m "github_pull.sh $(date '+%Y-%m-%d %H:%M')" --quiet
    STASHED=true
fi

# ------------------------------------------------------------------------------
# Mise à jour forcée depuis la branche distante
# ------------------------------------------------------------------------------

# Synchronisation forcée avec la branche distante
info "Synchronisation avec origin/$DEFAULT_BRANCH..."
git checkout "$DEFAULT_BRANCH" 2>/dev/null || git switch -c "$DEFAULT_BRANCH" --track "origin/$DEFAULT_BRANCH"
git fetch origin "$DEFAULT_BRANCH" --quiet
git reset --hard "origin/$DEFAULT_BRANCH" --quiet
git submodule update --init --recursive --quiet 2>/dev/null || true

# Confirmation de la synchronisation
success "Projet synchronisé avec le dépôt distant"

# ------------------------------------------------------------------------------
# Restauration des modifications locales
# ------------------------------------------------------------------------------

# Restauration du stash si effectué
if [[ "$STASHED" = true ]]; then
    info "Restauration des modifications locales (stash pop)..."
    if git stash pop --quiet; then
        success "Modifications locales restaurées sans conflit"
    else
        echo "[INFO]  Conflits détectés lors du stash pop"
        echo "        Résolvez-les manuellement avec : git stash pop"
    fi
fi

# ------------------------------------------------------------------------------
# Finalisation et message de succès
# ------------------------------------------------------------------------------

# Affichage final récapitulatif
echo ""
echo "════════════════════════════════════════════════════════════"
echo "             MISE À JOUR GITHUB TERMINÉE AVEC SUCCÈS        "
echo "════════════════════════════════════════════════════════════"
echo ""
printf " %-18s : %s\n" "Projet" "$PROJECT_NAME"
printf " %-18s : %s\n" "Branche" "$DEFAULT_BRANCH"
printf " %-18s : %s\n" "Commit actuel" "$(git rev-parse --short HEAD)"
printf " %-18s : %s\n" "Dépôt distant" "https://github.com/$GIT_USER/$PROJECT_NAME"
echo ""
echo " Les fichiers non versionnés sont préservés."
echo " Vos modifications locales ont été restaurées (si conflits → à résoudre)."
echo ""
echo "════════════════════════════════════════════════════════════"
echo ""