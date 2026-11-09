# AWS Infrastructure as Code (Terraform) Module

This directory contains Terraform modules and configurations developed in **Milestones 15 through 17** for provisioning production cloud infrastructure on Amazon Web Services (AWS).

## Structure
- `terraform/`:
  - `versions.tf`: Pinned Terraform and AWS provider versions.
  - `providers.tf`: AWS provider configuration with default tags.
  - `variables.tf`: Parameterized inputs for VPC CIDR, regions, and cluster sizing.
  - `main.tf`: Root orchestrator calling modules.
  - `networking.tf`: VPC, public/private subnets, Internet Gateway, NAT Gateway.
  - `eks.tf`: Managed AWS EKS cluster with managed node groups.
  - `ecr.tf`: AWS Elastic Container Registry for frontend and backend images.
  - `outputs.tf`: Connection strings, cluster endpoints, and ECR URLs.
  - `terraform.tfvars.example`: Example environment inputs.
- `eks/`: Addon manifests (AWS Load Balancer Controller, EBS CSI Driver).

