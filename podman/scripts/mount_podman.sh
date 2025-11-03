#!/bin/bash

# Monter le disque
#pod_list=("pod_sd" "pod_comfyui" "pod_cdrage" "pod_kohya_ss" "pod_jupyter_lab" "build")
nb_ln=0
nb_ln_err=0
element=0
#Check que le disque exter est present
if ! mountpoint -q /mnt/podman; then
    sudo mount /mnt/podman
fi

if mountpoint -q /mnt/podman; then
    # Montage des pods
    for element in "${pod_list[@]}"; do
        # Définir le chemin de stockage personnalisé pour ce pod
        CONFIG_FILE=~/.config/containers/storage-$element.conf

        # Créer le fichier de configuration pour Podman (une seule fois)
        if [ ! -f "$CONFIG_FILE" ]; then
            echo "🐱 Création du fichier de configuration pour $element..."
            mkdir -p ~/.config/containers/
            cat > "$CONFIG_FILE" <<EOF
[storage]
driver = "overlay"
graphroot = "/home/dcrazyboy/.local/share/$element/containers/storage"
runroot = "/run/user/$(id -u)"
EOF
        fi
        # Créer le dossier local s'il n'existe pas
        if [ ! -d ~/.local/share/"$element"/containers ]; then
            echo "🐱 Création du dossier local pour $element"
            mkdir -p ~/.local/share/"$element"/containers
        fi

        # Créer le dossier sur le disque externe s'il n'existe pas
        if [ ! -d /mnt/podman/"$element"/storage ]; then
            echo "🐱 Création du dossier externe pour $element"
            mkdir -p /mnt/podman/"$element"/storage
        fi

        # Supprimer le lien symbolique existant s'il y en a un
        if [ -e ~/.local/share/"$element"/containers/storage ]; then
            rm -rf ~/.local/share/"$element"/containers/storage
        fi

        # Créer le dossier local temporaire s'il n'existe pas
        if [ ! -d /mnt/podman/build/"$element" ]; then
            echo "🐱 Création du dossier temporaire pour $element"
            mkdir -p /mnt/podman/build/"$element"
        fi

        # Créer le lien symbolique
        ln -s /mnt/podman/"$element"/storage ~/.local/share/"$element"/containers
        echo "🐱 Lien symbolique pour $element créé"
        nb_ln=$((nb_ln+1))
    done

    # check podman est actif
    if ! $(systemctl --user is-active podman.socket); then
        systemctl --user start podman.socket
    fi
    echo "🐱 Nombre de pods accessibles : $nb_ln | En erreur : $nb_ln_err"
else
    echo "❌ Erreur : Le disque n'a pas pu être monté."
    exit 1
fi