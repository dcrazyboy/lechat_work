#!/bin/bash

# Définir le fichier de configuration pour ce pod
export CONTAINERS_STORAGE_CONF=~/.config/containers/storage-pod_sd.conf
# Nom du pod et du conteneur
POD_NAME="pod_sd"
CONTAINER_NAME="app_sd"
WEB_CONTAINER_NAME="web_sd"
PORT=7860
WORK_DIR="/mnt/podman/shared_volumes/models"
EXTERNAL_STORAGE="/mnt/podman/shared_volumes/images/stable-diffusion"
USER_UID=$(id -u)
USER_GID=$(id -g)

# Créer le lien symbolique vers le stockage externe
if [ ! -d "mnt/podman/pod_sd/storage" ]; then
  mkdir -p /mnt/podman/pod_sd/storage
fi
ln -sf /mnt/podman/pod_sd/storage ~/.local/share/containers/storage

# Vérifier si le port est déjà utilisé
if ss -tulnp | grep -q ":${PORT} "; then
    echo "Erreur: Le port ${PORT} est déjà utilisé."
    exit 1
fi

# Supprimer le pod s'il existe déjà
if podman pod exists $POD_NAME; then
    echo "Le pod $POD_NAME existe déjà. Redémarrage..."
    podman pod stop $POD_NAME
    podman pod rm $POD_NAME
fi

# Créer le répertoire de travail s'il n'existe pas
if [ ! -d "$WORK_DIR" ]; then
    echo "Création du répertoire de travail $WORK_DIR"
    sudo mkdir -p "$WORK_DIR"
    sudo chown -R $USER_UID:$USER_GID "$WORK_DIR"
    sudo chmod -R 755 "$WORK_DIR"
fi

# Créer le répertoire de stockage externe s'il n'existe pas
if [ ! -d "$EXTERNAL_STORAGE" ]; then
    echo "Création du répertoire de stockage externe $EXTERNAL_STORAGE"
    sudo mkdir -p "$EXTERNAL_STORAGE"
    sudo chown -R $USER_UID:$USER_GID "$EXTERNAL_STORAGE"
    sudo chmod -R 755 "$EXTERNAL_STORAGE"
fi

# Créer le pod avec le port défini et l'accès au GPU
echo "Création du pod $POD_NAME avec le port $PORT et l'accès au GPU"
podman pod create --name $POD_NAME -p $PORT:7860 --device=nvidia.com/gpu=all --device=/dev/nvidia-uvm --device=/dev/nvidia-uvm-tools --device=/dev/nvidiactl --userns=keep-id

# Démarrer le conteneur Stable Diffusion en mode web
echo "Lancement du conteneur $CONTAINER_NAME en mode web"
podman run -dt --pod $POD_NAME --name $CONTAINER_NAME \
  -v "$WORK_DIR:/workspace/models:Z" \
  -v "$EXTERNAL_STORAGE:/workspace/images:Z" \
  -u $USER_UID:$USER_GID \
  --group-add=users \
  --workdir /workspace \
  docker.io/ghcr.io/automatic1111/stable-diffusion-webui:latest \
  /bin/bash -c "cd /workspace/stable-diffusion-webui && python3 launch.py --listen --xformers --enable-insecure-extension-access"


# Attendre quelques secondes pour que Stable Diffusion démarre
sleep 30

# Afficher les logs du conteneur web
echo "Logs du conteneur web :"
podman logs $WEB_CONTAINER_NAME

# Afficher l'URL d'accès
echo "Accède à Stable Diffusion via l'URL suivante :"
echo "http://127.0.0.1:${PORT}"
