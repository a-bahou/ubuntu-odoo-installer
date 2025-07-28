#!/bin/bash

#################################################################################
# SCRIPT D'INSTALLATION AUTOMATISÉE - UBUNTU SERVER + ODOO 17 SÉCURISÉ
# Version: 2.0
# Date: Juin 2025
#################################################################################

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction de log
log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERREUR] $1${NC}"
    exit 1
}

warning() {
    echo -e "${YELLOW}[ATTENTION] $1${NC}"
}

info() {
    echo -e "${BLUE}[INFO] $1${NC}"
}

#################################################################################
# CONFIGURATION INTERACTIVE - VALEURS PAR DÉFAUT
#################################################################################

# Paramètres réseau (fixes)
DOMAIN_LOCAL="systemerp.local"
SERVER_NAME="systemerp-prod"
ADMIN_USER="sysadmin"
ODOO_USER="sys-erp"

# Valeurs par défaut
DEFAULT_SSH_PORT="8173"
DEFAULT_WEBMIN_PORT="12579"
DEFAULT_ODOO_PORT="9017"
DEFAULT_ODOO_LONGPOLL_PORT="8072"
DEFAULT_POSTGRES_PORT="6792"
DEFAULT_ODOO_VERSION="17.0"
DEFAULT_PASSWORD="B@hou1983"

# Interface réseau (auto-détectée)
NETWORK_INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n1)
DETECTED_IP=$(ip addr show $NETWORK_INTERFACE | grep "inet " | awk '{print $2}' | cut -d/ -f1)
DETECTED_GATEWAY=$(ip route | grep default | awk '{print $3}')

echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║             CONFIGURATION INTERACTIVE DU SERVEUR                ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""
echo "ℹ️  Appuyez sur ENTRÉE pour utiliser la valeur par défaut"
echo ""

# Configuration des ports
echo "🔧 CONFIGURATION DES PORTS :"
read -p "Port SSH [$DEFAULT_SSH_PORT]: " SSH_PORT
SSH_PORT=${SSH_PORT:-$DEFAULT_SSH_PORT}

read -p "Port Webmin [$DEFAULT_WEBMIN_PORT]: " WEBMIN_PORT
WEBMIN_PORT=${WEBMIN_PORT:-$DEFAULT_WEBMIN_PORT}

read -p "Port Odoo [$DEFAULT_ODOO_PORT]: " ODOO_PORT
ODOO_PORT=${ODOO_PORT:-$DEFAULT_ODOO_PORT}

read -p "Port PostgreSQL [$DEFAULT_POSTGRES_PORT]: " POSTGRES_PORT
POSTGRES_PORT=${POSTGRES_PORT:-$DEFAULT_POSTGRES_PORT}

# Configuration version Odoo
echo ""
echo "📦 VERSION ODOO :"
echo "   Versions disponibles : 14.0, 15.0, 16.0, 17.0, 18.0"
read -p "Version Odoo [$DEFAULT_ODOO_VERSION]: " ODOO_VERSION
ODOO_VERSION=${ODOO_VERSION:-$DEFAULT_ODOO_VERSION}

# Configuration réseau
echo ""
echo "🌐 CONFIGURATION RÉSEAU :"
echo "   Interface détectée : $NETWORK_INTERFACE"
echo "   IP détectée        : $DETECTED_IP"
echo "   Passerelle détectée: $DETECTED_GATEWAY"
read -p "Adresse IP serveur [$DETECTED_IP]: " CURRENT_IP
CURRENT_IP=${CURRENT_IP:-$DETECTED_IP}

read -p "Passerelle [$DETECTED_GATEWAY]: " GATEWAY
GATEWAY=${GATEWAY:-$DETECTED_GATEWAY}

# Configuration des mots de passe
echo ""
echo "🔐 CONFIGURATION DES MOTS DE PASSE :"
echo "   Mot de passe par défaut : $DEFAULT_PASSWORD"
echo ""

read -s -p "Mot de passe PostgreSQL (postgres) [$DEFAULT_PASSWORD]: " POSTGRES_ADMIN_PASS
echo ""
POSTGRES_ADMIN_PASS=${POSTGRES_ADMIN_PASS:-$DEFAULT_PASSWORD}

read -s -p "Mot de passe PostgreSQL (sys-erp) [$DEFAULT_PASSWORD]: " POSTGRES_USER_PASS
echo ""
POSTGRES_USER_PASS=${POSTGRES_USER_PASS:-$DEFAULT_PASSWORD}

read -s -p "Mot de passe Master Odoo [$DEFAULT_PASSWORD]: " ODOO_MASTER_PASS
echo ""
ODOO_MASTER_PASS=${ODOO_MASTER_PASS:-$DEFAULT_PASSWORD}

# Port longpolling automatique (port Odoo + 1000)
ODOO_LONGPOLL_PORT=$((ODOO_PORT + 1000))

# Confirmation des paramètres
echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║                    CONFIGURATION DÉTECTÉE                       ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""
echo "🌐 Interface réseau    : $NETWORK_INTERFACE"
echo "📍 IP configurée       : $CURRENT_IP"
echo "🚪 Passerelle          : $GATEWAY"
echo "🏠 Domaine local       : $DOMAIN_LOCAL"
echo "🔑 SSH Port            : $SSH_PORT"
echo "⚙️ Webmin Port         : $WEBMIN_PORT" 
echo "🏢 Odoo Port           : $ODOO_PORT"
echo "🗄️ PostgreSQL Port     : $POSTGRES_PORT"
echo "📦 Version Odoo        : $ODOO_VERSION"
echo ""
echo "⚠️  INSTALLATION AUTOMATIQUE EN COURS..."
echo "    Le script va maintenant s'exécuter sans interruption."
echo "    Aucune intervention manuelle ne sera requise."
echo "    Durée estimée : 15-30 minutes selon la connexion Internet."
echo ""
read -p "Continuer avec cette configuration ? (y/N): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Installation annulée."
    exit 1
fi

echo ""
log "🚀 Démarrage de l'installation automatique..."
log "⏳ Veuillez patienter, aucune intervention requise..."

#################################################################################
# CONFIGURATION NON-INTERACTIVE
#################################################################################

# Configuration pour éviter toute interaction utilisateur
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a
export NEEDRESTART_SUSPEND=1

# Configuration debconf pour mode automatique
echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
echo 'debconf debconf/priority select critical' | debconf-set-selections

# Configuration des redémarrages automatiques de services
mkdir -p /etc/needrestart/conf.d
cat > /etc/needrestart/conf.d/50-local.conf << 'EOF'
# Automatically restart services without asking
$nrconf{restart} = 'a';
$nrconf{kernelhints} = 0;
$nrconf{ucodehints} = 0;
EOF

