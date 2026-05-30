# Contract Deployment (Remix)

Deploy on **OPN Testnet** — Chain ID **984**.

## Prerequisites

1. MetaMask on OPN Testnet (984)
2. Test OPN for gas: https://faucet.iopn.tech
3. Files in `remix/` folder (Remix-compatible imports)

## Steps

### 1. Deploy MyToken

1. Open https://remix.ethereum.org
2. Create `MyToken.sol` — paste from `remix/MyToken.sol`
3. Compiler: **0.8.20**, Optimization **200 runs**
4. Environment: **Injected Provider — MetaMask**
5. Deploy → sign → copy **contract address** and **deploy TX hash**

### 2. Deploy Faucet

1. Create `Faucet.sol` — paste from `remix/Faucet.sol` or `contracts/Faucet.sol`
2. Deploy with constructor: `tokenAddress` = **MyToken address from step 1**
3. Copy **Faucet address** and **deploy TX hash**

### 3. Fund the faucet

In Remix, on **MyToken** → `transfer`:

| Field | Value |
|-------|-------|
| `to` | Faucet address |
| `amount` | `500000000000000000000000` |

### 4. Verify

On **Faucet** → `getFaucetBalance()` → should return `500000000000000000000000`.

### 5. Update the project

Replace placeholders in `frontend/src/config.js`:

```javascript
export const TOKEN_ADDRESS = "0x...";  // MyToken
export const FAUCET_ADDRESS = "0x...";  // Faucet
```

Explorer links:

```
https://testnet.iopn.tech/tx/<TX_MYTOKEN>
https://testnet.iopn.tech/tx/<TX_FAUCET>
```

Rebuild frontend — see [DEPLOYMENT.md](./DEPLOYMENT.md) Phase B2.

## Automated alternative

```bash
cp .env.example .env
# Add DEPLOYER_PRIVATE_KEY=0x... (never commit .env)
npm install
npm run deploy
```

Updates `config.js`, README, and `hackathon-application.md` automatically.
