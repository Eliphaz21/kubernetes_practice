# Kubernetes Manifests Directory

This directory contains declarative Kubernetes YAML manifests developed across **Milestones 7 through 10**.

## Subdirectory Structure
- `00-namespace/`: Cluster tenancy and isolation (`csec-learning` namespace).
- `01-config/`: ConfigMaps and Secrets for environment injection.
- `02-workloads/`: Deployments and ReplicaSets for Frontend and Backend.
- `03-networking/`: Services (ClusterIP, NodePort) and Ingress rules.
- `04-storage/`: PersistentVolumes (PV), PersistentVolumeClaims (PVC), and StorageClasses.
- `05-security/`: RBAC (ServiceAccounts, Roles, RoleBindings) and NetworkPolicies.
- `06-resources/`: ResourceQuotas and LimitRanges.
- `07-availability/`: Probes (liveness, readiness, startup) and PodDisruptionBudgets (PDB).
- `08-scheduling/`: NodeAffinity, PodAffinity, Taints, and Tolerations.
- `09-advanced/`: Horizontal Pod Autoscaler (HPA) and Metrics Server configs.

