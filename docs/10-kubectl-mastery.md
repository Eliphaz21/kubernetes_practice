# Module 10: kubectl Mastery & Complete Cheat Sheet

## Organization: CSEC ASTU – Development Division
### Project: CSEC Welcome – Cloud-Native Kubernetes & DevOps Training Curriculum

---

### Step 1 – What are we learning?
In this module, you will master **`kubectl`** (the Kubernetes Command Line Interface). You will learn how to inspect, create, update, troubleshoot, scale, and manage cluster resources from your PowerShell terminal.

---

### Step 2 – Why do we need it?
`kubectl` is the primary tool used by DevOps engineers, Site Reliability Engineers (SREs), and cloud architects to interact with the Kubernetes API Server. Whether diagnosing a crashing container, rolling back a failed deployment, or inspecting cluster network routing, `kubectl` provides the control interface.

---

### Step 3 – What are we going to create?
A complete reference guide, hands-on command tutorial, and practical cheat sheet for every essential `kubectl` command.

---

### Step 4 – Where do we create it?
Documented at `c:\devops\docs\10-kubectl-mastery.md`.

---

### Step 5 – Comprehensive Command Reference

#### 1. Cluster Inspection & Context
- **`kubectl cluster-info`**
  - **Purpose**: Displays the control plane API address and core cluster add-ons.
  - **Syntax**: `kubectl cluster-info`
  - **Expected Output**: `Kubernetes control plane is running at https://127.0.0.1:54321`
- **`kubectl config get-contexts`**
  - **Purpose**: Lists all cluster contexts configured in `~/.kube/config`.
  - **Syntax**: `kubectl config get-contexts`
- **`kubectl config use-context <name>`**
  - **Purpose**: Switches active cluster (e.g. from `minikube` to `csec-astu-eks`).
  - **Syntax**: `kubectl config use-context minikube`

#### 2. Resource Discovery (`get`)
- **`kubectl get nodes -o wide`**
  - **Purpose**: Lists all worker and control plane nodes with OS, kernel, and internal IP.
- **`kubectl get pods -A`**
  - **Purpose**: Lists all Pods across ALL namespaces (`-A` or `--all-namespaces`).
- **`kubectl get pods -n <namespace> -l <label>`**
  - **Purpose**: Filters Pods by namespace and key-value label selector (e.g. `-l app=backend`).
- **`kubectl get deployments,services,ingress -n <namespace>`**
  - **Purpose**: Retrieves multiple resource types in a single query.

#### 3. Deep Diagnosis (`describe`, `logs`, `events`)
- **`kubectl describe pod <pod-name> -n <namespace>`**
  - **Purpose**: Displays deep metadata, container states, IP addresses, resource limits, and the crucial **Events** log at the bottom.
  - **When to use**: Whenever a Pod is stuck in `Pending`, `CrashLoopBackOff`, or `ImagePullBackOff`.
- **`kubectl logs <pod-name> -n <namespace> -c <container-name> -f --tail=100`**
  - **Purpose**: Streams (`-f`) stdout/stderr logs from a specific container.
- **`kubectl logs <pod-name> --previous`**
  - **Purpose**: Dumps logs of a container that just crashed and restarted.
- **`kubectl get events --sort-by='.metadata.creationTimestamp' -n <namespace>`**
  - **Purpose**: Shows recent cluster events chronologically to trace scheduling and mount failures.

#### 4. Interactive Execution (`exec`, `port-forward`)
- **`kubectl exec -it <pod-name> -n <namespace> -- sh`**
  - **Purpose**: Spawns an interactive shell inside a running container for direct troubleshooting.
- **`kubectl port-forward svc/<service-name> 8080:80 -n <namespace>`**
  - **Purpose**: Forwards a local workstation port directly to a Kubernetes Service or Pod, bypassing ingress/firewalls for instant debugging.

#### 5. Declarative Operations (`apply`, `delete`, `explain`)
- **`kubectl apply -f <path-or-directory>`**
  - **Purpose**: Declaratively applies the desired state from YAML files. Creates or updates resources automatically.
  - **Syntax**: `kubectl apply -f ./kubernetes/02-workloads/`
- **`kubectl delete -f <path-or-directory>`**
  - **Purpose**: Gracefully tears down resources defined in a YAML file.
