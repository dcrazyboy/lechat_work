# Contexte Stable Diffusion - Configuration, Modèles et Workflow

---
# ⚙️ CONTEXTE POUR LE CHAT (À NE PAS MODIFIER)
## 1. Configuration Matérielle et Logicielle

**Contraintes** :
- **Scripting** : Bash, Python 3.11+.
- **OS** : openSUSE LEAP 15.6
- **Carte Graphisue** : NVIDIA GeForce RTX 3070 (8 Go VRAM)
- **Processeur** : AMD Ryzen 7
- **Memoire** : 32G
- **Outils** :  tmux, git, wget, curl, npm
- **Securité** : apparmor
- **reseau** : NetworkManager

### Configuration Validée
- **OS** : openSUSE Tumbleweed (Kernel 6.16.1-1-default)
- **GPU** : NVIDIA RTX 3070 (8 Go VRAM, Driver 580.65.06, CUDA 13.0)
- **RAM** : 32 Go (Swap : 31 Go)
- **Python** : 3.11+
- **Outils** : tmux, git, wget, curl, npm


### Dépôts Actifs (zypper)
# | Alias         | Name                                   | Enabled | GPG Check | Refresh
--+---------------+----------------------------------------+---------+-----------+--------
1 | cuda          | cuda                                   | Oui     | (r ) Oui  | Non
2 | repo-debug    | openSUSE-Tumbleweed-Debug              | Non     | ----      | ----
3 | repo-non-oss  | openSUSE-Tumbleweed-Non-Oss            | Oui     | (r ) Oui  | Oui
4 | repo-openh264 | Open H.264 Codec (openSUSE Tumbleweed) | Oui     | (r ) Oui  | Oui
5 | repo-oss      | openSUSE-Tumbleweed-Oss                | Oui     | (r ) Oui  | Oui
6 | repo-source   | openSUSE-Tumbleweed-Source             | Non     | ----      | ----
7 | repo-update   | openSUSE-Tumbleweed-Update             | Oui     | (r ) Oui  | Oui
8 | vscodium      | vscodium                               | Oui     | (r ) Oui  | Oui


---
# 📝 AIDE-MÉMOIRE (À REMPLIR)

## 📝 Installation Validée
### Prérequis
```bash
#sudo zypper install python310 python310-devel
#curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
#python3.10 get-pip.py

sudo zypper install git wget curl python311 python311-pip python311-devel gcc gcc-c++ make cmake nodejs npm libffi-devel libopenssl-devel readline-devel sqlite3-devel xz-devel libbz2-devel tk-devel libexpat-devel jitterentropy-devel
```
### récuperation de StableSwarmUI

git clone https://github.com/mcmonkeyprojects/SwarmUI.git
chmod +x install-linux.sh

./install-linux.sh

```bash
cd /data
sudo mkdir projets
sudo chown dcrazyboy:root /data/projets/
cd projets
sudo git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git /data/projets/stable-diffusion-webui
cd stable-diffusion-webui
```
### Création de l'environnement virtuel
```bash
python3.11 -m venv venv
source venv/bin/activate
```
### Installation de PyTorch xformers et dépendances
```bash
# mettre a niveau pip et wheel
pip install --upgrade pip wheel

# Installe PyTorch, torchvision, et torchaudio en version 2.3.0 pour CUDA 12.1
pip install torch==2.5.1 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

# Installe xformers depuis la source pour éviter les conflits de version
pip install xformers==0.0.28.post3 --no-cache-dir

# Installe les dépendances restantes depuis le fichier requirements.txt
pip install -r requirements.txt

```
### Vérification des versions
```bash
# Affiche les versions de torch et xformers installées
pip list | grep -E "torch|xformers"

# Vérifie que PyTorch utilise bien CUDA
python3.11 -c "import torch; print('PyTorch version:', torch.__version__, '| CUDA available:', torch.cuda.is_available())"

```
## ⚡ Résolution des Problèmes de Versions
### Problème
Les versions installées de torch et torchvision ne correspondent pas à celles attendues.
Solution

#### Désinstaller les versions actuelles :
```bash
pip uninstall torch torchvision torchaudio
```
#### Réinstaller les versions correctes :
```bash
pip install torch==2.5.0 torchvision==0.18.0 torchaudio==2.5.0 --index-url https://download.pytorch.org/whl/cu121
```
Vérifier les versions après réinstallation.


## 🔄 Lancement initial de Stable Diffusion
### Clonage et Lancement
```bash
./webui.sh --xformers --medvram --opt-sdp-attention --disable-nan-check
```
Au premeir alncement, StableDiffusion charge un modele
v1-5-pruned-emaonly.safetensors et demarre l'inteface sur  : URL:  http://127.0.0.1:7860

