Voici la version complète et réorganisée du fichier Markdown, intégrant toutes les informations, y compris les modèles recommandés, les scripts de démarrage/arrêt, et les optimisations pour 8 Go de VRAM.

# Contexte Stable Diffusion - Configuration, Modèles et Workflow

---
# ⚙️ CONTEXTE POUR LE CHAT (À NE PAS MODIFIER)
## 1. Configuration Matérielle et Logicielle

### Matériel
- **PC Portable** :
  - Processeur : AMD Ryzen 7
  - Carte graphique : NVIDIA GeForce RTX 3070 (8 Go VRAM)
  - VRAM disponible : 8192 MiB
  - Driver NVIDIA : 580.76.05
  - CUDA Version : 13.0

### OS
- **Linux** : openSUSE Tumbleweed
- Kernel : 6.16.1-1-default

### Mémoire Système
```plaintext
MemTotal:       32095200 kB (~32 Go de RAM)
MemFree:        13312348 kB
MemAvailable:   20282992 kB
SwapTotal:      31457276 kB (~31 Go de swap)
```
---
# 📝 AIDE-MÉMOIRE (À REMPLIR)
## 1. Étapes d'Installation Validées
### Prérequis
```bash
sudo zypper install python310 python310-devel
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python3.10 get-pip.py

sudo zypper install gcc-c++ make git # libopenblas-dev
sudo zypper install libopenblas_serial-devel
```
### Nettoyage de l'environnement (si besoin)
```bash
deactivate
rm -rf venv
```
## récuperation de stable difusion
```bash
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git ~/stable-diffusion-webui
cd ~/stable-diffusion-webui
```
### Création de l'environnement virtuel
```bash
python3.10 -m venv venv
source venv/bin/activate
```
## Installation de PyTorch et dépendances
```bash
# Installe PyTorch, torchvision, et torchaudio en version 2.3.0 pour CUDA 12.1
pip install torch==2.3.0 torchvision==0.18.0 torchaudio==2.3.0 --index-url https://download.pytorch.org/whl/cu121

# Installe xformers depuis la source pour éviter les conflits de version
pip install xformers==0.0.20

# Installe les dépendances restantes depuis le fichier requirements.txt
pip install -r requirements.txt

```
## Vérification des versions
```bash
# Affiche les versions de torch et xformers installées
pip list | grep -E "torch|xformers"

# Vérifie que PyTorch utilise bien CUDA
python3.10 -c "import torch; print('PyTorch version:', torch.__version__, '| CUDA available:', torch.cuda.is_available())"

```
## 2. Résolution des Problèmes de Versions
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


## 3. Lancement de Stable Diffusion
```bash
./webui.sh --xformers --medvram --opt-sdp-attention --disable-nan-check
```
## 4. Paramètres de Génération Recommandés
### Exemple de Prompt SDXL
```plaintext
A cyberpunk basement room with neon lights, concrete walls, a high-tech desk with PCs, a young man in VR, cinematic lighting, --ar 16:9 --w 768 --h 768
```
Paramètres

Steps : 20–30
Sampler : DPM++ 2M Karras
CFG Scale : 7–10


## 5. Gestion de la Surchauffe
### Surveillance
```bash
sudo apt install nvtop
nvtop
```
### Limitation de Puissance
```bash
sudo nvidia-smi -pl 100  # Limite à 100W
```
### Refroidissement
Utiliser un support de refroidissement pour éviter le thermal throttling.

## 6. Modèles Recommandés pour 8 Go de VRAM

### Modèle Minimal Recommandé

Stable Diffusion 1.5 (Pruned/EMAonly)

Taille : ~2-4 Go (version "pruned" optimisée).
Avantages :

Très léger, compatible avec 8 Go de VRAM.
Bonne qualité pour les bases (portraits, paysages, objets).
Rapide à charger et à utiliser.


Lien de téléchargement :

