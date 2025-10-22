Comment ajouter des icônes/emojis dans un fichier Markdown ?
Pour ajouter des icônes ou emojis dans un fichier Markdown (comme les 🔧, ⚙️, 📝, etc.), il suffit de copier-coller l'emoji directement dans le texte. Voici quelques exemples utiles :
⚙️:gear:Configuration, paramètres
📝:memo:Notes, aide-mémoire
🔄:arrows_clockwise:,Redémarrage, cycles
⚡:zap:Optimisations, performances
💻:computer:, Matériel, logiciel
📦:package:Dépôts, paquets
⚠️ poitn d'attention

Le code pour l'emoji :tools: est :tools:, mais il semble que cet emoji spécifique ne soit pas universellement supporté sur toutes les plateformes (comme GitHub ou certains éditeurs Markdown). Voici ce que tu peux faire :

1. Emojis Alternatifs pour "Outils"
Si :tools: ne s'affiche pas, utilise plutôt :

🛠️ → :hammer_and_wrench: (représente des outils)
🔧 → :wrench: (clé à molette, souvent utilisé pour les outils/configurations)
💻 → :computer: (pour les outils logiciels)


2. Comment les Insérer dans Markdown ?
Il suffit de copier-coller l'emoji directement dans ton fichier .md ou d'utiliser le code entre deux points (:code:). Exemple :
## 🛠️ Outils Recommandés
- **tmux** : Pour gérer les sessions en arrière-plan.
- **Python 3.11** : Environnement d'exécution.

3. Liste des Emojis Couramment Supportés
Voici quelques emojis utiles pour les fichiers techniques :
🛠️:hammer_and_wrench:Outils, configurations
🔧:wrench:Paramètres, ajustements
💻:computer:Matériel, logiciel
📦:package:Dépôts, paquets
⚙️:gear:Réglages, options
📝:memo:Notes, documentation
🔄:arrows_clockwise:Redémarrage, cycles
⚡:zap:Performances, optimisations

4. Tester l'Affichage

GitHub/GitLab : Tous les emojis standard sont supportés.
Éditeurs locaux (VS Code, Typora) : La plupart des emojis s'affichent correctement.
Terminaux : Certains terminaux (comme iTerm2) supportent les emojis en couleur.


Exemple dans ton fichier :
## 🛠️ Outils et Commandes Tmux
- **Arrêter** : `pkill -f "webui.sh"`
- **Redémarrer** : `tmux send-keys -t test "./webui.sh" Enter`

Liste d'Emojis par Catégorie
1. Outils et Configuration

Emoji,Code Markdown,Utilisation Typique
🛠️,:hammer_and_wrench:,Outils, configurations, scripts.
🔧,:wrench:,Paramètres, ajustements techniques.
⚙️,:gear:,Réglages, options avancées.
💻,:computer:,Matériel, logiciels, PC.
📦,:package:,Dépôts, paquets, installations.

2. Résultats et Tests

Emoji,Code Markdown,Utilisation Typique
✅,:white_check_mark:,Succès, validation.
❌,:x:,Échec, problème.
⚠️,:warning:,Attention, avertissement.
📊,:bar_chart:,Comparatifs, tableaux de résultats.
🔍,:mag:,Recherche, analyse.

3. Modèles et Génération

Emoji,Code Markdown,Utilisation Typique
🎨,:art:,Génération d'images, art.
🖼️,:framed_picture:,Images, résultats visuels.
🌄,:sunrise:,Paysages, environnements.
👤,:bust_in_silhouette:,Portraits, personnages.
🤖,:robot:,Cyberpunk, IA, éléments futuristes.

4. Performances et Optimisations

Emoji,Code Markdown,Utilisation Typique
⚡,:zap:,Performances, vitesse.
📈,:chart_with_upwards_trend:,Améliorations, optimisations.
🔄,:arrows_clockwise:,Redémarrage, cycles, itérations.
⏳,:hourglass:,Temps de génération, attente.

5. Divers (Organisation)

Emoji,Code Markdown,Utilisation Typique
📁,:file_folder:,Dossiers, arborescence.
📝,:memo:,Notes, documentation.
🔗,:link:,Liens, références.
📌,:pushpin:,Points clés, rappels.

<custom-element data-json="%7B%22type%22%3A%22table-metadata%22%2C%22attributes%22%3A%7B%22title%22%3A%22Comparatif%20des%20Mod%C3%A8les%20-%20Exemple%22%7D%7D" />

| **Critère**          | **Realistic Vision V5.0**       | **Juggernaut XL v8**          |
|----------------------|----------------------------------|-------------------------------|
| **Qualité (1-10)**   | 9/10                             | 8/10                         |
| **Résolution Max**   | 768x768                          | 768x512                       |
| **Temps Génération** | ~25s (30 steps)                 | ~30s (30 steps)               |
| **Détails Forts**    | Visages, textures               | Éclairages, ambiances         |
| **Problèmes**        | Aucun en 512x768                | OOM si > 768x512              |


xplications


Syntaxe :

Les | séparent les colonnes.
La 2ème ligne (avec les ---) définit l’en-tête.
Alignement : Par défaut, le texte est aligné à gauche. Pour centrer, utilise :---: (ex : |:---:|).



Style :

Gras pour les en-têtes (**Texte**).
Données concises pour une lecture rapide.



Intégration dans SD_rules.md :
Copie-colle ce bloc et adapte les valeurs. Tu peux ajouter autant de lignes que nécessaire.


| **Critère**          | **Realistic Vision V5.0**       | **Juggernaut XL v8**          |
|:---------------------:|:--------------------------------:|:-----------------------------:|
| **Qualité (1-10)**   | 9/10                             | 8/10                         |
| **Résolution Max**   | 768x768                          | 768x512                       |

🎨 Variante avec Alignement Centré

