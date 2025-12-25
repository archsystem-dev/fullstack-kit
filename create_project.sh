#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Nom du script       : create_project.sh
# Version             : 1.0.0
# Auteur              : archsystem-dev
# Date de modification: 14 décembre 2025
# Description         : Crée un nouveau projet web FastAPI/Vue avec environnements
#                       npm (frontend), Conda (backend) et base PostgreSQL, à
#                       partir d'une configuration interactive et d'un
#                       fichier .ini.
# ------------------------------------------------------------------------------

# Activation des options strictes pour robustesse et sécurité
# Pourquoi : arrête sur erreur, variable non définie ou pipeline échoué
set -euo pipefail

# Séparateurs internes sécurisés pour gérer espaces dans chemins/noms
IFS=$'\n\t'

# ------------------------------------------------------------------------------
# Fonctions utilitaires d'affichage
# Description : Fournissent un affichage standardisé avec préfixes [INFO], [OK], [ERREUR]
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Nom de la fonction   : info()
# Liste des Paramètres : "$@" (message à afficher)
# Description          : Affiche un message informatif avec préfixe [INFO]
# ------------------------------------------------------------------------------
info() {
    echo "[INFO] $*"
}

# ------------------------------------------------------------------------------
# Nom de la fonction   : success()
# Liste des Paramètres : "$@" (message à afficher)
# Description          : Affiche un message de succès avec préfixe [OK]
# ------------------------------------------------------------------------------
success() {
    echo "[OK]   $*"
}

# ------------------------------------------------------------------------------
# Nom de la fonction   : error()
# Liste des Paramètres : "$@" (message à afficher)
# Description          : Affiche un message d'erreur avec [ERREUR] et quitte le script
# ------------------------------------------------------------------------------
error() {
    echo "[ERREUR] $*" >&2
    exit 1
}

# ------------------------------------------------------------------------------
# Fonction   : to_lowercase()
# Paramètres : $1 - Chaîne à convertir
# Description: Convertit une chaîne en minuscules de manière POSIX-compatible
# ------------------------------------------------------------------------------
to_lowercase() {
    echo "${1,,}"
}

# ------------------------------------------------------------------------------
# Fonction   : get_config_value()
# Paramètres : $1 fichier ini, $2 section, $3 clé
# Description: Lit une valeur depuis un fichier .ini via crudini et substitue $USER
# ------------------------------------------------------------------------------
get_config_value() {
    local file=$1 section=$2 key=$3
    local val
    # Lecture de la valeur ; erreur si absente
    val=$(crudini --get "$file" "$section" "$key" 2>/dev/null || echo "")
    [ -n "$val" ] || error "Clé $key manquante dans [$section] ($file)"
    # Substitution de $USER par l'utilisateur réel
    echo "$val" | sed "s|\$USER|$REAL_USER|g"
}

# ------------------------------------------------------------------------------
# Fonction   : create_symlink()
# Paramètres : $1 source, $2 destination
# Description: Crée un lien symbolique en gérant proprement les cas existants
# ------------------------------------------------------------------------------
create_symlink() {
    local src="$1" dest="$2"

    # Suppression propre si lien ou fichier existant
    if [ -L "$dest" ]; then
        rm "$dest"
    elif [ -f "$dest" ]; then
        rm "$dest"
    elif [ ! -d "$(dirname "$dest")" ]; then
        # Création du répertoire parent si nécessaire
        mkdir -p "$(dirname "$dest")"
    fi

    # Création du lien symbolique
    ln -s "$src" "$dest"
    # Ajustement du propriétaire du lien
    chown -h "$REAL_USER":"$REAL_GROUP" "$dest"
}

# ------------------------------------------------------------------------------
# Variables globales et vérifications initiales
# ------------------------------------------------------------------------------

# Le script doit être exécuté en root via sudo
# Pourquoi : opérations privilégiées (PostgreSQL, systemctl, etc.)
if [ "$EUID" -ne 0 ]; then
    error "Ce script doit être exécuté avec sudo."
fi

# Récupération de l'utilisateur réel ayant lancé sudo
# Pourquoi : toutes les créations appartiennent à cet utilisateur
REAL_USER="${SUDO_USER:-}"
[ -n "$REAL_USER" ] || error "Impossible de déterminer l'utilisateur réel (sudo non détecté)."

# Détermination du home et groupe primaire de l'utilisateur réel
REAL_HOME="$(getent passwd "$REAL_USER" | cut -d: -f6)"
REAL_GROUP="$(id -gn "$REAL_USER")"

# Chemin absolu du script et de son répertoire
SCRIPT_DIR="$(pwd)"
# Fichier de configuration globale
CONFIG_INSTALL_FILE="$SCRIPT_DIR/install_softwares.ini"

