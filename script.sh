#!/bin/bash

# Trap errors and echo the error message before exiting
trap 'echo "Error occurred at line $LINENO: $BASH_COMMAND"; exit 1' ERR

# Enable exit on error
set -e

# Update system and install dependencies
echo "Updating system and installing dependencies..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget apt-transport-https

# Check if Docker is installed, install if missing
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    sudo apt install -y docker.io
    sudo systemctl enable --now docker
else
    echo "Docker already installed, ensuring service is running..."
    sudo systemctl enable --now docker
fi

# Ensure user is in docker group
if ! groups | grep -q docker; then
    echo "Adding user to docker group..."
    sudo usermod -aG docker $USER
    echo "Applying group changes..."
    # Use sg to switch group in current session to avoid newgrp issues
    sg docker -c "bash $0"
    exit 0
fi

# Install Minikube if not already installed
if ! command -v minikube &> /dev/null; then
    echo "Installing Minikube..."
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo install minikube-linux-amd64 /usr/local/bin/minikube
    rm minikube-linux-amd64
else
    echo "Minikube already installed."
fi

# Install kubectl if not already installed
if ! command -v kubectl &> /dev/null; then
    echo "Installing kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
else
    echo "kubectl already installed."
fi

# Check if Minikube cluster is already running
if minikube status &> /dev/null; then
    echo "Minikube cluster already running."
else
    echo "Starting Minikube with Docker driver..."
    minikube start --driver=docker --cpus=2 --memory=4096
fi

# Verify cluster
echo "Verifying Kubernetes cluster..."
minikube status
kubectl cluster-info
kubectl get nodes

echo "Minikube cluster setup complete!"
echo "To access the Kubernetes dashboard, run: minikube dashboard"
echo "To test with a sample deployment, run:"
echo "  kubectl create deployment nginx --image=nginx"
echo "  kubectl expose deployment nginx --type=NodePort --port=80"
echo "  minikube service nginx --url"
