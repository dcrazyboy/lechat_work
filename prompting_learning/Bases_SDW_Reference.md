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
#### Qu’est-ce qu’une seed ?
Une seed (ou "graine") est un nombre aléatoire qui initialise le processus de génération d’image.
Elle détermine la disposition de base des éléments dans l’image (visages, paysages, objets, etc.).
Même seed + même prompt + mêmes paramètres = même image (à quelques variations mineures près).

#### Validité de la seed
La seed n’est pas liée à une session active :
Une fois qu’une image est générée avec une seed spécifique, on peux réutiliser cette seed plus tard (même après avoir fermé SDW ou redémarré ton ordinateur).

Ce qui peut changer le résultat :
- Modifier le prompt, les paramètres (CFG, steps, sampler), ou le modèle (checkpoint), l’image sera différente, même avec la même seed.
- Utiliser une version différente de Stable Diffusion (ex : passage de SD 1.5 à SDXL), la seed peut donner un résultat différent.

#### Comment utiliser la seed pour faire évoluer une image ?


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

1. Stockage des Paramètres sur Disque

Oui, les paramètres sont stockés (mais pas automatiquement dans un historique complet) :


Dossier des sorties :

Par défaut, les images générées sont sauvegardées dans stable-diffusion-webui/outputs/ (ou un sous-dossier comme txt2img-images/).
Chaque image est accompagnée d’un fichier texte (ex: 2023-11-01-123456.png + 2023-11-01-123456.txt) contenant :

Le prompt complet.
La seed.
Le sampler, CFG, steps, model, etc.





Exemple de fichier .txt :
Prompt: A cyberpunk punk with a cybernetic arm, neon alley, --seed 123456789
Negative prompt: blurry, deformed
Steps: 30, Sampler: Euler a, CFG scale: 12, Seed: 123456789, Size: 512x768, Model: realisticVision-v5





2. Historique des Générations

Pas d’historique natif :

SDW ne stocke pas automatiquement un "historique des sessions" avec toutes les générations successives.
Mais : Tu peux reconstruire manuellement l’historique en :

Conservant les fichiers .txt associés à chaque image.
Utilisant des outils externes (voir section 3).






3. Retrouver une Génération Spécifique (ex: 2ème génération)


Méthode 1 : Fichiers .txt :

Ouvre le dossier outputs/ et cherche le fichier .txt correspondant à la 2ème génération.
Copie-colle les paramètres (seed, prompt, etc.) dans SDW pour regénérer l’image.



Méthode 2 : Extensions pour SDW :

Prompt History :

Une extension qui enregistre tous les prompts et paramètres utilisés pendant une session.
Lien vers l’extension.


Image Browser :

Permet de visualiser et filtrer les images générées par seed, prompt, ou date.
Lien vers l’extension.





Méthode 3 : Scripts Python :

Si tu es à l’aise avec le code, tu peux écrire un script pour parser les fichiers .txt et extraire les paramètres par seed.




4. Exemple Concret
Scénario :

Tu génères 3 images en changeant un paramètre à chaque fois (ex: CFG = 10, 12, 14).
Tu veux revenir à la 2ème génération (CFG = 12).

Solution :

Ouvre le fichier .txt de la 2ème image.
Copie le prompt, la seed, et les paramètres (CFG=12, etc.).
Colle-les dans SDW et relance la génération.


5. Astuces pour un Meilleur Suivi

Nomme tes dossiers :

Crée des sous-dossiers par projet (ex: outputs/cyberpunk_punk/, outputs/gothic_castle/).


Utilise des tags :

Ajoute des mots-clés dans le prompt pour faciliter la recherche (ex: #v1, #test_cfg12).


Extensions recommandées :

Prompt All in One : Pour sauvegarder/importer des prompts complets.
Seed Travel : Pour explorer des variantes autour d’une seed.