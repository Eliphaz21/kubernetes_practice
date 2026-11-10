# Monitoring & Observability Module: Prometheus & Grafana

## CSEC ASTU – Development Division
### Project: CSEC Welcome – Cloud-Native Kubernetes & DevOps Training Curriculum

---

## 1. Observability Architecture
In production Kubernetes, you cannot SSH into individual Pods to check top or free memory. We use:
- **Prometheus**: Time-series database scraping CPU, memory, and HTTP metrics every 15s.
- **kube-state-metrics**: Reports Kubernetes object states (e.g. how many replicas are ready vs requested).
- **Grafana**: Web visualization platform displaying real-time metrics dashboards.

---

## 2. Quick Installation via Helm
Run these commands in PowerShell:

```powershell
# 1. Add Prometheus Community Helm Repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# 2. Install Prometheus Stack into dedicated monitoring namespace
helm install csec-monitoring prometheus-community/kube-prometheus-stack `
  --namespace monitoring `
  --create-namespace `
  -f c:\devops\monitoring\prometheus\prometheus-values.yaml

# 3. Verify Monitoring Pods are Running
kubectl get pods -n monitoring
```

---

## 3. Accessing the Grafana Dashboard

### Open Grafana in your Browser
```powershell
minikube service csec-monitoring-grafana -n monitoring
```
- **Default Username**: `admin`
- **Default Password**: `csec-training-admin-2026`

### Import the CSEC Welcome Dashboard
1. Inside Grafana, click **Dashboards** -> **New** -> **Import**.
2. Click **Upload JSON file** and select:
   `c:\devops\monitoring\grafana\csec-welcome-dashboard.json`.
3. View real-time CPU, memory, and active replicas for your `csec-backend` and `csec-frontend` Pods!
