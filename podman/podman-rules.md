# Règles et Guide Podman pour l'IA Générative

## ⚙️ CONTEXTE POUR LE CHAT (À METTRE À JOUR)
**Contexte / Contraintes**
- **OS** : openSUSE Tumbleweed
- **Carte graphique** : NVIDIA GTX 3070 (driver 580.82.07), CUDA 13.0 (hôte)
- **Outils** : Podman (mode **rootless**), git
- **Langages** : bash, Python 3.1*
- **Securite** : Selinux enforced
- **disque externe**
  - **Type de disque** : HDD (disque dur mécanique, modèle 2019).
  - **Système de fichiers** : EXT4.
  - **Taille** : 4 To, exclusivement dédié à Podman.
  - **ontage manuel** : sur UUID.
  - **Utilisation** : Exclusivement dédié à Podman.

**Objectifs Principaux**
- Isoler les applications d'IA générative (SD, ComfyUI, etc.) dans des **pods réutilisables**.
- Utiliser une **version fixe de CUDA (12.4)** pour éviter les incompatibilités.
- Stocker **images et pods sur un disque externe amovible dédié**, pour :
  - Éviter toute pollution des autres disques.
  - Bénéficier d’un espace dédié et modulable.
  - Pouvoir monter/démonter le disque **sans impact sur le système hôte**.

**Fonctionnement de base**

Où sont les Pods et les Conteneurs ?
### Stockage des Données par Podman
Podman stocke tous les conteneurs, pods, images et volumes dans un dossier centralisé :

Chemin par défaut : ~/.local/share/containers/
Structure interne :

libpod/ : Contient les métadonnées des conteneurs, pods, images et volumes.
overlay/ : Contient les couches de stockage des conteneurs (système de fichiers en couches).
volumes/ : Contient les volumes nommés.

### Ton Arborescence Externe (/mnt/podman/)

Dans ton cas, tu as redirigé le stockage de Podman vers ton disque externe via des liens symboliques. Voici comment cela fonctionne :

Chaque dossier pod_*/storage/ (ex: pod_sd/storage/, pod_comfyui/storage/) est lié à ~/.local/share/containers/storage via un lien symbolique.
En réalité, Podman utilise toujours ~/.local/share/containers/storage comme point de montage, mais grâce à tes liens symboliques, les données sont stockées sur /mnt/podman/pod_*/storage/.

- Où sont les Pods et Conteneurs Physiquement ?

Pods : Les métadonnées des pods sont stockées dans libpod/ (ex: ~/.local/share/containers/storage/libpod/).
Conteneurs : Chaque conteneur est un sous-dossier dans libpod/containers/ (ex: ~/.local/share/containers/storage/libpod/containers/<container_id>/).
Images : Les images sont stockées dans libpod/images/ (ex: ~/.local/share/containers/storage/libpod/images/).

### Exemple Concret avec pod_sd et pod_comfyui
a. Structure Logique (Podman)

Pod sd_pod :

Conteneur 1 : sd_app (Stable Diffusion)
Conteneur 2 : sd_web (Interface web)

Pod comfyui_pod :

Conteneur 1 : comfyui_app (ComfyUI)
Conteneur 2 : comfyui_web (Interface web)

b. Structure Physique (Disque Externe)

Pour pod_sd :

/mnt/podman/pod_sd/storage/libpod/containers/ : Contient les métadonnées des conteneurs sd_app et sd_web.
/mnt/podman/pod_sd/storage/libpod/pods/ : Contient les métadonnées du pod sd_pod.

Pour pod_comfyui :

/mnt/podman/pod_comfyui/storage/libpod/containers/ : Contient les métadonnées des conteneurs comfyui_app et comfyui_web.
/mnt/podman/pod_comfyui/storage/libpod/pods/ : Contient les métadonnées du pod comfyui_pod.

### Réutilisation du Conteneur NVIDIA
a. Chaque Pod est Indépendant

Si tu crées un pod pour SD (sd_pod) et un pod pour ComfyUI (comfyui_pod), chaque pod peut contenir son propre conteneur utilisant les ressources NVIDIA.
Exemple :

sd_pod : Conteneur sd_app avec --gpus all.
comfyui_pod : Conteneur comfyui_app avec --gpus all.

b. Ressources Partagées ou Non ?

Non partagées : Chaque pod a son propre espace de noms et ses propres ressources. Les conteneurs dans différents pods ne partagent pas les ressources GPU ou CPU par défaut.
Partagées : Si tu veux que deux conteneurs partagent les mêmes ressources GPU, ils doivent être dans le même pod.


---

## 1. Contraintes et Choix de Base

### 1.1 Stockage sur Disque Externe Amovible
- **Organisation** :
  - Un répertoire dédié sur le disque externe pour les images/pods (ex : `/mnt/podman`).
  - Configuration de Podman pour utiliser ce répertoire comme stockage par défaut.
- **Avantages** :
  - Espace illimité (selon la taille du disque).
  - Possibilité de démonter le disque quand il n’est pas utilisé.
- **Script de Montage** :
  ```bash
  #!/bin/bash
  # Monter le disque (adapter l'UUID)
  sudo mount /dev/disk/by-uuid/TON_UUID_DU_DISQUE /mnt/podman
  # Créer le lien symbolique
  ln -sf /mnt/podman/podman_data/storage ~/.local/share/containers/storage
  echo "Disque monté et Podman prêt ! 🐱
  ```
- **Permissions** :
  ```bash
  sudo chown -R \$USER:\$USER /mnt/podman
  ```
- #### 🗃️ Organisation du Disque Externe
  - #### 📝Structure Recommandée 
