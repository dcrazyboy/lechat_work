#!/bin/bash
# Définir le fichier de configuration pour ce pod
export CONTAINERS_STORAGE_CONF=~/.config/containers/storage-jupyter_lab.conf
# Nom du pod et du conteneur
POD_NAME="pod_jupyter_lab"
CONTAINER_NAME="app_jupyter_lab"
PORT=8888
WORK_DIR="/mnt/podman/shared_volumes/jupyter_lab"
USER_UID=$(id -u)
USER_GID=$(id -g)

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
    sudo chmod -R 775 "$WORK_DIR"
fi

# Créer le pod avec le port défini
echo "Création du pod $POD_NAME avec le port $PORT"
podman pod create --name $POD_NAME -p $PORT:8888 --userns=keep-id

# Démarrer le conteneur Jupyter Lab avec les UID et GID de l'utilisateur et ajouter le groupe users
echo "Lancement du conteneur $CONTAINER_NAME"
podman run -dt --pod $POD_NAME --name $CONTAINER_NAME \
  -v "$WORK_DIR:/home/jovyan/work" \
  -u $USER_UID:$USER_GID \
  --group-add=users \
  docker.io/jupyter/base-notebook:latest

sleep 10

# Afficher les logs du conteneur pour obtenir l'URL d'accès
#echo "Logs du conteneur :"
#podman logs $CONTAINER_NAME

# Afficher l'URL d'accès
TOKEN=$(podman logs $CONTAINER_NAME 2>&1 | grep -oP 'http://127.0.0.1:8888/lab\?token=\K[^ ]+')

if [ -n "$TOKEN" ]; then
    echo "Accède à Jupyter Lab via l'URL suivante :"
    echo "http://127.0.0.1:${PORT}/lab?token=${TOKEN}"
else
    echo "Impossible de récupérer le token d'accès. Vérifie les logs du conteneur."
fi
