# CSEC ASTU – Complete AWS EKS Production Deployment Guide (Capstone Project)

Welcome to the **Capstone Production Deployment Guide** for the **CSEC ASTU (Computer Science & Engineering Club, Adama Science and Technology University) – Development Division**.

---

## 🎯 The Student Learning Journey

In the previous modules, you practiced locally:
1. You ran the app locally with `npm run dev`.
2. You packaged the app into multi-stage containers with `docker compose up --build`.
3. You built and verified all 10 stages of raw Kubernetes manifests in **Minikube** (`csec-learning` namespace).
4. You packaged the application into a versioned **Helm Chart**.

Now comes the **ultimate capstone achievement**:  
Deploying the exact same full-stack application to **real cloud infrastructure on Amazon Web Services (AWS EKS)** using Terraform, Amazon ECR, AWS Managed Node Groups, and an Application Load Balancer (ALB)!

---

## 🗺️ Master Cloud Deployment Roadmap

```
[ Developer Workstation ]
        │
        ▼ (Step 1)
Authenticate AWS CLI: 'aws configure'
        │
        ▼ (Step 2)
Provision Infrastructure with Terraform: 'terraform apply'
  ├── 1. Multi-AZ VPC (Public & Private Subnets, IGW, NAT Gateway)
  ├── 2. Amazon ECR Repositories (csec-welcome-backend & frontend)
  └── 3. Managed AWS EKS Cluster Control Plane + Worker Nodes
        │
        ▼ (Step 3)
Connect local kubectl: 'aws eks update-kubeconfig'
        │
        ▼ (Step 4)
Push Container Images to Amazon ECR: 'docker push'
        │
        ▼ (Step 5)
Deploy AWS Load Balancer Controller (ALB provisioner)
        │
        ▼ (Step 6)
Deploy Application with Production Helm: 'helm install -f values-prod.yaml'
        │
        ▼ (Step 7)
Verify Live Public Traffic via AWS ALB Ingress URL
        │
        ▼ (Step 8)
Complete Teardown: '.\scripts\cleanup-aws.ps1' (Prevent cloud bills!)
```

---

## Step 0: Prerequisites on Your Workstation

Ensure you have the required CLI tools installed and verified:

```powershell
# 1. Verify AWS CLI
aws --version
# If not installed: winget install --id Amazon.AWSCLI -e --source winget

# 2. Verify Terraform CLI
terraform version
# If not installed: winget install --id Hashicorp.Terraform -e --source winget

# 3. Verify kubectl
kubectl version --client

# 4. Verify Helm
helm version

# 5. Ensure Docker Desktop is running
docker version
```

---

## Step 1: AWS Credentials & Authentication

You need an AWS account. Configure your CLI with temporary or IAM credentials:

```powershell
# Run the interactive configuration wizard
aws configure
```
Prompt inputs:
- **AWS Access Key ID**: `YOUR_ACCESS_KEY`
- **AWS Secret Access Key**: `YOUR_SECRET_KEY`
- **Default region name**: `us-east-1`
- **Default output format**: `json`

### Verify Authentication
Run this command to verify AWS can identify your account:
```powershell
aws sts get-caller-identity
```
**Expected Output:**
```json
{
    "UserId": "AIDASAMPLEUSERIDEXAMPLE",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/csec-devops-student"
}
```

---

## Step 2: Create the Terraform Infrastructure Code

If starting from a fresh workstation, create the Terraform files in `c:\devops\infrastructure\aws\terraform\`:

### 2.1 Create Directory & Core Files (1-Click Copy)
```powershell
New-Item -ItemType Directory -Force -Path "c:\devops\infrastructure\aws\terraform"

# 1. versions.tf
@'
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
'@ | Set-Content -Path "c:\devops\infrastructure\aws\terraform\versions.tf" -Encoding UTF8

# 2. providers.tf
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

# 3. variables.tf
@'
variable "aws_region" {
  type    = string
  default = "us-east-1"
}
variable "environment" {
  type    = string
  default = "training"
}
variable "cluster_name" {
  type    = string
  default = "csec-welcome-eks"
}
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}
variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}
variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.10.0/24", "10.0.20.0/24"]
}
variable "node_instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}
variable "node_desired_size" {
  type    = number
  default = 2
}
variable "node_min_size" {
  type    = number
  default = 1
}
variable "node_max_size" {
  type    = number
  default = 3
}
'@ | Set-Content -Path "c:\devops\infrastructure\aws\terraform\variables.tf" -Encoding UTF8
```

### 2.2 Create Networking, ECR & EKS Manifests (1-Click Copy)
```powershell
# 4. networking.tf
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
  tags = { Name = "${var.cluster_name}-igw" }
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
  tags   = { Name = "${var.cluster_name}-nat-eip" }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  tags          = { Name = "${var.cluster_name}-nat-gateway" }
  depends_on    = [aws_internet_gateway.igw]
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
  tags = { Name = "${var.cluster_name}-public-rt" }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = { Name = "${var.cluster_name}-private-rt" }
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

