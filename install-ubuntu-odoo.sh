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
# CONFIGURATION PERSONNALISÉE - MODIFIEZ VOS PORTS ICI
#################################################################################

# Paramètres réseau
DOMAIN_LOCAL="systemerp.local"
SERVER_NAME="systemerp-prod"
ADMIN_USER="sysadmin"
ODOO_USER="sys-erp"

# Ports personnalisés (MODIFIEZ SELON VOS BESOINS)
SSH_PORT="8173"
WEBMIN_PORT="12579"
ODOO_PORT="9017"
ODOO_LONGPOLL_PORT="8072"
POSTGRES_PORT="6792"

# Interface réseau (auto-détectée ou forcée)
NETWORK_INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n1)
CURRENT_IP=$(ip addr show $NETWORK_INTERFACE | grep "inet " | awk '{print $2}' | cut -d/ -f1)
GATEWAY=$(ip route | grep default | awk '{print $3}')

# Mots de passe (SAISISSEZ VOS MOTS DE PASSE FORTS)
echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║              CONFIGURATION DES MOTS DE PASSE                    ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

read -s -p "Mot de passe PostgreSQL (postgres): " POSTGRES_ADMIN_PASS
echo ""
read -s -p "Mot de passe PostgreSQL (sys-erp): " POSTGRES_USER_PASS
echo ""
read -s -p "Mot de passe Master Odoo: " ODOO_MASTER_PASS
echo ""

# Confirmation des paramètres
echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║                    CONFIGURATION DÉTECTÉE                       ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""
echo "🌐 Interface réseau    : $NETWORK_INTERFACE"
echo "📍 IP actuelle         : $CURRENT_IP"
echo "🚪 Passerelle          : $GATEWAY"
echo "🏠 Domaine local       : $DOMAIN_LOCAL"
echo "🔑 SSH Port            : $SSH_PORT"
echo "⚙️ Webmin Port         : $WEBMIN_PORT" 
echo "🏢 Odoo Port           : $ODOO_PORT"
echo "🗄️ PostgreSQL Port     : $POSTGRES_PORT"
echo ""
read -p "Continuer avec cette configuration ? (y/N): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Installation annulée."
    exit 1
fi

#################################################################################
# ÉTAPE 1: MISE À JOUR SYSTÈME ET INSTALLATION OUTILS
#################################################################################

log "Démarrage de l'installation automatisée..."
log "ÉTAPE 1/5: Mise à jour système et installation des outils"

# Mise à jour système
log "Mise à jour du système..."
apt update && apt full-upgrade -y || error "Échec mise à jour système"

# Installation groupée des outils système
log "Installation des outils système essentiels..."
apt install -y \
    ufw fail2ban unattended-upgrades nano rsyslog cron \
    iputils-ping dnsutils net-tools curl wget git \
    python3-pip python3-dev python3-venv \
    libxml2-dev libxslt1-dev libevent-dev libsasl2-dev libldap2-dev \
    pkg-config libtiff5-dev libjpeg8-dev libopenjp2-7-dev zlib1g-dev \
    libfreetype6-dev liblcms2-dev libwebp-dev libharfbuzz-dev \
    libfribidi-dev libxcb1-dev || error "Échec installation outils"

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
apt install -y postgresql postgresql-contrib || error "Échec installation PostgreSQL"
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
apt install -y nginx certbot python3-certbot-nginx || error "Échec installation Nginx"
systemctl enable nginx

# Configuration reverse proxy Nginx
log "Configuration du reverse proxy Nginx..."
cat > /etc/nginx/sites-available/$DOMAIN_LOCAL << EOF
server {
    listen 80;
    server_name $DOMAIN_LOCAL $CURRENT_IP;
    
    # Redirection vers Odoo
    location / {
        proxy_pass http://127.0.0.1:$ODOO_PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_redirect off;
    }
    
    # WebSocket pour Odoo
    location /websocket {
        proxy_pass http://127.0.0.1:$ODOO_LONGPOLL_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
    }
}
EOF

ln -sf /etc/nginx/sites-available/$DOMAIN_LOCAL /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

nginx -t && systemctl restart nginx || error "Échec configuration Nginx"

# Installation Odoo 17
log "Installation d'Odoo 17..."
wget -O - https://nightly.odoo.com/odoo.key | gpg --dearmor -o /usr/share/keyrings/odoo-archive-keyring.gpg
echo 'deb [signed-by=/usr/share/keyrings/odoo-archive-keyring.gpg] https://nightly.odoo.com/17.0/nightly/deb/ ./' | tee /etc/apt/sources.list.d/odoo.list
apt-get update && apt-get install -y odoo || error "Échec installation Odoo"

# Création structure sécurisée Odoo
log "Création de la structure sécurisée Odoo..."
mkdir -p /opt/odoo-secure/{addons-custom,addons-external,config,logs}
chown -R $ODOO_USER:$ODOO_USER /opt/odoo-secure/
chmod 750 /opt/odoo-secure/addons-custom/
chmod 750 /opt/odoo-secure/addons-external/
chmod 750 /opt/odoo-secure/config/
chmod 755 /opt/odoo-secure/logs/

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

