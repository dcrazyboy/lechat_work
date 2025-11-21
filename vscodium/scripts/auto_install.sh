#!/bin/bash

# Détection de la distribution
if grep -q "Rocky" /etc/os-release; then
    echo "Installation pour Rocky Linux..."
    sudo rpmkeys --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg
    sudo dnf config-manager --add-repo https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/rpms/
    sudo dnf install codium -y
elif grep -q "openSUSE" /etc/os-release; then
    echo "Installation pour openSUSE..."
    sudo rpm --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg
    sudo zypper ar -f https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/rpms/ vscodium
    sudo zypper install codium -y
else
    echo "Distribution non supportée. Veuillez installer VSCodium manuellement."
    exit 1
fi

# Création de l'arborescence
mkdir -p ~/prof/vscodium/{.vscode,mon_projet_prive,mon_projet_public}
cd ~/prof/vscodium/mon_projet_prive && git init
cd ~/prof/vscodium/mon_projet_public && git init

# Téléchargement des fichiers de configuration anonymisés
wget https://raw.githubusercontent.com/dcrazyboy/postgres_dba_toolkit/main/vscodium/config/settings.json -O ~/.config/VSCodium/User/settings.json
wget https://raw.githubusercontent.com/dcrazyboy/postgres_dba_toolkit/main/vscodium/config/launch_codium.sh -O ~/scripts/launch_codium.sh
chmod +x ~/scripts/launch_codium.sh

# Installation des extensions
codium --install-extension eamodio.gitlens
codium --install-extension alefragnani.project-manager
codium --install-extension yzhang.markdown-all-in-one
codium --install-extension timonwong.shellcheck

echo "Installation terminée ! Redémarrez VSCodium."
