#!/bin/bash

# Configuration
DISK_PATH="/run/media/dcrazyboy/My\ Passport/prof/vscodium/"
WORKSPACES_DIR="$DISK_PATH/lechat_work/vscodium/workspaces"
VSCODIUM_BIN="codium"

# Vérifier si le disque externe est monté
if [ ! -d "$DISK_PATH" ]; then
    echo "❌ Erreur : Le disque externe n'est pas monté."
    read -p "Voulez-vous essayer de le monter maintenant ? (y/n) " choice
    if [ "$choice" = "y" ]; then
        sudo mount /dev/sdX1 "$DISK_PATH"  # Remplace sdX1 par ton périphérique
    else
        exit 1
    fi
fi

# Lister les workspaces disponibles
echo "📂 Workspaces disponibles :"
ls "$WORKSPACES_DIR" | grep -E "\.code-workspace$" | sed 's/\.code-workspace//g'

# Demander à l'utilisateur de choisir un workspace
read -p "Quel workspace voulez-vous ouvrir ? (sans l'extension) " workspace_name

# Vérifier si le workspace existe
WORKSPACE_FILE="$WORKSPACES_DIR/$workspace_name.code-workspace"
if [ ! -f "$WORKSPACE_FILE" ]; then
    echo "❌ Erreur : Le workspace '$workspace_name' n'existe pas."
    exit 1
fi

# Lancer VSCodium avec le workspace
echo "🚀 Ouverture de '$workspace_name'..."
"$VSCODIUM_BIN" --folder-uri "$WORKSPACE_FILE"

# Message de fin
echo "✅ VSCodium est lancé avec le workspace '$workspace_name'."
