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

## 9. 🚀 Interactive Hands-On Runbook (Step-by-Step Execution)

Follow this interactive, zero-ambiguity runbook to deploy, inspect, and test the full application stack on your local machine using **Docker Desktop & Minikube**.

---

### 📋 Student Progress Checklist
- [ ] **Step 1**: Start Docker Desktop & Verify Daemon
- [ ] **Step 2**: Provision Local Minikube Cluster with Addons
- [ ] **Step 3**: Build & Load Local Container Images into Minikube
- [ ] **Step 4**: Apply Architectural Manifests in Dependency Order (00 ➔ 09)
- [ ] **Step 5**: Verify Cluster State (`1/1 Running`)
- [ ] **Step 6**: Launch Live Web Portal in Browser (`http://localhost:8080`)
- [ ] **Step 7**: Execute Chaos Self-Healing & Autoscaling Labs
- [ ] **Step 8**: Practice Versioned Helm Releases

---

### Step 1: Start Docker Desktop
1. Open **Docker Desktop** from your Windows Start Menu or Taskbar.
2. Wait until the Docker whale icon in your system tray indicates **"Docker Desktop is running"**.
3. Verify in your PowerShell terminal:
```powershell
docker ps
```
*Expected Output:* Table headers (`CONTAINER ID   IMAGE   COMMAND ...`) printed with zero errors.

---

### Step 2: Start Minikube with Essential Addons
Run our automated provisioner script to start Minikube with the Docker driver (2 CPUs, 4GB RAM, `metrics-server` & `ingress`):

```powershell
Set-Location -Path "c:\devops"
.\scripts\deploy-minikube.ps1
```

*(Manual fallback if preferred: `minikube start --driver=docker --cpus=2 --memory=4096`)*

---

### Step 3: Build & Load Docker Images into Minikube
Because Kubernetes pods execute inside Minikube's Docker daemon, build and load local images:

```powershell
# 1. Build local Frontend and Backend images
.\scripts\build-images.ps1

# 2. Transfer images into Minikube's internal container cache
minikube image load csec-astu/csec-welcome-backend:latest
minikube image load csec-astu/csec-welcome-frontend:latest

# 3. Verify images are stored safely inside Minikube
minikube image ls --format=table | Select-String "csec-welcome"
```
*Expected Output:*
```text
docker.io/csec-astu/csec-welcome-backend:latest
docker.io/csec-astu/csec-welcome-frontend:latest
```

---

### Step 4: Apply & Inspect Manifests (Stage-by-Stage)

> [!IMPORTANT]
> **Dependency Ordering Principle**:  
> Always apply **Networking (Services)** before **Workloads (Pods)**. This ensures CoreDNS records exist *before* frontend Nginx boots, guaranteeing instant `1/1 Running` statuses with zero startup crashes!

#### 🔹 Stage 00: Namespace Isolation
```powershell
kubectl apply -f kubernetes/00-namespace/
kubectl get namespaces csec-learning
```
*Expected Output:* `csec-learning   Active`

#### 🔹 Stage 01: Configuration & Secrets (Decoupled Config)
```powershell
kubectl apply -f kubernetes/01-config/
kubectl get configmap,secret -n csec-learning
```
*Expected Output:* `csec-backend-config`, `csec-frontend-config`, and `csec-backend-secret` listed.

#### 🔹 Stage 02: Workloads & Pods (Replicas Launching)
```powershell
kubectl apply -f kubernetes/02-workloads/
kubectl get deployments,replicasets,pods -n csec-learning -o wide
```
*Expected Output:* `csec-backend` (2/2 ready) and `csec-frontend` (2/2 ready).

#### 🔹 Stage 03: Networking Services (ClusterIP, NodePort & Ingress)
```powershell
kubectl apply -f kubernetes/03-networking/
kubectl get services,ingress -n csec-learning
```
*Expected Output:* `service/csec-backend` (port 5000), `service/backend` (port 5000 alias), `service/csec-frontend` (port 80:30080), and `ingress/csec-ingress`.

#### 🔹 Stage 04: Storage (Persistent Volumes & Claims)
```powershell
kubectl apply -f kubernetes/04-storage/
kubectl get storageclass,pv,pvc -n csec-learning
```
*Expected Output:* `csec-local-storage` StorageClass, `csec-pv-volume` Bound, `csec-app-pvc` Bound.

#### 🔹 Stage 05: Security & Governance (RBAC & Zero-Trust Network Policy)
```powershell
kubectl apply -f kubernetes/05-security/
kubectl get serviceaccount,role,rolebinding,networkpolicy -n csec-learning
```
*Expected Output:* `csec-service-account`, `csec-app-role`, `csec-app-rolebinding`, `csec-backend-netpol`.

#### 🔹 Stage 06: Resource Governance (ResourceQuotas & LimitRanges)
```powershell
kubectl apply -f kubernetes/06-resources/
kubectl get resourcequota,limitrange -n csec-learning
```
*Expected Output:* `csec-namespace-quota` and `csec-container-limits`.

#### 🔹 Stage 07: High Availability (PodDisruptionBudgets & Probes)
```powershell
kubectl apply -f kubernetes/07-availability/
kubectl get poddisruptionbudget -n csec-learning
```
*Expected Output:* `csec-backend-pdb` and `csec-frontend-pdb` with `MIN AVAILABLE: 1`.

