# =============================================
# RÈGLES XEN – openSUSE Tumbleweed (Mode Texte)
# Projet : xen
# OS : openSUSE Tumbleweed (rolling release)
# Type : Xen strict (dom0 dédié)
# Dernière mise à jour : 24/08/2025
# =============================================

---
## ⚙️ CONTEXTE POUR LE CHAT (À NE PAS MODIFIER)
**Objectif** :
Installer Xen + créer VM1 (WireGuard), VM2 (Web), VM4 (BDD) pour tests.

**Contraintes** :
- **OS** : openSUSE tunbleweed
- **dom0** : `xl` (pas QEMU), Wicked, AppArmor strict, nftables.
- **VM1** : WireGuard + Dnsmasq (DNS interne : `10.0.10.10`).
- **VM2/VM3** : Nginx.
- **VM4/VM5** : PostgreSQL.
- **Scripting** : Bash, Python 3.11+.
- **Mise à jour IP publique** : Script pour Gandi LiveDNS (jeton personnel).
- **Langague scripting** : Bash, Pythn 3.11+ 

**Stockage** :
- `/dev/sda1` : VFAT32 (`/boot/efi`). 
- `/dev/sda2` : ext4 (`/`).
- `/dev/DomU/iso` : ISOs d’installation (`/iso`).
- `/dev/DomU/vm` : disques VMs en (qcow2) (`/vm`).

**Réseau** :
### Description Générale
Ce document décrit la configuration réseau et les règles nftables pour un serveur Xen avec deux configurations possibles : 1 FAI et 2 FAI.
## Interfaces et Réseaux

### Interfaces Physiques
- **enp6s0** : Interface physique connectée au FAI 1 (sans IP, en mode bridge pour `xenbr0`).
- **enp9s0** : Interface physique connectée au FAI 1 ou FAI 2 (selon la configuration).

### Bridges Xen
- **xenbr0** : Bridge interne avec IP `192.168.1.36/24`.
- **xenbr1** : Bridge pour WireGuard avec IP `10.0.10.1/24`.
- **xenbr2** : Bridge pour Nginx avec IP `10.0.20.1/24`.
- **xenbr3** : Bridge pour PostgreSQL avec IP `10.0.30.1/24`.
- **Bridges Xen et VLANs Dom0** (Validé le 24/08/2025) :

| Bridge   | Carte Physique | VLAN Tag | Plage IP       | Usage                  | IP dom0         |
|----------|----------------|----------|----------------|------------------------|-----------------|
| xenbr0   | enp6s0         | -        | 192.168.1.0/24 | Réseau privé dom0      | 192.168.1.36    |
| xenbr1   | enp9s0.10      | 10       | 10.0.10.0/24   | VPN/Management         | 10.0.10.1       |
| xenbr2   | enp9s0.20      | 20       | 10.0.20.0/24   | Public (Web/OpenSIM)   | 10.0.20.1       |
| xenbr3   | enp9s0.30      | 30       | 10.0.30.0/24   | Isolé (BDD)            | 10.0.30.1       |

- **plan d'adressage** (Validé le 24/08/2025)

| Bridge   | Plage IP       | IP dom0       | VM1          | VM2          | VM3          | VM4          | VM5          |
|----------|----------------|---------------|--------------|--------------|--------------|--------------|--------------|
| xenbr0   | 192.168.1.0/24 | 192.168.1.36  | 192.168.1.40 | 192.168.1.41 | 192.168.1.42 | 192.168.1.43 | 192.168.1.44 |
| xenbr1   | 10.0.10.0/24   | 10.0.10.1     | 10.0.10.10   | 10.0.10.20   | 10.0.10.30   | 10.0.10.40   | 10.0.10.50   |
| xenbr2   | 10.0.20.0/24   | 10.0.20.1     | 10.0.20.10   | 10.0.20.20   | 10.0.20.30   | 10.0.20.40   | 10.0.20.50   |
| xenbr3   | 10.0.30.0/24   | 10.0.30.1     | 10.0.30.10   | 10.0.30.20   | 10.0.30.30   | 10.0.30.40   | 10.0.30.50   |


## 🔧 CONFIGURATION RÉSEAU

### Configuration generale
- **Fichier principal** : `/etc/nftables/rules/main.nft` (Validé le 07/09/2025)
```ini

#!/usr/sbin/nft -f

# Inclure les règles spécifiques à la configuration active
include "/etc/nftables/rules/rules.d/myrules.nft" # Lien vers la configuration active
```

