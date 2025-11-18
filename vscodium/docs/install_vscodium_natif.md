# Installation Native de VSCodium

Vous pouovez-biensur utilise Snap, mais je préfère la méthode :hammer_and_wrench: 

## Prérequis

- 1 pc (portable ou fixe)
- 1 disque externe ou pouquoi pas un clef usb formatée pour linux
- git installe sur le PC

## Sur Rocky Linux (RedHat family)
```bash
sudo rpmkeys --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg
sudo dnf config-manager --add-repo https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/rpms/
sudo dnf install codium
```
## Sur openSUSE tumbleweed (openSUSE family)
```bash
sudo rpm --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg
sudo zypper ar -f https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/rpms/ vscodium
sudo zypper install codium
```

## L'espace de travail

Choix : Installation de l'espace de travail sur disque externe ou clef usb (petits projets ou pour demo/partage)

### Arborescence
```
prof
  └──  vscodium
        ├── dcrazyboy/          # 🔒 Projet privé (GitHub privé)
        ├── lechat_work/        # 🤝 Projet collaboratif (GitHub privé/public)
        └── postgres_dba_toolkit/ # 🌍 Projet public (GitHub public)

```
### Initialisation
```bash
# se placer sur la racine du DD ou de la clef
mkdir -p prof
cd prof
mkdir -p vscodium
mkdir -p vscodium/{.vscode dcrazyboy lechat_work postgres_dba_toolkif}
cd vscodium/dcrazyboy
git init
cd ../lechat_work
git init
cd ../postgres_dba_toolkit
git init
cd <racine diqu externe>
# se dépalcer sur le $HOME
cd ~
# s'il n'existe pas
mkdir -p scripts
# s'il nexiste pas
mkdir -p .config
mkdir -p .config/VSCodium
mkdir -p .config/VSCodium/User
# creer le dossier par defaut pour VSCodium
mkdir -p default_codium
```
### Installations complementaires
Récuperer sur github les fichier workspace et json dans lechat_work/vscodium/workspace_and_settings et les installer
```bash
cp <workspace_name>.workspace <nom disque>/prof/vscodium/<vorkspace_name>/
cp emojis.md <nom disque>/prof/vscodium/
cp settings.json ~/.config/VSCodium/User/
```
Récupérer sur github les fichiers scripts dans lechat_work/vscodium/scripts et les installer
```bash
cp launch_codium.sh ~/scripts/
chmod +x ~/sctipts/*.sh
```
#### Mise à jour du gestionnaire d'application
##### GNOME
Récupérer le .desktop general et l'installe dans le $HOME
```bash
cp /usr/share/applications/codium.desktop ~/.local/share/applications/
```
Mettre à jour le codium.desktop
```bash
# editer ~/.local/share/applications/codium.desktop (vi, nano, ...)
# ligen a modifier
# Exec=/usr/share/codium/codium %F
# devient
Exec=/bin/bash -c "~/scripts/launch_codium.sh"
# régénérer le cache
update-desktop-database ~/.local/share/applications/
```
#### Test
DD ou clef USB retirée lancer VSCodium
Il doit démarrer dan le dossier par defaut ~/default_codium

Branche le DD ou la clef USB
Vérifier qu'elle est bien montée et accessible
Relance VSCodium
Il doit démarre sur < disque externe >/prof/vscodium

## Paramètrage et shortcut
### Général
#### Paramètrage
```
    // Apparence
    "workbench.colorTheme": "Default Dark+",
    "workbench.iconTheme": "material-icon-theme",
    // Raccourcis personnalisés (à ajouter dans keybindings.json)
    "workbench.startupEditor": "newUntitledFile",
    //editeur
    "editor.fontSize": 14,
    "editor.fontFamily": "'Fira Code', 'Courier New', monospace",
    "editor.fontLigatures": true,
    // Comportement
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
        "source.fixAll": "explicit"
    },
    // Dossiers exclus
    "files.exclude": {
        "**/.git": true,
        "**/node_modules": true,
        "**/__pycache__": true,
        "**/*.pyc": true
    },
    // Terminal
    "terminal.integrated.shell.linux": "/bin/bash",
    "terminal.integrated.fontFamily": "'Fira Code'",
    // Extensions
    "extensions.autoUpdate": true,
```
#### Shortcut
Ajout des shortcut de bascule d'un environnement a l'autre