# Préfixes pour noms PostgreSQL
PG_DB_PREFIX="db_"
PG_USER_PREFIX="usr_"

# ------------------------------------------------------------------------------
# Fonction   : project_config()
# Description: Boucle interactive de saisie et validation de la configuration projet
# ------------------------------------------------------------------------------

project_config() {

    # Affichage du titre du configurateur
    echo ""
    echo "════════════════════════════════════════════════════════════"
    echo "          CONFIGURATEUR DE PROJET WEB FASTAPI/VUE           "
    echo "════════════════════════════════════════════════════════════"
    echo " Script lancé par : $REAL_USER (home: $REAL_HOME)"
    echo "════════════════════════════════════════════════════════════"
    echo ""

    # Boucle principale jusqu'à validation
    while true; do
        # Saisie du nom du projet (converti en minuscules)
        read -rp " Nom du projet (PROJECT_NAME) : " INPUT_PROJECT_NAME
        PROJECT_NAME=$(to_lowercase "$INPUT_PROJECT_NAME")

        # Saisie de la version Python
        read -rp " Version de Python souhaitée (ex: 3.13) : " PYTHON_VERSION

        # Saisie du mot de passe PostgreSQL
        read -rp " Mot de passe par défaut PostgreSQL : " PG_PASSWORD
        echo ""

        # Récapitulatif de la configuration saisie
        echo ""
        echo "════════════════════════════════════════════════════════════"
        echo "             RÉCAPITULATIF DE LA CONFIGURATION               "
        echo "════════════════════════════════════════════════════════════"
        printf " %-18s : %s\n" "PROJECT_NAME" "$PROJECT_NAME"
        printf " %-18s : %s\n" "PYTHON_VERSION" "$PYTHON_VERSION"
        echo "────────────────────────────────────────────────────────────"
        printf " %-18s : %s\n" "PG_DATABASE" "$PG_DB_PREFIX$PROJECT_NAME"
        printf " %-18s : %s\n" "PG_USER" "$PG_USER_PREFIX$PROJECT_NAME"
        printf " %-18s : %s\n" "PG_PASSWORD" "$PG_PASSWORD"
        echo "════════════════════════════════════════════════════════════"
        echo ""

        # Menu de validation
        while true; do
            echo " Options :"
            echo " 1) Créer le projet"
            echo " 2) Recommencer la configuration"
            echo " 3) Quitter"
            echo ""
            read -rp " Votre choix (1/2/3) : " choice

            case "$choice" in
                1|"")
                    info "Configuration validée."
                    return 0
                    ;;
                2)
                    info "Reconfiguration demandée."
                    echo ""
                    break
                    ;;
                3)
                    info "Création annulée par l'utilisateur."
                    exit 0
                    ;;
                *)
                    error "Choix invalide. Veuillez entrer 1, 2 ou 3."
                    ;;
            esac
        done
    done
}

# Lancement du configurateur interactif
project_config

# ------------------------------------------------------------------------------
# Lecture configuration générale depuis install_softwares.ini
# ------------------------------------------------------------------------------

# Récupération des chemins globaux depuis le fichier .ini
PROJECTS_DIR=$(get_config_value "$CONFIG_INSTALL_FILE" General projects_dir)
MINICONDA_PATH=$(get_config_value "$CONFIG_INSTALL_FILE" Miniconda install_dir)

# ------------------------------------------------------------------------------
# Définition des chemins du projet
# ------------------------------------------------------------------------------

# Chemins dérivés du nom du projet
PROJECT_DIR="$PROJECTS_DIR/$PROJECT_NAME"
FRONTEND_DIR="$PROJECT_DIR/frontend"
BACKEND_DIR="$PROJECT_DIR/backend"
DB_NAME="$PG_DB_PREFIX$PROJECT_NAME"
PG_USER="$PG_USER_PREFIX$PROJECT_NAME"

# ------------------------------------------------------------------------------
# Vérifications préalables anti-écrasement
# ------------------------------------------------------------------------------

# Vérifications pour éviter les écrasements accidentels
info "Vérifications préalables..."
[ -d "$PROJECT_DIR" ] && error "Le répertoire $PROJECT_DIR existe déjà."
sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='$PG_USER'" | grep -q 1 \
    && error "L'utilisateur PostgreSQL $PG_USER existe déjà."
success "Vérifications passées – création possible."

# Chargement de Conda pour root
# Pourquoi : nécessaire pour créer l'environnement Conda
[ -f "$MINICONDA_PATH/etc/profile.d/conda.sh" ] && . "$MINICONDA_PATH/etc/profile.d/conda.sh" \
    || error "Fichier conda.sh introuvable dans $MINICA_PATH."

