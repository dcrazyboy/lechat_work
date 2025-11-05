#!/bin/bash

# Sourcer le script de montage (avec vérification)
MOUNT_SCRIPT="$HOME/scripts/mount_podman.sh"
if [ -f "$MOUNT_SCRIPT" ]; then
    echo "🐱 Vérification du montage des pods..."
    source "$MOUNT_SCRIPT"
else
    echo "❌ Erreur : Le script $MOUNT_SCRIPT est introuvable."
    exit 1
fi

# Liste des pods valides
valid_pods=("pod_sd" "pod_comfyui" "pod_cdrage" "pod_kohya_ss" "pod_jupyter_lab")

# Vérifier si l'argument est valide
if [[ ! " ${valid_pods[*]} " =~ " $1 " ]]; then
    echo "Pod inconnu. Pods valides :"
    printf '%s\n' "${valid_pods[@]}"
    exit 1
fi

# Définir les variables d'environnement
export CONTAINERS_STORAGE_CONF=$HOME/.config/containers/storage-${1}.conf
export TMPDIR=/mnt/podman/build/${1}

# Afficher la configuration
echo "Configuration appliquée :"
echo "  - CONTAINERS_STORAGE_CONF = $CONTAINERS_STORAGE_CONF"
echo "  - TMPDIR = $TMPDIR"
