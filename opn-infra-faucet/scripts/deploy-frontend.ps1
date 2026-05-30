# Build + upload frontend to VPS. Docs: docs/DEPLOYMENT.md (Phase B)
# Edit before running:
$VPS_USER    = "ubuntu"
$VPS_IP      = "1.2.3.4"
$DOMAIN      = "faucet.your-domain.com"
$REMOTE_DIR  = "/var/www/faucet"
$LOCAL_FRONT = Join-Path (Split-Path $PSScriptRoot -Parent) "frontend"

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "[1/3] Building frontend..." -ForegroundColor Cyan
Set-Location $LOCAL_FRONT
npm run build

if ($LASTEXITCODE -ne 0) {
    Write-Error "npm run build failed"
    exit 1
}

Write-Host "[2/3] Uploading to VPS..." -ForegroundColor Cyan
scp -r "$LOCAL_FRONT\build\*" "${VPS_USER}@${VPS_IP}:${REMOTE_DIR}/"

Write-Host "[3/3] Verifying..." -ForegroundColor Cyan
ssh "${VPS_USER}@${VPS_IP}" "ls -lh ${REMOTE_DIR}/ | head -10"

Write-Host ""
Write-Host "Deploy complete." -ForegroundColor Green
Write-Host "  Open: https://${DOMAIN}" -ForegroundColor Green
Write-Host "  Note: Get Tokens works only after real addresses in config.js" -ForegroundColor Yellow
