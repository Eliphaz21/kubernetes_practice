# ==============================================================================
# CSEC ASTU - Minikube Local Cluster Setup Script
# Initializes Minikube with Docker driver, recommended resources, and addons
# ==============================================================================

param (
    [int]$CPUs = 2,
    [int]$MemoryMB = 4096,
    [string]$Driver = "docker",
    [string]$KubernetesVersion = "v1.30.0"
)

$ErrorActionPreference = "Stop"

Write-Host "====================================================" -ForegroundColor Cyan
Write-Host " CSEC ASTU - Minikube Cluster Provisioner" -ForegroundColor Cyan
Write-Host " Driver:             $Driver" -ForegroundColor Yellow
Write-Host " CPUs:               $CPUs cores" -ForegroundColor Yellow
Write-Host " Memory:             $MemoryMB MB" -ForegroundColor Yellow
Write-Host " Kubernetes Version: $KubernetesVersion" -ForegroundColor Yellow
Write-Host "====================================================" -ForegroundColor Cyan

# 1. Check Prerequisites
Write-Host "`n[1/4] Checking Docker engine status..." -ForegroundColor Green
docker version | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Error "Docker is not running. Please start Docker Desktop before running this script."
    exit 1
}

# 2. Start Minikube Cluster
Write-Host "`n[2/4] Starting Minikube cluster with $Driver driver..." -ForegroundColor Green
minikube start `
    --driver=$Driver `
    --cpus=$CPUs `
    --memory=$MemoryMB `
    --kubernetes-version=$KubernetesVersion

# 3. Enable Essential Addons
Write-Host "`n[3/4] Enabling essential cluster addons (metrics-server, ingress)..." -ForegroundColor Green
minikube addons enable metrics-server
minikube addons enable ingress

# 4. Verify Cluster Health & Node Status
Write-Host "`n[4/4] Verifying cluster connectivity..." -ForegroundColor Green
kubectl cluster-info
Write-Host "`nCluster Nodes:" -ForegroundColor Green
kubectl get nodes -o wide

Write-Host "`n====================================================" -ForegroundColor Cyan
Write-Host " Minikube Cluster Ready for CSEC ASTU Training!" -ForegroundColor Cyan
Write-Host " Next step: Deploy your applications using kubectl or Helm." -ForegroundColor Yellow
Write-Host "====================================================" -ForegroundColor Cyan

