import BridgeTestModule from "../../ignition/modules/BridgeTest";
import tokens from "../../config/tokens";
import addresses from "../../config/union";
import { HardhatRuntimeEnvironment } from "hardhat/types";

async function deploy({ networkId }: { networkId: number }, hre: HardhatRuntimeEnvironment) {
  const wrappedNativeTokenAddress = tokens[networkId].find((t) => t.symbol === "WETH")?.address;
  const ibcHandlerAddress = addresses[networkId].IBCHandler;

  if (!wrappedNativeTokenAddress || !ibcHandlerAddress) {
    throw new Error("Missing addresses");
  }

  const { bridgeTest } = await hre.ignition.deploy(BridgeTestModule, {
    parameters: {
      BridgeTestModule: {
        _wrappedNativeToken: wrappedNativeTokenAddress,
        _ibcHandler: ibcHandlerAddress,
      },
    },
  });

  console.log(`BridgeTest deployed to: ${bridgeTest.address}`);

  return bridgeTest.address;
}

export default deploy;
