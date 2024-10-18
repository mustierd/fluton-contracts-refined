import { arbitrum, arbitrumSepolia, avalanche, mainnet, optimism, scrollSepolia, sepolia } from "viem/chains";

const tokens: { [key: number]: Array<{ symbol: string; address: `0x${string}` }> } = {
  [optimism.id]: [
    {
      symbol: "USDT",
      address: "0x94b008aA00579c1307B0EF2c499aD98a8ce58e58",
    },
    {
      symbol: "USDC",
      address: "0x0b2C639c533813f4Aa9D7837CAf62653d097Ff85",
    },
    { symbol: "WETH", address: "0x4200000000000000000000000000000000000006" },
  ],
  [arbitrum.id]: [
    {
      symbol: "USDT",
      address: "0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9",
    },
    {
      symbol: "USDC",
      address: "0xaf88d065e77c8cC2239327C5EDb3A432268e5831",
    },
    { symbol: "WETH", address: "0x82aF49447D8a07e3bd95BD0d56f35241523fBab1" },
  ],
  [mainnet.id]: [
    {
      symbol: "USDC",
      address: "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48",
    },
    { symbol: "WETH", address: "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2" },
  ],
  [avalanche.id]: [
    {
      symbol: "USDC",
      address: "0x49d5c2bdffac6ce2bfdb6640f4f80f226bc10bab",
    },
    // bridged weth
    { symbol: "WETH", address: "0x49d5c2bdffac6ce2bfdb6640f4f80f226bc10bab" },
  ],
  [sepolia.id]: [
    {
      symbol: "USDC",
      address: "0x2831d2b6b7bd5Ca9E2EEe932055a91f5a6cEBe2f",
    },
    { symbol: "USDT", address: "0x9F1210757915bf7aEE3B5D82F99dac70828Bad77" },
    { symbol: "UNI", address: "0x64BC0Baad7371ece4B6467715bE75f3aa2FBBF0c" },
    { symbol: "WETH", address: "0x7b79995e5f793a07bc00c21412e50ecae098e7f9" },
  ],
  [arbitrumSepolia.id]: [
    {
      symbol: "USDC",
      address: "0x1746FB6484647F83E27Ed43460bbE30883F8F5b5",
    },
    { symbol: "USDT", address: "0xf065447aE1b6597410c4Ef0990F83C5F37bfD5B4" },
    { symbol: "UNI", address: "0x31BB6bC0E8E79eF3F6C983CB145BA7677A98284F" },
    { symbol: "WETH", address: "0x64BC0Baad7371ece4B6467715bE75f3aa2FBBF0c" },
  ],
  [scrollSepolia.id]: [
    {
      symbol: "USDC",
      address: "0xfa6a407c4C49Ea1D46569c1A4Bcf71C3437bE54c",
    },
    { symbol: "USDT", address: "0x7b79995e5f793a07bc00c21412e50ecae098e7f9" },
    { symbol: "UNI", address: "0x7b79995e5f793a07bc00c21412e50ecae098e7f9" },
    { symbol: "WETH", address: "0x49d5c2bdffac6ce2bfdb6640f4f80f226bc10bab" },
  ],
};

export default tokens;
