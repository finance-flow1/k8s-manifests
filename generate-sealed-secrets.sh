#!/bin/bash
# =============================================================================
# generate-sealed-secrets.sh
#
# Generates SealedSecret YAMLs for all environments by reading plaintext
# credentials from a local .env file.
#
# USAGE:
#   1. Copy .env.example to .env and fill in your real values
#   2. Run: bash generate-sealed-secrets.sh
#   3. Commit the generated *-sealed-secret.yaml files (NOT the .env file)
# =============================================================================

set -euo pipefail

# --- Load environment variables from .env file ---
ENV_FILE="$(dirname "$0")/.env"

if [ ! -f "$ENV_FILE" ]; then
  echo "ERROR: .env file not found at: $ENV_FILE"
  echo "       Copy .env.example to .env and fill in your credentials."
  exit 1
fi

# shellcheck source=/dev/null
source "$ENV_FILE"

# --- Validate required variables are set ---
REQUIRED_VARS=(
  POSTGRES_USER
  DEV_POSTGRES_PASSWORD
  PROD_POSTGRES_PASSWORD
  USER_DB_NAME
  TXN_DB_NAME
  NOTIFY_DB_NAME
  DEV_JWT_SECRET
  PROD_JWT_SECRET
  RABBITMQ_USER
  RABBITMQ_PASSWORD
)

for var in "${REQUIRED_VARS[@]}"; do
  if [ -z "${!var:-}" ]; then
    echo "ERROR: Required variable '$var' is not set in .env"
    exit 1
  fi
done

# --- Ensure namespaces exist ---
kubectl create namespace finance-dev --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace finance-prod --dry-run=client -o yaml | kubectl apply -f -

# =============================================================================
# DEV SECRETS
# =============================================================================
echo ""
echo "=========================================="
echo "  Generating DEV secrets..."
echo "=========================================="

kubectl create secret generic postgres-secret \
  --namespace=finance-dev \
  --from-literal=POSTGRES_USER="${POSTGRES_USER}" \
  --from-literal=POSTGRES_PASSWORD="${DEV_POSTGRES_PASSWORD}" \
  --from-literal=USER_DB_NAME="${USER_DB_NAME}" \
  --from-literal=TXN_DB_NAME="${TXN_DB_NAME}" \
  --from-literal=NOTIFY_DB_NAME="${NOTIFY_DB_NAME}" \
  --dry-run=client -o yaml | kubeseal --format=yaml > dev-postgres-sealed-secret.yaml
echo "  [OK] dev-postgres-sealed-secret.yaml"

kubectl create secret generic jwt-secret \
  --namespace=finance-dev \
  --from-literal=JWT_SECRET="${DEV_JWT_SECRET}" \
  --dry-run=client -o yaml | kubeseal --format=yaml > dev-jwt-sealed-secret.yaml
echo "  [OK] dev-jwt-sealed-secret.yaml"

kubectl create secret generic rabbitmq-secret \
  --namespace=finance-dev \
  --from-literal=RABBITMQ_USER="${RABBITMQ_USER}" \
  --from-literal=RABBITMQ_PASSWORD="${RABBITMQ_PASSWORD}" \
  --from-literal=RABBITMQ_URL="amqp://${RABBITMQ_USER}:${RABBITMQ_PASSWORD}@rabbitmq:5672" \
  --dry-run=client -o yaml | kubeseal --format=yaml > dev-rabbitmq-sealed-secret.yaml
echo "  [OK] dev-rabbitmq-sealed-secret.yaml"

# =============================================================================
# PROD SECRETS
# =============================================================================
echo ""
echo "=========================================="
echo "  Generating PROD secrets..."
echo "=========================================="

kubectl create secret generic postgres-secret \
  --namespace=finance-prod \
  --from-literal=POSTGRES_USER="${POSTGRES_USER}" \
  --from-literal=POSTGRES_PASSWORD="${PROD_POSTGRES_PASSWORD}" \
  --from-literal=USER_DB_NAME="${USER_DB_NAME}" \
  --from-literal=TXN_DB_NAME="${TXN_DB_NAME}" \
  --from-literal=NOTIFY_DB_NAME="${NOTIFY_DB_NAME}" \
  --dry-run=client -o yaml | kubeseal --format=yaml > prod-postgres-sealed-secret.yaml
echo "  [OK] prod-postgres-sealed-secret.yaml"

kubectl create secret generic jwt-secret \
  --namespace=finance-prod \
  --from-literal=JWT_SECRET="${PROD_JWT_SECRET}" \
  --dry-run=client -o yaml | kubeseal --format=yaml > prod-jwt-sealed-secret.yaml
echo "  [OK] prod-jwt-sealed-secret.yaml"

kubectl create secret generic rabbitmq-secret \
  --namespace=finance-prod \
  --from-literal=RABBITMQ_USER="${RABBITMQ_USER}" \
  --from-literal=RABBITMQ_PASSWORD="${RABBITMQ_PASSWORD}" \
  --from-literal=RABBITMQ_URL="amqp://${RABBITMQ_USER}:${RABBITMQ_PASSWORD}@rabbitmq:5672" \
  --dry-run=client -o yaml | kubeseal --format=yaml > prod-rabbitmq-sealed-secret.yaml
echo "  [OK] prod-rabbitmq-sealed-secret.yaml"

echo ""
echo "=========================================="
echo "  All secrets generated successfully!"
echo "  The following encrypted files are safe"
echo "  to commit to your GitOps repository:"
echo "=========================================="
ls -lh ./*-sealed-secret.yaml
echo ""
echo "  REMINDER: Never commit the .env file!"
echo "=========================================="
