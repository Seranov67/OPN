// Contract addresses — update after Remix deployment
export const TOKEN_ADDRESS = "0x0000000000000000000000000000000000000000";
export const FAUCET_ADDRESS = "0x0000000000000000000000000000000000000000";

export const CHAIN_ID = 984;
export const CHAIN_ID_HEX = "0x3D8";

export const NETWORK = {
  chainId: CHAIN_ID_HEX,
  chainName: "OPN Testnet",
  nativeCurrency: {
    name: "OPN",
    symbol: "OPN",
    decimals: 18,
  },
  rpcUrls: ["https://testnet-rpc.iopn.tech"],
  blockExplorerUrls: ["https://testnet.iopn.tech"],
};

export const TOKEN_ABI = [
  "function balanceOf(address account) view returns (uint256)",
  "function symbol() view returns (string)",
  "function decimals() view returns (uint8)",
];

export const FAUCET_ABI = [
  "function requestTokens() external",
  "function getFaucetBalance() view returns (uint256)",
  "function timeUntilNextRequest(address user) view returns (uint256)",
  "function DRIP_AMOUNT() view returns (uint256)",
  "function COOLDOWN() view returns (uint256)",
  "event SendToken(address indexed to, uint256 amount)",
];

export const DRIP_AMOUNT = 100n * 10n ** 18n;
