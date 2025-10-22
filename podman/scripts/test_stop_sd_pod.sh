#!/bin/bash

# Nom du pod
POD_NAME="sd_pod"

# Vérifier si le pod existe
if ! podman pod exists $POD_NAME; then
    echo "⚠️ Le pod $POD_NAME n'existe pas."
    exit 1
fi

# Arrêter le pod et ses conteneurs
podman pod stop $POD_NAME

# Afficher un message de confirmation
echo "🐾 Pod $POD_NAME arrêté avec succès !"
podman pod ps --format "table {{.Name}}\t{{.Status}}"