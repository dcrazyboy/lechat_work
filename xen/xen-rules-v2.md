# =============================================
# RÈGLES XEN – openSUSE Tumbleweed (Mode Texte) – VERSION 2
# Projet : xen
# OS : openSUSE Tumbleweed (rolling release)
# Type : Xen strict (dom0 dédié)
# Dernière mise à jour : 24/08/2025
# =============================================

---
## ⚙️ CONTEXTE (À NE PAS MODIFIER)
**Objectif** :
Installer Xen + créer VM1 (WireGuard), VM2 (Web), VM3/VM4/VM5 pour tests.

**Réseau Physique** :
- `enp6s0` : Privé (`192.168.1.36/24`, GW `192.168.1.1`, DNS `89.2.0.1,89.2.0.11`).
- `enp9s0` : Public (`192.168.0.10/24`, GW `192.168.0.1`, DNS `89.2.0.1,89.2.0.2`).

---
## 📊 PLAN D’ADRESSAGE (Validé le 24/08/2025)

| Bridge   | Plage IP       | IP dom0       | VM1          | VM2          | VM3          | VM4          | VM5          |
|----------|----------------|---------------|--------------|--------------|--------------|--------------|--------------|
| xenbr0   | 192.168.1.0/24 | 192.168.1.36  | 192.168.1.40 | 192.168.1.41 | 192.168.1.42 | 192.168.1.43 | 192.168.1.44 |
| xenbr1   | 10.0.10.0/24   | 10.0.10.10    | 10.0.10.10   | 10.0.10.20   | 10.0.10.30   | 10.0.10.40   | 10.0.10.50   |
| xenbr2   | 10.0.20.0/24   | 10.0.20.10    | 10.0.20.10   | 10.0.20.20   | 10.0.20.30   | 10.0.20.40   | 10.0.20.50   |
| xenbr3   | 10.0.30.0/24   | 10.0.30.10    | 10.0.30.10   | 10.0.30.20   | 10.0.30.30   | 10.0.30.40   | 10.0.30.50   |

---
## 🛠️ ACTIONS SUR LE DOM0

### 1. Activer le routage IP
```bash
sudo sysctl -w net.ipv4.ip_forward=1
```

### 2. Configurer les routes
```bash
# Route par défaut (via enp9s0 : 192.168.0.10)
sudo ip route add default via 192.168.0.10 dev enp9s0

# Route pour xenbr0 (via enp6s0 : 192.168.1.36)
sudo ip route add 192.168.1.0/24 dev xenbr0 src 192.168.1.36
```

### 3. Règles iptables
```bash
# Autoriser le trafic entre xenbr0 et enp6s0
sudo iptables -A FORWARD -i xenbr0 -o enp6s0 -j ACCEPT
sudo iptables -A FORWARD -i enp6s0 -o xenbr0 -j ACCEPT

# Autoriser SSH/HTTP/HTTPS depuis le dom0 vers les VMs (exemple pour VM1)
sudo iptables -A FORWARD -p tcp --dport 22 -d 10.0.10.10 -j ACCEPT
sudo iptables -A FORWARD -p tcp --dport 80 -d 10.0.10.10 -j ACCEPT
sudo iptables -A FORWARD -p tcp --dport 443 -d 10.0.10.10 -j ACCEPT

# Bloquer tout le reste par défaut
sudo iptables -P FORWARD DROP
```

---
## 🖥️ CONFIGURATION DES VMs

### Exemple pour VM1 (fichier `/etc/xen/vm1.cfg`)
```cfg
vif = [
    'ip=192.168.1.40,bridge=xenbr0',
    'ip=10.0.10.10,bridge=xenbr1',
    'ip=10.0.20.10,bridge=xenbr2',
    'ip=10.0.30.10,bridge=xenbr3'
]
```

---
## ✅ PROCHAINES ÉTAPES
- [x] Valider le fichier de règle (IP/VLAN/routage)
- [ ] Appliquer les commandes sur le dom0
- [ ] Créer les VMs avec les IP fixes
- [ ] Tester la connectivité (ping, SSH, HTTP)
- [ ] Documenter les règles iptables finales

---
## 📝 NOTES
- Les VLANs sont gérés via des sous-interfaces (`enp9s0.10`, etc.).
- Pour persister les règles iptables : `iptables-save > /etc/iptables.rules`.
