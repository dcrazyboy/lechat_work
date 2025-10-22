# Model et test
## 5. Paramètres de Génération Recommandés
### Exemple de Prompt SDXL
```plaintext
A cyberpunk basement room with neon lights, concrete walls, a high-tech desk with PCs, a young man in VR, cinematic lighting, --ar 16:9 --w 768 --h 768
```
Paramètres

Steps : 20–30
Sampler : DPM++ 2M Karras
CFG Scale : 7–10

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
| Sampler| DPM++ 2M Karras | Bon compromis qualité/vitesse pour les GPU limités.|
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





