#!/bin/bash
POD_NAME="cuda-base"
IMAGE_NAME="nvcr.io/nvidia/cuda:12.4.1-runtime-ubuntu22.04"
EXTERNAL_STORAGE="/chemin/vers/disque/externe/podman/pods/\$POD_NAME"

mkdir -p "\$EXTERNAL_STORAGE"
podman pod create --name "\$POD_NAME" --device=nvidia.com/gpu=all
podman run -it --pod "\$POD_NAME" --mount type=bind,source="\$EXTERNAL_STORAGE",destination=/app/data "\$IMAGE_NAME" /bin/