# Module 08: Kubernetes Learning Environment Installation

## Organization: CSEC ASTU – Development Division
### Project: CSEC Welcome – Cloud-Native Kubernetes & DevOps Training Curriculum

---

### Step 1 – What are we learning?
In this module, you will install and configure the essential Kubernetes CLI tools and local cluster environment on your workstation:
1. **kubectl**: The official command-line interface for communicating with the Kubernetes API Server.
2. **Minikube**: A tool that runs a local, single-node or multi-node Kubernetes cluster inside Docker on your personal computer.
3. **Helm**: The package manager for Kubernetes (often called "apt/brew for Kubernetes").

### Step 2 – Why do we need it?
Enterprise Kubernetes clusters on cloud providers (like AWS EKS or Google GKE) incur financial costs, require cloud accounts, and have complex IAM access barriers.
**Minikube** provides a 100% faithful, lightweight, free local Kubernetes cluster running on your laptop. Learning on Minikube gives you the exact same `kubectl` commands, YAML manifests, networking behaviors, and API primitives that you will use in production on AWS EKS.

### Step 3 – What are we going to create?
A functioning local Kubernetes learning environment on Windows 11 PowerShell (with macOS and Linux alternatives), verified and ready to run workloads.

### Step 4 – Where do we create it?
Documented at `c:\devops\docs\08-kubernetes-installation.md`.
Automation script provided at `c:\devops\scripts\deploy-minikube.ps1`.

### Step 5 – Complete Installation Commands

#### Primary: Windows 11 (PowerShell Administrator)
```powershell
# 1. Install kubectl CLI
winget install --id Kubernetes.kubectl -e --source winget

# 2. Install Minikube
winget install --id Kubernetes.minikube -e --source winget

# 3. Install Helm Package Manager
winget install --id Helm.Helm -e --source winget
```

#### Alternative: macOS (Homebrew)
```bash
brew install kubectl minikube helm
```

#### Alternative: Linux (Ubuntu / Debian)
```bash
# Install kubectl
sudo apt update && sudo apt install -y curl apt-transport-https ca-certificates
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update && sudo apt install -y kubectl

# Install Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

### Step 6 – Configuration & Resource Allocation
- **Cluster Driver**: We use the `--driver=docker` driver, which runs the entire Kubernetes node as a Docker container.
- **Minimum Requirements**:
  - 2 CPUs
  - 4GB (4096MB) RAM allocated to Minikube
  - 20GB free disk space
- Recommended aliases for PowerShell (add to your `$PROFILE`):
  ```powershell
  Set-Alias -Name k -Value kubectl
  ```

### Step 7 – Execute
Restart PowerShell to refresh your PATH, then start your local cluster:
```powershell
# Verify CLI versions
kubectl version --client
minikube version
helm version

# Start the cluster with 2 CPUs and 4GB RAM
minikube start --driver=docker --cpus=2 --memory=4096 --kubernetes-version=v1.30.0
```

### Step 8 – Expected Result
```text
😄  minikube v1.34.0 on Microsoft Windows 11
✨  Using the docker driver based on user configuration
👍  Starting "minikube" primary control-plane node in "minikube" cluster
🚜  Pulling base image v0.0.45 ...
🔥  Creating docker container (CPUs=2, Memory=4096MB, Disk=20000MB) ...
🐳  Preparing Kubernetes v1.30.0 on containerd 1.7.19 ...
🔎  Verifying Kubernetes components...
🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace.
```

### Step 9 – Verify
Run these commands to confirm that `kubectl` can communicate with your new cluster:
```powershell
# 1. Check cluster endpoints
kubectl cluster-info

# 2. Inspect cluster nodes
kubectl get nodes -o wide

# 3. Check cluster status
minikube status
```
*Expected Output*: Node `minikube` shows status `Ready` running Kubernetes `v1.30.0`.

### Step 10 – Troubleshoot
- **Problem**: `Exiting due to GUEST_PROVISION: Docker daemon is not running`
  - **Solution**: Open Docker Desktop from your Windows Start Menu and wait for the status indicator to turn green.
- **Problem**: `VT-x/AMD-v hardware acceleration is disabled`
  - **Solution**: Enable Virtualization in your computer's BIOS/UEFI settings and enable Hyper-V / WSL2 in Windows Features.

### Step 11 – Practice
Launch the graphical Kubernetes Web Dashboard provided by Minikube:
```powershell
minikube dashboard
```
*A web browser window will open displaying workloads, pods, services, and cluster metrics in an intuitive web UI.*

### Step 12 – Cleanup
When you are finished learning for the day, pause or stop your cluster to free up your computer's RAM:
```powershell
# Gracefully stop the cluster (saves state)
minikube stop

# Or use our automation script:
.\scripts\cleanup-minikube.ps1
```

### Step 13 – Production Connection
In cloud production environments, you will not run Minikube. Instead, cloud providers offer managed control planes (such as AWS EKS, GCP GKE, or Azure AKS) where the Kubernetes master components are automatically managed, patched, and replicated across multiple availability zones by cloud engineers. However, the exact same `kubectl` tool and commands you practice here are identical in production.

