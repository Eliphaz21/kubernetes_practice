# Module 01: Project Introduction & Architecture

## Organization: CSEC ASTU – Development Division
### Project: CSEC Welcome – Cloud-Native Kubernetes & DevOps Training Curriculum

---

### Step 1 – What are we learning?
In this module, you are learning the architecture of modern cloud-native web applications. We explore how a decoupled TypeScript frontend and backend communicate via REST APIs, how containerization prepares code for the cloud, and why container orchestration (Kubernetes) and Infrastructure as Code (Terraform) are the foundation of modern software engineering.

### Step 2 – Why do we need it?
In enterprise environments, monolithic applications that mix UI, database, and logic on a single virtual machine fail to scale, suffer from brittle deployments, and are difficult for distributed engineering teams to maintain. By decoupling the frontend (React) and backend (Express) and strictly defining their communication contracts through TypeScript interfaces, we can:
1. Scale the frontend and backend independently based on user traffic.
2. Containerize each tier with tailored operating environments and security boundaries.
3. Deploy updates with zero downtime using Kubernetes rolling deployments.

### Step 3 – What are we going to create?
We are establishing the global architecture blueprint and repository workspace for the **CSEC Welcome** application. This includes:
- Architecture diagram connecting client browsers, Nginx reverse proxy, Node.js API, and Kubernetes orchestration.
- The project root directory structure with separation of concerns.

### Step 4 – Where do we create it?
In your root workspace directory:
`c:\devops\docs\01-project-introduction-and-architecture.md`

### Step 5 – Complete Architecture Specification
```
[User Browser]
       │
       ▼ (HTTP / Port 80)
┌────────────────────────────────────────────────────────┐
│  Kubernetes Pod / Container: Frontend                  │
│  - Static Asset Server (Nginx)                        │
│  - Serves React + Vite + TypeScript Single Page App    │
│  - Proxies requests matching '/api/*' to Backend       │
└───────────────────────┬────────────────────────────────┘
                        │ (Internal Cluster DNS / Port 5000)
                        ▼
┌────────────────────────────────────────────────────────┐
│  Kubernetes Pod / Container: Backend                   │
│  - Node.js + Express + TypeScript API                  │
│  - Exposes:                                            │
│    • GET /api/welcome (Community payload)              │
│    • GET /api/health  (Liveness probe)                 │
│    • GET /api/ready   (Readiness probe)                │
└────────────────────────────────────────────────────────┘
```

### Step 6 – Code Explanation
- **Frontend Layer**: React generates a compiled client-side single page application (SPA). Nginx acts as the lightweight web server serving static `.html`, `.js`, and `.css` bundles.
- **Reverse Proxy**: Instead of hardcoding cloud backend IP addresses into frontend client code, Nginx proxies requests made to `/api/*` directly to the backend service name.
- **Backend Layer**: A stateless Node.js HTTP service built in strict TypeScript. It implements operational probes (`/api/health` and `/api/ready`) required by Kubernetes kubelet to manage pod lifecycle.

### Step 7 – Execute
Open PowerShell and verify your root repository structure:
```powershell
Set-Location -Path "c:\devops"
Get-ChildItem -Name
```

### Step 8 – Expected Result
```
.env.example
.git
.gitignore
backend
docker
docs
frontend
helm
infrastructure
kubernetes
monitoring
README.md
scripts
```

### Step 9 – Verify
Verify that Git tracking is active and clean:
```powershell
git status
```
*Output should show untracked or staged files in the clean workspace.*

### Step 10 – Troubleshoot
- **Problem**: `git : The term 'git' is not recognized`
  - **Solution**: Install Git for Windows via `winget install --id Git.Git -e --source winget` and restart PowerShell.
- **Problem**: Folder path mismatch
  - **Solution**: Confirm current directory using `Get-Location`. Ensure you are working in `c:\devops`.

### Step 11 – Practice
Draw or write out what happens when a student navigates to `http://localhost:5173/api/health`. Trace the request path from client to backend.

### Step 12 – Cleanup
No temporary resources were created in this module.

### Step 13 – Production Connection
In real-world companies like Google, Amazon, and Netflix, frontend static assets are served through CDNs (CloudFront, Cloudflare) backed by containerized API microservices running in Kubernetes clusters spread across multiple availability zones.

