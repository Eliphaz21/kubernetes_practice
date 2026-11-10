# ==============================================================================
# CSEC ASTU - Automated AWS EKS Deployment Script (Production Capstone)
# Provisions AWS Infrastructure, pushes container images to ECR,
# configures kubectl, and deploys the full stack via Helm.
# ==============================================================================

param (
    [string]$Region = "us-east-1",
    [string]$ClusterName = "csec-welcome-eks",
    [string]$ImageTag = "v1.0.0"
)

$ErrorActionPreference = "Stop"

Write-Host "====================================================" -ForegroundColor Cyan
Write-Host " CSEC ASTU - AWS EKS Production Deployment Pipeline" -ForegroundColor Cyan
Write-Host " Region:       $Region" -ForegroundColor Yellow
Write-Host " Cluster Name: $ClusterName" -ForegroundColor Yellow
Write-Host " Image Tag:    $ImageTag" -ForegroundColor Yellow
Write-Host "====================================================" -ForegroundColor Cyan

# 1. Verify AWS Identity
Write-Host "`n[1/6] Verifying AWS credentials..." -ForegroundColor Green
$identity = aws sts get-caller-identity | ConvertFrom-Json
$accountId = $identity.Account
Write-Host "Authenticated as AWS Account: $accountId (User/Role: $($identity.Arn))" -ForegroundColor White

# 2. Terraform Provisioning (VPC, EKS, ECR)
Write-Host "`n[2/6] Initializing & Applying Terraform Infrastructure..." -ForegroundColor Green
Set-Location -Path "c:\devops\infrastructure\aws\terraform"
terraform init
terraform apply -auto-approve

$ecrBackendUrl = (terraform output -raw ecr_backend_repository_url)
$ecrFrontendUrl = (terraform output -raw ecr_frontend_repository_url)

# 3. Connect kubectl to AWS EKS
Write-Host "`n[3/6] Connecting local kubectl to AWS EKS..." -ForegroundColor Green
aws eks update-kubeconfig --region $Region --name $ClusterName
Write-Host "Cluster Nodes:" -ForegroundColor White
kubectl get nodes -o wide

# 4. Authenticate Docker to Amazon ECR & Push Images
Write-Host "`n[4/6] Pushing production container images to Amazon ECR..." -ForegroundColor Green
aws ecr get-login-password --region $Region | docker login --username AWS --password-stdin "$accountId.dkr.ecr.$Region.amazonaws.com"

# Tag local images for ECR
docker tag csec-astu/csec-welcome-backend:latest "$ecrBackendUrl`:$ImageTag"
docker tag csec-astu/csec-welcome-frontend:latest "$ecrFrontendUrl`:$ImageTag"

# Push to ECR
docker push "$ecrBackendUrl`:$ImageTag"
docker push "$ecrFrontendUrl`:$ImageTag"

# 5. Deploy Application via Helm
Write-Host "`n[5/6] Deploying CSEC Welcome to AWS EKS using Helm..." -ForegroundColor Green
Set-Location -Path "c:\devops"
helm upgrade --install csec-welcome .\helm\csec-welcome `
    --namespace csec-learning `
    --create-namespace `
    -f .\helm\csec-welcome\values-prod.yaml `
    --set backend.image.repository="$ecrBackendUrl" `
    --set backend.image.tag="$ImageTag" `
    --set frontend.image.repository="$ecrFrontendUrl" `
    --set frontend.image.tag="$ImageTag"

# 6. Verification
Write-Host "`n[6/6] Verifying live cloud deployment..." -ForegroundColor Green
kubectl get pods,svc,ingress -n csec-learning -o wide

Write-Host "`n====================================================" -ForegroundColor Cyan
Write-Host " Deployment Complete on AWS EKS!" -ForegroundColor Green
Write-Host " Note: It takes 2-3 minutes for AWS Application Load Balancers (ALB) to provision." -ForegroundColor Yellow
Write-Host " Run 'kubectl get ingress -n csec-learning' to view the public URL." -ForegroundColor White
Write-Host " When finished, run '.\scripts\cleanup-aws.ps1' to destroy resources." -ForegroundColor Red
Write-Host "====================================================" -ForegroundColor Cyan

