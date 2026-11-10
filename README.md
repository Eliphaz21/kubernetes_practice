# CSEC ASTU – Complete Kubernetes, Docker, Helm, Terraform & AWS EKS Training

Welcome to the hands-on DevOps and Cloud-Native training curriculum for the **CSEC ASTU (Computer Science & Engineering Club, Adama Science and Technology University) – Development Division**.

Students will use this repository and accompanying guides to learn Docker, Kubernetes, Helm, Terraform, and AWS EKS deployment step-by-step.

---

## 1. Project Repository Structure

```
csec-kubernetes-learning/
│
├── frontend/                     # React 18 + Vite + TypeScript Single Page App
│   ├── src/
│   │   ├── components/           # UI Components (Welcome.tsx)
│   │   ├── services/             # Typed API client (api.ts)
│   │   ├── types/                # TypeScript interface definitions (welcome.ts)
│   │   ├── App.tsx               # Primary layout container
│   │   ├── main.tsx              # React DOM mounting
│   │   ├── index.css             # Clean, minimal university community styling
│   │   └── vite-env.d.ts         # Vite client type definitions
│   ├── index.html                # HTML entrypoint
│   ├── tsconfig.json             # TypeScript compiler configuration
│   ├── vite.config.ts            # Vite bundler & dev proxy config
│   ├── package.json              # Frontend dependencies and scripts
│   ├── Dockerfile                # Multi-stage production container build (Milestone 2)
│   ├── nginx.conf                # Nginx web server & /api reverse proxy config (Milestone 2)
│   └── .dockerignore             # Docker build exclusion rules
│
├── backend/                      # Node.js + Express + TypeScript REST API
│   ├── src/
│   │   ├── routes/               # Express routes (/api/welcome, health, ready)
│   │   ├── controllers/          # Business logic handlers (welcome.controller.ts)
│   │   ├── types/                # Strict request/response types (welcome.types.ts)
│   │   ├── middleware/           # Centralized error handlers (error.middleware.ts)
│   │   ├── app.ts                # Express app factory with CORS & JSON parsing
│   │   └── server.ts             # Server entrypoint with graceful shutdown
│   ├── tests/                    # Automated integration tests (health.test.ts)
│   ├── tsconfig.json             # Strict TypeScript compiler configuration
│   ├── package.json              # Backend dependencies and scripts
│   ├── Dockerfile                # Multi-stage Alpine container build (Milestone 2)
│   └── .dockerignore             # Docker build exclusion rules
│
├── kubernetes/                   # Raw Kubernetes Declarative Manifests
│   ├── 00-namespace/             # Cluster tenancy (csec-learning namespace)
│   ├── 01-config/                # ConfigMaps and Secrets
│   ├── 02-workloads/             # Deployments & ReplicaSets
│   ├── 03-networking/            # ClusterIP, NodePort, and Ingress
│   ├── 04-storage/               # PV, PVC, and StorageClass demonstrations
│   ├── 05-security/              # RBAC, ServiceAccounts, and NetworkPolicies
│   ├── 06-resources/             # ResourceQuotas and LimitRanges
│   ├── 07-availability/          # Liveness/Readiness probes and PDBs
│   ├── 08-scheduling/            # NodeAffinity, Taints, Tolerations
│   └── 09-advanced/              # HPA, Metrics Server, and Kustomize overlays
│
├── helm/                         # Helm Package Manager
│   └── csec-welcome/             # Production-grade Helm chart for CSEC Welcome
│       ├── Chart.yaml
│       ├── values.yaml
│       ├── values-dev.yaml
│       ├── values-prod.yaml
│       └── templates/
│
├── .github/                      # CI/CD Automation
│   └── workflows/                # GitHub Actions pipelines (Lint, Test, Docker Build, Scan)
│
├── monitoring/                   # Observability & Metrics
│   ├── prometheus/               # Prometheus scrape configs & alerts
│   ├── grafana/                  # Grafana dashboards for cluster & app metrics
│   └── README.md
│
├── infrastructure/               # Infrastructure as Code (IaC)
│   └── aws/
│       ├── terraform/            # Terraform modules: VPC, Subnets, EKS, ECR, IAM
│       ├── eks/                  # EKS cluster add-ons (ALB Controller, EBS CSI)
│       └── README.md
│
├── scripts/                      # Automation scripts for students
│   ├── build-images.ps1          # Image build helper
│   ├── deploy-minikube.ps1       # Local Minikube deployment script
│   ├── cleanup-minikube.ps1      # Local cleanup
│   └── cleanup-aws.ps1           # AWS teardown helper
│
├── docs/                         # Complete 36-Module Student Curriculum
│   ├── 01-project-introduction-and-architecture.md
│   ├── 02-development-environment-installation.md
│   ├── 03-typescript-application-development.md
│   ├── 04-docker-fundamentals.md
│   ├── 05-dockerfiles-and-containerization.md
│   ├── 06-docker-compose.md
│   └── ...
│
├── docker-compose.yaml           # Local multi-container development configuration
├── .env.example                  # Environment variables template
├── .gitignore                    # Git tracking ignore rules
└── README.md                     # Root project documentation
```