### script de bascule  : /usr/local/bin/switch_network_config.sh
```bash
#!/bin/bash
# Script pour basculer entre les configurations 1 FAI et 2 FAI
# Exemple d'utilisation :
#   ./switch_network_config.sh 1fai  # Active la Configuration 1 FAI
#   ./switch_network_config.sh 2fai  # Active la Configuration 2 FAI

CONFIG=\$1
NF_RULES_DIR="/etc/nftables/rules/rules.d"

# Désactiver les règles actuelles
nft flush ruleset

# Charger les règles de la configuration demandée
if [ "\$CONFIG" = "1fai" ]; then
    ln -sf "\$NF_RULES_DIR/myrules.1fai" "\$NF_RULES_DIR/myrules.nft"
elif [ "\$CONFIG" = "2fai" ]; then
    ln -sf "\$NF_RULES_DIR/myrules.2fai" "\$NF_RULES_DIR/myrules.nft"
else
    echo "Configuration invalide. Utilisez '1fai' ou '2fai'."
    exit 1
fi

# Recharger les règles
nft -f "\$NF_RULES_DIR/main.nft"
systemctl restart nftables
```
### 🔧 Configuration 1 FAI
#### règles de base
- **enp9s0** : IP `192.168.1.100/24`.
- **Route par défaut** : `192.168.1.1` via `enp9s0`.
- **NAT** : Actif pour masquer le trafic sortant via `enp9s0`.

#### Règles nftables

- **Fichier** : `/etc/nftables/rules/rules.d/myrules.1fai` (Validé le 07/09/2025)
```ini
# Règles pour 1 FAI
flush ruleset
 
table inet xen_filter {
    chain input {
        type filter hook input priority filter; 
        policy drop;
        # Autoriser le trafic loopback
        iifname "lo" accept
        # Autoriser SSH/SCP pour toutes les VMs sur xenbr0 + dom0 (zone interne)
        iifname { "xenbr0", "enp6s0" } tcp dport 22 accept
        # Autoriser WireGuard (UDP 51820) pour VM1 (xenbr1)
        iifname "xenbr1" udp dport 51820 accept
        # Autoriser le trafic UDP sur le port 53
        udp dport 53 accept
        # Autoriser ICMP (ping)
        icmp type echo-request accept
        # Autoriser le trafic établi/relatif
        ct state established,related accept
    }

    chain forward {
        type filter hook forward priority 0; 
        policy drop;
        # --- ZONE INTERNE (xenbr0/enp6s0) ---
        # Autoriser tout le trafic entre xenbr0 et enp6s0 (LAN privé)
        iifname "xenbr0" oifname "enp9s0" accept
        iifname "enp9s0" oifname "xenbr0" ct state established,related accept
        # --- ZONE MANAGEMENT (xenbr1) ---
        # Autoriser WireGuard (UDP 51820) entre VM1 et l'extérieur (via enp9s0)
        iifname "xenbr1" oifname "enp9s0" udp dport 51820 accept
        iifname "enp9s0" oifname "xenbr1" udp sport 51820 accept
        # Autoriser l'accès Internet pour les VMs sur xenbr0 (via enp9s0)
        # Autoriser SSH/SCP depuis xenbr1 vers xenbr2 et xenbr3
        iifname "xenbr1" oifname { "xenbr2", "xenbr3" } tcp dport 22 accept
        iifname { "xenbr2", "xenbr3" } oifname "xenbr1" ct state established,related accept
        # --- ZONE PUBLIC (xenbr2) ---
        # Autoriser HTTP/HTTPS depuis l'extérieur (enp9s0) vers xenbr2
        iifname "enp9s0" oifname "xenbr2" tcp dport { 80, 443 } accept
        iifname "xenbr2" oifname "enp9s0" ct state established,related accept
        # Autoriser l'accès Internet pour xenbr2 (HTTP/HTTPS)
        iifname "xenbr2" oifname "enp9s0" tcp dport { 80, 443 } accept
        # --- ZONE ISOLÉE (xenbr3) ---
        # Autoriser PostgreSQL entre VM2 ↔ VM4 et VM3 ↔ VM5 sur xenbr3
        iifname "xenbr2" ip daddr 10.0.30.40 tcp dport 5432 accept
        iifname "xenbr3" ip saddr 10.0.30.40 tcp sport 5432 accept
        iifname "xenbr2" ip daddr 10.0.30.50 tcp dport 5432 accept
        iifname "xenbr3" ip saddr 10.0.30.50 tcp sport 5432 accept
        # --- ACCÈS INTERNET POUR LES VMs (HTTP/HTTPS/MAJ) ---
        # Autoriser les mises à jour (HTTP/HTTPS) pour toutes les VMs
        iifname { "xenbr0", "xenbr1", "xenbr2", "xenbr3" } oifname "enp9s0" tcp dport { 80, 443 } accept
        iifname "enp9s0" oifname { "xenbr0", "xenbr1", "xenbr2", "xenbr3" } ct state established,related accept
    }

    # Chaîne pour le trafic sortant
    chain output {
        type filter hook output priority 0; 
        policy accept;
        udp dport 53 accept
    }
}

table ip xen_nat {
    chain postrouting {
        type nat hook postrouting priority 100;
        oifname "enp9s0" masquerade
    }
}
```

