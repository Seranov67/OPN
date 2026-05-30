# OPN Builders — Submission Guide

> Open this file next to the submission form at the OPN Builders portal.
> Copy each block into the corresponding field. Replace placeholders as instructed.

---

## Placeholders — replace before submitting

| Placeholder | Replace with | When |
|-------------|-------------|------|
| `YOUR_GITHUB` | your GitHub username | after `git push` |
| `YOUR_DOMAIN` | your domain (without https://) | after VPS + SSL |
| `MYTOKEN_ADDRESS` | MyToken contract address from Remix | after contract deployment |
| `FAUCET_ADDRESS` | Faucet contract address from Remix | after contract deployment |
| `TX_MYTOKEN` | MyToken deploy TX hash | after contract deployment |
| `TX_FAUCET` | Faucet deploy TX hash | after contract deployment |

---

## STEP 1 — Basics

**Project name**

```
OPN Infrastructure Faucet
```

**One-line tagline**

```
High-availability ERC20 faucet on self-hosted OPN Chain RPC node behind Nginx
```

**Demo URL**

```
https://faucet.YOUR_DOMAIN
```

> Replace `YOUR_DOMAIN` after VPS and SSL are up. Verify the URL loads before submitting.

**Repository URL**

```
https://github.com/YOUR_GITHUB/opn-infra-faucet
```

> Replace `YOUR_GITHUB` after `git push`. Repository must be **public**.

---

## STEP 2 — Contracts

> Fill this step only after Remix deployment.

**MyToken (OPIT)**

```
Address:   MYTOKEN_ADDRESS
Network:   OPN Testnet
Chain ID:  984
Explorer:  https://testnet.iopn.tech/address/MYTOKEN_ADDRESS
Deploy TX: https://testnet.iopn.tech/tx/TX_MYTOKEN
```

**Faucet**

```
Address:   FAUCET_ADDRESS
Network:   OPN Testnet
Chain ID:  984
Explorer:  https://testnet.iopn.tech/address/FAUCET_ADDRESS
Deploy TX: https://testnet.iopn.tech/tx/TX_FAUCET
```

---

## STEP 3 — Description

**Problem**

```
DeFi developers on OPN Testnet rely on centralized public RPC endpoints
with aggressive rate-limiting and no uptime guarantees. There is no
stable, self-sovereign infrastructure for distributing test tokens,
which slows down the smart contract development and testing cycle.
```

**Solution**

```
A decentralized ERC20 faucet connected to a self-hosted OPN Chain full
node behind an Nginx reverse proxy with TLS. This architecture eliminates
rate-limiting and single points of failure, providing uninterrupted access
to test liquidity for the entire developer ecosystem.
```

**How it works**

```
1. User connects an EVM-compatible wallet (MetaMask).
2. React frontend automatically switches to OPN Testnet (Chain ID 984).
3. Requests route through Nginx → private RPC endpoint → self-hosted OPN node.
4. Faucet contract validates Sybil protection (24h on-chain cooldown per address).
5. Tendermint BFT finalizes the transaction in ~1 second.
6. UI updates faucet and user balances in real time via ethers.js event listeners.
```

---

## STEP 4 — Roadmap

```
Phase 1 — Current (OPN Testnet):
  - ERC20 faucet deployed with self-hosted RPC node
  - Nginx reverse proxy: SSL, CORS, security headers
  - On-chain Sybil protection (24h cooldown)

Phase 2 — Post-Mainnet:
  - Production deployment on OPN Chain Mainnet
  - Neo ID ZK-KYC integration for enhanced Sybil resistance

Phase 3 — Ecosystem tooling:
  - Node Telemetry dashboard with public performance metrics
    for developers integrating with OPN Chain
  - Multi-token faucet support for other ERC20 projects on OPN
```

---

## STEP 5 — Review checklist

Before clicking Submit, verify:

- [ ] Demo URL opens over HTTPS without errors
- [ ] MetaMask connects and shows Chain ID 984
- [ ] "Request tokens" button works (test after Remix)
- [ ] GitHub repository is **public** and README is complete
- [ ] Contract addresses link correctly in testnet.iopn.tech
- [ ] All placeholders replaced: `YOUR_DOMAIN`, `YOUR_GITHUB`,
      `MYTOKEN_ADDRESS`, `FAUCET_ADDRESS`, `TX_MYTOKEN`, `TX_FAUCET`

---

## Final git commit after Remix

```bash
git add frontend/src/config.js README.md docs/OPN_BUILDERS_SUBMISSION.md
git commit -m "chore: add deployed contract addresses (OPN Testnet 984)"
git push
```