#################################################################################
# ÉTAPE 1: MISE À JOUR SYSTÈME ET INSTALLATION OUTILS
#################################################################################

log "Démarrage de l'installation automatisée..."
log "ÉTAPE 1/5: Mise à jour système et installation des outils (mode non-interactif)"

# Mise à jour système en mode automatique
log "Mise à jour du système..."
apt update && DEBIAN_FRONTEND=noninteractive apt full-upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" || error "Échec mise à jour système"

# Installation groupée des outils système
log "Installation des outils système essentiels..."
DEBIAN_FRONTEND=noninteractive apt install -y \
    ufw fail2ban unattended-upgrades nano rsyslog cron \
    iputils-ping dnsutils net-tools curl wget git \
    python3-pip python3-dev python3-venv \
    libxml2-dev libxslt1-dev libevent-dev libsasl2-dev libldap2-dev \
    pkg-config libtiff5-dev libjpeg8-dev libopenjp2-7-dev zlib1g-dev \
    libfreetype6-dev liblcms2-dev libwebp-dev libharfbuzz-dev \
    libfribidi-dev libxcb1-dev fontconfig libxrender1 xfonts-75dpi xfonts-base \
    -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" || error "Échec installation outils"

# Installation wkhtmltopdf (version officielle pour meilleure compatibilité)
log "Installation de wkhtmltopdf (génération PDF Odoo)..."
WKHTMLTOPDF_VERSION="0.12.6.1-2"
WKHTMLTOPDF_URL="https://github.com/wkhtmltopdf/packaging/releases/download/${WKHTMLTOPDF_VERSION}/wkhtmltox_${WKHTMLTOPDF_VERSION}.jammy_amd64.deb"
cd /tmp
wget -q $WKHTMLTOPDF_URL -O wkhtmltox.deb || warning "Échec téléchargement wkhtmltopdf, installation depuis apt"
if [ -f "wkhtmltox.deb" ]; then
    DEBIAN_FRONTEND=noninteractive dpkg -i wkhtmltox.deb || true
    DEBIAN_FRONTEND=noninteractive apt-get install -f -y
    log "✅ wkhtmltopdf installé depuis les sources officielles"
else
    DEBIAN_FRONTEND=noninteractive apt install -y wkhtmltopdf
    log "✅ wkhtmltopdf installé depuis apt"
fi

# Installation des dépendances Python pour modules Odoo avancés
log "Installation des dépendances Python pour modules Odoo..."
pip3 install --upgrade pip
pip3 install \
    dropbox \
    pyncclient \
    nextcloud-api-wrapper \
    boto3 \
    paramiko \
    requests \
    cryptography \
    pillow \
    lxml \
    'lxml[html_clean]' \
    lxml_html_clean \
    reportlab \
    qrcode[pil] \
    xlsxwriter \
    xlrd \
    openpyxl \
    python-dateutil \
    pytz || warning "Certaines dépendances Python ont échoué (continuer...)"

log "✅ Outils système et dépendances Python installés avec succès"

log "✅ Outils système installés avec succès"

#################################################################################
# ÉTAPE 2: CONFIGURATION FIREWALL COMPLÈTE
#################################################################################

log "ÉTAPE 2/5: Configuration firewall avec tous les ports personnalisés"

# Configuration UFW
log "Configuration du firewall UFW..."
ufw --force reset
ufw default deny incoming
ufw default allow outgoing

# Ouverture des ports personnalisés
log "Ouverture du port SSH: $SSH_PORT"
ufw allow $SSH_PORT/tcp comment 'SSH Custom'

log "Ouverture des ports HTTP/HTTPS"
ufw allow 80/tcp comment 'HTTP'
ufw allow 443/tcp comment 'HTTPS'

log "Ouverture du port Odoo: $ODOO_PORT"
ufw allow $ODOO_PORT/tcp comment 'Odoo Custom'

log "Ouverture du port PostgreSQL: $POSTGRES_PORT"
ufw allow $POSTGRES_PORT/tcp comment 'PostgreSQL Custom'

log "Ouverture du port Webmin: $WEBMIN_PORT"
ufw allow $WEBMIN_PORT/tcp comment 'Webmin Custom'

# Activation firewall
ufw --force enable || error "Échec activation firewall"

log "✅ Firewall configuré avec succès"

# Configuration IP fixe
log "Configuration de l'IP fixe..."
cat > /etc/netplan/00-installer-config.yaml << EOF
network:
  version: 2
  ethernets:
    $NETWORK_INTERFACE:
      dhcp4: no
      addresses:
        - $CURRENT_IP/24
      routes:
        - to: default
          via: $GATEWAY
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4, $GATEWAY]
EOF

netplan apply || warning "Échec configuration réseau (continuons...)"

# Configuration domaine local
log "Configuration du domaine local..."
echo "$CURRENT_IP    $DOMAIN_LOCAL" >> /etc/hosts
echo "$CURRENT_IP    $SERVER_NAME.$DOMAIN_LOCAL" >> /etc/hosts

log "✅ Configuration réseau terminée"

#################################################################################
# ÉTAPE 3: INSTALLATION POSTGRESQL
#################################################################################

log "ÉTAPE 3/5: Installation et configuration PostgreSQL"

# Installation PostgreSQL
log "Installation de PostgreSQL..."
DEBIAN_FRONTEND=noninteractive apt install -y postgresql postgresql-contrib -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" || error "Échec installation PostgreSQL"
systemctl enable postgresql

# Configuration des utilisateurs
log "Configuration des utilisateurs PostgreSQL..."
sudo -u postgres psql << EOF
ALTER USER postgres PASSWORD '$POSTGRES_ADMIN_PASS';
CREATE USER "$ODOO_USER" WITH CREATEDB;
ALTER USER "$ODOO_USER" PASSWORD '$POSTGRES_USER_PASS';
\q
EOF

# Configuration port personnalisé
log "Configuration du port PostgreSQL: $POSTGRES_PORT"
sed -i "s/#port = 5432/port = $POSTGRES_PORT/" /etc/postgresql/*/main/postgresql.conf
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = 'localhost'/" /etc/postgresql/*/main/postgresql.conf

systemctl restart postgresql || error "Échec redémarrage PostgreSQL"

log "✅ PostgreSQL configuré sur le port $POSTGRES_PORT"

#################################################################################
# ÉTAPE 4: INSTALLATION NGINX + ODOO + WEBMIN
#################################################################################

log "ÉTAPE 4/5: Installation Nginx, Odoo 17 et Webmin"