# 5. ecr.tf
@'
resource "aws_ecr_repository" "backend" {
  name                 = "csec-welcome-backend"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration { scan_on_push = true }
  tags = { Name = "csec-welcome-backend-ecr" }
}

resource "aws_ecr_repository" "frontend" {
  name                 = "csec-welcome-frontend"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration { scan_on_push = true }
  tags = { Name = "csec-welcome-frontend-ecr" }
}
'@ | Set-Content -Path "c:\devops\infrastructure\aws\terraform\ecr.tf" -Encoding UTF8

# 6. eks.tf
@'
resource "aws_iam_role" "cluster_role" {
  name = "${var.cluster_name}-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
    }]
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
  depends_on = [aws_iam_role_policy_attachment.cluster_policy]
}

resource "aws_iam_role" "node_role" {
  name = "${var.cluster_name}-node-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
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

resource "aws_iam_role_policy_attachment" "node_ElasticLoadBalancingFullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
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
  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.node_ElasticLoadBalancingFullAccess
  ]
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

# 7. main.tf and outputs.tf
@'
locals { name_prefix = "${var.cluster_name}-${var.environment}" }
'@ | Set-Content -Path "c:\devops\infrastructure\aws\terraform\main.tf" -Encoding UTF8

@'
output "cluster_name" { value = aws_eks_cluster.main.name }
output "cluster_endpoint" { value = aws_eks_cluster.main.endpoint }
output "ecr_backend_repository_url" { value = aws_ecr_repository.backend.repository_url }
output "ecr_frontend_repository_url" { value = aws_ecr_repository.frontend.repository_url }
output "configure_kubectl_command" {
  value = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.main.name}"
}
'@ | Set-Content -Path "c:\devops\infrastructure\aws\terraform\outputs.tf" -Encoding UTF8
```

---

## Step 3: Provision AWS Cloud Infrastructure

Now execute Terraform to provision the VPC, ECR, and EKS Cluster:

```powershell
Set-Location -Path "c:\devops\infrastructure\aws\terraform"

# 1. Download provider plugins
terraform init

# 2. Format and validate
terraform fmt
terraform validate

# 3. Preview resources to be created (35+ resources)
terraform plan

# 4. Provision infrastructure (takes ~12 to 15 minutes)
terraform apply -auto-approve
```

---

## Step 4: Connect kubectl to your Cloud EKS Cluster

When `terraform apply` finishes, it outputs the exact command to configure your local `kubectl`:

```powershell
# 1. Update your local ~/.kube/config with cloud EKS credentials
aws eks update-kubeconfig --region us-east-1 --name csec-welcome-eks

# 2. Verify connection to the AWS control plane
kubectl cluster-info

# 3. View your live EC2 worker nodes running in AWS private subnets
kubectl get nodes -o wide
```
**Expected Output:**
```text
NAME                             STATUS   ROLES    AGE   VERSION   INTERNAL-IP   OS-IMAGE
ip-10-0-10-45.ec2.internal       Ready    <none>   3m    v1.30.0   10.0.10.45    Amazon Linux 2023
ip-10-0-20-112.ec2.internal      Ready    <none>   3m    v1.30.0   10.0.20.112   Amazon Linux 2023
```

---

## Step 5: Push Containers to Amazon ECR

Your EKS cluster is ready. Now push your frontend and backend images to the newly created private ECR registries:

```powershell
# 1. Retrieve your 12-digit AWS Account ID
$accountId = (aws sts get-caller-identity --query "Account" --output text)
$ecrUrl = "$accountId.dkr.ecr.us-east-1.amazonaws.com"

# 2. Authenticate Docker CLI to Amazon ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ecrUrl

# 3. Tag local images with your Amazon ECR repository URLs
docker tag csec-astu/csec-welcome-backend:latest "$ecrUrl/csec-welcome-backend:v1.0.0"
docker tag csec-astu/csec-welcome-frontend:latest "$ecrUrl/csec-welcome-frontend:v1.0.0"

# 4. Push images to Amazon ECR
docker push "$ecrUrl/csec-welcome-backend:v1.0.0"
docker push "$ecrUrl/csec-welcome-frontend:v1.0.0"

# 5. Verify images are stored in ECR
aws ecr list-images --repository-name csec-welcome-backend --region us-east-1
aws ecr list-images --repository-name csec-welcome-frontend --region us-east-1
```

---

## Step 6: Deploy AWS Load Balancer Controller (ALB Ingress)

In Minikube, we used the Nginx Ingress Controller. On AWS, we use the **AWS Load Balancer Controller**, which provisions a real AWS Application Load Balancer:

```powershell
# 1. Associate IAM OIDC Provider with your EKS cluster
aws eks describe-cluster --name csec-welcome-eks --region us-east-1 --query "cluster.identity.oidc.issuer" --output text

