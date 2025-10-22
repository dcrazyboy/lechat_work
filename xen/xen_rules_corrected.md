# =============================================
# RÈGLES XEN – openSUSE Tumbleweed (Mode Texte) – VERSION CORRIGÉE
# Projet : xen
# OS : openSUSE Tumbleweed (rolling release)
# Type : Xen strict (dom0 dédié)
# Dernière mise à jour : 24/08/2025
# =============================================

---
## ⚙️ CONTEXTE POUR LE CHAT (À NE PAS MODIFIER)
**Objectif** :
Installer Xen + créer VM1 (WireGuard), VM2 (Web), VM4 (BDD) pour tests.

**Réseau Physique** :
- `enp6s0` : Privé (`192.168.1.36/24`, GW `192.168.1.1`, DNS `89.2.0.1,89.2.0.11`).
- `enp9s0` : Public (`192.168.0.10/24`, GW `192.168.0.1`, DNS `89.2.0.1,89.2.0.2`).

**Routage Dom0**
- Toutes les adresses de type 192.168.1.XXX (xenbr0) sont routées vers 192.168.1.36.
- Le routage par défaut est sur 192.168.0.10.

---
## 📊 BRIDGES XEN ET VLANS DOM0 (CORRIGÉ)
| Bridge   | Carte Physique | VLAN Tag | Plage IP       | Usage                  | IP dom0          |
|----------|----------------|----------|----------------|------------------------|------------------|
| xenbr0   | enp6s0         | -        | 192.168.1.0/24 | Réseau privé dom0      | 192.168.1.36     |
| xenbr1   | enp9s0.10      | 10       | 10.0.10.0/24   | VPN/Management         | **10.0.10.1**    |
| xenbr2   | enp9s0.20      | 20       | 10.0.20.0/24   | Public (Web/OpenSIM)   | **10.0.20.1**    |
| xenbr3   | enp9s0.30      | 30       | 10.0.30.0/24   | Isolé (BDD)            | **10.0.30.1**    |

---
## 📊 PLAN D’ADRESSAGE (CORRIGÉ)
| Bridge   | Plage IP       | IP dom0       | VM1          | VM2          | VM3          | VM4          | VM5          |
|----------|----------------|---------------|--------------|--------------|--------------|--------------|--------------|
| xenbr0   | 192.168.1.0/24 | 192.168.1.36  | 192.168.1.40 | 192.168.1.41 | 192.168.1.42 | 192.168.1.43 | 192.168.1.44 |
| xenbr1   | 10.0.10.0/24   | **10.0.10.1**  | 10.0.10.10   | 10.0.10.20   | 10.0.10.30   | 10.0.10.40   | 10.0.10.50   |
| xenbr2   | 10.0.20.0/24   | **10.0.20.1**  | 10.0.20.10   | 10.0.20.20   | 10.0.20.30   | 10.0.20.40   | 10.0.20.50   |
| xenbr3   | 10.0.30.0/24   | **10.0.30.1**  | 10.0.30.10   | 10.0.30.20   | 10.0.30.30   | 10.0.30.40   | 10.0.30.50   |

**Stockage** :
- `/dev/sda1` : VFAT32 (`/boot/efi`).
- `/dev/sda2` : ext4 (`/`).
- `/dev/DomU/iso` : ISOs d’installation.
- `/dev/DomU/vm` : disques VMs en (qcow2).

**Contraintes** :
- **dom0** : `xl` (pas QEMU), Wicked, AppArmor strict.
- **VM1** : WireGuard + Dnsmasq (DNS interne : `10.0.10.20`).
- **VM2/VM3** : Nginx.
- **VM4/VM5** : PostgreSQL.
- **Scripting** : Bash, Python 3.11+.
- **Mise à jour IP publique** : Script pour Gandi LiveDNS (jeton personnel).

---
## 🛠️ ROUTAGE ET SÉCURITÉ (NFTABLES)

