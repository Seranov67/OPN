# Contract Deployment (Remix)

Deploy on **OPN Testnet** — Chain ID **984**.

## Prerequisites

1. MetaMask on OPN Testnet (984)
2. Test OPN for gas: https://faucet.iopn.tech
3. Files in `remix/` folder

## Steps

### 1. Deploy MyToken

1. Open https://remix.ethereum.org
2. Paste `remix/MyToken.sol`
3. Compiler: **0.8.20**, Optimization **200 runs**
4. Environment: **Injected Provider — MetaMask**
5. Deploy with constructor **`initialOwner`** = your wallet address
6. Copy contract address and deploy TX hash

### 2. Deploy Faucet

1. Paste `remix/Faucet.sol`
2. Deploy with **`tokenAddress`** = MyToken address from step 1
3. Copy Faucet address and deploy TX hash

### 3. Fund the faucet

On **MyToken** → `transfer`:

| Field | Value |
|-------|-------|
| `to` | Faucet address |
| `amount` | `500000000000000000000000` |

### 4. Verify

On **Faucet**:

- `getFaucetBalance()` → `500000000000000000000000`
- `amountAllowed()` → `100000000000000000000` (100 OPIT)
- `cooldownRemaining(yourAddress)` → `0` before first claim

### 5. Update the project

```javascript
// frontend/src/config.js
export const TOKEN_ADDRESS = "0x...";
export const FAUCET_ADDRESS = "0x...";
```

Rebuild: `.\scripts\deploy-frontend.ps1`

## Owner functions (optional)

After deploy, Faucet owner can call:

- `setAmountAllowed(uint256)` — change drip size
- `withdrawAll(address)` — emergency token recovery

## Automated alternative

```bash
cp .env.example .env
# DEPLOYER_PRIVATE_KEY=0x...
npm install
npm run deploy
```
