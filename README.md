# CSEC ASTU – Complete Kubernetes, Docker, Helm, Terraform and AWS EKS Hands-On Training

Welcome to the official practical DevOps curriculum repository for **CSEC ASTU (Computer Science and Engineering Club, Adama Science and Technology University) – Development Division**.

This repository is a comprehensive, production-grade, end-to-end curriculum designed to take students from zero knowledge to architecting, deploying, and monitoring cloud-native applications on **AWS EKS** using modern industry-standard DevOps tools.

---

## 1. Project Overview: CSEC Welcome Application

The core application used throughout this training is **CSEC Welcome**, a clean, responsive TypeScript application consisting of:
- **Frontend**: React 18, Vite, TypeScript, and CSS. A clean, minimal university community landing page.
- **Backend**: Node.js, Express, TypeScript. Provides typed REST API endpoints (`/api/welcome`, `/api/health`, `/api/ready`).

The application is purposefully simple to maximize focus on infrastructure, containerization, orchestration, automation, and security.

---

## 2. Professional Repository Structure

```
csec-kubernetes-learning/
│
├── frontend/                     # React + Vite + TypeScript Frontend
│   ├── src/
│   │   ├── components/           # UI Components (Welcome.tsx)
│   │   ├── services/             # API clients (api.ts)
│   │   ├── types/                # TypeScript types & interfaces
│   │   ├── App.tsx               # App entry component
│   │   ├── main.tsx              # React DOM mounting
│   │   └── index.css             # Professional minimal styling
│   ├── index.html                # HTML entrypoint
│   ├── tsconfig.json             # TypeScript compiler configuration
│   ├── vite.config.ts            # Vite bundler & dev proxy config
│   ├── package.json              # Frontend dependencies and scripts
│   ├── Dockerfile                # Multi-stage production container build (Milestone 2)
│   ├── nginx.conf                # Nginx web server and reverse proxy config (Milestone 2)
│   └── .dockerignore             # Docker build exclusion rules
│
├── backend/                      # Node.js + Express + TypeScript API
│   ├── src/
│   │   ├── routes/               # API routes (welcome.routes.ts)
│   │   ├── controllers/          # Business logic handlers (welcome.controller.ts)
│   │   ├── types/                # Request & response types (welcome.types.ts)
│   │   ├── middleware/           # Error handling & logging middleware
│   │   ├── app.ts                # Express application configuration
│   │   └── server.ts             # HTTP server entrypoint with graceful shutdown
│   ├── tests/                    # Automated API & health check tests
│   │   └── health.test.ts
│   ├── tsconfig.json             # Strict TypeScript compiler configuration
│   ├── package.json              # Backend dependencies and scripts
│   ├── Dockerfile                # Multi-stage container build (Milestone 2)
│   └── .dockerignore             # Docker build exclusion rules
│
├── docker/                       # Docker architecture guides and exercise notes
│   └── README.md
│
├── kubernetes/                   # Raw Kubernetes Declarative Manifests
│   ├── 00-namespace/             # Isolated namespace definition
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
├── scripts/                      # PowerShell automation scripts for students
│   ├── build-images.ps1          # Image build helper
│   ├── deploy-minikube.ps1       # Local Minikube deployment script
│   ├── cleanup-minikube.ps1      # Local cleanup
│   └── cleanup-aws.ps1           # AWS teardown helper
│
├── docs/                         # Complete 36-Module Notion Curriculum
│   ├── 01-project-introduction-and-architecture.md
│   ├── 02-development-environment-installation.md
│   ├── 03-typescript-application-development.md
│   └── ...
│
├── docker-compose.yaml           # Local multi-container development (Milestone 2)
├── .env.example                  # Environment variables template
├── .gitignore                    # Git tracking ignore rules
└── README.md                     # Root project documentation
```

---

## 3. Curriculum Milestones

| Milestone | Title | Status |
| :---: | :--- | :---: |
| **01** | **TypeScript Application (Frontend + Backend + Tests)** | **In Progress** |
| **02** | Docker & Multi-Stage Containerization | Planned |
| **03** | Git Workflow & GitHub Actions CI/CD | Planned |
| **04** | Kubernetes Learning Environment (Minikube + CLI Tools) | Planned |
| **05** | Kubernetes Core Architecture & Internals | Planned |
| **06** | Complete kubectl Mastery & Cheat Sheet | Planned |
| **07** | Kubernetes Core Resources (Namespaces, Pods, Deployments, Services, Ingress) | Planned |
| **08** | Storage & Workload Types (PV/PVC, StatefulSets, DaemonSets, Jobs) | Planned |
| **09** | Reliability, Probes & Resource Management (HPA, Quotas) | Planned |
| **10** | Kubernetes Security (RBAC, Security Contexts, Network Policies) | Planned |
| **11** | Observability, Logging & Troubleshooting | Planned |
| **12** | Helm Packaging & Release Lifecycle | Planned |
| **13** | Kustomize & GitOps (Argo CD) | Planned |
| **14** | Production-Grade Kubernetes Checklist | Planned |
| **15** | Terraform Fundamentals & Infrastructure as Code | Planned |
| **16** | AWS Fundamentals & EKS Architecture | Planned |
| **17** | Terraform AWS Provisioning (VPC, EKS, ECR, IAM) | Planned |
| **18** | Production Deployment of CSEC Welcome to AWS EKS | Planned |

---

## 4. Getting Started (Milestone 1)

### Prerequisites
- Node.js (v18 or newer, recommended v20+)
- npm (v9 or newer)
- Git

### Quick Start
```powershell
# 1. Setup and run the Backend
cd backend
npm install
npm run build
npm test
npm run dev

# 2. In a separate terminal, setup and run the Frontend
cd frontend
npm install
npm run build
npm run dev
```

Visit the frontend at [http://localhost:5173](http://localhost:5173). The frontend connects to the backend running at [http://localhost:5000](http://localhost:5000).

