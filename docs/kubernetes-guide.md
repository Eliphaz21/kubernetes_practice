# CSEC ASTU – Complete Kubernetes Hands-On Practice Handbook

Welcome to the definitive hands-on Kubernetes training manual for the **CSEC ASTU (Computer Science & Engineering Club, Adama Science and Technology University) – Development Division**.

---

## 🎯 How Students Should Use This Handbook

> [!IMPORTANT]
> **Zero-Indentation-Error Guaranteed**:
> YAML files are strictly sensitive to spacing and indentation. To make copying 100% error-proof, **every single step below gives you two options**:
> - **Option 1 (Recommended - 1-Click Terminal Command)**: Copy and paste the provided PowerShell `@' ... '@ | Set-Content` command into your terminal. It creates the folder and writes the file with **exact, verified indentation automatically**.
> - **Option 2 (Manual File Creation)**: Create the file manually in VS Code and copy the standard YAML block.

---

## 🗺️ Master Directory Blueprint

When you finish following this guide, your `kubernetes/` directory will look exactly like this:

```
kubernetes/
│
├── 00-namespace/
│   └── namespace.yaml                  # Dedicated csec-learning namespace
│
├── 01-config/
│   ├── configmap.yaml                  # Decoupled backend & frontend environment configs
│   └── secret.yaml                     # Secure credentials template (Base64)
│
├── 02-workloads/
│   ├── backend-deployment.yaml         # Express API deployment (2 replicas, probes, non-root)
│   └── frontend-deployment.yaml        # React SPA deployment (2 replicas, Nginx web server)
│
├── 03-networking/
│   ├── backend-service.yaml            # Internal ClusterIP service (port 5000)
│   ├── frontend-service.yaml           # External NodePort service (port 80 / nodePort 30080)
│   └── ingress.yaml                    # Nginx Ingress routing csec.local (/ and /api)
│
├── 04-storage/
│   ├── storageclass.yaml               # Dynamic volume provisioner definition
│   ├── pv-demo.yaml                    # Cluster-level PersistentVolume demonstration
│   └── pvc-demo.yaml                   # PersistentVolumeClaim and demo writer Pod
│
├── 05-security/
│   ├── serviceaccount.yaml             # Dedicated application ServiceAccount identity
│   ├── rbac.yaml                       # Least-privilege Role and RoleBinding
│   └── networkpolicy.yaml              # Zero-Trust network isolation for backend
│
├── 06-resources/
│   ├── resourcequota.yaml              # Namespace-level CPU, memory, and pod limits
│   └── limitrange.yaml                 # Container default requests and maximum constraints
│
├── 07-availability/
│   ├── pdb.yaml                        # PodDisruptionBudget ensuring zero-downtime during maintenance
│   └── probes-demo.yaml                # Lifecycle testing pod (Startup, Liveness, Readiness)
│
├── 08-scheduling/
│   ├── node-affinity.yaml              # Soft and hard node affinity placement rules
│   └── taints-tolerations.yaml         # Dedicated node isolation and tolerations
│
├── 09-advanced/
│   ├── hpa.yaml                        # Horizontal Pod Autoscaler (2-6 replicas on 70% CPU)
│   └── kustomization.yaml              # Advanced workloads kustomization
│
└── kustomization.yaml                  # Master Kustomize file deploying the entire cluster
```

---

## Prerequisites: Start Minikube & Load Application Images

Before creating Kubernetes files, initialize your local Minikube cluster and load the Docker images:

### 1. Start Minikube
```powershell
minikube start --driver=docker --cpus=2 --memory=4096 --kubernetes-version=v1.30.0
```

### 2. Enable Required Addons
```powershell
minikube addons enable ingress
minikube addons enable metrics-server
```

### 3. Build & Load Application Images into Minikube
Minikube runs inside its own isolated Docker container. To make your local images available to Minikube without pushing to the internet:
```powershell
cd c:\devops

# 1. Build local container images
.\scripts\build-images.ps1 -Tag "latest"

# 2. Load images into Minikube's internal cache
minikube image load csec-astu/csec-welcome-backend:latest
minikube image load csec-astu/csec-welcome-frontend:latest

# 3. Verify images are inside Minikube
minikube image ls --format=table | Select-String "csec-welcome"
```

