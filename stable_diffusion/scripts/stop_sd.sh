#!/bin/bash
# Script d'arrêt de Stable Diffusion
pkill -f "webui.sh"
pkill -f "python.*launch.py"