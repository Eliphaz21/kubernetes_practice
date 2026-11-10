# ==============================================================================
# CSEC ASTU - Terraform Outputs
# Connection strings, repository URLs, and kubeconfig command
# ==============================================================================

output "cluster_name" {
  description = "The name of the provisioned AWS EKS Cluster"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "The Kubernetes API server endpoint URL"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = aws_eks_cluster.main.certificate_authority[0].data
  sensitive   = true
}

output "ecr_backend_repository_url" {
  description = "Amazon ECR Repository URL for Backend Container Image"
  value       = aws_ecr_repository.backend.repository_url
}

output "ecr_frontend_repository_url" {
  description = "Amazon ECR Repository URL for Frontend Container Image"
  value       = aws_ecr_repository.frontend.repository_url
}

output "configure_kubectl_command" {
  description = "Exact command to configure local kubectl to connect to this AWS EKS cluster"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.main.name}"
}