---

## Step 0: Namespace Isolation (`00-namespace/`)

Namespaces divide cluster resources between different projects or environments.

### 0.1 Create File with Verified Indentation (1-Click Copy)
Copy and paste this exact command into PowerShell:

```powershell
New-Item -ItemType Directory -Force -Path "c:\devops\kubernetes\00-namespace"
@'
apiVersion: v1
kind: Namespace
metadata:
  name: csec-learning
  labels:
    organization: csec-astu
    division: development
    environment: training
    app.kubernetes.io/managed-by: manual
'@ | Set-Content -Path "c:\devops\kubernetes\00-namespace\namespace.yaml" -Encoding UTF8
```

*(Or copy raw YAML manually if creating in an editor):*
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: csec-learning
  labels:
    organization: csec-astu
    division: development
    environment: training
    app.kubernetes.io/managed-by: manual
```

### 0.2 Apply & Verify
```powershell
kubectl apply -f c:\devops\kubernetes\00-namespace\namespace.yaml
kubectl get namespaces
```
*Expected Output:* `csec-learning` is listed with status `Active`.

---

## Step 1: Configuration & Secrets (`01-config/`)

Decouples environment variables and credentials from container images.

### 1.1 Create ConfigMap File (1-Click Copy)
Copy and paste this exact command into PowerShell:

```powershell
New-Item -ItemType Directory -Force -Path "c:\devops\kubernetes\01-config"
@'
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
'@ | Set-Content -Path "c:\devops\kubernetes\01-config\configmap.yaml" -Encoding UTF8
```

*(Or copy raw YAML manually):*
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

### 1.2 Create Secret File (1-Click Copy)
Copy and paste this exact command into PowerShell:

```powershell
@'
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
'@ | Set-Content -Path "c:\devops\kubernetes\01-config\secret.yaml" -Encoding UTF8
```

*(Or copy raw YAML manually):*
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

### 1.3 Apply & Verify
```powershell
kubectl apply -f c:\devops\kubernetes\01-config\
kubectl get configmap,secret -n csec-learning
```

---

## Step 2: Workloads & Pods (`02-workloads/`)

Deployments manage Pod replicas, rolling updates, self-healing, and health probes.

### 2.1 Create Backend Deployment File (1-Click Copy)
Copy and paste this exact command into PowerShell:

```powershell
New-Item -ItemType Directory -Force -Path "c:\devops\kubernetes\02-workloads"
@'
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
  revisionHistoryLimit: 5
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
              protocol: TCP
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
            timeoutSeconds: 3
            failureThreshold: 3
          readinessProbe:
            httpGet:
              path: /api/ready
              port: http
            initialDelaySeconds: 5
            periodSeconds: 10
            timeoutSeconds: 2
            failureThreshold: 2
          securityContext:
            allowPrivilegeEscalation: false
            capabilities:
              drop:
                - ALL
          envFrom:
            - configMapRef:
                name: csec-backend-config
            - secretRef:
                name: csec-backend-secret
'@ | Set-Content -Path "c:\devops\kubernetes\02-workloads\backend-deployment.yaml" -Encoding UTF8
```

*(Or copy raw YAML manually):*
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
  revisionHistoryLimit: 5
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
              protocol: TCP
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
            timeoutSeconds: 3
            failureThreshold: 3
          readinessProbe:
            httpGet:
              path: /api/ready
              port: http
            initialDelaySeconds: 5
            periodSeconds: 10
            timeoutSeconds: 2
            failureThreshold: 2
          securityContext:
            allowPrivilegeEscalation: false
            capabilities:
              drop:
                - ALL
          envFrom:
            - configMapRef:
                name: csec-backend-config
            - secretRef:
                name: csec-backend-secret
```

### 2.2 Create Frontend Deployment File (1-Click Copy)
Copy and paste this exact command into PowerShell:

