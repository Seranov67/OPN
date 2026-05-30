#!/usr/bin/env bash
# Publish repo to GitHub. Docs: docs/DEPLOYMENT.md (Phase A)
set -euo pipefail

# ── Edit before running ───────────────────────────────────────────────────────
GITHUB_USERNAME="your-username"
# ─────────────────────────────────────────────────────────────────────────────

cd "$(dirname "$0")/.."

echo "[1/3] git init + commit..."
git init
git add .
git commit -m "feat: OPN Infrastructure Faucet - initial release

- ERC20 MyToken (OPIT, 1M supply)
- Faucet contract (100 OPIT / 24h cooldown)
- React frontend with MetaMask, Chain ID 984 auto-switch
- Nginx reverse proxy (RPC + static)
- English docs and OPN Builders submission templates"

echo "[2/3] remote..."
git branch -M main
git remote add origin "https://github.com/${GITHUB_USERNAME}/opn-infra-faucet.git"

echo "[3/3] push..."
git push -u origin main

echo ""
echo "Done. Repository: https://github.com/${GITHUB_USERNAME}/opn-infra-faucet"
echo ""
echo "After contract deploy, update config.js and run:"
echo "  git add frontend/src/config.js README.md"
echo "  git commit -m \"chore: add deployed contract addresses (OPN Testnet 984)\""
echo "  git push"
