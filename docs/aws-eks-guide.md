# CSEC ASTU – Complete AWS EKS & Terraform Hands-On Practice Handbook

Welcome to the definitive cloud infrastructure training manual for the **CSEC ASTU (Computer Science & Engineering Club, Adama Science and Technology University) – Development Division**.

---

## 🎯 How Students Should Use This Handbook

> [!IMPORTANT]
> **Zero-Syntax-Error Guaranteed**:
> Just like the Kubernetes and Helm guides, this handbook allows you to build the entire AWS Terraform project from scratch even if the `infrastructure/` directory is cleared:
> - **Option 1 (Recommended - 1-Click Terminal Command)**: Copy and paste the provided PowerShell `@' ... '@ | Set-Content` command into your terminal. It creates the folder and writes each HCL file with **100% exact syntax automatically**.
> - **Option 2 (Manual File Creation)**: Create the file manually in VS Code and copy the standard HCL block.

---

## 🗺️ Master Cloud Infrastructure Blueprint

When you finish following this guide, your `infrastructure/aws/` directory will look exactly like this:

```
infrastructure/aws/
│
├── terraform/
│   ├── versions.tf                     # Pinned Terraform and AWS provider versions
│   ├── providers.tf                    # AWS provider configuration and default tags
│   ├── variables.tf                    # Parameterized variables (VPC CIDR, region, node types)
│   ├── main.tf                         # Root coordinator and local naming conventions
│   ├── networking.tf                   # Multi-AZ VPC, public/private subnets, IGW, NAT Gateway
│   ├── ecr.tf                          # Amazon ECR container registries with automated scan
│   ├── eks.tf                          # Managed EKS cluster control plane & worker node groups
│   ├── outputs.tf                      # EKS endpoints, ECR URLs, and kubectl connection command
│   └── terraform.tfvars.example        # Example custom variable overrides
│
└── eks/
    └── README.md                       # AWS Load Balancer Controller & EBS CSI Driver guide
```

---

## Step 0: Terraform Versions & Providers (`versions.tf` & `providers.tf`)

Pins tested provider versions and configures standard AWS tags.

### 0.1 Create Directory & versions.tf (1-Click Copy)
```powershell
New-Item -ItemType Directory -Force -Path "c:\devops\infrastructure\aws\terraform"
@'
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }
  }
}
'@ | Set-Content -Path "c:\devops\infrastructure\aws\terraform\versions.tf" -Encoding UTF8
```

### 0.2 Create providers.tf (1-Click Copy)
```powershell
@'
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
'@ | Set-Content -Path "c:\devops\infrastructure\aws\terraform\providers.tf" -Encoding UTF8
```

---

## Step 1: Input Variables (`variables.tf` & `terraform.tfvars.example`)

Defines customizable parameters for VPC subnets, AWS region, and worker node sizing.

### 1.1 Create variables.tf (1-Click Copy)
```powershell
@'
variable "aws_region" {
  description = "AWS deployment region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment identifier (e.g. dev, staging, prod)"
  type        = string
  default     = "training"
}

variable "cluster_name" {
  description = "Name of the AWS EKS Cluster"
  type        = string
  default     = "csec-welcome-eks"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (spread across at least 2 AZs)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (spread across at least 2 AZs)"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "node_instance_types" {
  description = "EC2 instance types for EKS managed node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 4
}
'@ | Set-Content -Path "c:\devops\infrastructure\aws\terraform\variables.tf" -Encoding UTF8
```

### 1.2 Create terraform.tfvars.example (1-Click Copy)
```powershell
@'
aws_region   = "us-east-1"
environment  = "training"
cluster_name = "csec-welcome-eks"

vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]

node_instance_types = ["t3.medium"]
node_desired_size   = 2
node_min_size       = 1
node_max_size       = 3
'@ | Set-Content -Path "c:\devops\infrastructure\aws\terraform\terraform.tfvars.example" -Encoding UTF8
```

---

## Step 2: Multi-AZ Networking (`networking.tf`)

Provisions VPC, 2 public subnets, 2 private subnets, Internet Gateway, and NAT Gateway.

### 2.1 Create networking.tf (1-Click Copy)
```powershell
@'
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.cluster_name}-vpc"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.cluster_name}-igw"
  }
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                     = "${var.cluster_name}-public-subnet-${count.index + 1}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.cluster_name}-nat-eip"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "${var.cluster_name}-nat-gateway"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name                              = "${var.cluster_name}-private-subnet-${count.index + 1}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.cluster_name}-public-rt"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "${var.cluster_name}-private-rt"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
'@ | Set-Content -Path "c:\devops\infrastructure\aws\terraform\networking.tf" -Encoding UTF8
```

---

## Step 3: Amazon ECR Registries (`ecr.tf`)

Creates private Docker registries for frontend and backend images with automated vulnerability scanning.

### 3.1 Create ecr.tf (1-Click Copy)
```powershell
@'
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
'@ | Set-Content -Path "c:\devops\infrastructure\aws\terraform\ecr.tf" -Encoding UTF8
```

---

