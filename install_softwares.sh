#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Nom du script       : install_softwares.sh
# Version             : 1.0.0
# Auteur              : archsystem-dev
# Date de modification: 13 décembre 2025
# Description         : Installe et configure Miniconda, PostgreSQL, Redis, Nginx,
#                       Node.js/npm avec les paramètres définis dans install_softwares.ini,
#                       nettoie les installations précédentes et prépare l'environnement
#                       pour les projets full-stack.
# ------------------------------------------------------------------------------

# Activation des options strictes pour une exécution robuste
set -euo pipefail

# Séparateurs internes sécurisés
IFS=$'\n\t'

# ------------------------------------------------------------------------------
# Fonctions utilitaires d'affichage
# ------------------------------------------------------------------------------

# Affiche un message informatif avec préfixe [INFO]
info() {
    printf "[INFO]  %s\n" "$*" >&2
}

# Affiche un message de succès avec préfixe [OK]
success() {
    printf "[OK]    %s\n" "$*" >&2
}

# Affiche un message d'erreur avec préfixe [ERREUR] puis quitte
error() {
    printf "[ERREUR] %s\n" "$*" >&2
    exit 1
}

# ------------------------------------------------------------------------------
# Fonction : get_config_value()
# Liste des Paramètres : $1 → section, $2 → clé
# Description          : Lit une valeur dans install_softwares.ini via crudini et
#                       remplace $USER par le nom de l'utilisateur réel
# ------------------------------------------------------------------------------

get_config_value() {
    local section=$1 key=$2
    local val
    val=$(crudini --get "$CONFIG_FILE" "$section" "$key" 2>/dev/null || echo "")
    [[ -n "$val" ]] || error "Clé '$key' manquante dans la section [$section]"
    echo "$val" | sed "s|\$USER|$REAL_USER|g"
}

# ------------------------------------------------------------------------------
# Fonction : add_block()
# Liste des Paramètres : $1 → marqueur, $2 → contenu du bloc
# Description          : Ajoute un bloc délimité dans le .bashrc de l'utilisateur
#                       réel si absent
# ------------------------------------------------------------------------------

add_block() {
    local marker="$1"
    local content="$2"

    if grep -q "^# >>> $marker >>>$" "$USER_BASHRC"; then
        info "Bloc « $marker » déjà présent dans $USER_BASHRC"
    else
        info "Ajout du bloc « $marker » dans $USER_BASHRC"
        printf '\n# >>> %s >>>\n%s# <<< %s <<<\n' "$marker" "$content" "$marker" >> "$USER_BASHRC"
        success "Bloc « $marker » ajouté"
    fi
}

# ------------------------------------------------------------------------------
# Vérifications préliminaires : privilèges et utilisateur réel
# ------------------------------------------------------------------------------

info "Vérification des privilèges root..."
[[ "$EUID" -eq 0 ]] || error "Ce script doit être exécuté avec sudo."

[[ -n "${SUDO_USER:-}" ]] || error "Impossible de détecter l'utilisateur réel (sudo requis)."

REAL_USER="$SUDO_USER"
REAL_GROUP="$(id -gn "$REAL_USER")"
USER_HOME="$(getent passwd "$REAL_USER" | cut -d: -f6)"
USER_BASHRC="$USER_HOME/.bashrc"

success "Utilisateur réel : $REAL_USER (home: $USER_HOME, groupe: $REAL_GROUP)"

# ------------------------------------------------------------------------------
# Chemins absolus et fichier de configuration
# ------------------------------------------------------------------------------

SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"
CONFIG_FILE="$SCRIPT_DIR/install_softwares.ini"

[[ -f "$CONFIG_FILE" ]] || error "Fichier de configuration manquant : $CONFIG_FILE"

# ------------------------------------------------------------------------------
# Installation de crudini si nécessaire
# ------------------------------------------------------------------------------

info "Vérification de la présence de crudini, curl et git..."
if ! command -v crudini &>/dev/null; then
    info "Installation de crudini, curl et git..."
    apt update && apt install -y crudini curl git
    success "Outils complémentaires installés"
fi

# ------------------------------------------------------------------------------
# Lecture des paramètres depuis install_softwares.ini
# ------------------------------------------------------------------------------

info "Lecture de la configuration globale..."
PROJECTS_DIR=$(get_config_value General projects_dir)

PG_USER=$(get_config_value PostgreSQL user)
PG_PASSWORD=$(get_config_value PostgreSQL password)
PG_DATABASE=$(get_config_value PostgreSQL database)

MINICONDA_DIR=$(get_config_value Miniconda install_dir)

