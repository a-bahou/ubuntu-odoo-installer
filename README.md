# 🚀 Ubuntu Server + Odoo - Installation Automatisée Sécurisée

Script d'installation automatique pour **Ubuntu Server 22.04** avec **Odoo (16.0/17.0/18.0)**, PostgreSQL, Nginx et Webmin.

## ⚡ Installation Ultra-Rapide (15-30 minutes)

### **🔧 Prérequis Minimum**
```bash
# Sur Ubuntu Server fraîchement installé
sudo apt update
sudo apt install -y nano wget curl  # Outils de base requis
```

### **🚀 Installation Automatique Complète**
```bash
wget https://raw.githubusercontent.com/a-bahou/ubuntu-odoo-installer/main/install-ubuntu-odoo.sh
chmod +x install-ubuntu-odoo.sh
sudo ./install-ubuntu-odoo.sh
```

## 🎯 Fonctionnalités Incluses

### 🛡️ **Sécurité Maximale**
- ✅ **Firewall UFW** avec ports personnalisés
- ✅ **SSH sécurisé** + désactivation automatique mots de passe
- ✅ **Fail2ban** anti-intrusion
- ✅ **PostgreSQL** port personnalisé
- ✅ **Odoo structure sécurisée** (addons protégés)
- ✅ **Chiffrement** configurations sensibles

### 🏢 **Applications Installées**
- ✅ **Odoo** (version configurable)
- ✅ **PostgreSQL** avec port custom
- ✅ **Nginx** reverse proxy
- ✅ **Webmin** administration web
- ✅ **wkhtmltopdf** (génération PDF optimisée)
- ✅ **Sauvegarde automatique** quotidienne

### 🐍 **Dépendances Python Incluses**
- ✅ **dropbox** - Intégration Dropbox
- ✅ **pyncclient** - Connexion Nextcloud
- ✅ **nextcloud-api-wrapper** - API Nextcloud avancée
- ✅ **boto3** - Intégration AWS/S3
- ✅ **paramiko** - Connexions SSH/SFTP
- ✅ **Autres** : requests, cryptography, pillow, reportlab, qrcode, xlsxwriter...

### ⚙️ **Configuration Interactive**
- ✅ **Ports personnalisés** (SSH, Odoo, PostgreSQL, Webmin)
- ✅ **Version Odoo** au choix (16.0, 17.0, 18.0)
- ✅ **IP fixe** (détection auto + option manuelle)
- ✅ **Mots de passe** (défaut B@hou1983 ou personnalisé)

## 🔧 Ports par Défaut (Configurables)

| Service    | Port Standard | Port Personnalisé | Sécurité      |
|------------|---------------|-------------------|---------------|
| SSH        | 22            | 8173              | ✅ Obfusqué   |
| HTTP       | 80            | 80                | ✅ Nginx      |
| HTTPS      | 443           | 443               | ✅ SSL        |
| Odoo       | 8069          | 9017              | ✅ Masqué     |
| PostgreSQL | 5432          | 6792              | ✅ Interne    |
| Webmin     | 10000         | 12579             | ✅ SSL        |

## 📋 Processus d'Installation

### 🔑 **Option 1 - Sécurité Maximale (RECOMMANDÉE)**

**1. Configuration PuTTY d'abord :**
```bash
# Sur le serveur Ubuntu (nano inclus automatiquement dans le script)
mkdir -p ~/.ssh
nano ~/.ssh/authorized_keys
# Coller votre clé publique PuTTY
chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys
```

**2. Installation automatique complète :**
```bash
wget https://raw.githubusercontent.com/a-bahou/ubuntu-odoo-installer/main/install-ubuntu-odoo.sh
chmod +x install-ubuntu-odoo.sh
sudo ./install-ubuntu-odoo.sh
```

**Résultat :** 🔒 **Sécurisation SSH automatique** (mots de passe désactivés)

### 🔧 **Option 2 - Installation Rapide**

**1. Installation directe :**
```bash
sudo ./install-ubuntu-odoo.sh
```

**2. Configuration PuTTY après installation**

**3. Sécurisation automatique :**
```bash
sudo ./install-ubuntu-odoo.sh  # Relancer pour désactivation auto des mots de passe
```

## 🖥️ Configuration PuTTY (Windows)