### 🛠️ Scripts de Démarrage/Arrêt manuels

#### Script de Démarrage (start_sd.sh)
**Fichier `~/scripts/start_sd.sh`** : 
```ini
#!/bin/bash
# Script de démarrage optimisé pour Stable Diffusion
SD_WEBUI_DIR="/data/projets/stable-diffusion-webui"

# Vérifie et clone uniquement si le dossier n'existe pas
if [ ! -d "$SD_WEBUI_DIR" ]; then
    echo "Clonage initial du dépôt..."
    git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git "$SD_WEBUI_DIR"
fi

# Se place dans le dossier et met à jour
cd "$SD_WEBUI_DIR" || exit
git pull

# Active l'environnement virtuel
source venv/bin/activate

# Lance l'interface avec tes flags
./webui.sh --xformers --medvram --opt-sdp-attention --disable-nan-check
```
#### Script d'Arrêt (stop_sd.sh)
**Fichier `~/scripts/stop_sd.sh`** : 
```ini
#!/bin/bash
# Script d'arrêt de Stable Diffusion
pkill -f "webui.sh"
pkill -f "python.*launch.py"
```
#### Script de Redémarrage (restart_sd.sh)
**Fichier `~/scripts/restart_sd.sh`** : 
```ini
#!/bin/bash
# Script de redémarrage de Stable Diffusion
/data/projets/stable-diffusion-webui/stop_sd.sh
sleep 2
/data/projets/stable-diffusion-webui/start_sd.sh
```
#### Nepas oublier ###
rendre les script executables
Rendre les Scripts Exécutables
```bash
chmod +x ~/scripts/*
```
## 🔄 Gestion avec Tmux  : utilisation en tâche de fond 

Détacher : Ctrl+B puis D
Revenir : tmux attach -t sd_session
Tuer : tmux kill-session -t sd_session

### Exemple flux tmux
#### Demarage initial
```bash
tmux new -s sd_session
~/scripts/start_sd.sh
```
### Arrêter le Script sans tuer la session
```bash
pkill -f "webui.sh"  # Tue tous les processus liés
```
ou (si besoin de cibler un PID spécifique) :
```bash
kill $(pgrep -f "webui.sh")
```
ou par tmux
```bash
tmux send-keys -t sd_session C-c
```

### Redémarrer le Script
```bash
tmux send-keys -t sd_session "~/scripts/start_sd.sh" Enter
```

### Script de Redémarrage Automatisé
```bash
#!/bin/bash
tmux send-keys -t sd_session C-c  # Interrompt le processus actuel
sleep 2
tmux send-keys -t sd_session "./webui.sh --xformers --medvram --opt-sdp-attention --disable-nan-check" Enter
```
ou
```bash
tmux send-keys -t sd_session "~/scripts/restart_sd.sh" Enter
```
## 📝 utilisation en tâche de fond (solution possible)

Avec screen
```bash
screen -S sd_session
~/stable-diffusion-webui/start_sd.sh
# Détacher : Ctrl+A puis D
# Revenir : screen -r sd_session
# Tuer : screen -X -S sd_session quit
```
Avec tmux
```bash
tmux new -s sd_session
~/stable-diffusion-webui/start_sd.sh
# Détacher : Ctrl+B puis D
# Revenir : tmux attach -t sd_session
# Tuer : tmux kill-session -t sd_session
```

## 🔧 Gestion de la Surchauffe
### Surveillance
```bash
sudo apt install nvtop
nvtop
```
### Limitation de Puissance
```bash
sudo nvidia-smi -pl 100  # Limite à 100W
```

## 🛠️ installation des modeles
### Choix possibles
📌 Modèles Photorealistes (Génération + img2img)

#### Modèles "Base" (Stables et Polyvalents)
|                 Model | Taille | Source       | notes pour 8G de VRAM
|:-----------------------:|:--------:|:--------------:|:-----------------------------------------------------:|
| Realistic Vision V5.0 |  ~4 Go | CivitAI      | Excellente fidélité photorealiste. Utilise --medvram.
| Juggernaut XL v8      |  ~5 Go | CivitAI      | Version "light" disponible. Résolution max : 768x768.
| Photon v1             |  ~4 Go | CivitAI      | Spécialisé portraits/paysages.
|SD 1.5 (Realistic)     |  ~4 Go | Hugging Face | Classique, bien optimisé.


