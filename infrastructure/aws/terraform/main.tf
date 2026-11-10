# ==============================================================================
# CSEC ASTU - Terraform Root Main Configuration
# Orchestrates VPC Networking, ECR Registries, and AWS EKS Cluster
# ==============================================================================

locals {
  name_prefix = "${var.cluster_name}-${var.environment}"
}
