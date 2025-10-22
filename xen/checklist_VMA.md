📋 Checklist : Installation de VM1 (WireGuard)
1️⃣ Préparation du disque et de la config


 Disque VM1 :

Vérifier que /vm/vm1-wireguard.qcow2 existe et fait 20 Go :
ls -lh /vm/vm1-wireguard.qcow2

Vérifier l’espace disponible sur /vm :
df -h /vm




 Fichier de config Xen :

Vérifier que /etc/xen/vm/vm1_wireguard_ini.cfg est correct (voir plus bas pour les points réseau).




2️⃣ Vérification du réseau (points critiques)
2.1. Bridges Xen


 Lister les bridges existants :
brctl show
→ Doit afficher xenbr0, xenbr1, xenbr2, xenbr3.


 Vérifier les IPs des bridges :
ip addr show xenbr1
→ xenbr1 doit avoir une IP dans 10.0.10.1/24.


 Vérifier que les interfaces physiques sont bien attachées aux bridges :
ip link show enp6s0
ip link show enp9s0
→ Doivent être en mode UP et sans IP (sauf si configuré autrement).


2.2. Règles nftables

 Vérifier que les règles autorisent le trafic entre dom0 et VM1 :
sudo nft list ruleset
→ Chercher des règles du type :
chain forward {
    iifname "xenbr1" oifname "vif*" accept
    iifname "vif*" oifname "xenbr1" accept
}


2.3. MAC et VLANs


 Vérifier que les MACs dans la config Xen sont uniques :

Dans /etc/xen/vm/vm1_wireguard_ini.cfg, les MACs (00:16:3e:11:11:11, etc.) ne doivent pas être utilisées ailleurs.
Vérifier avec :
grep -r "00:16:3e" /etc/xen/




 Si tu utilises des VLANs :

Vérifier que les sous-interfaces (ex: enp9s0.10) existent :
ip -d link show enp9s0





3️⃣ Lancement de l’installation


 Démarrer VM1 en mode installation :
sudo xl create -c /etc/xen/vm/vm1_wireguard_ini.cfg
→ Si ça bloque, vérifier les logs Xen :
sudo xl dmesg
sudo journalctl -u xenconsoled


 Pendant l’installation :

Choisir l’ISO comme source d’installation.
Configurer le réseau manuellement si le DHCP ne fonctionne pas (IP : 10.0.10.10/24, gateway : 10.0.10.1).

post installation initialisation du system



4️⃣ Post-installation


 Configurer WireGuard :

Dans VM1, installer WireGuard :
sudo zypper install wireguard-tools

Générer les clés et configurer /etc/wireguard/wg0.conf.



 Configurer Dnsmasq :

Éditer /etc/dnsmasq.conf :
interface=xenbr1
dhcp-range=10.0.10.100,10.0.10.200,12h

Redémarrer Dnsmasq :
sudo systemctl restart dnsmasq




 Tester la connectivité :

Depuis dom0, pinguer VM1 :
ping 10.0.10.10

Depuis VM1, pinguer dom0 :
ping 10.0.10.1





5️⃣ Diagnostics si problème réseau
5.1. Vérifier les interfaces dans VM1

Dans VM1, lister les interfaces :
ip addr
→ Doit afficher eth0 (ou similaire) avec une IP dans 10.0.10.0/24.

5.2. Vérifier les routes

Dans VM1 :
ip route
→ Doit avoir une route par défaut via 10.0.10.1.

5.3. Vérifier les logs Xen

Dans dom0 :
sudo xl network-list vm1
→ Doit afficher les interfaces virtuelles attachées à VM1.

5.4. Tester la connectivité bas niveau

Depuis dom0, vérifier que la carte virtuelle de VM1 est bien attachée au bridge :
brctl show xenbr1
→ Doit afficher vif<X>.0 (où <X> est l’ID de VM1).


🔍 Points à ajouter pour la création de VM1
D’après ta config et tes retours, voici ce qu’il faudrait absolument vérifier pour éviter les problèmes réseau :


Les bridges Xen :

xenbr1 doit être UP et avoir l’IP 10.0.10.1/24.
Les interfaces physiques (enp6s0, enp9s0) doivent être attachées aux bons bridges (pas d’IP sur les interfaces physiques si elles sont en mode bridge).



Les règles nftables :

Autoriser le trafic forward entre xenbr1 et les interfaces virtuelles (vif*).
Exemple de règle minimale :
table ip xen {
    chain forward {
        iifname "xenbr1" oifname "vif*" accept
        iifname "vif*" oifname "xenbr1" accept
    }
}




Les MACs :

Les MACs dans la config Xen doivent être uniques et ne pas entrer en conflit avec d’autres VMs.



Le DHCP (Dnsmasq) :

Si VM1 ne reçoit pas d’IP, vérifier que Dnsmasq tourne sur dom0 et écoute bien sur xenbr1 :
sudo systemctl status dnsmasq
sudo ss -tulnp | grep dnsmasq





💡 Suggestion
Si le réseau ne passe toujours pas après ces vérifications, on peut :

Désactiver temporairement nftables pour tester :
sudo systemctl stop nftables
→ Si ça marche, le problème vient des règles.
Utiliser tcpdump pour voir le trafic :
sudo tcpdump -i xenbr1



Question : Est-ce que tu veux qu’on affine un point en particulier (ex: les règles nftables, la config des bridges) ? Ou est-ce que tu préfères tester directement avec la checklist ?