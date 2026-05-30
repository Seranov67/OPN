# ── Змінити перед запуском ─────────────────────────────────────────────────────
$VPS_USER    = "ubuntu"                                    # ← SSH-користувач
$VPS_IP      = "1.2.3.4"                                  # ← IP вашого VPS
$DOMAIN      = "faucet.your-domain.com"                   # ← для повідомлення після деплою
$REMOTE_DIR  = "/var/www/faucet"
$LOCAL_FRONT = Join-Path (Split-Path $PSScriptRoot -Parent) "frontend"
# ──────────────────────────────────────────────────────────────────────────────

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "[1/3] Збірка фронтенду..." -ForegroundColor Cyan
Set-Location $LOCAL_FRONT
npm run build

if ($LASTEXITCODE -ne 0) {
    Write-Error "npm run build завершився з помилкою"
    exit 1
}

Write-Host "[2/3] Завантаження на VPS..." -ForegroundColor Cyan
scp -r "$LOCAL_FRONT\build\*" "${VPS_USER}@${VPS_IP}:${REMOTE_DIR}/"

Write-Host "[3/3] Перевірка..." -ForegroundColor Cyan
ssh "${VPS_USER}@${VPS_IP}" "ls -lh ${REMOTE_DIR}/ | head -10"

Write-Host ""
Write-Host "✓ Деплой завершено." -ForegroundColor Green
Write-Host "  Відкрийте: https://${DOMAIN}" -ForegroundColor Green
