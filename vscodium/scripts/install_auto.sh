#!/bin/bash

# =============================================
# EN-TÊTE
# =============================================
PROGNAME=$(basename "$0")
AUTHOR="D. Crazyboy"
VERSION="Version 1.0.0"
DESCRIPTION="Script d'installation automatisée de VSCodium pour Linux/WSL."

# Chargement de /etc/profile (pour les variables d'environnement système)
. /etc/profile

# =============================================
# MODE DRY-RUN (simulation)
# =============================================
DRY_RUN=false
if [ "$1" = "--dry-run" ]; then
    DRY_RUN=true
    echo "🔍 Mode SIMULATION activé (aucune modification ne sera appliquée)."
fi

# =============================================
# SECTION 1 : Fixation des variables
# =============================================
if [ "$DRY_RUN" = false ]; then
    echo "📌 [Étape 1/5] Configuration des variables..."
else
    echo "[DRY RUN ] 📌 [Étape 1/5] Configuration des variables..."
fi

# Variables personnalisables (à adapter par l'utilisateur)
export RACINE_EXT="/mnt/d"          # Chemin du disque externe (ex: D:\ sous WSL/Windows)
export PATH_EXT="prof/vscodium"     # Chemin relatif sur le disque externe
export RACINE_INT="$HOME"           # Chemin interne par défaut ($HOME)
export PATH_INT="default_codium"    # Dossier interne par défaut
export REPO_PRIV="repo_priv"        # Dossier pour les projets privés
export REPO_COL="repo_col"          # Dossier pour les projets collaboratifs
export REPO_PUB="repo_pub"          # Dossier pour les projets publics

# Variables dérivées (ne pas modifier)
export FULL_PATH_EXT="${RACINE_EXT}/${PATH_EXT}"
export FULL_PATH_INT="${RACINE_INT}/${PATH_INT}"

if [ "$DRY_RUN" = false ]; then
    echo "   Variables définies :"
    echo "   - Disque externe : ${FULL_PATH_EXT}"
    echo "   - Dossier interne : ${FULL_PATH_INT}"
else
    echo "   [DRY RUN] Variables définies (simulation)."
    echo "   [DRY RUN] - Disque externe prévu : ${FULL_PATH_EXT}"
    echo "   [DRY RUN] - Dossier interne prévu : ${FULL_PATH_INT}"
fi

# =============================================
# SECTION 2 : Validation du disque externe
# =============================================
if [ "$DRY_RUN" = false ]; then
    echo -e "\n📌 [Étape 2/5] Vérification du disque externe..."
else
    echo -e "\n[DRY YUN] 📌 [Étape 2/5] Vérification du disque externe..."
fi
if [ ! -d "$RACINE_EXT" ]; then
    if [ "$DRY_RUN" = false ]; then
        echo "⚠️ Erreur : Le disque externe (${RACINE_EXT}) n'est pas monté ou inaccessible."
        echo "   - Branchez votre disque externe et réessayez."
        echo "   - Sous WSL, utilisez /mnt/<lettre> pour accéder aux disques Windows."
    else
        echo "[DRY YUN] ⚠️ Erreur : Le disque externe (${RACINE_EXT}) n'est pas monté ou inaccessible."
        echo "[DRY YUN]    - Branchez votre disque externe et réessayez."
        echo "[DRY YUN]    - Sous WSL, utilisez /mnt/<lettre> pour accéder aux disques Windows."
    fi
    exit 1
fi
if [ ! -w "$RACINE_EXT" ]; then
    if [ "$DRY_RUN" = false ]; then
        echo "⚠️ Erreur : Pas de permissions en écriture sur ${RACINE_EXT}."
        echo "   - Utilisez 'sudo chmod' ou 'sudo chown' pour ajuster les permissions."
    else
        echo "[DRY YUN] ⚠️ Erreur : Pas de permissions en écriture sur ${RACINE_EXT}."
        echo "[DRY YUN]    - Utilisez 'sudo chmod' ou 'sudo chown' pour ajuster les permissions."
    fi
    exit 1
fi
if [ "$DRY_RUN" = false ]; then
    echo "   ✅ Disque externe validé : ${RACINE_EXT}"
else
    echo "   [DRY RUN] ✅ Disque externe validé : ${RACINE_EXT}"
fi

# =============================================
# SECTION 3 : Détection de la distro et installation de Codium
# =============================================
if [ "$DRY_RUN" = false ]; then
    echo -e "\n📌 [Étape 3/5] Détection de la distro et installation de VSCodium..."
else
    echo -e "\n[DRY RUN] 📌 [Étape 3/5] Détection de la distro et installation de VSCodium..."
