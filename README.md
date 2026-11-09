# CSEC ASTU – Complete Kubernetes, Docker, Helm, Terraform & AWS EKS Training

Welcome to the hands-on DevOps and Cloud-Native training curriculum for the **CSEC ASTU (Computer Science & Engineering Club, Adama Science and Technology University) – Development Division**.

This repository is designed for students to **clone, run, inspect, and deploy** a complete full-stack cloud application, progressing from a clean workstation to production-grade deployment on **Amazon Web Services (AWS EKS)** using Terraform, Helm, Docker, and GitHub Actions.

---

## 📑 Table of Contents
1. [Application Architecture](#1-application-architecture)
2. [Prerequisites](#2-prerequisites)
3. [Method 1: Run Locally with `npm run dev` (Development Mode)](#3-method-1-run-locally-with-npm-run-dev-development-mode)
4. [Method 2: Run with Docker Compose (Containerized Production Simulation)](#4-method-2-run-with-docker-compose-containerized-production-simulation)
5. [Crucial Concept: Why `0.0.0.0` vs `localhost`?](#5-crucial-concept-why-0000-vs-localhost)
6. [API Endpoints Reference](#6-api-endpoints-reference)
7. [Running Tests & Compiling TypeScript](#7-running-tests--compiling-typescript)
8. [Curriculum Roadmap & Student Guides](#8-curriculum-roadmap--student-guides)
9. [Troubleshooting Common Issues](#9-troubleshooting-common-issues)
10. [Repository Structure](#10-repository-structure)

---

## 1. Application Architecture

The application is **CSEC Welcome**, consisting of:
- **Frontend**: React 18, Vite, TypeScript, and minimal CSS. A clean university development community landing page.
- **Backend**: Node.js, Express, TypeScript. Provides typed REST API endpoints (`/api/welcome`, `/api/health`, `/api/ready`).

```
[ Your Web Browser ]
        │
        ▼ (Port 5173 in Dev / Port 8080 in Docker)
┌────────────────────────────────────────────────────────┐
│  Frontend Tier (React + Vite + TypeScript)             │
│  - Dev Mode: Vite Dev Server with HMR (Port 5173)      │
│  - Docker Mode: Nginx Web Server + Reverse Proxy (8080)│
└───────────────────────┬────────────────────────────────┘
                        │ (REST API /api/*)
                        ▼
┌────────────────────────────────────────────────────────┐
│  Backend API Tier (Node.js + Express + TypeScript)     │
│  - Binds on 0.0.0.0:5000                               │
│  - Endpoints:                                          │
│    • GET /api/welcome (Community payload)              │
│    • GET /api/health  (Liveness probe)                 │
│    • GET /api/ready   (Readiness probe)                │
└────────────────────────────────────────────────────────┘
```

---

## 2. Prerequisites

Make sure the following tools are installed on your machine before starting:

| Tool | Recommended Version | Verify Command | Purpose |
| :--- | :---: | :--- | :--- |
| **Node.js** | v20.x or newer | `node -v` | Server runtime & build tools |
| **npm** | v10.x or newer | `npm -v` | JavaScript/TypeScript package manager |
| **Git** | v2.40+ | `git --version` | Version control |
| **Docker Desktop** | Latest | `docker version` | Container engine *(needed for Method 2)* |

> 💡 **Need to install these?** Follow [Module 02: Development Environment Installation](docs/02-development-environment-installation.md).

---

## 3. Method 1: Run Locally with `npm run dev` (Development Mode)

Use this method when you want to edit TypeScript code and see changes instantly via **Hot Module Replacement (HMR)**.

### Step 1: Open Terminal 1 and Start the Backend
Open a PowerShell terminal and run:

```powershell
# 1. Navigate to backend directory
cd c:\devops\backend

# 2. Install dependencies (only needed the first time)
npm install

# 3. Start the backend development server
npm run dev
```

**Expected Terminal Output:**
```text
====================================================
 CSEC Welcome Backend API Server
 Organization: CSEC ASTU - Development Division
 Status:       Running
 Local:        http://localhost:5000
 Bind Host:    http://0.0.0.0:5000
 Endpoints:
   - Root:     http://localhost:5000/
   - Welcome:  http://localhost:5000/api/welcome
   - Health:   http://localhost:5000/api/health
   - Ready:    http://localhost:5000/api/ready
====================================================
```
> ⚠️ **Keep this terminal window open!** If you close it, the server stops.

---

### Step 2: Open Terminal 2 and Start the Frontend
Open a **second PowerShell terminal** and run:

```powershell
# 1. Navigate to frontend directory
cd c:\devops\frontend

# 2. Install dependencies (only needed the first time)
npm install

# 3. Start the frontend development server
npm run dev
```

**Expected Terminal Output:**
```text
  VITE v6.0.7  ready in 250 ms

  ➜  Local:   http://localhost:5173/
  ➜  Network: http://192.168.x.x:5173/
```
> ⚠️ **Keep this second terminal window open as well!**

---

### Step 3: View the Application
Open your browser and navigate to:
👉 **[http://localhost:5173](http://localhost:5173)**

You should see:
- Main heading: **CSEC ASTU**
- Subtitle: **Development Division**
- Welcome message: *"Welcome to the CSEC ASTU Development Division. We learn, build and collaborate to develop software engineering skills and create meaningful technology solutions."*
- A live connection metadata box showing the timestamp received from the backend API.

---

### Step 4: Stop the Local Servers
When you are done, press `Ctrl + C` in both terminal windows and type `Y` to exit.

---

## 4. Method 2: Run with Docker Compose (Containerized Production Simulation)

Use this method to run both tiers exactly as they run in production: inside isolated Linux containers on a private Docker bridge network.

### Step 1: Make Sure Docker Desktop is Running
Start Docker Desktop on your workstation and verify:
```powershell
docker version
```

### Step 2: Build and Launch Containers
From the root project directory (`c:\devops`), run:

```powershell
cd c:\devops
docker compose up --build
```
*(Tip: Add `-d` to run in the background: `docker compose up --build -d`)*

**What Docker is doing automatically:**
1. **Backend**: Builds a multi-stage `node:20-alpine` image, strips development dependencies, and switches to non-root user `node`.
2. **Frontend**: Compiles the React SPA and copies static files into an `nginx:1.27-alpine` web server configured with a reverse proxy for `/api/*`.
3. **Networking**: Connects both containers to an isolated bridge network called `csec-network`.
4. **Health Check**: Waits for backend `/api/health` to turn healthy before opening frontend traffic.

---

### Step 3: View the Containerized Application
Open your browser and navigate to:
👉 **[http://localhost:8080](http://localhost:8080)**

Notice the port is **8080** for Docker Compose! Nginx serves the frontend and transparently proxies all `/api/*` calls to the backend container over internal Docker DNS (`http://backend:5000`).

---

### Step 4: Useful Docker Commands
```powershell
# View running containers and health status
docker compose ps

# View live streaming logs from both containers
docker compose logs -f

# View backend logs only
docker compose logs backend

# Stop and remove containers and networks cleanly
docker compose down
```

---

## 5. Crucial Concept: Why `0.0.0.0` vs `localhost`?

Beginners often get confused when the terminal says `Listening: http://0.0.0.0:5000` instead of `localhost`. Here is why:

- **`0.0.0.0` is for the SERVER (Binding):**
  It tells Windows/Linux: *"Accept incoming connections from **ALL** network interfaces (Wi-Fi, Ethernet, Docker virtual adapters, local machine)."* In Docker and Kubernetes, services **must** bind to `0.0.0.0`, otherwise container port forwarding and cluster routing will fail!
- **`localhost` (or `127.0.0.1`) is for YOUR BROWSER (Connecting):**
  Your browser connects through the loopback interface. You should **always** type `http://localhost:5000` or `http://localhost:5173` in your browser address bar.

---

## 6. API Endpoints Reference

When the backend is running, you can test these endpoints using your browser or PowerShell `curl.exe`:

| Method | Endpoint | Description | Expected Status |
| :---: | :--- | :--- | :---: |
| `GET` | `/` | API root index with friendly links | `200 OK` |
| `GET` | `/api/welcome` | CSEC ASTU community payload & welcome message | `200 OK` |
| `GET` | `/api/health` | Service liveness probe (uptime & status) | `200 OK` |
| `GET` | `/api/ready` | Service readiness probe (readiness check) | `200 OK` |

### Test with PowerShell:
```powershell
curl.exe http://localhost:5000/api/welcome
curl.exe http://localhost:5000/api/health
curl.exe http://localhost:5000/api/ready
```

---

## 7. Running Tests & Compiling TypeScript

Both the frontend and backend use **strict TypeScript**. You can verify that all types and automated integration tests pass:

### 1. Run Backend Automated Tests
```powershell
cd c:\devops\backend
npm test
```
*Executes integration tests verifying status 200, schema types, and 404 handling using Supertest and Node.js test runner.*

### 2. Verify TypeScript Compilation (Type Check)
```powershell
# Backend type check & build
cd c:\devops\backend
npm run build

# Frontend type check & build
cd c:\devops\frontend
npm run build
```
*Both commands should finish with 0 errors and output to their respective `dist/` directories.*

---

## 8. Curriculum Roadmap & Student Guides

Every lesson in `docs/` is structured with our **13-Step Teaching Format** (What, Why, Complete Code, Execute, Verify, Troubleshoot, Practice, Cleanup, Production Connection).

| Module | Title | Topic | Link |
| :---: | :--- | :--- | :---: |
| **01** | Project Introduction & Architecture | System design, decoupling, microservices | [Read Module 01](docs/01-project-introduction-and-architecture.md) |
| **02** | Development Environment Setup | Node.js, npm, Git, VS Code configuration | [Read Module 02](docs/02-development-environment-installation.md) |
| **03** | TypeScript Application Development | React, Express, TS strict mode, probes | [Read Module 03](docs/03-typescript-application-development.md) |
| **04** | Docker Fundamentals | Images vs containers, daemon, CLI mastery | [Read Module 04](docs/04-docker-fundamentals.md) |
| **05** | Dockerfiles & Multi-Stage Builds | Non-root security, Alpine, Nginx proxy | [Read Module 05](docs/05-dockerfiles-and-containerization.md) |
| **06** | Docker Compose Orchestration | Multi-container networking, healthchecks | [Read Module 06](docs/06-docker-compose.md) |
| **07** | Git & GitHub Actions CI/CD | Testing, building, GHCR, security scans | *Milestone 3* |
| **08-14**| Kubernetes Core to Production | Minikube, Pods, Deployments, Services, Helm | *Milestones 4-14* |
| **15-18**| Terraform IaC & AWS EKS | VPC, EKS cluster, ECR, cloud deployment | *Milestones 15-18* |

---

## 9. Troubleshooting Common Issues

### Issue 1: "This site can’t be reached / localhost refused to connect"
- **Cause**: No server process is currently running on that port.
- **Fix**: Open a terminal, run `npm run dev` in `backend` or `frontend`, and **leave that terminal open**.

### Issue 2: `EADDRINUSE: address already in use :::5000`
- **Cause**: An old node process is still occupying port 5000.
- **Fix**: Run in PowerShell to terminate the lingering process:
  ```powershell
  Get-Process -Id (Get-NetTCPConnection -LocalPort 5000).OwningProcess | Stop-Process -Force
  ```

### Issue 3: Docker says `failed to connect to the docker API at npipe`
- **Cause**: Docker Desktop is not started.
- **Fix**: Open Docker Desktop from your Start menu, wait for the whale icon to stabilize, then rerun `docker compose up --build`.

### Issue 4: PowerShell `Execution of scripts is disabled on this system`
- **Cause**: Windows PowerShell security policy blocks local scripts.
- **Fix**: Run in PowerShell as Administrator:
  ```powershell
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
  ```

---

## 10. Repository Structure

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
│   │   ├── index.css             # Restrained, clean university community CSS
│   │   └── vite-env.d.ts         # Vite client type definitions
│   ├── Dockerfile                # Multi-stage production container build
│   ├── nginx.conf                # Nginx web server and /api reverse proxy
│   ├── package.json              # Frontend dependencies and scripts
│   └── tsconfig.json             # TypeScript compiler options
│
├── backend/                      # Node.js + Express + TypeScript REST API
│   ├── src/
│   │   ├── routes/               # Express routes (/api/welcome, health, ready)
│   │   ├── controllers/          # Business logic handlers
│   │   ├── types/                # Strict request/response types
│   │   ├── middleware/           # Centralized 404 and 500 error handlers
│   │   ├── app.ts                # Express app factory with CORS & JSON parsing
│   │   └── server.ts             # Server entrypoint with graceful shutdown
│   ├── tests/                    # Automated integration tests (health.test.ts)
│   ├── Dockerfile                # Multi-stage Alpine container build (non-root)
│   ├── package.json              # Backend dependencies and scripts
│   └── tsconfig.json             # Strict TypeScript compiler options
│
├── docker/                       # Docker architecture guides & cheat sheets
├── kubernetes/                   # Raw Kubernetes manifests (00-09 modules)
├── helm/                         # Helm packaging (csec-welcome chart)
├── monitoring/                   # Prometheus & Grafana observability
├── infrastructure/aws/           # Terraform modules (VPC, EKS, ECR, IAM)
├── scripts/                      # PowerShell automation scripts (build-images.ps1)
├── docs/                         # Complete 36-module student learning curriculum
├── docker-compose.yaml           # Multi-container orchestration specification
├── .env.example                  # Environment variables template
├── .gitignore                    # Git tracking rules
└── README.md                     # This file
```
