# Kubernetes

This directory contains a Kustomize-based Kubernetes scaffold for the University App server stack.

## Layout

- `base/` contains the shared resources.
- `overlays/local/` targets a developer cluster such as kind or minikube.
- `overlays/prod/` keeps the same resource model with production-oriented resource sizing.

## What Is Included

- Namespace
- PostgreSQL StatefulSet with persistent storage
- Backend Deployment with a migration init container
- Frontend Deployment
- ClusterIP Services
- Ingress routing for `/`, `/api`, and `/static`
- Shared Secrets and ConfigMap resources

## Backend Migration Flow

The backend image supports two runtime modes:

- normal server mode
- migration-only mode via `RUN_MIGRATIONS_ONLY=true`

The Kubernetes backend Deployment uses a migration init container so the main app container only starts after schema updates have completed.

## Local Workflow

Build the images with tags that match the overlay, then apply the local overlay:

```bash
docker build -t university-app-backend:local ./backend
docker build -t university-app-frontend:local ./frontend
kubectl apply -k k8s/overlays/local
```

## Production Workflow

The production overlay uses the same manifests and raises resource requests and limits for the core services.

## Notes

- Replace the placeholder secret values in `base/secret.yaml` before deploying to any real cluster.
- The current setup keeps the frontend API contract at `/api/v1`.
- The backend serves profile photos from `/static/profile-photos`.

## Important Commands

### Minikube Setup

```bash
minikube start --driver=docker
minikube addons enable ingress
```

### Build and Load Images

```bash
cd server
docker build -t university-app-backend:local ./backend
docker build -t university-app-frontend:local ./frontend
minikube image load university-app-backend:local
minikube image load university-app-frontend:local
```

### Deploy and Delete

```bash
cd server
kubectl apply -k k8s/overlays/local
kubectl delete -k k8s/overlays/local
```

### Health and Debugging

```bash
kubectl -n university-app get pods -o wide
kubectl -n university-app get events --sort-by=.lastTimestamp | tail -n 40
kubectl -n university-app describe pod postgres-0
kubectl -n university-app logs deployment/backend -c backend --tail=120
kubectl -n university-app logs deployment/backend -c migrate --tail=120
```

### Rollout and Restart

```bash
kubectl -n university-app rollout status statefulset/postgres --timeout=240s
kubectl -n university-app rollout status deployment/backend --timeout=240s
kubectl -n university-app rollout status deployment/frontend --timeout=240s
kubectl -n university-app rollout restart statefulset/postgres deployment/backend deployment/frontend
```

### Access the App

```bash
minikube ip
curl -fsS http://$(minikube ip)/api/v1/health
curl -fsSI http://$(minikube ip)/
```

For a reliable host-side test on macOS, use port-forwards instead of tunnel:

```bash
cd server
make k8s-port-forward
```

Then open:
- Admin portal: `http://localhost:8081`
- Backend API: `http://localhost:3334`

During Minikube testing, use `http://localhost:8081` for the admin portal instead of the cluster ingress IP.

If ingress access from your host is flaky, run this in another terminal:

```bash
minikube tunnel
```