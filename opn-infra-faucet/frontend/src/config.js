// Replace after deploying contracts on OPN Testnet (Chain ID 984)
// See: docs/CONTRACTS.md

export const TOKEN_ADDRESS = "MYTOKEN_ADDRESS"; // MyToken  → 0x...
export const FAUCET_ADDRESS = "FAUCET_ADDRESS"; // Faucet   → 0x...

export const CHAIN_ID = 984;
export const CHAIN_ID_HEX = "0x3D8";
export const RPC_URL = "https://testnet-rpc.iopn.tech"; // or https://faucet.YOUR_DOMAIN/rpc

export const NETWORK = {
  chainId: CHAIN_ID_HEX,
  chainName: "OPN Testnet",
  nativeCurrency: {
    name: "OPN",
    symbol: "OPN",
    decimals: 18,
  },
  rpcUrls: [RPC_URL],
  blockExplorerUrls: ["https://testnet.iopn.tech"],
};

export const TOKEN_ABI = [
  "function name() view returns (string)",
  "function symbol() view returns (string)",
  "function balanceOf(address) view returns (uint256)",
  "function decimals() view returns (uint8)",
  "function transfer(address to, uint256 amount) returns (bool)",
];

export const FAUCET_ABI = [
  "function requestTokens()",
  "function getFaucetBalance() view returns (uint256)",
  "function cooldownRemaining(address user) view returns (uint256)",
  "function amountAllowed() view returns (uint256)",
  "function lastAccessTime(address) view returns (uint256)",
  "event SendToken(address indexed to, uint256 amount)",
];

export const DEFAULT_DRIP_AMOUNT = 100n * 10n ** 18n;
