#!/bin/bash

# Supprimer le lien symbolique SD
echo "Supprimer le lie symbolique SD"
rm -rf ~/.local/share/pod_sd/containers/storage
# Supprimer le lien symbolique ComfyUI
echo "Supprimer le lien symbolique ComfyUI"
rm -rf ~/.local/share/pod_comfyui/containers/storage
# Supprimer le lien symbolique cdrage
echo "Supprimer le lien symbolique cdrage"
rm -rf ~/.local/share/pod_cdrage/containers/storage
# Supprimer le lien symbolique kohya_ss
echo "Supprimer le lien symbolique kohya_ss"
rm -rf ~/.local/share/pod_kohya_ss/containers/storage
# Supprimer le lien symbolique jupyter_lab
echo "Supprimer le lien symbolique jupyter_lab"
rm -rf ~/.local/share/pod_jupyter_lab/containers/storage
# Démonter le disque
sudo umount /mnt/podman
echo "🐾 Disque démonté en sécurité !"
