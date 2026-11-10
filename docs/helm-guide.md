# CSEC ASTU – Complete Helm Package Manager Hands-On Practice Handbook

Welcome to the definitive hands-on Helm training manual for the **CSEC ASTU (Computer Science & Engineering Club, Adama Science and Technology University) – Development Division**.

---

## 🎯 How Students Should Use This Handbook

> [!IMPORTANT]
> **Zero-Indentation-Error Guaranteed**:
> Just like the Kubernetes guide, this handbook is designed so that even if the entire `helm/` directory is deleted, you can build the complete production chart from scratch step-by-step:
> - **Option 1 (Recommended - 1-Click Terminal Command)**: Copy and paste the provided PowerShell `@' ... '@ | Set-Content` command into your terminal. It creates the folder and writes each file with **100% exact, verified indentation automatically**.
> - **Option 2 (Manual File Creation)**: Create the file manually in VS Code and copy the standard YAML block.

---

## 🗺️ Master Helm Chart Blueprint

When you finish following this guide, your `helm/csec-welcome/` chart will look exactly like this:

```
helm/csec-welcome/
│
├── Chart.yaml                          # Chart metadata, semantic versioning, maintainers
├── values.yaml                         # Default base configuration values
├── values-dev.yaml                     # Minikube development overrides (1 replica, local images)
├── values-prod.yaml                    # AWS EKS production overrides (3 replicas, AWS ALB)
│
└── templates/                          # Parameterized Kubernetes resource templates
    ├── _helpers.tpl                    # Named template helpers (labels, selectors, names)
    ├── serviceaccount.yaml             # Dedicated application ServiceAccount
    ├── configmap.yaml                  # Decoupled backend and frontend ConfigMaps
    ├── secret.yaml                     # Application Secret template
    ├── backend-service.yaml            # ClusterIP service for Express backend
    ├── frontend-service.yaml           # NodePort service for React frontend
    ├── backend-deployment.yaml         # Backend Deployment (replicated, probes, non-root)
    ├── frontend-deployment.yaml        # Frontend Deployment (Nginx web server)
    ├── ingress.yaml                    # Ingress routing rules (/ and /api)
    ├── hpa.yaml                        # Horizontal Pod Autoscaler template
    └── NOTES.txt                       # Instructive post-installation banner
```

---

## Step 0: Chart Metadata (`Chart.yaml`)

Defines the chart name, description, API version, and semantic versioning.

### 0.1 Create Directory & Chart.yaml (1-Click Copy)
```powershell
New-Item -ItemType Directory -Force -Path "c:\devops\helm\csec-welcome\templates"
@'
apiVersion: v2
name: csec-welcome
description: Production-grade Helm chart for the CSEC ASTU Welcome application (React + Node.js)
type: application
version: 1.0.0
appVersion: "1.0.0"
keywords:
  - csec
  - astu
  - devops
  - kubernetes
  - react
  - express
maintainers:
  - name: CSEC ASTU Development Division
    email: devops@csec-astu.org
'@ | Set-Content -Path "c:\devops\helm\csec-welcome\Chart.yaml" -Encoding UTF8
```

*(Or copy raw YAML manually):*
```yaml
apiVersion: v2
name: csec-welcome
description: Production-grade Helm chart for the CSEC ASTU Welcome application (React + Node.js)
type: application
version: 1.0.0
appVersion: "1.0.0"
keywords:
  - csec
  - astu
  - devops
  - kubernetes
  - react
  - express
maintainers:
  - name: CSEC ASTU Development Division
    email: devops@csec-astu.org
```

---

## Step 1: Base Values (`values.yaml`)

Defines default parameters that can be overridden per environment.

