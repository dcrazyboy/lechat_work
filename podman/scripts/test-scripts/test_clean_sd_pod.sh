#!/bin/bash

# Nom du pod
POD_NAME="sd_pod"

# Vérifier si le pod existe
if ! podman pod exists $POD_NAME; then
    echo "⚠️ Le pod $POD_NAME n'existe pas."
    exit 1
fi

# Supprimer le pod et ses conteneurs
podman pod rm -f $POD_NAME

# Nettoyer les ressources inutilisées (images, volumes, etc.)
podman system prune -f

# Afficher un message de confirmation
echo "🧹 Pod $POD_NAME supprimé et ressources nettoyées !"
podman pod ps -a --format "table {{.Name}}\t{{.Status}}"