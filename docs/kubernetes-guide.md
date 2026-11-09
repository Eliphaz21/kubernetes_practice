# CSEC ASTU – Complete Kubernetes Hands-On Practice Handbook

Welcome to the definitive hands-on Kubernetes training manual for the **CSEC ASTU (Computer Science & Engineering Club, Adama Science and Technology University) – Development Division**.

---

## 🎯 How Students Should Use This Handbook

> [!IMPORTANT]
> **Zero-to-Hero Interactive Lab**:
> This handbook is designed so you can start with **zero Kubernetes files** on your computer. Follow this document from **Step 1 to Step 10**:
> 1. Create the designated directory.
> 2. Create the YAML file and paste the complete code provided.
> 3. Run the exact `kubectl` commands in PowerShell to apply and verify.
> 4. Test live connectivity and observe how Kubernetes manages the **CSEC Welcome** application.

---

## 🗺️ Learning Roadmap

```
Step 1: Start Minikube & Enable Addons
   │
   ▼
Step 2: Create Isolated Namespace (00-namespace/namespace.yaml)
   │
   ▼
Step 3: Decouple Configuration (01-config/configmap.yaml & secret.yaml)
   │
   ▼
Step 4: Deploy Workloads & Pods (02-workloads/backend & frontend)
   │
   ▼
Step 5: Internal Discovery & Services (03-networking/services)
   │
   ▼
Step 6: External Access via Ingress (03-networking/ingress.yaml)
   │
   ▼
Step 7: Persistent Storage (04-storage/pv, pvc, storageclass)
   │
   ▼
Step 8: Zero-Trust Security & RBAC (05-security/rbac, networkpolicy)
   │
   ▼
Step 9: Resource Governance & HA (06-resources & 07-availability)
   │
   ▼
Step 10: Advanced Autoscaling (09-advanced/hpa.yaml & Kustomize)
```

---

## Step 1: Start the Local Kubernetes Cluster (Minikube)

### 1.1 Start Minikube with Recommended Settings
Open PowerShell as Administrator and run:

```powershell
# Start Minikube with 2 CPUs and 4GB RAM using the Docker driver
minikube start --driver=docker --cpus=2 --memory=4096 --kubernetes-version=v1.30.0
```

### 1.2 Enable Ingress and Metrics Server Addons
```powershell
# Enable Ingress Controller (Nginx)
minikube addons enable ingress

# Enable Metrics Server (needed for HPA autoscaling)
minikube addons enable metrics-server
```

### 1.3 Verify Cluster Health
```powershell
kubectl cluster-info
kubectl get nodes -o wide
```
*Expected*: Node `minikube` is in status `Ready`.

### 1.4 Load Local Application Images into Minikube
To run our local CSEC Welcome images in Minikube without pulling from an external registry:
```powershell
# Build images locally if not already done:
cd c:\devops
.\scripts\build-images.ps1 -Tag "latest"

# Load images into Minikube's internal container cache:
minikube image load csec-astu/csec-welcome-backend:latest
minikube image load csec-astu/csec-welcome-frontend:latest

# Verify images are loaded inside Minikube:
minikube image ls --format=table | Select-String "csec-welcome"
```

---

## Step 2: Namespace Isolation

Namespaces provide logical virtual clusters, separating teams, environments, and workloads.

### 2.1 Create the Directory and File
```powershell
New-Item -ItemType Directory -Force -Path "c:\devops\kubernetes\00-namespace"
New-Item -ItemType File -Force -Path "c:\devops\kubernetes\00-namespace\namespace.yaml"
```

### 2.2 Complete Code (`kubernetes/00-namespace/namespace.yaml`)
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: csec-learning
  labels:
    organization: csec-astu
    division: development
    environment: training
```

### 2.3 Apply & Verify
```powershell
kubectl apply -f c:\devops\kubernetes\00-namespace\namespace.yaml
kubectl get namespaces
```

---

## Step 3: Decoupled Configuration (ConfigMaps & Secrets)

Hardcoding configuration inside containers is an anti-pattern. ConfigMaps store non-sensitive variables; Secrets store sensitive credentials.

### 3.1 Create the Directory and Files
```powershell
New-Item -ItemType Directory -Force -Path "c:\devops\kubernetes\01-config"
New-Item -ItemType File -Force -Path "c:\devops\kubernetes\01-config\configmap.yaml"
New-Item -ItemType File -Force -Path "c:\devops\kubernetes\01-config\secret.yaml"
```

### 3.2 Complete Code: ConfigMap (`kubernetes/01-config/configmap.yaml`)
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: csec-backend-config
  namespace: csec-learning
  labels:
    app: csec-welcome
    tier: backend
data:
  PORT: "5000"
  HOST: "0.0.0.0"
  NODE_ENV: "production"
  CORS_ORIGIN: "*"
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: csec-frontend-config
  namespace: csec-learning
  labels:
    app: csec-welcome
    tier: frontend
data:
  APP_ENV: "production"
  APP_TITLE: "CSEC ASTU Development Division"
```