```
/mnt/podman/
├── pod_sd/          # Lien symbolique vers ~/.local/share/containers/
│   └── storage/         # Contient images, conteneurs et métadonnées Podman
│       ├── libpod/      # Données internes (conteneurs, images, volumes)
│       ├── overlay/      # Couches overlay
│       └── volumes/      # Volumes nommés (optionnel)
│
├── pod_comfyui/          # Lien symbolique vers ~/.local/share/containers/
│   └── storage/         # Contient images, conteneurs et métadonnées Podman
│       ├── libpod/      # Données internes (conteneurs, images, volumes)
│       ├── overlay/      # Couches overlay
│       └── volumes/      # Volumes nommés (optionnel)
│
├── pod_cdrage/          # Lien symbolique vers ~/.local/share/containers/
│   └── storage/         # Contient images, conteneurs et métadonnées Podman
│       ├── libpod/      # Données internes (conteneurs, images, volumes)
│       ├── overlay/      # Couches overlay
│       └── volumes/      # Volumes nommés (optionnel)
│
├── pod_kohya_ss/          # Lien symbolique vers ~/.local/share/containers/
│   └── storage/         # Contient images, conteneurs et métadonnées Podman
│       ├── libpod/      # Données internes (conteneurs, images, volumes)
│       ├── overlay/      # Couches overlay
│       └── volumes/      # Volumes nommés (optionnel)
│
├── pod_jupyter_lab/          # Lien symbolique vers ~/.local/share/containers/
│   └── storage/         # Contient images, conteneurs et métadonnées Podman
│       ├── libpod/      # Données internes (conteneurs, images, volumes)
│       ├── overlay/      # Couches overlay
│       └── volumes/      # Volumes nommés (optionnel)
│
├── pod_base/          # Lien symbolique vers ~/.local/share/containers/
│   └── storage/         # Contient images, conteneurs et métadonnées Podman
│       ├── libpod/      # Données internes (conteneurs, images, volumes)
│       ├── overlay/      # Couches overlay
│       └── volumes/      # Volumes nommés (optionnel)
│
├── pod_xxx/          # Lien symbolique vers ~/.local/share/containers/
│   └── storage/         # Contient images, conteneurs et métadonnées Podman
│       ├── libpod/      # Données internes (conteneurs, images, volumes)
│       ├── overlay/      # Couches overlay
│       └── volumes/      # Volumes nommés (optionnel)
│
├── shared_volumes/      # Dossiers partagés entre pods (images, modèles, workflows)
│   ├── images/          # Images générées par SD/ComfyUI/autres
│   │   ├── stable-diffusion/  # Outputs de Stable Diffusion
│   │   ├── comfyui/          # Outputs de ComfyUI
│   │   └── ...              # Autres outils
│   ├── models/          # Modèles partagés (checkpoints, LoRAs)
│   └── workflows/       # Workflows ComfyUI réutilisables
│
├── build/
│   ├── storage/          # Répertoire pour stocker les images construites
│   │   ├── <nom_image_1> # Résultat du build
│   │   ├── <nom_image_2> # Résultat du build
│   │   └── ...
│   ├── pod_sd/           # Répertoire pour construire l'image de Stable Diffusion
│   │   ├── Dockerfile
│   │   └── scripts/
│   ├── pod_base/         # Répertoire pour construire une image de base
│   │   ├── Dockerfile
│   │   └── scripts/
│   └── xxx/              # Autres projets
│       ├── Dockerfile
│       └── scripts/
│
└── README.md            # Instructions pour le montage et l'utilisation```
```

  - 📝**Définition des Dossiers Proposés**
    -  **Lien Symbolique pour Podman (`podman_data/`)**
        - **Objectif** : Rediriger `~/.local/share/containers/storage` vers `/mnt/podman_external/podman_data/storage` pour stocker **images, conteneurs et métadonnées** sur le disque amovible.
        - **Avantage** : Pas de modification de l'installation Podman existante.
         - **Inconvénient** : Le disque doit être monté avant d'utiliser Podman.
    - **pod_xxx/** :Contient les données internes de Podman (images, conteneurs, métadonnées).Redirigé via un lien symbolique vers ~/.local/share/containers/storage.
    - **libpod/** : Stocke les couches des images, les métadonnées des conteneurs, et les fichiers de configuration.
    - **overlay/** : Contient les couches en écriture des conteneurs (modifications apportées aux images de base).
    - **volumes/** : Utilisé uniquement si tu crées des volumes nommés avec podman volume create. Optionnel dans ton cas, car tu utilises shared_volumes/.
    - **shared_volumes/** :Dossiers partagés entre pods pour les images générées, modèles, et workflows.
    - **images/** : Centralise les outputs des outils (SD, ComfyUI) pour faciliter les opérations comme img2img.
    - **models/** : Stocke les modèles partagés (checkpoints, LoRAs).
    - **workflows/** : Contient les workflows réutilisables pour ComfyUI
      - Exemple de Workflow :
        - Stable Diffusion génère des images dans shared_volumes/images/stable-diffusion/.
        - ComfyUI monte shared_volumes/images/ et utilise les images de SD pour du img2img.
        - Résultat : Pas de duplication, flux de travail fluide.
    - **Logs** :Les logs restent stockés dans chaque pod ou conteneur, et ne sont pas centralisés dans shared_volumes/.
  - 📝**Exemple Concret**
    - Tu lances un conteneur Stable Diffusion :
      ```bash 
      podman run -d --name sd-pod -v /mnt/podman/shared_volumes/images/sd:/outputs nvidia/cuda:12.4.0
      ```
      - Image de base : libpod/images/ (couches de nvidia/cuda:12.4.0).
      - Métadonnées : libpod/containers/<ID_SD_POD>/.
      - Données en écriture : overlay-containers/<ID_SD_POD>/ (si le conteneur écrit en dehors de /outputs).
      - Images générées : shared_volumes/images/sd/ (monté via -v).
    - Tu arrêtes le conteneur :Les fichiers dans overlay-containers/<ID_SD_POD>/ persistent (sauf si tu fais podman rm sd-pod).
Les images générées restent dans shared_volumes/images/sd/.

### 1.2 Configuration du Disque Externe (WD My Passport 4 To)
- **Type de disque** : HDD (disque dur mécanique, modèle 2019).
- **Système de fichiers** : EXT4 (Linux).
- **Taille** : 4 To, exclusivement dédié à Podman.
- **UUID** : `003A24B23A24A71E`.
- **Point de montage** : `/mnt/podman` (fixe, pour éviter les conflits avec `/run/media/`).
  - **Problème** : Montage automatique par `udev` dans `/run/media/dcrazyboy/my\ passport/`, ce qui peut entrer en conflit avec un autre disque similaire.
  - **Solution** : Utiliser un **point de montage fixe** (`/mnt/podman`) et désactiver le montage automatique par `udev`.
- **Utilisation** : Exclusivement dédié à Podman.
- **Utilisation avec NTFS** 
  - **Avantages** :
    - Compatible avec Windows et Linux.
    - Pas besoin de reformater.
  - **Inconvénients** :
    - Performances légèrement inférieures à ext4 sous Linux.
    - Pas de support natif pour les permissions Linux (d’où l’importance des options uid, gid, dmask, fmask dans /etc/fstab).
  - **Décision**
    - Reformatage en ext4 

voir section "Configuration Technique" -> "Préparation du Disque Externe"

### 1.3 Briques à empiler vs. images toutes faites ?
#### 1.3.1 Images toutes faites (ex : cdrage/ai-image-generation-aio-podman)

- **Avantages** :
  - Prêtes à l’emploi : Pas besoin de configurer manuellement les dépendances (CUDA, Python, extensions).
  - Optimisées : Souvent allégées (ex : suppression des modèles par défaut comme SDXL pour gagner de la place).
  - Intégration facile : Partage des modèles/LoRAs entre outils (ex : Stable Diffusion → ComfyUI).
  - Maintenance simplifiée : Mises à jour gérées par le mainteneur de l’image.
- **Inconvénients** :
  - Moins flexibles : Difficile de modifier la configuration de base (ex : changer de version de CUDA).
  - Taille : Certaines images peuvent être lourdes (même allégées).
  - Dépendance au mainteneur : Si l’image n’est plus mise à jour, tu devras migrer.

#### 1.3.2 Briques à empiler (ex : partir de nvidia/cuda:12.4.0 et ajouter les outils)

- **Avantages** :
  - Contrôle total : Tu choisis chaque composant (version de Python, extensions, etc.).
  - Personnalisation : Adapté pour des besoins spécifiques (ex : ajouter un outil rare).
  - Apprentissage : Meilleure compréhension du fonctionnement des conteneurs.
- **Inconvénients** :
  - Complexité : Configuration manuelle des dépendances (risque d’erreurs).
  - Maintenance : Tu dois gérer les mises à jour toi-même.
  - Temps : Plus long à mettre en place.

#### 1.3.3 Images Podman pour SD/ComfyUI (cdrage et autres)

- **cdrage/ai-image-generation-aio-podman**
  - Contenu :
Stable Diffusion WebUI (avec ControlNet, After Detailer, Dreambooth, etc.).
ComfyUI (avec synchronisation des modèles/LoRAs entre les outils).
Kohya_ss (pour l’entraînement de modèles).
Jupyter Lab pour uploader/modifier des fichiers.
  - Avantages :
Tout-en-un : Idéal pour démarrer rapidement.
Synchronisation des modèles : Télécharge un modèle dans SD, il apparaît dans ComfyUI.
Allégé : Modèles par défaut supprimés (ex : SDXL).
  - Inconvénients :
Linux uniquement : Ne fonctionne pas sur macOS/Windows via Podman Machine.
Personnalisation limitée : Difficile d’ajouter des outils non prévus.

- **ai-dock/comfyui** :
Spécialisé pour ComfyUI avec support NVIDIA GPU et gestion des UID/GID.
  - Avantages : 
Léger, configurable, adapté aux environnements cloud/locaux.
  - Inconvénients : 
Moins d’outils intégrés que cdrage.

- **mmartial/ComfyUI-Nvidia-Docker** :
Pour NVIDIA GPU avec gestion des permissions utilisateur.
  - Avantages : 
Séparation claire entre données utilisateur et runtime (dossier basedir).
  - Inconvénients : 
Configuration plus complexe pour les débutants.

- **YanWenKun/ComfyUI-Docker** :
Simple pour les débutants (inclut ComfyUI-Manager et le modèle Photon SD1.5).
  - Avantages : 
Facile à déployer, même en WSL2.
  - Inconvénients : 
Pas recommandé pour Podman rootless.

#### 1.3.4 Résumé des Avantages/Inconvénients

|Critère        |Images toutes faites|Briques à empiler
|:--|:--:|:--:| 
|Facilité|⭐⭐⭐⭐⭐ (ex : cdrage)|⭐⭐ (complexe)|
|Flexibilité|⭐⭐ (limitée)|⭐⭐⭐⭐⭐ (totale)|
|Maintenance|⭐⭐⭐⭐ (gérée par le mainteneur)|⭐ (à toi de tout gérer)|
|Apprentissage|⭐ (peu de contrôle)|⭐⭐⭐⭐⭐ (meilleure compréhension)|
|Performance|⭐⭐⭐ (optimisée)|⭐⭐⭐⭐ (si bien configuré)|

#### 1.3.5 Compatibilité avec la structure d'installation prévue
L’image cdrage/ai-image-generation-aio-podman est très proche la réflexion actuelle, mais elle nécessite quelques adaptations mineures pour s’intégrer parfaitement au schéma d’organisation du disque externe.
A noter :
- **Compatibilité avec organisation prévue**
  - Points communs :
  - Partage des modèles/LoRAs : 
  L’image cdrage synchronise automatiquement les modèles entre Stable Diffusion et ComfyUI, ce qui correspond à ton objectif de partage via shared_volumes/models/.
  - Utilisation de volumes : 
  Elle est conçue pour monter des dossiers locaux (comme ton /mnt/podman/shared_volumes/).
  - Mode rootless : 
  Fonctionne en mode rootless (comme ta configuration Podman).
  - PAs besoin de changer de pod pour passe de SD à ComfyUI
  - Montage des Volumes
    - Problème : L’image cdrage s’attend à un dossier /workspace pour stocker les données persistantes (modèles, images générées, etc.).
    - Solution : Monte tes dossiers shared_volumes/ dans /workspace à l’intérieur du conteneur
Lien Symbolique pour Podman
  - Le lien symbolique (/mnt/podman/podman_data/storage) reste inchangé.
  - L’image cdrage n’interfère pas avec la configuration de Podman elle-même (elle utilise les volumes montés, pas le stockage interne de Podman).
  - Pas besoin de modifier ta configuration prévue de Podman.

- **Points d'attention**
  - Ports : 
L’image cdrage expose plusieurs ports (ex : 3000 pour SD, 8888 pour Jupyter Lab). Assure-toi qu’ils ne sont pas en conflit avec d’autres services.
  - Modèles par défaut : 
Certains modèles (comme SDXL) sont supprimés pour gagner de la place. Tu devras les télécharger manuellement dans shared_volumes/models/.
  - Extensions : 
L’image inclut des plugins pour Stable Diffusion (ControlNet, After Detailer, etc.). Vérifie qu’ils correspondent à tes besoins.

- **Avantages de cette Intégration**
  - Pas de duplication : 
  Les données restent sur le disque externe, dans shared_volumes/.
  - Compatibilité totale : 
  L’image cdrage utilise les chemins existants.
  - Flexibilité : 
  Démontage du disque sans perdre des données (elles restent dans shared_volumes/).

#### 1.3.6 Configuration prévue vs. cdrage

- **Configuration prévue** :
  - Un pod Podman pour Stable Diffusion et un autre pour ComfyUI, avec des dossiers partagés (shared_volumes/).
  - Inconvénient : On dois basculer entre les pods pour utiliser SD ou ComfyUI.
  - Avantage : Contrôle total sur chaque outil, mais moins pratique pour un workflow fluide.
- **cdrage/ai-image-generation-aio-podman** :
  - Tout-en-un : 
  Stable Diffusion et ComfyUI (et d’autres outils) dans le même conteneur.
  - Pas besoin de changer de pod : 
  Tu peux passer de SD à ComfyUI en un clic (via les ports exposés).
  - Synchronisation automatique : 
  Les modèles/LoRAs/Images sont partagés entre les outils sans configuration supplémentaire.
  - Outils intégrés : 
  Inclut Kohya_ss (pour créer des LoRAs/modèles), Dreambooth, et d’autres extensions.

**EN RESUME**

|Critère|Configuration prévue|cdrage/aio-podman{}
| :--- | :---: | :---: |
|Nombre de pods|2 (SD + ComfyUI)|1 (tout-en-un)[]
|Basculer entre SD/ComfyUI|Oui (changer de pod)|Non (accès via différents ports)|
|Partage des modèles|Manuel (via shared_volumes/)|Automatique (synchronisé)|
|Outils intégrés|Aucun (à ajouter manuellement)|Kohya_ss, Dreambooth, Jupyter Lab, etc.|
|Création de LoRAs|Non|Oui (via Kohya_ss)
|Interface unifiée|Non|Oui (Jupyter Lab pour tout gérer)

#### 1.3.6 Possibilité solution hybrudre Configuration prevue + cdrage

oui, la structure de disque necessaire pour cdrage est la suivante
```
/mnt/podman/
├── podman_data/          # Lien symbolique vers ~/.local/share/containers/ (inchangé)
│   └── storage/          # Stockage interne de Podman (images, conteneurs, métadonnées)
│
├── shared_volumes/       # Monté dans /workspace/ à l'intérieur du conteneur
│   ├── images/           # → /workspace/images (images générées)
│   ├── models/           # → /workspace/models (modèles/LoRAs)
│   └── workflows/        # → /workspace/workflows (workflows ComfyUI)
│
└── README.md
```

Cela implique uen modification du plan prévu
```
/mnt/podman/
├── shared_volumes/
│   ├── images/          # Images générées (SD + ComfyUI)
│   ├── models/          # Modèles/LoRAs (SD + ComfyUI + Kohya_ss)
│   ├── workflows/       # Workflows ComfyUI
│   └── training_data/   # Datasets pour Kohya_ss
│
├── pod_sd/              # Pod Stable Diffusion
├── pod_comfyui/         # Pod ComfyUI
└── pod_kohya_ss/        # Pod Kohya_ss (activé ponctuellement)
```



#### 1.3.7 définition complémentaires des outls

- **Kohya_ss et Création de LoRAs/Modèles**
  - Kohya_ss est un outil intégré dans l’image cdrage pour :
  - Entraîner des LoRAs (Low-Rank Adaptations) à partir de tes propres datasets.
  - Créer des modèles personnalisés (fine-tuning de Stable Diffusion).
  - Compatibilité avec le PC :
    - Oui, ça devrait tourner si tu as :
    - Une carte NVIDIA GTX 3070 (comme tu l’as mentionné).
    - Assez de VRAM (au moins 8 Go pour entraîner des LoRAs légers).
  - Podman avec support GPU (déjà configuré chez toi).
- **Jupyter Lab : À quoi ça sert ?**
  - Jupyter Lab est un environnement interactif (comme un notebook) intégré à l’image cdrage. Il permet de :
  - Uploader/télécharger des fichiers (modèles, images, datasets) via une interface web.
  - Écrire du code Python pour automatiser des tâches (ex : pré-traitement d’images avant entraînement).
  - Visualiser et organiser tes données (ex : parcourir les images générées).
  - Lancer des scripts pour Kohya_ss ou d’autres outils sans quitter ton navigateur.

#### 1.3.7.1 Outils à Ajouter dans les Pods SD et ComfyUI
(À installer dans les deux pods pour une expérience complète et cohérente)
- **Extensions pour Stable Diffusion**
  - ControlNet :
    - Pourquoi ? :
  Permet un contrôle précis sur la génération d’images (poses, compositions).
    - Installation : 
  Ajoute l’extension via le gestionnaire d’extensions de SD ou en montant un dossier extensions/ dans ton pod.
    - Dossier partagé : 
  shared_volumes/models/ControlNet/ (pour les modèles).
  - After Detailer :
    - Pourquoi ? : 
  Améliore les détails des images après la génération initiale.
    - Installation : 
  Extension disponible dans le gestionnaire de SD.
  - Dreambooth :
    - Pourquoi ? : 
  Pour entraîner des modèles personnalisés (ex : ton visage, un style artistique).
    - Installation : 
  Extension ou script Python dans le pod SD.
  - Deforum :
    - Pourquoi ? :
  Génération de vidéos à partir d’images (animation).
    - Installation : 
  Script Python ou extension dans le pod SD.
- **Extensions pour ComfyUI**
  - ComfyUI-Manager :
    - Pourquoi ? : 
  Gestion centralisée des extensions et modèles pour ComfyUI.
    - Installation : 
  À ajouter via Git dans le pod ComfyUI.
    - Dossier partagé : 
  shared_volumes/models/ et shared_volumes/workflows/.
  - ControlNet pour ComfyUI :
  - Pourquoi ? : 
  Même utilité que dans SD, mais adapté à l’interface de ComfyUI.
  - Installation : 
  Via ComfyUI-Manager.
- IP-Adapter :
  - Pourquoi ? : 
  Génération d’images guidée par une image de référence (style transfer).
  - Installation : E
  xtension pour ComfyUI.

#### 1.3.7.2 Outils Spécifiques à Séparer (Pods Indépendants)
(À installer dans des pods dédiés, car moins fréquemment utilisés)
a. Kohya_ss
- Pourquoi séparer ? : Utilisé uniquement pour l’entraînement de LoRAs/modèles (ressource intensive, besoin ponctuel).
- Pod dédié :
  Image de base : python:3.10 + CUDA 12.4.
- Installation :
  git clone https://github.com/bmaltais/kohya_ss
  pip install -r requirements.txt
- Montage des dossiers :
-v /mnt/podman/shared_volumes/models:/kohya_ss/models \
-v /mnt/podman/shared_volumes/training_data:/kohya_ss/training_data
- Utilisation : 
Lance le pod uniquement quand tu as besoin d’entraîner un LoRA.

b. Jupyter Lab
- Pourquoi séparer ? : 
Utile pour le développement/automatisation, mais pas nécessaire en permanence.
- Pod dédié :
  - Image de base : jupyter/base-notebook + CUDA 12.4.
  - Montage des dossiers :
-v /mnt/podman/shared_volumes:/workspace
  - Utilisation : 
Pour uploader des fichiers, écrire des scripts, ou automatiser des tâches entre SD/ComfyUI.

**Organisation des Dossiers Partagés**
Voir **📝Structure Recommandée** pour la version finale 

### 1.4 Rootless (Obligatoire)
- **Pourquoi ?**
  - Sécurité : Pas besoin de droits root pour gérer les pods/images.
  - Flexibilité : Permet de monter/démonter le disque externe sans contraintes.
  - Isolation : Tout est contenu sur le disque dédié, pas de risque de pollution.
- **Comment ?**
  - Podman sera configuré en mode **rootless** (voir section "Configuration Technique").
  - Le disque externe sera monté avec des permissions adaptées pour l’utilisateur courant.

### 1.5 Version de CUDA (Fixée à 12.4)
- **Justification** :
  - CUDA 13.0 peut poser des problèmes de compatibilité (ex : SD 1.x).
  - CUDA 12.4 est stable et compatible avec le driver 580.82.07.
- **Implémentation** :
  - Les images des pods utiliseront CUDA 12.4 (via des conteneurs NVIDIA appropriés).
 
### 1.6 Accélération GPU
- **Prérequis** :
  - Installer `nvidia-container-toolkit` sur l’hôte :
    ```bash
    sudo zypper install nvidia-container-toolkit
    sudo nvidia-ctk runtime configure --runtime=podman
    sudo systemctl restart podman
    ```
  - Tester l’accès au GPU dans un conteneur :
    ```bash
    podman run --rm --device=nvidia.com/gpu=all nvcr.io/nvidia/cuda:12.4.1-base-ubuntu22.04 nvidia-smi
    ```
  - *Questions* :
    - Quel est le résultat de cette commande ? (Doit afficher les infos de la GTX 3070.)
    - Si ça ne marche pas, quelles erreurs obtients-tu ?
### 1.7 Le cas SELINUX

Pour Configurer SELinux avec Podman

1. Vérifier l'état global de SELinux
```bash
sestatus
```
=> Vérifie que SELinux est en mode enforcing et que la politique targeted est active.

1. Configurer les Booléens SELinux pour Podman
Ces commandes autorisent Podman à gérer les ressources système nécessaires (cgroups, périphériques, etc.) :
```bash
sudo setsebool -P container_manage_cgroup true   # Permet à Podman de gérer les cgroups
sudo setsebool -P container_use_devices true     # Permet l'accès aux périphériques (ex: GPU)
```

2. Appliquer le Contexte SELinux aux Fichiers
Pour que Podman puisse lire/écrire dans /mnt/podman :
```bash
# Appliquer le contexte temporairement
sudo chcon -R -t container_file_t /mnt/podman

