# 🚀 Ubuntu Server + Odoo - Installation Automatisée Sécurisée

Script d'installation automatique pour **Ubuntu Server 22.04** avec **Odoo (16.0/17.0/18.0)**, PostgreSQL, Nginx et Webmin.

## ⚡ Installation Ultra-Rapide (5-8 minutes)

### **🔧 Prérequis Minimum**
```bash
# Sur Ubuntu Server fraîchement installé
sudo apt update
sudo apt upgrade -y
sudo apt install -y nano wget curl  # Outils de base requis
```

### **🚀 Installation Automatique Complète**
```bash
wget https://raw.githubusercontent.com/a-bahou/ubuntu-odoo-installer/main/install-ubuntu-odoo.sh
chmod +x install-ubuntu-odoo.sh
sudo ./install-ubuntu-odoo.sh
```

**Le script vous demande quelques configurations au début, puis s'exécute automatiquement sans interruption !**

## 🎯 Fonctionnalités Incluses

### 🛡️ **Sécurité Maximale**
- ✅ **Firewall UFW** avec ports personnalisés
- ✅ **SSH sécurisé** + désactivation automatique mots de passe
- ✅ **Fail2ban** anti-intrusion
- ✅ **PostgreSQL** port personnalisé + utilisateur dédié
- ✅ **Odoo structure sécurisée** (addons protégés chmod 750)
- ✅ **Détection automatique clés SSH** + sécurisation

### 🏢 **Applications Installées**
- ✅ **Odoo** (version configurable 16.0/17.0/18.0)
- ✅ **PostgreSQL** avec port custom + utilisateur dédié
- ✅ **Nginx** reverse proxy complet
- ✅ **Webmin** administration web (port SSL custom)
- ✅ **wkhtmltopdf** (génération PDF optimisée - version officielle)
- ✅ **Sauvegarde automatique** quotidienne avec rétention

### 🐍 **Dépendances Python Complètes**
- ✅ **dropbox** - Intégration Dropbox
- ✅ **pyncclient** - Connexion Nextcloud
- ✅ **nextcloud-api-wrapper** - API Nextcloud avancée
- ✅ **boto3** - Intégration AWS/S3
- ✅ **paramiko** - Connexions SSH/SFTP
- ✅ **lxml + lxml[html_clean] + lxml_html_clean** - Parsing XML/HTML complet
- ✅ **Autres** : requests, cryptography, pillow, reportlab, qrcode, xlsxwriter, openpyxl...

### ⚙️ **Configuration Interactive Intelligente**
- ✅ **Ports personnalisés** (SSH, Odoo, PostgreSQL, Webmin)
- ✅ **Version Odoo** au choix (16.0, 17.0, 18.0)
- ✅ **IP fixe** (détection auto + option manuelle)
- ✅ **Mots de passe** (défaut B@hou1983 ou personnalisé)
- ✅ **Installation 100% automatique** après configuration

### 📋 **Documentation Automatique**
- ✅ **Cahier des charges final** généré automatiquement
- ✅ **Tous les mots de passe** de l'installation inclus
- ✅ **Configuration complète** documentée
- ✅ **Téléchargeable immédiatement** sur le serveur

## 🔧 Ports par Défaut (Configurables)

| Service    | Port Standard | Port Personnalisé | Sécurité      |
|------------|---------------|-------------------|---------------|
| SSH        | 22            | 8173              | ✅ Obfusqué   |
| HTTP       | 80            | 80                | ✅ Nginx      |
| HTTPS      | 443           | 443               | ✅ SSL        |
| Odoo       | 8069          | 9017              | ✅ Masqué     |
| PostgreSQL | 5432          | 6792              | ✅ Interne    |
| Webmin     | 10000         | 12579             | ✅ SSL        |

## 📋 Processus d'Installation Optimisé

### 🔑 **Option 1 - Sécurité Maximale (RECOMMANDÉE)**

**1. Configuration SSH d'abord (Choisir votre méthode) :**

#### **Windows (PuTTY) :**
```bash
# 1. PuTTYgen : RSA 4096 bits, Generate, Save: systemerp-client.ppk
# 2. Sur serveur :
mkdir -p ~/.ssh
nano ~/.ssh/authorized_keys
# Coller clé publique PuTTY
chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys
```

#### **Linux/Ubuntu (Terminal) :**
```bash
# Sur votre PC Linux :
ssh-keygen -t rsa -b 4096 -C "admin@systemerp-client"
ssh-copy-id -p PORT_SSH sysadmin@IP_SERVEUR
```

