#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Nom du script       : github_create_or_clone.sh
# Version             : 1.0.0
# Auteur              : archsystem-dev
# Date de modification: 14 décembre 2025
# Description         : Crée un dépôt privé GitHub si inexistant ou clone le dépôt
#                       existant, initialise Git localement et effectue le premier
#                       push avec les identifiants configurés dans github.ini.
# ------------------------------------------------------------------------------

# Activation des options strictes pour une exécution robuste et sécurisée
# Pourquoi : arrête le script en cas d'erreur, variable non définie ou pipeline
set -euo pipefail

# Définition des séparateurs internes pour éviter les problèmes avec espaces
IFS=$'\n\t'

# ------------------------------------------------------------------------------
# Fonctions utilitaires d'affichage standardisées
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Nom de la fonction   : info()
# Liste des Paramètres : "$@" (message à afficher)
# Description          : Affiche un message informatif précédé de [INFO]
# ------------------------------------------------------------------------------
info() {
    printf "[INFO]  %s\n" "$*"
}

# ------------------------------------------------------------------------------
# Nom de la fonction   : success()
# Liste des Paramètres : "$@" (message à afficher)
# Description          : Affiche un message de succès précédé de [OK]
# ------------------------------------------------------------------------------
success() {
    printf "[OK]    %s\n" "$*"
}

# ------------------------------------------------------------------------------
# Nom de la fonction   : error()
# Liste des Paramètres : "$@" (message d'erreur)
# Description          : Affiche un message d'erreur précédé de [ERREUR] et quitte
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
# Pourquoi : les opérations Git doivent se faire en utilisateur standard
[[ "$EUID" -ne 0 ]] || error "Ce script ne doit pas être exécuté avec sudo ou en root."

# Confirmation du mode d'exécution correct
success "Exécution en utilisateur standard confirmée"

# ------------------------------------------------------------------------------
# Nom de la fonction   : get_config_value()
# Liste des Paramètres : $1 fichier ini, $2 section, $3 clé
# Description          : Extrait une valeur du fichier ini via crudini,
#                        gère les erreurs et substitue $USER si présent.
# ------------------------------------------------------------------------------
get_config_value() {
    local file=$1 section=$2 key=$3
    local val

    # Tentative de lecture avec crudini, valeur vide si absent ou erreur
    val=$(crudini --get "$file" "$section" "$key" 2>/dev/null || echo "")

    # Erreur fatale si la clé est obligatoire et absente
    [[ -n "$val" ]] || error "Clé '$key' manquante dans la section [$section] du fichier $file"

    # Substitution de $USER par la valeur réelle de l'utilisateur
    echo "$val" | sed "s|\$USER|$USER|g"
}

# ------------------------------------------------------------------------------
# Détermination des répertoires SCRIPT_DIR et PROJECT_DIR
# ------------------------------------------------------------------------------

