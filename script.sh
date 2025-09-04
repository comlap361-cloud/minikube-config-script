#!/bin/bash

# Exit on any error
set -e

# Update system and install dependencies
echo "Updating system and installing dependencies..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget apt-transport-https

# Install Docker
echo "Installing Docker..."
sudo apt install -y docker.io
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
newgrp docker

# Install Minikube
echo "Installing Minikube..."
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
rm minikube-linux-amd64

# Install kubectl
echo "Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Start Minikube with Docker driver
echo "Starting Minikube with Docker driver..."
minikube start --driver=docker --cpus=2 --memory=4096

# Verify cluster
echo "Verifying Kubernetes cluster..."
minikube status
kubectl cluster-info
kubectl get nodes

echo "Minikube cluster setup complete! Use 'kubectl' to manage your cluster."
echo "To access the Kubernetes dashboard, run: minikube dashboard"
