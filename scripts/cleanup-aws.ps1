# ==============================================================================
# CSEC ASTU - AWS Infrastructure Teardown Script
# Safely destroys all Terraform-provisioned AWS resources (EKS, VPC, NAT Gateway)
# to prevent recurring cloud charges.
# ==============================================================================

Write-Host "====================================================" -ForegroundColor Red
Write-Host " WARNING: AWS TEARDOWN INITIATED" -ForegroundColor Red
Write-Host " This will terminate the EKS cluster, worker nodes," -ForegroundColor Yellow
Write-Host " NAT Gateways, and VPC resources in your AWS account." -ForegroundColor Yellow
Write-Host "====================================================" -ForegroundColor Red

$confirmation = Read-Host "Are you sure you want to destroy all AWS resources? (type 'yes' to proceed)"

if ($confirmation -ne "yes") {
    Write-Host "Teardown aborted by user." -ForegroundColor Green
    exit 0
}

# 1. First remove the Helm chart and AWS Ingress / ALB to release VPC ENIs
Write-Host "`n[1/4] Removing Kubernetes Helm releases and Ingress..." -ForegroundColor Yellow
try {
    helm uninstall csec-welcome -n csec-learning 2>$null
    helm uninstall aws-load-balancer-controller -n kube-system 2>$null
    Write-Host "Waiting 25 seconds for AWS to deregister Application Load Balancers and release ENIs..." -ForegroundColor White
    Start-Sleep -Seconds 25
} catch {
    Write-Host "Helm release already uninstalled or not reachable. Proceeding to Terraform..." -ForegroundColor Gray
}

# 2. Navigate to Terraform directory
Set-Location -Path "c:\devops\infrastructure\aws\terraform"

# 3. Running Terraform Plan in destroy mode
Write-Host "`n[2/4] Running Terraform Plan (Destroy mode)..." -ForegroundColor Yellow
terraform plan -destroy

# 4. Destroy AWS Resources
Write-Host "`n[3/4] Destroying AWS resources..." -ForegroundColor Red
terraform destroy -auto-approve

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n====================================================" -ForegroundColor Green
    Write-Host " All AWS resources destroyed successfully!" -ForegroundColor Green
    Write-Host " Your AWS account will no longer incur charges." -ForegroundColor Green
    Write-Host "====================================================" -ForegroundColor Green
} else {
    Write-Host "`nError during destruction. Check the terraform output above." -ForegroundColor Red
}