### 🔧 Configuration 2 FAI
#### règles de base
- **enp9s0** : IP `192.168.0.10/24`.
- **Route par défaut** : `192.168.0.1` via `enp9s0`.
- **NAT** : Désactivé (chaque FAI a sa propre IP publique).

#### Règles nftables

- **Fichier** : `/etc/nftables/rules/rules.d/myrules.2fai` (Validé le 07/09/2025)
```ini
# Règles pour 2 FAI

flush ruleset

table inet xen_filter {
    chain input {
        type filter hook input priority filter; 
        policy drop;
        # Autoriser le trafic loopback
        iifname "lo" accept
        # Autoriser SSH/SCP pour toutes les VMs sur xenbr0 + dom0 (zone interne)
        iifname { "xenbr0", "enp6s0" } tcp dport 22 accept
        # Autoriser WireGuard (UDP 51820) pour VM1 (xenbr1)
        iifname "xenbr1" udp dport 51820 accept
        # Autoriser le trafic UDP sur le port 53
        udp dport 53 accept
        # Autoriser ICMP (ping)
        icmp type echo-request accept
        # Autoriser le trafic établi/relatif
        ct state established,related accept
    }

    chain forward {
        type filter hook forward priority 0; policy drop;
        # --- ZONE INTERNE (xenbr0/enp6s0) ---
        # Autoriser tout le trafic entre xenbr0 et enp6s0 (LAN privé)
        iifname "xenbr0" oifname "enp6s0" accept
        iifname "enp6s0" oifname "xenbr0" accept
        # --- ZONE MANAGEMENT (xenbr1) ---
        # Autoriser WireGuard (UDP 51820) entre VM1 et l'extérieur (via enp9s0)
        iifname "xenbr1" oifname "enp9s0" udp dport 51820 accept
        iifname "enp9s0" oifname "xenbr1" udp sport 51820 accept
        # Autoriser SSH/SCP depuis xenbr1 vers xenbr2 et xenbr3
        iifname "xenbr1" oifname { "xenbr2", "xenbr3" } tcp dport 22 accept
        iifname { "xenbr2", "xenbr3" } oifname "xenbr1" ct state established,related accept
        # --- ZONE PUBLIC (xenbr2) ---
        # Autoriser HTTP/HTTPS depuis l'extérieur (enp9s0) vers xenbr2
        iifname "enp9s0" oifname "xenbr2" tcp dport { 80, 443 } accept
        # Autoriser l'accès Internet pour xenbr2 (HTTP/HTTPS)
        iifname "xenbr2" oifname "enp9s0" ct state established,related accept
        iifname "xenbr2" oifname "enp9s0" tcp dport { 80, 443 } accept
        # --- ZONE ISOLÉE (xenbr3) ---
        # Autoriser PostgreSQL entre VM2 ↔ VM4 et VM3 ↔ VM5 sur xenbr3
        iifname "xenbr2" ip daddr 10.0.30.40 tcp dport 5432 accept
        iifname "xenbr3" ip saddr 10.0.30.40 tcp sport 5432 accept
        iifname "xenbr2" ip daddr 10.0.30.50 tcp dport 5432 accept
        iifname "xenbr3" ip saddr 10.0.30.50 tcp sport 5432 accept
        # --- ACCÈS INTERNET POUR LES VMs (HTTP/HTTPS/MAJ) ---
        # Autoriser les mises à jour (HTTP/HTTPS) pour toutes les VMs
        iifname { "xenbr0", "xenbr1", "xenbr2", "xenbr3" } oifname "enp9s0" tcp dport { 80, 443 } accept
        iifname "enp9s0" oifname { "xenbr0", "xenbr1", "xenbr2", "xenbr3" } ct state established,related accept
    }

    # Chaîne pour le trafic sortant
    chain output {
        type filter hook output priority 0; 
        policy accept;
        udp dport 53 accept
    }
}

# Pas de NAT pour 2 FAI
```
---
## 📝 AIDE-MÉMOIRE (À REMPLIR)