#### 🔹 Stage 08: Intelligent Scheduling (Node Affinity & Tolerations)
```powershell
kubectl apply -f kubernetes/08-scheduling/
kubectl get pods -n csec-learning -o wide --show-labels
```

#### 🔹 Stage 09: Horizontal Pod Autoscaler (HPA Cruise Control)
```powershell
kubectl apply -f kubernetes/09-advanced/hpa.yaml
kubectl get hpa -n csec-learning
```
*Expected Output:* `csec-backend-hpa   Deployment/csec-backend   cpu: 70%, memory: 80%   MIN: 2   MAX: 6`.

---

### 🔍 Master All-in-One Inspection Command
View every active resource across the entire `csec-learning` namespace in one consolidated view:

```powershell
kubectl get all,configmap,secret,ingress,pvc,hpa -n csec-learning
```

*(⚡ Or apply all 10 stages in 1 second using Kustomize: `kubectl apply -k kubernetes/`)*

---

### Step 5: Verify Final Pod Health
```powershell
kubectl get pods -n csec-learning
```
**Expected Clean Output:**
```text
NAME                             READY   STATUS    RESTARTS   AGE
csec-backend-694cb8cb6c-lkbf9    1/1     Running   0          10m
csec-backend-694cb8cb6c-sjkw9    1/1     Running   0          10m
csec-frontend-88cfb6c74-2r9cz    1/1     Running   0          5m
csec-frontend-88cfb6c74-9m8wq    1/1     Running   0          5m
```

> [!TIP]
> **Stale Pod Cleanup**:
> If you have old stopped pods from earlier testing sessions, purge them with:  
> `kubectl delete pod -l tier=frontend -n csec-learning`  
> Kubernetes will immediately spin up fresh, healthy replacement pods in 2 seconds!

---

### Step 6: 🌐 Open & Interact in Your Browser!

#### Method 1: Port-Forwarding (Universal Access — Recommended for Windows)
Open two separate PowerShell tabs:
```powershell
# Terminal 1: Forward Frontend Web Application
kubectl port-forward svc/csec-frontend -n csec-learning 8080:80

# Terminal 2: Forward Backend REST API
kubectl port-forward svc/csec-backend -n csec-learning 5000:5000
```

Now click the live links to test:
* 🌐 **Frontend Web Portal:** 👉 **[http://localhost:8080](http://localhost:8080)**
* 🔌 **Backend Welcome API:** 👉 **[http://localhost:5000/api/welcome](http://localhost:5000/api/welcome)**
* 🩺 **Backend Health API:** 👉 **[http://localhost:5000/api/health](http://localhost:5000/api/health)**
* 🟢 **Backend Readiness API:** 👉 **[http://localhost:5000/api/ready](http://localhost:5000/api/ready)**

#### Method 2: Minikube Service URL (Direct Browser Launch)
```powershell
minikube service csec-frontend -n csec-learning
```

---

### Step 7: 🧪 Interactive Classroom Labs (Demonstrate DevOps Superpowers)

#### Lab A: Kubernetes Self-Healing (Pod Resurrection)
```powershell
# 1. Capture a running backend pod name
$pod = (kubectl get pods -n csec-learning -l tier=backend -o jsonpath='{.items[0].metadata.name}')

# 2. Deliberately terminate the pod
kubectl delete pod $pod -n csec-learning

# 3. Immediately watch Kubernetes replace it in real time!
kubectl get pods -n csec-learning -w
```
*Zero downtime! Client requests continue uninterrupted.*

#### Lab B: Manual Deployment Scaling
```powershell
# Scale backend to 5 replicas
kubectl scale deployment csec-backend -n csec-learning --replicas=5
kubectl get pods -n csec-learning -l tier=backend

# Scale back down to 2 replicas
kubectl scale deployment csec-backend -n csec-learning --replicas=2
```

#### Lab C: Live HPA Stress Test (Autoscaling under load)
```powershell
# In terminal 1: Watch autoscaler metrics
kubectl get hpa csec-backend-hpa -n csec-learning -w

# In terminal 2: Generate fast load
1..1000 | ForEach-Object { curl.exe -s http://localhost:5000/api/welcome > $null }
```
*Watch HPA scale replicas from 2 ➔ 4 ➔ 6 as CPU utilization climbs!*

---

### Step 8: ⎈ Practice with Helm on Minikube

When you are ready to test Helm packaging:

```powershell
# 1. Lint the chart syntax
helm lint .\helm\csec-welcome

# 2. Render templates locally
helm template csec-welcome .\helm\csec-welcome -f .\helm\csec-welcome\values-dev.yaml

# 3. Deploy the application as a Helm release
helm upgrade --install csec-welcome .\helm\csec-welcome `
  --namespace csec-learning `
  --create-namespace `
  -f .\helm\csec-welcome\values-dev.yaml

# 4. View active Helm releases
helm list -n csec-learning
helm status csec-welcome -n csec-learning
```

---

### Step 9: 🧹 One-Click Reset & Cleanup
When you want to stop Minikube and free your laptop's RAM:
```powershell
.\scripts\cleanup-minikube.ps1
```
*(Stops the Minikube cluster and preserves all your code for next time).*
```
*(Stops Minikube and frees your system CPU and memory).*