```powershell
@'
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
  revisionHistoryLimit: 5
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
              protocol: TCP
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
            timeoutSeconds: 3
            failureThreshold: 3
          readinessProbe:
            httpGet:
              path: /healthz
              port: http
            initialDelaySeconds: 3
            periodSeconds: 10
            timeoutSeconds: 2
            failureThreshold: 2
          securityContext:
            allowPrivilegeEscalation: false
            capabilities:
              drop:
                - AUDIT_WRITE
                - KILL
          envFrom:
            - configMapRef:
                name: csec-frontend-config
'@ | Set-Content -Path "c:\devops\kubernetes\02-workloads\frontend-deployment.yaml" -Encoding UTF8
```

*(Or copy raw YAML manually):*
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
  revisionHistoryLimit: 5
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
              protocol: TCP
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
            timeoutSeconds: 3
            failureThreshold: 3
          readinessProbe:
            httpGet:
              path: /healthz
              port: http
            initialDelaySeconds: 3
            periodSeconds: 10
            timeoutSeconds: 2
            failureThreshold: 2
          securityContext:
            allowPrivilegeEscalation: false
            capabilities:
              drop:
                - AUDIT_WRITE
                - KILL
          envFrom:
            - configMapRef:
                name: csec-frontend-config
```

### 2.3 Apply & Verify
```powershell
kubectl apply -f c:\devops\kubernetes\02-workloads\
kubectl get deployments -n csec-learning
kubectl get pods -n csec-learning -o wide
```
*Expected Output:* Both `csec-backend` and `csec-frontend` show 2/2 ready Pods in `Running` status.

---

## Step 3: Networking & Ingress (`03-networking/`)

Provides stable internal service DNS and external HTTP routing.

### 3.1 Create Backend Service File (1-Click Copy)
Copy and paste this exact command into PowerShell:

```powershell
New-Item -ItemType Directory -Force -Path "c:\devops\kubernetes\03-networking"
@'
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
      protocol: TCP
---
apiVersion: v1
kind: Service
metadata:
  name: backend
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
      protocol: TCP
'@ | Set-Content -Path "c:\devops\kubernetes\03-networking\backend-service.yaml" -Encoding UTF8
```

*(Or copy raw YAML manually):*
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
      protocol: TCP
---
apiVersion: v1
kind: Service
metadata:
  name: backend
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
      protocol: TCP
```

### 3.2 Create Frontend Service File (1-Click Copy)
Copy and paste this exact command into PowerShell:

```powershell
@'
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
      protocol: TCP
'@ | Set-Content -Path "c:\devops\kubernetes\03-networking\frontend-service.yaml" -Encoding UTF8
```

*(Or copy raw YAML manually):*
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
      protocol: TCP
```

### 3.3 Create Ingress File (1-Click Copy)
Copy and paste this exact command into PowerShell:

```powershell
@'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: csec-ingress
  namespace: csec-learning
  labels:
    app: csec-welcome
  annotations:
    nginx.ingress.kubernetes.io/proxy-body-size: "10m"
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
spec:
  ingressClassName: nginx
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
'@ | Set-Content -Path "c:\devops\kubernetes\03-networking\ingress.yaml" -Encoding UTF8
```

*(Or copy raw YAML manually):*
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: csec-ingress
  namespace: csec-learning
  labels:
    app: csec-welcome
  annotations:
    nginx.ingress.kubernetes.io/proxy-body-size: "10m"
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
spec:
  ingressClassName: nginx
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

### 3.4 Apply & Verify
```powershell
kubectl apply -f c:\devops\kubernetes\03-networking\
kubectl get services,ingress -n csec-learning
```

### 3.5 Test Live Access in Browser
1. **Via NodePort directly**:
   ```powershell
   minikube service csec-frontend -n csec-learning
   ```
2. **Via Ingress Host (`csec.local`)**:
   - Find your Minikube IP: `minikube ip` (e.g. `192.168.49.2`).
   - Add to `C:\Windows\System32\drivers\etc\hosts`:
     ```text
     192.168.49.2  csec.local
     ```
   - Open browser to **[http://csec.local](http://csec.local)**!

---

## Step 4: Persistent Storage (`04-storage/`)

Demonstrates cluster-managed persistent storage that outlives Pod lifecycles.

### 4.1 Create StorageClass File (1-Click Copy)
Copy and paste this exact command into PowerShell:

```powershell
New-Item -ItemType Directory -Force -Path "c:\devops\kubernetes\04-storage"
@'
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: csec-fast-storage
provisioner: k8s.io/minikube-hostpath
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
'@ | Set-Content -Path "c:\devops\kubernetes\04-storage\storageclass.yaml" -Encoding UTF8
```

*(Or copy raw YAML manually):*
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: csec-fast-storage
provisioner: k8s.io/minikube-hostpath
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
```

