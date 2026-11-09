# ==============================================================================
# CSEC ASTU - Minikube Cleanup Script
# Stops or deletes local Minikube cluster to free system RAM and disk
# ==============================================================================

param (
    [switch]$Delete
)

Write-Host "====================================================" -ForegroundColor Cyan
Write-Host " CSEC ASTU - Minikube Cleanup Utility" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan

if ($Delete) {
    Write-Host "Deleting Minikube cluster and all allocated virtual disks..." -ForegroundColor Red
    minikube delete
    Write-Host "Minikube cluster completely deleted." -ForegroundColor Green
} else {
    Write-Host "Stopping Minikube cluster (preserves your cluster state)..." -ForegroundColor Yellow
    minikube stop
    Write-Host "Minikube stopped. Run '.\scripts\deploy-minikube.ps1' to resume." -ForegroundColor Green
}

