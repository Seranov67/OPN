#!/usr/bin/env bash
# Одна операція після Remix — заповнити змінні нижче і запустити:
#   bash scripts/apply-addresses.sh

set -euo pipefail

MYTOKEN="0x..."   # MyToken address
FAUCET="0x..."    # Faucet address
TX_MYTOKEN="0x..." # deploy tx hash
TX_FAUCET="0x..."  # deploy tx hash
DOMAIN="faucet.your-domain.com"
GITHUB="your-username"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG="${ROOT}/frontend/src/config.js"
APP="${ROOT}/hackathon-application.md"
README="${ROOT}/README.md"

for f in "$CONFIG" "$APP"; do
  sed -i "s|MYTOKEN_ADDRESS|${MYTOKEN}|g" "$f"
  sed -i "s|FAUCET_ADDRESS|${FAUCET}|g" "$f"
done

sed -i "s|TX_MYTOKEN|${TX_MYTOKEN}|g" "$APP"
sed -i "s|TX_FAUCET|${TX_FAUCET}|g" "$APP"
sed -i "s|YOUR_DOMAIN|${DOMAIN}|g" "$APP"
sed -i "s|YOUR_GITHUB|${GITHUB}|g" "$APP"

# README table (optional placeholders if present)
if grep -q "0x0000000000000000000000000000000000000000" "$README" 2>/dev/null; then
  sed -i "0,0x0000000000000000000000000000000000000000/s//${MYTOKEN}/" "$README"
  sed -i "0,0x0000000000000000000000000000000000000000/s//${FAUCET}/" "$README"
fi

echo "✓ Оновлено: config.js, hackathon-application.md"
echo "  MyToken: ${MYTOKEN}"
echo "  Faucet:  ${FAUCET}"
echo ""
echo "Далі: cd frontend && npm run build && ../scripts/deploy-frontend.ps1"