### 1.1 Create values.yaml (1-Click Copy)
```powershell
@'
# Global Configurations
global:
  environment: "production"
  organization: "csec-astu"

# Backend Service (Node.js + Express + TypeScript)
backend:
  replicaCount: 2
  image:
    repository: csec-astu/csec-welcome-backend
    pullPolicy: IfNotPresent
    tag: "latest"
  service:
    type: ClusterIP
    port: 5000
  resources:
    requests:
      cpu: 100m
      memory: 128Mi
    limits:
      cpu: 250m
      memory: 256Mi
  livenessProbe:
    path: /api/health
    initialDelaySeconds: 10
    periodSeconds: 15
  readinessProbe:
    path: /api/ready
    initialDelaySeconds: 5
    periodSeconds: 10
  env:
    PORT: "5000"
    HOST: "0.0.0.0"
    NODE_ENV: "production"
    CORS_ORIGIN: "*"
  secret:
    sessionSecret: "csec-helm-session-secret-key-32chars"
    apiKey: "csec-helm-api-key-2026"

# Frontend Service (React 18 + Nginx SPA)
frontend:
  replicaCount: 2
  image:
    repository: csec-astu/csec-welcome-frontend
    pullPolicy: IfNotPresent
    tag: "latest"
  service:
    type: NodePort
    port: 80
    nodePort: 30080
  resources:
    requests:
      cpu: 50m
      memory: 64Mi
    limits:
      cpu: 150m
      memory: 128Mi
  livenessProbe:
    path: /healthz
    initialDelaySeconds: 5
    periodSeconds: 15
  readinessProbe:
    path: /healthz
    initialDelaySeconds: 3
    periodSeconds: 10
  env:
    APP_ENV: "production"
    APP_TITLE: "CSEC ASTU Development Division"

# Ingress Controller Routing
ingress:
  enabled: true
  className: "nginx"
  annotations:
    nginx.ingress.kubernetes.io/proxy-body-size: "10m"
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
  host: "csec.local"
  tls: []

# Autoscaling (HPA)
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 6
  targetCPUUtilizationPercentage: 70
  targetMemoryUtilizationPercentage: 80

# RBAC & Security
serviceAccount:
  create: true
  name: "csec-app-sa"
'@ | Set-Content -Path "c:\devops\helm\csec-welcome\values.yaml" -Encoding UTF8
```

---

## Step 2: Environment Overrides (`values-dev.yaml` & `values-prod.yaml`)

Separates local Minikube settings from production cloud settings.

### 2.1 Create values-dev.yaml for Minikube (1-Click Copy)
```powershell
@'
global:
  environment: "development"

backend:
  replicaCount: 1
  image:
    repository: csec-astu/csec-welcome-backend
    pullPolicy: IfNotPresent
    tag: "latest"
  resources:
    requests:
      cpu: 50m
      memory: 64Mi
    limits:
      cpu: 150m
      memory: 128Mi

frontend:
  replicaCount: 1
  image:
    repository: csec-astu/csec-welcome-frontend
    pullPolicy: IfNotPresent
    tag: "latest"
  resources:
    requests:
      cpu: 25m
      memory: 32Mi
    limits:
      cpu: 100m
      memory: 64Mi

ingress:
  enabled: true
  className: "nginx"
  host: "csec.local"

autoscaling:
  enabled: false
'@ | Set-Content -Path "c:\devops\helm\csec-welcome\values-dev.yaml" -Encoding UTF8
```

### 2.2 Create values-prod.yaml for AWS EKS (1-Click Copy)
```powershell
@'
global:
  environment: "production"

backend:
  replicaCount: 3
  image:
    repository: ghcr.io/csec-astu/backend
    pullPolicy: Always
    tag: "v1.0.0"
  resources:
    requests:
      cpu: 200m
      memory: 256Mi
    limits:
      cpu: 500m
      memory: 512Mi

frontend:
  replicaCount: 3
  image:
    repository: ghcr.io/csec-astu/frontend
    pullPolicy: Always
    tag: "v1.0.0"
  resources:
    requests:
      cpu: 100m
      memory: 128Mi
    limits:
      cpu: 250m
      memory: 256Mi

ingress:
  enabled: true
  className: "alb"
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}]'
  host: "welcome.csec-astu.org"

autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
'@ | Set-Content -Path "c:\devops\helm\csec-welcome\values-prod.yaml" -Encoding UTF8
```

---

## Step 3: Template Helpers (`templates/_helpers.tpl`)

Defines reusable helper templates to compute resource names and labels consistently.

### 3.1 Create templates/_helpers.tpl (1-Click Copy)
```powershell
@'
{{/*
Expand the name of the chart.
*/}}
{{- define "csec-welcome.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "csec-welcome.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Common labels applied to all resources.
*/}}
{{- define "csec-welcome.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{ include "csec-welcome.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels.
*/}}
{{- define "csec-welcome.selectorLabels" -}}
app.kubernetes.io/name: {{ include "csec-welcome.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
'@ | Set-Content -Path "c:\devops\helm\csec-welcome\templates\_helpers.tpl" -Encoding UTF8
```