### 3.3 Complete Code: Secret (`kubernetes/01-config/secret.yaml`)
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: csec-backend-secret
  namespace: csec-learning
  labels:
    app: csec-welcome
    tier: backend
type: Opaque
stringData:
  SESSION_SECRET: "csec-training-super-secret-key-32chars"
  API_KEY: "csec-astu-dev-division-token-2026"
```

### 3.4 Apply & Verify
```powershell
kubectl apply -f c:\devops\kubernetes\01-config\
kubectl get configmap,secret -n csec-learning
```

---

## Step 4: Replicated Workloads (Backend & Frontend Deployments)

Deployments manage Pod lifecycles, self-healing, rolling updates, resource constraints, and health probes.

### 4.1 Create the Directory and Files
```powershell
New-Item -ItemType Directory -Force -Path "c:\devops\kubernetes\02-workloads"
New-Item -ItemType File -Force -Path "c:\devops\kubernetes\02-workloads\backend-deployment.yaml"
New-Item -ItemType File -Force -Path "c:\devops\kubernetes\02-workloads\frontend-deployment.yaml"
```

### 4.2 Complete Code: Backend Deployment (`kubernetes/02-workloads/backend-deployment.yaml`)
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: csec-backend
  namespace: csec-learning
  labels:
    app: csec-welcome
    tier: backend
spec:
  replicas: 2
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: csec-welcome
      tier: backend
  template:
    metadata:
      labels:
        app: csec-welcome
        tier: backend
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        runAsGroup: 1000
        fsGroup: 1000
      containers:
        - name: backend
          image: csec-astu/csec-welcome-backend:latest
          imagePullPolicy: IfNotPresent
          ports:
            - name: http
              containerPort: 5000
          resources:
            requests:
              cpu: 100m
              memory: 128Mi
            limits:
              cpu: 250m
              memory: 256Mi
          livenessProbe:
            httpGet:
              path: /api/health
              port: http
            initialDelaySeconds: 10
            periodSeconds: 15
          readinessProbe:
            httpGet:
              path: /api/ready
              port: http
            initialDelaySeconds: 5
            periodSeconds: 10
          envFrom:
            - configMapRef:
                name: csec-backend-config
            - secretRef:
                name: csec-backend-secret
```

### 4.3 Complete Code: Frontend Deployment (`kubernetes/02-workloads/frontend-deployment.yaml`)
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: csec-frontend
  namespace: csec-learning
  labels:
    app: csec-welcome
    tier: frontend
spec:
  replicas: 2
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: csec-welcome
      tier: frontend
  template:
    metadata:
      labels:
        app: csec-welcome
        tier: frontend
    spec:
      containers:
        - name: frontend
          image: csec-astu/csec-welcome-frontend:latest
          imagePullPolicy: IfNotPresent
          ports:
            - name: http
              containerPort: 80
          resources:
            requests:
              cpu: 50m
              memory: 64Mi
            limits:
              cpu: 150m
              memory: 128Mi
          livenessProbe:
            httpGet:
              path: /healthz
              port: http
            initialDelaySeconds: 5
            periodSeconds: 15
          readinessProbe:
            httpGet:
              path: /healthz
              port: http
            initialDelaySeconds: 3
            periodSeconds: 10
          envFrom:
            - configMapRef:
                name: csec-frontend-config
```

### 4.4 Apply & Verify
```powershell
kubectl apply -f c:\devops\kubernetes\02-workloads\
kubectl get deployments -n csec-learning
kubectl get pods -n csec-learning -o wide
```
*Expected*: All 4 Pods (2 backend, 2 frontend) show status `Running` with `1/1 Ready`.

---

## Step 5: Service Discovery & Internal Routing

Pods are ephemeral; their IP addresses change when destroyed. Services provide stable virtual IPs and DNS names.

### 5.1 Create the Directory and Files
```powershell
New-Item -ItemType Directory -Force -Path "c:\devops\kubernetes\03-networking"
New-Item -ItemType File -Force -Path "c:\devops\kubernetes\03-networking\backend-service.yaml"
New-Item -ItemType File -Force -Path "c:\devops\kubernetes\03-networking\frontend-service.yaml"
```

### 5.2 Complete Code: Backend Service (`kubernetes/03-networking/backend-service.yaml`)
```yaml
apiVersion: v1
kind: Service
metadata:
  name: csec-backend
  namespace: csec-learning
  labels:
    app: csec-welcome
    tier: backend
spec:
  type: ClusterIP
  selector:
    app: csec-welcome
    tier: backend
  ports:
    - name: http
      port: 5000
      targetPort: 5000
```

### 5.3 Complete Code: Frontend Service (`kubernetes/03-networking/frontend-service.yaml`)
```yaml
apiVersion: v1
kind: Service
metadata:
  name: csec-frontend
  namespace: csec-learning
  labels:
    app: csec-welcome
    tier: frontend
spec:
  type: NodePort
  selector:
    app: csec-welcome
    tier: frontend
  ports:
    - name: http
      port: 80
      targetPort: 80
      nodePort: 30080
