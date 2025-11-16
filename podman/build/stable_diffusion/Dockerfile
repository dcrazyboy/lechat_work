FROM docker.io/nvidia/cuda:12.4.0-runtime-ubuntu22.04

# Installer les dépendances système (Ubuntu)
RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-venv git wget curl \
    firefox xvfb libgl1-mesa-glx libglib2.0-0 \
    meson ninja-build \
    && rm -rf /var/lib/apt/lists/*

# Créer un lien symbolique pour python
RUN ln -s /usr/bin/python3 /usr/bin/python

# Définir les variables d'environnement
ENV SD_WEBUI_PORT=7860 \
    SD_MODELS_DIR=/models \
    SD_OUTPUT_DIR=/output \
    DISPLAY=:99 \
    DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1

# Créer les répertoires pour les volumes
RUN mkdir -p /models /output

# Installer PyTorch et Torchvision en premier
WORKDIR /stable-diffusion-webui
RUN pip install torch==2.1.2+cu121 torchvision==0.16.2+cu121 --index-url https://download.pytorch.org/whl/cu121

# Installer xformers depuis une source fiable
RUN pip install -U -v --index-url https://download.pytorch.org/whl/cu121 --no-cache-dir xformers

# Installer les autres dépendances
RUN pip install svglib && \
    pip install -r https://raw.githubusercontent.com/Automatic1111/stable-diffusion-webui/master/requirements.txt

# Cloner Stable Diffusion (Automatic1111)
RUN git clone https://github.com/Automatic1111/stable-diffusion-webui.git /stable-diffusion-webui \
    && cd /stable-diffusion-webui \
    && git checkout master

# Installer les extensions (optionnel)
RUN cd /stable-diffusion-webui/extensions \
    && git clone https://github.com/Mikubill/sd-webui-controlnet.git \
    && git clone https://github.com/continue-revolution/sd-webui-segment-anything.git

# Exposer le port
EXPOSE 7860

# Lancer l'application avec la syntaxe shell
CMD ["/bin/bash", "-c", "cd /stable-diffusion-webui && python3 launch.py --listen --port=${SD_WEBUI_PORT} --xformers --enable-insecure-extension-access"]
