#!/bin/bash
# Script pour mettre à jour l'IP publique sur Gandi LiveDNS
TOKEN="personal token"
DOMAIN="domain name" # Remplace par ton domaine
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
