# Module 09: Kubernetes Architecture & Internals

## Organization: CSEC ASTU – Development Division
### Project: CSEC Welcome – Cloud-Native Kubernetes & DevOps Training Curriculum

---

### Step 1 – What are we learning?
In this module, you are learning the internal architecture of **Kubernetes (K8s)** from beginner principles to enterprise mastery. You will explore how the **Control Plane** (the "brain") coordinates with **Worker Nodes** (the "muscle"), what each component does, how the **Reconciliation Loop** enforces desired state, and the exact step-by-step lifecycle of `kubectl apply -f deployment.yaml`.

---

### Step 2 – Why do we need it?
Running containers on a single server with Docker Compose is fragile:
- If a server loses power, your containers die.
- If traffic spikes 1000%, containers cannot automatically replicate across other computers.
- If a container crashes, nothing automatically heals or reschedules it.
Kubernetes is a **Distributed Container Orchestrator**. It abstracts a collection of physical or virtual machines into a single unified computing surface, guaranteeing high availability, auto-scaling, self-healing, and declarative infrastructure management.

---

### Step 3 – What are we going to create?
We will create and analyze the comprehensive architectural model of Kubernetes, inspect control plane and worker components in our live Minikube cluster, and trace real cluster events.

---

### Step 4 – Where do we create it?
Documented at `c:\devops\docs\09-kubernetes-architecture.md`.

---