### Installation
```bash
sudo zypper install nftables
sudo systemctl enable --now nftables
```

### Configuration de `/etc/nftables.conf`
```bash
#!/usr/sbin/nft -f

flush ruleset

table inet xen_filter {
    chain input {
        type filter hook input priority 0; policy drop;
        iifname "lo" accept
        meta iifname { "xenbr0", "enp6s0" } tcp dport { 22 } accept
        meta iifname "xenbr1" udp dport 51820 accept
        icmp type echo-request accept
        ct state established,related accept
    }

    chain forward {
        type filter hook forward priority 0; policy drop;
        meta iifname "xenbr0" meta oifname "enp6s0" accept
        meta iifname "enp6s0" meta oifname "xenbr0" accept
        meta iifname "xenbr0" meta oifname "enp9s0" accept
        meta iifname "enp9s0" meta oifname "xenbr0" ct state established,related accept
        meta iifname "xenbr1" meta oifname "enp9s0" udp dport 51820 accept
        meta iifname "enp9s0" meta oifname "xenbr1" udp sport 51820 accept
        meta iifname "xenbr1" meta oifname { "xenbr2", "xenbr3" } tcp dport { 22 } accept
        meta iifname { "xenbr2", "xenbr3" } meta oifname "xenbr1" ct state established,related accept
        meta iifname "enp9s0" meta oifname "xenbr2" tcp dport { 80, 443 } accept
        meta iifname "xenbr2" meta oifname "enp9s0" ct state established,related accept
        meta iifname "xenbr2" meta oifname "enp9s0" tcp dport { 80, 443 } accept
        meta iifname "xenbr2" ip daddr 10.0.30.40 tcp dport 5432 accept
        meta iifname "xenbr3" ip saddr 10.0.30.40 tcp sport 5432 accept
        meta iifname "xenbr2" ip daddr 10.0.30.50 tcp dport 5432 accept
        meta iifname "xenbr3" ip saddr 10.0.30.50 tcp sport 5432 accept
        meta iifname { "xenbr0", "xenbr1", "xenbr2", "xenbr3" } meta oifname "enp9s0" tcp dport { 80, 443 } accept
        meta iifname "enp9s0" meta oifname { "xenbr0", "xenbr1", "xenbr2", "xenbr3" } ct state established,related accept
    }

    chain output {
        type filter hook output priority 0; policy accept;
    }
}
```

### Activation
```bash
sudo nft -f /etc/nftables.conf
sudo systemctl restart nftables
```

### Persistance
```bash
sudo nft list ruleset > /etc/nftables.conf
```

---
## 🖥️ CONFIGURATION DES VMS

### Exemple pour VM1 (WireGuard)
```cfg
builder = "hvm"
name = "VM1"
memory = 4096
vcpus = 2
disk = ['file:/dev/DomU/vm/vm1-disk.qcow2,xvda,w']
vif = [
    'ip=192.168.1.40,bridge=xenbr0',
    'ip=10.0.10.10,bridge=xenbr1',
    'ip=10.0.20.10,bridge=xenbr2',
    'ip=10.0.30.10,bridge=xenbr3'
]
boot = "c"
```

---
## 📝 SCRIPT POUR GANDI LIVEDNS
```bash
#!/bin/bash
NEW_IP=$(curl -s ifconfig.me)
api_key="ton_jeton_gandi"
curl -X PUT "https://dns.api.gandi.net/api/v5/domains/tondomaine.fr/records/A/@"      -H "X-Api-Key: $api_key"      -H "Content-Type: application/json"      -d "{"rrset_values": ["$NEW_IP"]}"
```

---
## ✅ PROCHAINES ÉTAPES
- [x] Valider le fichier de règle (IP/VLAN/routage/nftables)
- [ ] Appliquer les commandes sur le dom0
- [ ] Créer les VMs avec les IP fixes
- [ ] Tester la connectivité (ping, SSH, HTTP, WireGuard, PostgreSQL)
- [ ] Documenter les règles nftables finales
