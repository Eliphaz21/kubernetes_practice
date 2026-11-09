# Helm Package Manager Directory

This directory contains the production-ready Helm chart (`csec-welcome`) created in **Milestone 12**.

## Structure
- `csec-welcome/`: Helm chart for packaging and version-controlling the CSEC application.
  - `Chart.yaml`: Metadata, versioning, and dependencies.
  - `values.yaml`: Default configuration parameters.
  - `values-dev.yaml`: Overrides for local development / Minikube.
  - `values-prod.yaml`: Production-hardened overrides for AWS EKS.
  - `templates/`: Parameterized Kubernetes resource templates.