---

## Step 4: Parameterized Templates (`templates/`)

### 4.1 ServiceAccount (`templates/serviceaccount.yaml`)
```powershell
@'
{{- if .Values.serviceAccount.create -}}
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ .Values.serviceAccount.name }}
  labels:
    {{- include "csec-welcome.labels" . | nindent 4 }}
automountServiceAccountToken: false
{{- end }}
'@ | Set-Content -Path "c:\devops\helm\csec-welcome\templates\serviceaccount.yaml" -Encoding UTF8
```

### 4.2 ConfigMap (`templates/configmap.yaml`)
```powershell
@'
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "csec-welcome.fullname" . }}-backend-config
  labels:
    {{- include "csec-welcome.labels" . | nindent 4 }}
    tier: backend
data:
  PORT: {{ .Values.backend.env.PORT | quote }}
  HOST: {{ .Values.backend.env.HOST | quote }}
  NODE_ENV: {{ .Values.backend.env.NODE_ENV | quote }}
  CORS_ORIGIN: {{ .Values.backend.env.CORS_ORIGIN | quote }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "csec-welcome.fullname" . }}-frontend-config
  labels:
    {{- include "csec-welcome.labels" . | nindent 4 }}
    tier: frontend
data:
  APP_ENV: {{ .Values.frontend.env.APP_ENV | quote }}
  APP_TITLE: {{ .Values.frontend.env.APP_TITLE | quote }}
'@ | Set-Content -Path "c:\devops\helm\csec-welcome\templates\configmap.yaml" -Encoding UTF8
```

### 4.3 Secret (`templates/secret.yaml`)
```powershell
@'
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "csec-welcome.fullname" . }}-backend-secret
  labels:
    {{- include "csec-welcome.labels" . | nindent 4 }}
    tier: backend
type: Opaque
stringData:
  SESSION_SECRET: {{ .Values.backend.secret.sessionSecret | quote }}
  API_KEY: {{ .Values.backend.secret.apiKey | quote }}
'@ | Set-Content -Path "c:\devops\helm\csec-welcome\templates\secret.yaml" -Encoding UTF8
```

### 4.4 Backend Deployment (`templates/backend-deployment.yaml`)
```powershell
@'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "csec-welcome.fullname" . }}-backend
  labels:
    {{- include "csec-welcome.labels" . | nindent 4 }}
    tier: backend
spec:
  replicas: {{ .Values.backend.replicaCount }}
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      {{- include "csec-welcome.selectorLabels" . | nindent 6 }}
      tier: backend
  template:
    metadata:
      labels:
        {{- include "csec-welcome.selectorLabels" . | nindent 8 }}
        tier: backend
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        runAsGroup: 1000
        fsGroup: 1000
      containers:
        - name: backend
          image: "{{ .Values.backend.image.repository }}:{{ .Values.backend.image.tag }}"
          imagePullPolicy: {{ .Values.backend.image.pullPolicy }}
          ports:
            - name: http
              containerPort: {{ .Values.backend.service.port }}
              protocol: TCP
          resources:
            {{- toYaml .Values.backend.resources | nindent 12 }}
          livenessProbe:
            httpGet:
              path: {{ .Values.backend.livenessProbe.path }}
              port: http
            initialDelaySeconds: {{ .Values.backend.livenessProbe.initialDelaySeconds }}
            periodSeconds: {{ .Values.backend.livenessProbe.periodSeconds }}
          readinessProbe:
            httpGet:
              path: {{ .Values.backend.readinessProbe.path }}
              port: http
            initialDelaySeconds: {{ .Values.backend.readinessProbe.initialDelaySeconds }}
            periodSeconds: {{ .Values.backend.readinessProbe.periodSeconds }}
          securityContext:
            allowPrivilegeEscalation: false
            capabilities:
              drop:
                - ALL
          envFrom:
            - configMapRef:
                name: {{ include "csec-welcome.fullname" . }}-backend-config
            - secretRef:
                name: {{ include "csec-welcome.fullname" . }}-backend-secret
'@ | Set-Content -Path "c:\devops\helm\csec-welcome\templates\backend-deployment.yaml" -Encoding UTF8
```

