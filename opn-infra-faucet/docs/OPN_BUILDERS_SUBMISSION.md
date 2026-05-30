# OPN Builders — Submission Guide

> Open alongside the OPN Builders portal form.
> All blocks are copy-paste ready. Replace placeholders per the table below.

---

## Placeholders

| Placeholder | Replace with | When |
|-------------|-------------|------|
| `YOUR_GITHUB` | GitHub username | after `git push` |
| `YOUR_DOMAIN` | domain without https:// | after VPS + SSL |
| `MYTOKEN_ADDRESS` | MyToken address from Remix | after Remix deploy |
| `FAUCET_ADDRESS` | Faucet address from Remix | after Remix deploy |
| `TX_MYTOKEN` | MyToken deploy TX hash | after Remix deploy |
| `TX_FAUCET` | Faucet deploy TX hash | after Remix deploy |

---

## STEP 1 — Basics

**Project name**

```
OPN Infrastructure Faucet & Node Monitor
```

**One-line tagline**

```
High-availability ERC20 Token Faucet running on a self-hosted OPN Chain RPC node
```

**Demo URL**

```
https://faucet.YOUR_DOMAIN
```

> Ensure 100% uptime during the judging period.

**Repository URL**

```
https://github.com/YOUR_GITHUB/opn-infra-faucet
```

> Must be public. README must describe architecture and local run instructions.

---

## STEP 2 — Contracts

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
DeFi developers on OPN Testnet rely on centralized public RPC endpoints with
aggressive rate-limiting and no uptime guarantees. There is no stable,
sovereign infrastructure for distributing test tokens, which slows down the
smart contract development and testing cycle.
```

**Solution**

```
A decentralized ERC20 faucet connected to a self-hosted OPN Chain full node
behind an Nginx reverse proxy with TLS. The node runs with RocksDB backend
and tuned Tendermint P2P parameters, eliminating rate-limiting and single
points of failure for the entire developer ecosystem.
```

**How it works**

```
1. User connects an EVM-compatible wallet (MetaMask).
2. React frontend auto-switches to OPN Testnet (Chain ID 984).
3. Requests route through Nginx (/rpc) → localhost:8545 → self-hosted OPN node.
4. Faucet contract verifies on-chain Sybil guard (24h cooldown per address).
5. Tendermint BFT finalizes the transaction in ~1 second.
6. UI updates balances in real time via ethers.js listeners.
```

---

## STEP 4 — Roadmap

```
Phase 1 — Current (OPN Testnet):
  ✓ ERC20 faucet with self-hosted OPN Chain full node
  ✓ RocksDB backend, tuned P2P, UFW port isolation
  ✓ Nginx reverse proxy with TLS, CORS, Sybil protection

Phase 2 — Post-Mainnet:
  → Production deployment on OPN Chain Mainnet
  → Neo ID ZK-KYC integration for enhanced Sybil resistance

Phase 3 — Ecosystem tooling:
  → Node Telemetry dashboard — public node metrics for OPN developers
  → Multi-token faucet for other ERC20 projects on OPN Chain
```

---

## STEP 5 — Review checklist

- [ ] Demo URL loads over HTTPS without errors
- [ ] MetaMask connects, Chain ID shows 984
- [ ] "Request tokens" button works end-to-end
- [ ] GitHub repo is **public**, README covers architecture + local run
- [ ] Contract addresses are clickable on testnet.iopn.tech
- [ ] All 6 placeholders replaced

---

## Final git commit after Remix

```bash
git add frontend/src/config.js README.md docs/OPN_BUILDERS_SUBMISSION.md
git commit -m "chore: add deployed contract addresses (OPN Testnet 984)"
git push
```
