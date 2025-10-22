
# Stable Diffusion - Guide des Modèles Photorealistes (8 Go VRAM)

---
## ⚙️ Contexte et Configuration
*(Section existante : matériel, logiciels, optimisations VRAM - à compléter avec tes informations.)*

---
## 📂 Modèles Testés

---
### 🔹 Realistic Vision V5.0
#### 1. **Informations Générales**
- **Type** : Photorealiste (portraits/paysages).
- **Taille** : 4 Go.
- **Lien** : [CivitAI](https://civitai.com/models/4201/realistic-vision-v50).
- **Fichier** : `realisticVisionV50.safetensors`.

#### 2. **Paramètres de Base (Génération)**
| Paramètre          | Valeur Recommandée | Notes                                  |
|--------------------|--------------------|----------------------------------------|
| **Sampler**        | DPM++ 2M Karras    | Équilibre qualité/vitesse.            |
| **Résolution**     | 512x768            | Max pour 8 Go VRAM.                    |
| **CFG Scale**      | 7-9                | Évite les artéfacts.                  |
| **Steps**          | 20-30              | Suffisant pour des détails nets.      |
| **Batch Size**     | 1                  | Obligatoire pour 8 Go VRAM.            |

#### 3. **Commande de Lancement**
```bash
./webui.sh --xformers --medvram --opt-sdp-attention
```

#### 4. **Exemples de Prompts Testés**
- **Portrait** :
  `"a photorealistic portrait of a 30-year-old woman, detailed skin texture, 8k, cinematic lighting, --ar 9:16"`
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
- **Taille** : 5 Go.
- **Lien** : [CivitAI](https://civitai.com/models/133005/juggernaut-xl).
- **Fichier** : `juggernautXL_v8.safetensors`.

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
- **Lien** : [CivitAI](https://civitai.com/models/11340/photon-v1).
- **Fichier** : `photon_v1.safetensors`.

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
- **Fichier** : `sd_xl_base_1.0.safetensors`.

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



Modèles Recommandés pour img2img Complexe
🔹 Modèles "Tout-en-Un" (Généralistes)
stabilityai/stable-diffusion-2-12.5 GoBon équilibre qualité/mémoire.Hugging FaceUtilise --medvram. Résolution max : 768x768.runwayml/stable-diffusion-v1-54 GoTrès stable pour img2img.Hugging FaceIdéal pour les détails complexes.andite/anything-v4.02.5 GoSpécialisé anime/manga, mais bon pour les détails.Hugging FaceRéduit le denoising strength à 0.5-0.7.
🔹 Modèles Spécialisés (Si Besoin)
stabilityai/stable-diffusion-xl-refiner-1.0Améliore les détails (à utiliser en 2ème passe).Hugging FaceNécessite plus de VRAM, mais peut être combiné avec SDXL base.Lykon/DreamShaperDétails réalistes/artistiques.CivitAIVersion 7 ou 8 recommandée.

2. Paramètres Clés pour img2img sur 8 Go VRAM
📌 Paramètres de Lancement
Utilise toujours ces flags dans webui.sh :
./webui.sh --xformers --medvram --opt-sdp-attention --disable-nan-check
📌 Paramètres dans l’UI (Onglet img2img)
Denoising strength0.5 à 0.75Évite de trop modifier l’image source (risque d’artéfacts).SamplerDPM++ 2M Karras ou Euler aMoins gourmands en VRAM.Résolution≤ 768x768 (ou 512x512 pour SDXL)Évite les crashes OOM.Batch size1Obligatoire pour 8 Go VRAM.CFG Scale7 à 10Équilibre entre fidélité et créativité.

3. Workflow Optimisé pour img2img Complexe


Prétraitement :

Utilise des images sources nettes et bien éclairées (évite les flous).
Redimensionne l’image source à la résolution cible (ex : 768x768) avant de l’uploader.



Premier Passage :

Modèle : stable-diffusion-2-1 ou DreamShaper.
Denoising strength : 0.6.
Prompt : Décris précisément les éléments à conserver/modifier (ex : "a detailed cyberpunk city, neon lights, highly detailed, 8k").



Deuxième Passage (Optionnel) :

Si besoin de plus de détails, utilise un refiner (ex : SDXL Refiner) avec un denoising strength de 0.3-0.4.




4. Exemple de Commande pour Télécharger DreamShaper
cd ~/stable-diffusion-webui/models/Stable-diffusion/
wget https://civitai.com/api/download/models/128713 -O dreamshaper_8.safetensors

5. Gestion de la VRAM

Si crash :

Réduis la résolution à 512x512.
Désactive les extensions gourmandes (ex : ControlNet).
Utilise --opt-split-attention (expérimental, peut aider).




6. Comparatif Rapide
Architecture complexestable-diffusion-2-1Résolution 768x768, denoising 0.6Paysage ultra-détailléDreamShaper 8CFG 9, sampler DPM++ 2M KarrasIllustration animeanything-v4.0Denoising 0.5, prompt très descriptif