- **`kubectl explain <resource>.<field>`**
  - **Purpose**: Built-in interactive documentation for any Kubernetes API field.
  - **Example**: `kubectl explain deployment.spec.strategy`

#### 6. Rollout & Scaling Management
- **`kubectl scale deployment <name> --replicas=5 -n <namespace>`**
  - **Purpose**: Immediately scales a Deployment to the specified number of Pod replicas.
- **`kubectl rollout status deployment/<name> -n <namespace>`**
  - **Purpose**: Watches the progress of a rolling update in real-time.
- **`kubectl rollout history deployment/<name> -n <namespace>`**
  - **Purpose**: Shows revision history of deployed releases.
- **`kubectl rollout undo deployment/<name> --to-revision=1 -n <namespace>`**
  - **Purpose**: Instantly rolls back to a previous known-good deployment revision.

---

### Step 6 – Complete `kubectl` Quick Cheat Sheet

| Task | Command |
| :--- | :--- |
| **Check Cluster** | `kubectl cluster-info` |
| **List Nodes** | `kubectl get nodes -o wide` |
| **List All Pods** | `kubectl get pods -A` |
| **List Pods in Namespace** | `kubectl get pods -n csec-learning` |
| **Detailed Inspection** | `kubectl describe pod <name> -n <ns>` |
| **Stream Pod Logs** | `kubectl logs -f <name> -n <ns>` |
| **Previous Crashed Logs** | `kubectl logs --previous <name> -n <ns>` |
| **Terminal Inside Pod** | `kubectl exec -it <name> -n <ns> -- sh` |
| **Port Forwarding** | `kubectl port-forward svc/csec-frontend 8080:80 -n <ns>` |
| **Apply Manifests** | `kubectl apply -f <folder>/` |
| **Delete Manifests** | `kubectl delete -f <folder>/` |
| **Scale Deployment** | `kubectl scale deployment csec-backend --replicas=3 -n <ns>` |
| **Rollout Status** | `kubectl rollout status deployment/csec-backend -n <ns>` |
| **Rollback Deployment** | `kubectl rollout undo deployment/csec-backend -n <ns>` |
| **Recent Events** | `kubectl get events --sort-by='.metadata.creationTimestamp' -A` |

---

### Step 7 – Execute
Test basic cluster discovery on your local environment:
```powershell
kubectl cluster-info
kubectl get namespaces
kubectl api-resources --namespaced=true | Select-Object -First 10
```

---

### Step 8 – Expected Result
```text
Kubernetes control plane is running at https://127.0.0.1:xxxxx
CoreDNS is running at https://127.0.0.1:xxxxx/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

NAME              STATUS   AGE
default           Active   1h
kube-node-lease   Active   1h
kube-public       Active   1h
kube-system       Active   1h
```

---

### Step 9 – Verify
Verify you can inspect API definitions using `explain`:
```powershell
kubectl explain pod.spec.containers.resources
```
*Expected Output*: Detailed documentation of `limits` and `requests` for CPU and Memory directly from your cluster's API schema.

---

### Step 10 – Troubleshoot
- **Problem**: `error: You must be logged in to the server (Unauthorized)`
  - **Solution**: Your kubeconfig context expired or certificate changed. Re-authenticate or run `minikube update-context`.
- **Problem**: `Error from server (NotFound): namespaces "csec-learning" not found`
  - **Solution**: The requested namespace has not been created yet. Create it using `kubectl create namespace csec-learning`.

---

### Step 11 – Practice
1. Scale the CoreDNS deployment in `kube-system` to test declarative scaling:
   ```powershell
   kubectl scale deployment coredns -n kube-system --replicas=2
   kubectl get pods -n kube-system -l k8s-app=kube-dns
   ```
2. Scale it back to 1 replica to conserve resources:
   ```powershell
   kubectl scale deployment coredns -n kube-system --replicas=1
   ```

---

### Step 12 – Cleanup
No temporary custom resources were created in this module.

---

### Step 13 – Production Connection
In production SRE environments, `kubectl` is combined with plugins (managed by `krew`), custom contexts (`kubectx`, `kubens`), and read-only RBAC roles to safely audit and debug live multi-cluster environments without risking production outages.