### 1. Commandes Xen de Base
| Action               | Commande                          | Notes                      |
|-----------------------|-----------------------------------|---------------------------|
| Lister les VMs        | `sudo xl list`                    |                           |
| Démarrer une VM       | `sudo xl create /etc/xen/<vm>.cfg`|                           |
| Console VM            | `sudo xl console <nom-vm>`        | `Ctrl+]` pour quitter.    |
| Arrêter une VM        | `sudo xl shutdown <nom-vm>`       |                           |
| Vérifier les logs     | `sudo xl dmesg`                   |                           |

## 🛠️ ROUTAGE ET SÉCURITÉ (NFTABLES)

### 1. Routage et securité
 - enp9s0 (192.168.0.10/24) : Zone externe
   - xenbr1 sur enp9s0  (10.0.10.0/24) : Management (VPN, interne).
   - xenbr2 sur enp9s0  (10.0.20.0/24) : Public (Web/OpenSIM, exposé).  
   - xenbr3  sur enp9s0 (10.0.30.0/24) : Isolé (BDD, sécurisé).
 - enp6s0 (192.168.1.36/24) : Zone interne  
   - xenbr0 sur enp6s0  (192.168.1.0/24) : Interne (réseau privé dom0).
 - Règles
   - Toutes les VM xenbr0 + Dom0 sont accessibles par SSH, SCP et peuvent acceder au net pour leur mise a jour
   - Toutes les VM xenbr2 sont acessible depuis xenbr1 par SSH, SCP 
   - Toutes les VM xenbr3 sont acessible depuis xenbr1 par SSH, SCP
   - Toutes les machines sur xenbr2 sont acceissble depuis l'extérieur
   - La VM2 (xenbr2) accede a postgres sur la VM4 port : 5432 par Xenbr3
   - La VM3 (xenbr2) accede a postgres sur la VM5 port : 5432 par xenbr3

### 2. Installation
```bash
sudo zypper install nftables
sudo systemctl enable --now nftables

```

### 3. Installations supplemantires routage et securite
#### 3.1 Préparer les bridges et VLAN
**Créer les VLANs et Bridges** *(à exécuter sur dom0)*
```bash
# Charger le module VLAN
sudo modprobe 8021q

# Créer les sous-interfaces VLAN
ip link add link enp9s0 name enp9s0.10 type vlan id 10
ip link add link enp9s0 name enp9s0.20 type vlan id 20
ip link add link enp9s0 name enp9s0.30 type vlan id 30

# Créer les bridges
brctl addbr xenbr0
brctl addbr xenbr1
brctl addbr xenbr2
brctl addbr xenbr3

# Associer les VLANs aux bridges
brctl addif xenbr1 enp9s0.10
brctl addif xenbr2 enp9s0.20
brctl addif xenbr3 enp9s0.30

# Configurer les IP des bridges
ip addr add 192.168.1.36/24 dev xenbr0
ip addr add 10.0.10.1/24 dev xenbr1
ip addr add 10.0.20.1/24 dev xenbr2
ip addr add 10.0.30.1/24 dev xenbr3

# Activer les interfaces
ip link set enp9s0.10 up
ip link set enp9s0.20 up
ip link set enp9s0.30 up
ip link set xenbr0 up
ip link set xenbr1 up
ip link set xenbr2 up
ip link set xenbr3 up
```

### 3.2 Configurer le routage

#### Active la redirection ipv4
```bash
# Activer le routage IP
sysctl -w net.ipv4.ip_forward=1

# Ajouter les routes
# si 1 fai
ip route add default via 192.168.1.1 dev enp9s0
# si 2 fai
ip route add default via 192.168.0.10 dev enp9s0
ip route add 192.168.1.0/24 dev xenbr0 src 192.168.1.36
```
#### Règles nftables
```bash
cd /etc/nftables/rules/
mkdir rules.d
```
copier els source
 cp $source/xen/config/main.nft /etc/nftables/rules/main.nft
 cp $source/xen/config/myrules.1fai /etc/nftables/rules/rules.d/myrules.1fai
 cp $source/xen/config/myrules.2fai /etc/nftables/rules/rules.d/myrules.2fai
 cp $source/xen/config/switch_network_config.sh /usr/local/bin/bswitch_network_config.sh


#### Appliquer les règles nftables

```Bash
cd  /usr/local/bin/
chmod +x bswitch_network_config.sh
switch_network_config.sh [1|2]fai
```

