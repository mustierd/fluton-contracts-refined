// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import hre from "hardhat";
import tokens from "../../config/tokens";
import addresses from "../../config/union";

const LockModule = buildModule("BridgeTestModule", (m) => {
  const networkId = hre.network.config.chainId;

  if (networkId === undefined) {
    throw new Error("Unknown network id");
  }

  const wrappedNativeTokenAddress = tokens[networkId].find((t) => t.symbol === "WETH")?.address;
  const ibcHandlerAddress = addresses[networkId].IBCHandler;
  const timeoutInSeconds = 60 * 60 * 24 * 7; // 7 days

  if (wrappedNativeTokenAddress === undefined || ibcHandlerAddress === undefined) {
    throw new Error("Missing configuration");
  }

  const wrappedNativeToken = m.getParameter("_wrappedNativeToken", wrappedNativeTokenAddress);
  const ibcHandler = m.getParameter("_ibcHandler", ibcHandlerAddress);
  const timeout = m.getParameter("_timeout", timeoutInSeconds);

  const bridgeTest = m.contract("BridgeTest", [wrappedNativeToken, ibcHandler, timeout]);

  return { bridgeTest };
});

export default LockModule;
