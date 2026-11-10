# Module 30: AWS EKS Cloud Infrastructure with Terraform

## Organization: CSEC ASTU – Development Division
### Project: CSEC Welcome – Cloud-Native Kubernetes & DevOps Training Curriculum

---

### Step 1 – What are we learning?
In this module, you will learn how to provision an enterprise-grade cloud Kubernetes cluster on **Amazon Web Services (AWS)** using **Terraform** (Infrastructure as Code). You will provision an isolated multi-AZ VPC, public and private subnets, an Internet Gateway, NAT Gateway, AWS ECR container registries, and a fully managed **AWS EKS Cluster** with managed worker nodes.

---

### Step 2 – Why do we need it?
Manual cloud provisioning through the AWS Management Console is slow, non-reproducible, and prone to human errors (like forgetting to enable DNS hostnames or tagging subnets incorrectly).
With **Terraform**:
1. Your entire cloud infrastructure is defined declaratively in version-controlled code.
2. Multiple team members can spin up identical, reproducible environments.
3. When training is complete, a single command destroys all resources to prevent unintended cloud bills.

---

### Step 3 – What are we going to create?
A complete Terraform project in `c:\devops\infrastructure\aws\terraform\`:
- Multi-AZ VPC (`10.0.0.0/16`) across 2 Availability Zones
- 2 Public Subnets (for internet ALBs) & 2 Private Subnets (for worker nodes)
- Internet Gateway & Elastic IP + NAT Gateway
- 2 AWS ECR Repositories (`csec-welcome-backend` and `csec-welcome-frontend`)
- Managed AWS EKS Control Plane (Kubernetes v1.30)
- Managed Worker Node Group (`t3.medium` instances)

---

### Step 4 – Where do we create it?
Located at `c:\devops\infrastructure\aws\terraform\`.
Teardown script at `c:\devops\scripts\cleanup-aws.ps1`.

---

### Step 5 – Complete Command Workflow

```powershell
# 1. Navigate to the Terraform directory
Set-Location -Path "c:\devops\infrastructure\aws\terraform"

# 2. Configure AWS credentials (via AWS CLI or environment variables)
# Never commit your AWS Access Keys to Git!
aws configure

# 3. Initialize Terraform (downloads AWS and Kubernetes providers)
terraform init

# 4. Format and validate configuration
terraform fmt
terraform validate

# 5. Review the execution plan
terraform plan

# 6. Provision the infrastructure on AWS (takes ~12-15 minutes)
terraform apply -auto-approve

# 7. Inspect Outputs & Configure kubectl
$clusterName = (terraform output -raw cluster_name)
$region = "us-east-1"
aws eks update-kubeconfig --region $region --name $clusterName

# 8. Verify EKS Cluster Connectivity
kubectl get nodes -o wide
```

---

### Step 6 – Code Explanation
1. **Subnet Tagging for Kubernetes Ingress**:
   - `"kubernetes.io/role/elb" = "1"`: Placed on public subnets so the AWS Load Balancer Controller knows where to deploy internet-facing Application Load Balancers.
   - `"kubernetes.io/role/internal-elb" = "1"`: Placed on private subnets for internal routing.
2. **Private Worker Nodes**:
   - Worker nodes reside in private subnets with no public IPs, protecting them from direct internet scanning. Outbound traffic (e.g. pulling images from ECR) routes through the NAT Gateway.
3. **ECR Image Scanning**:
   - `scan_on_push = true` automatically triggers Amazon Inspector to audit pushed container images for OS CVEs.

---

### Step 7 – Deploying CSEC Welcome to EKS using Helm

Once `kubectl` is connected to your AWS EKS cluster, deploy the application using the production Helm values:

```powershell
# Authenticate Docker to Amazon ECR
$account = (aws sts get-caller-identity --query "Account" --output text)
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin "$account.dkr.ecr.us-east-1.amazonaws.com"

# Tag and push local images to Amazon ECR
docker tag csec-astu/csec-welcome-backend:latest "$account.dkr.ecr.us-east-1.amazonaws.com/csec-welcome-backend:v1.0.0"
docker tag csec-astu/csec-welcome-frontend:latest "$account.dkr.ecr.us-east-1.amazonaws.com/csec-welcome-frontend:v1.0.0"

docker push "$account.dkr.ecr.us-east-1.amazonaws.com/csec-welcome-backend:v1.0.0"
docker push "$account.dkr.ecr.us-east-1.amazonaws.com/csec-welcome-frontend:v1.0.0"

# Deploy via Helm with production values
cd c:\devops
helm install csec-welcome .\helm\csec-welcome `
  --namespace csec-learning `
  --create-namespace `
  -f .\helm\csec-welcome\values-prod.yaml `
  --set backend.image.repository="$account.dkr.ecr.us-east-1.amazonaws.com/csec-welcome-backend" `
  --set frontend.image.repository="$account.dkr.ecr.us-east-1.amazonaws.com/csec-welcome-frontend"
```

---

### Step 8 – Expected Result
```text
NAME                               READY   STATUS    RESTARTS   AGE
csec-welcome-backend-xxxxxxxxx-1   1/1     Running   0          2m
csec-welcome-backend-xxxxxxxxx-2   1/1     Running   0          2m
csec-welcome-backend-xxxxxxxxx-3   1/1     Running   0          2m
csec-welcome-frontend-yyyyyyyy-1   1/1     Running   0          2m
csec-welcome-frontend-yyyyyyyy-2   1/1     Running   0          2m
csec-welcome-frontend-yyyyyyyy-3   1/1     Running   0          2m
```

---

### Step 9 – Verify
```powershell
kubectl get ingress -n csec-learning
```
*The `ADDRESS` column will display an AWS ALB DNS name (e.g. `k8s-csecwelcome-xxxx.us-east-1.elb.amazonaws.com`). Opening this address in any browser shows the live CSEC Welcome application running on AWS!*

---

### Step 10 – Complete Cleanup (Crucial for Cloud Budgets)
When you finish testing, **always destroy AWS infrastructure** to avoid recurring hourly charges:

```powershell
cd c:\devops
.\scripts\cleanup-aws.ps1
```
*(This triggers `terraform destroy -auto-approve` and deletes the EKS cluster, worker nodes, and NAT Gateways).*