#### Redemarrer wicked
```Bash
sudo systemctl restart wicked
```
## 🛠️ installer XEN

### 1. installer les dependance necessaire

```bash
 zypper install -t pattern devel_basis
 ```

 ### 2. Installer les paquet Xen et les outils
 ```bash
zypper install xen xen-tools xen-libs xen-doc
zypper install kernel-xen
 ```
ou passer par yast2
virtualisation > Install Hypervisor and tools
puis
System > Boot Loader
dans Bootloader Option changer pour :  openSUSE Tumbleweed, with Xen hypervisor▒
activer les services
```bash
systemctl enable xenstored
systemctl enable xenconsoled
systemctl enable xendomains
systemctl start xenstored
systemctl start xenconsoled
```
puis rebooter la machine

 ### 3. Validation de l'installation
```bash
# sous root
xl info 
```
Résultat attendu
```text
xl info
host                   : xensrv
release                : 6.16.0-1-default
version                : #1 SMP PREEMPT_DYNAMIC Thu Aug  7 07:54:52 UTC 2025 (49fcd7f)
machine                : x86_64
nr_cpus                : 24
max_cpu_id             : 31
nr_nodes               : 1
cores_per_socket       : 12
threads_per_core       : 2
cpu_mhz                : 3693.066
hw_caps                : 178bf3ff:76f8320b:2e500800:644037ff:0000000f:219c97a9:0040068c:00000780
virt_caps              : pv hvm hvm_directio pv_directio hap shadow gnttab-v1 gnttab-v2
total_memory           : 32677
free_memory            : 28057
sharing_freed_memory   : 0
sharing_used_memory    : 0
outstanding_claims     : 0
free_cpus              : 0
xen_major              : 4
xen_minor              : 20
xen_extra              : .1_02-1
xen_version            : 4.20.1_02-1
xen_caps               : xen-3.0-x86_64 hvm-3.0-x86_32 hvm-3.0-x86_32p hvm-3.0-x86_64 
xen_scheduler          : credit2
xen_pagesize           : 4096
platform_params        : virt_start=0xffff800000000000
xen_changeset          : 
xen_commandline        : 
cc_compiler            : gcc (SUSE Linux) 15.1.1 20250626
cc_compile_by          : abuild
cc_compile_domain      : [unknown]
cc_compile_date        : 
build_id               : 9855e7ed6fe75b36cf1881978ef16572
xend_config_format     : 4
```

```bash
# sous root
ip link show 
```
résultat attendu
```text
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: enp6s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master xenbr0 state UP mode DEFAULT group default qlen 1000
    link/ether 10:27:f5:c7:79:3c brd ff:ff:ff:ff:ff:ff
    altname enx1027f5c7793c
3: enp9s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
    link/ether 3c:7c:3f:d7:66:c4 brd ff:ff:ff:ff:ff:ff
    altname enx3c7c3fd766c4
4: xenbr0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether f2:8b:4e:f5:2e:10 brd ff:ff:ff:ff:ff:ff
5: xenbr2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether fe:b2:99:dc:ed:74 brd ff:ff:ff:ff:ff:ff
6: xenbr1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether 52:75:52:a3:1b:00 brd ff:ff:ff:ff:ff:ff
7: xenbr3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether a6:cb:7e:a0:75:64 brd ff:ff:ff:ff:ff:ff
8: enp9s0.20@enp9s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master xenbr2 state UP mode DEFAULT group default qlen 1000
    link/ether 3c:7c:3f:d7:66:c4 brd ff:ff:ff:ff:ff:ff
9: enp9s0.10@enp9s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master xenbr1 state UP mode DEFAULT group default qlen 1000
    link/ether 3c:7c:3f:d7:66:c4 brd ff:ff:ff:ff:ff:ff
10: enp9s0.30@enp9s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master xenbr3 state UP mode DEFAULT group default qlen 1000
    link/ether 3c:7c:3f:d7:66:c4 brd ff:ff:ff:ff:ff:ff

```
```bash
ls -ld /vm /iso
```
resultat attendu
```text
ls -ld /vm /iso
drwxr-xr-x 2 root root 48 Sep  7 04:44 /iso
drwxr-xr-x 2 root root 33 Sep  7 05:55 /vm
```
le chmod est bien a 755

```bash
lsmod | grep xen
```
resultat attendu
```text
xen_gntdev             45056  2
xen_gntalloc           20480  0
xen_evtchn             16384  2
xen_netback            86016  0
xen_blkback            61440  0
xen_pciback           106496  0
xen_acpi_processor     20480  0
xenfs                  16384  1
xen_privcmd            36864  24 xenfs

```

