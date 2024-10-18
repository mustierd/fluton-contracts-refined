pragma solidity ^0.8.27;

import "./union/apps/Base.sol";
import "./union/core/25-handler/IBCHandler.sol";

interface BridgeTestInterface {
  // ENUMS
  enum FilledStatus {
    NOT_FILLED,
    FILLED
  }


  // STRUCTS
  struct Intent {
    address sender;
    address receiver;
    address relayer;
    address inputToken;
    address outputToken;
    uint256 inputAmount;
    uint256 outputAmount;
    uint256 id;
    uint32 originChainId;
    uint32 destinationChainId;
    FilledStatus filledStatus;
  }


  // EVENTS
  event IntentFulfilled(Intent intent);
  event IntentCreated(Intent intent);
  event IntentRepaid(Intent intent);

  function bridge(Intent calldata intent) external;
  function fulfill(Intent calldata intent) external;
  

  // ERRORS

}