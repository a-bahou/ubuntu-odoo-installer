# 🚀 Ubuntu Server + Odoo - Installation Automatisée Sécurisée

Script d'installation automatique pour **Ubuntu Server 22.04** avec **Odoo (16.0/17.0/18.0)**, PostgreSQL, Nginx et Webmin.

## ⚡ Installation Ultra-Rapide (5-10 minutes)

### **🔧 Prérequis Minimum**
```bash
# Sur Ubuntu Server fraîchement installé
sudo apt update
sudo apt install -y nano wget curl  # Outils de base requis
```

### **🚀 Installation Automatique Complète avec Vérifications**
```bash
wget https://raw.githubusercontent.com/a-bahou/ubuntu-odoo-installer/main/install-ubuntu-odoo.sh
chmod +x install-ubuntu-odoo.sh
sudo ./install-ubuntu-odoo.sh
```

**Le script vérifie automatiquement :**
- ✅ Installation de tous les outils système
- ✅ Fonctionnement des services (PostgreSQL, Nginx, Odoo, Webmin)
- ✅ Connectivité sur tous les ports personnalisés
- ✅ Dépendances Python pour modules Odoo avancés
- ✅ wkhtmltopdf pour génération PDF

### **📋 Processus Post-Installation**

#### **1. Création Base de Données Odoo**
```bash
# Après installation, le Database Manager est OUVERT temporairement
# Accédez à : http://IP_SERVEUR/web/database
# Utilisez le Master Password fourni lors de l'installation
# Créez votre base de données Odoo
```

#### **2. Sécurisation Automatique**
```bash
# IMPORTANT : Après création de votre base de données
# Téléchargez et exécutez le script de sécurisation
wget http://IP_SERVEUR/secure-after-db-creation.sh
sudo bash secure-after-db-creation.sh

# Ce script :
# ✅ Ferme l'accès au Database Manager (list_db = False)
# ✅ Applique les sécurisations finales
# ✅ Redémarre Odoo avec la configuration sécurisée
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

### **Vérification Automatique Complète**
```bash
# Le script génère automatiquement des vérifications
# Voir le rapport final d'installation pour :
✅ État de tous les services
✅ Connectivité sur tous les ports
✅ Dépendances Python installées
✅ wkhtmltopdf fonctionnel
✅ Base de données PostgreSQL configurée
```

### **Logs Système**
```bash
sudo tail -f /opt/odoo-secure/logs/odoo.log
sudo fail2ban-client status sshd
sudo journalctl -u odoo -f
```

### **Test Database Manager**
```bash
# Avant sécurisation (Database Manager ouvert)
curl -I http://IP_SERVEUR/web/database
# Doit retourner : 200 OK

# Après sécurisation (Database Manager fermé)
curl -I http://IP_SERVEUR/web/database  
# Doit retourner : erreur ou message "disabled"
```

## 🚨 Dépannage Rapide

### **Installation - Vérifications Automatiques**
Le script vérifie automatiquement chaque composant installé :

```bash
# Si erreur lors des vérifications :
[ERREUR] Outils manquants après installation : curl wget
[ERREUR] PostgreSQL ne démarre pas correctement
[ERREUR] wkhtmltopdf non installé ou non fonctionnel
[ERREUR] Odoo n'écoute pas sur le port 9017
```

**Solutions :**
```bash
# Réinstaller outils manquants
sudo apt install -y curl wget git nano

# Redémarrer services
sudo systemctl restart postgresql nginx odoo webmin

# Vérifier logs
sudo journalctl -u odoo -f
sudo journalctl -u postgresql -f
```

### **Odoo ne démarre pas :**
```bash
sudo chown -R odoo:odoo /opt/odoo-secure/
sudo systemctl restart odoo
```

### **Database Manager fermé prématurément :**
```bash
# Si vous devez rouvrir le Database Manager
sudo nano /opt/odoo-secure/config/odoo.conf
# Changer : list_db = False → list_db = True
sudo systemctl restart odoo

# Après création DB, relancer la sécurisation
sudo bash secure-after-db-creation.sh
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

### **Script de sécurisation échoue :**
```bash
# Vérifier l'état d'Odoo
sudo systemctl status odoo

# Restaurer configuration précédente
sudo cp /opt/odoo-secure/config/odoo.conf.backup-* /opt/odoo-secure/config/odoo.conf
sudo systemctl restart odoo
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

## 🎯 Avantages du Système Amélioré

### **🔍 Vérifications Automatiques**
- ✅ **Zéro défaillance** : Chaque composant vérifié avant continuation
- ✅ **Diagnostic précis** : Messages d'erreur clairs si problème
- ✅ **Fiabilité maximale** : Installation garantie fonctionnelle
- ✅ **Gain de temps** : Détection immédiate des problèmes

### **🔒 Sécurité en Deux Phases**
- ✅ **Phase 1** : Installation avec Database Manager ouvert (création DB)
- ✅ **Phase 2** : Sécurisation automatique après création DB
- ✅ **Flexibilité** : Possibilité de créer plusieurs bases avant sécurisation
- ✅ **Sécurité finale** : Database Manager fermé définitivement

### **📋 Documentation Automatique**
- ✅ **Cahier des charges** complet avec toutes les informations
- ✅ **Script de sécurisation** téléchargeable automatiquement  
- ✅ **Mots de passe** sauvegardés pour chaque installation
- ✅ **Traçabilité** complète de la configuration

### **🛠️ Maintenance Simplifiée**
- ✅ **Commandes de diagnostic** pré-configurées
- ✅ **Scripts de dépannage** inclus
- ✅ **Sauvegarde automatique** avec restauration facile
- ✅ **Support technique** facilité par la documentation

---

**🚀 Installation automatisée développée pour la production critique**  
**🔒 Sécurité maximale + Vérifications systématiques + Documentation complète**  
**📅 Mis à jour : Juillet 2025**