# ------------------------------------------------------------------------------
# Création des répertoires projet
# ------------------------------------------------------------------------------

# Création de la structure de répertoires
info "Création des répertoires projet..."
mkdir -p "$FRONTEND_DIR" "$BACKEND_DIR"
# Attribution des droits à l'utilisateur réel
chown -R "$REAL_USER":"$REAL_GROUP" "$PROJECT_DIR"
chmod -R 755 "$PROJECT_DIR"

# ------------------------------------------------------------------------------
# Initialisation npm (frontend)
# ------------------------------------------------------------------------------

# Initialisation du projet npm en tant qu'utilisateur réel
info "Initialisation de l'environnement npm (frontend)..."
su - "$REAL_USER" -c "
    cd \"$FRONTEND_DIR\"
    npm init -y >/dev/null
    npm install express --save >/dev/null 2>&1
"
success "Frontend npm initialisé"

# ------------------------------------------------------------------------------
# Création environnement Conda (backend)
# ------------------------------------------------------------------------------

# Création de l'environnement Conda dédié
info "Création de l'environnement Conda (backend)..."
conda create -p "$BACKEND_DIR/conda" python="$PYTHON_VERSION" -y >/dev/null
chown -R "$REAL_USER":"$REAL_GROUP" "$BACKEND_DIR"
success "Environnement Conda créé"

# ------------------------------------------------------------------------------
# Configuration PostgreSQL
# ------------------------------------------------------------------------------

# Création rôle et base de données
info "Création de l'utilisateur et de la base PostgreSQL..."
sudo -u postgres psql <<-EOF
  CREATE ROLE "$PG_USER" WITH LOGIN PASSWORD '$PG_PASSWORD' CREATEDB INHERIT;
  CREATE DATABASE "$DB_NAME" OWNER "$PG_USER" ENCODING 'UTF8' TEMPLATE template0;
EOF

# Ajout de la règle d'authentification si absente
PG_HBA_LINE="host    all             $PG_USER             127.0.0.1/32            md5"
if ! grep -qF "$PG_HBA_LINE" /etc/postgresql/*/main/pg_hba.conf 2>/dev/null; then
    echo "$PG_HBA_LINE" | tee -a /etc/postgresql/*/main/pg_hba.conf >/dev/null
fi

# Redémarrage et attente de disponibilité
systemctl restart postgresql
until pg_isready -h 127.0.0.1 -p 5432 >/dev/null 2>&1; do sleep 1; done
success "PostgreSQL configuré"

# ------------------------------------------------------------------------------
# Création des liens symboliques et copie des fichiers de configuration
# ------------------------------------------------------------------------------

# Création des liens vers les scripts du kit
info "Création des liens symboliques vers les scripts du kit..."
for script in install_packages.sh api_dev.sh api_start.sh api_stop.sh \
              nginx_reload.sh npm_dist_generate.sh github_create_or_clone.sh \
              github_push.sh github_pull.sh launch_dev.sh launch_test_prod.sh \
              npm_dev.sh; do
    [ -f "$SCRIPT_DIR/$script" ] && create_symlink "$SCRIPT_DIR/$script" "$PROJECT_DIR/$script"
done

# Copie et personnalisation des fichiers de configuration
[ -f "$SCRIPT_DIR/nginx.conf" ] && {
    cp "$SCRIPT_DIR/nginx.conf" "$PROJECT_DIR/nginx.conf"
    sed -i "s|{PROJECT_DIR}|${PROJECT_DIR}|g" "$PROJECT_DIR/nginx.conf"
}

[ -f "$SCRIPT_DIR/gitignore.conf" ] && {
    cp "$SCRIPT_DIR/gitignore.conf" "$PROJECT_DIR/.gitignore"
}

# ------------------------------------------------------------------------------
# Création d'un project.ini
# ------------------------------------------------------------------------------

PROJECT_INI="$PROJECT_DIR/project.ini"
cat > "$PROJECT_INI" << 'EOF'
[Github]
user=
token=
name=
email=

[General]
EOF

# ------------------------------------------------------------------------------
# Mise à jour simple de backend/config.json (fichier déjà présent)
# ------------------------------------------------------------------------------

info "Mise à jour de backend/config.json..."

CONFIG_JSON="$BACKEND_DIR/config.json"

# Vérif existence (sécurité minimale)
[ -f "$CONFIG_JSON" ] || error "Le fichier $CONFIG_JSON n'existe pas dans le template backend !"

