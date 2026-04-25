#!/bin/bash
# Script to generate SealedSecret YAMLs for the finance application

# Make sure namespaces exist so kubeseal knows the scope
kubectl create namespace finance-dev --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace finance-prod --dry-run=client -o yaml | kubectl apply -f -

echo "=========================================="
echo "Generating DEV secrets..."
echo "=========================================="

kubectl create secret generic postgres-secret --namespace=finance-dev \
  --from-literal=POSTGRES_USER=finance_admin \
  --from-literal=POSTGRES_PASSWORD=supersecretpassword \
  --from-literal=USER_DB_NAME=user_db \
  --from-literal=TXN_DB_NAME=txn_db \
  --from-literal=NOTIFY_DB_NAME=notify_db \
  --dry-run=client -o yaml | kubeseal --format=yaml > dev-postgres-sealed-secret.yaml

kubectl create secret generic jwt-secret --namespace=finance-dev \
  --from-literal=JWT_SECRET=my-development-jwt-secret \
  --dry-run=client -o yaml | kubeseal --format=yaml > dev-jwt-sealed-secret.yaml

kubectl create secret generic rabbitmq-secret --namespace=finance-dev \
  --from-literal=RABBITMQ_USER=guest \
  --from-literal=RABBITMQ_PASSWORD=guest \
  --from-literal=RABBITMQ_URL=amqp://guest:guest@rabbitmq:5672 \
  --dry-run=client -o yaml | kubeseal --format=yaml > dev-rabbitmq-sealed-secret.yaml

echo "=========================================="
echo "Generating PROD secrets..."
echo "=========================================="

kubectl create secret generic postgres-secret --namespace=finance-prod \
  --from-literal=POSTGRES_USER=finance_admin \
  --from-literal=POSTGRES_PASSWORD=supersecretpassword \
  --from-literal=USER_DB_NAME=user_db \
  --from-literal=TXN_DB_NAME=txn_db \
  --from-literal=NOTIFY_DB_NAME=notify_db \
  --dry-run=client -o yaml | kubeseal --format=yaml > prod-postgres-sealed-secret.yaml

kubectl create secret generic jwt-secret --namespace=finance-prod \
  --from-literal=JWT_SECRET=my-production-jwt-secret \
  --dry-run=client -o yaml | kubeseal --format=yaml > prod-jwt-sealed-secret.yaml

kubectl create secret generic rabbitmq-secret --namespace=finance-prod \
  --from-literal=RABBITMQ_USER=guest \
  --from-literal=RABBITMQ_PASSWORD=guest \
  --from-literal=RABBITMQ_URL=amqp://guest:guest@rabbitmq:5672 \
  --dry-run=client -o yaml | kubeseal --format=yaml > prod-rabbitmq-sealed-secret.yaml

echo "Done! The following encrypted files have been created:"
ls -l *-sealed-secret.yaml
echo "You can now copy the contents of these files into your local k8s-manifests workspace."
