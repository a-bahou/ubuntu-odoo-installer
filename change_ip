#!/bin/bash

#################################################################################
# SCRIPT DE CHANGEMENT D'ADRESSE IP - SYSTEMERP
# Version: 1.0
# Description: Change l'adresse IP dans tous les fichiers de configuration
#################################################################################

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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

success() {
    echo -e "${CYAN}[SUCCÈS] $1${NC}"
}

# Fonction pour demander confirmation
confirm_step() {
    local message="$1"
    local default="$2"
    
    echo ""
    echo -e "${YELLOW}$message${NC}"
    if [ "$default" = "y" ]; then
        read -p "Continuer ? (Y/n): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Nn]$ ]]; then
            return 1
        fi
    else
        read -p "Continuer ? (y/N): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 1
        fi
    fi
    return 0
}

# Fonction de sauvegarde de fichier
backup_file() {
    local file="$1"
    local backup_suffix=$(date +%Y%m%d_%H%M%S)
    
    if [ -f "$file" ]; then
        cp "$file" "$file.backup_$backup_suffix"
        info "Sauvegarde créée : $file.backup_$backup_suffix"
        return 0
    else
        warning "Fichier non trouvé : $file"
        return 1
    fi
}

# Fonction pour changer IP dans un fichier
change_ip_in_file() {
    local file="$1"
    local old_ip="$2"
    local new_ip="$3"
    local description="$4"
    
    echo ""
    echo "================================================="
    echo "🔧 MODIFICATION: $description"
    echo "📁 Fichier: $file"
    echo "🔄 Changement: $old_ip → $new_ip"
    echo "================================================="
    
    if [ ! -f "$file" ]; then
        warning "Fichier non trouvé : $file - Ignoré"
        return 0
    fi
    
    # Vérifier si l'IP est présente dans le fichier
    if ! grep -q "$old_ip" "$file"; then
        info "Ancienne IP non trouvée dans $file - Aucun changement nécessaire"
        return 0
    fi
    
    # Afficher les lignes qui seront modifiées
    echo ""
    echo "📋 Lignes à modifier :"
    grep -n "$old_ip" "$file" | head -5
    if [ $(grep -c "$old_ip" "$file") -gt 5 ]; then
        echo "... et $(( $(grep -c "$old_ip" "$file") - 5 )) autres occurrences"
    fi
    echo ""
    
    if confirm_step "Effectuer le changement dans ce fichier ?" "y"; then
        # Sauvegarde
        backup_file "$file"
        
        # Remplacement
        sed -i "s/$old_ip/$new_ip/g" "$file"
        
        # Vérification
        local count=$(grep -c "$new_ip" "$file")
        success "✅ $count occurrences modifiées dans $file"
        
        # Afficher le résultat
        echo ""
        echo "📋 Lignes modifiées :"
        grep -n "$new_ip" "$file" | head -3
        echo ""
    else
        warning "❌ Modification annulée pour $file"
    fi
}

#################################################################################
# DÉBUT DU SCRIPT
#################################################################################

echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║              CHANGEMENT D'ADRESSE IP SYSTEMERP                  ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

# Vérification des droits root
if [ "$EUID" -ne 0 ]; then
    error "Ce script doit être exécuté en tant que root (sudo)"
fi

#################################################################################
# ÉTAPE 1: DÉTECTION ET CONFIGURATION
#################################################################################

log "Étape 1/6 : Détection de la configuration actuelle"

# Détection IP actuelle
CURRENT_IP=$(hostname -I | awk '{print $1}')
INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n1)
CURRENT_GATEWAY=$(ip route | grep default | awk '{print $3}')

echo ""
echo "🔍 CONFIGURATION ACTUELLE DÉTECTÉE :"
echo "   📡 Interface réseau : $INTERFACE"
echo "   🌐 IP actuelle      : $CURRENT_IP"
echo "   🚪 Passerelle       : $CURRENT_GATEWAY"

# Vérification de l'IP détectée
echo ""
if confirm_step "L'IP actuelle détectée ($CURRENT_IP) est-elle correcte ?" "y"; then
    OLD_IP="$CURRENT_IP"
