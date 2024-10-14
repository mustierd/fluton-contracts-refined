import type { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-viem";
import "@nomicfoundation/hardhat-toolbox-viem";
import "@nomicfoundation/hardhat-foundry";
import dotenv from "dotenv";

dotenv.config();

if (!process.env.PRIVATE_KEY_1) {
  throw new Error("PRIVATE_KEY_1 is not set");
}

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.27",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  defaultNetwork: "sepolia",
  networks: {
    sepolia: {
      url: "https://rpc.sepolia.org",
      accounts: [process.env.PRIVATE_KEY_1],
      chainId: 11155111,
    },
    baseTestnet: {
      url: "https://sepolia.base.org",
      accounts: [process.env.PRIVATE_KEY_1],
      chainId: 84532,
    },
    optimismTestnet: {
      url: "https://sepolia.optimism.io",
      accounts: [process.env.PRIVATE_KEY_1],
      chainId: 11155420,
    },
    arbitrumTestnet: {
      url: "https://arbitrum-sepolia.blockpi.network/v1/rpc/public",
      accounts: [process.env.PRIVATE_KEY_1],
      chainId: 421614,
    },

    mainnet: {
      url: "https://eth.llamarpc.com",
      accounts: [process.env.PRIVATE_KEY_1],
      chainId: 1,
    },
    baseMainnet: {
      url: "https://base.llamarpc.com",
      accounts: [process.env.PRIVATE_KEY_1],
      chainId: 8453,
    },
    optimismMainnet: {
      url: "https://optimism.llamarpc.com",
      accounts: [process.env.PRIVATE_KEY_1],
      chainId: 10,
    },
    arbitrumMainnet: {
      url: "https://arbitrum.llamarpc.com",
      accounts: [process.env.PRIVATE_KEY_1],
      chainId: 42161,
    },
  },
};

export default config;