# Récupération Redis depuis install_softwares.ini (via fonction existante)
REDIS_PASSWORD=$(get_config_value "$CONFIG_INSTALL_FILE" Redis password || echo "secure_password_123")
REDIS_PORT=$(get_config_value "$CONFIG_INSTALL_FILE" Redis port || echo "6379")
REDIS_DB=$(get_config_value "$CONFIG_INSTALL_FILE" Redis db || echo "0")

# Échappement basique des caractères problématiques pour sed (/ & \)
ESC_PG_PASSWORD=$(echo "$PG_PASSWORD" | sed 's/[\/&]/\\&/g')
ESC_REDIS_PASSWORD=$(echo "$REDIS_PASSWORD" | sed 's/[\/&]/\\&/g')

# Mise à jour des 6 lignes concernées avec sed (style déjà utilisé dans le script)
sed -i "s/\"DB_NAME\": *\"[^\"]*\"/\"DB_NAME\": \"$DB_NAME\"/"     "$CONFIG_JSON"
sed -i "s/\"DB_USER\": *\"[^\"]*\"/\"DB_USER\": \"$PG_USER\"/"     "$CONFIG_JSON"
sed -i "s/\"DB_PASSWORD\": *\"[^\"]*\"/\"DB_PASSWORD\": \"$ESC_PG_PASSWORD\"/" "$CONFIG_JSON"

sed -i "s/\"REDIS_PORT\": *[0-9]*/\"REDIS_PORT\": $REDIS_PORT/"    "$CONFIG_JSON"
sed -i "s/\"REDIS_PASSWORD\": *\"[^\"]*\"/\"REDIS_PASSWORD\": \"$ESC_REDIS_PASSWORD\"/" "$CONFIG_JSON"
sed -i "s/\"REDIS_DB\": *[0-9]*/\"REDIS_DB\": $REDIS_DB/"          "$CONFIG_JSON"

# Ajustement final des permissions
sudo chown -R "$REAL_USER":"$REAL_GROUP" "$PROJECT_DIR/"
sudo chmod -R 755 "$PROJECT_DIR/"

# Nettoyage du package-lock.json généré inutilement
rm -f "$FRONTEND_DIR/package-lock.json"

# ------------------------------------------------------------------------------
# Gestion du dépôt GitHub
# ------------------------------------------------------------------------------

# Délégation à un script dédié pour création/clonage GitHub
info "Création ou clonage du dépôt GitHub..."
sudo -u "$REAL_USER" bash "$SCRIPT_DIR/github_create_or_clone.sh" "$SCRIPT_DIR" "$PROJECT_DIR"

# ------------------------------------------------------------------------------
# Vérifications finales des environnements
# ------------------------------------------------------------------------------

# Affichage du titre de vérification
echo ""
echo "════════════════════════════════════════════════════════════"
echo "              VÉRIFICATION DES ENVIRONNEMENTS                "
echo "════════════════════════════════════════════════════════════"
echo " Vérifications :"

# Test npm
su - "$REAL_USER" -c "cd \"$FRONTEND_DIR\" && npm list express >/dev/null" \
    && echo " npm        : OK" || echo " npm        : ÉCHEC"

# Test Conda
conda activate "$BACKEND_DIR/conda" && python -c "import sys" >/dev/null && conda deactivate \
    && echo " Conda      : OK" || echo " Conda      : ÉCHEC"

# Test PostgreSQL
export PGPASSWORD="$PG_PASSWORD"
psql -U "$PG_USER" -h 127.0.0.1 -d "$DB_NAME" -c "\q" >/dev/null 2>&1 \
    && echo " PostgreSQL : OK" || echo " PostgreSQL : ÉCHEC"
unset PGPASSWORD

# ------------------------------------------------------------------------------
# Finalisation et récapitulatif
# ------------------------------------------------------------------------------

# Dernier ajustement des permissions
chown -R "$REAL_USER":"$REAL_GROUP" "$PROJECT_DIR"

# Affichage final de succès avec récapitulatif
echo ""
echo "════════════════════════════════════════════════════════════"
echo "                PROJET CRÉÉ AVEC SUCCÈS                     "
echo "════════════════════════════════════════════════════════════"
printf " %-18s : %s\n" "Projet" "$PROJECT_NAME"
printf " %-18s : %s\n" "Dossier" "$PROJECT_DIR"
printf " %-18s : %s\n" "Propriétaire" "$REAL_USER"
printf " %-18s : %s\n" "Base de données" "$DB_NAME"
printf " %-18s : %s\n" "Utilisateur DB" "$PG_USER"
printf " %-18s : %s\n" "Mot de passe DB" "$PG_PASSWORD"
echo "════════════════════════════════════════════════════════════"
echo ""