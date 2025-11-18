#!/bin/bash

# Chemin vers le disque externe
EXTERNAL_DISK_PATH="/run/media/dcrazyboy/My Passport/prof/vscodium/"

# Chemin de repli si le disque externe n'est pas disponible
FALLBACK_PATH="$HOME/default_codium"

# Vérifie si le disque externe est accessible
if [ -d "$EXTERNAL_DISK_PATH" ]; then
    # Si le disque est accessible, ouvre le répertoire sur le disque externe
    /usr/share/codium/codium "$EXTERNAL_DISK_PATH"
else
    # Sinon, ouvre le répertoire de repli
    /usr/share/codium/codium "$FALLBACK_PATH"
fi