## 🛠️ Creation des VM
### Généralite
#### TYPE DE VM : 

##### HVM (Hardware Virtual Machine) (utilisée ici)
- **Définition** : Les VMs HVM permettent une virtualisation complète (comme un PC physique), avec accès direct au matériel via VT-x/AMD-V.
- **Avantages** :
  - Meilleure performance pour les OS non modifiés (Windows, Linux standard).
  - Support des pilotes matériels virtuels (ex: GPU, USB).
- **Inconvénients** :
  - Légère surcharge par rapport aux VMs PV (Paravirtualisées).
  - Nécessite un CPU compatible (VT-x/AMD-V activé dans le BIOS).

##### Bonnes pratiques pour les VMs HVM
1. **Activer VT-x/AMD-V** dans le BIOS du serveur.
2. **Utiliser des disques en format qcow2** pour les snapshots.
3. **Choisir le bon modèle de carte réseau** :
   - `model=e1000` : Compatible avec la plupart des OS.
   - `model=virtio` : Meilleure performance (si l’OS invité supporte virtio).
4. **Allouer suffisamment de mémoire** (minimum 2 Go pour un OS moderne).
5. **Désactiver les périphériques inutiles** (ex: `usb=0` si non nécessaire).
6. **Sauvegarder les configurations** avant de démarrer les VMs.

##### Créer un disque qcow2 pour une VM
```bash
qemu-img create -f qcow2 /dev/DomU/vm/<nom vm>.qcow2 <taille vm>G # min taille 20G
```
##### Démarrer toutes les VM
```bash
for vm in vm1 vm2 vm4; do
    sudo xl create /etc/xen/\${vm}.cfg
done
```
##### Récupération d'iso
pour openSuse Tumbleweed
```bash
wget https://download.opensuse.org/tumbleweed/iso/openSUSE-Tumbleweed-DVD-x86_64-Current.iso -O /dev/DomU/iso/openSUSE-Tumbleweed-DVD-x86_64.iso
```
##### Dépannage

|-----------------------|----------------------------------------|----------------------|
|     Problème          |              Solution                  |      Commande        |
|-----------------------|----------------------------------------|----------------------|
|Bridge non créé        |sudo wicked ifup xenbr1                 |brctl show            |
|VM sans réseau         |Vérifier ip a dans la VM                |xl network-list <vm>  |
|AppArmor bloque une VM |sudo aa-complain /etc/apparmor.d/xen.vm1|`dmesg                |
|VLAN non détecté       |ip -d link show enp9s0                  |modprobe 8021q        |


#### Commandes utiles

| Action               | Commande                                   | Notes                     |
|-----------------------|-------------------------------------------|---------------------------|
| recharge conf nftables| `nft -f /etc/nftables.conf`               |                           |
| recharge nftables     | `systemctl restart nftables`              |                           |
| Lister le journal     | `journalctl -u nftables --no-pager -n 50` |                           |
| Démarrer une VM       | `sudo xl create /etc/xen/<vm>.cfg`        |                           |
| Console VM            | `sudo xl console <nom-vm>`                | `Ctrl+]` pour quitter.    |
| Arrêter une VM        | `sudo xl shutdown <nom-vm>`               |                           |
| Vérifier les logs     | `sudo xl dmesg`                           |                           |

## 🛠️ Creation des VM1 (wireguard)

### Mise à jour IP publique (Gandi LiveDNS) par Dom0
#### EXEMPLE
**Fichier `/usr/local/bin/update_live_ip.sh`** :
```bash
#!/bin/bash
# Script pour mettre à jour l'IP publique sur Gandi LiveDNS
TOKEN="id du jeton"
DOMAIN="nom du domaine" # Remplace par ton domaine
LOG_FILE="/var/log/update_ip.log"

# Récupérer l'IP publique
IP_PUB=$(curl -s ifconfig.me)
echo "$(date) - IP publique détectée : $IP_PUB" >> "$LOG_FILE"

# Mettre à jour l'IP sur Gandi LiveDNS avec le jeton
RESPONSE=$(curl -s -X PUT \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"rrset_values\": [\"$IP_PUB\"]}" \
  "https://api.gandi.net/v5/livedns/domains/$DOMAIN/records/@/A")

# Vérifier la réponse de l'API
if echo "$RESPONSE" | grep -q "message"; then
  echo "$(date) - Erreur : $RESPONSE" >> "$LOG_FILE"
else
  echo "$(date) - Mise à jour réussie : $RESPONSE" >> "$LOG_FILE"
