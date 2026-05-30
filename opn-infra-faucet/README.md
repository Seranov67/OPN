# OPN Infrastructure Faucet

> High-availability ERC20 faucet running on a self-hosted OPN Chain full node behind Nginx.

[![OPN Testnet](https://img.shields.io/badge/network-OPN%20Testnet-7c3aed)](https://testnet.iopn.tech)
[![Chain ID](https://img.shields.io/badge/chain--id-984-blue)](https://testnet.iopn.tech)
[![Solidity](https://img.shields.io/badge/solidity-0.8.20-orange)](https://soliditylang.org)
[![License: MIT](https://img.shields.io/badge/license-MIT-green)](LICENSE)

---

## Overview

Standard DeFi faucets depend on centralized public RPC endpoints with aggressive rate-limiting.
This project eliminates that bottleneck: a standard ERC20 faucet backed by a **self-hosted
OPN Chain full node**, proxied through Nginx with TLS termination.

Built for the **OPN Builders Hackathon — DeFi & Open Finance** season.

**Stack:** Solidity 0.8.20 · OpenZeppelin v5 · React 18 · ethers.js v6 · Nginx · Tendermint BFT · Ubuntu 22.04

---

## Architecture

```
User (MetaMask)
      │  HTTPS
      ▼
┌─────────────────────────────────────┐
│  VPS (Ubuntu 22.04, NVMe SSD)       │
│                                     │
│  Nginx (443/TLS)                    │
│    ├── /        → React build       │
│    └── /rpc     → localhost:8545    │
│                       │             │
│         OPN Chain Full Node         │
│         (Tendermint BFT)            │
│         RocksDB, P2P: 26656         │
│                       │             │
│         Faucet Contract             │
│         24h cooldown, Sybil guard   │
└─────────────────────────────────────┘
```

| Layer | Component | Notes |
|-------|-----------|-------|
| Consensus | Tendermint BFT | Byzantine fault tolerant, ~1s finality |
| Storage | RocksDB | `db_backend = "rocksdb"`, better EVM concurrent writes |
| Network | P2P tuned | `send_rate = recv_rate = 5120000` |
| Proxy | Nginx + TLS | `/rpc` → `127.0.0.1:8545`, CORS handled |
| Firewall | UFW | Port 26657 & 8545 restricted to localhost only |

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

### Faucet logic

```
requestTokens()
  ├── require: faucet balance ≥ amountAllowed (default 100 OPIT)
  ├── require: block.timestamp ≥ lastAccessTime[msg.sender] + 24h
  ├── lastAccessTime[msg.sender] = block.timestamp   (CEI: state before transfer)
  ├── token.transfer(msg.sender, amountAllowed)
  └── emit SendToken(msg.sender, amountAllowed)
```

Owner functions: `setAmountAllowed()`, `withdrawAll()`.

---

## Project Structure

```
opn-infra-faucet/
├── contracts/
│   ├── MyToken.sol              # ERC20 + Ownable, 1M OPIT
│   └── Faucet.sol               # 100 OPIT / 24h, owner controls
├── remix/                       # Remix IDE copies (GitHub imports)
├── frontend/
│   ├── src/
│   │   ├── App.js
│   │   ├── App.css
│   │   └── config.js            # addresses + ABI (placeholders until Remix)
│   └── package.json
├── scripts/
│   ├── setup-node.sh            # OPN full node + RocksDB + UFW
│   ├── setup-vps.sh             # Nginx + Let's Encrypt
│   ├── deploy-frontend.ps1
│   └── git-init.sh
├── docs/
│   └── OPN_BUILDERS_SUBMISSION.md
└── README.md
```

---

## Deployment

### Prerequisites

- MetaMask + OPN Testnet (Chain ID: 984) — test OPN from [faucet.iopn.tech](https://faucet.iopn.tech)
- VPS: Ubuntu 22.04, **NVMe SSD**, 4 CPU, 8 GB RAM, 100 GB disk
- Domain pointed to VPS IP
- Node.js 18+ on local machine

---

### Step 1 — Deploy Contracts (Remix IDE)

1. Open [remix.ethereum.org](https://remix.ethereum.org)
2. MetaMask → OPN Testnet (Chain ID: 984)
3. Create `MyToken.sol` from `remix/MyToken.sol` → Compiler `0.8.20`, Optimization `200 runs`
4. Environment: `Injected Provider - MetaMask`
5. Deploy `MyToken` → `initialOwner` = your wallet address → copy address
6. Deploy `Faucet` → `tokenAddress` = MyToken address → copy address
7. MyToken → `transfer(faucetAddress, 500000000000000000000000)`
8. Verify: `Faucet.getFaucetBalance()` → `500000000000000000000000`

Update `frontend/src/config.js`:

```js
export const TOKEN_ADDRESS  = "0x...";   // MyToken
export const FAUCET_ADDRESS = "0x...";   // Faucet
```

---

### Step 2 — OPN Chain Node (differentiator)

```bash
chmod +x scripts/setup-node.sh
sudo ./scripts/setup-node.sh
```

Optimizations applied automatically:

- `db_backend = "rocksdb"`
- `send_rate = recv_rate = 5120000`
- RPC ports `26657` and `8545` → `127.0.0.1` only
- `chmod 600` on private keys
- `fstrim.timer` for NVMe

Follow printed next steps (binary, genesis, seeds). Docs: https://iopn.gitbook.io/developer-docs/node-overview

---

### Step 3 — Nginx + SSL

```bash
sudo ./scripts/setup-vps.sh
```

Edit `DOMAIN` and `EMAIL` at the top of the script first.

---

### Step 4 — Build & Deploy Frontend

```powershell
.\scripts\deploy-frontend.ps1
```

Edit `$VPS_USER`, `$VPS_IP`, `$DOMAIN` at the top first.

---

### Step 5 — GitHub

```bash
bash scripts/git-init.sh
```

Edit `GITHUB_USERNAME` in the script first.

---

### Step 6 — After Remix: Final Update

```bash
git add frontend/src/config.js README.md
git commit -m "chore: add deployed contract addresses (OPN Testnet 984)"
git push

.\scripts\deploy-frontend.ps1
```

---

## Running Locally

```bash
cd frontend
npm install
npm start
```

MetaMask must be on OPN Testnet (Chain ID: 984).

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

## Roadmap

| Phase | Goal |
|-------|------|
| 1 · Current | ERC20 faucet on OPN Testnet, self-hosted node, Nginx |
| 2 · Post-Mainnet | Production deploy; Neo ID ZK-KYC Sybil protection |
| 3 · Ecosystem | Node Telemetry dashboard; multi-token faucet support |

---

## OPN Builders Submission

Copy-paste guide: [docs/OPN_BUILDERS_SUBMISSION.md](docs/OPN_BUILDERS_SUBMISSION.md)

---

## License

MIT
