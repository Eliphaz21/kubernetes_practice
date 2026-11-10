# ==============================================================================
# CSEC ASTU - AWS Provider Configuration
# Enforces default tags across all provisioned cloud resources
# ==============================================================================
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project      = "csec-welcome"
      Organization = "CSEC ASTU - Development Division"
      ManagedBy    = "Terraform"
      Environment  = var.environment
    }
  }
}