### 4.2 Create PersistentVolume Demo File (1-Click Copy)
Copy and paste this exact command into PowerShell:

```powershell
@'
apiVersion: v1
kind: PersistentVolume
metadata:
  name: csec-demo-pv
  labels:
    type: local
    storage-tier: fast
spec:
  capacity:
    storage: 1Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: csec-fast-storage
  hostPath:
    path: /data/csec-storage-demo
'@ | Set-Content -Path "c:\devops\kubernetes\04-storage\pv-demo.yaml" -Encoding UTF8
```

*(Or copy raw YAML manually):*
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: csec-demo-pv
  labels:
    type: local
    storage-tier: fast
spec:
  capacity:
    storage: 1Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: csec-fast-storage
  hostPath:
    path: /data/csec-storage-demo
```

### 4.3 Create PVC & Demo Writer Pod File (1-Click Copy)
Copy and paste this exact command into PowerShell:

```powershell
@'
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: csec-demo-pvc
  namespace: csec-learning
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
  storageClassName: csec-fast-storage
---
apiVersion: v1
kind: Pod
metadata:
  name: csec-storage-writer-pod
  namespace: csec-learning
  labels:
    app: storage-demo
spec:
  containers:
    - name: writer
      image: busybox:1.36
      command: ["/bin/sh", "-c"]
      args:
        - while true; do
            echo "$(date) - CSEC ASTU persistent data write" >> /data/audit.log;
            sleep 10;
          done
      volumeMounts:
        - name: persistent-storage
          mountPath: /data
  volumes:
    - name: persistent-storage
      persistentVolumeClaim:
        claimName: csec-demo-pvc
'@ | Set-Content -Path "c:\devops\kubernetes\04-storage\pvc-demo.yaml" -Encoding UTF8
```

*(Or copy raw YAML manually):*
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: csec-demo-pvc
  namespace: csec-learning
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
  storageClassName: csec-fast-storage
---
apiVersion: v1
kind: Pod
metadata:
  name: csec-storage-writer-pod
  namespace: csec-learning
  labels:
    app: storage-demo
spec:
  containers:
    - name: writer
      image: busybox:1.36
      command: ["/bin/sh", "-c"]
      args:
        - while true; do
            echo "$(date) - CSEC ASTU persistent data write" >> /data/audit.log;
            sleep 10;
          done
      volumeMounts:
        - name: persistent-storage
          mountPath: /data
  volumes:
    - name: persistent-storage
      persistentVolumeClaim:
        claimName: csec-demo-pvc
```

### 4.4 Apply & Verify
```powershell
kubectl apply -f c:\devops\kubernetes\04-storage\
kubectl get pv,pvc -n csec-learning
```

---

## Step 5: Cluster Security, RBAC & Zero-Trust (`05-security/`)

Enforces Least-Privilege service accounts and network segmentation.

### 5.1 Create ServiceAccount File (1-Click Copy)
Copy and paste this exact command into PowerShell:

```powershell
New-Item -ItemType Directory -Force -Path "c:\devops\kubernetes\05-security"
@'
apiVersion: v1
kind: ServiceAccount
metadata:
  name: csec-app-sa
  namespace: csec-learning
  labels:
    app: csec-welcome
automountServiceAccountToken: false
'@ | Set-Content -Path "c:\devops\kubernetes\05-security\serviceaccount.yaml" -Encoding UTF8
```

