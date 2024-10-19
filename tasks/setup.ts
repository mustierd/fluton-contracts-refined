import { task } from "hardhat/config";

const setupTask = task(
  "setup",
  "Deploys BridgeTest contract on sourceNetwork and targetNetwork and establishes a connection between them with Union infrastructure"
)
  .addPositionalParam("sourceNetwork", "example: sepolia")
  .addPositionalParam("targetNetwork", "example: scrollSepolia")
  .setAction(async ({ sourceNetwork, targetNetwork }, hre) => {
    const supportedNetworks = Object.keys(hre.config.networks);

    if (!supportedNetworks.includes(sourceNetwork) || !supportedNetworks.includes(targetNetwork)) {
      throw new Error("Source or target network not found");
    }

    const bridgeTestSourceAddress = await hre.run("deploy", {
      sourceNetwork: sourceNetwork,
    });

    const bridgeTestTargetAddress = await hre.run("deploy", {
      sourceNetwork: targetNetwork,
    });
  });

export default setupTask;
