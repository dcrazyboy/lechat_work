# Installation Native de VSCodium

Vous pouovez-biensur utilise Snap, mais je préfère la méthode :hammer: :wrench: 

## Prérequis

- 1 pc (portable ou fixe)
- 1 disque externe ou pouquoi pas un clef usb formatée pour linux
- git installe sur le PC

## Sur Rocky Linux
```bash
sudo rpmkeys --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg
sudo dnf config-manager --add-repo https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/rpms/
sudo dnf install codium
```
## Sur openSUSE tumblewzdd
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
# se placer sur la racine du DD
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
```

Récuperer sur github les fichier workspace et json dans lechat_work/vscodium/workspace_and_settings
```bash
cp <workspace_name>.workspace <nom disque>/prof/vscodium/<vorkspace_name/
cp emojis.md <nom disque>/prof/vscodium/