---

## 2. Quick Prerequisites

- **Node.js** (v20+ recommended) & **npm**
- **Git**
- **Docker Desktop** *(for Docker Compose mode)*

---

## 3. How to Run the Project

You can run the application using **Method A (Local Development)** or **Method B (Docker Containers)**.

### Method A: Local Development (`npm run dev`)

Run this mode when editing source code with instant live reload.

#### 1. Start Backend (Terminal 1)
```powershell
cd c:\devops\backend
npm install
npm run dev
```
*Backend runs on [http://localhost:5000](http://localhost:5000). Keep this terminal open.*

#### 2. Start Frontend (Terminal 2)
```powershell
cd c:\devops\frontend
npm install
npm run dev
```
*Frontend runs on [http://localhost:5173](http://localhost:5173). Keep this terminal open.*

#### 3. Open in Browser
Visit **[http://localhost:5173](http://localhost:5173)** to view the landing page.

---

### Method B: Containerized Mode (`docker compose`)

Run this mode to simulate production containers inside Docker.

#### 1. Start Containers
Make sure Docker Desktop is running, then run:
```powershell
cd c:\devops
docker compose up --build
```
*(Add `-d` to run in the background)*

#### 2. Open in Browser
Visit **[http://localhost:8080](http://localhost:8080)**.

Nginx serves the frontend static build on port `8080` and transparently proxies `/api/*` requests to the backend container over internal Docker DNS (`http://backend:5000`).

#### 3. Stop Containers
```powershell
docker compose down
```

---

## 4. `0.0.0.0` vs `localhost`

- **`0.0.0.0` (Server Binding)**: Tells the backend server to accept requests from all network interfaces (needed for Docker and Kubernetes).
- **`localhost` (Browser Access)**: When visiting from your browser on Windows, always use `http://localhost:5000` or `http://localhost:5173`.

---

## 5. API Endpoints

| Method | Endpoint | Description |
| :---: | :--- | :--- |
| `GET` | `/` | API index & available endpoints |
| `GET` | `/api/welcome` | CSEC ASTU welcome information |
| `GET` | `/api/health` | Health check (Kubernetes liveness probe) |
| `GET` | `/api/ready` | Readiness check (Kubernetes readiness probe) |

Quick test with PowerShell:
```powershell
curl.exe http://localhost:5000/api/welcome
```

---

## 6. Testing & Building

```powershell
# Run backend integration tests
cd c:\devops\backend
npm test

# Build production TypeScript output
npm run build

# Build frontend production bundle
cd c:\devops\frontend
npm run build
```

---

## 7. Hands-On Student Practice Handbooks (Zero-to-Hero Labs)

Every tier of this curriculum is built with **1-Click Copy Terminal Commands** so students can delete directories, copy exact code without indentation errors, and build each stage from scratch:

| Practice Handbook | Scope | Key Capabilities | Link |
| :--- | :--- | :--- | :---: |
| **Kubernetes Master Guide** | Manifests `00` to `09` | Namespaces, Pods, Deployments, Services, Ingress, PV/PVC, RBAC, HPA | 👉 **[Read Kubernetes Guide](docs/kubernetes-guide.md)** |
| **Helm Master Guide** | Packaging & Releases | Helm Charting, `_helpers.tpl`, `values-dev.yaml`, `values-prod.yaml`, Rollbacks | 👉 **[Read Helm Guide](docs/helm-guide.md)** |
| **AWS & Terraform Guide** | Cloud Infrastructure | Multi-AZ VPC, EKS Cluster, ECR Registries, Cloud Deployments, Teardown | 👉 **[Read AWS EKS Guide](docs/aws-eks-guide.md)** |

---

## 8. Curriculum Guides (`docs/`)

Each module follows our **13-Step Teaching Format** (What, Why, Complete Code, Execute, Verify, Troubleshoot, Practice, Cleanup, Production Connection):

| Module | Title | Status |
| :---: | :--- | :---: |
| **01** | [Project Introduction & Architecture](docs/01-project-introduction-and-architecture.md) | ✅ Complete |
| **02** | [Development Environment Installation](docs/02-development-environment-installation.md) | ✅ Complete |
| **03** | [TypeScript Application Development](docs/03-typescript-application-development.md) | ✅ Complete |
| **04** | [Docker Fundamentals](docs/04-docker-fundamentals.md) | ✅ Complete |
| **05** | [Dockerfiles & Multi-Stage Builds](docs/05-dockerfiles-and-containerization.md) | ✅ Complete |
| **06** | [Docker Compose Multi-Container Orchestration](docs/06-docker-compose.md) | ✅ Complete |
| **07** | [Git & GitHub Actions CI/CD](docs/07-git-and-github-actions.md) | ✅ Complete |
| **08** | [Kubernetes Master Handbook (00 to 09)](docs/kubernetes-guide.md) | ✅ Complete |
| **09** | [Helm Master Handbook](docs/helm-guide.md) | ✅ Complete |
| **10** | [AWS EKS & Terraform Production Guide](docs/aws-eks-guide.md) | ✅ Complete |

---

## 9. 🚀 Local Minikube Execution Runbook (Step-by-Step Practice)

Run the full stack immediately on your local machine using Docker Desktop and Minikube without writing any new files. All manifests are pre-configured in `kubernetes/`.

### Step 1: Start Docker Desktop
1. Launch **Docker Desktop** from your Windows Start Menu or Taskbar.
2. Wait until the whale icon in your system tray shows **Docker Desktop is running**.
3. Verify in PowerShell:
```powershell
docker ps
```
*(Should output table headers `CONTAINER ID   IMAGE   COMMAND ...` with no errors).*

---

### Step 2: Start Minikube with Addons
Run our automation script, which allocates 2 CPUs, 4GB RAM, and enables `ingress` + `metrics-server`:
```powershell
Set-Location -Path "c:\devops"
.\scripts\deploy-minikube.ps1
```
*(Or manually: `minikube start --driver=docker --cpus=2 --memory=4096 --kubernetes-version=v1.30.0`)*

---

### Step 3: Build & Load Docker Images into Minikube
Because Kubernetes pods run inside Minikube's Docker daemon, build and load local images:
```powershell
# 1. Build local frontend and backend images
.\scripts\build-images.ps1

# 2. Transfer images into Minikube's internal cache
minikube image load csec-astu/csec-welcome-backend:latest
minikube image load csec-astu/csec-welcome-frontend:latest

# 3. Verify images are inside Minikube
minikube image ls --format=table | Select-String "csec-welcome"
```

---

### Step 4: Apply & Verify Kubernetes Manifests (Stage-by-Stage)
Apply each directory in sequence, and immediately run the corresponding `kubectl get` command to observe each architectural layer come to life:

```powershell
# 00: Namespace Isolation
kubectl apply -f kubernetes/00-namespace/
kubectl get namespaces csec-learning

# 01: ConfigMaps & Secrets (Configuration Decoupling)
kubectl apply -f kubernetes/01-config/
kubectl get configmap,secret -n csec-learning

# 02: Workloads & Pods (3 Backend Replicas & 2 Frontend Replicas)
kubectl apply -f kubernetes/02-workloads/
kubectl get deployments,replicasets,pods -n csec-learning -o wide

# 03: Networking (ClusterIP with 'csec-backend' & 'backend' DNS aliases, NodePort & Ingress)
kubectl apply -f kubernetes/03-networking/
kubectl get services,ingress -n csec-learning

# 💡 Pro-Tip: If frontend pods were started before networking was applied, restart them immediately:
kubectl rollout restart deployment csec-frontend -n csec-learning

# 04: Storage (StorageClass, PersistentVolume & Claim)
kubectl apply -f kubernetes/04-storage/
kubectl get storageclass,pv,pvc -n csec-learning

# 05: Security (ServiceAccount, RBAC Roles & NetworkIsolation)
kubectl apply -f kubernetes/05-security/
kubectl get serviceaccount,role,rolebinding,networkpolicy -n csec-learning

# 06: Resource Governance (ResourceQuotas & LimitRanges)
kubectl apply -f kubernetes/06-resources/
kubectl get resourcequota,limitrange -n csec-learning

# 07: High Availability (PodDisruptionBudgets & Health Probes)
kubectl apply -f kubernetes/07-availability/
kubectl get poddisruptionbudget,pods -n csec-learning -l app=csec-welcome

# 08: Intelligent Scheduling (Node Affinity & Tolerations)
kubectl apply -f kubernetes/08-scheduling/
kubectl get pods -n csec-learning -o wide --show-labels

# 09: Horizontal Pod Autoscaler (Auto-Scaling based on CPU & Memory)
kubectl apply -f kubernetes/09-advanced/hpa.yaml
kubectl get hpa -n csec-learning
```

---

### 🔍 Master All-in-One Inspection Command
To inspect every active resource across the entire `csec-learning` namespace in a single view:

```powershell
kubectl get all,configmap,secret,ingress,pvc,hpa -n csec-learning
```

*(⚡ Or apply all 10 stages in 1 second using Kustomize: `kubectl apply -k kubernetes/`)*

---

### Step 5: Verify Running Pods & Services
```powershell
# 1. View all running Pods across Frontend and Backend
kubectl get pods -n csec-learning -o wide

# 2. View active Services
kubectl get svc -n csec-learning

# 3. View Horizontal Pod Autoscaler status
kubectl get hpa -n csec-learning
```
**Expected Output:**
```text
NAME                                READY   STATUS    RESTARTS   AGE
csec-backend-7db94c6f9-2x8pl        1/1     Running   0          45s
csec-backend-7db94c6f9-7qjlm        1/1     Running   0          45s
csec-backend-7db94c6f9-w9k2r        1/1     Running   0          45s
csec-frontend-5d8f6cc97-8nv4j       1/1     Running   0          40s
csec-frontend-5d8f6cc97-m2cpx       1/1     Running   0          40s
```

> [!TIP]
> **Troubleshooting Pod Statuses**:
> - **`CrashLoopBackOff` on Frontend**: Nginx was waiting for the backend service DNS. Simply run:  
>   `kubectl rollout restart deployment csec-frontend -n csec-learning`
> - **`ImagePullBackOff`**: Images are not yet loaded in Minikube. Run:  
>   `minikube image load csec-astu/csec-welcome-backend:latest`  
>   `minikube image load csec-astu/csec-welcome-frontend:latest`

---

### Step 6: 🌐 Open & View in Your Browser!

#### Option A: Port-Forwarding (Universal Localhost Access — Recommended for Windows)
Open separate PowerShell terminals and run:
```powershell
# Terminal 1: Frontend Web Portal (Access at http://localhost:8080):
kubectl port-forward svc/csec-frontend -n csec-learning 8080:80

# Terminal 2: Backend API (Access at http://localhost:5000):
kubectl port-forward svc/csec-backend -n csec-learning 5000:5000
```
- 🌐 Frontend Web Portal: 👉 **[http://localhost:8080](http://localhost:8080)**
- 🔌 Backend Welcome API: 👉 **[http://localhost:5000/api/welcome](http://localhost:5000/api/welcome)**
- 🩺 Backend Health API: 👉 **[http://localhost:5000/api/health](http://localhost:5000/api/health)**

#### Option B: Minikube Service URL (Direct Access)
```powershell
minikube service csec-frontend -n csec-learning
```
Minikube will automatically open your default browser to the live **CSEC ASTU Welcome Portal**!

---

### Step 7: 🧪 Self-Healing Test (Demonstrate Kubernetes Power!)
Prove self-healing to yourself and your students:
```powershell
# 1. Grab a running backend pod name
$pod = (kubectl get pods -n csec-learning -l tier=backend -o jsonpath='{.items[0].metadata.name}')

# 2. Deliberately terminate the pod
kubectl delete pod $pod -n csec-learning

# 3. Immediately watch Kubernetes replace it in 2 seconds!
kubectl get pods -n csec-learning -w
```

---

## 10. ⎈ Helm Practice Runbook on Minikube

When practicing with Helm, manage the entire application as a versioned release:

```powershell
# 1. Validate the chart syntax
helm lint .\helm\csec-welcome

# 2. Render templates locally to verify generated YAML
helm template csec-welcome .\helm\csec-welcome -f .\helm\csec-welcome\values-dev.yaml

# 3. Deploy the application release to Minikube using Dev values
helm upgrade --install csec-welcome .\helm\csec-welcome `
  --namespace csec-learning `
  --create-namespace `
  -f .\helm\csec-welcome\values-dev.yaml

# 4. View your active Helm release
helm list -n csec-learning
helm status csec-welcome -n csec-learning
```

---

## 11. 🧹 Local Cleanup (Free Laptop RAM)
When your study or teaching session is complete:
```powershell
.\scripts\cleanup-minikube.ps1
```
*(Stops Minikube and frees your system CPU and memory).*