else
    echo ""
    read -p "Saisissez l'ancienne IP à remplacer : " OLD_IP
    if [[ ! $OLD_IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        error "Format IP invalide : $OLD_IP"
    fi
fi

# Saisie nouvelle IP
echo ""
read -p "Saisissez la nouvelle IP : " NEW_IP
if [[ ! $NEW_IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    error "Format IP invalide : $NEW_IP"
fi

# Saisie nouvelle passerelle (optionnel)
echo ""
read -p "Nouvelle passerelle [$CURRENT_GATEWAY] : " NEW_GATEWAY
NEW_GATEWAY=${NEW_GATEWAY:-$CURRENT_GATEWAY}

# Calcul nouveau réseau
NEW_NETWORK=$(echo $NEW_IP | cut -d. -f1-3)
OLD_NETWORK=$(echo $OLD_IP | cut -d. -f1-3)

echo ""
echo "🎯 CHANGEMENT PLANIFIÉ :"
echo "   🔄 IP : $OLD_IP → $NEW_IP"
echo "   🔄 Passerelle : $CURRENT_GATEWAY → $NEW_GATEWAY"
echo "   🔄 Réseau : $OLD_NETWORK.0/24 → $NEW_NETWORK.0/24"

echo ""
if ! confirm_step "Confirmer le changement d'IP complet ?" "n"; then
    error "Changement d'IP annulé par l'utilisateur"
fi

#################################################################################
# ÉTAPE 2: MODIFICATION CONFIGURATION RÉSEAU
#################################################################################

log "Étape 2/6 : Modification de la configuration réseau"

# Configuration Netplan
NETPLAN_FILE="/etc/netplan/00-installer-config.yaml"
if [ -f "$NETPLAN_FILE" ]; then
    change_ip_in_file "$NETPLAN_FILE" "$OLD_IP" "$NEW_IP" "Configuration réseau Netplan"
    
    # Modification passerelle si différente
    if [ "$CURRENT_GATEWAY" != "$NEW_GATEWAY" ]; then
        echo ""
        echo "🔧 Modification de la passerelle dans Netplan..."
        if confirm_step "Changer la passerelle $CURRENT_GATEWAY → $NEW_GATEWAY ?" "y"; then
            backup_file "$NETPLAN_FILE"
            sed -i "s/$CURRENT_GATEWAY/$NEW_GATEWAY/g" "$NETPLAN_FILE"
            success "✅ Passerelle modifiée dans Netplan"
        fi
    fi
    
    # Afficher configuration finale
    echo ""
    echo "📋 Configuration Netplan finale :"
    cat "$NETPLAN_FILE"
    echo ""
    
    if confirm_step "Appliquer la nouvelle configuration réseau maintenant ?" "y"; then
        log "Application de la configuration réseau..."
        netplan apply
        success "✅ Configuration réseau appliquée"
        
        # Attendre stabilisation
        sleep 5
        
        # Vérifier nouvelle IP
        NEW_CURRENT_IP=$(hostname -I | awk '{print $1}')
        if [ "$NEW_CURRENT_IP" = "$NEW_IP" ]; then
            success "✅ Nouvelle IP active : $NEW_CURRENT_IP"
        else
            warning "⚠️ IP non encore active. Actuelle : $NEW_CURRENT_IP"
        fi
    else
        warning "⚠️ Configuration réseau non appliquée - Changements en attente"
    fi
else
    warning "Fichier Netplan non trouvé - Configuration réseau manuelle requise"
fi

#################################################################################
# ÉTAPE 3: MODIFICATION /etc/hosts
#################################################################################

log "Étape 3/6 : Modification du fichier /etc/hosts"

HOSTS_FILE="/etc/hosts"
change_ip_in_file "$HOSTS_FILE" "$OLD_IP" "$NEW_IP" "Résolution locale DNS (/etc/hosts)"

#################################################################################
# ÉTAPE 4: MODIFICATION CONFIGURATION NGINX
#################################################################################

log "Étape 4/6 : Modification de la configuration Nginx"

# Configuration site Nginx
NGINX_SITE="/etc/nginx/sites-available/systemerp.local"
if [ -f "$NGINX_SITE" ]; then
    change_ip_in_file "$NGINX_SITE" "$OLD_IP" "$NEW_IP" "Configuration Nginx (site systemerp.local)"
    
    # Test configuration Nginx
    echo ""
    if confirm_step "Tester et redémarrer Nginx avec la nouvelle configuration ?" "y"; then
        log "Test de la configuration Nginx..."
        if nginx -t; then
            systemctl reload nginx
            success "✅ Nginx redémarré avec succès"
        else
            error "❌ Erreur dans la configuration Nginx"
        fi
    fi
else
    info "Configuration Nginx systemerp.local non trouvée"
fi

# Configuration globale Nginx (si IP présente)
NGINX_CONF="/etc/nginx/nginx.conf"
if [ -f "$NGINX_CONF" ] && grep -q "$OLD_IP" "$NGINX_CONF"; then
    change_ip_in_file "$NGINX_CONF" "$OLD_IP" "$NEW_IP" "Configuration globale Nginx"
fi

#################################################################################
# ÉTAPE 5: MODIFICATION CONFIGURATION ODOO
#################################################################################

log "Étape 5/6 : Vérification de la configuration Odoo"

ODOO_CONF="/opt/odoo-secure/config/odoo.conf"
if [ -f "$ODOO_CONF" ]; then
    if grep -q "$OLD_IP" "$ODOO_CONF"; then
        change_ip_in_file "$ODOO_CONF" "$OLD_IP" "$NEW_IP" "Configuration Odoo"
        
        echo ""
        if confirm_step "Redémarrer Odoo avec la nouvelle configuration ?" "y"; then
            log "Redémarrage d'Odoo..."
            systemctl restart odoo
            sleep 5
            if systemctl is-active --quiet odoo; then
                success "✅ Odoo redémarré avec succès"
            else
                warning "⚠️ Problème redémarrage Odoo - Vérification requise"
            fi
        fi
    else
        info "Configuration Odoo utilise localhost - Aucun changement nécessaire"
    fi
else
    warning "Configuration Odoo non trouvée"
fi

#################################################################################
# ÉTAPE 6: MODIFICATION DOCUMENTATION
#################################################################################

log "Étape 6/6 : Mise à jour de la documentation"

# Cahier des charges
CAHIER_PATTERN="/opt/backup/CAHIER-DES-CHARGES-FINAL-*.md"
CAHIER_FILES=$(ls $CAHIER_PATTERN 2>/dev/null)

if [ -n "$CAHIER_FILES" ]; then
    for file in $CAHIER_FILES; do
        change_ip_in_file "$file" "$OLD_IP" "$NEW_IP" "Cahier des charges ($file)"
    done
    
    # Mise à jour lien web
    CAHIER_LINK="/var/www/html/cahier-des-charges-final.md"
    if [ -L "$CAHIER_LINK" ]; then
        change_ip_in_file "$(readlink -f $CAHIER_LINK)" "$OLD_IP" "$NEW_IP" "Documentation web"
    fi
else
    info "Aucun cahier des charges trouvé"
fi

# Guide d'installation
GUIDE_FILE="/opt/backup/GUIDE-INSTALLATION-SystemERP.md"
if [ -f "$GUIDE_FILE" ]; then
    change_ip_in_file "$GUIDE_FILE" "$OLD_IP" "$NEW_IP" "Guide d'installation"
fi

#################################################################################
# ÉTAPE 7: CRÉATION NOUVEAU CAHIER DES CHARGES
#################################################################################

echo ""
log "Génération d'un nouveau cahier des charges avec la nouvelle IP..."

if confirm_step "Créer un nouveau cahier des charges avec la nouvelle IP ?" "y"; then
    NEW_CAHIER="/opt/backup/CAHIER-DES-CHARGES-CHANGEMENT-IP-$(date +%Y%m%d_%H%M%S).md"
    
    cat > "$NEW_CAHIER" << EOF
# 📋 CHANGEMENT D'ADRESSE IP - SYSTEMERP

## 🔄 CHANGEMENT EFFECTUÉ

| Paramètre | Ancienne Valeur | Nouvelle Valeur |
|-----------|----------------|-----------------|
| **IP Serveur** | $OLD_IP | $NEW_IP |
| **Passerelle** | $CURRENT_GATEWAY | $NEW_GATEWAY |
| **Date Changement** | $(date '+%d/%m/%Y à %H:%M:%S') | - |

## 🌐 NOUVELLES URLS D'ACCÈS

```
🏢 Odoo ERP          : http://$NEW_IP
⚙️ Webmin Admin      : https://$NEW_IP:12579
🔑 SSH PuTTY         : $NEW_IP:8173
📋 Cahier des charges: http://$NEW_IP/cahier-des-charges-final.md
```

## 📁 FICHIERS MODIFIÉS

$(date '+%Y-%m-%d %H:%M:%S') - Changement IP effectué par script automatique

### 🔧 Configurations mises à jour :
- /etc/netplan/00-installer-config.yaml
- /etc/hosts
- Configuration Nginx
- Documentation SystemERP

## ✅ VÉRIFICATIONS POST-CHANGEMENT

### Tests à effectuer :
\`\`\`bash
# Test connectivité
ping $NEW_IP

# Test services web
curl -I http://$NEW_IP
curl -I https://$NEW_IP:12579

# Test SSH
ssh -p 8173 sysadmin@$NEW_IP

# Status services
sudo systemctl status nginx odoo postgresql
\`\`\`

---
Document généré automatiquement le $(date)
Changement IP : $OLD_IP → $NEW_IP
EOF

    ln -sf "$NEW_CAHIER" /var/www/html/changement-ip.md
    success "✅ Nouveau cahier des charges créé : $NEW_CAHIER"
fi

#################################################################################
# FINALISATION
#################################################################################

echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║                  CHANGEMENT D'IP TERMINÉ !                      ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

success "🎉 Changement d'IP effectué avec succès !"
echo ""
echo "📋 RÉSUMÉ DU CHANGEMENT :"
echo "   🔄 IP : $OLD_IP → $NEW_IP"
echo "   🔄 Passerelle : $CURRENT_GATEWAY → $NEW_GATEWAY"
echo ""
echo "🌐 NOUVELLES URLS D'ACCÈS :"
echo "   🏢 Odoo ERP      : http://$NEW_IP"
echo "   ⚙️ Webmin Admin  : https://$NEW_IP:12579"
echo "   🔑 SSH           : $NEW_IP:8173"
echo "   📋 Documentation : http://$NEW_IP/changement-ip.md"
echo ""

echo "✅ VÉRIFICATIONS RECOMMANDÉES :"
echo ""
echo "1. Test connectivité réseau :"
echo "   ping $NEW_IP"
echo ""
echo "2. Test services web :"
echo "   curl -I http://$NEW_IP"
echo "   curl -I https://$NEW_IP:12579"
echo ""
echo "3. Test SSH :"
echo "   ssh -p 8173 sysadmin@$NEW_IP"
echo ""
echo "4. Status des services :"
echo "   sudo systemctl status nginx odoo postgresql webmin"
echo ""

if confirm_step "Effectuer les tests de vérification maintenant ?" "y"; then
    echo ""
    log "Tests de vérification..."
    
    # Test ping
    echo "🔍 Test ping..."
    if ping -c 3 "$NEW_IP" > /dev/null 2>&1; then
        success "✅ Ping OK"
    else
        warning "⚠️ Ping failed - Vérifiez la connectivité réseau"
    fi
    
    # Test Odoo
    echo "🔍 Test Odoo..."
    if curl -s -I "http://$NEW_IP" | head -1 | grep -q "303\|200"; then
        success "✅ Odoo accessible"
    else
        warning "⚠️ Odoo non accessible - Vérifiez la configuration"
    fi
    
    # Test services
    echo "🔍 Test services..."
    systemctl is-active --quiet nginx && success "✅ Nginx actif" || warning "⚠️ Nginx inactif"
    systemctl is-active --quiet odoo && success "✅ Odoo actif" || warning "⚠️ Odoo inactif"
    systemctl is-active --quiet postgresql && success "✅ PostgreSQL actif" || warning "⚠️ PostgreSQL inactif"
fi

echo ""
echo "🎯 CHANGEMENT D'IP SYSTEMERP TERMINÉ AVEC SUCCÈS !"
log "Script de changement d'IP terminé"
EOF
