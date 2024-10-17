pragma solidity ^0.8.27;

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
  event IntentFulfilled(Intent calldata intent);
  event IntentCreated(Intent calldata intent);
  event IntentRepaid(Intent calldata intent);


  // FUNCTIONS
  function bridge(Intent calldata intent) external;
  function fulfillIntent(Intent calldata intent) external;
  function repayIntent(Intent calldata intent) external;
}