#### Modèles "Haute Qualité" (Plus Gourmands mais Gérables)
|                 Model | Taille | Source       | notes pour 8G de VRAM
|:-----------------------:|:--------:|:--------------:|:-----------------------------------------------------:|
|SDXL 1.0               | ~6-7Go | Hugging Face | Utilise --no-half-vae et limite à 512x512.
|RealVisXL V2.0         |  ~6 Go | CivitAI      | Version "turbo" pour moins de VRAM.

#### Modèles Spécialisés (Paysages, Portraits)
|                 Model  | specialisation           | lien    | notes pour 8G de VRAM
|:------------------------:|:--------------------------:|:---------:|:-----------------------------------------:|
| EpicRealism            | Portraits hyperréalistes | CivitAI | Idéal pour img2img sur visages.
| Landscapism            | Paysages photorealistes  | CivitAI | Optimisé pour les scènes naturelles.

#### Lien de chargement
|                 Model | Taille | Source       | notes pour 8G de VRAM
|:-----------------------:|:--------:|:--------------:|:-----------------------------------------------------:|
| Realistic Vision V5.0 | https://civitai.com/models/4201/realistic-vision-v50
| Juggernaut XL v8      | https://civitai.com/models/133005/juggernaut-xl
| Photon v1             | https://civitai.com/models/11340/photon-v1
| SD 1.5 (Realistic)    | https://huggingface.co/runwayml/stable-diffusion-v1-5
| SDXL 1.0              | https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0
| RealVisXL V2.0        | https://civitai.com/models/146688/realvisxl-v20
| EpicRealism           | https://civitai.com/models/25853/epicrealism
| Landscapism           | https://civitai.com/models/11960/landscapism => remove by owner


#### 🔍 Conseils pour le Téléchargement

- Format : Préfère les fichiers .safetensors (plus sûrs et souvent plus légers).
- Emplacement : Place les modèles dans : ~/stable-diffusion-webui/models/Stable-diffusion/

Commande de téléchargement (exemple pour Realistic Vision) :
```bash
cd ~/stable-diffusion-webui/models/Stable-diffusion/
wget https://civitai.com/api/download/models/4201 -O realisticVisionV50.safetensors
```


#### ⚠️ Modèles à Éviter (Trop Gourmands ou Non Photorealistes)

Anime : Anything V3/V4, Counterfeit, etc.
3D/Style Artistique : Lyriel, OpenJourney.
Modèles >7 Go : Certains LoRA/embeddings non optimisés.
SDXL Turbo (trop gourmand).
Modèles non optimisés (> 7 Go).
Versions complètes non "pruned".

#### 📂 Fichier modele uploadé
- `Realistic_Vision_V5.0.safetensors`.
- `Juggernaut-XL_v9_RunDiffusionPhoto_v2`.
- `sd_xl_base_1.0_0.9vae.safetensors`.
- `mixrealV1_mixrealV1.safetensors`.




## 📂 Modèles Testés