**2. Installation automatique complète :**
```bash
wget https://raw.githubusercontent.com/a-bahou/ubuntu-odoo-installer/main/install-ubuntu-odoo.sh
chmod +x install-ubuntu-odoo.sh
sudo ./install-ubuntu-odoo.sh
```

**Résultat :** 🔒 **Sécurisation SSH automatique** (mots de passe désactivés automatiquement)

---

### 🔧 **Option 2 - Installation Rapide**

**1. Installation directe :**
```bash
sudo ./install-ubuntu-odoo.sh
```

**2. Configuration SSH après installation**  
**3. Sécurisation automatique :**
```bash
sudo ./install-ubuntu-odoo.sh  # Relancer → détection clés + sécurisation auto
```

## ⚙️ Configuration Interactive du Script

### **🎛️ Questions Posées (Valeurs par Défaut Disponibles)**
```
🔧 CONFIGURATION DES PORTS :
Port SSH [8173]: 
Port Webmin [12579]: 
Port Odoo [9017]: 
Port PostgreSQL [6792]: 

📦 VERSION ODOO :
Version Odoo [17.0]: 18.0

🌐 CONFIGURATION RÉSEAU :
Adresse IP serveur [détectée automatiquement]: 

🔐 CONFIGURATION DES MOTS DE PASSE :
Mot de passe PostgreSQL [B@hou1983]: 
Mot de passe Master Odoo [B@hou1983]: 
```

**Puis installation automatique 5-8 minutes sans interruption !**

## 🖥️ Configuration SSH - Deux Méthodes

### **🔑 MÉTHODE 1 - PuTTY (Windows)**

