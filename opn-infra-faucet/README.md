# OPN Infrastructure Faucet

High-availability ERC20 faucet on OPN Testnet with optional self-hosted RPC node behind Nginx.

## Architecture

```
┌──────────┐     HTTPS      ┌─────────────────────────────────────┐
│   User   │ ──────────────▶│              Nginx (VPS)            │
│ MetaMask │                │                                     │
└──────────┘                │  /          →  /var/www/faucet (React)│
                            │  /rpc       →  localhost:8545 (Node) │
                            └──────────┬──────────────┬─────────────┘
                                       │              │
                              Static React      OPN Chain Node
                              (ethers.js)       (JSON-RPC)
                                       │              │
                                       └──────┬───────┘
                                              ▼
                                    OPN Testnet (Chain ID: 984)
                                    ┌─────────────────────┐
                                    │  MyToken (OPIT)     │
                                    │  Faucet Contract    │
                                    └─────────────────────┘
```

**Flow:** MetaMask → React Frontend → Nginx → OPN Node → Smart Contracts

## Project Structure

```
opn-infra-faucet/
├── contracts/
│   ├── MyToken.sol       # ERC20 token (1M OPIT)
│   └── Faucet.sol        # Faucet with 24h rate limit
├── frontend/
│   ├── src/
│   │   ├── App.js        # Main UI component
│   │   └── config.js     # Contract addresses + ABI
│   └── package.json
├── nginx/
│   └── nginx.conf        # VPS reverse proxy config (reference)
├── scripts/
│   ├── setup-vps.sh      # VPS: Nginx + SSL (run on server)
│   ├── deploy-frontend.ps1  # Build + scp (run on Windows)
│   └── git-init.sh       # GitHub init + push (Git Bash)
└── README.md
```

## Network Configuration

| Parameter  | Value                              |
|------------|------------------------------------|
| Network    | OPN Testnet                        |
| Chain ID   | 984                                |
| RPC        | https://testnet-rpc.iopn.tech      |
| Symbol     | OPN                                |
| Explorer   | https://testnet.iopn.tech          |
| OPN Faucet | https://faucet.iopn.tech           |

Add OPN Testnet to MetaMask manually or let the frontend auto-add it on connect.

## Deployed Contracts

> Плейсхолдери: `MYTOKEN_ADDRESS`, `FAUCET_ADDRESS` у `frontend/src/config.js` та `hackathon-application.md`.  
> Після Remix: `bash scripts/apply-addresses.sh` або `.\scripts\apply-addresses.ps1`

| Contract | Address         | Deploy TX |
|----------|-----------------|-----------|
| MyToken  | MYTOKEN_ADDRESS | https://testnet.iopn.tech/tx/TX_MYTOKEN |
| Faucet   | FAUCET_ADDRESS  | https://testnet.iopn.tech/tx/TX_FAUCET  |

Chain ID: **984**

## Автодеплой (замість Remix)

Якщо є гаманець з тестовими OPN:

```bash
# 1. Скопіювати .env.example → .env
# 2. Вставити приватний ключ MetaMask (НЕ надсилати в чат!)
DEPLOYER_PRIVATE_KEY=0x...

# 3. OPN на gas: https://faucet.iopn.tech
npm run deploy
```

Скрипт задеплоїть MyToken + Faucet, поповнить кран 500k OPIT і оновить `config.js`, `README.md`, `hackathon-application.md`.

Remix-версії контрактів: папка `remix/`.

## Quick Deploy (після Remix)

```
Remix → адреси контрактів
    ↓
config.js оновлено
    ↓
setup-vps.sh (на VPS)
    ↓
deploy-frontend.ps1 (локально, Windows)
    ↓
git-init.sh (локально, Git Bash)
    ↓
Заявка на хакатон
```

### 1. `scripts/setup-vps.sh` — на VPS від root

Змінити вгорі файлу: `DOMAIN`, `EMAIL`

```bash
chmod +x setup-vps.sh
sudo ./setup-vps.sh
```

### 2. `scripts/deploy-frontend.ps1` — локально (PowerShell)

Змінити: `$VPS_USER`, `$VPS_IP`, `$DOMAIN`

```powershell
.\scripts\deploy-frontend.ps1
```

### 3. `scripts/git-init.sh` — локально (Git Bash)

Змінити: `GITHUB_USERNAME`, запускати з кореня проєкту

```bash
bash scripts/git-init.sh
```

## Day 1 — Smart Contracts (Remix)

### 1. Get test OPN

Visit https://faucet.iopn.tech and request test OPN for gas.

### 2. Deploy MyToken

1. Open [Remix IDE](https://remix.ethereum.org)
2. Create `MyToken.sol` from `contracts/MyToken.sol`
3. Compiler: **0.8.20**, enable optimization (200 runs)
4. Environment: **Injected Provider — MetaMask** (OPN Testnet)
5. Deploy → sign transaction
6. Copy contract address from Remix console

### 3. Deploy Faucet

1. Create `Faucet.sol` from `contracts/Faucet.sol`
2. Deploy with constructor parameter: **MyToken address**
3. Copy Faucet address

### 4. Fund the Faucet

In Remix, call on MyToken contract:

```
transfer(faucet_address, 500000000000000000000000)
```

This sends 500,000 OPIT (with 18 decimals) to the faucet.

### 5. Verify on Explorer

Open https://testnet.iopn.tech, find both contracts, save deploy TX links for the hackathon submission.

## Day 2 — Infrastructure (VPS)

### Server Setup

```bash
apt update && apt upgrade -y
apt install -y nginx certbot python3-certbot-nginx ufw git curl

ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 26656/tcp   # P2P node
ufw deny 26657/tcp    # RPC — only via Nginx
ufw enable
```

### OPN Chain Node (optional, +points)

Follow official docs: https://iopn.gitbook.io/developer-docs/node-overview

If skipped, the frontend uses the public RPC (`https://testnet-rpc.iopn.tech`).

### Nginx + SSL

```bash
cp nginx/nginx.conf /etc/nginx/sites-available/faucet
ln -s /etc/nginx/sites-available/faucet /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx

mkdir -p /var/www/faucet
certbot --nginx -d faucet.your-domain.com
```

Replace `faucet.your-domain.com` in the config with your actual domain.

## Day 3 — Frontend

### Local Development

```bash
cd frontend
npm install
```

Update `frontend/src/config.js` with deployed contract addresses:

```js
export const TOKEN_ADDRESS = "0xYourMyTokenAddress";
export const FAUCET_ADDRESS = "0xYourFaucetAddress";
```

```bash
npm start     # http://localhost:3000
npm run build # production build
```

### Deploy to VPS

```bash
scp -r build/* user@vps:/var/www/faucet/
```

## Interface Screenshot

<!-- Replace with actual screenshot after deployment -->
![Faucet UI](./docs/screenshot.png)

## Hackathon Submission

| Field       | Value |
|-------------|-------|
| Project     | OPN Infrastructure Faucet |
| Tagline     | High-availability ERC20 faucet on self-hosted OPN RPC node |
| Demo URL    | https://faucet.your-domain.com |
| Repository  | https://github.com/you/opn-infra-faucet |
| Problem     | Dependency on public RPCs with rate-limiting |
| Solution    | Self-hosted node + Nginx proxy + ERC20 faucet |
| How it works| MetaMask → React → Nginx → OPN Node → Smart Contract |
| Roadmap     | Neo ID KYC integration for Sybil protection on Mainnet |

## License

MIT