```
[
  {
    "key": "ctrl+alt+1",
    "command": "projectManager.openProject",
    "args": "dcrazyboy"
  },
  {
    "key": "ctrl+alt+2",
    "command": "projectManager.openProject",
    "args": "lechat_work"
  },
  {
    "key": "ctrl+alt+3",
    "command": "projectManager.openProject",
    "args": "postgres_dba_toolkit"
  }
]
```
### Extension : Gitlens
#### Paramètrage
Paramètrage Git
```
    // Git
    "git.enableSmartCommit": true,
    "git.confirmSync": false,
    "git.ignoreMissingGitWarning": true
```
Paramètrage Gitlens
```
    // GitLens
    "gitlens.codeLens.enabled": true,
    "gitlens.currentLine.enabled": true,
    "gitlens.hovers.currentLine.over": "line",
    "gitlens.hovers.enabled": true,
```
#### Shortcut
| Raccourci | Commande GitLens                                |
| :-------- | :---------------------------------------------- |
| Alt+G B   | Basculer le blame du fichier                    |
| Alt+G L   | Basculer le blame de la ligne                   |
| Alt+G H   | Ouvrir l'historique du fichier                  |
| Alt+G F   | Ouvrir l'historique rapide du fichier           |
| Alt+G R   | Ouvrir l'historique rapide du dépôt             |
| Alt+G C   | Voir les détails du commit actuel               |
| Alt+G D   | Voir les détails du commit de la ligne actuelle |

### Extension : Markdown All In One
#### Parametrage
```
    // Markdown
    "markdown.preview.fontSize": 14,
    "markdown.preview.fontFamily": "'Fira Code'",
    // Activation des fonctionnalités de base
    "markdown.extension.toc.levels": "1..6",
    "markdown.extension.toc.orderedList": true,
    // Formatage automatique
    "markdown.extension.orderedList.marker": "one",
    // Prévisualisation
    "markdown.extension.preview.autoShowPreviewToSide": true,
    // Autres paramètres utiles
    "markdown.extension.completion.enabled": true,
```

#### Shortcut
| Raccourci              | Action                                   |
| :--------------------- | :--------------------------------------- |
| Ctrl+B                 | Mettre en gras le texte sélectionné.     |
| Ctrl+I                 | Mettre en italique le texte sélectionné. |
| Ctrl+Shift+``          | Insérer un bloc de code.                 |
| Ctrl+Shift+M           | Basculer la prévisualisation Markdown.   |
| Ctrl+Shift+P > "Table" | Insérer un tableau Markdown.             |

### Extension : Project Manager
#### Paramètrage
```
    // Project Manager
    "projectManager.sortList": "Name",
    "projectManager.git.baseFolders": [
        "/run/media/dcrazyboy/My Passport/prof/vscodium/"
    ],
```
#### Initialisation
1. Installer l'Extension
   1. Ouvrir VSCodium.
   2. Dans l'onglet des extensions (Ctrl+Shift+X).
   3. Chercher Project Manager (alefragnani.project-manager) et l'installer.


2. Sauvegarder les Projets dans Project Manager (a recommence pour chaque projet)
   1. Ouvrir le projet à sauvegarder dans VSCodium. (open folder)
   2. Ouvre la palette de commandes (Ctrl+Shift+P).
   3. Sélectionner "Project Manager: Save Project".
   4. Donner un nom à ton projet (par exemple, dcrazyboy).

### Extension : Shellcheck
#### Paramètrage
```
    // ShellCheck
    "shellcheck.executablePath": "/usr/bin/shellcheck",
    "shellcheck.run": "onSave",
    "shellcheck.ignorePatterns": {
        "**/node_modules/**": true,
        "**/vendor/**": true
    },
    "shellcheck.disableVersionCheck": true
```
