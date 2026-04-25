#!/bin/bash
# Script to create required secrets for the finance-flow application

echo "Creating secrets for finance-dev namespace..."
kubectl create namespace finance-dev --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic postgres-secret \
  --namespace=finance-dev \
  --from-literal=POSTGRES_USER=finance_admin \
  --from-literal=POSTGRES_PASSWORD=supersecretpassword \
  --from-literal=USER_DB_NAME=user_db \
  --from-literal=TXN_DB_NAME=txn_db \
  --from-literal=NOTIFY_DB_NAME=notify_db \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic jwt-secret \
  --namespace=finance-dev \
  --from-literal=JWT_SECRET=my-development-jwt-secret \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic rabbitmq-secret \
  --namespace=finance-dev \
  --from-literal=RABBITMQ_USER=guest \
  --from-literal=RABBITMQ_PASSWORD=guest \
  --from-literal=RABBITMQ_URL=amqp://guest:guest@rabbitmq:5672 \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Creating secrets for finance-prod namespace..."
kubectl create namespace finance-prod --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic postgres-secret \
  --namespace=finance-prod \
  --from-literal=POSTGRES_USER=finance_admin \
  --from-literal=POSTGRES_PASSWORD=supersecretpassword \
  --from-literal=USER_DB_NAME=user_db \
  --from-literal=TXN_DB_NAME=txn_db \
  --from-literal=NOTIFY_DB_NAME=notify_db \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic jwt-secret \
  --namespace=finance-prod \
  --from-literal=JWT_SECRET=my-production-jwt-secret \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic rabbitmq-secret \
  --namespace=finance-prod \
  --from-literal=RABBITMQ_USER=guest \
  --from-literal=RABBITMQ_PASSWORD=guest \
  --from-literal=RABBITMQ_URL=amqp://guest:guest@rabbitmq:5672 \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Secrets created successfully!"
