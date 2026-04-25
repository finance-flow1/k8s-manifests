# k8s-manifests — FinanceFlow GitOps Repository

This repository is the **single source of truth** for all Kubernetes deployments of the FinanceFlow application. It is managed via **ArgoCD** (GitOps pull-based CD) and updated automatically by the **GitHub Actions CI pipelines** in each service repository.

---

## Repository Structure

```
k8s-manifests/
├── charts/
│   ├── user-service/          # Port 5001 — Identity & Auth
│   ├── transaction-service/   # Port 5002 — Finance & Analytics
│   ├── notification-service/  # Port 5003 — Alerts & Events
│   ├── frontend/              # Port 80  — React SPA + Nginx proxy
│   ├── postgres/              # StatefulSet + PVC — Unified data store
│   └── rabbitmq/              # Message broker (AMQP)
└── argocd/
    ├── dev/                   # ArgoCD Applications → finance-dev namespace
    └── prod/                  # ArgoCD Applications → finance-prod namespace
```

Each chart contains:
- `Chart.yaml` — Chart metadata
- `values.yaml` — Base values (**`image.tag` updated by CI/CD pipeline**)
- `values-dev.yaml` — Dev environment overrides (lower resources, HPA disabled)
- `values-prod.yaml` — Prod environment overrides (HPA enabled, higher replicas)
- `templates/` — Kubernetes resource templates

---

## How the GitOps Pipeline Works

```
Push to service repo (main or dev branch)
      │
      ▼
GitHub Actions CI
  ├── npm test
  ├── SonarQube scan (SAST quality gate)
  ├── Snyk scan (dependency vulnerabilities)
  ├── Docker build
  ├── Trivy scan (container OS vulnerabilities)
  └── Docker push to Docker Hub
      │
      ▼
GitHub Actions CD
  ├── dev branch  → updates charts/<service>/values-dev.yaml  (image.tag = dev-<branch>-<sha>)
  └── main branch → updates charts/<service>/values.yaml      (image.tag = v1.2.3 semver)
      │
      ▼
ArgoCD detects git commit in k8s-manifests
  ├── finance-dev  ← syncs from values.yaml + values-dev.yaml
  └── finance-prod ← syncs from values.yaml + values-prod.yaml
```

---

## Prerequisites

### Required K8s Secrets (created once manually — NOT in Helm)

These secrets must exist in each namespace before deploying. They are NOT managed by Helm.

```bash
# postgres-secret
kubectl create secret generic postgres-secret \
  --from-literal=POSTGRES_USER=financeuser \
  --from-literal=POSTGRES_PASSWORD=<CHANGE_ME> \
  --from-literal=USER_DB_NAME=user_db \
  --from-literal=TXN_DB_NAME=txn_db \
  --from-literal=NOTIFY_DB_NAME=notify_db \
  -n finance-dev  # repeat for finance-prod

# jwt-secret
kubectl create secret generic jwt-secret \
  --from-literal=JWT_SECRET=<CHANGE_ME> \
  -n finance-dev

# rabbitmq-secret
kubectl create secret generic rabbitmq-secret \
  --from-literal=RABBITMQ_USER=guest \
  --from-literal=RABBITMQ_PASSWORD=<CHANGE_ME> \
  --from-literal=RABBITMQ_URL=amqp://guest:<CHANGE_ME>@rabbitmq:5672 \
  -n finance-dev
```

### Required GitHub Secrets (in each service repo)

| Secret | Description |
|--------|-------------|
| `SONAR_TOKEN` | SonarQube authentication token |
| `SONAR_HOST_URL` | SonarQube server URL |
| `SNYK_TOKEN` | Snyk API token |
| `DOCKER_USERNAME` | Docker Hub username |
| `DOCKER_PASSWORD` | Docker Hub password or PAT |
| `SMTP_HOST` | Email SMTP host |
| `SMTP_PORT` | SMTP port (e.g. 587) |
| `SMTP_USERNAME` | SMTP username |
| `SMTP_PASSWORD` | SMTP password |
| `EMAIL_TO` | Notification recipient email |
| `APP_ID` | GitHub App ID (for k8s-manifests write access) |
| `APP_PRIVATE_KEY` | GitHub App private key |
| `MANIFEST_REPO` | `finance-flow1/k8s-manifests` |

---

## Installing ArgoCD Applications

```bash
# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Apply dev applications
kubectl apply -f argocd/dev/

# Apply prod applications
kubectl apply -f argocd/prod/
```

---

## Verifying Deployment

```bash
# Check all resources in each environment
kubectl get all -n finance-dev
kubectl get all -n finance-prod

# Check ArgoCD sync status
kubectl get applications -n argocd

# Check pod logs
kubectl logs -l app.kubernetes.io/name=user-service -n finance-prod --tail=50
```