*(Or copy raw YAML manually):*
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: csec-app-sa
  namespace: csec-learning
  labels:
    app: csec-welcome
automountServiceAccountToken: false
```

### 5.2 Create RBAC File (1-Click Copy)
Copy and paste this exact command into PowerShell:

```powershell
@'
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: csec-config-reader-role
  namespace: csec-learning
  labels:
    app: csec-welcome
rules:
  - apiGroups: [""]
    resources: ["configmaps"]
    verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: csec-config-reader-binding
  namespace: csec-learning
  labels:
    app: csec-welcome
subjects:
  - kind: ServiceAccount
    name: csec-app-sa
    namespace: csec-learning
roleRef:
  kind: Role
  name: csec-config-reader-role
  apiGroup: rbac.authorization.k8s.io
'@ | Set-Content -Path "c:\devops\kubernetes\05-security\rbac.yaml" -Encoding UTF8
```

*(Or copy raw YAML manually):*
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: csec-config-reader-role
  namespace: csec-learning
  labels:
    app: csec-welcome
rules:
  - apiGroups: [""]
    resources: ["configmaps"]
    verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: csec-config-reader-binding
  namespace: csec-learning
  labels:
    app: csec-welcome
subjects:
  - kind: ServiceAccount
    name: csec-app-sa
    namespace: csec-learning
roleRef:
  kind: Role
  name: csec-config-reader-role
  apiGroup: rbac.authorization.k8s.io
```

### 5.3 Create NetworkPolicy File (1-Click Copy)
Copy and paste this exact command into PowerShell:

```powershell
@'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: csec-backend-network-policy
  namespace: csec-learning
  labels:
    app: csec-welcome
    tier: backend
spec:
  podSelector:
    matchLabels:
      app: csec-welcome
      tier: backend
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: csec-welcome
              tier: frontend
      ports:
        - protocol: TCP
          port: 5000
'@ | Set-Content -Path "c:\devops\kubernetes\05-security\networkpolicy.yaml" -Encoding UTF8
```

*(Or copy raw YAML manually):*
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: csec-backend-network-policy
  namespace: csec-learning
  labels:
    app: csec-welcome
    tier: backend
spec:
  podSelector:
    matchLabels:
      app: csec-welcome
      tier: backend
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: csec-welcome
              tier: frontend
      ports:
        - protocol: TCP
          port: 5000
```

### 5.4 Apply & Verify
```powershell
kubectl apply -f c:\devops\kubernetes\05-security\
kubectl get sa,role,rolebinding,networkpolicy -n csec-learning
```

---

## Step 6: Resource Governance (`06-resources/`)

Protects the cluster against runaway pods and noisy neighbors.

### 6.1 Create ResourceQuota File (1-Click Copy)
Copy and paste this exact command into PowerShell:

```powershell
New-Item -ItemType Directory -Force -Path "c:\devops\kubernetes\06-resources"
@'
apiVersion: v1
kind: ResourceQuota
metadata:
  name: csec-compute-quota
  namespace: csec-learning
  labels:
    app: csec-welcome
spec:
  hard:
    requests.cpu: "2"
    requests.memory: "2Gi"
    limits.cpu: "4"
    limits.memory: "4Gi"
    pods: "10"
    services: "5"
    configmaps: "10"
    secrets: "10"
'@ | Set-Content -Path "c:\devops\kubernetes\06-resources\resourcequota.yaml" -Encoding UTF8
```

*(Or copy raw YAML manually):*
```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: csec-compute-quota
  namespace: csec-learning
  labels:
    app: csec-welcome
spec:
  hard:
    requests.cpu: "2"
    requests.memory: "2Gi"
    limits.cpu: "4"
    limits.memory: "4Gi"
    pods: "10"
    services: "5"
    configmaps: "10"
    secrets: "10"
```

### 6.2 Create LimitRange File (1-Click Copy)
Copy and paste this exact command into PowerShell:

```powershell
@'
apiVersion: v1
kind: LimitRange
metadata:
  name: csec-container-limits
  namespace: csec-learning