### 4.5 Backend Service (`templates/backend-service.yaml`)
```powershell
@'
apiVersion: v1
kind: Service
metadata:
  name: {{ include "csec-welcome.fullname" . }}-backend
  labels:
    {{- include "csec-welcome.labels" . | nindent 4 }}
    tier: backend
spec:
  type: {{ .Values.backend.service.type }}
  selector:
    {{- include "csec-welcome.selectorLabels" . | nindent 4 }}
    tier: backend
  ports:
    - name: http
      port: {{ .Values.backend.service.port }}
      targetPort: {{ .Values.backend.service.port }}
      protocol: TCP
'@ | Set-Content -Path "c:\devops\helm\csec-welcome\templates\backend-service.yaml" -Encoding UTF8
```

### 4.6 Frontend Deployment (`templates/frontend-deployment.yaml`)
```powershell
@'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "csec-welcome.fullname" . }}-frontend
  labels:
    {{- include "csec-welcome.labels" . | nindent 4 }}
    tier: frontend
spec:
  replicas: {{ .Values.frontend.replicaCount }}
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      {{- include "csec-welcome.selectorLabels" . | nindent 6 }}
      tier: frontend
  template:
    metadata:
      labels:
        {{- include "csec-welcome.selectorLabels" . | nindent 8 }}
        tier: frontend
    spec:
      containers:
        - name: frontend
          image: "{{ .Values.frontend.image.repository }}:{{ .Values.frontend.image.tag }}"
          imagePullPolicy: {{ .Values.frontend.image.pullPolicy }}
          ports:
            - name: http
              containerPort: {{ .Values.frontend.service.port }}
              protocol: TCP
          resources:
            {{- toYaml .Values.frontend.resources | nindent 12 }}
          livenessProbe:
            httpGet:
              path: {{ .Values.frontend.livenessProbe.path }}
              port: http
            initialDelaySeconds: {{ .Values.frontend.livenessProbe.initialDelaySeconds }}
            periodSeconds: {{ .Values.frontend.livenessProbe.periodSeconds }}
          readinessProbe:
            httpGet:
              path: {{ .Values.frontend.readinessProbe.path }}
              port: http
            initialDelaySeconds: {{ .Values.frontend.readinessProbe.initialDelaySeconds }}
            periodSeconds: {{ .Values.frontend.readinessProbe.periodSeconds }}
          securityContext:
            allowPrivilegeEscalation: false
            capabilities:
              drop:
                - ALL
          envFrom:
            - configMapRef:
                name: {{ include "csec-welcome.fullname" . }}-frontend-config
'@ | Set-Content -Path "c:\devops\helm\csec-welcome\templates\frontend-deployment.yaml" -Encoding UTF8
```

### 4.7 Frontend Service (`templates/frontend-service.yaml`)
```powershell
@'
apiVersion: v1
kind: Service
metadata:
  name: {{ include "csec-welcome.fullname" . }}-frontend
  labels:
    {{- include "csec-welcome.labels" . | nindent 4 }}
    tier: frontend
spec:
  type: {{ .Values.frontend.service.type }}
  selector:
    {{- include "csec-welcome.selectorLabels" . | nindent 4 }}
    tier: frontend
  ports:
    - name: http
      port: {{ .Values.frontend.service.port }}
      targetPort: {{ .Values.frontend.service.port }}
      {{- if and (eq .Values.frontend.service.type "NodePort") .Values.frontend.service.nodePort }}
      nodePort: {{ .Values.frontend.service.nodePort }}
      {{- end }}
      protocol: TCP
'@ | Set-Content -Path "c:\devops\helm\csec-welcome\templates\frontend-service.yaml" -Encoding UTF8
```

### 4.8 Ingress (`templates/ingress.yaml`)
```powershell
@'
{{- if .Values.ingress.enabled -}}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ include "csec-welcome.fullname" . }}-ingress
  labels:
    {{- include "csec-welcome.labels" . | nindent 4 }}
  {{- with .Values.ingress.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- if .Values.ingress.className }}
  ingressClassName: {{ .Values.ingress.className }}
  {{- end }}
  rules:
    - host: {{ .Values.ingress.host | quote }}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: {{ include "csec-welcome.fullname" . }}-frontend
                port:
                  number: {{ .Values.frontend.service.port }}
          - path: /api
            pathType: Prefix
            backend:
              service:
                name: {{ include "csec-welcome.fullname" . }}-backend
                port:
                  number: {{ .Values.backend.service.port }}
{{- end }}
'@ | Set-Content -Path "c:\devops\helm\csec-welcome\templates\ingress.yaml" -Encoding UTF8
```