```

### 5.4 Apply & Verify
```powershell
kubectl apply -f c:\devops\kubernetes\03-networking\backend-service.yaml
kubectl apply -f c:\devops\kubernetes\03-networking\frontend-service.yaml
kubectl get services -n csec-learning
```

### 5.5 Test Direct NodePort Access
In Minikube, test opening the frontend via NodePort:
```powershell
minikube service csec-frontend -n csec-learning
```
*A browser window opens directly to the running React frontend!*

---

## Step 6: External Ingress (Path-Based Routing)

Ingress consolidates routing rules into a single entrypoint, directing `/` to frontend and `/api` to backend.

### 6.1 Create the Ingress File
```powershell
New-Item -ItemType File -Force -Path "c:\devops\kubernetes\03-networking\ingress.yaml"
```

### 6.2 Complete Code (`kubernetes/03-networking/ingress.yaml`)
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: csec-ingress
  namespace: csec-learning
  labels:
    app: csec-welcome
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/proxy-body-size: "10m"
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
spec:
  rules:
    - host: csec.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: csec-frontend
                port:
                  number: 80
          - path: /api
            pathType: Prefix
            backend:
              service:
                name: csec-backend
                port:
                  number: 5000
```

### 6.3 Apply & Configure Local DNS
```powershell
kubectl apply -f c:\devops\kubernetes\03-networking\ingress.yaml
kubectl get ingress -n csec-learning
```

Get your Minikube IP:
```powershell
minikube ip
```
*(e.g., `192.168.49.2`)*

Add this line to `C:\Windows\System32\drivers\etc\hosts` (as Administrator):
```text
192.168.49.2  csec.local
```

Now open your browser and visit: **`http://csec.local`**!

---

## Step 7: Persistent Storage & Volumes

Demonstrates cluster-managed storage that outlives Pod lifecycles.

### 7.1 Create Storage Manifests
```powershell
New-Item -ItemType Directory -Force -Path "c:\devops\kubernetes\04-storage"
New-Item -ItemType File -Force -Path "c:\devops\kubernetes\04-storage\storageclass.yaml"
New-Item -ItemType File -Force -Path "c:\devops\kubernetes\04-storage\pvc-demo.yaml"
```

### 7.2 Apply StorageClass and PVC Demo Pod
```powershell
kubectl apply -f c:\devops\kubernetes\04-storage\
kubectl get pvc -n csec-learning
```

---

## Step 8: Cluster Security, RBAC & NetworkPolicy

Enforces Least Privilege and Zero-Trust network segmentation.

### 8.1 Create Security Directory & Files
```powershell
New-Item -ItemType Directory -Force -Path "c:\devops\kubernetes\05-security"
```
*(Refer to `kubernetes/05-security/serviceaccount.yaml`, `rbac.yaml`, and `networkpolicy.yaml`)*

### 8.2 Apply Security Controls
```powershell
kubectl apply -f c:\devops\kubernetes\05-security\
kubectl get sa,role,rolebinding,networkpolicy -n csec-learning
```

---

## Step 9: Resource Governance & High Availability

Protects the cluster from noisy neighbors and node evictions.

### 9.1 Apply ResourceQuotas, Limits, and PDBs
```powershell
kubectl apply -f c:\devops\kubernetes\06-resources\
kubectl apply -f c:\devops\kubernetes\07-availability\
kubectl get resourcequota,limitrange,pdb -n csec-learning
```

---

## Step 10: Autoscaling & Declarative Kustomize

Enables automatic horizontal scaling when CPU load exceeds 70%.

### 10.1 Apply Autoscaler
```powershell
kubectl apply -f c:\devops\kubernetes\09-advanced\hpa.yaml
kubectl get hpa -n csec-learning
```

### 10.2 Deploy the Entire Architecture with One Command (Kustomize)
Once all files are in place, you can teardown and redeploy the complete infrastructure in a single command:
```powershell
# Deploy everything using Kustomize:
kubectl apply -k c:\devops\kubernetes\

# View complete application status:
kubectl get all,ingress,hpa,pdb,netpol -n csec-learning
```

---

## 🛠️ Complete Troubleshooting Guide for Students

| Symptom | Root Cause | Solution Command |
| :--- | :--- | :--- |
| **`ImagePullBackOff` / `ErrImagePull`** | Minikube cannot find the Docker image | Run `minikube image load csec-astu/csec-welcome-backend:latest` |
| **`CrashLoopBackOff`** | Container process crashed or exited | Inspect logs: `kubectl logs <pod-name> -n csec-learning --previous` |
| **`Pending` Pod** | Node lacks sufficient CPU or RAM | Check events: `kubectl describe pod <pod-name> -n csec-learning` |
| **`OOMKilled` (Exit code 137)** | Container exceeded memory limit | Increase `resources.limits.memory` in the deployment YAML |
| **Backend 404 / Connection Refused** | Service selector does not match Pod labels | Check endpoints: `kubectl get endpoints csec-backend -n csec-learning` |
| **Ingress 404 Not Found** | Ingress addon disabled or host mismatch | Run `minikube addons enable ingress` and verify `csec.local` in hosts file |
