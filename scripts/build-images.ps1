# ==============================================================================
# CSEC ASTU - Automated Docker Image Build Script
# Builds multi-stage production images for Frontend and Backend
# ==============================================================================

param (
    [string]$Tag = "v1.0.0",
    [string]$Registry = "csec-astu"
)

$ErrorActionPreference = "Stop"

Write-Host "====================================================" -ForegroundColor Cyan
Write-Host " CSEC ASTU Container Image Builder" -ForegroundColor Cyan
Write-Host " Tag:      $Tag" -ForegroundColor Yellow
Write-Host " Registry: $Registry" -ForegroundColor Yellow
Write-Host "====================================================" -ForegroundColor Cyan

# 1. Build Backend Image
Write-Host "`n[1/2] Building Backend Docker Image..." -ForegroundColor Green
$backendImageName = "$Registry/csec-welcome-backend:$Tag"
$backendLatest = "$Registry/csec-welcome-backend:latest"

docker build `
    -t $backendImageName `
    -t $backendLatest `
    -f c:\devops\backend\Dockerfile `
    c:\devops\backend

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to build backend image."
    exit 1
}

# 2. Build Frontend Image
Write-Host "`n[2/2] Building Frontend Docker Image..." -ForegroundColor Green
$frontendImageName = "$Registry/csec-welcome-frontend:$Tag"
$frontendLatest = "$Registry/csec-welcome-frontend:latest"

docker build `
    -t $frontendImageName `
    -t $frontendLatest `
    -f c:\devops\frontend\Dockerfile `
    c:\devops\frontend

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to build frontend image."
    exit 1
}

Write-Host "`n====================================================" -ForegroundColor Cyan
Write-Host " Build Complete! Image Summary:" -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan
docker images --filter "reference=$Registry/csec-welcome-*" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

Write-Host "`nTo run these images with Docker Compose:" -ForegroundColor Yellow
Write-Host "  docker compose up --build" -ForegroundColor White