spec:
  limits:
    - type: Container
      default:
        cpu: "200m"
        memory: "256Mi"
      defaultRequest:
        cpu: "50m"
        memory: "64Mi"
      max:
        cpu: "1000m"
        memory: "1Gi"
      min:
        cpu: "10m"
        memory: "16Mi"
'@ | Set-Content -Path "c:\devops\kubernetes\06-resources\limitrange.yaml" -Encoding UTF8
```

*(Or copy raw YAML manually):*
```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: csec-container-limits
  namespace: csec-learning
spec:
  limits:
    - type: Container
      default:
        cpu: "200m"
        memory: "256Mi"
      defaultRequest:
        cpu: "50m"
        memory: "64Mi"
      max:
        cpu: "1000m"
        memory: "1Gi"
      min:
        cpu: "10m"
        memory: "16Mi"
```

### 6.3 Apply & Verify
```powershell
kubectl apply -f c:\devops\kubernetes\06-resources\
kubectl describe resourcequota csec-compute-quota -n csec-learning
kubectl describe limitrange csec-container-limits -n csec-learning
```

---

## Step 7: High Availability & Probes (`07-availability/`)

Guarantees application availability during node maintenance.

### 7.1 Create PodDisruptionBudget File (1-Click Copy)
Copy and paste this exact command into PowerShell:

```powershell
New-Item -ItemType Directory -Force -Path "c:\devops\kubernetes\07-availability"
@'
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: csec-backend-pdb
  namespace: csec-learning
  labels:
    app: csec-welcome
    tier: backend
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: csec-welcome
      tier: backend
---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: csec-frontend-pdb
  namespace: csec-learning
  labels:
    app: csec-welcome
    tier: frontend
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: csec-welcome
      tier: frontend
'@ | Set-Content -Path "c:\devops\kubernetes\07-availability\pdb.yaml" -Encoding UTF8
```

*(Or copy raw YAML manually):*
```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: csec-backend-pdb
  namespace: csec-learning
  labels:
    app: csec-welcome
    tier: backend
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: csec-welcome
      tier: backend
---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: csec-frontend-pdb
  namespace: csec-learning
  labels:
    app: csec-welcome
    tier: frontend
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: csec-welcome
      tier: frontend
```

### 7.2 Create Probes Demo File (1-Click Copy)
Copy and paste this exact command into PowerShell:

```powershell
@'
apiVersion: v1
kind: Pod
metadata:
  name: csec-probes-demonstration
  namespace: csec-learning
  labels:
    app: probes-demo
spec:
  containers:
    - name: probe-tester
      image: busybox:1.36
      command: ["/bin/sh", "-c"]
      args:
        - touch /tmp/healthy;
          sleep 60;
          rm -f /tmp/healthy;
          sleep 600;
      startupProbe:
        exec:
          command: ["cat", "/tmp/healthy"]
        initialDelaySeconds: 2
        periodSeconds: 5
        failureThreshold: 10
      livenessProbe:
        exec:
          command: ["cat", "/tmp/healthy"]
        periodSeconds: 5
        failureThreshold: 2
      readinessProbe:
        exec:
          command: ["cat", "/tmp/healthy"]
        periodSeconds: 5
        failureThreshold: 2
'@ | Set-Content -Path "c:\devops\kubernetes\07-availability\probes-demo.yaml" -Encoding UTF8
```

*(Or copy raw YAML manually):*
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: csec-probes-demonstration
  namespace: csec-learning
  labels:
    app: probes-demo
spec:
  containers:
    - name: probe-tester
      image: busybox:1.36
      command: ["/bin/sh", "-c"]
      args:
        - touch /tmp/healthy;
          sleep 60;
          rm -f /tmp/healthy;
          sleep 600;
      startupProbe:
        exec:
          command: ["cat", "/tmp/healthy"]
        initialDelaySeconds: 2
        periodSeconds: 5
        failureThreshold: 10
      livenessProbe:
        exec:
          command: ["cat", "/tmp/healthy"]
        periodSeconds: 5
        failureThreshold: 2
      readinessProbe:
        exec:
          command: ["cat", "/tmp/healthy"]
        periodSeconds: 5
        failureThreshold: 2
```