REDIS_PASSWORD=$(get_config_value Redis password)
REDIS_PORT=$(get_config_value Redis port)

NGINX_CONFIG=$(get_config_value Nginx config)
NGINX_SITES_AVAILABLE=$(get_config_value Nginx sites_available)
NGINX_SITES_ENABLED=$(get_config_value Nginx sites_enabled)
NGINX_PORT=$(get_config_value Nginx port)
NGINX_HTML_DIR=$(get_config_value Nginx html_dir)
NGINX_INDEX_FILE=$(get_config_value Nginx index_file)

NPM_DIR=$(get_config_value npm install_dir)
NODE_VERSION=$(get_config_value npm node_version)

success "Configuration chargée"

# ------------------------------------------------------------------------------
# Étape 1 : Nettoyage des installations précédentes
# ------------------------------------------------------------------------------

info "Arrêt des services et nettoyage des anciennes installations..."
systemctl stop postgresql redis-server nginx 2>/dev/null || true

apt purge -y postgresql* redis* nginx* nodejs npm 2>/dev/null || true
apt autoremove -y

rm -rf /etc/postgresql /var/lib/postgresql /var/log/postgresql
rm -rf "$MINICONDA_DIR" "$NPM_DIR" ~/.nvm /usr/local/bin/{node,npm,npx} 2>/dev/null || true

# Nettoyage des blocs dans .bashrc
sed -i '/# >>> Miniconda initialization >>>/,/# <<< Miniconda initialization <<</d' "$USER_BASHRC" 2>/dev/null || true
sed -i '/# >>> Npm initialization >>>/,/# <<< Npm initialization <<</d' "$USER_BASHRC" 2>/dev/null || true

success "Nettoyage terminé"

# ------------------------------------------------------------------------------
# Étape 2 : Mise à jour du système
# ------------------------------------------------------------------------------

info "Mise à jour du système..."
apt update && apt upgrade -y
success "Système à jour"

# ------------------------------------------------------------------------------
# Étape 3 : Installation et configuration PostgreSQL
# ------------------------------------------------------------------------------

info "Installation et configuration de PostgreSQL..."
adduser --system --group --no-create-home postgres 2>/dev/null || true
mkdir -p /var/lib/postgresql /var/run/postgresql
chown postgres:postgres /var/lib/postgresql /var/run/postgresql
chmod 700 /var/lib/postgresql
chmod 775 /var/run/postgresql

apt install -y postgresql postgresql-contrib

PG_VERSION=$(ls /usr/lib/postgresql/ | sort -V | tail -n1)
PG_CONF="/etc/postgresql/$PG_VERSION/main/pg_hba.conf"
PG_MAIN_CONF="/etc/postgresql/$PG_VERSION/main/postgresql.conf"

systemctl enable postgresql

sudo -u postgres psql <<-EOF
	DROP ROLE IF EXISTS "$PG_USER";
	CREATE ROLE "$PG_USER" WITH LOGIN PASSWORD '$PG_PASSWORD' CREATEDB;
	CREATE DATABASE "$PG_DATABASE" OWNER "$PG_USER";
EOF

echo "host all all 127.0.0.1/32 md5" >> "$PG_CONF"
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = 'localhost'/" "$PG_MAIN_CONF"

systemctl restart postgresql
sleep 2

export PGPASSWORD="$PG_PASSWORD"
psql -U "$PG_USER" -d "$PG_DATABASE" -h 127.0.0.1 -c "\q" >/dev/null 2>&1 && success "PostgreSQL configuré" || error "Échec connexion PostgreSQL"
unset PGPASSWORD

# ------------------------------------------------------------------------------
# Étape 4 : Installation Miniconda
# ------------------------------------------------------------------------------

info "Installation de Miniconda..."
rm -rf "$MINICONDA_DIR" 2>/dev/null || true
mkdir -p "$(dirname "$MINICONDA_DIR")"
wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh
bash /tmp/miniconda.sh -b -p "$MINICONDA_DIR"
rm /tmp/miniconda.sh

chown -R "$REAL_USER":"$REAL_GROUP" "$MINICONDA_DIR"

add_block "Miniconda initialization" "export PATH=\"$MINICONDA_DIR/bin:\$PATH\"
. \"$MINICONDA_DIR/etc/profile.d/conda.sh\""

success "Miniconda installé"

# ------------------------------------------------------------------------------
# Étape 5 : Installation et configuration Redis
# ------------------------------------------------------------------------------

info "Installation et configuration de Redis..."
apt install -y redis-server

TMP_CONF=$(mktemp)
TMP_ACL=$(mktemp)

