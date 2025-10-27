#!/bin/bash

# Définir le fichier de configuration pour ce pod
export CONTAINERS_STORAGE_CONF=~/.config/containers/storage-pod_sd.conf

# Nom du pod et des conteneurs
POD_NAME="pod_sd"
CONTAINER_APP_NAME="app_sd"

# Créer le pod
podman pod create --name $POD_NAME

# Démarrer le conteneur principal avec GPU et volume de stockage
podman run -dt --pod $POD_NAME --name $CONTAINER_APP_NAME \
  --security-opt label=disable --gpus all \
  -v /mnt/podman/pod_sd/storage:/app/storage \
  -v /mnt/podman/shared_volumes/models:/app/models \
  docker.io/nvidia/cuda:12.4.0-runtime-ubuntu22.04 sleep infinity

# Exemple : Exécuter un script en mode batch
podman exec -it $CONTAINER_APP_NAME bash -c "python3 /app/storage/generate_images.py"

echo "🐱 Pod $POD_NAME démarré en mode batch !"