# Rendre le changement permanent
sudo semanage fcontext -a -t container_file_t "/mnt/podman(/.*)?"

# Appliquer les règles SELinux (charge les changements)
sudo restorecon -Rv /mnt/podman
```
3. Vérifications

a) Vérifier les contextes des fichiers

```bash
ls -Z /mnt/podman
```
=> Tous les fichiers doivent afficher container_file_t (ex: drwxr-xr-x. dcrazyboy dcrazyboy system_u:object_r:container_file_t:s0).

b) Vérifier les contextes des fichiers
```bash
podman run --rm -it -v /mnt/podman/shared_volumes:/test alpine ls /test
```
=> Si la commande liste le contenu de /test, SELinux est bien configuré.

c) Déboguer en cas d'erreur

Si la commande échoue :
```bash
# Voir les refus d'accès récents
sudo ausearch -m avc -ts recent

# Voir les logs SELinux dans le noyau
sudo dmesg | grep -i selinux

# Alternative (si setroubleshoot est installé)
sudo journalctl -t setroubleshoot
```
=> Ces commandes t'aident à identifier quel contexte ou booléen manque.

4. Bonus : Désactiver SELinux Temporairement (pour tests)
Si tu veux vérifier si SELinux est bien le problème :
```bash
# Désactiver SELinux (mode permissif)
sudo setenforce 0

# Réactiver SELinux (mode enforcing)
sudo setenforce 1
```
=> À utiliser uniquement pour le débogage ! Ne laisse pas SELinux en mode permissif en production.

5. Eventuellement créer une policy particuliere
Si les règles par défaut ne suffisent pas, crée une politique personnalisée :

```bash
sudo audit2allow -a -M mypodman
sudo semodule -i mypodman.pp
```
6. Résumé

|Commande|Description|
| :----- | :----- |
|sestatus|Vérifier l'état de SELinux.|
|chcon -t container_file_t /chemin|Changer le contexte d'un fichier.|
|semanage fcontext -a -t container_file_t "/chemin(/.*)?"|Rendre le changement permanent.|
|restorecon -Rv /chemin|Appliquer les règles SELinux.|
|setsebool -P container_manage_cgroup true|Autoriser Podman à gérer les cgroups.|
|ls -Z /chemin|Voir les contextes SE|

### 1.8 le cas nvidia
1. Configuration des Modules NVIDIA


Vérification des modules NVIDIA chargés :
```bash
lsmod | grep nvidia
```

Création des fichiers /dev/nvidia* avec les bonnes permissions :

Création manuelle de /dev/nvidia-uvm :
```bash
sudo mknod -m 666 /dev/nvidia-uvm c 195 254
```



2. Configuration des règles udev pour la persistance :


Création des fichiers de règles udev :
```bash
sudo nano /etc/udev/rules.d/70-nvidia-uvm.rules
```
Ajouter :
```bash
KERNEL=="nvidia-uvm", MODE="0666"
```

Configuration des permissions pour tous les fichiers NVIDIA :
```bash
sudo nano /etc/udev/rules.d/70-nvidia-permissions.rules
```
Ajouter :
```bash
KERNEL=="nvidia*", MODE="0666"
```



Rechargement des règles udev :
```bash
sudo udevadm control --reload-rules
sudo udevadm trigger
```


3. Configuration de nvidia-container-toolkit


Réinstallation de nvidia-container-toolkit :
```bash
sudo zypper remove nvidia-container-toolkit
sudo zypper install nvidia-container-toolkit
```

Génération du fichier de configuration CDI :
```bash
sudo nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml
```

Redémarrage de Podman :
```bash
systemctl --user restart podman.socket
```


4. Vérification Finale


Test de l'accès aux volumes partagés avec Podman :
```bash
podman run --rm -it -v /mnt/podman/shared_volumes:/test alpine ls /test
```

Test de l'accès au GPU avec Podman :
```bash
podman run --rm --gpus all nvidia/cuda:12.4.0-runtime-ubuntu22.04 nvidia-smi
```


5. Persistance après Redémarrage


Vérification des modules NVIDIA après redémarrage :
```bash
lsmod | grep nvidia
```

Vérification des fichiers /dev/nvidia* après redémarrage :
```bash
ls -l /dev/nvidia*
```

---


## 2. Configuration/installation Technique

## 2.1 Installaiton / paramètrage Podman

ATTTENTION on est en rootless

### 2.1.1 Installation
```bash
sudo zypper install podman
#ajout du repos de nvidia-container-toolkit
sudo zypper ar -f https://nvidia.github.io/libnvidia-container/stable/rpm/nvidia-container-toolkit.repo
sudo zypper intall nvidia-container-toolkit

# vérifier la version
nvidia-ctk --version
NVIDIA Container Toolkit CLI version 1.17.8
commit: f202b80a9b9d0db00d9b1d73c0128c8962c55f4d

# générer le cdi

sudo nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml


```
### 2.1.2 Configuration en mode rootless

```bash
# crée l'environement de stockage local d ela config
mkdir -p ~/.config/containers/oci/hooks.d/

# Configurer le hook NVIDIA

tee ~/.config/containers/oci/hooks.d/oci-nvidia-hook.json << 'EOF'
{
  "version": "1.0.0",
  "hook": {
    "createRuntime": {
      "path": "/usr/bin/nvidia-container-cli",
      "args": ["hook", "prestart"],
      "env": [
        "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
      ]
    }
  },
  "when": {
    "always": true,
    "commands": ["create", "start"]
  },
  "stages": ["prestart"]
}
EOF

# configurer policy.json
tee ~/.config/containers/policy.json << 'EOF'
{
  "default": [
    {
      "type": "insecureAcceptAnything"
    }
  ]
}
EOF

# configurer registriess.conf

tee ~/.config/containers/registries.conf << 'EOF'
unqualified-search-registries = ["docker.io", "ghcr.io", "quay.io"]
EOF

# genere container.conf (optionnel si problème)

tee ~/.config/containers/containers.conf << 'EOF'
[containers]
default_ulimits = ["nofile=65535:65535", "memlock=-1:-1"]
runtime = "crun"
hooks_dir = ["~/.config/containers/oci/hooks.d/"]

EOF
# lancer poodman en rootless

systemctl --user start podman.socket

```

### 2.1.3 Vérification et tests

```
tree ~/.config/containers/

/home/dcrazyboy/.config/containers/
├── oci
│   └── hooks.d
│       └── oci-nvidia-hook.json
├── policy.json
└── registries.conf


 systemctl --user status podman.socket