### **A. Génération Clé SSH**
1. **Télécharger** : [PuTTY + PuTTYgen](https://www.putty.org/)
2. **PuTTYgen** : Type RSA, 4096 bits, Generate
3. **Sauver** : `systemerp-prod.ppk` (clé privée)
4. **Copier** : Clé publique (zone de texte)

### **B. Configuration Session PuTTY**
- **Host** : IP_SERVEUR
- **Port** : Port SSH configuré (défaut: 8173)
- **SSH → Auth → Credentials** : Charger `systemerp-prod.ppk`
- **Connection → Data** : Auto-login username: `sysadmin`
- **Session** : Sauver comme `SystemERP-Prod`

## 🌐 URLs d'Accès Final

```
🏢 Odoo ERP       : http://IP_SERVEUR
⚙️ Webmin Admin   : https://IP_SERVEUR:PORT_WEBMIN
🔑 SSH PuTTY      : IP_SERVEUR:PORT_SSH
🗄️ PostgreSQL     : localhost:PORT_POSTGRES (interne)
```

## 📁 Structure Sécurisée Odoo

```
/opt/odoo-secure/
├── addons-custom/          # 🔒 Vos addons personnalisés (chmod 750)
├── addons-external/        # 🔒 Addons tiers téléchargés (chmod 750)
├── config/                 # 🔒 Configuration sécurisée (chmod 640)
│   └── odoo.conf          # Configuration principale
├── filestore/             # 🔒 Données Odoo (chmod 750)
└── logs/                  # 📊 Logs isolés (chmod 755)
```

**Propriétaire unique :** `odoo:odoo` (protection maximale)

### 🧩 **Modules Odoo Supportés Automatiquement**
Grâce aux dépendances Python installées, ces modules fonctionnent immédiatement :

- ✅ **Cloud Storage** : Dropbox, AWS S3, Nextcloud
- ✅ **Documents** : Génération PDF, Excel, QR codes
- ✅ **Intégrations** : SSH/SFTP, API externes
- ✅ **Backup** : Sauvegarde cloud automatique
- ✅ **Reporting** : Rapports avancés avec graphiques

## 💾 Sauvegarde Automatique

### **Sauvegarde Quotidienne (02h00)**
```bash
# Contenu sauvegardé automatiquement :
- Base de données PostgreSQL
- Filestore Odoo sécurisé  
- Addons personnalisés
- Configurations système
- Rétention : 7 jours
```

### **Localisation :** `/opt/backup/`

## 🔍 Vérification Installation

### **Services Actifs**
```bash
sudo systemctl status postgresql nginx odoo webmin ssh fail2ban
```

### **Ports en Écoute**
```bash
sudo ss -tlnp | grep -E "(8173|9017|6792|12579)"
```

### **Logs Système**
```bash
sudo tail -f /opt/odoo-secure/logs/odoo.log
sudo fail2ban-client status sshd
```

## 🚨 Dépannage Rapide

### **Odoo ne démarre pas :**
```bash
sudo chown -R odoo:odoo /opt/odoo-secure/
sudo systemctl restart odoo
```

### **Modules Odoo manquent des dépendances :**
```bash
# Réinstallation dépendances Python
sudo pip3 install --upgrade dropbox pyncclient nextcloud-api-wrapper boto3 paramiko

# Vérification wkhtmltopdf
wkhtmltopdf --version
```

### **Génération PDF ne fonctionne pas :**
```bash
# Test wkhtmltopdf
echo "<h1>Test PDF</h1>" | wkhtmltopdf - test.pdf
# Si erreur, réinstaller :
sudo apt install -y wkhtmltopdf
```

### **SSH bloqué :**
```bash
# Accès physique au serveur :
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl restart sshd
```

### **Firewall bloque l'accès :**
```bash
sudo ufw status
sudo ufw allow PORT_NUMBER/tcp
```

## 🔐 Sécurité Post-Installation

### **Recommandations Critiques**
1. **Changez** le mot de passe master Odoo
2. **Configurez** SSL/HTTPS avec Let's Encrypt
3. **Testez** les sauvegardes régulièrement
4. **Surveillez** les logs Fail2ban
5. **Mettez à jour** le système mensuellement

### **Commandes de Maintenance**
```bash
# Mise à jour système
sudo apt update && sudo apt upgrade -y

# Nettoyage logs
sudo journalctl --vacuum-time=30d

# Test sauvegarde
/opt/backup/backup-odoo.sh

# Monitoring sécurité
sudo fail2ban-client status
sudo ufw status numbered
```

## 📊 Spécifications Techniques

### **Prérequis Serveur**
- **OS** : Ubuntu Server 22.04 LTS
- **RAM** : 8GB minimum (16GB recommandé)
- **CPU** : 4 cores minimum
- **Stockage** : 100GB SSD minimum
- **Réseau** : 1 Gbps

### **Compatibilité**
- **Versions Odoo** : 16.0, 17.0, 18.0
- **PostgreSQL** : 14+
- **Python** : 3.10
- **Nginx** : 1.18+
- **wkhtmltopdf** : 0.12.6+ (version officielle)

### **Dépendances Automatiques**
- **Système** : nano, curl, wget, git, pip3
- **Python** : dropbox, boto3, paramiko, pyncclient, nextcloud-api-wrapper
- **PDF** : wkhtmltopdf (version officielle GitHub)
- **Fonts** : fontconfig, xfonts-base, xfonts-75dpi

## 🎯 Cas d'Usage

### **Production Entreprise**
- ✅ **PME** : 5-50 utilisateurs
- ✅ **Données critiques** : Chiffrement + sauvegarde
- ✅ **Accès distant** : SSH clés + VPN recommandé
- ✅ **Maintenance** : Monitoring automatique

### **Développement/Test**
- ✅ **Environnement isolé** : Addons personnalisés
- ✅ **Déploiement rapide** : 15-30 minutes
- ✅ **Configuration flexible** : Ports variables

## 🆘 Support

### **Logs de Diagnostic**
```bash
# Logs installation
sudo journalctl -u odoo -f

# Configuration SSH
sudo sshd -T

# Status complet
sudo systemctl --failed
```

### **Community & Issues**
- **GitHub** : [a-bahou/ubuntu-odoo-installer](https://github.com/a-bahou/ubuntu-odoo-installer)
- **Documentation** : README.md
- **Issues** : GitHub Issues

---

**🚀 Installation automatisée développée pour la production critique**  
**🔒 Sécurité maximale + Rapidité d'installation optimisée**  
**📅 Mis à jour : Juin 2025**
