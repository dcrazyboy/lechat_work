# 🐱 Boîte à Outils VSCodium pour Le Matou

Ce dépôt contient une configuration **hybride** pour VSCodium, optimisée pour :
- **Travailler sur plusieurs projets Git** en isolation.
- **Basculer facilement** entre un contexte global et des workspaces dédiés.
- **Partager des fichiers** entre projets (ex: SQL, scripts, docs).

---

## 📂 Structure des Dossiers
```
prof
  └──  vscodium
        ├── dcrazyboy/          # 🔒 Projet privé (GitHub privé)
        ├── lechat_work/        # 🤝 Projet collaboratif (GitHub privé/public)
        ├── postgres_dba_toolkit/ # 🌍 Projet public (GitHub public)
        ├── README.md           # Ce fichier
        ├── dcrazyboy.code-workspace
        ├── lechat_work.code-workspace
        └── postgres_dba_toolkit.code-workspace
```

---

## 🛠 Extensions Communes
Toutes les configurations incluent ces extensions de base :
- **ShellCheck** : Vérification des scripts shell.
- **GitLens** : Superpouvoirs Git (historique, blame, etc.).
- **Workspace Switcher** : Basculer entre les workspaces en 1 clic.
- **Markdown All in One** : Édition avancée de Markdown.

---

## 🚀 Comment Utiliser ?
1. **Ouvrir le contexte global** :
   - `File > Open Folder` → Sélectionne `<mon_disk>/prof/vscodium`.
   - Idéal pour **rechercher/copier** des fichiers entre projets.

2. **Travailler dans un workspace isolé** :
   - `Ctrl+K O` → Sélectionne un fichier `.code-workspace` (ex: `lechat_work.code-workspace`).
   - GitLens **détecte automatiquement** le dépôt Git du projet.

3. **Revenir au contexte global** :
   - Ferme le workspace (`File > Close Workspace`) et rouvre le dossier racine.

---

## 🎯 Raccourcis Clavier Utiles
| Action                          | Raccourci          |
| :--- | :--- |
| Ouvrir un workspace             | `Ctrl+K O`         |
| Basculer vers le contexte global | `Ctrl+Alt+G`       |
| Basculer vers `dcrazyboy`       | `Ctrl+Alt+1`       |
| Basculer vers `lechat_work`     | `Ctrl+Alt+2`       |

*(Les raccourcis sont configurés dans `keybindings.json`.)*

---

## 📌 Notes
- Les **emojis Markdown** sont disponibles dans `emojis.md`.
- Les **paramètres communs** sont dans `settings.json` (partagés entre tous les workspaces).
- Pour ajouter des **extensions spécifiques** à un projet, édite son fichier `.code-workspace`.
