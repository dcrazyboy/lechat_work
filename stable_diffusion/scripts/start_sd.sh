#!/bin/bash
# Script de démarrage optimisé pour Stable Diffusion
SD_WEBUI_DIR="/data/projets/stable-diffusion-webui"

# Vérifie et clone uniquement si le dossier n'existe pas
if [ ! -d "$SD_WEBUI_DIR" ]; then
    echo "Clonage initial du dépôt..."
    git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git "$SD_WEBUI_DIR"
fi

# Se place dans le dossier et met à jour
cd "$SD_WEBUI_DIR" || exit
git pull

# Active l'environnement virtuel
source venv/bin/activate

# Lance l'interface avec tes flags
./webui.sh --xformers --medvram --opt-sdp-attention --disable-nan-check
