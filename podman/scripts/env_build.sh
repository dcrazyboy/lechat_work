#!/bin/bash

# Sourcer le script de montage (avec vérification)
MOUNT_SCRIPT="$HOME/scripts/mount_podman.sh"
if [ -f "$MOUNT_SCRIPT" ]; then
    echo "🐱 Vérification du montage des pods..."
    source "$MOUNT_SCRIPT" "build"
else
    echo "❌ Erreur : Le script $MOUNT_SCRIPT est introuvable."
    exit 1
fi

# Liste des pods valides
pod_list=("pod_sd" "pod_comfyui" "pod_cdrage" "pod_kohya_ss" "pod_jupyter_lab")

# Vérifier si l'argument est valide
for element in "${pod_list[@]}"; do
  # ajoute les variables spécifique si besoin 
  if [[ ! " ${element}} " == "${1}" ]]; then
    case $element in
      pod_sd)
        export SD_WEBUI_PORT=7860
        export SD_MODELS_DIR=/mnt/podman/shared_volumes/models
        export SD_OUTPUT_DIR=/mnt/podman/shared_volumes/images/stable-diffusion
        export DISPLAY=:99
        export CUDA_VISIBLE_DEVICES=0
        echo "Configuration spécifique appliquée :"
        echo "  - SD_WEBUI_PORT = $SD_WEBUI_PORT"
        echo "  - SD_MODELS_DIR = $SD_MODELS_DIR"
        echo "  - SD_OUTPUT_DIR = $SD_OUTPUT_DIR"
        echo "  - DISPLAY = $DISPLAY"
        echo "  - CUDA_VISIBLE_DEVICES = $CUDA_VISIBLE_DEVICES"
        ;;
      pod_comfyui)
        ;;
      pod_cdrage)
        ;; 
      pod_kohya_ss)
        ;;
      pod_jupyter_lab)
        ;;
      *)
        echo "Pod inconnu."
        exit 1
        ;;
    esac
  fi
done

# Définir les variables d'environnement
export CONTAINERS_STORAGE_CONF=$HOME/.config/containers/storage-${1}.conf
export TMPDIR=/mnt/podman/build/${1}
export PODMAN_STORAGE=/mnt/podman/build/storage

# Afficher la configuration
echo "Configuration générale appliquée :"
echo "  - CONTAINERS_STORAGE_CONF = $CONTAINERS_STORAGE_CONF"
echo "  - TMPDIR = $TMPDIR"
echo "  - PODMAN_STORAGE = $PODMAN_STORAGE"
