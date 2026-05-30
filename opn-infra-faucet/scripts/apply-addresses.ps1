# Одна операція після Remix — заповнити змінні нижче і запустити:
#   .\scripts\apply-addresses.ps1

$MYTOKEN = "0x..."
$FAUCET  = "0x..."
$TX_MYTOKEN = "0x..."
$TX_FAUCET  = "0x..."
$DOMAIN  = "faucet.your-domain.com"
$GITHUB  = "your-username"

$Root = Split-Path $PSScriptRoot -Parent
$Files = @(
    (Join-Path $Root "frontend\src\config.js"),
    (Join-Path $Root "hackathon-application.md")
)

foreach ($file in $Files) {
    $c = Get-Content $file -Raw
    $c = $c -replace "MYTOKEN_ADDRESS", $MYTOKEN
    $c = $c -replace "FAUCET_ADDRESS", $FAUCET
    Set-Content $file $c -NoNewline
}

$app = Join-Path $Root "hackathon-application.md"
$c = Get-Content $app -Raw
$c = $c -replace "TX_MYTOKEN", $TX_MYTOKEN
$c = $c -replace "TX_FAUCET", $TX_FAUCET
$c = $c -replace "YOUR_DOMAIN", $DOMAIN
$c = $c -replace "YOUR_GITHUB", $GITHUB
Set-Content $app $c -NoNewline

Write-Host "✓ Оновлено: config.js, hackathon-application.md" -ForegroundColor Green