### Step 5 – Kubernetes Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ CONTROL PLANE (Master Brain)                                                │
│                                                                             │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │ kube-apiserver                                                      │   │
│   │ (The sole front door; validates and processes all REST requests)    │   │
│   └──────┬────────────────┬──────────────────────────┬──────────────────┘   │
│          │                │                          │                      │
│          ▼                ▼                          ▼                      │
│   ┌──────────────┐ ┌──────────────┐          ┌──────────────┐               │
│   │ etcd         │ │ kube-        │          │ kube-        │               │
│   │ (Distributed │ │ scheduler    │          │ controller-  │               │
│   │ key-value DB;│ │ (Decides on  │          │ manager      │               │
│   │ cluster truth│ │ which node a │          │ (Reconciles  │               │
│   │ is saved)    │ │ Pod lands)   │          │ desired state│               │
│   └──────────────┘ └──────────────┘          └──────────────┘               │
└───────────────────────────────────┬─────────────────────────────────────────┘
                                    │ Network Traffic (TLS)
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ WORKER NODE (Computing Muscle)                                              │
│                                                                             │
│   ┌───────────────────────────────┐         ┌───────────────────────────┐   │
│   │ kubelet                       │         │ kube-proxy                │   │
│   │ (Node agent: receives PodSpec,│         │ (Manages iptables/IPVS    │   │
│   │ instructs container runtime)  │         │ for Service IP routing)   │   │
│   └──────────────┬────────────────┘         └───────────────────────────┘   │
│                  │                                                          │
│                  ▼                                                          │
│   ┌───────────────────────────────┐                                         │
│   │ Container Runtime             │                                         │
│   │ (containerd / CRI-O)          │                                         │
│   └──────────────┬────────────────┘                                         │
│                  │                                                          │
│                  ▼                                                          │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │ Pod: csec-welcome                                                   │   │
│   │  [Container: Nginx :80] ◄──► [Container: Node API :5000]            │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

### Step 6 – Component Deep Dive & Analogies

| Component | Layer | Real-World Analogy | Primary Responsibility |
| :--- | :---: | :--- | :--- |
| **`kube-apiserver`** | Control Plane | **The Airport Reception / Front Desk** | Authenticates, authorizes, schema-validates, and processes every single interaction. It is the **only** component allowed to talk directly to `etcd`. |
| **`etcd`** | Control Plane | **The Safe Vault / Immutable Ledger** | A high-performance, strongly consistent, distributed key-value database storing the entire cluster state, secrets, and configurations. |
| **`kube-scheduler`** | Control Plane | **The Resource Dispatcher** | Monitors newly created Pods that have no assigned node. Evaluates CPU/RAM requirements, affinity rules, and taints, then assigns the Pod to the best available node. |
| **`kube-controller-manager`** | Control Plane | **The Thermostat / Quality Officer** | Runs continuous reconciliation loops. If your deployment requests 3 replicas and one dies, it notices the discrepancy and orders a new Pod. |
| **`kubelet`** | Worker Node | **The General Contractor on Site** | An agent running on every worker node. Reads the PodSpec sent by the API Server and commands the container runtime to start or stop containers. |
| **`kube-proxy`** | Worker Node | **The Traffic Police / Switchboard** | Maintains network rules on host nodes, configuring IP routing so Kubernetes Services can route traffic to Pods across the cluster. |
| **Container Runtime** | Worker Node | **The Factory Engine** | The software (e.g. `containerd`) responsible for pulling container images and running container processes via the Container Runtime Interface (CRI). |

---

### Deep Dive: What Happens During `kubectl apply -f deployment.yaml`?

1. **Client Submission**: You execute `kubectl apply -f deployment.yaml`. The `kubectl` CLI translates your YAML into a JSON payload and sends an HTTP POST/PUT request to the `kube-apiserver`.
2. **Authentication & Authorization**: The API Server checks your identity (TLS certificate or bearer token) and validates RBAC permissions.
3. **Admission Control**: Mutating and validating admission webhooks inspect and sanitize the manifest (e.g. injecting sidecars or enforcing security standards).
4. **Persisted in etcd**: The API Server writes the desired Deployment state into `etcd`. Once committed, `kubectl` receives an HTTP 200/201 response (`deployment.apps/csec-welcome created`).
5. **Controller Loop Trigger**: The `Deployment Controller` inside `kube-controller-manager` detects the new Deployment and creates a `ReplicaSet`.
6. **ReplicaSet Controller**: The `ReplicaSet Controller` notices the desired replica count (e.g. 3) and creates 3 unassigned Pod objects in `etcd` (status: `Pending`).
7. **Scheduler Evaluation**: The `kube-scheduler` notices the 3 unassigned Pods. It filters out nodes that lack sufficient CPU/memory or violate affinity rules, scores the remaining nodes, and assigns each Pod to a node by writing the node name to the PodSpec.
8. **Kubelet Execution**: The `kubelet` on the selected worker node detects that a Pod was assigned to it. It calls the local `containerd` runtime via CRI.
9. **Image Pull & Container Start**: `containerd` pulls the images (if not cached), sets up the Linux cgroups and namespaces, mounts volumes, and starts the container processes.
10. **Readiness Probe**: `kubelet` executes readiness checks (`/api/ready`). When healthy, `kube-proxy` adds the Pod's private IP to the Service endpoints, allowing client traffic to flow!

---

### Step 7 – Execute
Inspect the actual control plane components running inside your Minikube cluster:
```powershell
# View control plane pods in the system namespace
kubectl get pods -n kube-system -o wide
```

### Step 8 – Expected Result
```text
NAME                               READY   STATUS    RESTARTS   AGE   NODE
etcd-minikube                      1/1     Running   0          10m   minikube
kube-apiserver-minikube            1/1     Running   0          10m   minikube
kube-controller-manager-minikube   1/1     Running   0          10m   minikube
kube-proxy-abcde                   1/1     Running   0          10m   minikube
kube-scheduler-minikube            1/1     Running   0          10m   minikube
storage-provisioner                1/1     Running   0          10m   minikube
```

### Step 9 – Verify
Query the component status directly from the API Server:
```powershell
kubectl get componentstatuses
```
*(Shows health status of scheduler, controller-manager, and etcd).*

---

### Step 10 – Troubleshoot
- **Problem**: API Server unreachable (`The connection to the server localhost:8443 was refused`)
  - **Solution**: The control plane VM/container crashed. Run `minikube status` to inspect node state, and `minikube start` to revive it.

---

### Step 11 – Practice
Watch cluster events in real-time as components coordinate:
```powershell
kubectl get events --sort-by='.metadata.creationTimestamp' -A
```
Observe how the scheduler and kubelet log their decisions whenever resources are created.

---

### Step 12 – Cleanup
No temporary resources were created.

---

### Step 13 – Production Connection
On **AWS EKS**, Amazon runs and manages the Control Plane (`kube-apiserver`, `etcd`, `kube-scheduler`, `kube-controller-manager`) across multiple AWS Availability Zones behind private network endpoints. You only manage the Worker Nodes (Managed Node Groups or Fargate). However, understanding this exact architecture is what separates junior operators from senior DevOps architects.

