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

Set-Location -Path "c:\devops\infrastructure\aws\terraform"

Write-Host "`n[1/3] Running Terraform Plan (Destroy mode)..." -ForegroundColor Yellow
terraform plan -destroy

Write-Host "`n[2/3] Destroying AWS resources..." -ForegroundColor Red
terraform destroy -auto-approve

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n====================================================" -ForegroundColor Green
    Write-Host " All AWS resources destroyed successfully!" -ForegroundColor Green
    Write-Host " Your AWS account will no longer incur charges." -ForegroundColor Green
    Write-Host "====================================================" -ForegroundColor Green
} else {
    Write-Host "`nError during destruction. Check the terraform output above." -ForegroundColor Red
}