fi

if [ "$DRY_RUN" = false ]; then
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        case $ID in
            ubuntu|debian|mint)
                echo "   📌 Distro détectée : Debian family (${ID})"
                echo "   Installation de VSCodium..."
                wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg | sudo apt-key add - || { echo "⚠️ Échec : Ajout de la clé GPG."; exit 1; }
                echo 'deb https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/debs/ vscodium main' | sudo tee /etc/apt/sources.list.d/vscodium.list || { echo "⚠️ Échec : Ajout du dépôt."; exit 1; }
                sudo apt update || { echo "⚠️ Échec : Mise à jour des paquets."; exit 1; }
                sudo apt install codium -y || { echo "⚠️ Échec : Installation de VSCodium."; exit 1; }
                ;;
            fedora|rhel|centos|rocky|almalinux)
                echo "   📌 Distro détectée : Red Hat family (${ID})"
                echo "   Installation de VSCodium..."
                sudo rpmkeys --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg || { echo "⚠️ Échec : Import de la clé GPG."; exit 1; }
                sudo dnf config-manager --add-repo https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/rpms/ || { echo "⚠️ Échec : Ajout du dépôt."; exit 1; }
                sudo dnf install codium -y || { echo "⚠️ Échec : Installation de VSCodium."; exit 1; }
                ;;
            opensuse*)
                echo "   📌 Distro détectée : openSUSE family (${ID})"
                echo "   Installation de VSCodium..."
                sudo rpm --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg || { echo "⚠️ Échec : Import de la clé GPG."; exit 1; }
                sudo zypper ar -f https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/rpms/ vscodium || { echo "⚠️ Échec : Ajout du dépôt."; exit 1; }
                sudo zypper install codium -y || { echo "⚠️ Échec : Installation de VSCodium."; exit 1; }
                ;;
            *)
                echo "⚠️ Erreur : Famille de distro non supportée (${ID})."
                echo "   Ce script supporte Debian, Red Hat et openSUSE."
                exit 1
                ;;
        esac
    else
        echo "⚠️ Erreur : Impossible de détecter la distro (fichier /etc/os-release manquant)."
        exit 1
    fi
else
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        case $ID in
            ubuntu|debian|mint)
                echo "[DRY RUN]   📌 Distro détectée : Debian family (${ID})"
                ;;
            fedora|rhel|centos|rocky|almalinux)
                echo "[DRY RUN]   📌 Distro détectée : Red Hat family (${ID})"
                ;;
            opensuse*)
                echo "[DRY RUN]   📌 Distro détectée : openSUSE family (${ID})"
                ;;
            *)
                echo "[DRY RUN] ⚠️ Erreur : Famille de distro non supportée (${ID})."
                echo "[DRY RUN]    Ce script supporte Debian, Red Hat et openSUSE."
                exit 1
                ;;
        esac
        echo "[DRY RUN]   Installation de VSCodium...(simulation)"
    else
        echo "[DRY RUN] ⚠️ Erreur : Impossible de détecter la distro (fichier /etc/os-release manquant)."
        exit 1
    fi
fi

# Installation des extensions (même en dry-run, on affiche les commandes)
if [ "$DRY_RUN" = false ]; then
    echo "   📌 Installation des extensions VSCodium..."
else
    echo "[DRY RUN]   📌 Installation des extensions VSCodium..."
fi
if [ "$DRY_RUN" = false ]; then
    codium --install-extension eamodio.gitlens || echo "⚠️ Échec : Installation de GitLens."
    codium --install-extension alefragnani.project-manager || echo "⚠️ Échec : Installation de Project Manager."
    codium --install-extension yzhang.markdown-all-in-one || echo "⚠️ Échec : Installation de Markdown All in One."
    codium --install-extension timonwong.shellcheck || echo "⚠️ Échec : Installation de ShellCheck."
else
    echo "   [DRY RUN] Commandes pour installer les extensions :"
    echo "   [DRY RUN] codium --install-extension eamodio.gitlens"
    echo "   [DRY RUN] codium --install-extension alefragnani.project-manager"
    echo "   [DRY RUN] codium --install-extension yzhang.markdown-all-in-one"
    echo "   [DRY RUN] codium --install-extension timonwong.shellcheck"
fi

# =============================================
# SECTION 4 : Récupération des fichiers depuis GitHub
# =============================================
if [ "$DRY_RUN" = false ]; then
    echo -e "\n📌 [Étape 4/5] Téléchargement des fichiers de configuration..."
else
    echo -e "\n[DRY RUN]📌 [Étape 4/5] Téléchargement des fichiers de configuration..."