### 7.3 Apply & Verify
```powershell
kubectl apply -f c:\devops\kubernetes\07-availability\
kubectl get pdb -n csec-learning
```

---

## Step 8: Advanced Scheduling (`08-scheduling/`)

Guides the kube-scheduler on node placement and dedicated node isolation.

### 8.1 Create Node Affinity File (1-Click Copy)
Copy and paste this exact command into PowerShell:

```powershell
New-Item -ItemType Directory -Force -Path "c:\devops\kubernetes\08-scheduling"
@'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: csec-affinity-demo
  namespace: csec-learning
  labels:
    app: affinity-demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: affinity-demo
  template:
    metadata:
      labels:
        app: affinity-demo
    spec:
      affinity:
        nodeAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
            - weight: 80
              preference:
                matchExpressions:
                  - key: disktype
                    operator: In
                    values:
                      - ssd
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: kubernetes.io/os
                    operator: In
                    values:
                      - linux
      containers:
        - name: nginx
          image: nginx:alpine
          ports:
            - containerPort: 80
'@ | Set-Content -Path "c:\devops\kubernetes\08-scheduling\node-affinity.yaml" -Encoding UTF8
```

*(Or copy raw YAML manually):*
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: csec-affinity-demo
  namespace: csec-learning
  labels:
    app: affinity-demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: affinity-demo
  template:
    metadata:
      labels:
        app: affinity-demo
    spec:
      affinity:
        nodeAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
            - weight: 80
              preference:
                matchExpressions:
                  - key: disktype
                    operator: In
                    values:
                      - ssd
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: kubernetes.io/os
                    operator: In
                    values:
                      - linux
      containers:
        - name: nginx
          image: nginx:alpine
          ports:
            - containerPort: 80
```

### 8.2 Create Taints & Tolerations File (1-Click Copy)
Copy and paste this exact command into PowerShell:

```powershell
@'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: csec-toleration-demo
  namespace: csec-learning
  labels:
    app: toleration-demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: toleration-demo
  template:
    metadata:
      labels:
        app: toleration-demo
    spec:
      tolerations:
        - key: "dedicated"
          operator: "Equal"
          value: "production"
          effect: "NoSchedule"
      containers:
        - name: app
          image: busybox:1.36
          command: ["sleep", "3600"]
'@ | Set-Content -Path "c:\devops\kubernetes\08-scheduling\taints-tolerations.yaml" -Encoding UTF8
```

*(Or copy raw YAML manually):*
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: csec-toleration-demo
  namespace: csec-learning
  labels:
    app: toleration-demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: toleration-demo
  template:
    metadata:
      labels:
        app: toleration-demo
    spec:
      tolerations:
        - key: "dedicated"
          operator: "Equal"
          value: "production"
          effect: "NoSchedule"
      containers:
        - name: app
          image: busybox:1.36
          command: ["sleep", "3600"]
```

### 8.3 Apply & Verify
```powershell
kubectl apply -f c:\devops\kubernetes\08-scheduling\
kubectl get deployments -n csec-learning -l "app in (affinity-demo, toleration-demo)"
```

---

## Step 9: Horizontal Pod Autoscaler (`09-advanced/`)

Automatically scales backend replicas between 2 and 6 based on real-time CPU utilization.

### 9.1 Create HPA File (1-Click Copy)
Copy and paste this exact command into PowerShell:

```powershell
New-Item -ItemType Directory -Force -Path "c:\devops\kubernetes\09-advanced"
@'
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: csec-backend-hpa
  namespace: csec-learning
  labels:
    app: csec-welcome
    tier: backend
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: csec-backend
  minReplicas: 2
  maxReplicas: 6
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
        - type: Percent
          value: 100
          periodSeconds: 15
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
        - type: Percent
          value: 50
          periodSeconds: 60
'@ | Set-Content -Path "c:\devops\kubernetes\09-advanced\hpa.yaml" -Encoding UTF8
```