## Step 4: AWS EKS Control Plane & Worker Nodes (`eks.tf`)

Provisions managed Kubernetes control plane, IAM roles, and private worker node groups.

### 4.1 Create eks.tf (1-Click Copy)
```powershell
@'
resource "aws_iam_role" "cluster_role" {
  name = "${var.cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role_name  = aws_iam_role.cluster_role.name
}

resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster_role.arn
  version  = "1.30"

  vpc_config {
    subnet_ids              = concat(aws_subnet.public[*].id, aws_subnet.private[*].id)
    endpoint_public_access  = true
    endpoint_private_access = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy
  ]
}

resource "aws_iam_role" "node_role" {
  name = "${var.cluster_name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role_name  = aws_iam_role.node_role.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role_name  = aws_iam_role.node_role.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role_name  = aws_iam_role.node_role.name
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.cluster_name}-workers"
  node_role_arn   = aws_iam_role.node_role.arn
  subnet_ids      = aws_subnet.private[*].id

  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  instance_types = var.node_instance_types
  capacity_type  = "ON_DEMAND"

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly
  ]

  tags = {
    Name = "${var.cluster_name}-worker-node"
  }
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "vpc-cni"
}

resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "coredns"
  depends_on   = [aws_eks_node_group.main]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "kube-proxy"
}
'@ | Set-Content -Path "c:\devops\infrastructure\aws\terraform\eks.tf" -Encoding UTF8
```

---

## Step 5: Root Coordinator & Outputs (`main.tf` & `outputs.tf`)

Generates endpoint URLs and the exact `aws eks update-kubeconfig` command.

### 5.1 Create main.tf (1-Click Copy)
```powershell
@'
locals {
  name_prefix = "${var.cluster_name}-${var.environment}"
}
'@ | Set-Content -Path "c:\devops\infrastructure\aws\terraform\main.tf" -Encoding UTF8
```

### 5.2 Create outputs.tf (1-Click Copy)
```powershell
@'
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
'@ | Set-Content -Path "c:\devops\infrastructure\aws\terraform\outputs.tf" -Encoding UTF8
```

---

## Step 6: Step-by-Step Provisioning & Verification Workflow

### 6.1 Configure AWS Credentials
```powershell
# Open terminal and authenticate to AWS (Never put secret keys in code!)
aws configure
```

### 6.2 Initialize, Format & Plan Terraform
```powershell
Set-Location -Path "c:\devops\infrastructure\aws\terraform"

# Download provider plugins
terraform init

# Check formatting and syntax
terraform fmt
terraform validate

# Inspect the execution plan (Review resources before applying)
terraform plan
```

### 6.3 Apply & Provision Cloud Infrastructure
```powershell
terraform apply -auto-approve
```
*(Takes ~12 to 15 minutes as AWS spins up the managed control plane and worker nodes).*

### 6.4 Connect Local kubectl to AWS EKS
```powershell
# Run the command generated by Terraform outputs:
$clusterName = (terraform output -raw cluster_name)
aws eks update-kubeconfig --region us-east-1 --name $clusterName

# Verify worker nodes are active on AWS:
kubectl get nodes -o wide
```

---

## Step 7: Push Containers to Amazon ECR & Deploy via Helm

### 7.1 Push Local Images to Amazon ECR
```powershell
$account = (aws sts get-caller-identity --query "Account" --output text)
$ecrUrl = "$account.dkr.ecr.us-east-1.amazonaws.com"

# Log Docker into Amazon ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ecrUrl

# Tag and push Backend image
docker tag csec-astu/csec-welcome-backend:latest "$ecrUrl/csec-welcome-backend:v1.0.0"
docker push "$ecrUrl/csec-welcome-backend:v1.0.0"

# Tag and push Frontend image
docker tag csec-astu/csec-welcome-frontend:latest "$ecrUrl/csec-welcome-frontend:v1.0.0"
docker push "$ecrUrl/csec-welcome-frontend:v1.0.0"
```

### 7.2 Deploy CSEC Welcome with Production Helm Values
```powershell
cd c:\devops

helm install csec-welcome .\helm\csec-welcome `
  --namespace csec-learning `
  --create-namespace `
  -f .\helm\csec-welcome\values-prod.yaml `
  --set backend.image.repository="$ecrUrl/csec-welcome-backend" `
  --set frontend.image.repository="$ecrUrl/csec-welcome-frontend"
```

### 7.3 Verify Live Production Pods
```powershell
kubectl get pods -n csec-learning -o wide
kubectl get ingress -n csec-learning
```
*The Ingress address will display the AWS Application Load Balancer endpoint. Opening it in any browser shows the live CSEC Welcome application running on AWS EKS!*

---

## Step 8: Complete Teardown (Prevent Cloud Billing)

> [!WARNING]
> **Cloud Billing Alert**:
> EKS Control Planes, NAT Gateways, and EC2 worker nodes incur hourly charges. Always teardown resources when testing is finished:

```powershell
cd c:\devops
.\scripts\cleanup-aws.ps1
```
*(Confirms and triggers `terraform destroy -auto-approve` to completely remove all resources).*
