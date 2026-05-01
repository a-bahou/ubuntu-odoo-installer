# 📘 Manuel d'Installation Complet – Ubuntu Server + Odoo Sécurisé
*Script automatisé v2.0 – Odoo 16/17/18 | Ubuntu 22.04 LTS*

> ⏱️ Temps total : **7-11 minutes** (serveur) + **2 min** (par client)  
> 🔐 Sécurité : SSH clés, UFW, Fail2ban, ports personnalisés

---

## 📋 Sommaire
1. [Prérequis](#1-prérequis)
2. [Configuration IP Fixe – Serveur](#2-configuration-ip-fixe--serveur)
3. [Configuration SSH – Poste Client](#3-configuration-ssh--poste-client)
4. [Lancement du Script d'Installation](#4-lancement-du-script-dinstallation)
5. [Configuration Interactive](#5-configuration-interactive)
6. [Configuration IP Fixe – Postes Clients](#6-configuration-ip-fixe--postes-clients)
7. [Vérifications & Accès](#7-vérifications--accès)
8. [Maintenance & Dépannage](#8-maintenance--dépannage)

---

## 1️⃣ Prérequis

### Serveur
- Ubuntu Server 22.04 LTS fraîchement installé
- RAM : 8 Go min (16 Go recommandé) | CPU : 4 cœurs | Stockage : 100 Go SSD
- Accès root ou utilisateur avec `sudo`

### Poste client
- Linux/Ubuntu : terminal + `ssh`
- Windows : PuTTY + PuTTYgen (téléchargement : [putty.org](https://www.chiark.greenend.org.uk/~sgtatham/putty/))

### Mise à jour initiale du serveur
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y nano wget curl
```

---

## 2️⃣ Configuration IP Fixe – Serveur

> ⚠️ À faire **avant** l'installation si vous souhaitez une IP statique

### Éditer la configuration réseau
```bash
sudo nano /etc/netplan/00-installer-config.yaml
```

### Exemple de configuration
```yaml
network:
  version: 2
  ethernets:
    eth0:  # ou ens18, vérifier avec `ip link`
      dhcp4: no
      addresses:
        - 192.168.1.150/24      # ← Votre IP fixe souhaitée
      routes:
        - to: default
          via: 192.168.1.1      # ← Passerelle
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4, 192.168.1.1]
```

### Appliquer et vérifier
```bash
sudo netplan apply
ip addr show  # Vérifier que l'IP est bien appliquée
```

### Mettre à jour `/etc/hosts`
```bash
sudo nano /etc/hosts
```
```
# Remplacer l'ancienne IP par la nouvelle :
192.168.1.150    systemerp.local
192.168.1.150    systemerp-prod.systemerp.local
```

---

## 3️⃣ Configuration SSH – Poste Client

> ✅ Recommandé **avant** le script pour sécurisation automatique

### 🐧 Méthode Linux/Ubuntu
```bash
# 1. Générer la clé (sur votre poste)
ssh-keygen -t ed25519 -f ~/.ssh/labo -C "labo"

# 2. Copier vers le serveur (port 22 par défaut avant installation)
ssh-copy-id -i ~/.ssh/labo.pub sysadmin@192.168.1.150

# 3. Tester
ssh -i ~/.ssh/labo sysadmin@192.168.1.150
```

### 🪟 Méthode Windows (PuTTY)
1. **PuTTYgen** : RSA 4096 → Generate → Sauvegarder `labo.ppk`
2. **Copier la clé publique** dans `~/.ssh/authorized_keys` sur le serveur :
   ```bash
   mkdir -p ~/.ssh && nano ~/.ssh/authorized_keys
   # Coller le contenu, puis :
   chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys
   ```
3. **Configurer PuTTY** :
   - Host : `192.168.1.150` | Port : `22` (puis `8173` après installation)
   - Connection → SSH → Auth → Credentials → Sélectionner `labo.ppk`
   - Session → Saved Sessions : `SystemERP` → Save

> 🔁 Après configuration SSH, relancez le script : il détectera les clés et désactivera automatiquement l'authentification par mot de passe.

---

## 4️⃣ Lancement du Script d'Installation

```bash
# Téléchargement
wget https://raw.githubusercontent.com/a-bahou/ubuntu-odoo-installer/main/install-ubuntu-odoo.sh

# Exécution
chmod +x install-ubuntu-odoo.sh
sudo ./install-ubuntu-odoo.sh
```

> ⚡ Le script s'exécute ensuite **sans interruption** (5-8 minutes).

---

## 5️⃣ Configuration Interactive

| Catégorie | Question | Valeur par défaut |
|-----------|----------|------------------|
| 🔧 Ports | SSH / Webmin / Odoo / PostgreSQL | `8173` / `12579` / `9017` / `6792` |
| 📦 Version | Odoo | `17.0` (16.0/17.0/18.0 disponibles) |
| 🌐 Réseau | IP serveur | Détection auto (vérifiez qu'elle correspond à votre IP fixe) |
| 🔐 Mots de passe | PostgreSQL / Master Odoo | `B@hou1983` (personnalisable) |

> ✅ Validez ou personnalisez, puis laissez l'installation se poursuivre.

---

## 6️⃣ Configuration IP Fixe – Postes Clients

> 🔗 Pour accéder au serveur via un nom de domaine local (`systemerp.local`)

### 🐧 Sur Ubuntu/Linux Client
```bash
# 1. Éditer le fichier hosts
sudo nano /etc/hosts

# 2. Ajouter à la fin :
192.168.1.150    systemerp.local systemerp-prod.systemerp.local

# 3. Tester
ping -c 4 systemerp.local
curl -I http://systemerp.local
```

### 🪟 Sur Windows Client (PowerShell Admin)
```powershell
# 1. Vider le cache DNS
ipconfig /flushdns

# 2. Ajouter l'entrée hosts
$hostsPath = "C:\Windows\System32\drivers\etc\hosts"
$entry = "192.168.1.150    systemerp.local"
Add-Content -Path $hostsPath -Value $entry -Encoding ASCII -Force

# 3. Vérifier
Get-Content $hostsPath | Select-String "systemerp.local"
ping systemerp.local
nslookup systemerp.local
```

### 🔑 Configuration SSH Client (Optionnel – Linux/Ubuntu)
```bash
nano ~/.ssh/config
```
```
Host systemerp
    HostName systemerp.local
    Port 8173
    User sysadmin
    IdentityFile ~/.ssh/labo
```
```bash
# Connexion simplifiée ensuite :
ssh systemerp
```

---

## 7️⃣ Vérifications & Accès

### ✅ Sur le serveur
```bash
# Services actifs
sudo systemctl status postgresql nginx odoo webmin ssh fail2ban

# Ports en écoute
sudo ss -tlnp | grep -E "(8173|9017|6792|12579)"

# Accès local
curl -I http://localhost:9017  # Doit retourner : HTTP/1.0 303 SEE OTHER
```

### 🔗 URLs d'accès (depuis clients)
| Service | URL | Identifiants par défaut |
|---------|-----|------------------------|
| 🏢 Odoo ERP | `http://systemerp.local` | User: `admin` / Pwd: `admin-sys-erp` |
| ⚙️ Webmin | `https://systemerp.local:12579` | root / mot de passe système |
| 🔑 SSH | `systemerp.local:8173` | Clé SSH requise |

### 📄 Documentation auto-générée
```bash
# Téléchargement immédiat
wget http://systemerp.local/cahier-des-charges-final.md
wget http://systemerp.local/guide-installation.md

# Sauvegarde locale
cp cahier-des-charges-final.md "Client-$(date +%Y%m%d)-Installation.md"
```

---

## 8️⃣ Maintenance & Dépannage

### 🔄 Tâches recommandées
```bash
# Hebdomadaire
sudo apt update && sudo apt upgrade -y
sudo journalctl --since "1 week ago" --priority=err

# Mensuel
sudo journalctl --vacuum-time=30d
df -h  # Vérifier espace disque
/opt/backup/backup-odoo.sh  # Test sauvegarde
```

### 🚨 Dépannage express
| Problème | Solution |
|----------|----------|
| ❌ Odoo inactif | `sudo systemctl restart odoo` + `journalctl -u odoo -n 20` |
| ❌ SSH refusé | `sudo ufw allow 8173/tcp` + `sudo systemctl restart ssh` |
| ❌ Webmin SSL | `sudo systemctl restart webmin` |
| ❌ lxml.html.clean ImportError | `sudo pip3 install 'lxml[html_clean]' lxml_html_clean` |
| ❌ wkhtmltopdf PDF | `sudo apt install -y wkhtmltopdf` ou version officielle GitHub |
| ❌ "systemerp.local" non résolu (client) | Vérifier `/etc/hosts` ou `C:\Windows\System32\drivers\etc\hosts` |

### 🔐 Sécurité post-installation
- [ ] Changer le mot de passe master Odoo
- [ ] Configurer Let's Encrypt pour HTTPS (`certbot`)
- [ ] Tester la restauration de sauvegarde
- [ ] Surveiller Fail2ban : `sudo fail2ban-client status`

---

## 📁 Structure Sécurisée Odoo
```
/opt/odoo-secure/
├── addons-custom/     # Vos addons (chmod 750)
├── addons-external/   # Addons tiers (chmod 750)
├── config/odoo.conf   # Config sécurisée (chmod 640)
├── filestore/         # Données (chmod 750)
└── logs/              # Logs (chmod 755)
# Propriétaire : odoo:odoo
```

---

> ✅ **Installation terminée** – Votre environnement Odoo est prêt pour la production.  
> 🔄 *Pour changer l'IP ultérieurement* : modifier `/etc/netplan/`, `/etc/hosts`, Nginx, puis redémarrer les services et mettre à jour les clients.

*Document généré pour un déploiement rapide, sécurisé et documenté – v2.0 – Juillet 2025*
