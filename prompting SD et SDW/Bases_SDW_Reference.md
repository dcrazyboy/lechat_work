# Référence des Paramètres de Base pour Stable Diffusion WebUI (SDW)

## Paramètres Clés
| Paramètre       | Description                                                                 | Valeurs Recommandées                     |
|-----------------|-----------------------------------------------------------------------------|-------------------------------------------|
| **CFG Scale**   | Contrôle la fidélité au prompt (trop haut = artefacts, trop bas = flou).    | 7-12 (équilibre), 15-20 (style artistique).|
| **Steps**       | Nombre d’itérations pour affiner l’image.                                  | 20-30 (rapide), 40-50 (détails).          |
| **Sampler**     | Algorithme de génération (impacte le style et la netteté).                 | Euler a (équilibre), DPM++ 2M Karras (détails). |
| **Seed**        | Graine aléatoire pour la reproductibilité.                                  | `-1` (aléatoire), ou fixe (ex: `123456789`). |
| **Resolution**  | Taille de l’image (impacte les proportions).                               | 512x768 (portrait), 768x512 (paysage).     |
| **Model**       | Checkpoint utilisé (détermine le style de base).                            | RealisticVision (réalisme), CyberpunkAnime (manga). |

## Mots-Clés Techniques
- **Qualité** : `8K`, `ultra HD`, `sharp focus`, `intricate details`.
- **Éclairage** : `cinematic lighting`, `neon glow`, `moonlight`, `dramatic shadows`.
- **Textures** : `weathered stone`, `rusty metal`, `glowing circuits`, `cracked glass`.
- **Negative Prompts** : `blurry`, `deformed`, `low quality`, `extra limbs`, `watermark`.

## Ressources Utiles
- [Stable Diffusion Wiki (Automatic1111)](https://github.com/AUTOMATIC1111/stable-diffusion-webui/wiki)
- [Guide des Samplers (CivitAI)](https://civitai.com/articles/123-samplers-explained)
- [Glossaire des termes SD](https://stable-diffusion-art.com/glossary/)

## notes de cours

### seed
1. Qu’est-ce qu’une seed ?

Une seed (ou "graine") est un nombre aléatoire qui initialise le processus de génération d’image.
Elle détermine la disposition de base des éléments dans l’image (visages, paysages, objets, etc.).
Même seed + même prompt + mêmes paramètres = même image (à quelques variations mineures près).


2. Validité de la seed


La seed n’est pas liée à une session active :

Une fois qu’une image est générée avec une seed spécifique, tu peux réutiliser cette seed plus tard (même après avoir fermé SDW ou redémarré ton ordinateur).
Exemple : Si tu génères une image avec seed=123456789 aujourd’hui, et que tu réutilises seed=123456789 dans 1 mois avec le même prompt et les mêmes paramètres, tu obtiendras la même image.



Ce qui peut changer le résultat :

Si tu modifies le prompt, les paramètres (CFG, steps, sampler), ou le modèle (checkpoint), l’image sera différente, même avec la même seed.
Si tu utilises une version différente de Stable Diffusion (ex : passage de SD 1.5 à SDXL), la seed peut donner un résultat différent.




3. Comment utiliser la seed pour faire évoluer une image ?


Faire évoluer une image ne signifie pas que la seed "mémorise" l’image précédente. C’est à toi de guider l’évolution en modifiant :

Le prompt : Ajoute ou retire des détails.
Les paramètres : Change le CFG, le sampler, ou le nombre de steps.
Les LORAs/embeddings : Pour ajouter des styles spécifiques.



Exemple concret :

Image de base :

Prompt : "A cyberpunk punk with a cybernetic arm, neon alley, --seed 123456789".


Évolution :

Nouveau prompt : "A cyberpunk punk with a cybernetic arm and glowing tattoos, neon alley, rainy atmosphere, --seed 123456789".
Résultat : L’image gardera la même pose et structure de base, mais avec les nouveaux détails (tatouages lumineux, pluie).