# Utiliser OpenSUSE Tumbleweed comme base
FROM opensuse/tumbleweed:latest

# Installer les dépendances système
RUN zypper --non-interactive refresh && \
    zypper --non-interactive install -y \
    git \
    wget \
    curl \
    python311 \
    python311-pip \
    python311-devel \
    gcc \
    gcc-c++ \
    make \
    cmake \
    nodejs22 \
    npm22 \
    libffi-devel \
    libopenssl-devel \
    readline-devel \
    sqlite3-devel \
    xz-devel \
    libbz2-devel \
    tk-devel \
    libexpat-devel \
    jitterentropy-devel \
    Mesa-libGL1 \
    libX11-6 \
    libXext6 \
    libXrender1 \
    libXi6 \
    libfreetype6 \
    libfontconfig1 \
    libcups2 \
    libcurl4 \
    libjpeg8 \
    libpng16-16 \
    libtiff6 \
    libwebp7 \
    libopenjp2-7 \
    libgbm1 \
    libdrm2 \
    libxkbcommon0 \
    libxcb-util1 \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-render-util0 \
    libxcb-xinerama0 \
    libxcb-xinput0 \
    libxcb-xfixes0 \
    libxcb-shape0 \
    libxcb-randr0 \
    libxcb-util1 \
    libxcb-xkb1 \
    libxcb-sync1 \
    libxshmfence1 \
    libXcursor1 \
    libXdamage1 \
    libXfixes3 \
    libXft2 \
    libXinerama1 \
    libXrandr2 \
    libXrender1 \
    libXtst6 \
    libpulse0 \
    libasound2 \
    libatk-1_0-0 \
    libatk-bridge-2_0-0 \
    libatspi0 \
    libdbus-1-3 \
    libgdk_pixbuf-2_0-0 \
    libgtk-3-0 \
    libpango-1_0-0 \
    libglvnd \
    libGLU1 \
    libglvnd \
    nvidia-gl-G06

# Cloner Stable Diffusion WebUI
RUN mkdir -p /data/projets && \
    git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git /data/projets/stable-diffusion-webui

# Configurer l'environnement virtuel et installer les dépendances
WORKDIR /data/projets/stable-diffusion-webui
RUN python3.11 -m venv venv && \
    . venv/bin/activate && \
    pip install --upgrade pip wheel && \
    pip install torch==2.5.1 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121 && \
    pip install xformers==0.0.28.post3 --no-cache-dir && \
    pip install -r requirements.txt

# Configurer l'utilisateur
RUN useradd -m appuser && \
    chown -R appuser:appuser /data/projets

USER appuser
WORKDIR /data/projets/stable-diffusion-webui

# Activer l'environnement virtuel et lancer Stable Diffusion avec python3.11
CMD ["bash", "-c", "source venv/bin/activate && python3.11 launch.py --listen --xformers --enable-insecure-extension-access"]