cat > "$TMP_CONF" <<EOF
bind 127.0.0.1
port $REDIS_PORT
requirepass $REDIS_PASSWORD
protected-mode yes
supervised systemd
dir /var/lib/redis
logfile /var/log/redis/redis-server.log
acllog-max-len 128
save ""
appendonly no
EOF

cat > "$TMP_ACL" <<EOF
user default off
user default on >$REDIS_PASSWORD ~* +@all
EOF

systemctl stop redis-server 2>/dev/null || true
cp "$TMP_CONF" /etc/redis/redis.conf
cp "$TMP_ACL" /etc/redis/users.acl
chown redis:redis /etc/redis/redis.conf /etc/redis/users.acl
chmod 640 /etc/redis/redis.conf /etc/redis/users.acl
rm -f "$TMP_CONF" "$TMP_ACL"

systemctl enable redis-server
systemctl restart redis-server
success "Redis configuré"

# ------------------------------------------------------------------------------
# Étape 6 : Installation et configuration Nginx
# ------------------------------------------------------------------------------

info "Installation et configuration de Nginx..."
apt install -y nginx

mkdir -p "$NGINX_HTML_DIR"
echo "<html><body><h1>Hello, Nginx!</h1></body></html>" > "$NGINX_HTML_DIR/$NGINX_INDEX_FILE"
chown -R www-data:www-data "$NGINX_HTML_DIR"
chmod -R 755 "$NGINX_HTML_DIR"

cat > "$NGINX_SITES_AVAILABLE" <<EOF
server {
    listen 127.0.0.1:$NGINX_PORT default_server;
    server_name localhost;
    root $NGINX_HTML_DIR;
    index $NGINX_INDEX_FILE;
    location / { try_files \$uri \$uri/ =404; }
}
EOF

[[ -L "$NGINX_SITES_ENABLED" ]] || ln -sf "$NGINX_SITES_AVAILABLE" "$NGINX_SITES_ENABLED"

sed -i '/http {/a\    server_tokens off;' "$NGINX_CONFIG" 2>/dev/null || true

nginx -t && systemctl enable nginx && systemctl restart nginx
success "Nginx configuré"

# ------------------------------------------------------------------------------
# Étape 7 : Installation Node.js et npm
# ------------------------------------------------------------------------------

info "Installation de Node.js $NODE_VERSION et npm..."
apt install -y nodejs npm
npm install -g n
n "$NODE_VERSION"

mkdir -p "$NPM_DIR"
chown "$REAL_USER":"$REAL_GROUP" "$NPM_DIR"

su - "$REAL_USER" -c "npm config set prefix '$NPM_DIR'"

add_block "Npm initialization" "export PATH=\"$NPM_DIR/bin:\$PATH\""

success "Node.js et npm configurés"

# ------------------------------------------------------------------------------
# Étape 8 : Création du répertoire projets
# ------------------------------------------------------------------------------

info "Création du répertoire des projets..."
mkdir -p "$PROJECTS_DIR"
chown "$REAL_USER":"$REAL_GROUP" "$PROJECTS_DIR"
chmod 755 "$PROJECTS_DIR"
success "Répertoire projets prêt"

# ------------------------------------------------------------------------------
# Finalisation et tests
# ------------------------------------------------------------------------------


echo ""
echo "════════════════════════════════════════════════════════════"
echo "         INSTALLATION TERMINÉE AVEC SUCCÈS                  "
echo "════════════════════════════════════════════════════════════"
echo ""
printf " %-18s : %s\n" "Utilisateur" "$REAL_USER"
printf " %-18s : %s\n" "Miniconda" "$MINICONDA_DIR"
printf " %-18s : %s\n" "Projets" "$PROJECTS_DIR"
printf " %-18s : %s\n" "Node/npm prefix" "$NPM_DIR"
echo ""
echo " Tests rapides :"
echo ""
printf " %-18s : %s\n" "Nginx" "$(curl -s http://127.0.0.1:$NGINX_PORT | grep -o '<h1>Hello, Nginx!</h1>' || echo 'ÉCHEC')"
printf " %-18s : %s\n" "Redis" "$(redis-cli -h 127.0.0.1 -p $REDIS_PORT --no-auth-warning -a $REDIS_PASSWORD ping 2>/dev/null || echo 'ÉCHEC')"
printf " %-18s : %s\n" "PostgreSQL" "$(PGPASSWORD=$PG_PASSWORD psql -U $PG_USER -d $PG_DATABASE -h 127.0.0.1 -c 'SELECT 1;' 2>/dev/null | tr -d '\n' || echo 'ÉCHEC')"
echo ""
echo "════════════════════════════════════════════════════════════"
echo ""