v1-5-pruned-emaonly.safetensors (déjà téléchargé automatiquement par l'installation).


Dossier de destination :
```plaintext
~/stable-diffusion-webui/models/Stable-diffusion/
```
### Autres Modèles Optimisés
| Paramètre | Valeur recommandée | Explication |
| :---- | :-----| :----- |
| Stable Diffusion model | Realistic Vision V6.0 (ou SD 1.5) | Modèle optimisé pour le réalisme et compatible avec 8 Go de VRAM. |
| Sampler,DPM++ | 2M Karras | Bon compromis qualité/vitesse pour les GPU limités.|
| Steps | 25-30 | Suffisant pour un bon rendu sans surcharger la VRAM.|
| CFG Scale |7-9 | Équilibre entre créativité et cohérence.|
| Resolution | 768x512 (ou 768x768 max) | Évite les erreurs de mémoire avec 8 Go de VRAM.|
| Batch count | 1 | Génère une image à la fois pour économiser la mémoire.|
| Batch size | 1 | Idem.|
| Enable HR Fix | Désactivé | Consomme trop de VRAM.|
| Denoising strength | 0.3-0.5 (si tu utilises img2img) | Pour les retouches légères.|

## 7. Téléchargement et Installation des Modèles
### Étape 1 : Télécharger le Modèle


#### Depuis CivitAI :

Va sur la page du modèle (ex: Realistic Vision V6.0). : https://civitai.com/models/4201/realistic-vision-v60
Clique sur Download (choisis la version .safetensors si disponible).
Place le fichier dans ~/stable-diffusion-webui/models/Stable-diffusion/.

#### Depuis Hugging Face :

Va sur la page du modèle (ex: SDXL 1.0). https://huggingface.co/hakurei/anime-diffusion-1.3
Télécharge le fichier .safetensors ou .ckpt.
Place-le dans le même dossier que ci-dessus.

### Étape 2 : Vérifier le Modèle dans l'Interface

Lance Stable Diffusion avec ton script :
~/stable-diffusion-webui/start_sd.sh

Dans l'interface web (http://127.0.0.1:7860), vérifie que le modèle apparaît dans la liste déroulante Stable Diffusion checkpoint.


## 8. Optimisations pour 8 Go de VRAM
### Pour SDXL 1.0

Résolution max : 768x768 (au lieu de 1024x1024).
Steps : 20-30 (au lieu de 50).
Sampler : DPM++ 2M Karras.
Flags de lancement :
./webui.sh --medvram --opt-sdp-attention --disable-nan-check --precision full --no-half


### Pour les Autres Modèles

Utilise les mêmes flags que ci-dessus.
Active xformers si installé (sinon, --medvram suffit).


## 9. Exemple de Prompt Optimisé pour Realistic Vision V6.0
A highly detailed photorealistic portrait of a young woman, cinematic lighting, 8k, ultra HD, sharp focus, intricate details, --ar 16:9 --v 6.0

Paramètres recommandés :

Steps : 30
CFG Scale : 7
Sampler : Euler a

## 10. Modèles à Éviter avec 8 Go de VRAM

SDXL Turbo (trop gourmand).
Modèles non optimisés (> 7 Go).
Versions complètes non "pruned".


## 11. Scripts de Démarrage/Arrêt
Script de Démarrage (start_sd.sh)
**Fichier `~/start_sd.sh`** : 
```ini
#!/bin/bash
# Script de démarrage de Stable Diffusion
cd /home/dcrazyboy/stable-diffusion-webui || exit
source venv/bin/activate
./webui.sh --medvram --opt-sdp-attention --disable-nan-check --precision full --no-half
```
Script d'Arrêt (stop_sd.sh)
**Fichier `~/stop_sd.sh`** : 
```ini
#!/bin/bash
# Script d'arrêt de Stable Diffusion
pkill -f "webui.sh"
pkill -f "python.*launch.py"
```
Rendre les Scripts Exécutables
```bash
chmod +x ~/stable-diffusion-webui/start_sd.sh
chmod +x ~/stable-diffusion-webui/stop_sd.sh
```
Script de Redémarrage (restart_sd.sh)
**Fichier `~/restart_sd.sh`** : 
```ini
#!/bin/bash
# Script de redémarrage de Stable Diffusion
~/stable-diffusion-webui/stop_sd.sh
sleep 2
~/stable-diffusion-webui/start_sd.sh
```
## 12. Utilisation de screen ou tmux
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
## 12.  Prochaines Étapes**
1# ✅ PROCHAINES ÉTAPES
- [X] Valider le fichier de règle Valider le 26/08/205
- [ ] Installer python et SD 
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