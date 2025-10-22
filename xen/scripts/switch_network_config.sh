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
    ln -sf "\$NF_RULES_DIR/myrules_1fai.nft" "\$NF_RULES_DIR/myrules.nft"
elif [ "\$CONFIG" = "2fai" ]; then
    ln -sf "\$NF_RULES_DIR/myrules_2fai.nft" "\$NF_RULES_DIR/myrules.nft"

    
else
    echo "Configuration invalide. Utilisez '1fai' ou '2fai'."
    exit 1
fi

# Recharger les règles
nft -f "\$NF_RULES_DIR/main.nft"
systemctl restart nftables