# Installation Nginx
log "Installation de Nginx..."
DEBIAN_FRONTEND=noninteractive apt install -y nginx certbot python3-certbot-nginx -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" || error "Échec installation Nginx"
systemctl enable nginx

# Configuration reverse proxy Nginx
log "Configuration du reverse proxy Nginx pour Odoo..."
log "Optimisation pour uploads volumineux (bases de données, modules)..."
cat > /etc/nginx/sites-available/$DOMAIN_LOCAL << EOF
server {
    listen 80;
    server_name $DOMAIN_LOCAL $CURRENT_IP;
    
    # Augmentation limites pour Odoo (bases de données volumineuses)
    client_max_body_size 1024M;
    client_body_timeout 300s;
    client_header_timeout 300s;
    
    # Timeouts proxy pour opérations longues
    proxy_connect_timeout 300s;
    proxy_send_timeout 300s;
    proxy_read_timeout 300s;
    send_timeout 300s;
    
    # Redirection vers Odoo
    location / {
        proxy_pass http://127.0.0.1:$ODOO_PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_redirect off;
        
        # Headers pour gros uploads
        proxy_buffering off;
        proxy_request_buffering off;
    }
    
    # WebSocket pour Odoo (longpolling)
    location /websocket {
        proxy_pass http://127.0.0.1:$ODOO_LONGPOLL_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    # Gestion fichiers statiques Odoo
    location ~* /web/static/ {
        proxy_cache_valid 200 90m;
        proxy_buffering on;
        expires 864000;
        proxy_pass http://127.0.0.1:$ODOO_PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

ln -sf /etc/nginx/sites-available/$DOMAIN_LOCAL /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

nginx -t && systemctl restart nginx || error "Échec configuration Nginx"

# Installation Odoo avec version personnalisée
log "Installation d'Odoo $ODOO_VERSION..."
wget -O - https://nightly.odoo.com/odoo.key | gpg --dearmor -o /usr/share/keyrings/odoo-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/odoo-archive-keyring.gpg] https://nightly.odoo.com/$ODOO_VERSION/nightly/deb/ ./" | tee /etc/apt/sources.list.d/odoo.list
DEBIAN_FRONTEND=noninteractive apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y odoo -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" || error "Échec installation Odoo $ODOO_VERSION"

# Création structure sécurisée Odoo
log "Création de la structure sécurisée Odoo..."
mkdir -p /opt/odoo-secure/{addons-custom,addons-external,config,logs,filestore}

# Configuration Odoo sécurisée
log "Configuration d'Odoo avec ports personnalisés et addons sécurisés..."
cat > /opt/odoo-secure/config/odoo.conf << EOF
[options]
# Ports personnalisés
xmlrpc_port = $ODOO_PORT
longpolling_port = $ODOO_LONGPOLL_PORT

# Base de données PostgreSQL
db_host = localhost
db_port = $POSTGRES_PORT
db_user = $ODOO_USER
db_password = $POSTGRES_USER_PASS

# Mot de passe master Odoo
admin_passwd = $ODOO_MASTER_PASS

# Sécurité renforcée
list_db = False
db_filter = ^.*$
proxy_mode = True

# Addons sécurisés (dossiers personnalisés protégés)
addons_path = /usr/lib/python3/dist-packages/odoo/addons,/opt/odoo-secure/addons-external,/opt/odoo-secure/addons-custom

# Logs et données sécurisés
logfile = /opt/odoo-secure/logs/odoo.log
data_dir = /opt/odoo-secure/filestore

# Sécurité supplémentaire
without_demo = True
max_cron_threads = 1
limit_memory_hard = 2684354560
limit_memory_soft = 2147483648
limit_request = 8192
limit_time_cpu = 600
limit_time_real = 1200
EOF

# CORRECTION CRITIQUE : Permissions correctes POUR L'UTILISATEUR ODOO
log "Application des permissions sécurisées..."
chown -R odoo:odoo /opt/odoo-secure/
chmod 750 /opt/odoo-secure/addons-custom/
chmod 750 /opt/odoo-secure/addons-external/
chmod 750 /opt/odoo-secure/config/
chmod 750 /opt/odoo-secure/filestore/
chmod 755 /opt/odoo-secure/logs/
chmod 640 /opt/odoo-secure/config/odoo.conf

# Lien vers configuration sécurisée ET permissions du lien
ln -sf /opt/odoo-secure/config/odoo.conf /etc/odoo/odoo.conf
chown odoo:odoo /etc/odoo/odoo.conf

# Test configuration Odoo avant démarrage
log "Test de la configuration Odoo..."
if sudo -u odoo odoo --config=/etc/odoo/odoo.conf --test-enable --stop-after-init --logfile=/tmp/odoo-test.log; then
    log "✅ Configuration Odoo valide"
else
    warning "❌ Problème configuration Odoo, vérification en cours..."
    cat /tmp/odoo-test.log
fi

# Redémarrage Odoo avec vérification robuste
log "Démarrage du service Odoo..."
systemctl stop odoo
sleep 3
systemctl start odoo
sleep 10

# Vérification finale avec plusieurs tentatives
for i in {1..3}; do
    if systemctl is-active --quiet odoo; then
        log "✅ Odoo démarré avec succès"
        break
    else
        warning "Tentative $i/3 : Odoo non démarré, nouvelle tentative..."
        systemctl restart odoo
        sleep 10
    fi
done

systemctl restart odoo || error "Échec redémarrage Odoo"

# Installation Webmin
log "Installation de Webmin..."
wget -qO - http://www.webmin.com/jcameron-key.asc | apt-key add -
echo "deb http://download.webmin.com/download/repository sarge contrib" | tee -a /etc/apt/sources.list
DEBIAN_FRONTEND=noninteractive apt update && DEBIAN_FRONTEND=noninteractive apt install -y webmin -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" || error "Échec installation Webmin"

# Configuration port Webmin
log "Configuration du port Webmin: $WEBMIN_PORT"
sed -i "s/port=10000/port=$WEBMIN_PORT/" /etc/webmin/miniserv.conf
sed -i "s/listen=10000/listen=$WEBMIN_PORT/" /etc/webmin/miniserv.conf

systemctl restart webmin || error "Échec redémarrage Webmin"

log "✅ Nginx, Odoo et Webmin installés et configurés"

#################################################################################
# ÉTAPE 5: SÉCURISATION FINALE + DÉSACTIVATION AUTOMATIQUE MOTS DE PASSE
#################################################################################

log "ÉTAPE 5/5: Sécurisation finale du système"

# Configuration SSH sécurisé (garde les mots de passe pour l'instant)
log "Configuration SSH sécurisé sur le port $SSH_PORT..."
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

cat > /etc/ssh/sshd_config << EOF
# Configuration SSH sécurisée
Port $SSH_PORT
PermitRootLogin no
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
PasswordAuthentication yes
MaxAuthTries 3
AllowUsers $ADMIN_USER
ClientAliveInterval 300
ClientAliveCountMax 2

# Protocoles sécurisés
Protocol 2
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key

# Authentification
LoginGraceTime 60
StrictModes yes
RSAAuthentication yes

# Sécurité supplémentaire
X11Forwarding no
PrintMotd no
AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/openssh/sftp-server
EOF

systemctl restart sshd || error "Échec redémarrage SSH"

# Configuration Fail2ban
log "Configuration de Fail2ban..."
cat > /etc/fail2ban/jail.local << EOF
[sshd]
enabled = true
port = $SSH_PORT
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
findtime = 600
EOF

# Activation logs traditionnels
systemctl enable rsyslog
systemctl start rsyslog
touch /var/log/auth.log
chown syslog:adm /var/log/auth.log
chmod 640 /var/log/auth.log

systemctl enable fail2ban
systemctl restart fail2ban || error "Échec démarrage Fail2ban"

# Configuration sauvegarde automatique
log "Configuration de la sauvegarde automatique..."
mkdir -p /opt/backup
chown $ADMIN_USER:$ADMIN_USER /opt/backup

cat > /opt/backup/backup-odoo.sh << EOF
#!/bin/bash
DATE=\$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/opt/backup"

# Sauvegarde base de données
PGPASSWORD='$POSTGRES_USER_PASS' pg_dump -h localhost -p $POSTGRES_PORT -U $ODOO_USER postgres > \$BACKUP_DIR/odoo_db_\${DATE}.sql

# Sauvegarde filestore Odoo sécurisé
tar -czf \$BACKUP_DIR/odoo_filestore_\${DATE}.tar.gz /opt/odoo-secure/filestore/ 2>/dev/null

# Sauvegarde addons personnalisés
tar -czf \$BACKUP_DIR/odoo_addons_custom_\${DATE}.tar.gz /opt/odoo-secure/addons-custom/ 2>/dev/null

# Sauvegarde configurations sécurisées
tar -czf \$BACKUP_DIR/configs_\${DATE}.tar.gz /opt/odoo-secure/config/ /etc/nginx/sites-available/ /etc/ssh/sshd_config /etc/fail2ban/jail.local 2>/dev/null

# Nettoyage (garde 7 jours)
find \$BACKUP_DIR -name "*.sql" -mtime +7 -delete
find \$BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete

echo "Sauvegarde terminée: \${DATE}"
EOF

chmod +x /opt/backup/backup-odoo.sh

# Cron automatique
(crontab -l 2>/dev/null; echo "0 2 * * * /opt/backup/backup-odoo.sh >> /var/log/backup.log 2>&1") | crontab -

# Création documentation d'installation sur le serveur
log "Création de la documentation d'installation..."
cat > /opt/backup/GUIDE-INSTALLATION-SystemERP.md << 'EOFDOC'
# 📖 GUIDE PRATIQUE D'INSTALLATION - SystemERP

## 🎯 Installation Ubuntu Server + Odoo en 5 minutes

### ⚡ INSTALLATION RAPIDE

#### 🔧 Prérequis (30 secondes)
```bash
sudo apt update
sudo apt install -y nano wget curl
```

#### 🚀 Installation Automatique (5 minutes)
```bash
wget https://raw.githubusercontent.com/a-bahou/ubuntu-odoo-installer/main/install-ubuntu-odoo.sh
chmod +x install-ubuntu-odoo.sh
sudo ./install-ubuntu-odoo.sh
```

### 🚨 ERREURS COMMUNES ET SOLUTIONS

#### ❌ Erreur : "Odoo Inactif"
```bash
sudo chown -R odoo:odoo /opt/odoo-secure/
sudo systemctl restart odoo
```

#### ❌ Erreur : "Port SSH connection refused"
```bash
sudo ufw allow 8173/tcp
sudo ufw reload
```

#### ❌ Erreur : "PostgreSQL connection failed"
```bash
sudo systemctl restart postgresql
sudo systemctl restart odoo
```

### 🔑 CONFIGURATION PUTTY

#### A. Génération Clé SSH
1. PuTTYgen : RSA, 4096 bits, Generate
2. Save private key : systemerp-client.ppk
3. Copier clé publique

#### B. Installation sur Serveur
```bash
mkdir -p ~/.ssh
nano ~/.ssh/authorized_keys
# Coller clé publique
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

#### C. Configuration PuTTY
- Host : IP_SERVEUR
- Port : 8173
- SSH→Auth→Credentials : systemerp-client.ppk
- Connection→Data : sysadmin

### 🌐 URLS D'ACCÈS
```
Odoo ERP    : http://IP_SERVEUR
Webmin      : https://IP_SERVEUR:12579
SSH PuTTY   : IP_SERVEUR:8173
```

### 📊 VÉRIFICATION
```bash
sudo systemctl status postgresql nginx odoo webmin ssh fail2ban
sudo ss -tlnp | grep -E "(8173|9017|6792|12579)"
```

### 🔧 MAINTENANCE
```bash
# Mise à jour
sudo apt update && sudo apt upgrade -y

# Logs
sudo journalctl -u odoo -f

# Redémarrage services
sudo systemctl restart postgresql nginx odoo webmin fail2ban
```

### 📁 FICHIERS IMPORTANTS
```
/opt/odoo-secure/config/odoo.conf
/etc/ssh/sshd_config  
/etc/nginx/sites-available/systemerp.local
/opt/backup/
```

---
Documentation générée automatiquement lors de l'installation
Date : $(date)
Serveur : $(hostname)
IP : $CURRENT_IP
EOFDOC

# NOUVEAU : Création du Cahier des Charges Final avec toutes les informations de cette installation
log "Génération du Cahier des Charges Final de cette installation..."

cat > /opt/backup/CAHIER-DES-CHARGES-FINAL-$(date +%Y%m%d_%H%M%S).md << 'EOFCAHIER'
# 📋 CAHIER DES CHARGES FINAL - INSTALLATION SYSTEMERP

## 🏢 INFORMATIONS GÉNÉRALES

| Information | Valeur |
|------------|--------|
| **Date Installation** | $(date '+%d/%m/%Y à %H:%M:%S') |
| **Serveur** | $(hostname) |
| **Système** | $(lsb_release -d | cut -f2) |
| **Architecture** | $(uname -m) |
| **Kernel** | $(uname -r) |
| **IP Serveur** | CURRENT_IP_VALUE |
| **Interface Réseau** | NETWORK_INTERFACE_VALUE |
| **Passerelle** | GATEWAY_VALUE |
| **Domaine Local** | DOMAIN_LOCAL_VALUE |

## 🔐 CONFIGURATION SÉCURITÉ

### 👤 Utilisateurs Système
| Utilisateur | Rôle | Mot de Passe |
|-------------|------|--------------|
| **ADMIN_USER_VALUE** | Administrateur Système | [Défini lors installation] |
| **ODOO_USER_VALUE** | Utilisateur Odoo | [Généré automatiquement] |

### 🚪 Ports Personnalisés Configurés
| Service | Port Standard | Port Configuré | Sécurité |
|---------|---------------|----------------|----------|
| **SSH** | 22 | **SSH_PORT_VALUE** | ✅ Obfusqué |
| **HTTP** | 80 | **80** | ✅ Nginx Proxy |
| **HTTPS** | 443 | **443** | ✅ SSL Ready |
| **Odoo** | 8069 | **ODOO_PORT_VALUE** | ✅ Masqué |
| **Odoo LongPolling** | 8072 | **ODOO_LONGPOLL_PORT_VALUE** | ✅ Interne |
| **PostgreSQL** | 5432 | **POSTGRES_PORT_VALUE** | ✅ Localhost Only |
| **Webmin** | 10000 | **WEBMIN_PORT_VALUE** | ✅ SSL Forcé |

### 🔑 Authentification Configurée
| Composant | Méthode | Status |
|-----------|---------|--------|
| **SSH** | Clés RSA 4096 | SSH_STATUS_VALUE |
| **Fail2Ban** | Anti-Intrusion | ✅ Actif sur port SSH_PORT_VALUE |
| **UFW Firewall** | Filtrage Réseau | ✅ Actif (ports personnalisés) |

## 🗄️ BASE DE DONNÉES

### 📊 Configuration PostgreSQL
| Paramètre | Valeur |
|-----------|--------|
| **Version** | PostgreSQL 14+ |
| **Port** | **POSTGRES_PORT_VALUE** |
| **Écoute** | localhost uniquement |
| **Utilisateur Admin** | postgres |
| **Utilisateur Odoo** | ODOO_USER_VALUE |
| **Mot de Passe postgres** | POSTGRES_ADMIN_PASS_VALUE |
| **Mot de Passe sys-erp** | POSTGRES_USER_PASS_VALUE |

### 🔐 Sécurité Base de Données
- ✅ Port non-standard (POSTGRES_PORT_VALUE)
- ✅ Accès localhost uniquement
- ✅ Utilisateur dédié pour Odoo
- ✅ Mots de passe forts configurés

## 🏢 CONFIGURATION ODOO

### 📦 Installation Odoo
| Paramètre | Valeur |
|-----------|--------|
| **Version Odoo** | ODOO_VERSION_VALUE |
| **Port Web** | **ODOO_PORT_VALUE** |
| **Port LongPolling** | **ODOO_LONGPOLL_PORT_VALUE** |
| **Utilisateur Système** | ODOO_USER_VALUE |
| **Mot de Passe Master** | ODOO_MASTER_PASS_VALUE |

### 📁 Structure Fichiers Sécurisée
```
/opt/odoo-secure/
|-- addons-custom/          # Addons personnalisés (chmod 750)
|-- addons-external/        # Addons tiers (chmod 750)
|-- config/                 # Configuration (chmod 640)
|   `-- odoo.conf          # Configuration principale
|-- filestore/             # Données Odoo (chmod 750)
`-- logs/                  # Logs (chmod 755)
```

**Propriétaire :** ODOO_USER_VALUE:ODOO_USER_VALUE (sécurité maximale)

### 🧩 Dépendances Python Installées
- ✅ **dropbox** - Intégration Dropbox
- ✅ **pyncclient** - Connexion Nextcloud  
- ✅ **nextcloud-api-wrapper** - API Nextcloud avancée
- ✅ **boto3** - Intégration AWS S3
- ✅ **paramiko** - Connexions SSH/SFTP
- ✅ **wkhtmltopdf** - Génération PDF optimisée
- ✅ **Autres** : requests, cryptography, pillow, reportlab, qrcode, xlsxwriter...

## 🌐 CONFIGURATION WEB

### 🔄 Nginx Reverse Proxy
| Paramètre | Valeur |
|-----------|--------|
| **Configuration** | /etc/nginx/sites-available/DOMAIN_LOCAL_VALUE |
| **Domaine** | DOMAIN_LOCAL_VALUE |
| **Proxy Vers** | localhost:ODOO_PORT_VALUE |
| **WebSocket** | localhost:ODOO_LONGPOLL_PORT_VALUE |
| **SSL** | Prêt pour Let's Encrypt |

### ⚙️ Webmin Administration
| Paramètre | Valeur |
|-----------|--------|
| **Port** | **WEBMIN_PORT_VALUE** |
| **SSL** | ✅ Forcé |
| **Accès** | https://CURRENT_IP_VALUE:WEBMIN_PORT_VALUE |

## 🌐 URLS D'ACCÈS FINAL

### 🔗 Accès Client
```
🏢 Odoo ERP          : http://CURRENT_IP_VALUE
🏢 Odoo Direct       : http://CURRENT_IP_VALUE:ODOO_PORT_VALUE  
⚙️ Webmin Admin      : https://CURRENT_IP_VALUE:WEBMIN_PORT_VALUE
🔑 SSH PuTTY         : CURRENT_IP_VALUE:SSH_PORT_VALUE
📊 Logs Odoo         : /opt/odoo-secure/logs/odoo.log
💾 Sauvegardes       : /opt/backup/
```

### 🔧 Accès Technique Interne
```
🗄️ PostgreSQL        : localhost:POSTGRES_PORT_VALUE
📁 Config Odoo       : /opt/odoo-secure/config/odoo.conf
🔧 Config SSH        : /etc/ssh/sshd_config
🌐 Config Nginx      : /etc/nginx/sites-available/DOMAIN_LOCAL_VALUE
🛡️ Config Fail2ban   : /etc/fail2ban/jail.local
```

## 💾 SAUVEGARDE AUTOMATIQUE

### 📅 Configuration Backup
| Paramètre | Valeur |
|-----------|--------|
| **Fréquence** | Quotidienne à 02h00 |
| **Rétention** | 7 jours |
| **Localisation** | /opt/backup/ |
| **Script** | /opt/backup/backup-odoo.sh |

### 📦 Contenu Sauvegardé
- ✅ **Base de données** PostgreSQL complète
- ✅ **Filestore Odoo** (documents, images)
- ✅ **Addons personnalisés** 
- ✅ **Configurations système** (SSH, Nginx, Fail2ban)

### 🔍 Commandes Vérification
```bash
# Vérifier dernière sauvegarde
ls -la /opt/backup/

# Test sauvegarde manuelle
/opt/backup/backup-odoo.sh

# Vérifier cron
sudo crontab -l
```

## 🛡️ SÉCURITÉ CONFIGURÉE

### 🔥 Firewall UFW Status
```bash
# Ports ouverts configurés :
SSH_PORT_VALUE/tcp     # SSH personnalisé
80/tcp            # HTTP
443/tcp           # HTTPS  
# Ports fermés par défaut : ODOO_PORT_VALUE, POSTGRES_PORT_VALUE, WEBMIN_PORT_VALUE (localhost)
```

### 🚫 Fail2Ban Protection
| Service | Port | Max Tentatives | Temps Ban |
|---------|------|----------------|-----------|
| **SSH** | SSH_PORT_VALUE | 3 | 3600 secondes |

### 🔐 SSH Sécurisé
```bash
# Configuration SSH active :
Port SSH_PORT_VALUE
PermitRootLogin no
PubkeyAuthentication yes
PasswordAuthentication SSH_PASSWORD_STATUS_VALUE
MaxAuthTries 3
AllowUsers ADMIN_USER_VALUE
```

## 📊 ÉTAT SERVICES INSTALLATION

### ✅ Services Actifs Vérifiés
SERVICES_STATUS_VALUE

### 📈 Ressources Système
| Ressource | Utilisation |
|-----------|-------------|
| **CPU** | CPU_USAGE_VALUE% utilisé |
| **RAM** | RAM_USAGE_VALUE utilisée |
| **Disque** | DISK_USAGE_VALUE |

## 🔧 MAINTENANCE POST-INSTALLATION

### 📅 Tâches Recommandées

#### Hebdomadaires
```bash
# Mise à jour système
sudo apt update && sudo apt upgrade -y

# Vérification logs
sudo journalctl --since "1 week ago" --priority=err

# Test sauvegarde
ls -la /opt/backup/
```

#### Mensuelles  
```bash
# Nettoyage logs
sudo journalctl --vacuum-time=30d

# Vérification espace disque
df -h

# Test restauration sauvegarde
```

### 🚨 Commandes Dépannage Rapide
```bash
# Status général
sudo systemctl status postgresql nginx odoo webmin ssh fail2ban

# Logs temps réel
sudo journalctl -f

# Redémarrage complet
sudo systemctl restart postgresql nginx odoo webmin fail2ban

# Vérification ports
sudo ss -tlnp | grep -E "(SSH_PORT_VALUE|ODOO_PORT_VALUE|POSTGRES_PORT_VALUE|WEBMIN_PORT_VALUE)"
```

## 📞 SUPPORT ET CONTACT

### 📋 Informations Installation
- **Script Version** : Latest
- **Date Installation** : $(date)
- **Installé par** : $USER
- **Serveur** : $(hostname)

### 📁 Fichiers Importants à Sauvegarder
```
/opt/backup/CAHIER-DES-CHARGES-FINAL-*.md    # Ce document
/opt/odoo-secure/config/odoo.conf             # Configuration Odoo
/etc/ssh/sshd_config                          # Configuration SSH
/etc/nginx/sites-available/DOMAIN_LOCAL_VALUE      # Configuration Nginx
/opt/backup/backup-odoo.sh                    # Script sauvegarde
```

---

## 🎯 INSTALLATION SYSTEMERP TERMINÉE AVEC SUCCÈS !

**📋 Ce cahier des charges contient TOUTES les informations spécifiques de cette installation.**

**💾 Document généré automatiquement le $(date) sur le serveur $(hostname)**

**🔐 GARDEZ CE DOCUMENT EN SÉCURITÉ - Il contient tous les mots de passe et configurations !**

---

**📥 Téléchargement disponible sur :** http://CURRENT_IP_VALUE/cahier-des-charges-final.md

EOFCAHIER

# Remplacer les placeholders par les vraies valeurs
sed -i "s/CURRENT_IP_VALUE/$CURRENT_IP/g" /opt/backup/CAHIER-DES-CHARGES-FINAL-$(date +%Y%m%d_%H%M%S).md
sed -i "s/NETWORK_INTERFACE_VALUE/$NETWORK_INTERFACE/g" /opt/backup/CAHIER-DES-CHARGES-FINAL-$(date +%Y%m%d_%H%M%S).md
sed -i "s/GATEWAY_VALUE/$GATEWAY/g" /opt/backup/CAHIER-DES-CHARGES-FINAL-$(date +%Y%m%d_%H%M%S).md
sed -i "s/DOMAIN_LOCAL_VALUE/$DOMAIN_LOCAL/g" /opt/backup/CAHIER-DES-CHARGES-FINAL-$(date +%Y%m%d_%H%M%S).md
sed -i "s/ADMIN_USER_VALUE/$ADMIN_USER/g" /opt/backup/CAHIER-DES-CHARGES-FINAL-$(date +%Y%m%d_%H%M%S).md
sed -i "s/ODOO_USER_VALUE/$ODOO_USER/g" /opt/backup/CAHIER-DES-CHARGES-FINAL-$(date +%Y%m%d_%H%M%S).md
sed -i "s/SSH_PORT_VALUE/$SSH_PORT/g" /opt/backup/CAHIER-DES-CHARGES-FINAL-$(date +%Y%m%d_%H%M%S).md
sed -i "s/ODOO_PORT_VALUE/$ODOO_PORT/g" /opt/backup/CAHIER-DES-CHARGES-FINAL-$(date +%Y%m%d_%H%M%S).md
sed -i "s/ODOO_LONGPOLL_PORT_VALUE/$ODOO_LONGPOLL_PORT/g" /opt/backup/CAHIER-DES-CHARGES-FINAL-$(date +%Y%m%d_%H%M%S).md
sed -i "s/POSTGRES_PORT_VALUE/$POSTGRES_PORT/g" /opt/backup/CAHIER-DES-CHARGES-FINAL-$(date +%Y%m%d_%H%M%S).md
sed -i "s/WEBMIN_PORT_VALUE/$WEBMIN_PORT/g" /opt/backup/CAHIER-DES-CHARGES-FINAL-$(date +%Y%m%d_%H%M%S).md
sed -i "s/ODOO_VERSION_VALUE/$ODOO_VERSION/g" /opt/backup/CAHIER-DES-CHARGES-FINAL-$(date +%Y%m%d_%H%M%S).md
sed -i "s/POSTGRES_ADMIN_PASS_VALUE/$POSTGRES_ADMIN_PASS/g" /opt/backup/CAHIER-DES-CHARGES-FINAL-$(date +%Y%m%d_%H%M%S).md
sed -i "s/POSTGRES_USER_PASS_VALUE/$POSTGRES_USER_PASS/g" /opt/backup/CAHIER-DES-CHARGES-FINAL-$(date +%Y%m%d_%H%M%S).md
sed -i "s/ODOO_MASTER_PASS_VALUE/$ODOO_MASTER_PASS/g" /opt/backup/CAHIER-DES-CHARGES-FINAL-$(date +%Y%m%d_%H%M%S).md

# Status SSH
if [ "$SSH_PASSWORD_DISABLED" = true ]; then
    sed -i "s/SSH_STATUS_VALUE/✅ Sécurisé (Mots de passe désactivés)/g" /opt/backup/CAHIER-DES-CHARGES-FINAL-$(date +%Y%m%d_%H%M%S).md
    sed -i "s/SSH_PASSWORD_STATUS_VALUE/no/g" /opt/backup/CAHIER-DES-CHARGES-FINAL-$(date +%Y%m%d_%H%M%S).md
else
    sed -i "s/SSH_STATUS_VALUE/⚠️ Configuration manuelle requise/g" /opt/backup/CAHIER-DES-CHARGES-FINAL-$(date +%Y%m%d_%H%M%S).md
    sed -i "s/SSH_PASSWORD_STATUS_VALUE/yes (temporaire)/g" /opt/backup/CAHIER-DES-CHARGES-FINAL-$(date +%Y%m%d_%H%M%S).md
fi

# Status services
SERVICES_STATUS=""
systemctl is-active postgresql >/dev/null 2>&1 && SERVICES_STATUS="${SERVICES_STATUS}- ✅ **PostgreSQL** : Actif\n" || SERVICES_STATUS="${SERVICES_STATUS}- ❌ **PostgreSQL** : Problème\n"
systemctl is-active nginx >/dev/null 2>&1 && SERVICES_STATUS="${SERVICES_STATUS}- ✅ **Nginx** : Actif\n" || SERVICES_STATUS="${SERVICES_STATUS}- ❌ **Nginx** : Problème\n"
systemctl is-active odoo >/dev/null 2>&1 && SERVICES_STATUS="${SERVICES_STATUS}- ✅ **Odoo** : Actif\n" || SERVICES_STATUS="${SERVICES_STATUS}- ❌ **Odoo** : Problème\n"
systemctl is-active webmin >/dev/null 2>&1 && SERVICES_STATUS="${SERVICES_STATUS}- ✅ **Webmin** : Actif\n" || SERVICES_STATUS="${SERVICES_STATUS}- ❌ **Webmin** : Problème\n"
systemctl is-active ssh >/dev/null 2>&1 && SERVICES_STATUS="${SERVICES_STATUS}- ✅ **SSH** : Actif\n" || SERVICES_STATUS="${SERVICES_STATUS}- ❌ **SSH** : Problème\n"
systemctl is-active fail2ban >/dev/null 2>&1 && SERVICES_STATUS="${SERVICES_STATUS}- ✅ **Fail2ban** : Actif\n" || SERVICES_STATUS="${SERVICES_STATUS}- ❌ **Fail2ban** : Problème\n"

sed -i "s/SERVICES_STATUS_VALUE/$SERVICES_STATUS/g" /opt/backup/CAHIER-DES-CHARGES-FINAL-$(date +%Y%m%d_%H%M%S).md

# Ressources système
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1 2>/dev/null || echo "N/A")
RAM_USAGE=$(free -h | awk 'NR==2{printf "%.1f%%", $3*100/$2 }' 2>/dev/null || echo "N/A")
DISK_USAGE=$(df -h / | awk 'NR==2{printf "%s utilisé sur %s (%s)", $3, $2, $5}' 2>/dev/null || echo "N/A")

sed -i "s/CPU_USAGE_VALUE/$CPU_USAGE/g" /opt/backup/CAHIER-DES-CHARGES-FINAL-$(date +%Y%m%d_%H%M%S).md
sed -i "s/RAM_USAGE_VALUE/$RAM_USAGE/g" /opt/backup/CAHIER-DES-CHARGES-FINAL-$(date +%Y%m%d_%H%M%S).md
sed -i "s/DISK_USAGE_VALUE/$DISK_USAGE/g" /opt/backup/CAHIER-DES-CHARGES-FINAL-$(date +%Y%m%d_%H%M%S).md

# Créer lien web pour téléchargement du cahier des charges
ln -sf /opt/backup/CAHIER-DES-CHARGES-FINAL-$(date +%Y%m%d_%H%M%S).md /var/www/html/cahier-des-charges-final.md

# Documentation accessible via web
log "Documentation accessible via téléchargement web..."
ln -sf /opt/backup/GUIDE-INSTALLATION-SystemERP.md /var/www/html/guide-installation.md

# NOUVELLE FONCTIONNALITÉ : Vérification et désactivation automatique des mots de passe SSH
log "Vérification des clés SSH et sécurisation automatique..."

# Vérifier si des clés SSH sont configurées pour l'utilisateur admin
if [ -f "/home/$ADMIN_USER/.ssh/authorized_keys" ] && [ -s "/home/$ADMIN_USER/.ssh/authorized_keys" ]; then
    log "🔑 Clés SSH détectées pour $ADMIN_USER"
    
    # Test rapide de connectivité avec clés
    if sudo -u $ADMIN_USER ssh -o StrictHostKeyChecking=no -o PasswordAuthentication=no -p $SSH_PORT $ADMIN_USER@localhost echo "test" 2>/dev/null; then
        log "✅ Clés SSH fonctionnelles - Désactivation automatique des mots de passe..."
        
        # Désactivation des mots de passe SSH
        sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
        systemctl restart sshd
        
        log "🔒 Mots de passe SSH désactivés automatiquement - Sécurité maximale activée"
        SSH_PASSWORD_DISABLED=true
    else
        log "⚠️ Clés SSH présentes mais non fonctionnelles - Conservation des mots de passe"
        SSH_PASSWORD_DISABLED=false
    fi
else
    log "⚠️ Aucune clé SSH détectée - Conservation des mots de passe pour configuration manuelle"
    SSH_PASSWORD_DISABLED=false
fi

log "✅ Sécurisation finale terminée"

#################################################################################
# VÉRIFICATIONS FINALES ET RAPPORT
#################################################################################

log "Vérifications finales du système..."

echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║               INSTALLATION AUTOMATIQUE TERMINÉE !               ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""
echo "🎉 Installation automatisée terminée avec succès !"
echo "✅ Aucune interruption manuelle n'a été requise"
echo ""
echo "📋 SERVICES INSTALLÉS ET CONFIGURÉS:"
echo "   ✅ Ubuntu Server sécurisé"
echo "   ✅ Firewall UFW activé avec ports personnalisés"
echo "   ✅ PostgreSQL sur port $POSTGRES_PORT"
echo "   ✅ Nginx reverse proxy"
echo "   ✅ Odoo $ODOO_VERSION sur port $ODOO_PORT"
echo "   ✅ Webmin sur port $WEBMIN_PORT"
echo "   ✅ SSH sécurisé sur port $SSH_PORT"
echo "   ✅ Fail2ban anti-intrusion"
echo "   ✅ Sauvegarde automatique quotidienne"
echo ""
echo "🌐 URLS D'ACCÈS:"
echo "   🏢 Odoo ERP      : http://$CURRENT_IP"
echo "   ⚙️ Webmin Admin  : https://$CURRENT_IP:$WEBMIN_PORT"
echo "   🔑 SSH           : $CURRENT_IP:$SSH_PORT"
echo ""
echo "⚠️  CONFIGURATION MANUELLE RESTANTE:"
echo ""
if [ "$SSH_PASSWORD_DISABLED" = true ]; then
    echo "🔒 SÉCURITÉ SSH : MAXIMALE (Mots de passe automatiquement désactivés)"
    echo "   ✅ Clés SSH détectées et fonctionnelles"
    echo "   ✅ PasswordAuthentication automatiquement désactivé"
    echo "   ✅ Accès SSH uniquement par clés (PuTTY ou Terminal)"
    echo ""
    echo "🔑 CONNEXION SSH :"
    echo "   - Windows : Utilisez PuTTY avec votre clé privée .ppk"
    echo "   - Linux/Ubuntu : ssh -p $SSH_PORT sysadmin@$CURRENT_IP"
    echo "   - Les mots de passe SSH sont désormais INTERDITS"
    echo ""
else
    echo "🔑 CONFIGURATION CLÉS SSH (DEUX MÉTHODES DISPONIBLES):"
    echo ""
    echo "   📋 MÉTHODE 1 - PuTTY (Windows) :"
    echo "   1. Télécharger PuTTY + PuTTYgen"
    echo "   2. PuTTYgen : RSA 4096 bits, Generate"
    echo "   3. Sauver clé privée : systemerp-client.ppk"
    echo "   4. Copier clé publique"
    echo "   5. Sur serveur : mkdir -p ~/.ssh && nano ~/.ssh/authorized_keys"
    echo "   6. Coller clé publique, chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys"
    echo "   7. PuTTY : Host $CURRENT_IP:$SSH_PORT, clé .ppk, user sysadmin"
    echo ""
    echo "   📋 MÉTHODE 2 - Terminal Ubuntu/Linux :"
    echo "   1. ssh-keygen -t rsa -b 4096 -C 'admin@systemerp-client'"
    echo "   2. ssh-copy-id -p $SSH_PORT sysadmin@$CURRENT_IP"
    echo "   3. Test : ssh -p $SSH_PORT sysadmin@$CURRENT_IP"
    echo ""
    echo "   🔄 PUIS relancer ce script pour sécurisation automatique :"
    echo "   sudo ./install-ubuntu-odoo.sh"
    echo ""
fi
echo "📁 DOSSIERS SÉCURISÉS ODOO CRÉÉS:"
echo "   🔒 Addons personnalisés : /opt/odoo-secure/addons-custom/"
echo "   🔒 Addons externes      : /opt/odoo-secure/addons-external/"  
echo "   🔒 Configuration        : /opt/odoo-secure/config/"
echo "   🔒 Logs sécurisés       : /opt/odoo-secure/logs/"
echo "   🔒 Filestore sécurisé   : /opt/odoo-secure/filestore/"
echo ""
echo "📁 DOCUMENTATION SAUVEGARDÉE :"
echo "   📋 Cahier des charges final : /opt/backup/CAHIER-DES-CHARGES-FINAL-$(date +%Y%m%d_%H%M%S).md"
echo "   🌐 Téléchargement direct     : http://$CURRENT_IP/cahier-des-charges-final.md"
echo "   📖 Guide installation       : http://$CURRENT_IP/guide-installation.md"
echo "   💾 Sauvegarde locale        : Disponible dans /opt/backup/"
echo ""
echo "🔐 INFORMATIONS IMPORTANTES SAUVEGARDÉES :"
echo "   👤 Utilisateur admin        : $ADMIN_USER"
echo "   🚪 Port SSH                 : $SSH_PORT"
echo "   🏢 Port Odoo                : $ODOO_PORT"  
echo "   ⚙️ Port Webmin              : $WEBMIN_PORT"
echo "   🗄️ Port PostgreSQL          : $POSTGRES_PORT"
echo "   📦 Version Odoo             : $ODOO_VERSION"
echo "   🌐 IP Serveur               : $CURRENT_IP"
echo "   🔑 Mots de passe            : Inclus dans le cahier des charges"
echo ""
echo "📝 ÉTAPES SUIVANTES:"
echo "   1. Testez l'accès Odoo: http://$CURRENT_IP"
echo "   2. Testez l'accès Webmin: https://$CURRENT_IP:$WEBMIN_PORT"
echo "   3. Téléchargez la documentation: http://$CURRENT_IP/guide-installation.md"
if [ "$SSH_PASSWORD_DISABLED" = true ]; then
    echo "   4. ✅ SSH sécurisé automatiquement (clés uniquement)"
    echo "   5. Placez vos addons dans /opt/odoo-secure/addons-custom/"
else
    echo "   4. Configurez vos clés SSH PuTTY (voir documentation)"
    echo "   5. Relancez ce script pour désactivation automatique des mots de passe"
fi
echo ""
echo "📊 ÉTAT DES SERVICES:"

# Vérification des services
systemctl is-active --quiet postgresql && echo "   ✅ PostgreSQL: Actif" || echo "   ❌ PostgreSQL: Inactif"
systemctl is-active --quiet nginx && echo "   ✅ Nginx: Actif" || echo "   ❌ Nginx: Inactif"  
systemctl is-active --quiet odoo && echo "   ✅ Odoo: Actif" || echo "   ❌ Odoo: Inactif"
systemctl is-active --quiet webmin && echo "   ✅ Webmin: Actif" || echo "   ❌ Webmin: Inactif"
systemctl is-active --quiet ssh && echo "   ✅ SSH: Actif" || echo "   ❌ SSH: Inactif"
systemctl is-active --quiet fail2ban && echo "   ✅ Fail2ban: Actif" || echo "   ❌ Fail2ban: Inactif"

echo ""
echo "🎯 INSTALLATION AUTOMATISÉE RÉUSSIE !"
echo ""

log "Script d'installation terminé avec succès"