---
### 🔹 Realistic Vision V5.0 
#### 1. **Informations Générales**
- **Type** : Photorealiste (portraits/paysages).
- **Taille** : 4 Go.
- **Lien** : [Hugging Face](https://huggingface.co/SG161222/Realistic_Vision_V5.0_noVAE).
- **Fichier** : `Realistic_Vision_V5.0.safetensors`.
- **Chargement** : ✅

#### 2. **Paramètres de Base (Génération)**
| Paramètre          | Valeur Recommandée | Notes                                  |
|--------------------|--------------------|----------------------------------------|
| **Sampler**        | DPM++ 2M Karras    | Équilibre qualité/vitesse.            |
| **Résolution**     | 512x768            | Max pour 8 Go VRAM.                    |
| **CFG Scale**      | 7-9                | Évite les artéfacts.                  |
| **Steps**          | 20-30              | Suffisant pour des détails nets.      |
| **Batch Size**     | 1                  | Obligatoire pour 8 Go VRAM.            |

Euler A or DPM++ 2M Karras
CFG Scale 3,5 - 7
Hires. fix with 4x-UltraSharp upscaler
0 Hires steps and Denoising strength 0.25-0.7
Upscale by 1.1-2.0

The recommended negative prompt:

(deformed iris, deformed pupils, semi-realistic, cgi, 3d, render, sketch, cartoon, drawing, anime:1.4), text, close up, cropped, out of frame, worst quality, low quality, jpeg artifacts, ugly, duplicate, morbid, mutilated, extra fingers, mutated hands, poorly drawn hands, poorly drawn face, mutation, deformed, blurry, dehydrated, bad anatomy, bad proportions, extra limbs, cloned face, disfigured, gross proportions, malformed limbs, missing arms, missing legs, extra arms, extra legs, fused fingers, too many fingers, long neck

OR

(deformed iris, deformed pupils, semi-realistic, cgi, 3d, render, sketch, cartoon, drawing, anime, mutated hands and fingers:1.4), (deformed, distorted, disfigured:1.3), poorly drawn, bad anatomy, wrong anatomy, extra limb, missing limb, floating limbs, disconnected limbs, mutation, mutated, ugly, disgusting, amputation

#### 3. **Commande de Lancement**
```bash
./webui.sh --xformers --medvram --opt-sdp-attention
```
http://127.0.0.1:7860/file=/data/projets/stable-diffusion-webui/outputs/txt2img-images/2025-09-09/00035-1236226699.png?1757372647.8473377
#### 4. **Exemples de Prompts Testés**
- **Portrait** :
  `"a photorealistic portrait of a 30-year-old cyborg man, detailed skin texture, 8k, cinematic lighting, --ar 9:16"`
A hyper-detailed photorealistic full-body standing 20-year-old cyborg man, intricate mechanical limbs, glowing neon circuits, cinematic RGB lighting, metallic textures, 8k, ultra HD, --ar 16:9, trending on artstation, unreal engine 5

A hyper-detailed photorealistic full-body standing 20-year-old cyborg man, intricate biomechanical limbs with exposed hydraulic pistons, glowing neon circuits (pink, green, blue), cinematic RGB backlighting, reflective metallic textures, futuristic exoskeleton, ultra HD 8k, symmetrical face, trending on artstation, unreal engine 5, octane render, unreal engine 5 --ar 16:9

- **Paysage** :
  `"a breathtaking photorealistic landscape of a mountain lake at sunset, hyper-detailed, 8k, --ar 16:9"`

#### 5. **Résultats et Notes**
- **Qualité** : [Note/10].
- **Problèmes** : [ex: "Aucun en 512x768"].
- **Exemple d'image générée** : [Lien ou chemin].
- **Paramètres optimaux** : [À remplir après tests].

#### 6. **Paramètres Spécifiques pour img2img**
| Paramètre               | Valeur          |
|-------------------------|-----------------|
| **Denoising Strength**  | 0.5-0.6         |
| **Prompt**              | `"add more details, hyperrealistic"` |

---
### 🔹 Juggernaut XL v8 
#### 1. **Informations Générales**
- **Type** : Photorealiste (style cinématographique).
- **Taille** : 6.6 Go.
- **Lien** : [Hugging Face](https://huggingface.co/RunDiffusion/Juggernaut-XL-v9).
- **Fichier** : `realisticVisionV50.safetensors`.
- **Chargement** : ✅

#### 2. **Paramètres de Base (Génération)**
| Paramètre          | Valeur Recommandée | Notes                                  |
|--------------------|--------------------|----------------------------------------|
| **Sampler**        | DPM++ 2M Karras    | [Notes].                               |
| **Résolution**     | 512x768            | Max pour 8 Go VRAM.                    |
| **CFG Scale**      | 7-9                | [Notes].                               |
| **Steps**          | 20-30              | [Notes].                               |
| **Batch Size**     | 1                  | Obligatoire pour 8 Go VRAM.            |

#### 3. **Commande de Lancement**
```bash
./webui.sh --xformers --medvram --opt-sdp-attention
```

#### 4. **Exemples de Prompts Testés**
- **Prompt 1** :
  `""`
- **Prompt 2** :
  `""`

#### 5. **Résultats et Notes**
- **Qualité** : [Note/10].
- **Problèmes** : [ex: ""].
- **Exemple d'image générée** : [Lien ou chemin].
- **Paramètres optimaux** : [À remplir après tests].

#### 6. **Paramètres Spécifiques pour img2img**
| Paramètre               | Valeur          |
|-------------------------|-----------------|
| **Denoising Strength**  | [ex: 0.5-0.6]   |
| **Prompt**              | `""`            |

---
### 🔹 Photon v1
#### 1. **Informations Générales**
- **Type** : Photorealiste (portraits/paysages).
- **Taille** : 4 Go.
- **Lien** : [CivitAI](https://civitai.com/models/27683/mixrealv1).
- **Fichier** : `mixrealV1_mixrealV1.safetensors`.

#### 2. **Paramètres de Base (Génération)**
| Paramètre          | Valeur Recommandée | Notes                                  |
|--------------------|--------------------|----------------------------------------|
| **Sampler**        | [ex: DPM++ 2M Karras] | [Notes].                               |
| **Résolution**     | [ex: 512x768]      | Max pour 8 Go VRAM.                    |
| **CFG Scale**      | [ex: 7-9]          | [Notes].                               |
| **Steps**          | [ex: 20-30]        | [Notes].                               |
| **Batch Size**     | 1                  | Obligatoire pour 8 Go VRAM.            |

#### 3. **Commande de Lancement**
```bash
./webui.sh --xformers --medvram --opt-sdp-attention
```

#### 4. **Exemples de Prompts Testés**
- **Prompt 1** :
  `""`
- **Prompt 2** :
  `""`

#### 5. **Résultats et Notes**
- **Qualité** : [Note/10].
- **Problèmes** : [ex: ""].
- **Exemple d'image générée** : [Lien ou chemin].
- **Paramètres optimaux** : [À remplir après tests].

#### 6. **Paramètres Spécifiques pour img2img**
| Paramètre               | Valeur          |
|-------------------------|-----------------|
| **Denoising Strength**  | [ex: 0.5-0.6]   |
| **Prompt**              | `""`            |

---
### 🔹 SDXL 1.0
#### 1. **Informations Générales**
- **Type** : Photorealiste (haute qualité).
- **Taille** : 6-7 Go.
- **Lien** : [Hugging Face](https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0).
- **Fichier** : `sd_xl_base_1.0_0.9vae.safetensors`.
- **Chargement** : ✅
https://civitai.com/models/424460/paradox-3-sd-xl-10
paradox3SDXL10_paradox3SDXL10.safetensors

#### 2. **Paramètres de Base (Génération)**
| Paramètre          | Valeur Recommandée | Notes                                  |
|--------------------|--------------------|----------------------------------------|
| **Sampler**        | DPM++ 2M Karras    | [Notes].                               |
| **Résolution**     | 512x512            | Limité pour 8 Go VRAM.                |
| **CFG Scale**      | 7-9                | [Notes].                               |
| **Steps**          | 20-30              | [Notes].                               |
| **Batch Size**     | 1                  | Obligatoire pour 8 Go VRAM.            |

#### 3. **Commande de Lancement**
```bash
./webui.sh --xformers --medvram --no-half-vae
```

#### 4. **Exemples de Prompts Testés**
- **Prompt 1** :
  `""`
- **Prompt 2** :
  `""`

#### 5. **Résultats et Notes**
- **Qualité** : [Note/10].
- **Problèmes** : [ex: "Nécessite --no-half-vae"].
- **Exemple d'image générée** : [Lien ou chemin].
- **Paramètres optimaux** : [À remplir après tests].

#### 6. **Paramètres Spécifiques pour img2img**
| Paramètre               | Valeur          |
|-------------------------|-----------------|
| **Denoising Strength**  | [ex: 0.4-0.5]   |
| **Prompt**              | `""`            |

---
## 🔄 Workflows et Comparatifs
*(À remplir après tes tests.)*

---
### 1. **Tableau Comparatif des Modèles**
| Modèle               | VRAM (8 Go) | Résolution Max | Qualité img2img | Notes                     |
|----------------------|-------------|-----------------|------------------|---------------------------|
| Realistic Vision V5  | ✅ (4 Go)   | 768x768         | [Note/10]        | [Notes].                   |
| Juggernaut XL v8     | ⚠️ (5 Go)   | 768x512         | [Note/10]        | [Notes].                   |

---
### 2. **Bonnes Pratiques**
- **Pour img2img** : Toujours commencer avec un `denoising strength` de 0.5.
- **Économiser la VRAM** : Désactiver les extensions inutiles.

---
### 3. **Exemples de Prompts Universels**
*(Liste de prompts testés et validés pour tous les modèles.)*




## 12.  Prochaines Étapes**
1# ✅ PROCHAINES ÉTAPES
- [✅] Valider le fichier de règle Valider le 26/08/205
- [✅] installer Stable_diffusion Valider le 27/08/2025  
- [✅] test lancement/arret Valider le 27/08/2025
- [ ] Installer les model
- [ ] Test général
- [ ] Tester un modèle spécifique.
- [ ] Optimiser un prompt.
- [ ] Configurer des LORA ou ControlNet.
- [ ] Automatiser des tâches.


---

### **Comment utiliser ce fichier ?**
1. Copie ce contenu dans un fichier nommé `sd_rulest.md`.
2. Partage-le avec moi pour nos prochaines sessions.
3. On pourra le mettre à jour ensemble au fur et à mesure.

---
**Question** :
Est-ce que cette version te convient ? Veux-tu ajouter ou modifier quelque chose ? 😊