# Utilisation des arguments si fournis correctement (deux dossiers existants)
if [[ $# -eq 2 ]] && [[ -d "$1" ]] && [[ -d "$2" ]]; then
    # Normalisation des chemins fournis
    SCRIPT_DIR="$(realpath -m "$1")"
    PROJECT_DIR="$(realpath -m "$2")"
else
    # Fallback sur le répertoire courant si arguments absents ou invalides
    SCRIPT_DIR="$(pwd)"
    PROJECT_DIR="$(pwd)"

    # Avertissement si des arguments ont été fournis mais sont incorrects
    if [[ $# -ne 0 ]]; then
        info "Arguments fournis incorrects ou incomplets."
        info "Utilisation du répertoire courant pour SCRIPT_DIR et PROJECT_DIR."
    fi
fi

# ------------------------------------------------------------------------------
# Affichage et confirmation des répertoires choisis
# ------------------------------------------------------------------------------

# Affichage clair des répertoires sélectionnés
echo ""
echo "════════════════════════════════════════════════════════════"
echo "           CONFIGURATION DES RÉPERTOIRES                    "
echo "════════════════════════════════════════════════════════════"
echo ""
printf " %-18s : %s\n" "Répertoire scripts" "$SCRIPT_DIR"
printf " %-18s : %s\n" "Répertoire projet"  "$PROJECT_DIR"
echo ""
echo "Le script va utiliser ces deux répertoires."
# Demande de confirmation explicite à l'utilisateur
read -rp "Confirmez-vous ces choix ? (oui) : " confirm

# Normalisation de la réponse (minuscules, suppression espaces)
confirm="${confirm,,}"
confirm="${confirm// /}"

# Annulation si réponse non affirmative
[[ "$confirm" == "oui" ]] || error "Opération annulée par l'utilisateur."

# Confirmation de la poursuite
info "Confirmation reçue. Poursuite du script..."

# ------------------------------------------------------------------------------
# Préparation finale des chemins et du nom du projet
# ------------------------------------------------------------------------------

# Création des répertoires si inexistants
mkdir -p "$PROJECT_DIR" || error "Impossible de créer $PROJECT_DIR"
mkdir -p "$SCRIPT_DIR" || error "Impossible de créer $SCRIPT_DIR"

# Extraction du nom du projet depuis le chemin
PROJECT_NAME="$(basename "$PROJECT_DIR")"

# Positionnement dans le répertoire des scripts pour résolution relative
cd "$SCRIPT_DIR" || error "Impossible d'accéder à $SCRIPT_DIR"

# Chemin complet vers le fichier de configuration du projet
CONFIG_PROJECT="$PROJECT_DIR/github.ini"

# Vérification de la présence du fichier ini obligatoire
[[ -f "$CONFIG_PROJECT" ]] || error "Fichier de configuration manquant : $CONFIG_PROJECT"

# ------------------------------------------------------------------------------
# Chargement des paramètres GitHub depuis github.ini
# ------------------------------------------------------------------------------

# Information sur le chargement des credentials
info "Lecture des paramètres GitHub depuis github.ini..."

# Extraction sécurisée des valeurs requises
GIT_USER=$(get_config_value "$CONFIG_PROJECT" Github user)
GIT_TOKEN=$(get_config_value "$CONFIG_PROJECT" Github token)
GIT_NAME=$(get_config_value "$CONFIG_PROJECT" Github name)
GIT_EMAIL=$(get_config_value "$CONFIG_PROJECT" Github email)

# Confirmation du chargement réussi
success "Paramètres GitHub chargés pour l'utilisateur $GIT_USER"

# ------------------------------------------------------------------------------
# Vérification de l'existence du dépôt distant
# ------------------------------------------------------------------------------

# Information sur la vérification distante
info "Vérification de l'existence du dépôt GitHub $PROJECT_NAME..."

# Test d'existence via l'API GitHub (succès si code 200)
if curl -f -s -u "$GIT_USER:$GIT_TOKEN" \
    "https://api.github.com/repos/$GIT_USER/$PROJECT_NAME" >/dev/null; then

    # Cas : dépôt existant → procédure de clonage
    info "Dépôt existant détecté → clonage en cours..."

    cd "$PROJECT_DIR" || error "Impossible d'accéder à $PROJECT_DIR"

    # Clonage temporaire pour récupérer uniquement le répertoire .git
    mkdir -p .tmp_clone
    GIT_TERMINAL_PROMPT=0 git clone --quiet \
        "https://$GIT_USER:$GIT_TOKEN@github.com/$GIT_USER/$PROJECT_NAME.git" .tmp_clone

    mv .tmp_clone/.git .
    rm -rf .tmp_clone
    git reset --hard HEAD --quiet

    success "Clonage du dépôt terminé avec succès"
else
    # Cas : dépôt inexistant → création et initialisation locale

    # Copie des templates backend/frontend sauf pour le kit de base
    if [[ "$PROJECT_NAME" != "fullstack-kit" ]]; then
        cp -R "$SCRIPT_DIR/backend" "$PROJECT_DIR/"
        cp -R "$SCRIPT_DIR/frontend" "$PROJECT_DIR/"
    fi

    # Création du dépôt privé via l'API GitHub
    info "Dépôt inexistant → création d'un dépôt privé sur GitHub..."

    curl -u "$GIT_USER:$GIT_TOKEN" https://api.github.com/user/repos -d '{
        "name": "'"$PROJECT_NAME"'",
        "private": true,
        "description": "Projet créé automatiquement via github_create_or_clone.sh"
    }' >/dev/null 2>&1

    success "Dépôt GitHub privé créé avec succès"

    # Initialisation locale et premier commit
    info "Initialisation Git locale et premier commit..."

    cd "$PROJECT_DIR" || error "Impossible d'accéder à $PROJECT_DIR"

    git init -q
    git checkout -b main

    # Configuration des identités pour author et committer
    export GIT_AUTHOR_NAME="$GIT_NAME"
    export GIT_AUTHOR_EMAIL="$GIT_EMAIL"
    export GIT_COMMITTER_NAME="$GIT_NAME"
    export GIT_COMMITTER_EMAIL="$GIT_EMAIL"

    # Ajout du remote avec authentification intégrée
    git remote add origin "https://$GIT_USER:$GIT_TOKEN@github.com/$GIT_USER/$PROJECT_NAME.git" \
        2>/dev/null || git remote set-url origin "https://$GIT_USER:$GIT_TOKEN@github.com/$GIT_USER/$PROJECT_NAME.git"

    git add .
    git commit --quiet --author="$GIT_NAME <$GIT_EMAIL>" -m "Initial commit"
    git branch -M main
    GIT_TERMINAL_PROMPT=0 git push --quiet -u origin main

    success "Premier push effectué avec succès"
fi

# ------------------------------------------------------------------------------
# Affichage final récapitulatif
# ------------------------------------------------------------------------------

# Récapitulatif final de l'opération
echo ""
echo "════════════════════════════════════════════════════════════"
echo "          DÉPÔT GITHUB CONFIGURÉ AVEC SUCCÈS                 "
echo "════════════════════════════════════════════════════════════"
echo ""

printf " %-18s : %s\n" "Projet" "$PROJECT_NAME"
printf " %-18s : %s\n" "Utilisateur GitHub" "$GIT_USER"
printf " %-18s : %s\n" "URL du dépôt" "https://github.com/$GIT_USER/$PROJECT_NAME"

echo ""
echo " Le dépôt est prêt à l'emploi (créé ou cloné)."
echo " Vous pouvez maintenant utiliser github_push.sh et github_pull.sh."
echo ""
echo "════════════════════════════════════════════════════════════"
echo ""