# 2. Add EKS Helm repository
helm repo add eks https://aws.github.io/eks-charts
helm repo update

# 3. Install AWS Load Balancer Controller
helm install aws-load-balancer-controller eks/aws-load-balancer-controller `
  -n kube-system `
  --set clusterName=csec-welcome-eks `
  --set serviceAccount.create=true `
  --set serviceAccount.name=aws-load-balancer-controller

# 4. Verify the controller is active
kubectl get deployment -n kube-system aws-load-balancer-controller
```

---

## Step 7: Deploy CSEC Welcome using Production Helm Values

Now deploy the complete application into the `csec-learning` namespace on AWS EKS using Helm and your `values-prod.yaml`:

```powershell
Set-Location -Path "c:\devops"

# Deploy via Helm referencing your ECR image repositories
helm install csec-welcome .\helm\csec-welcome `
  --namespace csec-learning `
  --create-namespace `
  -f .\helm\csec-welcome\values-prod.yaml `
  --set backend.image.repository="$ecrUrl/csec-welcome-backend" `
  --set backend.image.tag="v1.0.0" `
  --set frontend.image.repository="$ecrUrl/csec-welcome-frontend" `
  --set frontend.image.tag="v1.0.0"
```

---

## Step 8: Verify Live Cloud Deployment & Public Access

Inspect the running resources in your AWS cluster:

```powershell
# 1. Verify 3 backend and 3 frontend Pods are Running
kubectl get pods -n csec-learning -o wide

# 2. Verify Services
kubectl get services -n csec-learning

# 3. Retrieve the AWS Application Load Balancer Public URL
kubectl get ingress -n csec-learning
```

### View in Your Browser!
In the output of `kubectl get ingress -n csec-learning`, copy the hostname under `ADDRESS`:
```text
NAME                   CLASS   HOSTS                      ADDRESS
csec-welcome-ingress   alb     welcome.csec-astu.org      k8s-csecwelcome-1234567890.us-east-1.elb.amazonaws.com
```

Open that AWS ALB DNS name in your browser or test it via `curl`:
```powershell
# Test live public API endpoint on AWS!
curl.exe http://k8s-csecwelcome-1234567890.us-east-1.elb.amazonaws.com/api/welcome
```

**Congratulations!** You have deployed a high-availability, auto-scaling, containerized full-stack application on a multi-AZ AWS EKS cluster in production!

---

## Step 9: Test Cloud Resilience & Auto-Healing

Prove to your students that Kubernetes self-heals in production:

```powershell
# 1. Pick any running backend pod
$podName = (kubectl get pods -n csec-learning -l tier=backend -o jsonpath='{.items[0].metadata.name}')

# 2. Deliberately delete the pod
kubectl delete pod $podName -n csec-learning

# 3. Immediately watch Kubernetes create a replacement replica in real-time!
kubectl get pods -n csec-learning -w
```
*Zero downtime! The other 2 backend replicas handled client traffic while the deployment controller replaced the dead pod within 2 seconds.*

---

## Step 10: Complete Teardown (Prevent Unintended Cloud Billing)

> [!CAUTION]
> **Cloud Cost Notice**:
> EKS Control Planes (\$0.10/hour), EC2 worker nodes, and NAT Gateways incur hourly charges. When your training lab is finished, teardown all resources immediately!

```powershell
# 1. Uninstall Helm release (removes AWS ALB automatically)
helm uninstall csec-welcome -n csec-learning

# 2. Run the automated AWS teardown script
cd c:\devops
.\scripts\cleanup-aws.ps1
```
The script will prompt you to confirm (`yes`), and run `terraform destroy -auto-approve` to completely delete all cloud resources, leaving your AWS bill at **$0.00**.

---

## 🛠️ AWS EKS Troubleshooting Matrix

| Symptom | Cause | Solution Command |
| :--- | :--- | :--- |
| **`ImagePullBackOff` on EKS** | Worker node IAM role cannot pull from ECR | Verify IAM policy `AmazonEC2ContainerRegistryReadOnly` is attached to `aws_iam_role.node_role`. |
| **Ingress `ADDRESS` is empty** | AWS Load Balancer Controller not installed or subnets untagged | Verify `kubectl get deployment -n kube-system aws-load-balancer-controller` and confirm `kubernetes.io/role/elb = 1` tag on public subnets. |
| **`Unauthorized` on `kubectl`** | AWS credentials expired or wrong IAM user | Run `aws sts get-caller-identity` to re-verify active AWS session. |
| **Node Group stuck in `CREATING`** | Subnet CIDR overlap or lack of NAT Gateway | Verify private subnets route to NAT Gateway in `networking.tf`. |
