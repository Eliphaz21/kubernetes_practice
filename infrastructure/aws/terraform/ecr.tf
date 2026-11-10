# ==============================================================================
# CSEC ASTU - AWS Elastic Container Registry (ECR)
# Secure, private container registries with automatic vulnerability scanning
# ==============================================================================

# 1. ECR Repository for Backend Image
resource "aws_ecr_repository" "backend" {
  name                 = "csec-welcome-backend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "csec-welcome-backend-ecr"
    Tier = "backend"
  }
}

# 2. ECR Repository for Frontend Image
resource "aws_ecr_repository" "frontend" {
  name                 = "csec-welcome-frontend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "csec-welcome-frontend-ecr"
    Tier = "frontend"
  }
}

# 3. Lifecycle Policy: Retain only the 10 most recent images to save cloud storage cost
resource "aws_ecr_lifecycle_policy" "backend_policy" {
  repository = aws_ecr_repository.backend.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 30
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "aws_ecr_lifecycle_policy" "frontend_policy" {
  repository = aws_ecr_repository.frontend.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 30
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
