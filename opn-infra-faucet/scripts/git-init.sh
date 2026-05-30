#!/usr/bin/env bash
set -euo pipefail

# ── Змінити ────────────────────────────────────────────────────────────────────
GITHUB_USERNAME="your-username"
# ──────────────────────────────────────────────────────────────────────────────

# Виконувати з кореня проєкту: d:\OPN\opn-infra-faucet\

cd "$(dirname "$0")/.."

echo "[1/3] git init + commit..."
git init
git add .
git commit -m "feat: OPN Infrastructure Faucet - initial release

- ERC20 MyToken (OPIT, 1M supply)
- Faucet contract (100 OPIT / 24h, Sybil protection)
- React frontend with MetaMask, Chain ID 984 auto-switch
- Nginx reverse proxy config (RPC + static)
- Self-hosted OPN Testnet RPC node setup docs"

echo "[2/3] remote..."
git branch -M main
git remote add origin "https://github.com/${GITHUB_USERNAME}/opn-infra-faucet.git"

echo "[3/3] push..."
git push -u origin main

echo ""
echo "✓ Репозиторій опубліковано."
echo ""
echo "Після деплою контрактів у Remix:"
echo "  git add README.md frontend/src/config.js"
echo "  git commit -m \"chore: add deployed contract addresses (OPN Testnet)\""
echo "  git push"
