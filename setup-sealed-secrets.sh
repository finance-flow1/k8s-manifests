#!/bin/bash
# Script to install Sealed Secrets Controller and kubeseal CLI

echo "1. Adding bitnami helm repository..."
helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets
helm repo update

echo "2. Installing Sealed Secrets controller in kube-system namespace..."
helm install sealed-secrets sealed-secrets/sealed-secrets -n kube-system --set-string fullnameOverride=sealed-secrets-controller

echo "3. Installing kubeseal CLI..."
wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.26.0/kubeseal-0.26.0-linux-amd64.tar.gz
tar -xvzf kubeseal-0.26.0-linux-amd64.tar.gz kubeseal
sudo install -m 755 kubeseal /usr/local/bin/kubeseal
rm kubeseal-0.26.0-linux-amd64.tar.gz kubeseal

echo "=========================================================="
echo "Installation complete!"
echo "Please wait a few seconds for the controller to start up."
echo "You can check its status with:"
echo "kubectl get pods -n kube-system -l app.kubernetes.io/name=sealed-secrets"
echo "=========================================================="
