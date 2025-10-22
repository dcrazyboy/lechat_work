#!/bin/bash

# Nom du pod et du conteneur
POD_NAME="pod_jupyter_lab"
CONTAINER_NAME="app_jupyter_lab"

# Vérifier si le pod existe
if ! podman pod exists $POD_NAME; then
    echo "⚠️ Le pod $POD_NAME n'existe pas."
    exit 1
fi

# Afficher les informations du pod avant l'arrêt
echo "Statut actuel du pod $POD_NAME :"
podman pod ps --format "table {{.Name}}\t{{.Status}}"

# Arrêter le conteneur principal proprement
echo "Arrêt du conteneur $CONTAINER_NAME..."
podman stop $CONTAINER_NAME

# Attendre que le conteneur ait bien le temps de s'arrêter
sleep 5

# Vérifier l'état du conteneur après l'arrêt
CONTAINER_STATE=$(podman inspect $CONTAINER_NAME --format '{{.State.Status}}')
echo "État du conteneur après arrêt : $CONTAINER_STATE"

if [ "$CONTAINER_STATE" != "exited" ]; then
    echo "⚠️ Erreur lors de l'arrêt du conteneur $CONTAINER_NAME. État actuel : $CONTAINER_STATE"
    exit 1
fi

# Arrêter le pod
echo "Arrêt du pod $POD_NAME..."
podman pod stop $POD_NAME

# Attendre que le pod ait bien le temps de s'arrêter
sleep 5

# Vérifier l'état du pod après l'arrêt
POD_STATE=$(podman pod inspect $POD_NAME --format '{{.State}}')
echo "État du pod après arrêt : $POD_STATE"


if [[ "$POD_STATE" != "Stopped" && "$POD_STATE" != "Exited" ]]; then
    echo "⚠️ Erreur lors de l'arrêt du pod $POD_NAME. État actuel : $POD_STATE"
    exit 1
fi

# Supprimer le pod
echo "Suppression du pod $POD_NAME..."
podman pod rm $POD_NAME

echo "🐾 Pod $POD_NAME supprimé avec succès !"

# Vérifier si le port est toujours utilisé
if ss -tulnp | grep -q ":${PORT} "; then
    echo "⚠️ Le port ${PORT} est toujours utilisé après la suppression du pod."

    # Trouver et afficher le processus utilisant le port
    PID=$(sudo lsof -t -i :${PORT})
    if [ -n "$PID" ]; then
        echo "Processus utilisant le port ${PORT} : PID ${PID}"
    else
        echo "Aucun processus identifiable n'utilise le port ${PORT}."
    fi
else
    echo "🐾 Pod $POD_NAME supprimé et port ${PORT} libéré avec succès !"
fi
