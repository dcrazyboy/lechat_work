FROM nvcr.io/nvidia/pytorch:23.10-py3

# Installer les dépendances système
RUN apt-get update && apt-get install -y \
    git \
    wget \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Cloner Stable Diffusion WebUI
RUN git clone https://github.com/Automatic1111/stable-diffusion-webui.git /workspace/stable-diffusion-webui

# Installer les dépendances Python
WORKDIR /workspace/stable-diffusion-webui
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# Configurer l'utilisateur
RUN useradd -m appuser && \
    chown -R appuser:appuser /workspace

USER appuser
WORKDIR /workspace/stable-diffusion-webui
