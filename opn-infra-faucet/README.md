# OPN Infrastructure Faucet

> High-availability ERC20 faucet running on a self-hosted OPN Chain RPC node behind Nginx.

[![OPN Testnet](https://img.shields.io/badge/network-OPN%20Testnet-7c3aed)](https://testnet.iopn.tech)
[![Chain ID](https://img.shields.io/badge/chain--id-984-blue)](https://testnet.iopn.tech)
[![License: MIT](https://img.shields.io/badge/license-MIT-green)](LICENSE)

---

## Overview

Standard DeFi faucets depend on centralized public RPC endpoints with aggressive rate-limiting.
This project eliminates that bottleneck by pairing a standard ERC20 faucet with a self-hosted
OPN Chain full node, proxied through Nginx with TLS termination.

**Stack:** Solidity 0.8.20 · OpenZeppelin v5 · React 18 · ethers.js v6 · Nginx · Ubuntu 22.04

---

## Architecture

```
User (MetaMask)
      │
      ▼
  React SPA  ──── HTTPS ────►  Nginx (VPS)
                                    │
                     ┌──────────────┴──────────────┐
                     ▼                             ▼
             /  → React build            /rpc → OPN Chain Node
             (static files)              (localhost:8545)
                                               │
                                               ▼
                                     Faucet Smart Contract
                                     (Tendermint BFT, ~1s finality)
```

---

## Smart Contracts

Deployed on **OPN Testnet** (Chain ID: 984)

| Contract | Address | Explorer |
|----------|---------|----------|
| MyToken (OPIT) | `MYTOKEN_ADDRESS` | [View](https://testnet.iopn.tech/address/MYTOKEN_ADDRESS) |
| Faucet | `FAUCET_ADDRESS` | [View](https://testnet.iopn.tech/address/FAUCET_ADDRESS) |

**Deploy transactions:**
- MyToken: [`TX_MYTOKEN`](https://testnet.iopn.tech/tx/TX_MYTOKEN)
- Faucet: [`TX_FAUCET`](https://testnet.iopn.tech/tx/TX_FAUCET)

> Replace placeholders after Remix deployment. See [Deployment Guide](#deployment).

---

## Features

- **ERC20 Token (OPIT)** — 1,000,000 supply, 18 decimals, OpenZeppelin standard
- **Faucet contract** — 100 OPIT per request, 24-hour cooldown per address
- **Sybil protection** — on-chain rate limiting via `mapping(address => uint256)`
- **Chain guard** — frontend auto-switches MetaMask to Chain ID 984
- **Self-hosted RPC** — own OPN Chain node eliminates public RPC rate limits
- **Nginx reverse proxy** — `/rpc` proxied to local node, CORS handled, TLS via Let's Encrypt

---

## Project Structure

```
opn-infra-faucet/
├── contracts/
│   ├── MyToken.sol          # ERC20 "OPN Infra Token" (OPIT), 1M supply
│   └── Faucet.sol           # 100 OPIT / 24h cooldown, events, Sybil guard
├── frontend/
│   ├── src/
│   │   ├── App.js           # MetaMask connect, chain switch, TX states
│   │   ├── App.css          # Dark theme, vanilla CSS
│   │   └── config.js        # Contract addresses + ABI
│   └── package.json
├── scripts/
│   ├── setup-vps.sh         # Nginx + UFW + Let's Encrypt (run on VPS as root)
│   ├── deploy-frontend.ps1  # npm build + scp to VPS (run on Windows)
│   └── git-init.sh          # Git init + first commit + push
├── docs/
│   └── OPN_BUILDERS_SUBMISSION.md  # Hackathon submission copy
└── README.md
```

---

## Deployment

### Prerequisites

- MetaMask with OPN Testnet added (Chain ID: 984)
- Test OPN tokens from the [official faucet](https://faucet.iopn.tech)
- VPS with Ubuntu 22.04, public IP, domain pointed to it
- Node.js 18+ on local machine

---

### Step 1 — Deploy Smart Contracts (Remix IDE)

1. Open [remix.ethereum.org](https://remix.ethereum.org)
2. Set MetaMask to **OPN Testnet (Chain ID 984)**
3. Create `MyToken.sol`, paste contract code from `remix/MyToken.sol`
4. **Compiler:** `0.8.20`, Optimization: `200 runs`
5. **Environment:** `Injected Provider - MetaMask`
6. Deploy `MyToken` → copy contract address
7. Deploy `Faucet` with `tokenAddress = <MyToken address>`
8. Call `MyToken.transfer(faucetAddress, 500000000000000000000000)`
9. Verify: `Faucet.getFaucetBalance()` should return `500000000000000000000000`

Update `frontend/src/config.js`:

```js
export const TOKEN_ADDRESS  = "0x...";   // MyToken address
export const FAUCET_ADDRESS = "0x...";   // Faucet address
```

---

### Step 2 — VPS Setup

Edit variables at the top of the script, then run on your VPS:

```bash
# Edit DOMAIN and EMAIL in the script first
nano scripts/setup-vps.sh

chmod +x scripts/setup-vps.sh
sudo ./scripts/setup-vps.sh
```

The script handles: Nginx install, UFW rules, site config, SSL via certbot.

**Ports opened by UFW:**

| Port | Protocol | Purpose |
|------|----------|---------|
| 22   | TCP | SSH |
| 80   | TCP | HTTP → redirects to HTTPS |
| 443  | TCP | HTTPS |
| 26656 | TCP | OPN Chain P2P |

---

### Step 3 — Deploy Frontend

Edit `$VPS_USER`, `$VPS_IP`, `$DOMAIN` at the top of the script, then run on Windows:

```powershell
.\scripts\deploy-frontend.ps1
```

This builds the React app and uploads it to `/var/www/faucet/` on the VPS.

---

### Step 4 — GitHub

```bash
# Edit GITHUB_USERNAME in the script first
bash scripts/git-init.sh
```

---

### Step 5 — After Remix: Final Update

```bash
git add frontend/src/config.js README.md
git commit -m "chore: add deployed contract addresses (OPN Testnet 984)"
git push

# Rebuild and redeploy frontend
.\scripts\deploy-frontend.ps1
```

---

## Running Locally

```bash
cd frontend
npm install
npm start
# → http://localhost:3000
```

Make sure MetaMask is set to OPN Testnet before connecting.

---

## OPN Testnet Reference

| Parameter | Value |
|-----------|-------|
| Network Name | OPN Testnet |
| Chain ID | 984 (0x3d8) |
| RPC URL | https://testnet-rpc.iopn.tech |
| Currency | OPN |
| Min Gas Price | 7 Gwei |
| Block Explorer | https://testnet.iopn.tech |
| Official Faucet | https://faucet.iopn.tech |

---

## OPN Builders Submission

Copy-paste guide for the hackathon form: [docs/OPN_BUILDERS_SUBMISSION.md](docs/OPN_BUILDERS_SUBMISSION.md)

---

## License

MIT
