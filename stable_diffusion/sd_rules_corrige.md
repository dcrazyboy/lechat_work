
# Configuration Stable Diffusion - Optimisée pour 8 Go VRAM

---

## ⚙️ Contexte Matériel et Logiciel
### Configuration Validée
- **OS** : openSUSE Tumbleweed (Kernel 6.16.1-1-default)
- **GPU** : NVIDIA RTX 3070 (8 Go VRAM, Driver 580.76.05, CUDA 13.0)
- **RAM** : 32 Go (Swap : 31 Go)
- **Python** : 3.11+
- **Outils** : tmux, git, wget, curl, npm

### Dépôts Actifs (zypper)
| ID  | Nom du Dépôt               | Recommandation                     |
|-----|----------------------------|-------------------------------------|
| 2   | repo-non-free (NVIDIA)     | À garder (pilotes NVIDIA)          |
| 4   | Dépôt principal (NON-OSS)  | À garder (paquets non-open source) |
| 6   | Dépôt principal (OSS)      | À garder (paquets open source)     |

---

## 📝 Installation Validée
### Prérequis
```bash
sudo zypper install git wget curl python311 python311-pip python311-devel gcc gcc-c++ make cmake nodejs npm libffi-devel libopenssl-devel readline-devel sqlite3-devel xz-devel libbz2-devel tk-devel libexpat-devel jitterentropy-devel
```

### Clonage et Lancement
```bash
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
cd stable-diffusion-webui
./webui.sh --xformers --medvram --opt-sdp-attention --disable-nan-check
```

---

## 🔄 Gestion avec Tmux
### Arrêter le Script
```bash
pkill -f "webui.sh"  # Tue tous les processus liés
```
ou (si besoin de cibler un PID spécifique) :
```bash
kill $(pgrep -f "webui.sh")
```

### Redémarrer le Script
```bash
tmux send-keys -t test "./webui.sh --xformers --medvram --opt-sdp-attention --disable-nan-check" Enter
```

### Script de Redémarrage Automatisé
```bash
#!/bin/bash
tmux send-keys -t test C-c  # Interrompt le processus actuel
sleep 2
tmux send-keys -t test "./webui.sh --xformers --medvram --opt-sdp-attention --disable-nan-check" Enter
```

---

## ⚡ Optimisations pour 8 Go VRAM
- **Paramètres clés** :
  - Toujours utiliser `--medvram` et `--xformers`.
  - Limiter le batch size à 1 ou 2.
  - Éviter les résolutions > 768x768 sans optimisation supplémentaire.
