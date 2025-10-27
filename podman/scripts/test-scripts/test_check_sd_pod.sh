#!/bin/bash

# Nom du pod
POD_NAME="sd_pod"

# Afficher l'état du pod
echo "🐱 État du pod $POD_NAME :"
podman pod ps --filter name=$POD_NAME --format "table {{.Name}}\t{{.Status}}"

# Afficher les conteneurs du pod
echo -e "\n🐱 Conteneurs dans le pod $POD_NAME :"
podman ps --pod --filter pod=$POD_NAME --format "table {{.Names}}\t{{.Status}}"

# Afficher les volumes utilisés
echo -e "\n🐱 Volumes montés :"
podman volume ls --filter name=sd --format "table {{.Name}}\t{{.Driver}}"