# Lien vers configuration sécurisée
ln -sf /opt/odoo-secure/config/odoo.conf /etc/odoo/odoo.conf
chmod 640 /opt/odoo-secure/config/odoo.conf

# Création dossier filestore sécurisé
mkdir -p /opt/odoo-secure/filestore
chown $ODOO_USER:$ODOO_USER /opt/odoo-secure/filestore
chmod 750 /opt/odoo-secure/filestore

systemctl restart odoo || error "Échec redémarrage Odoo"

# Installation Webmin
log "Installation de Webmin..."
wget -qO - http://www.webmin.com/jcameron-key.asc | apt-key add -
echo "deb http://download.webmin.com/download/repository sarge contrib" | tee -a /etc/apt/sources.list
apt update && apt install -y webmin || error "Échec installation Webmin"

# Configuration port Webmin
log "Configuration du port Webmin: $WEBMIN_PORT"
sed -i "s/port=10000/port=$WEBMIN_PORT/" /etc/webmin/miniserv.conf
sed -i "s/listen=10000/listen=$WEBMIN_PORT/" /etc/webmin/miniserv.conf

systemctl restart webmin || error "Échec redémarrage Webmin"

log "✅ Nginx, Odoo et Webmin installés et configurés"

#################################################################################
# ÉTAPE 5: SÉCURISATION FINALE
#################################################################################

log "ÉTAPE 5/5: Sécurisation finale du système"

# Configuration SSH sécurisé
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

# Sauvegarde filestore Odoo
tar -czf \$BACKUP_DIR/odoo_filestore_\${DATE}.tar.gz /var/lib/odoo/filestore/ 2>/dev/null

# Sauvegarde configurations
tar -czf \$BACKUP_DIR/configs_\${DATE}.tar.gz /etc/odoo/ /etc/nginx/sites-available/ /etc/ssh/sshd_config /etc/fail2ban/jail.local 2>/dev/null

# Nettoyage (garde 7 jours)
find \$BACKUP_DIR -name "*.sql" -mtime +7 -delete
find \$BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete

echo "Sauvegarde terminée: \${DATE}"
EOF

chmod +x /opt/backup/backup-odoo.sh

# Cron automatique
(crontab -l 2>/dev/null; echo "0 2 * * * /opt/backup/backup-odoo.sh >> /var/log/backup.log 2>&1") | crontab -

log "✅ Sécurisation finale terminée"

#################################################################################
# VÉRIFICATIONS FINALES ET RAPPORT
#################################################################################

log "Vérifications finales du système..."

echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║                    INSTALLATION TERMINÉE !                      ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""
echo "🎉 Installation automatisée terminée avec succès !"
echo ""
echo "📋 SERVICES INSTALLÉS ET CONFIGURÉS:"
echo "   ✅ Ubuntu Server sécurisé"
echo "   ✅ Firewall UFW activé avec ports personnalisés"
echo "   ✅ PostgreSQL sur port $POSTGRES_PORT"
echo "   ✅ Nginx reverse proxy"
echo "   ✅ Odoo 17 sur port $ODOO_PORT"
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
echo "🔑 CONFIGURATION CLÉS SSH PUTTY (ÉTAPES DÉTAILLÉES):"
echo "   1. Sur Windows : Télécharger PuTTY + PuTTYgen"
echo "   2. PuTTYgen : Type RSA, 4096 bits, Generate"
echo "   3. Sauver clé privée : systemerp-prod.ppk"
echo "   4. Copier clé publique (zone de texte)"
echo "   5. Sur serveur : mkdir -p ~/.ssh"
echo "   6. Sur serveur : nano ~/.ssh/authorized_keys"
echo "   7. Coller la clé publique, sauvegarder"
echo "   8. Sur serveur : chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys"
echo "   9. PuTTY Config :"
echo "      - Host: $CURRENT_IP, Port: $SSH_PORT"
echo "      - SSH→Auth→Credentials: Charger systemerp-prod.ppk"
echo "      - Connection→Data: Auto-login: $ADMIN_USER"
echo "      - Session: Sauver 'SystemERP-Prod'"
echo "   10. Test connexion avec clé"
echo "   11. Désactiver mots de passe : PasswordAuthentication no"
echo ""
echo "📁 DOSSIERS SÉCURISÉS ODOO CRÉÉS:"
echo "   🔒 Addons personnalisés : /opt/odoo-secure/addons-custom/"
echo "   🔒 Addons externes      : /opt/odoo-secure/addons-external/"  
echo "   🔒 Configuration        : /opt/odoo-secure/config/"
echo "   🔒 Logs sécurisés       : /opt/odoo-secure/logs/"
echo "   🔒 Filestore sécurisé   : /opt/odoo-secure/filestore/"
echo ""
echo "📝 ÉTAPES SUIVANTES:"
echo "   1. Testez l'accès Odoo: http://$CURRENT_IP"
echo "   2. Testez l'accès Webmin: https://$CURRENT_IP:$WEBMIN_PORT"
echo "   3. Configurez vos clés SSH PuTTY"
echo "   4. Désactivez PasswordAuthentication dans /etc/ssh/sshd_config"
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
