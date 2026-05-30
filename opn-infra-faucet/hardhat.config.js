require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

const PRIVATE_KEY = process.env.DEPLOYER_PRIVATE_KEY || "";

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: { enabled: true, runs: 200 },
    },
  },
  paths: {
    sources: "./contracts",
  },
  networks: {
    opnTestnet: {
      url: process.env.RPC_URL || "https://testnet-rpc.iopn.tech",
      chainId: 984,
      accounts: PRIVATE_KEY ? [PRIVATE_KEY] : [],
    },
  },
};
