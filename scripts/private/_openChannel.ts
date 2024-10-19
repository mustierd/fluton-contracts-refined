import { HardhatRuntimeEnvironment } from "hardhat/types";
import addresses from "../../config/union";
import { zeroAddress } from "viem";

const application_default_pingpong_timeout = "36000000000000";
const application_protocol_version = "ucs00-bridgetest-1";
const channel_state_init = 1;
const channel_order_unordered = 1;
const channel_connection = "connection-5";
const channel_connection_arb = "connection-0";

interface OpenChannelParams {
  sourceNetworkId: number;
  targetNetworkId: number;
  sourceContractAddress: string;
  targetContractAddress: string;
}

async function openChannel(
  { sourceNetworkId, targetNetworkId, sourceContractAddress, targetContractAddress }: OpenChannelParams,
  hre: HardhatRuntimeEnvironment
) {
  const ibcHandlerAddress = addresses[sourceNetworkId].IBCHandler;

  if (!ibcHandlerAddress) {
    throw new Error("Missing addresses");
  }

  const ibcHandlerContract = await hre.viem.getContractAt("IBCHandler", ibcHandlerAddress);

  console.log(`Opening channel from ${sourceNetworkId} to ${targetNetworkId}`);

  const asd = await ibcHandlerContract.write.channelOpenInit([
    {
      portId: "", // A valid string representing portId
      channel: {
        state: channel_state_init, // uint8 for the state enum
        ordering: channel_order_unordered, // uint8 for the ordering enum
        counterparty: {
          port_id: `evm.${targetContractAddress}`, // Counterparty port_id
          channel_id: "", // Empty string for channel_id (ensure this is valid)
        },
        connection_hops: [channel_connection], // String array for connection hops
        version: application_protocol_version, // Version string
      },
      relayer: zeroAddress, // Example relayer address, replace it with the correct relayer address
    },
  ]);

  console.log("Channel opened", asd);
}

export default openChannel;
