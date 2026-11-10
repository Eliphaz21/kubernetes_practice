# Module 24: Helm Package Manager & Release Lifecycle

## Organization: CSEC ASTU – Development Division
### Project: CSEC Welcome – Cloud-Native Kubernetes & DevOps Training Curriculum

---

### Step 1 – What are we learning?
In this module, you are learning how to package, parameterize, version, and manage Kubernetes applications using **Helm** (the Kubernetes Package Manager). You will master Helm charts, `values.yaml` environment overrides, template functions, and the complete release lifecycle (`helm install`, `upgrade`, `rollback`, `uninstall`).

---

### Step 2 – Why do we need it?
Deploying raw Kubernetes YAML files has several problems in production:
1. **Hardcoded Values**: If you want to change replicas from 2 to 5 or change an image tag, you must manually edit multiple YAML files.
2. **Environment Duplication**: Development (Minikube), Staging, and Production (AWS EKS) have different resource requirements, ingress annotations, and replica counts. Duplicating raw YAML creates massive copy-paste drift.
3. **No Release History / Rollback**: Kubernetes alone does not track multi-resource atomic rollouts. Helm treats your entire application (Deployments + Services + Ingress + ConfigMaps) as a single versioned release that can be rolled back in one command.

---

### Step 3 – What are we going to create?
A complete, production-grade Helm chart named **`csec-welcome`**:
- `helm/csec-welcome/Chart.yaml`: Chart metadata and semantic versioning.
- `helm/csec-welcome/values.yaml`: Base default configuration.
- `helm/csec-welcome/values-dev.yaml`: Minikube developer overrides (1 replica, local images).
- `helm/csec-welcome/values-prod.yaml`: AWS EKS production overrides (3 replicas, AWS ALB annotations).
- `helm/csec-welcome/templates/`: Parameterized Go templates.

---

### Step 4 – Where do we create it?
Located at `c:\devops\helm\csec-welcome\`.

---

### Step 5 – Complete Command Workflow

```powershell
# 1. Lint the Helm chart for syntax errors
helm lint c:\devops\helm\csec-welcome

# 2. Render templates locally to inspect generated YAML
helm template csec-release c:\devops\helm\csec-welcome -f c:\devops\helm\csec-welcome\values-dev.yaml

# 3. Dry-run installation against cluster
helm install csec-welcome c:\devops\helm\csec-welcome `
  --namespace csec-learning `
  --create-namespace `
  -f c:\devops\helm\csec-welcome\values-dev.yaml `
  --dry-run

# 4. Actual Installation
helm install csec-welcome c:\devops\helm\csec-welcome `
  --namespace csec-learning `
  --create-namespace `
  -f c:\devops\helm\csec-welcome\values-dev.yaml

# 5. List active Helm releases
helm list -n csec-learning

# 6. Upgrade release (e.g. scale backend to 3 replicas)
helm upgrade csec-welcome c:\devops\helm\csec-welcome `
  --namespace csec-learning `
  --set backend.replicaCount=3

# 7. View release revision history
helm history csec-welcome -n csec-learning

# 8. Rollback to revision 1
helm rollback csec-welcome 1 -n csec-learning

# 9. Uninstall release
helm uninstall csec-welcome -n csec-learning
```

---

### Step 6 – Code Explanation
1. **Built-in Objects**:
   - `.Release.Name`: The name assigned to this installation.
   - `.Release.Namespace`: The target namespace.
   - `.Chart.Version`: Chart semantic version from `Chart.yaml`.
   - `.Values`: Key-value pairs supplied in `values.yaml` or via `--set`.
2. **Template Functions**:
   - `{{ include "csec-welcome.fullname" . }}`: Generates consistent names prefixed with the release name.
   - `{{- toYaml .Values.backend.resources | nindent 12 }}`: Dumps YAML blocks with exact 12-space indentation.
3. **Environment Separation**:
   - To deploy to Minikube: pass `-f values-dev.yaml`.
   - To deploy to AWS EKS: pass `-f values-prod.yaml`.

---

### Step 7 – Execute
Test rendering the Helm templates locally using PowerShell:
```powershell
cd c:\devops
helm template test-release .\helm\csec-welcome -f .\helm\csec-welcome\values-dev.yaml | Select-String "kind:"
```

---

### Step 8 – Expected Result
```text
# Source: csec-welcome/templates/serviceaccount.yaml
kind: ServiceAccount
# Source: csec-welcome/templates/configmap.yaml
kind: ConfigMap
# Source: csec-welcome/templates/configmap.yaml
kind: ConfigMap
# Source: csec-welcome/templates/secret.yaml
kind: Secret
# Source: csec-welcome/templates/backend-service.yaml
kind: Service
# Source: csec-welcome/templates/frontend-service.yaml
kind: Service
# Source: csec-welcome/templates/backend-deployment.yaml
kind: Deployment
# Source: csec-welcome/templates/frontend-deployment.yaml
kind: Deployment
# Source: csec-welcome/templates/ingress.yaml
kind: Ingress
```

---

### Step 9 – Verify
Verify that the chart passes `helm lint`:
```powershell
helm lint .\helm\csec-welcome
```
*Expected Output:* `1 chart(s) linted, 0 chart(s) failed`.

---

### Step 10 – Troubleshoot
- **Problem**: `helm : The term 'helm' is not recognized`
  - **Solution**: Install Helm via `winget install --id Helm.Helm -e --source winget` and restart PowerShell.
- **Problem**: `error: values.yaml parse error`
  - **Solution**: Check YAML indentation in your override values file. Run `helm lint` to pinpoint the line number.

---

### Step 11 – Practice
Override the frontend app title on the fly without editing files:
```powershell
helm template demo .\helm\csec-welcome --set frontend.env.APP_TITLE="CSEC ASTU Custom Title" | Select-String "APP_TITLE"
```

---

### Step 12 – Cleanup
```powershell
helm uninstall csec-welcome -n csec-learning
```

---

### Step 13 – Production Connection
In cloud production, companies publish Helm charts to private OCI registries (such as AWS ECR or GitHub Container Registry) and deploy them automatically via GitOps tools (Argo CD or Flux).