fi
if [ "$DRY_RUN" = false ]; then
    mkdir -p ~/scripts || { echo "⚠️ Échec : Création du dossier ~/scripts."; exit 1; }
    wget https://raw.githubusercontent.com/dcrazyboy/dba_toolkit/main/tools/vscodium/workspaces_and_settings/project.json -O ~/scripts/project.json || { echo "⚠️ Échec : Téléchargement de project.json."; exit 1; }
    wget https://raw.githubusercontent.com/dcrazyboy/dba_toolkit/main/tools/vscodium/workspaces_and_settings/settings.json -O ~/scripts/settings.json || { echo "⚠️ Échec : Téléchargement de settings.json."; exit 1; }
    wget https://raw.githubusercontent.com/dcrazyboy/dba_toolkit/main/tools/vscodium/scripts/launch_codium.sh -O ~/scripts/launch_codium.sh || { echo "⚠️ Échec : Téléchargement de launch_codium.sh."; exit 1; }
    echo "   ✅ Fichiers téléchargés dans ~/scripts/"
else
    echo "   [DRY RUN] Téléchargement des fichiers (simulation) :"
    echo "   - project.json → ~/scripts/project.json"
    echo "   - settings.json → ~/scripts/settings.json"
    echo "   - launch_codium.sh → ~/scripts/launch_codium.sh"
fi

# =============================================
# SECTION 5 : Intégration des variables et déplacement
# =============================================
if [ "$DRY_RUN" = false ]; then
    echo -e "\n📌 [Étape 5/5] Personnalisation et installation finale..."
else
    echo -e "\n[DRY RUN]📌 [Étape 5/5] Personnalisation et installation finale..."
fi

if [ "$DRY_RUN" = false ]; then
    # Remplacement des variables dans les fichiers
    echo "   Personnalisation des fichiers avec vos variables..."
    sed -i "s|<racine_ext>|${RACINE_EXT}|g" ~/scripts/launch_codium.sh || { echo "⚠️ Échec : Remplacement dans launch_codium.sh."; exit 1; }
    sed -i "s|<path_ext>|${PATH_EXT}|g" ~/scripts/launch_codium.sh || { echo "⚠️ Échec : Remplacement dans launch_codium.sh."; exit 1; }
    sed -i "s|<racine_ext>|${RACINE_EXT}|g" ~/scripts/project.json || { echo "⚠️ Échec : Remplacement dans project.json."; exit 1; }
    sed -i "s|<path_ext>|${PATH_EXT}|g" ~/scripts/project.json || { echo "⚠️ Échec : Remplacement dans project.json."; exit 1; }

    # Création des dossiers externes
    echo "   Création de l'arborescence externe..."
    mkdir -p "${FULL_PATH_EXT}/{.vscode,${REPO_PRIV},${REPO_COL},${REPO_PUB}}" || { echo "⚠️ Échec : Création des dossiers externes."; exit 1; }

    # Déplacement des fichiers de configuration
    echo "   Installation des fichiers de configuration..."
    mkdir -p ~/.config/VSCodium/User/ || { echo "⚠️ Échec : Création du dossier de config."; exit 1; }
    mv ~/scripts/settings.json ~/.config/VSCodium/User/ || { echo "⚠️ Échec : Déplacement de settings.json."; exit 1; }
    mkdir -p ~/.config/VSCodium/User/globalStorage/alefragnani.project-manager/ || { echo "⚠️ Échec : Création du dossier Project Manager."; exit 1; }
    mv ~/scripts/project.json ~/.config/VSCodium/User/globalStorage/alefragnani.project-manager/ || { echo "⚠️ Échec : Déplacement de project.json."; exit 1; }
    chmod +x ~/scripts/launch_codium.sh || { echo "⚠️ Échec : Ajout des permissions à launch_codium.sh."; exit 1; }

    echo -e "\n✅ Installation terminée avec succès !"
    echo "   - Disque externe : ${FULL_PATH_EXT}"
    echo "   - Fichiers de config : ~/.config/VSCodium/User/"
    echo "   - Pour lancer VSCodium : ~/scripts/launch_codium.sh"
else
    echo "   [DRY RUN] Actions finales (simulation) :"
    echo "   - Remplacement des variables dans les fichiers."
    echo "   - Création de ${FULL_PATH_EXT}/{.vscode,${REPO_PRIV},${REPO_COL},${REPO_PUB}}"
    echo "   - Déplacement des fichiers vers ~/.config/VSCodium/User/"
    echo "   - Ajout des permissions à launch_codium.sh"
    echo -e "\n   [DRY RUN] Installation simulée avec succès !"
fi