### 4.9 Horizontal Pod Autoscaler (`templates/hpa.yaml`)
```powershell
@'
{{- if .Values.autoscaling.enabled -}}
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: {{ include "csec-welcome.fullname" . }}-backend-hpa
  labels:
    {{- include "csec-welcome.labels" . | nindent 4 }}
    tier: backend
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{ include "csec-welcome.fullname" . }}-backend
  minReplicas: {{ .Values.autoscaling.minReplicas }}
  maxReplicas: {{ .Values.autoscaling.maxReplicas }}
  metrics:
    {{- if .Values.autoscaling.targetCPUUtilizationPercentage }}
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: {{ .Values.autoscaling.targetCPUUtilizationPercentage }}
    {{- end }}
    {{- if .Values.autoscaling.targetMemoryUtilizationPercentage }}
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: {{ .Values.autoscaling.targetMemoryUtilizationPercentage }}
    {{- end }}
{{- end }}
'@ | Set-Content -Path "c:\devops\helm\csec-welcome\templates\hpa.yaml" -Encoding UTF8
```

### 4.10 Post-Install Notes (`templates/NOTES.txt`)
```powershell
@'
==============================================================================
 CSEC Welcome Application - Deployed via Helm
 Organization: CSEC ASTU - Development Division
 Release:      {{ .Release.Name }}
 Namespace:    {{ .Release.Namespace }}
==============================================================================

1. Check Pod Status:
   kubectl get pods -n {{ .Release.Namespace }} -l "app.kubernetes.io/instance={{ .Release.Name }}"

2. Check Ingress / External Access:
{{- if .Values.ingress.enabled }}
   Add to your hosts file if using Minikube:
   $(minikube ip)  {{ .Values.ingress.host }}

   Then open in your browser:
   http://{{ .Values.ingress.host }}
{{- else }}
   NodePort Access (Minikube):
   minikube service {{ include "csec-welcome.fullname" . }}-frontend -n {{ .Release.Namespace }}
{{- end }}

3. Check API Endpoints:
   curl http://{{ .Values.ingress.host }}/api/health
   curl http://{{ .Values.ingress.host }}/api/welcome
'@ | Set-Content -Path "c:\devops\helm\csec-welcome\templates\NOTES.txt" -Encoding UTF8
```

---

## Step 5: Testing, Linting & Live Release Management

### 5.1 Lint the Chart
```powershell
helm lint c:\devops\helm\csec-welcome
```
*Expected Output:* `1 chart(s) linted, 0 chart(s) failed`.

### 5.2 Test Template Rendering
```powershell
helm template csec-test c:\devops\helm\csec-welcome -f c:\devops\helm\csec-welcome\values-dev.yaml
```

### 5.3 Install Chart onto Minikube
```powershell
helm install csec-welcome c:\devops\helm\csec-welcome `
  --namespace csec-learning `
  --create-namespace `
  -f c:\devops\helm\csec-welcome\values-dev.yaml
```

### 5.4 Verify Release Status
```powershell
helm list -n csec-learning
kubectl get pods,svc,ingress -n csec-learning
```

### 5.5 Perform a Live Helm Upgrade (Scale backend to 3 replicas)
```powershell
helm upgrade csec-welcome c:\devops\helm\csec-welcome `
  --namespace csec-learning `
  --set backend.replicaCount=3
```
*Notice: Helm triggers a rolling update and creates a new revision!*

### 5.6 View Revision History & Rollback
```powershell
# View history
helm history csec-welcome -n csec-learning

# Rollback to revision 1
helm rollback csec-welcome 1 -n csec-learning
```

### 5.7 Uninstall Release
```powershell
helm uninstall csec-welcome -n csec-learning
```

---

## 🛠️ Helm Troubleshooting Matrix

| Symptom | Cause | Solution |
| :--- | :--- | :--- |
| **`helm: command not found`** | Helm CLI not installed | Run `winget install --id Helm.Helm -e --source winget` and reopen terminal |
| **`error: values.yaml parse error`** | Indentation error in values file | Run `helm lint` to pinpoint the invalid line |
| **`release: already exists`** | Name already in use in that namespace | Use `helm upgrade --install` or choose a different release name |
| **`nil pointer evaluating interface`** | Missing required key in values.yaml | Check your template parameter names against `values.yaml` |
