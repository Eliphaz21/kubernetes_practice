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

## 7. Kubernetes Hands-On Practice Guide

> 📖 **Primary Student Manual**:  
> For an interactive, zero-to-hero practice guide with complete copy-pasteable YAML files, exact `kubectl` commands, Minikube instructions, and troubleshooting, read:  
> 👉 **[Complete Kubernetes Practice Handbook (docs/kubernetes-guide.md)](docs/kubernetes-guide.md)**

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
| **08-14**| Kubernetes Core to Production | ⏳ Next |
| **15-18**| Terraform IaC & AWS EKS Deployment | Planned |
