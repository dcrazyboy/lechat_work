#!/bin/bash

# Monter le disque
pod_list=("pod_sd" "pod_comfyui" "pod_cdrage" "pod_kohya_ss" "pod_jupyter_lab" "build")
for element in "${pod_list[@]}"; do
  # Supprimer le lien symbolique jupyter_lab
  echo "Supprimer le lien symbolique ${element}"
  rm -rf ~/.local/share/${element}/containers/storage
done
# Démonter le disque
sudo umount /mnt/podman
echo "🐾 Disque démonté en sécurité !"
