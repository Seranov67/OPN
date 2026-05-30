# Deployment Guide

Complete the project **without** contract addresses first, then add addresses later.

---

## Phase A — GitHub (no contracts required)

1. Edit `scripts/git-init.sh` — set `GITHUB_USERNAME=your-username`
2. From project root (Git Bash):

```bash
bash scripts/git-init.sh
```

3. Repository will be: `https://github.com/YOUR_GITHUB/opn-infra-faucet`

Placeholders in README and `config.js` are intentional until Phase C.

---

## Phase B — VPS + Node + HTTPS (no contracts required)

### B0. OPN Chain node (optional, recommended for sysadmin track)

```bash
chmod +x scripts/setup-node.sh
sudo ./scripts/setup-node.sh
```

Then download binary, genesis, and seeds per script output. Docs: https://iopn.gitbook.io/developer-docs/node-overview

### B1. On the VPS (as root)

Edit top of `scripts/setup-vps.sh`:

```bash
DOMAIN="faucet.your-domain.com"   # your real domain
EMAIL="admin@your-domain.com"     # for Let's Encrypt
```

Run:

```bash
chmod +x setup-vps.sh
sudo ./setup-vps.sh
```

This installs Nginx, firewall rules, SSL (certbot), and serves `/var/www/faucet`.

### B2. On Windows (local)

Edit `scripts/deploy-frontend.ps1`:

```powershell
$VPS_USER = "ubuntu"              # SSH user
$VPS_IP   = "1.2.3.4"             # VPS IP
$DOMAIN  = "faucet.your-domain.com"
```

Run:

```powershell
.\scripts\deploy-frontend.ps1
```

### B3. Verify

Open `https://faucet.your-domain.com` — UI should load.  
**Get Tokens** will fail until `config.js` has real addresses.

---

## Phase C — Smart contracts (required for working faucet)

Choose **one** method:

| Method | Doc |
|--------|-----|
| Remix + MetaMask | [CONTRACTS.md](./CONTRACTS.md) |
| Automated (private key in `.env`) | root `README.md` → `npm run deploy` |

After deploy, update **only these two lines** in `frontend/src/config.js`:

```javascript
export const TOKEN_ADDRESS = "0x...";  // MyToken
export const FAUCET_ADDRESS = "0x...";  // Faucet
```

Then repeat Phase B2 (`deploy-frontend.ps1`).

---

## Phase D — OPN Builders submission

See [OPN_BUILDERS_SUBMISSION.md](./OPN_BUILDERS_SUBMISSION.md).

---

## Optional: self-hosted RPC

If you run an OPN node on `localhost:8545`, set in `config.js`:

```javascript
export const RPC_URL = "https://faucet.YOUR_DOMAIN/rpc";
```

Nginx proxies `/rpc` → `127.0.0.1:8545` (configured in `setup-vps.sh`).

Without a node, keep the public RPC:

```javascript
export const RPC_URL = "https://testnet-rpc.iopn.tech";
```