fi

```
#### Installation
la version active se trouve dans $SOURCE/xen/config/update_live_ip.sh
à mettre dans /usr/local/bin sur Dom0

```Bash
chmod +x /root/live_ip.sh
crontab -e << 
# ajouter
*/30 * * * * /usr/local/bin/update_live_ip.sh
```

### Création du disque
```bash
qemu-img create -f qcow2 /vm/vm1-wireguard.qcow2 20G
```
### 5. AppArmor 
#### Profil pour VM1
Récuperer le profil pour la VM1 dans $SOURCE/xen/config/xen.vm1 et le mettre dans /etc/apparmo.d/xen.vm1

Activer le profil 
```Bash
sudo aa-complain /etc/apparmor.d/xen.vm1
sudo systemctl reload apparmor
```

## 🛠️ Creation des VM (Dom0)
### VM1 : vm1-wireguard
#### Génér&lité 

Cette VM, a deux objectifs :
 1) Donnée un point d'entré externe au système pour son management en utilisant Wireguard
 2) Gérer un DNS local par dnsmasq

- **Nom** : vm1-wireguard
- **Type** : HVM
- **OS** : OpenSuse tuùmbleweed
- **Applicatifs** : wicked, apparmor, wireguard, dnsmasq
- **Size** : 20G
- **Memoire** : 4G 
- **Scripting** : Bash
- **Acces** : externe / interne
- **Réseau** : xenbr0,xenbr1, xenbr2, xenbr3
- **source** : /iso
- **implantation** : /vm
- **vcpu** : 2

#### 🛠️ Création du disque
```bash
sudo qemu-img create -f qcow2 -o preallocation=full /vm/vm1-wireguard.qcow2 20G
```

#### 🛠️ initialisation de la VM ($source/xen/config/vm1_wireguard.cfg_ini)

**Fichier `/etc/xen/vm1-wireguard.cfg_ini`** :
```ini
# VM1 (WireGuard) - Installation via ISO
builder = "hvm"
name = "VM1"
memory = 4096  # 4 Go de RAM (ajustable)
vcpus = 2      # 2 CPU (ajustable)
pae = 1
acpi = 1
apic = 1

# Disque virtuel (qcow2, 20 Go)
disk = [
    'file:/dev/DomU/vm/vm1-wireguard.qcow2,xvda,w',
    'file:/dev/DomU/iso/oopenSUSE-Tumbleweed-DVD-x86_64.iso,xvdb:cdrom,r'
]

# Réseau (IP fixes sur chaque bridge)
vif = [
    'bridge=xenbr0,mac=00:16:3e:11:11:11',
    'bridge=xenbr1,mac=00:16:3e:11:11:12',
    'bridge=xenbr2,mac=00:16:3e:11:11:13',
    'bridge=xenbr3,mac=00:16:3e:11:11:14'
]

# Périphériques virtuels pour l'installation graphique
serial = "pty"
#vnc = 1
#vnclisten = "0.0.0.0"
#vncpasswd = 'ton_mot_de_passe'  # Remplace par un mot de passe sécurisé
stdvga = 1
sdl = 0

# Démarrage depuis l'ISO
boot = "dc"
on_poweroff = "destroy"
on_reboot = "restart"
on_crash = "restart"
```

#### 2.2 Démarrer VM1 :
```Bash 
sudo 

```
#### 2.3 Se connecter à l’interface graphique (VNC) :
Utilise un client VNC (comme vinagre, tigervnc, ou RealVNC) pour te connecter à l’adresse IP de ton dom0, sur le port 5900 (par défaut pour la première VM).
```Bash
vncviewer dom0-ip:5900
```
et installer
#### 3. Fichier de configuration pour VM1 après installation
Après installation
(À enregistrer sous /etc/xen/vm1-prod.cfg, sans l’ISO)
**Fichier `/etc/xen/vm1_prod.cfg`** :
```ini
# VM1 (WireGuard) - Configuration post-installation
builder = "hvm"
name = "VM1"
memory = 4096
vcpus = 2
pae = 1
acpi = 1
apic = 1

# Disque virtuel (post-installation)
disk = ['file:/dev/DomU/vm/vm1-disk.qcow2,xvda,w']

# Réseau
vif = [
    'ip=192.168.1.40,bridge=xenbr0,model=e1000',
    'ip=10.0.10.10,bridge=xenbr1,model=e1000',
    'ip=10.0.20.10,bridge=xenbr2,model=e1000',
    'ip=10.0.30.10,bridge=xenbr3,model=e1000'
]

