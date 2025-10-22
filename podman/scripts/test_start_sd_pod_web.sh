#!/bin/bash

# Nom du pod et des conteneurs
POD_NAME="sd_pod"
CONTAINER_APP_NAME="sd_app"
CONTAINER_WEB_NAME="sd_web"

# Vérifier si le pod existe déjà
if podman pod exists $POD_NAME; then
    echo "⚠️ Le pod $POD_NAME existe déjà. Redémarrage..."
    podman pod stop $POD_NAME
    podman pod rm $POD_NAME
fi

# Créer le pod avec le port 7860 (port par défaut pour SD)
podman pod create --name $POD_NAME -p 7860:7860

# Démarrer le conteneur principal avec GPU et volume de stockage
podman run -dt --pod $POD_NAME --name $CONTAINER_APP_NAME \
  --security-opt label=disable --gpus all \
  -v /mnt/podman/pod_sd/storage:/app/storage \
  -v /mnt/podman/shared_volumes/models:/app/models \
  docker.io/nvidia/cuda:12.4.0-runtime-ubuntu22.04 sleep infinity

# Démarrer un conteneur web (optionnel, pour une interface)
podman run -dt --pod $POD_NAME --name $CONTAINER_WEB_NAME \
  -v /mnt/podman/pod_sd/web:/app/web \
  docker.io/nginx:latest

# Afficher les logs du conteneur principal
echo "🐱 Pod $POD_NAME démarré avec succès !"
echo "🐱 Conteneurs en cours d'exécution :"
podman ps --pod --format "table {{.Names}}\t{{.Status}}"

# Instructions pour accéder à SD
echo "🐱 Pour accéder à Stable Diffusion, exécute :"
echo "podman exec -it $CONTAINER_APP_NAME /bin/bash"