● podman.socket - Podman API Socket
     Loaded: loaded (/usr/lib/systemd/user/podman.socket; enabled; preset: disa>
     Active: active (listening) since Mon 2025-09-29 00:01:18 CEST; 6s ago
 Invocation: 30178af9513b4064844f7d96fe881cc1
   Triggers: ● podman.service
       Docs: man:podman-system-service(1)
     Listen: /run/user/1001/podman/podman.sock (Stream)
     CGroup: /user.slice/user-1001.slice/user@1001.service/app.slice/podman.soc>

sept. 29 00:01:18 pc-pro systemd[1739]: Listening on Podman API Socket.
```
Test avec image simple

```
podman pull docker.io/library/hello-world
Trying to pull docker.io/library/hello-world:latest...
Getting image source signatures
Copying blob 17eec7bbc9d7 done   | 
Copying config 1b44b5a3e0 done   | 
Writing manifest to image destination
1b44b5a3e06a9aae883e7bf25e45c100be0bb81a0e01b32de604f3ac44711634

```

Test de CUDA
```
podman pull docker.io/nvidia/cuda:12.4.0-runtime-ubuntu22.04
Trying to pull docker.io/nvidia/cuda:12.4.0-runtime-ubuntu22.04...
Getting image source signatures
Copying blob 42896cdfd7b6 done   | 
Copying blob bccd10f490ab done   | 
Copying blob e06eb1b5c4cc done   | 
Copying blob edd1dba56169 done   | 
Copying blob 7f308a765276 done   | 
Copying blob 3af11d09e9cd done   | 
Copying blob 600519079558 done   | 
Copying blob 0ae42424cadf done   | 
Copying blob 73b7968785dc done   | 
Copying config ea6fb18ed8 done   | 
Writing manifest to image destination
ea6fb18ed8621f89d4a193c33126be30a3f01557d3324967cd35cfb199c0f9ee
dcrazyboy@pc-pro:~> podman run --rm --security-opt label=disable --gpus all docker.io/nvidia/cuda:12.4.0-runtime-ubuntu22.04 nvidia-smi

==========
== CUDA ==
==========

CUDA Version 12.4.0

Container image Copyright (c) 2016-2023, NVIDIA CORPORATION & AFFILIATES. All rights reserved.

This container image and its contents are governed by the NVIDIA Deep Learning Container License.
By pulling and using the container, you accept the terms and conditions of this license:
https://developer.nvidia.com/ngc/nvidia-deep-learning-container-license

A copy of this license is made available in this container at /NGC-DL-CONTAINER-LICENSE for your convenience.

Sun Sep 28 23:01:35 2025       
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 580.82.07              Driver Version: 580.82.07      CUDA Version: 13.0     |
+-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA GeForce RTX 3070 ...    On  |   00000000:01:00.0 Off |                  N/A |
| N/A   39C    P0             29W /  130W |      15MiB /   8192MiB |      7%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+

+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI              PID   Type   Process name                        GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|  No running processes found                                                             |
+-----------------------------------------------------------------------------------------+
```

### 2.2 Préparation du Disque Externe
#### 2.2.2 **Étapes pour Configurer le Point de Montage**
1. **Créer un point de montage fixe** :
   ```bash
   sudo mkdir -p /mnt/podman
   ```
2. **Ajouter une entrée dans /etc/fstab** :
  Édite /etc/fstab avec sudo nano /etc/fstab et ajoute :
  ```bash
    UUID=83b38d7e-e781-497d-82e4-cffd5d35f582  /mnt/podman  ext4  defaults  0  2
  ```
  Explications :
    **uid=dcrazyboy,gid=dcrazyboy** : Donne les permissions à ton utilisateur.
    **dmask=022,fmask=133** : Permet à ton utilisateur de lire/écrire les fichiers/dossiers.
    **nofail** : Empêche les erreurs au démarrage si le disque n’est pas branché.

2. **Monter le disque manuellement (pour tester)** :
  ```bash
  sudo mount /mnt/podman
  ```
3. **Vérifier le montage** :
  ```bash
    ls /mnt/podman
  ```
  → Doit afficher le contenu de ton disque.
4. **Permissions**
   Définir les permissions :
  ```bash
    sudo chcon -R -t container_file_t /mnt/podman
    sudo semanage fcontext -a -t container_file_t "/mnt/podman(/.*)?"
    sudo chown -R dcrazyboy\:dcrazyboy /mnt/podman
    sudo chmod -R 755 /mnt/podman
  ```
5. **Créer la structure sur le disque**
```bash
mkdir -p /mnt/podman/shared_volumes/images
mkdir -p /mnt/podman/shared_volumes/models
mkdir -p /mnt/podman/shared_volumes/workflows

```
6. **Déplacer les données existantes (si nécessaire)**
  ```bash
  mv ~/.local/share/containers/storage/* /mnt/podman/podman_data/storage/
  ```
7. **Créer le lien symbolique (si necessaire voir script plus loin)**
  ```bash
  ln -s /mnt/podman/podman_data/storage ~/.local/share/containers/storage
  ```
8. **Scripts de Montage/Démontage**
**Fichier `mount_podman.sh`** :
```ini
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
```
**Fichier `env_podman.sh`** :
ce fichier initialise les variable systeme pour le pod avec lequel on veut travailler
```ini
#!/bin/bash

# Sourcer le script de montage (avec vérification)
MOUNT_SCRIPT="~/scripts/mount_podman.sh"
if [ -f "$MOUNT_SCRIPT" ]; then
    echo "🐱 Vérification du montage des pods..."
    source "$MOUNT_SCRIPT"
else
    echo "❌ Erreur : Le script $MOUNT_SCRIPT est introuvable."
    exit 1
fi

# Liste des pods valides
valid_pods=("pod_sd" "pod_comfyui" "pod_cdrage" "pod_kohya_ss" "pod_jupyter_lab")

# Vérifier si l'argument est valide
if [[ ! " ${valid_pods[@]} " =~ " $1 " ]]; then
    echo "Pod inconnu. Pods valides :"
    printf '%s\n' "${valid_pods[@]}"
    exit 1
fi

# Définir les variables d'environnement
export CONTAINERS_STORAGE_CONF=~/.config/containers/storage-${1}.conf
export TMPDIR=/mnt/podman/build/${1}

# Afficher la configuration
echo "Configuration appliquée :"
echo "  - CONTAINERS_STORAGE_CONF = $CONTAINERS_STORAGE_CONF"
echo "  - TMPDIR = $TMPDIR"
```
**Fichier `env_build.sh`** :
ce fichier initialise les variable systeme pour le pod avec lequel on veut travailler
```ini
#!/bin/bash

# Sourcer le script de montage (avec vérification)
MOUNT_SCRIPT="~/scripts/mount_podman.sh"
if [ -f "$MOUNT_SCRIPT" ]; then
    echo "🐱 Vérification du montage des pods..."
    source "$MOUNT_SCRIPT"
else
    echo "❌ Erreur : Le script $MOUNT_SCRIPT est introuvable."
    exit 1
fi

# Liste des pods valides
valid_pods=("pod_sd" "pod_comfyui" "pod_cdrage" "pod_kohya_ss" "pod_jupyter_lab")

# Vérifier si l'argument est valide
if [[ ! " ${valid_pods[@]} " =~ " $1 " ]]; then
    echo "Pod inconnu. Pods valides :"
    printf '%s\n' "${valid_pods[@]}"
    exit 1
fi

# Définir les variables d'environnement
export CONTAINERS_STORAGE_CONF=~/.config/containers/storage-${1}.conf
export TMPDIR=/mnt/podman/build/${1}
export PODMAN_STORAGE=/mnt/podman/build/storage

# Afficher la configuration
echo "Configuration appliquée :"
echo "  - CONTAINERS_STORAGE_CONF = $CONTAINERS_STORAGE_CONF"
echo "  - TMPDIR = $TMPDIR"
echo "  - PODMAN_STORAGE = $PODMAN_STORAGE"
```
utilisation :
ATTENTION bien faire source et pas ./ pour que les variables soient bien initialisées dans la session
```bash
source env_podman.sh <nom_du_pod>
#ou
source env_build.sh <nom_du_pod>

```

**Fichier `umount_podman.sh`** :
```ini
#!/bin/bash

# Monter le disque
pod_list=("pod_sd" "pod_comfyui" "pod_cdrage" "pod_kohya_ss" "pod_jupyter_lab" "build")
for element in "${pod_list[@]}"; do
  # Supprimer le lien symbolique jupyter_lab
  echo "Supprimer le lien symbolique ${element}"
  rm -rf ~/.local/share/${element}/containers/storage
done
# Démonter le disque
sudo umount /mnt/podman
echo "🐾 Disque démonté en sécurité !"

```

Rendre les scripts exécutables :
```bash
chmod +x mount_podman.sh umount_podman.sh env_podman.sh env_build.sh
```

### 2.2.1 Dossiers Partagés (shared_volumes/)
- Objectif : Centraliser les images générées, modèles et workflows pour les partager entre pods (ex : SD → ComfyUI).
  
  Exemple : 

  - Stable Diffusion sauvegarde ses outputs dans shared_volumes/images/stable-diffusion/.
  - ComfyUI peut lire ces images pour des opérations img2img en montant ce dossier.

Montage dans les Pods :
```bash
# Exemple pour Stable Diffusion
podman run -d \
  --name sd-pod \
  -v /mnt/podman/shared_volumes/images/stable-diffusion:/app/outputs \
  -v /mnt/podman/shared_volumes/models:/app/models \
  nvcr.io/nvidia/cuda:12.4.0

# Exemple pour ComfyUI (accès aux images de SD)
podman run -d \
  --name comfyui-pod \
  -v /mnt/podman_external/shared_volumes/images:/app/images \
  comfyui/comfyui\:latest
```
### 2.2.2 Organisation :

Les logs restent décentralisés (dans chaque pod ou conteneur).
Les données partagées (images, modèles) sont centralisées dans shared_volumes/.

### 2.2.3 Permissions et Bonnes Pratiques

- Permissions :
  ```bash
  sudo chown -R \$USER:\$USER /mnt/podmanl
  ```
- Démontage :
  Toujours arrêter les pods avant de démonter le disque.

### 2.2.4 Exemple de Workflow : SD → ComfyUI

Stable Diffusion génère des images dans shared_volumes/images/stable-diffusion/.
ComfyUI monte shared_volumes/images/ et utilise les images de SD pour du img2img.
Résultat : Pas de duplication, flux de travail fluide.

### 2.2.5 Notes Importantes
#### 2.2.5.1 Compatibilité :
Testé avec Podman en mode rootless.
Les chemins sont relatifs au point de montage (/mnt/podman/).
#### 2.2.5.2 Sauvegardes :
Sauvegardez régulièrement podman_data/ et shared_volumes/ sur un autre support.


## 2.3 Vademecum Podman
### 2.3.1 Gestion courrante et bonne pratique

a. Gestion des Conteneurs
- Nommage des conteneurs : Utilise des noms explicites pour tes conteneurs afin de les identifier facilement.
```
podman run --name pod_<mon_conteneur> ...
```

- Utilisation des Pods : Si tu utilises plusieurs services liés (ex: Stable Diffusion + une base de données), regroupe-les dans un pod pour une gestion simplifiée.
```
podman pod create --name pod_<mon_pod>
podman run --pod pod_<mon_pod> --name nom_pod>_<appli> ...
```
- Persistance des données : Utilise des volumes pour les données persistantes (comme tu l’as déjà configuré avec ton disque externe).
```
podman volume create <nom_pod>_data
podman run --mount type=volume,source=sd_data,target=/app/data ...
```

b. Gestion des Images

- Nettoyage régulier : Supprime les images inutilisées pour libérer de l’espace.
```
podman image prune
```
- Mise à jour des images : Mets à jour tes images régulièrement pour bénéficier des dernières corrections de sécurité.
```
podman pull docker.io/nvidia/cuda:12.4.0-runtime-ubuntu22.04
```

c. Utilisation des Ressources

- Limitation des ressources : Utilise des limites de CPU et de mémoire pour éviter qu’un conteneur ne monopolise les ressources.
```
podman run --cpus=2 --memory=4g ...
```
2. Voir Ce Qui Traîne ou Tourne en Tâche de Fond
  a. Lister les Conteneurs en Cours d’Exécution
```
podman ps
```

(Affiche les conteneurs en cours d’exécution.)

  b. Lister Tous les Conteneurs (y compris ceux arrêtés)
```
podman ps -a
```
(Affiche tous les conteneurs, y compris ceux qui sont arrêtés.)

  c. Lister les Pods

```
podman pod ps
```
(Affiche les pods en cours d’exécution.)
  
  d. Voir les Ressources Utilisées par les Conteneurs
```
podman stats
```
(Affiche en temps réel l’utilisation des ressources par les conteneurs.)

3. Nettoyage des Conteneurs et Pods Inutilisés
a. Arrêter un Conteneur
```
podman stop nom_du_conteneur
```
b. Supprimer un Conteneur
```
podman rm nom_du_conteneur
```
c. Supprimer un Pod
```
podman pod rm nom_du_pod
```
d. Nettoyer les Conteneurs, Pods et Réseaux Inutilisés
```
podman system prune
```
(Supprime tous les conteneurs, pods et réseaux arrêtés, ainsi que les images non utilisées.)
e. Nettoyer les Volumes Inutilisés
```
podman volume prune
```
(Supprime les volumes non utilisés.)

4. Exemple de Workflow pour Stable Diffusion (SD)
a.  Créer et Démarrer un Pod pour SD
```
podman pod create --name sd_pod -p 7860:7860
podman run -dt --pod sd_pod --name sd_app \
  --security-opt label=disable --gpus all \
  -v /mnt/podman/pod_sd/storage:/app/storage \
  docker.io/nvidia/cuda:12.4.0-runtime-ubuntu22.04
```
b.  Arrêter et Nettoyer le Pod SD
```
podman pod stop sd_pod
podman pod rm sd_pod
```

5. Resumé
   
| Action | Commande |
| :--- | :--- |
|Lister les conteneurs|podman ps -a|
|Lister les pods|podman pod ps -a|
|Voir les ressources|podman stats|
|Arrêter un conteneur|podman stop nom_du_conteneur|
|Supprimer un conteneur|podman rm nom_du_conteneur|
|Nettoyer le système|podman system prune|
|Nettoyer les volumes|podman volume prune|

### 2.3.2  Exemple de gestion automatique
Voici comment automatiser la gestion des pods et conteneurs pour Stable Diffusion (SD) avec des scripts. On va créer des scripts pour :

- Démarrer un pod et ses conteneurs.
- Arrêter proprement le pod et ses conteneurs.
- Nettoyer les ressources inutilisées.


#### 2.3.2.1 Script pour Démarrer un Pod de test et ses Conteneurs (SD)
##### 2.3.2.1.i avec interface web
Ce script crée un pod pour SD, ajoute un conteneur avec les ressources GPU, et monte les volumes nécessaires ainsi que l'interface web.

**Fichier `test_start_jupyter_lab.sh`** :
```ini
#!/bin/bash
# Définir le fichier de configuration pour ce pod
export CONTAINERS_STORAGE_CONF=~/.config/containers/storage-pod_jupyter_lab.conf
# Nom du pod et du conteneur
POD_NAME="pod_jupyter_lab"
CONTAINER_NAME="app_jupyter_lab"
PORT=8888
WORK_DIR="/mnt/podman/shared_volumes/jupyter_lab"
USER_UID=$(id -u)
USER_GID=$(id -g)

# Vérifier si le port est déjà utilisé
if ss -tulnp | grep -q ":${PORT} "; then
    echo "Erreur: Le port ${PORT} est déjà utilisé."
    exit 1
fi

# Supprimer le pod s'il existe déjà
if podman pod exists $POD_NAME; then
    echo "Le pod $POD_NAME existe déjà. Redémarrage..."
    podman pod stop $POD_NAME
    podman pod rm $POD_NAME
fi

# Créer le répertoire de travail s'il n'existe pas
if [ ! -d "$WORK_DIR" ]; then
    echo "Création du répertoire de travail $WORK_DIR"
    sudo mkdir -p "$WORK_DIR"
    sudo chown -R $USER_UID:$USER_GID "$WORK_DIR"
    sudo chmod -R 775 "$WORK_DIR"
fi

# Créer le pod avec le port défini
echo "Création du pod $POD_NAME avec le port $PORT"
podman pod create --name $POD_NAME -p $PORT:8888 --userns=keep-id

# Démarrer le conteneur Jupyter Lab avec les UID et GID de l'utilisateur et ajouter le groupe users
echo "Lancement du conteneur $CONTAINER_NAME"
podman run -dt --pod $POD_NAME --name $CONTAINER_NAME \
  -v "$WORK_DIR:/home/jovyan/work" \
  -u $USER_UID:$USER_GID \
  --group-add=users \
  docker.io/jupyter/base-notebook:latest

sleep 10

# Afficher les logs du conteneur pour obtenir l'URL d'accès
#echo "Logs du conteneur :"
#podman logs $CONTAINER_NAME

# Afficher l'URL d'accès
TOKEN=$(podman logs $CONTAINER_NAME 2>&1 | grep -oP 'http://127.0.0.1:8888/lab\?token=\K[^ ]+')

if [ -n "$TOKEN" ]; then
    echo "Accède à Jupyter Lab via l'URL suivante :"
    echo "http://127.0.0.1:${PORT}/lab?token=${TOKEN}"
else
    echo "Impossible de récupérer le token d'accès. Vérifie les logs du conteneur."
fi
```
##### 2.3.2.1.3 Utilisation mode Batch (sans interface)

- Principe : Exécuter des commandes directement dans le conteneur via podman exec.
Exemple :
podman exec -it sd_app python3 /app/storage/generate_images.py --prompt "un chat en train de coder" --output /app/storage/output.png

- Cas d'usage : Génération d'images en arrière-plan, traitements automatisés.

##### 2.3.2.1.4 Utilisation mode Web (avec interface)

- Principe : Mapper un port (ex: 7860) et accéder à l'interface via http://localhost:7860.
Exemple de démarrage :
podman run -dt --pod sd_pod --name sd_web -p 7860:7860 docker.io/automatic1111/stable-diffusion-webui:latest

- Accès : Ouvrir un navigateur à l'adresse http://localhost:7860.

##### 2.3.2.1.4 Bonnes Pratiques
- Ports : Toujours mapper les ports (-p 7860:7860) pour l'interface web.
- Volumes : Monter les dossiers nécessaires (-v /mnt/podman/pod_sd/storage:/app/storage).
- GPU : Ajouter --gpus all pour les conteneurs nécessitant CUDA.


#### 2.3.2.2 Script pour Arrêter un Pod et ses Conteneurs
Ce script arrête proprement le pod et ses conteneurs.
#!/bin/bash
**Fichier `test_stop_jupyter_lab.sh`** :
```ini
#!/bin/bash

# Nom du pod et du conteneur
POD_NAME="pod_jupyter_lab"
CONTAINER_NAME="app_jupyter_lab"

# Vérifier si le pod existe
if ! podman pod exists $POD_NAME; then
    echo "⚠️ Le pod $POD_NAME n'existe pas."
    exit 1
fi

# Afficher les informations du pod avant l'arrêt
echo "Statut actuel du pod $POD_NAME :"
podman pod ps --format "table {{.Name}}\t{{.Status}}"

# Arrêter le conteneur principal proprement
echo "Arrêt du conteneur $CONTAINER_NAME..."
podman stop $CONTAINER_NAME

# Attendre que le conteneur ait bien le temps de s'arrêter
sleep 5

# Vérifier l'état du conteneur après l'arrêt
CONTAINER_STATE=$(podman inspect $CONTAINER_NAME --format '{{.State.Status}}')
echo "État du conteneur après arrêt : $CONTAINER_STATE"

if [ "$CONTAINER_STATE" != "exited" ]; then
    echo "⚠️ Erreur lors de l'arrêt du conteneur $CONTAINER_NAME. État actuel : $CONTAINER_STATE"
    exit 1
fi

# Arrêter le pod
echo "Arrêt du pod $POD_NAME..."
podman pod stop $POD_NAME

# Attendre que le pod ait bien le temps de s'arrêter
sleep 5

# Vérifier l'état du pod après l'arrêt
POD_STATE=$(podman pod inspect $POD_NAME --format '{{.State}}')
echo "État du pod après arrêt : $POD_STATE"


if [[ "$POD_STATE" != "Stopped" && "$POD_STATE" != "Exited" ]]; then
    echo "⚠️ Erreur lors de l'arrêt du pod $POD_NAME. État actuel : $POD_STATE"
    exit 1
fi

# Supprimer le pod
echo "Suppression du pod $POD_NAME..."
podman pod rm $POD_NAME

echo "🐾 Pod $POD_NAME supprimé avec succès !"

# Vérifier si le port est toujours utilisé
if ss -tulnp | grep -q ":${PORT} "; then
    echo "⚠️ Le port ${PORT} est toujours utilisé après la suppression du pod."

    # Trouver et afficher le processus utilisant le port
    PID=$(sudo lsof -t -i :${PORT})
    if [ -n "$PID" ]; then
        echo "Processus utilisant le port ${PORT} : PID ${PID}"
    else
        echo "Aucun processus identifiable n'utilise le port ${PORT}."
    fi
else
    echo "🐾 Pod $POD_NAME supprimé et port ${PORT} libéré avec succès !"
fi
```
#### 2.3.2.4  Script pour Vérifier l'État des Pods et Conteneurs
Ce script affiche l'état actuel des pods et conteneurs liés à SD.
**Fichier `test_check_jupyter_lab.sh`** :
```ini
#!/bin/bash

# Nom du pod
POD_NAME="pod_jupyter_lab"

# Afficher l'état du pod
echo "🐱 État du pod $POD_NAME :"
podman pod ps --filter name=$POD_NAME --format "table {{.Name}}\t{{.Status}}"

# Afficher les conteneurs du pod
echo -e "\n🐱 Conteneurs dans le pod $POD_NAME :"
podman ps --pod --filter pod=$POD_NAME --format "table {{.Names}}\t{{.Status}}"

# Afficher les volumes utilisés
echo -e "\n🐱 Volumes montés :"
podman volume ls --filter name=sd --format "table {{.Name}}\t{{.Driver}}"
```

#### 2.3.2.5 Explications et Bonnes Pratiques
a. Pourquoi Utiliser des Pods ?

- Isolation : Chaque pod est indépendant et peut être géré séparément.
- Partage de Ressources : Les conteneurs dans un pod partagent le même réseau et les mêmes volumes.
- Flexibilité : Tu peux ajouter ou supprimer des conteneurs dans un pod sans tout redémarrer.

b. Bonnes Pratiques

- Nommage Clair : Utilise des noms explicites pour tes pods et conteneurs (ex: sd_pod, sd_app).
- Volumes Partagés : Utilise des volumes pour les données persistantes (ex: /mnt/podman/shared_volumes/models).
- Nettoyage Régulier : Exécute podman system prune régulièrement pour libérer de l’espace.


### 2.3.3 Résolution des problèmes
#### 2.3.3.1 test 

a. creation
./test_start_jupyter_lab.sh 
e9b9752887f1bd5b21b2dde1e87002962f8a6bf33c11b0db3a4a67f9bed00623
Trying to pull docker.io/jupyter/base-notebook:latest...
Getting image source signatures
Copying blob 77e45ee945dc done   | 
Copying blob ef8373d600b0 done   | 
Copying blob aece8493d397 done   | 
Copying blob fd92c719666c done   | 
Copying blob 4f4fb700ef54 done   | 
Copying blob 088f11eb1e74 done   | 
Copying blob a30f89a0af6c done   | 
Copying blob dc42adc7eb73 done   | 
Copying blob 4f4fb700ef54 done   | 
Copying blob abaa8376a650 done   | 
Copying blob aa099bb9e49a done   | 
Copying blob 822c4cbcf6a6 done   | 
Copying blob 4f4fb700ef54 skipped: already exists  
Copying blob d25166dcdc7b done   | 
Copying blob 4f4fb700ef54 skipped: already exists  
Copying blob 964fc3e4ff9f done   | 
Copying blob 2c4c69587ee4 done   | 
Copying blob de2cdd875fa8 done   | 
Copying blob 75d33599f5f2 done   | 
Copying blob 4f4fb700ef54 skipped: already exists  
Copying config 07bb7d6acc done   | 
Writing manifest to image destination
3d03b85a7902e3e6cab30781a95a43d226afbb87c84dec12f23498a03f6caa78
🐱 Pod pod_jupyter_lab démarré avec succès ! Accède à http://localhost:8888

b. check

---

### 2.4 Le build
Pour étudier et apprendre le cas de test est le suivaant : 

**Intégration de Stable Diffusion avec Podman et GPU**

#### **2.4.1. Objectifs**
- **Containeriser** une installation manuelle de Stable Diffusion (Automatic1111) avec Podman.
- **Intégrer le GPU** via un conteneur CUDA dédié.
- **Gérer les volumes partagés** pour les modèles et les sorties.
- **Exposer l'interface web** (Gradio) avec un navigateur intégré ou externe.

#### **2.4.2. Architecture Globale**

##### **a. Structure des Répertoires**
```
/mnt/podman/
├── pod_sd/          # Lien symbolique vers ~/.local/share/containers/
│   └── storage/         # Contient images, conteneurs et métadonnées Podman
│       ├── libpod/      # Données internes (conteneurs, images, volumes)
│       ├── overlay/      # Couches overlay
│       └── volumes/      # Volumes nommés (optionnel)
│
/.../
├── shared_volumes/      # Dossiers partagés entre pods (images, modèles, workflows)
│   ├── images/          # Images générées par SD/ComfyUI/autres
│   │   ├── stable-diffusion/  # Outputs de Stable Diffusion
│   │   ├── comfyui/          # Outputs de ComfyUI
│   │   └── ...              # Autres outils
│   ├── models/          # Modèles partagés (checkpoints, LoRAs)
│   └── workflows/       # Workflows ComfyUI réutilisables
│
├── build/
│   ├── storage/          # Répertoire pour stocker les images construites
│   │   ├── <nom_image_1> # Résultat du build
│   │   ├── <nom_image_2> # Résultat du build
│   │   └── ...
│   ├── pod_sd/           # Répertoire pour construire l'image de Stable Diffusion
│   │   ├── Dockerfile
│   │   └── scripts/
│   ├── pod_base/         # Répertoire pour construire une image de base
│   │   ├── Dockerfile
│   │   └── scripts/
│   └── xxx/              # Autres projets
│       ├── Dockerfile
│       └── scripts/
│
└── README.md            # Instructions pour le montage et l'utilisation
```

##### **b. Composants**
| Composant | Rôle | Image/Technologie |
|-----------|------|-------------------|
| **Conteneur Stable Diffusion** | Exécute l'application et l'interface web | Image custom (basée sur `ubuntu:22.04`) |
| **Conteneur CUDA** | Fournit l'accès au GPU | `nvidia/cuda:12.4.0-runtime-ubuntu22.04` |
| **Pod Podman** | Lie les conteneurs et gère les volumes | Podman Pod |

---

#### **2.4.3. Variables d'Environnement**
Ajouter les variables suivantes à `env_build.sh` :

```bash
# Chemins et ports
export SD_WEBUI_PORT=7860
export SD_MODELS_DIR=/models
export SD_OUTPUT_DIR=/output

# GPU et affichage
export CUDA_VISIBLE_DEVICES=0
export DISPLAY=:99  # Pour Xvfb (si navigateur intégré)
```
#### **2.4.4. Dockerfile pour Stable Diffusion**
##### **a. Étapes Clés**

1. Base : ubuntu:22.04
2. Installer les dépendances :
   - Python, Git, wget, et outils système.
   - Navigateur (Firefox/Chrome) + Xvfb pour l'affichage.
3. Configurer l'environnement :

   - Définir les variables SD_MODELS_DIR, SD_OUTPUT_DIR, etc.
4. Télécharger les modèles :
   - Cloner Automatic1111 et télécharger les modèles dans /models.
5. Exposer le port :
   - EXPOSE 7860 pour l'interface web.
##### **b. Exemple de Structure**
```
FROM ubuntu:22.04

# Installer les dépendances
RUN apt-get update && apt-get install -y \
    python3 python3-pip git wget firefox-esr xvfb \
    && rm -rf /var/lib/apt/lists/*

# Configurer l'environnement
ENV SD_WEBUI_PORT=7860
ENV SD_MODELS_DIR=/models
ENV SD_OUTPUT_DIR=/output

# Copier les scripts et télécharger les modèles
COPY env_build.sh /tmp/env_build.sh
RUN /tmp/env_build.sh && rm /tmp/env_build.sh

# Exposer le port
EXPOSE 7860

# Lancer l'application
CMD ["python3", "launch.py", "--listen", "--port=7860"]
```
#### **2.4.5. Déploiement avec Podman**
##### **a. Créer le Pod**
```bash
podman pod create --name sd-pod --share=ipc -p 7860:7860
```
##### **b. Ajouter le Conteneur CUDA**
```bash
podman run --pod sd-pod --gpus all -d --name cuda-container \
  nvidia/cuda:12.4.0-runtime-ubuntu22.04 sleep infinity
```
##### **c. Ajouter le Conteneur Stable Diffusion***
```bash
podman run --pod sd-pod -d --name sd-container \
  --volume=/mnt/podman/shared_volumes/models:/models \
  --volume=/mnt/podman/shared_volumes/images/stable-diffusion:/output \
  --volume=/usr/local/cuda:/usr/local/cuda\:ro \
  mon-image-stable-diffusion
```
#### **2.4.6. Scripts de Gestion**
##### **a. Script de Build**

Rôle : Builder l'image Stable Diffusion et la stocker dans /mnt/podman/build/storage/.

Exemple :
```bash
podman build -t mon-image-stable-diffusion -f /mnt/podman/build/pod_sd/Dockerfile
podman save mon-image-stable-diffusion -o /mnt/podman/build/storage/mon-image-stable-diffusion.tar
```

##### **b. Script de Déploiement**

Rôle : Charger l'image, créer le pod, et lancer les conteneurs.

Exemple :
```bash
podman load -i /mnt/podman/build/storage/mon-image-stable-diffusion.tar
# Créer le pod et lancer les conteneurs (voir section 2.4.5)
```

##### **c. Scripts Start/Stop**

Start :
```bash
podman pod start sd-pod
```
Stop :
```bash
podman pod stop sd-pod
```

#### **2.4.7. Points à Valider**

- Compatibilité CUDA :

Vérifier que nvidia/cuda:12.4.0-runtime-ubuntu22.04 est compatible avec le driver hôte (13.0).


- Navigateur :

Tester l'affichage de l'interface web avec Xvfb ou exposer le port 7860 pour un navigateur externe.


- Permissions :

S'assurer que les volumes /models et /output ont les bonnes permissions (chmod -R 777).

#### **2.4.8. Plan d'Action**

1. Mettre à jour env_build.sh avec les nouvelles variables.
2. Rédiger le Dockerfile pour Stable Diffusion.
3. Builder l'image et la stocker dans /mnt/podman/build/storage/.
4. Créer le pod et déployer les conteneurs.
5. Tester :
   - Accès à l'interface web (http://localhost:7860).
   - Génération d'images avec le GPU.
6. Automatiser les scripts de build, déploiement, start/stop.

#### **2.4.8. IMPORTANT**
##### **2.4.8.1 Variable externes**
###### **a. Variables Existantes**

|Variable|Rôle|Exemple de valeur|
| :- | :- | :- |
|CONTAINERS_STORAGE_CONF|Chemin vers la configuration de stockage Podman|/mnt/podman/.config/containers/storage-${1}.conf|
|TMPDIR|Répertoire temporaire pour le build|/mnt/podman/build/${1}|
|PODMAN_STORAGE|Répertoire de stockage des images Podman|/mnt/podman/build/storage|
###### **b. Variables à Ajouter**
|Variable|Rôle|Exemple de valeur|
| :- | :- | :- |
|SD_WEBUI_PORT|Port pour l'interface web de Stable Diffusion|7860
|SD_MODELS_DIR|Répertoire des modèles/models|/models
|SD_OUTPUT_DIR|Répertoire de sortie des images|/output|
|DISPLAY|Affichage X11 pour le navigateur (si nécessaire)|:99|
|CUDA_VISIBLE_DEVICES|GPU à utiliser (si plusieurs)|0|

c. Intégration dans env_build.sh

Exemple :

##### **2.4.8.2 Structure des Répertoires et Volumes**
| Volume | Source (hote) | Destination (container) | Description |
| :- | :- | :- | :- |
|Modèles|/mnt/podman/shared_volumes/models|/models|Modèles Stable Diffusion|
|Sorties|/mnt/podman/shared_volumes/images/stable-diffusion|/output|Images générées|
|CUDAConteneur|cuda-container|/usr/local/cuda|Bibliothèques CUDA|

##### **2.4.8.3 Logique du Pod avec Navigateur Intégré**
###### **a. Conteneurs**
| Conteneur | Image | Role | Volume |
| :- | :- | :- | :- |
|sd-container|Image buildée (Stable Diffusion + navigateur)|Exécute Stable Diffusion et l'interface web|/models, /output, /usr/local/|
|cuda|cuda-containernvidia/cuda:12.4.0-runtime-ubuntu22.04|Fournit CUDA|/usr/local/cuda|
###### **b. Commandes Théoriques**

- Créer le pod :
```bash
podman pod create --name sd-pod --share=ipc -p 7860:7860
```
- Ajouter le conteneur CUDA :
```bash
podman run --pod sd-pod --gpus all -d --name cuda-container nvidia/cuda:12.4.0-runtime-ubuntu22.04 sleep infinity
```
- Ajouter le conteneur Stable Diffusion :
```bash
podman run --pod sd-pod -d --name sd-container \
  --volume=/mnt/podman/shared_volumes/models:/models \
  --volume=/mnt/podman/shared_volumes/images/stable-diffusion:/output \
  --volume=/usr/local/cuda:/usr/local/cuda:ro \
  mon-image-stable-diffusion
```
##### **2.4.8 Evolution des scripts**
###### **a. env_build.sh**

Ce script mest en place els acces et les variables pour l'environnement de build
```bash
#!/bin/bash

# Sourcer le script de montage (avec vérification)
MOUNT_SCRIPT="$HOME/scripts/mount_podman.sh"
if [ -f "$MOUNT_SCRIPT" ]; then
    echo "🐱 Vérification du montage des pods..."
    source "$MOUNT_SCRIPT" "build"
else
    echo "❌ Erreur : Le script $MOUNT_SCRIPT est introuvable."
    exit 1
fi

# Liste des pods valides
valid_pods=("pod_sd" "pod_comfyui" "pod_cdrage" "pod_kohya_ss" "pod_jupyter_lab")

# Vérifier si l'argument est valide
for element in "${pod_list[@]}"; do
  # ajoute les variables spécifique si besoin 
  if [[ ! " ${element}} " == "${1}" ]]; then
    case $element in
      pod_sd)
        export SD_WEBUI_PORT=7860
        export SD_MODELS_DIR=/mnt/podman/shared_volumes/models
        export SD_OUTPUT_DIR=/mnt/podman/shared_volumes/images/stable-diffusion
        export DISPLAY=:99
        export CUDA_VISIBLE_DEVICES=0
        echo "Configuration spécifique appliquée :"
        echo "  - SD_WEBUI_PORT = $SD_WEBUI_PORT"
        echo "  - SD_MODELS_DIR = $SD_MODELS_DIR"
        echo "  - SD_OUTPUT_DIR = $SD_OUTPUT_DIR"
        echo "  - DISPLAY = $DISPLAY"
        echo "  - CUDA_VISIBLE_DEVICES = $CUDA_VISIBLE_DEVICES"
        ;;
      pod_comfyui)
        ;;
      pod_cdrage)
        ;; 
      pod_kohya_ss)
        ;;
      pod_jupyter_lab)
        ;;
      *)
        echo "Pod inconnu."
        exit 1
        ;;
    esac
  fi
done

# Définir les variables d'environnement
export CONTAINERS_STORAGE_CONF=$HOME/.config/containers/storage-${1}.conf
export TMPDIR=/mnt/podman/build/${1}
export PODMAN_STORAGE=/mnt/podman/build/storage

# Afficher la configuration
echo "Configuration générale appliquée :"
echo "  - CONTAINERS_STORAGE_CONF = $CONTAINERS_STORAGE_CONF"
echo "  - TMPDIR = $TMPDIR"
echo "  - PODMAN_STORAGE = $PODMAN_STORAGE"

```

### Prerequis

## 3. Automatisation et Scripts
### 3.1. Pod de Base (CUDA 12.4)

**Objectif**
Créer un pod de base avec CUDA 12.4 pour tester l’accès au GPU et servir de base à l’installation de Stable Diffusion.

#### 3.1.1. Configuration du NVIDIA Container Toolkit pour Podman Rootless
Vérification de l’Installation
nvidia-ctk --version

→ Doit afficher une version récente (ex : NVIDIA Container Toolkit CLI version 1.17.8).

**Configuration du Hook NVIDIA**

Créer le dossier de configuration :
```bash
mkdir -p ~/.config/containers/oci/hooks.d/
```
Ajouter le hook NVIDIA :
```bash
tee ~/.config/containers/oci/hooks.d/oci-nvidia-hook.json << 'EOF'
{
  "version": "1.0.0",
  "hook": {
    "createRuntime": {
      "path": "/usr/bin/nvidia-container-cli",
      "args": ["hook", "prestart"],
      "env": [
        "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
      ]
    }
  },
  "when": {
    "always": true,
    "commands": ["create", "start"]
  },
  "stages": ["prestart"]
}
EOF
```
Redémarrer Podman :
```bash
systemctl --user restart podman.socket
```

Vérification des Périphériques NVIDIA
```bash
ls -l /dev/nvidia*
```
→ Doit afficher les périphériques /dev/nvidia0, /dev/nvidiactl, /dev/nvidia-uvm, etc.
```bash
ls -l /dev/nvidia*
crw-rw-rw-+ 1 root root 195,   0 26 oct.  23:56 /dev/nvidia0
crw-rw-rw-+ 1 root root 195, 255 26 oct.  23:56 /dev/nvidiactl
crw-rw-rw-+ 1 root root 195, 254 26 oct.  23:56 /dev/nvidia-modeset
crw-rw-rw-. 1 root root 510,   0 27 oct.  22:18 /dev/nvidia-uvm
crw-rw-rw-. 1 root root 510,   1 27 oct.  22:18 /dev/nvidia-uvm-tools

/dev/nvidia-caps:
total 0
cr--------. 1 root root 237, 1 27 oct.  22:18 nvidia-cap1
cr--r--r--. 1 root root 237, 2 27 oct.  22:18 nvidia-cap2
```


#### 3.1.1.2. si /dev/nvidia-uvm a une taille null

```bash
sudo rm /dev/nvidia-uvm
sudo mknod -m 666 /dev/nvidia-uvm c 195 254
s -l /dev/nvidia*
crw-rw-rw-+ 1 root root 195,   0 26 oct.  23:56 /dev/nvidia0
crw-rw-rw-+ 1 root root 195, 255 26 oct.  23:56 /dev/nvidiactl
crw-rw-rw-+ 1 root root 195, 254 26 oct.  23:56 /dev/nvidia-modeset
crw-rw-rw-. 1 root root 195, 254 27 oct.  22:31 /dev/nvidia-uvm
crw-rw-rw-. 1 root root 510,   1 27 oct.  22:18 /dev/nvidia-uvm-tools

/dev/nvidia-caps:
total 0
cr--------. 1 root root 237, 1 27 oct.  22:18 nvidia-cap1
cr--r--r--. 1 root root 237, 2 27 oct.  22:18 nvidia-cap2
```




3.1.2. Test du Pod de Base avec CUDA
Lancement d’un Conteneur de Test
 

```bash
podman run --rm --gpus all nvcr.io/nvidia/pytorch:23.10-py3 nvidia-smi

=============
== PyTorch ==
=============

NVIDIA Release 23.10 (build 71422337)
PyTorch Version 2.1.0a0+32f93b1

Container image Copyright (c) 2023, NVIDIA CORPORATION & AFFILIATES. All rights reserved.

Copyright (c) 2014-2023 Facebook Inc.
Copyright (c) 2011-2014 Idiap Research Institute (Ronan Collobert)
Copyright (c) 2012-2014 Deepmind Technologies    (Koray Kavukcuoglu)
Copyright (c) 2011-2012 NEC Laboratories America (Koray Kavukcuoglu)
Copyright (c) 2011-2013 NYU                      (Clement Farabet)
Copyright (c) 2006-2010 NEC Laboratories America (Ronan Collobert, Leon Bottou, Iain Melvin, Jason Weston)
Copyright (c) 2006      Idiap Research Institute (Samy Bengio)
Copyright (c) 2001-2004 Idiap Research Institute (Ronan Collobert, Samy Bengio, Johnny Mariethoz)
Copyright (c) 2015      Google Inc.
Copyright (c) 2015      Yangqing Jia
Copyright (c) 2013-2016 The Caffe contributors
All rights reserved.

Various files include modifications (c) NVIDIA CORPORATION & AFFILIATES.  All rights reserved.

This container image and its contents are governed by the NVIDIA Deep Learning Container License.
By pulling and using the container, you accept the terms and conditions of this license:
https://developer.nvidia.com/ngc/nvidia-deep-learning-container-license

ERROR: The NVIDIA Driver is present, but CUDA failed to initialize.  GPU functionality will not be available.
   [[ Unknown error (error 999) ]]

Mon Oct 27 21:34:22 2025       
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 580.82.07              Driver Version: 580.82.07      CUDA Version: 13.0     |
+-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA GeForce RTX 3070 ...    Off |   00000000:01:00.0 Off |                  N/A |
| N/A   34C    P0             24W /  130W |      15MiB /   8192MiB |      7%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+

+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI              PID   Type   Process name                        GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|  No running processes found                                                             |
+-----------------------------------------------------------------------------------------+
```
puis 
```bash
podman run --rm --gpus all -it nvcr.io/nvidia/pytorch:23.10-py3 python3 -c "import torch; print(torch.__version__); print(torch.cuda.is_available())"

=============
== PyTorch ==
=============

NVIDIA Release 23.10 (build 71422337)
PyTorch Version 2.1.0a0+32f93b1

Container image Copyright (c) 2023, NVIDIA CORPORATION & AFFILIATES. All rights reserved.

Copyright (c) 2014-2023 Facebook Inc.
Copyright (c) 2011-2014 Idiap Research Institute (Ronan Collobert)
Copyright (c) 2012-2014 Deepmind Technologies    (Koray Kavukcuoglu)
Copyright (c) 2011-2012 NEC Laboratories America (Koray Kavukcuoglu)
Copyright (c) 2011-2013 NYU                      (Clement Farabet)
Copyright (c) 2006-2010 NEC Laboratories America (Ronan Collobert, Leon Bottou, Iain Melvin, Jason Weston)
Copyright (c) 2006      Idiap Research Institute (Samy Bengio)
Copyright (c) 2001-2004 Idiap Research Institute (Ronan Collobert, Samy Bengio, Johnny Mariethoz)
Copyright (c) 2015      Google Inc.
Copyright (c) 2015      Yangqing Jia
Copyright (c) 2013-2016 The Caffe contributors
All rights reserved.

Various files include modifications (c) NVIDIA CORPORATION & AFFILIATES.  All rights reserved.

This container image and its contents are governed by the NVIDIA Deep Learning Container License.
By pulling and using the container, you accept the terms and conditions of this license:
https://developer.nvidia.com/ngc/nvidia-deep-learning-container-license

2.1.0a0+32f93b1
True
```

- **Script de création** (`create-base-pod.sh`) :
```bash
#!/bin/bash
POD_NAME="cuda-base"
IMAGE_NAME="nvcr.io/nvidia/cuda:12.4.1-runtime-ubuntu22.04"
EXTERNAL_STORAGE="/chemin/vers/disque/externe/podman/pods/\$POD_NAME"

mkdir -p "\$EXTERNAL_STORAGE"
podman pod create --name "\$POD_NAME" --device=nvidia.com/gpu=all
podman run -it --pod "\$POD_NAME" --mount type=bind,source="\$EXTERNAL_STORAGE",destination=/app/data "\$IMAGE_NAME" /bin/
```

### 3.2. Pods Applicatifs

#### 3.2.1 Jupyter_lab

Jupyter_lab a servi de base pour l'etablissement des scripts de base de la section 2
les script suivants on été duppliquer et validés car fonctionnel en section 2
test_start_jupyter_lab.sh => start_jupyter_lab.sh
test_stop_jupyter_lab.sh => stop_jupyter_lab.sh
test_check_jupyter_lab.sh => check_jupyter_lab.sh
 
#### 3.2.2 Stable_diffusion
##### 3.2.2.1 Choix

Explications des Choix
a. Mode Web par Défaut

Le mode web est plus flexible et permet d'accéder à l'interface graphique de Stable Diffusion.
Tu peux toujours utiliser le conteneur en mode bash si nécessaire.

b. Intégration du GPU

--device=nvidia.com/gpu=all : Cette option permet au pod d'accéder aux GPU NVIDIA, ce qui est essentiel pour Stable Diffusion.

b. Stockage Externe

EXTERNAL_STORAGE : Un répertoire de stockage externe est créé et monté dans /app/data à l'intérieur du conteneur. Cela permet de sauvegarder des données supplémentaires si nécessaire.

c. Port 7860

Le port 7860 est le port par défaut pour l'interface web de Stable Diffusion.

d. Montage des Volumes

d'apres l'aorbrescence prevue

├── shared_volumes/      # Dossiers partagés entre pods (images, modèles, workflows)
│   ├── images/          # Images générées par SD/ComfyUI/autres
│   │   ├── stable-diffusion/  # Outputs de Stable Diffusion
│   │   ├── comfyui/          # Outputs de ComfyUI
│   │   └── ...              # Autres outils
│   ├── models/          # Modèles partagés (checkpoints, LoRAs)
│   └── workflows/       # Workflows ComfyUI réutilisables

d.1 Montage des Modèles

├── shared_volumes/      # Dossiers partagés entre pods (images, modèles, workflows)
│   ├── models/          # Modèles partagés (checkpoints, LoRAs)

$WORK_DIR:/workspace/models : Les modèles (checkpoints, LoRAs) sont montés dans /workspace/models à l'intérieur du conteneur.

d.2 Montage des Images Générées

├── shared_volumes/      # Dossiers partagés entre pods (images, modèles, workflows)
│   ├── images/          # Images générées par SD/ComfyUI/autres
│   │   ├── stable-diffusion/  # Outputs de Stable Diffusion

$EXTERNAL_STORAGE:/workspace/images : Les images générées par Stable Diffusion sont montées dans /workspace/images à l'intérieur du conteneur.

e. Variables USER_UID et USER_GID :

Ces variables permettent de récupérer l'UID et le GID de l'utilisateur actuel pour les utiliser dans le conteneur.


f. Option -u $USER_UID:$USER_GID :

Cette option permet de lancer le conteneur avec les mêmes UID et GID que l'utilisateur actuel, ce qui évite les problèmes de permissions.

g. Option --group-add=users :

Ajoute le groupe users à l'utilisateur dans le conteneur, ce qui permet d'accéder aux fichiers avec les bonnes permissions.
Deux volumes sont montés :

##### 3.2.2.2 Utilisation mode Batch (sans interface)

- Principe : Exécuter des commandes directement dans le conteneur via podman exec.
Exemple :
podman exec -it sd_app python3 /app/storage/generate_images.py --prompt "un chat en train de coder" --output /app/storage/output.png

- Cas d'usage : Génération d'images en arrière-plan, traitements automatisés.

##### 3.2.2.3  Utilisation mode Web (avec interface)

- Principe : Mapper un port (ex: 7860) et accéder à l'interface via http://localhost:7860.
Exemple de démarrage :
podman run -dt --pod sd_pod --name sd_web -p 7860:7860 docker.io/automatic1111/stable-diffusion-webui:latest

- Accès : Ouvrir un navigateur à l'adresse http://localhost:7860.

##### 3.2.2.4 Script demarage avec interface web
Ce script crée un pod pour SD, ajoute un conteneur avec les ressources GPU, et monte les volumes nécessaires ainsi que l'interface web.

**Fichier `start_sd.sh`** :
```ini
#!/bin/bash
# Définir le fichier de configuration pour ce pod
export CONTAINERS_STORAGE_CONF=~/.config/containers/storage-pod_sd.conf
# Nom du pod et du conteneur
POD_NAME="pod_sd"
CONTAINER_NAME="app_sd"
WEB_CONTAINER_NAME="web_sd"
PORT=7860
WORK_DIR="/mnt/podman/shared_volumes/models"
EXTERNAL_STORAGE="/mnt/podman/shared_volumes/images/stable-diffusion"
USER_UID=$(id -u)
USER_GID=$(id -g)

# Vérifier si le port est déjà utilisé
if ss -tulnp | grep -q ":${PORT} "; then
    echo "Erreur: Le port ${PORT} est déjà utilisé."
    exit 1
fi

# Supprimer le pod s'il existe déjà
if podman pod exists $POD_NAME; then
    echo "Le pod $POD_NAME existe déjà. Redémarrage..."
    podman pod stop $POD_NAME
    podman pod rm $POD_NAME
fi

# Créer le répertoire de travail s'il n'existe pas
if [ ! -d "$WORK_DIR" ]; then
    echo "Création du répertoire de travail $WORK_DIR"
    sudo mkdir -p "$WORK_DIR"
    sudo chown -R $USER_UID:$USER_GID "$WORK_DIR"
    sudo chmod -R 755 "$WORK_DIR"
fi

# Créer le répertoire de stockage externe s'il n'existe pas
if [ ! -d "$EXTERNAL_STORAGE" ]; then
    echo "Création du répertoire de stockage externe $EXTERNAL_STORAGE"
    sudo mkdir -p "$EXTERNAL_STORAGE"
    sudo chown -R $USER_UID:$USER_GID "$EXTERNAL_STORAGE"
    sudo chmod -R 755 "$EXTERNAL_STORAGE"
fi

# Créer le pod avec le port défini et l'accès au GPU
echo "Création du pod $POD_NAME avec le port $PORT et l'accès au GPU"
podman pod create --name $POD_NAME -p $PORT:7860 --device=nvidia.com/gpu=all --device=/dev/nvidia-uvm --device=/dev/nvidia-uvm-tools --device=/dev/nvidiactl --userns=keep-id

# Démarrer le conteneur Stable Diffusion en mode web avec les volumes montés
echo "Lancement du conteneur $CONTAINER_NAME en mode web"
podman run -dt --pod $POD_NAME --name $CONTAINER_NAME \
  -v "$WORK_DIR:/workspace/models:Z" \
  -v "$EXTERNAL_STORAGE:/workspace/images:Z" \
  -u $USER_UID:$USER_GID \
  --group-add=users \
  --workdir /workspace \
  docker.io/runpod/stable-diffusion:latest

# Démarrer un conteneur avec un serveur web pour Stable Diffusion
echo "Lancement du conteneur $WEB_CONTAINER_NAME pour le serveur web"
podman run -dt --pod $POD_NAME --name $WEB_CONTAINER_NAME \
  -v "$WORK_DIR:/workspace/models:Z" \
  -v "$EXTERNAL_STORAGE:/workspace/images:Z" \
  -u $USER_UID:$USER_GID \
  --group-add=users \
  --workdir /workspace \
  docker.io/runpod/stable-diffusion:latest \
  /bin/bash -c "cd /workspace/stable-diffusion-webui && python3 launch.py --listen --xformers --enable-insecure-extension-access"

# Attendre quelques secondes pour que Stable Diffusion démarre
sleep 30

# Afficher les logs du conteneur web
echo "Logs du conteneur web :"
podman logs $WEB_CONTAINER_NAME

# Afficher l'URL d'accès
echo "Accède à Stable Diffusion via l'URL suivante :"
echo "http://127.0.0.1:${PORT}"


podman pod create --name $POD_NAME -p $PORT:7860 --device=nvidia.com/gpu=all --device=/dev/nvidia-uvm --device=/dev/nvidia-uvm-tools --device=/dev/nvidiactl --userns=keep-id

```

##### 3.2.2.5 Script d'arret avec interface web
Ce script crée un pod pour SD, ajoute un conteneur avec les ressources GPU, et monte les volumes nécessaires ainsi que l'interface web.

**Fichier `stop_sd.sh`** :
```ini
#!/bin/bash

# Nom du pod et du conteneur
POD_NAME="pod_sd"
CONTAINER_NAME="app_sd"

# Vérifier si le pod existe
if ! podman pod exists $POD_NAME; then
    echo "⚠️ Le pod $POD_NAME n'existe pas."
    exit 1
fi

# Afficher les informations du pod avant l'arrêt
echo "Statut actuel du pod $POD_NAME :"
podman pod ps --format "table {{.Name}}\t{{.Status}}"

# Arrêter le conteneur principal proprement
echo "Arrêt du conteneur $CONTAINER_NAME..."
podman stop $CONTAINER_NAME

# Attendre que le conteneur ait bien le temps de s'arrêter
sleep 2

# Arrêter le pod
echo "Arrêt du pod $POD_NAME..."
podman pod stop $POD_NAME

# Attendre que le pod ait bien le temps de s'arrêter
sleep 2

# Supprimer le pod
echo "Suppression du pod $POD_NAME..."
podman pod rm $POD_NAME

echo "🐾 Pod $POD_NAME supprimé avec succès !"

```

#### 3.3. Sauvegarde et Portabilité

Sauvegarder une image :
```bash
podman save -o /chemin/vers/disque/externe/podman/images/mon-image.tar mon-image
```

Recharger une image :
```bash
podman load -i /chemin/vers/disque/externe/podman/images/mon-image.tar
```
Limites :

Les pods ne sont pas exportables directement. Il faudra recréer les pods sur un autre système à partir des images et des scripts.
---
### 4. Points Ouverts à Approfondir
#### 4.1. Compatibilité des Applications

Stable Diffusion/ComfyUI :

Quelles versions veux-tu utiliser ? (ex : SD 1.5, SDXL, ComfyUI custom ?)
Ces versions ont-elles des exigences spécifiques (ex : CUDA 11.8) ?


Action : Lister les dépendances exactes pour chaque application.

#### 4.2. Gestion des Données

Modèles et Outputs :

Où et comment stocker les gros fichiers (checkpoints, LORAs) ?
Comment les partager entre différents pods (si nécessaire) ?


Proposition :

Un dossier /podman/shared/models/ pour les modèles communs ?
Un dossier /podman/pods/<app>/outputs/ pour les résultats ?



#### 4.3. Automatisation Avancée

Scripts vs Kubernetes :

Les scripts Bash suffisent pour l’instant, mais si la complexité augmente, on peut envisager des fichiers YAML (compatible avec podman play kube).
Question : Veux-tu un exemple de fichier YAML pour un pod ?



#### 4.4. Sécurité et Permissions

Mode Rootless :

Podman en rootless a des limitations (ex : ports < 1024, certains devices).
À vérifier : As-tu besoin d’accès privilégiés pour certaines applications ?

---

## 5. Étapes Suivantes Proposées et gestion du document

Valider l’accès GPU dans un conteneur Podman (cf. 1.2).
Créer le pod de base avec CUDA 12.4 et tester le montage du stockage externe.
Discuter de l’organisation des données (modèles, outputs) et des dépendances Python.
Écrire un script pour un pod applicatif (ex : Stable Diffusion).


Notes :

Ce document est évolutif : ajoute tes questions, tes retours d’expérience, ou tes ajustements.
Pour chaque point, on peut approfondir avec des exemples concrets ou des tests.

---

### Comment l’utiliser ?
1. Copie ce contenu dans un fichier `rules-podman.md` sur ton PC.
2. Ajoute tes notes, questions ou modifications directement dans le fichier.
3. Quand tu veux approfondir un point, dis-moi lequel, et on avance étape par étape.

---
**Question pour toi** :
Par quel point veux-tu commencer ? Par exemple :
- Tester l’accès GPU dans un conteneur ?
- Discuter de l’organisation des dossiers sur le disque externe ?
- Écrire le script pour le pod de base ?

---
## **🔹 Prochaines Étapes**
# ✅ PROCHAINES ÉTAPES
- [✅] Section1 : Contraintes et Choix de Base (validée)
  - [✅] Stockage sur Disque Externe Amovible
  - [✅] Rootless or not rootless
  - [✅] Choix de l'image utilisée (image personnalisée, Image de cdrage)
  - [✅] Rootless or not rootless
  - [✅] Accélération GPU
  - [✅] Version de CUDA (Fixée à 12.4)
  - [✅] Bypasse montage automatique ?
- [✅] Section 2 : Configuration/installation Technique (section 2)
  - [✅] Installation podman
    - [✅] Installation / demarrage (rootless)
    - [✅] Installation nvidia-container-toolkit
    - [✅] Test
  - [✅] Installation disque externe
    - [✅] Cération structure
    - [✅] Montage et scripte si non automatique
  - [✅] Vademecum podman
    - [✅] Gestion courrantes
    - [✅] resolution problème
  - [ ] Le build
    - [ ] Mise en place environnement
    - [ ] Construction
    - [ ] Test
- [ ]Automatisation des pod prevu
  - [ ] Stable diffusion
    - [ ] scripts sopt/start mode web /bash
    - [ ] test
  - [ ] ComfyUI
    - [ ] scripts sopt/start mode web /bash
    - [ ] test
  - [ ] cdrage
    - [ ] scripts sopt/start mode web /bash
    - [ ] test
  - [ ] kohya_ss
    - [ ] scripts sopt/start mode web /bash
    - [ ] test
  - [✅] jupyter_lab
    - [✅] scripts sopt/start mode web /bash
    - [✅] test