# Périphériques virtuels (post-installation)
serial = "pty"
#vnc = 1
#vnclisten = "0.0.0.0"
#vncpasswd = 'ton_mot_de_passe'
stdvga = 0

# Démarrage depuis le disque
boot = "c"
on_poweroff = "destroy"
on_reboot = "restart"
on_crash = "restart"
```
#### 4 Script pour une utilisation courante après l’installation
À enregistrer sous /usr/local/bin/start-vm1.sh et rendre exécutable avec chmod +x /usr/local/bin/start-vm1.sh
**Fichier `/usr/local/bin/start-vm1.sh`** :
```ini
#!/bin/bash

# Démarrer VM1 (sans ISO, en mode normal)
sudo xl create -c /etc/xen/vm1-prod.cfg

# Attendre 10 secondes pour que le réseau soit prêt
sleep 10

# Afficher les infos de connexion
echo "VM1 (WireGuard) est démarrée !"
echo "Adresses IP :"
echo "- xenbr0 : 192.168.1.40"
echo "- xenbr1 : 10.0.10.10"
echo "- xenbr2 : 10.0.20.10"
echo "- xenbr3 : 10.0.30.10"
echo ""
echo "Pour te connecter en SSH :"
echo "ssh root@192.168.1.40"
```
# Récupere les config de VM pour installation
cp $source/xen/config/vm1.cfg_ini /etc//etc/xen/vm1.cfg_ini
cp $source/xen/config/vm2.cfg_ini /etc//etc/xen/vm2.cfg_ini
cp $source/xen/config/vm2.cfg_ini /etc//etc/xen/vm3.cfg_ini
cp $source/xen/config/vm2.cfg_ini /etc//etc/xen/vm4.cfg_ini

# Récupere les config de VM après installation
cp $source/xen/config/vm1_prod.cfg /etc//etc/xen/vm1_prod.cfg
cp $source/xen/config/vm2_prod.cfg /etc//etc/xen/vm2_prod.cfg
cp $source/xen/config/vm2_prod.cfg /etc//etc/xen/vm3_prod.cfg
cp $source/xen/config/vm2_prod.cfg /etc//etc/xen/vm4_prod.cfg

## ⚠️ PIÈGES CONNUS
### 1. VLANs sur enp9s0 :

Toujours créer les VLANs avant les bridges.
Vérifier avec ip -d link show enp9s0.

### 2. AppArmor :

Tester en mode complain avant d’appliquer :
```Bash
sudo aa-complain /etc/apparmor.d/xen.vm1
```

### 3. Stockage LVM :

#### Vérifier que /dev/DomU/vm existe :
```Bash
sudo lvdisplay
sudo mkfs.xfs /dev/DomU/vm  # Si non formaté
```

### 4. IP Publique Flottante :

Si attribuée à une VM (ex: VM2), configurer dans sa VM :
```Bsah
vif = ['bridge=xenbr2,ip=10.0.20.30', 'bridge=xenbr0,ip=192.168.0.100']  # IP publique
```

## 5. WireGuard sur VM1 :

Installer WireGuard dans VM1 :
```Bsah
sudo zypper install wireguard-tools
```

Configurer dnsmasq pour le DNS interne :
```Bsah
# /etc/dnsmasq.conf
interface=xenbr1
dhcp-range=10.0.10.100,10.0.10.200,12h
```
## 6. nftables sur Dom0 :
Sur suse nftable attend le fichier de conf des rule dans : /etc/nftables/rules 
---
## **🔹 Prochaines Étapes**
1# ✅ PROCHAINES ÉTAPES
- [x] Valider le fichier de règle (IP/VLAN/routage) Validé le 23/08/2025
- [x] Ré-installationfrom scratch du serveur minimal Validé le 24/08/2025
- [x] Appliquer les commandes sur le dom0 Validé le 24/08/2025
- [x] Tester la connectivité (ping, SSH, HTTP) Validé le 07/09/2025
- [x] Documenter les règles iptables finales Validé le 07/09/2025
- [x] Installer XEN Validé le 07/09/2025
- [ ] Créer VM1 (wireguard)
- [ ] Créer VM2 (Serveur web)
- [ ] Créer VM3 (BDD Serveur Web)
- [ ] Créer VM4 (Opensimulator)
- [ ] Créer VM5 (BDD opensimulator)

---
## 📝 NOTES
- Les VLANs sont gérés via des sous-interfaces (`enp9s0.10`, etc.).
- Pour persister les règles iptables : `iptables-save > /etc/iptables.rules`.