*(Or copy raw YAML manually):*
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: csec-backend-hpa
  namespace: csec-learning
  labels:
    app: csec-welcome
    tier: backend
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: csec-backend
  minReplicas: 2
  maxReplicas: 6
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
        - type: Percent
          value: 100
          periodSeconds: 15
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
        - type: Percent
          value: 50
          periodSeconds: 60
```

### 9.2 Create Advanced Kustomization File (1-Click Copy)
Copy and paste this exact command into PowerShell:

```powershell
@'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ./hpa.yaml
'@ | Set-Content -Path "c:\devops\kubernetes\09-advanced\kustomization.yaml" -Encoding UTF8
```

*(Or copy raw YAML manually):*
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ./hpa.yaml
```

### 9.3 Apply & Verify
```powershell
kubectl apply -f c:\devops\kubernetes\09-advanced\hpa.yaml
kubectl get hpa -n csec-learning
```

---

## Step 10: Master Kustomize Deployment (`kubernetes/kustomization.yaml`)

Allows students to deploy or destroy the entire architecture in a single declarative command.

### 10.1 Create Master Kustomization File (1-Click Copy)
Copy and paste this exact command into PowerShell:

```powershell
@'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: csec-learning

labels:
  - pairs:
      app.kubernetes.io/part-of: csec-welcome
      app.kubernetes.io/managed-by: kustomize

resources:
  - 00-namespace/namespace.yaml
  - 01-config/configmap.yaml
  - 01-config/secret.yaml
  - 02-workloads/backend-deployment.yaml
  - 02-workloads/frontend-deployment.yaml
  - 03-networking/backend-service.yaml
  - 03-networking/frontend-service.yaml
  - 03-networking/ingress.yaml
  - 05-security/serviceaccount.yaml
  - 05-security/rbac.yaml
  - 05-security/networkpolicy.yaml
  - 06-resources/resourcequota.yaml
  - 06-resources/limitrange.yaml
  - 07-availability/pdb.yaml
  - 09-advanced/hpa.yaml
'@ | Set-Content -Path "c:\devops\kubernetes\kustomization.yaml" -Encoding UTF8
```

*(Or copy raw YAML manually):*
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: csec-learning

labels:
  - pairs:
      app.kubernetes.io/part-of: csec-welcome
      app.kubernetes.io/managed-by: kustomize

resources:
  - 00-namespace/namespace.yaml
  - 01-config/configmap.yaml
  - 01-config/secret.yaml
  - 02-workloads/backend-deployment.yaml
  - 02-workloads/frontend-deployment.yaml
  - 03-networking/backend-service.yaml
  - 03-networking/frontend-service.yaml
  - 03-networking/ingress.yaml
  - 05-security/serviceaccount.yaml
  - 05-security/rbac.yaml
  - 05-security/networkpolicy.yaml
  - 06-resources/resourcequota.yaml
  - 06-resources/limitrange.yaml
  - 07-availability/pdb.yaml
  - 09-advanced/hpa.yaml
```

### 10.2 Deploy Everything at Once!
```powershell
kubectl apply -k c:\devops\kubernetes\
kubectl get all,ingress,hpa,pdb,netpol -n csec-learning
```

---

## 🛠️ Complete Student Troubleshooting Matrix

| Symptom | Cause | Solution |
| :--- | :--- | :--- |
| **`ImagePullBackOff`** | Image not loaded into Minikube | Run `minikube image load csec-astu/csec-welcome-backend:latest` |
| **`CrashLoopBackOff`** | Container crashed on startup | Check logs: `kubectl logs <pod-name> -n csec-learning --previous` |
| **`Pending` Pod** | CPU/RAM insufficient or node taint mismatch | Run `kubectl describe pod <pod-name> -n csec-learning` and read the bottom **Events** |
| **`OOMKilled`** | Container exceeded memory limit | Increase `limits.memory` in deployment YAML |
| **Service Connection Refused** | Label selector mismatch | Verify `kubectl get endpoints csec-backend -n csec-learning` shows Pod IPs |
| **Ingress 404** | Ingress addon not enabled | Run `minikube addons enable ingress` |
| **Teardown Cluster** | Clean up all resources | Run `kubectl delete -k c:\devops\kubernetes\` |