#### **A. Génération Clé SSH avec PuTTYgen**
1. **Télécharger** : [PuTTY + PuTTYgen](https://www.putty.org/)
2. **Lancer PuTTYgen** :
   - **Type of key** : RSA
   - **Number of bits** : 4096
   - **Cliquer Generate** et bouger la souris
3. **Sauvegarder** :
   - **Key comment** : `admin@systemerp-client`
   - **Key passphrase** : (optionnel mais recommandé)
   - **Save private key** : `systemerp-client.ppk`
   - **Copier** le texte de la clé publique (zone "Public key for pasting...")

#### **B. Installation Clé sur Serveur**
```bash
# Connexion SSH temporaire avec mot de passe
ssh -p 8173 sysadmin@IP_SERVEUR

# Installation de la clé publique
mkdir -p ~/.ssh
nano ~/.ssh/authorized_keys
# Coller la clé publique PuTTYgen (TOUT le texte)
# Ctrl+X, Y, ENTRÉE pour sauvegarder

# Permissions correctes
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
exit
```

#### **C. Configuration Session PuTTY**
1. **PuTTY Configuration** :
   - **Host Name** : IP_SERVEUR
   - **Port** : PORT_SSH_CONFIGURÉ (ex: 8173)
   - **Connection → SSH → Auth → Credentials** : 
     - **Browse** → Sélectionner `systemerp-client.ppk`
   - **Connection → Data** :
     - **Auto-login username** : `sysadmin`
2. **Session** :
   - **Saved Sessions** : `SystemERP-Client`
   - **Save**

#### **D. Test et Finalisation**
```bash
# Test connexion avec clé (session PuTTY sauvée)
# Si connexion réussie, relancer le script pour sécurisation auto :
sudo ./install-ubuntu-odoo.sh
# Le script détectera les clés et désactivera automatiquement les mots de passe SSH
```

---

### **🔑 MÉTHODE 2 - Terminal Linux/Ubuntu**

#### **A. Génération Clé SSH (sur votre PC Ubuntu/Linux)**
```bash
# Sur votre ordinateur Ubuntu/Linux
ssh-keygen -t rsa -b 4096 -C "admin@systemerp-client"

# Réponses aux questions :
# Enter file in which to save the key: [ENTRÉE] (défaut)
# Enter passphrase: [mot de passe optionnel]
# Enter same passphrase again: [répéter mot de passe]

# Vérification clé créée
ls -la ~/.ssh/
# Vous devez voir : id_rsa (privée) et id_rsa.pub (publique)
```

#### **B. Copie Clé vers Serveur**
```bash
# Méthode automatique (recommandée)
ssh-copy-id -p PORT_SSH sysadmin@IP_SERVEUR
# Exemple : ssh-copy-id -p 8173 sysadmin@192.168.1.100

# OU méthode manuelle
# Afficher votre clé publique
cat ~/.ssh/id_rsa.pub

# Copier le résultat, puis sur le serveur :
ssh -p PORT_SSH sysadmin@IP_SERVEUR
mkdir -p ~/.ssh
nano ~/.ssh/authorized_keys
# Coller votre clé publique
chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys
exit
```

#### **C. Test Connexion SSH avec Clé**
```bash
# Test connexion avec clé (depuis votre PC Ubuntu)
ssh -p PORT_SSH sysadmin@IP_SERVEUR

# Si connexion réussie sans mot de passe :
# ✅ Configuration SSH réussie !

# Pour sécurisation automatique, relancer le script :
sudo ./install-ubuntu-odoo.sh
# Le script détectera les clés et désactivera automatiquement les mots de passe
```

#### **D. Configuration SSH Client Permanente (Optionnel)**
```bash
# Créer configuration SSH locale pour faciliter connexion
nano ~/.ssh/config

# Ajouter :
Host systemerp-client
    HostName IP_SERVEUR
    Port PORT_SSH
    User sysadmin
    IdentityFile ~/.ssh/id_rsa

# Puis connexion simplifiée :
ssh systemerp-client
```

---

### **🔒 SÉCURISATION AUTOMATIQUE**

#### **✅ Détection Automatique des Clés**
Le script **détecte automatiquement** si des clés SSH sont configurées :

1. **Si clés détectées et fonctionnelles** :
   ```
   🔒 SÉCURITÉ SSH : MAXIMALE (Mots de passe automatiquement désactivés)
   ✅ Clés SSH détectées et fonctionnelles
   ✅ PasswordAuthentication automatiquement désactivé
   ```

2. **Si clés non configurées** :
   ```
   🔑 CONFIGURATION CLÉS SSH REQUISE
   [Instructions détaillées affichées]
   PUIS relancer ce script pour sécurisation automatique
   ```

#### **🔄 Processus Recommandé**
```bash
# 1. Installation serveur
sudo ./install-ubuntu-odoo.sh

# 2. Configuration clés SSH (PuTTY ou Terminal)
# [Suivre une des méthodes ci-dessus]

# 3. Sécurisation automatique
sudo ./install-ubuntu-odoo.sh
# Script détecte les clés et sécurise automatiquement

# 4. Connexion sécurisée uniquement par clés
```

## 🌐 URLs d'Accès Final

### **🔗 Accès Utilisateur**
```
🏢 Odoo ERP          : http://IP_SERVEUR via User admin par default : admin-sys-erp
🏢 Odoo Direct       : http://IP_SERVEUR:PORT_ODOO
⚙️ Webmin Admin      : https://IP_SERVEUR:PORT_WEBMIN
🔑 SSH               : IP_SERVEUR:PORT_SSH
```

### **📋 Documentation Automatique**
```
📖 Guide Installation      : http://IP_SERVEUR/guide-installation.md
📋 Cahier des Charges     : http://IP_SERVEUR/cahier-des-charges-final.md
💾 Sauvegarde Locale      : /opt/backup/
```

**Exemple avec IP 192.168.1.100 :**
```
🏢 Odoo ERP          : http://192.168.1.100
⚙️ Webmin Admin      : https://192.168.1.100:12579
🔑 SSH PuTTY         : 192.168.1.100:8173
📋 Cahier des Charges: http://192.168.1.100/cahier-des-charges-final.md
```

## 📋 Cahier des Charges Automatique

### **🎯 Contenu Généré Automatiquement**
- ✅ **Informations serveur** (IP, hostname, date installation)
- ✅ **Tous les ports configurés** pour cette installation
- ✅ **Tous les mots de passe** utilisés
- ✅ **Configuration sécurité** (SSH, Firewall, Fail2ban)
- ✅ **Structure Odoo** et dépendances installées
- ✅ **URLs d'accès** spécifiques au serveur
- ✅ **Commandes maintenance** personnalisées
- ✅ **État des services** au moment de l'installation

### **💾 Téléchargement**
```bash
# Immédiatement après installation :
wget http://IP_SERVEUR/cahier-des-charges-final.md

# Sauvegarde locale pour vos archives :
cp cahier-des-charges-final.md "Client-$(date +%Y%m%d)-Installation.md"
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

### **✅ Services Actifs (Tous doivent être "active")**
```bash
sudo systemctl status postgresql nginx odoo webmin ssh fail2ban
```

### **✅ Ports en Écoute**
```bash
sudo ss -tlnp | grep -E "(8173|9017|6792|12579)"
```

**Résultat attendu :**
```
LISTEN 0  128  0.0.0.0:8173   (sshd)      # SSH
LISTEN 0  128  0.0.0.0:9017   (odoo)      # Odoo
LISTEN 0  128  localhost:6792 (postgres)  # PostgreSQL
LISTEN 0  128  0.0.0.0:12579  (miniserv)  # Webmin
```

### **✅ Test Accès Web**
```bash
# Test Odoo local
curl -I http://localhost:9017
# Doit retourner : HTTP/1.0 303 SEE OTHER

# Test depuis navigateur
# http://IP_SERVEUR → Page login Odoo
# https://IP_SERVEUR:12579 → Interface Webmin
```

### **✅ Vérification Sécurité SSH**
```bash
# Vérifier port SSH custom
sudo ss -tlnp | grep :8173

# Vérifier config SSH
sudo grep -E "(Port|PasswordAuthentication)" /etc/ssh/sshd_config

# Test clés SSH (depuis votre PC)
ssh -p 8173 sysadmin@IP_SERVEUR  # Doit fonctionner sans mot de passe
```

## 🚨 Dépannage Rapide

### **❌ Erreur : "Odoo Inactif"**
```bash
# Diagnostic
sudo systemctl status odoo
sudo journalctl -u odoo -n 20

# Solution
sudo chown -R odoo:odoo /opt/odoo-secure/
sudo systemctl restart odoo
```

### **❌ Erreur : "Port SSH connection refused"**
```bash
# Vérifier firewall
sudo ufw status
sudo ufw allow 8173/tcp

# Vérifier service SSH
sudo systemctl status ssh
sudo systemctl restart ssh
```

### **❌ Erreur : "Webmin SSL certificate"**
```bash
# Régénérer certificat Webmin
sudo /usr/share/webmin/miniserv.pl /etc/webmin/miniserv.conf &
sudo systemctl restart webmin
```

### **❌ Erreur : "PostgreSQL connection failed"**
```bash
# Vérifier PostgreSQL
sudo systemctl status postgresql
sudo ss -tlnp | grep 6792

# Redémarrage
sudo systemctl restart postgresql
sudo systemctl restart odoo
```

### **❌ Erreur : "lxml.html.clean ImportError"**
```bash
# Diagnostic
sudo journalctl -u odoo -n 10

# Solution - Installation dépendance manquante
sudo pip3 install 'lxml[html_clean]' lxml_html_clean

# Redémarrage
sudo systemctl restart odoo
sudo systemctl status odoo
```

### **❌ Erreur : "wkhtmltopdf PDF generation"**
```bash
# Test wkhtmltopdf
wkhtmltopdf --version

# Réinstallation si nécessaire
sudo apt install -y wkhtmltopdf
# Ou version officielle :
wget https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox_0.12.6.1-2.jammy_amd64.deb
sudo dpkg -i wkhtmltox_0.12.6.1-2.jammy_amd64.deb
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
- **wkhtmltopdf** : 0.12.6+ (version officielle GitHub)

### **Dépendances Automatiques**
- **Système** : nano, curl, wget, git, pip3, fontconfig, xfonts
- **Python** : 18+ packages (dropbox, boto3, paramiko, lxml[html_clean], etc.)
- **PDF** : wkhtmltopdf version officielle
- **Sécurité** : ufw, fail2ban, rsyslog avec logs traditionnels

### **Temps d'Installation**
- **Configuration interactive** : 2-3 minutes
- **Installation automatique** : 5-8 minutes
- **Total** : 7-11 minutes selon connexion Internet

## 🔧 Maintenance Post-Installation

### **📅 Tâches Automatiques**
- **Sauvegarde quotidienne** : 02h00 (base de données + filestore + configs)
- **Rétention** : 7 jours automatique
- **Logs** : Rotation automatique via systemd

### **📅 Tâches Manuelles Recommandées**

#### **Hebdomadaires**
```bash
# Mise à jour système
sudo apt update && sudo apt upgrade -y

# Vérification logs erreurs
sudo journalctl --since "1 week ago" --priority=err

# Test sauvegarde
ls -la /opt/backup/ && /opt/backup/backup-odoo.sh
```

#### **Mensuelles**
```bash
# Nettoyage logs anciens
sudo journalctl --vacuum-time=30d

# Vérification espace disque
df -h

# Test fonctionnement SSH
ssh -p PORT_SSH sysadmin@localhost
```

### **🚨 Commandes Support**
```bash
# Diagnostic complet
sudo systemctl --failed
sudo ss -tlnp | grep -E "(8173|9017|6792|12579)"

# Redémarrage services
sudo systemctl restart postgresql nginx odoo webmin fail2ban

# Logs temps réel
sudo journalctl -f
sudo tail -f /opt/odoo-secure/logs/odoo.log
```

## 🎯 Cas d'Usage

### **Production Entreprise**
- ✅ **PME** : 5-50 utilisateurs Odoo
- ✅ **Données critiques** : Sauvegarde + sécurité maximale
- ✅ **Accès distant** : SSH clés + Webmin SSL
- ✅ **Maintenance** : Documentation automatique

### **Multi-Clients**
- ✅ **Ports différents** par client
- ✅ **Cahier des charges** spécifique par installation
- ✅ **Support facilité** : Documentation complète
- ✅ **Déploiement rapide** : 7-11 minutes par serveur

### **Développement/Test**
- ✅ **Environnement isolé** : Structure addons sécurisée
- ✅ **Versions flexibles** : Odoo 16/17/18 au choix
- ✅ **Configuration rapide** : Script intelligent

## 🆘 Support

### **📋 Logs de Diagnostic**
```bash
# Script installation
/var/log/syslog | grep "install-ubuntu-odoo"

# Configuration SSH
sudo sshd -T | grep -E "(port|password)"

# Status services
sudo systemctl list-units --failed
```

### **📞 Informations Support**
- **Repository** : [a-bahou/ubuntu-odoo-installer](https://github.com/a-bahou/ubuntu-odoo-installer)
- **Documentation** : README.md + Cahier des charges auto-généré
- **Version** : 2.0 (Juillet 2025)

---

## 🚀 NOUVEAUTÉS VERSION 2.0

### **⚡ Améliorations Majeures**
- ✅ **Installation ultra-rapide** : 5-8 minutes (vs 15-30 avant)
- ✅ **Configuration interactive** intelligente avec valeurs par défaut
- ✅ **Mode 100% non-interactif** : Aucune interruption après lancement
- ✅ **Détection automatique SSH** : Sécurisation auto si clés présentes
- ✅ **Documentation automatique** : Cahier des charges personnalisé généré

### **🔒 Sécurité Renforcée**
- ✅ **Structure Odoo protégée** : Addons dans `/opt/odoo-secure/` (chmod 750)
- ✅ **Double méthode SSH** : Support PuTTY (Windows) + Terminal (Linux)
- ✅ **Firewall intelligent** : Ports customs + protection automatique
- ✅ **Fail2ban optimisé** : Protection sur port SSH personnalisé

### **📦 Dépendances Complètes**
- ✅ **wkhtmltopdf officiel** : Version GitHub pour PDF parfaits
- ✅ **Python packages** : 16+ modules pour tous addons Marketplace
- ✅ **Cloud ready** : Dropbox, AWS S3, Nextcloud intégrés
- ✅ **Automation** : paramiko pour SSH/SFTP automatisé

### **📋 Documentation Automatique**
- ✅ **Cahier des charges** généré avec infos spécifiques installation
- ✅ **Tous mots de passe** inclus dans documentation
- ✅ **Téléchargement immédiat** : `http://IP_SERVEUR/cahier-des-charges-final.md`
- ✅ **Support facilité** : Toutes infos clients centralisées

---

✅ Ajout de systemerp.local sur le poste Windows – Résultat : OK

1- Puis vidage du cache DNS :

ipconfig /flushdns

2- Ajout manuel de l’entrée DNS locale via modification du fichier hosts :

$hostsContent = Get-Content "C:\Windows\System32\drivers\etc\hosts"

$hostsContent += "192.168.100.240 systemerp.local"

Set-Content -Path "C:\Windows\System32\drivers\etc\hosts" -Value $hostsContent -Encoding ASCII -Force

3- Test l'acces

Get-Content ... | Select-String "systemerp.local"

ping systemerp.local

nslookup systemerp.local


**🚀 Installation automatisée développée pour la production critique**  
**🔒 Sécurité maximale + Rapidité d'installation optimisée**  
**📅 Version 2.0 - Juillet 2025**
